# Brainfuck Interpreter in Haskell

This interpreter checks the syntax, parses, and runs programs written in [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck)

## Compiling and Running the Interpreter

- Be sure to have the Glasgow Haskell Compiler
- Change destination to the directory containing the source code
- In the command line enter:
  `ghc --make BFInterpreter.hs`
- Run the interpreter by entering:
  `.\BFInterpreter.exe .\test03.bf` (Windows)
  `./BFInterpreter ./test03.bf` (Linux)
  where test03.bf is the name of a file containing a Brainfuck program
