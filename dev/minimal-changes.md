# Minimal Changes to Civil War Strategy Source to Run in QB64

## Introduction

There are a number of small changes which need to be made to the original source code to get Civil War Strategy running in QB64. This document attempts to outline what those changes are.

## File Cleanup

There a number of files which are no longer needed:

- *.OBJ - an intermediary file format created in the process of compiling applications. It is the source code in a different form, it does not contain unique contents that add value to the original source code.
- *.EXE - The DOS binaries won't work on contemporary systems.
- WRHGAMES.DOC and README.1ST - outdated documents.
- PRINTDOC.BAT, INSTALL.BAT, GO.BAT - not needed on modern systems.
- CWSDOC.COM - a very basic guide to CWS
- .MAK, .LNK - Used by the QB compiler but not necessary for QB64.

In addition there are a few files we want to change formats on:

- CWS.DOC => CWS.TXT - It isn't actually a DOC in the sense of a Word document, but a regular text file, so let's change the naming to reflect this.
    - We remove some old DOS characters from the file.
- CWSDOC.COM => CWSDOC.TXT - This is a COM file (an executable) that provides a quick reference to playing CWS. We will rename and remove old COM code.
    - We rmeove some old DOS characters from the file.

Finally, we add two files:

- This file which records the changes we are making.
- A .gitignore file that excludes executables and JetBrain's .idea files.