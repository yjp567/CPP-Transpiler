# Compilers - II (CS3423)
# C++ Transpiler

## Description

This project implements a lexer and parser for a custom programming language (details in problem statement) using Lex and Yacc. The parser transpiles the input code into equivalent C++ code and generates logs for tokens and statements encountered during parsing.

## Features

-   **Lexical Analysis**: Tokenizes identifiers, constants, punctuation, reserved words, types, and operators.
    
-   **Syntax Analysis**: Transpiles the input code to C++ following specified syntax rules.
    
-   **Logging**: Generates `tokens.txt` and `parsed.txt` to record recognized tokens and categorized statements.
    

## Files and Directories

-   `lexer.l` - Defines tokenization rules using Lex.
    
-   `parser.y` - Defines grammar and parsing logic using Yacc.
    
-   `Makefile` - Automates the build process.
    
-   `report.pdf` - Documentation and explanations.
    
-   `test/input` - Contains test cases.
    
-   `problem_statement.pdf` - The original assignment statement.
    

## Compilation and Execution

### Prerequisites

Ensure you have `flex` and `bison` installed on your system.

### Build Instructions

To compile the project, run:

```
make
```

This will generate an executable named `parser.o`.

### Running the Parser
To run all test cases , run :
```
make run
```
Alternatively, to execute the parser on a specific test file, run:

```
./parser test/input/t1.txt
```

Replace `test/input/t1.txt` with any other test file as needed.

## Output and Logging
- **Output files** (`<name>.cpp`): The equivalent cpp code file. (Directory: `test/output/`)
-   **Token Log** (`<name>_tokens.txt`): Logs every token with its category. (Directory: `test/tokens/`)
    
-   **Parsed Log** (`<name>_parsed.txt`): Logs statements and function declarations with categories. (Directory: `test/parsed/`)
    

## Testing

Sample test cases are provided in the `test/input` directory. You can run them using the command above.

## Cleanup

To remove generated files, run:

```
make clean
```

## License

This project is for academic purposes only.
