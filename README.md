# Brainfuck Interpreter in Haskell

This interpreter, implemented in Haskell, checks the syntax of, parses, and runs programs written in [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck)

## Compiling and Running the Interpreter

- Be sure to have the Glasgow Haskell Compiler
- Change destination to the directory containing the source code
- In the command line enter:  
  `ghc --make BFInterpreter.hs`
- Run the interpreter by entering:  
  `.\BFInterpreter.exe .\test03.bf` (Windows) or  
  `./BFInterpreter ./test03.bf` (Linux)  
  ...where test03.bf is the name of a file containing a Brainfuck program

## Running the Provided Tests

The following describes the expected results of running the tests:

- test00: Takes an input from the user and returns the character two spots above it (input 'g' would output 'i')
- test01: From the Brainfuck Wikipedia: Adds 2 and 5 and transforms the result to the ASCII to output '7'
- test02: From the Brainfuck Wikipedia: Prints "Hello World!" with a newline
- test03: From the Brainfuck Wikipedia: ROT13 takes a stream of input from the user and outputs each each rotated by 13 places ("hello" becomes "uryyb")
- test04: Contains no Brainfuck source code and should evoke an error message
- test05: Contains mismatched brackets and should evoke a syntax error
- test06: Also contains mismatched brackets and should evoke a syntax error

## Testing Functions in the GHCi

The interactive version of the GHC can be used to test functions within the module, but also to type Braincode directly into the command line and have it interpreted. To do so, within the GHCi enter:  
`$> runBF . parseTheBF $ "<Brainfuckcode>"`  
where \<Brainfuckcode> is syntatically correct Brainfuck.

Example:

```
Prelude> :l BFInterpreter.hs
[1 of 1] Compiling Main             ( BFInterpreter.hs, interpreted )
Ok, one module loaded.
*Main> runBF . parseTheBF $ "+,++."
g
i*Main>
```
