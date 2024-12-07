# Introduction
This branch represents the minimal changes needed to make CWS executable by QB64.

# Changes
1. Removal of unnecessary files: ABELINCO.EXE, CITYBURN.EXE, CWS.EXE, CWS.LINK, CWSDOC.COM, CWSMAK.BTM, CWSMENU.OBJ, CWSTRAT.OBJ, CWSTRAT2.OBJ, GO.BAT, INSTALL.BAT, PRINTDOC.BAT, README.1ST, WRHGAMES.DOC
2. Addition of changelogs.
3. Addition of .gitignore.
4. Remove of code related to .EXEs:
    - CWSTRAT.BAS lines 60-63, 1009-1014
    - CWSTRAT2.BAS lines 202, 525
    - CWS14.BI line 11
    - CWSMENU.BAS lines 273-280
5. Replace instances of DIR$ with _FILEEXISTS.
