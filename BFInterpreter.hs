{-------------------------------
----- Brainfuck Interpreter ----
------ implemented in Haskell --
-------- by Blake Oakley -------
--------------------------------}

module Main where
import Data.Maybe ( mapMaybe )
import Data.Char ( ord, chr )
import System.IO ( hFlush, stdout )
import System.Environment ( getArgs )

main :: IO ()
main = do
    bfFileName <- getArgs
    if length bfFileName /= 1
        then error "Must have one file as argument."
        else readFile (head bfFileName) >>= runBF . parseTheBF

{-----------------------
----- The Commands -----
------------------------}
data BFCommand  =   MovR        -- >
                |   MovL        -- <
                |   Inc         -- +
                |   Dec         -- -
                |   Prnt        -- .
                |   Rd          -- ,
                |   LpOp        -- [
                |   LpCl        -- ]

instance Show BFCommand --for fun times in the GHCi
    where show x = case x of
            MovR -> "Move Right"
            MovL -> "Move Left"
            Inc  -> "Increment"
            Dec  -> "Decrement"
            Prnt -> "Print Output"
            Rd   -> "Read Input"
            LpOp -> "Open Loop"
            LpCl -> "Close Loop"

{-----------------------
------ The Parser ------
------------------------}
parseTheBF :: [Char] -> [BFCommand]
parseTheBF xs = if syntaxCheck 0 0 xs 
                then mapMaybe elemToCmnd xs 
                else error "Syntax Failure"
    where elemToCmnd x = case x of
            '>' -> Just MovR
            '<' -> Just MovL
            '+' -> Just Inc
            '-' -> Just Dec
            '.' -> Just Prnt
            ',' -> Just Rd
            '[' -> Just LpOp
            ']' -> Just LpCl
            _   -> Nothing

{-----------------------
------- The Tape -------
------------------------}
-- ? Potential Improvement: make Lists into Streams or Zippers
-- ? Potential Improvement: write a Functor Instance for Tape
data Tape a = Tape [a] a [a]

emptyTape :: Tape Int
emptyTape = Tape [0,0..] 0 [0,0..]

movRght :: Tape a -> Tape a
movRght (Tape left pivot []) = error "Can't do that! There's no more tape to the Right."
movRght (Tape left pivot (r:rs)) = Tape (pivot:left) r rs

movLft :: Tape a -> Tape a
movLft (Tape [] pivot right) = error "Can't do that! There's no more tape to the Left."
movLft (Tape (l:ls) pivot right) = Tape ls l (pivot:right)

{-----------------------
---- The Execution -----
------------------------}
runBF :: [BFCommand] -> IO ()
runBF = run emptyTape . bfSrcToTape
    where   bfSrcToTape [] = error "There's no source code!"
            bfSrcToTape (x:xs) = Tape [] x xs

run :: Tape Int -> Tape BFCommand -> IO ()
run dataTape@(Tape lft piv rght) srcTape@(Tape _ x _) = case x of
    MovR -> onward (movRght dataTape) srcTape           --executes >
    MovL -> onward (movLft dataTape) srcTape            --executes <
    Inc  -> onward (Tape lft (piv+1) rght) srcTape      --executes +
    Dec  -> onward (Tape lft (piv-1) rght) srcTape      --executes -
    Prnt -> do                                          --executes .
        putChar (chr piv)
        hFlush stdout
        onward dataTape srcTape
    Rd   -> do                                          --executes ,
        piv <- getChar
        onward (Tape lft (ord piv) rght) srcTape
    LpOp
        | piv == 0 -> findCloser 0 dataTape srcTape     --executes [
        | otherwise -> onward dataTape srcTape
    LpCl
        | piv /= 0 -> findOpener 0 dataTape srcTape     --executes ]
        | otherwise -> onward dataTape srcTape

{-----------------------
---- Up Next in Src ----
------------------------}
onward :: Tape Int -> Tape BFCommand -> IO ()
onward dataTape (Tape _ _ []) = return ()
onward dataTape srcTape = run dataTape (movRght srcTape)

{-----------------------
---- Handling Loops ----
------------------------}
-- ? Potential Improvement: Explore alternate ways of handling loops as 'subcode with counter'
findCloser :: (Eq a, Num a) => a -> Tape Int -> Tape BFCommand -> IO ()
findCloser 1 dataTape srcTape@(Tape _ LpCl _) = onward dataTape srcTape
findCloser nstLvl dataTape srcTape@(Tape _ LpCl _) = findCloser (nstLvl-1) dataTape (movRght srcTape)
findCloser nstLvl dataTape srcTape@(Tape _ LpOp _) = findCloser (nstLvl+1) dataTape (movRght srcTape)
findCloser nstLvl dataTape srcTape = findCloser nstLvl dataTape (movRght srcTape)

findOpener :: (Eq a, Num a) => a -> Tape Int -> Tape BFCommand -> IO ()
findOpener 1 dataTape srcTape@(Tape _ LpOp _) = onward dataTape srcTape
findOpener nstLvl dataTape srcTape@(Tape _ LpOp _) = findOpener (nstLvl-1) dataTape (movLft srcTape)
findOpener nstLvl dataTape srcTape@(Tape _ LpCl _) = findOpener (nstLvl+1) dataTape (movLft srcTape)
findOpener nstLvl dataTape srcTape = findOpener nstLvl dataTape (movLft srcTape)

{-----------------------
---- Checking Syntax ---
------------------------}
-- ? Potential Improvement: There's probably a better way to do this
syntaxCheck :: (Num a, Ord a) => a -> a -> [Char] -> Bool
syntaxCheck lefts rights [] =
    (lefts == rights) || error "Syntax error: Mismatched brackets"
syntaxCheck lefts rights (x:xs)
    | x == '[' = syntaxCheck (lefts + 1) rights xs
    | x == ']' = if rights >= lefts
                    then error "Syntax error: Mismatched brackets"
                    else syntaxCheck lefts (rights + 1) xs
    | otherwise = syntaxCheck lefts rights xs

-- ? Potential Improvement: Various Optimizations
    -- combining incs and decs (+++++ = (+5))
    -- handling common BF patterns ([-] = set to zero)
    -- better error messages which give location of error