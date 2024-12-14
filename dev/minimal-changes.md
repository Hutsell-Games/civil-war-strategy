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
- .MAK, .LNK, .BTM - Used by the QB compiler but not necessary for QB64.

In addition there are a few files we want to change formats on:

- CWS.DOC => CWS.TXT - It isn't actually a DOC in the sense of a Word document, but a regular text file, so let's change the naming to reflect this.
    - We remove some old DOS characters from the file.
- CWSDOC.COM => CWSDOC.TXT - This is a COM file (an executable) that provides a quick reference to playing CWS. We will rename and remove old COM code.
    - We rmeove some old DOS characters from the file.

Finally, we add two files:

- This file which records the changes we are making.
- A .gitignore file that excludes executables and JetBrain's .idea files.

## Code Cleanup

### File References

The next thing we need to do is some minimal code cleanup.

Particularly, we want to remove references in the code to the files that we deleted above.

There are four code files for CWS:

- CWS14.BI - Contains subroutine and variable declarations used throughout the game.
- CWSMENU.BAS - Contains a (somewhat) generic menu system for the game.
- CWSTRAT.BAS - Contains the main game code.
- CWSTRAT2.BAS - Continues the main game code.

In the original QB there were limits to the length of a code file so the main game code is split into two files.

We will use find/replace to remove references to the files we deleted above.

- Remove lines 60, 62, 63 from CWSTRAT.BAS
- Remove the entire burn SUB found in CWSTRAT.BAS
    - the line that calls it in CWSTRAT2.BAS on line 202. 
    - the declaration found in CWS14.BI.
- Remove the reference to abelinco.exe found in CWSTRAT2.BAS
- Remove a reference to cwsdoc.com found in CWSMENU.BAS, on lines 237-280.
- Remove the instruction to press F1 for HELP as this called the old CWSDOC.COM file, it's found in CWSTRAT2.BAS

### Old DOS Characters
Next we remove or replace old unsupported DOS characters. They make look like this: "�". Unless otherwise noted we will replace these with the "+" character.

We'll replace "�" with "|" on these two lines:
```vb
PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / armysize(attack)))))); "%) �";
COLOR 16 - c: PRINT "� Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
```

We'll replace this:
```vb
COLOR 14: LOCATE 23, 50: PRINT "�������������ͻ"
LOCATE 24, 50: PRINT "� U P D A T E �"
LOCATE 25, 50: PRINT "�������������ͼ"
```
With this:
```vb
COLOR 14: LOCATE 23, 50: PRINT "+-----------+"
LOCATE 24, 50: PRINT "| U P D A T E |"
LOCATE 25, 50: PRINT "+-----------+"
```

We'll again replace the "" with a "|" on the following lines:
```vb
LOCATE 2, 7: PRINT STRING$(57, "�")
LOCATE 9, 7: PRINT STRING$(57, "�")
FOR i = 1 TO 6
	LOCATE 2 + i, 7: PRINT "�"; SPACE$(55); "�"
NEXT i
```

And for the two occurrences right near one another we'll use "-":
```vb
PRINT " "; STRING$(70, "-")
PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(INT(aggress! * x))); "00 ]"
PRINT " "; STRING$(70, "-")
```

### Merging the Code Files
The way QB64 handles includes is different from QB and will throw an error if you try running the code in QB off the bat. So we will update our code to reflect this.

We could use the QB64 INCLUDE statement but that requires some reorganization of the code, instead we'll condense the four code files into one.

Paste the contents of CWS14.BI at the top of CWSTRAT.BAS. Remove the duplicate DEFINT A-Z. Once this is done we can delete CWS14.BI.

Take the declarations at the top of CWSTRAT2.BAS and paste them in at the beginning of CWSTRAT.BAS. Again remove the duplicate DEFINT A-Z.

Paste the rest of the contents of CWSTRAT2.BAS into CWSTRAT.BAS.

We follow the same process for the contents of CWSMENU.BAS - declarations at the top, remove duplicate DEFINT, rest of file at the end.

We can then delete these other code files - CWSTRAT2.BAS, CWSMENU.BAS, CWS14.BI.

This makes for quite the lengthy code file, something that I'm not a huge fan of, but we can break it up later.