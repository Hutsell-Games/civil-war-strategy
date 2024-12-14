# Contributing to the Civil War Strategy Game

## Development Environment

The original code was written in QuickBasic and it's successor Professional Development System (PDS). Currently the code in newer branches has been written for the QB64 compiler, a QuickBasic compliant compiler.

There are several forks of QB64 out there, we utilize [QB64 Phoenix Edition](https://github.com/QB64-Phoenix-Edition/QB64pe).

QB64 includes an IDE that is very similar to the IDE available in the original QuickBasic software. It includes some advanced functionality (e.g. debugging) that is useful.

For day-to-day code editing we recommend Visual Studio Code or JetBrain's Rider. Neither of these editors actually knows QuickBasic or QB64, but they know some forms of Visual Basic, so one can get by.

## Getting the Repo

Clone the repo to your local system, e.g.:

```
git clone https://github.com/Hutsell-Games/civil-war-strategy.git
```

## Editing / Executing / Debugging the Code in QB64

When you want to use the QB64 IDE, enter the directory you've placed the code in using a terminal. Then run `path-to-qb64pe/qb64pe-binary`. This ensures the working directory for the editor is the same as where your code is.

To run this on windows one might use a command like:

```
c:\qb64pe\qb64pe.exe
```