# Cherry8 🍒🎮

Cherry 8 is an open-source fantasy console, loosely inspired by the Playdate console.

It has its own language, BerryLang, which is heavily inspired by the Tiny BASIC programming
language, expanding on it to provide additiona APIs to interact with the console's video
and sound features.

The console specification doesn't define hardware, but rather a set of features that any
implementation must provide. Which would allow anyone to come up with their own hardware
if wanted. At first, a mobile app and a desktop application will be developed as the
"official" implementations of the console. Hopefully this project grows and the community
creates their own hardwares as well!

## Features

- 128x128 monochrome display
- 8-directional D-pad and 2 action buttons
- 2 meta buttons (start and select)
- TODO: Sound capabilities

## Game cartridge

A game cartridge is the composition of a BerryLang source code file named source.berry,
a README.md file with the game description and a image file named icon.png with a 64x64 icon.

The cartridge can be distributed as a zip file, or an url for a git repository that hosts
that structure.

##  BerryLang language reference

BerryLang is common purpose programming language, heavily inspired by Tiny BASIC, with
the ability to be easialy extended to provide additional APIs.

The choice of Tiny BASIC as the base for BerryLang is motivated by the fact that it is
a language quite easy to build interpreters for, and it is able to provide everything
necessary for someone to create simple games.

### Language structure

BerryLang is language that is line-number based. Lines starts with a number, followed by
the statement.

Example:

```BASIC
10 LET A = 100
20 PRINT A
```

The program will start to execute on the first line.

### Language commands and statements:

 - `PRINT`: Outputs a static text or a variable
 - `LET`: Assigns a value to a variable (Check the next section for more details on variables)
 - `GOTO`: Jumps the execution to a specific line number
 - `IF ... GOTO`: If the condition is true, jumps the execution to a specific line number, otherwise
   continues to the next line
 - `GOSUB`: Jumps to a specific line number, saving the current execution position on a stack
 - `RETURN`: Pops the last execution position from the stack and jumps to it
 - `END`: Ends the program execution

### Variables

Variables are identified by a single letter (A-Z). They can store integer values.

### If statement

The IF statement allows conditional execution of code. The syntax is as follows:

```BASIC
IF <condition> GOTO <line_number>
```

Where `<condition>` can be a comparison between variables and/or integer values using
```
=, <>, <, >, <=, >=
```

Example:

```BASIC
10 LET A = 10
20 IF A > 5 GOTO 50
30 PRINT "A is less than or equal to 5"
40 GOTO 60
50 PRINT "A is greater than 5"
60 END
```

## Project Structure

This repository is structured as mono repository, using dart workspaces for the management
of the packages.

 - `berry_lang`: The BerryLang language implementation.
 - `cherry8_runtime`: The console runtime.
 - `cherry8_cli`: The command line interface to help developers to implement and test their
   games.

The official mobile and desktop apps are not part of this repository since they are apps
published on stores, they are kept in their own private (at least for now) repositories.
