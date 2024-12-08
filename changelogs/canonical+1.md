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
6. Renamed global variables to reflect their nature in the name, e.g. control => globalControl
7. Removed unused variables: price
8. Remove unused sub declarations: sndfx, sndblst, usamap, blastem, war
9. Move CWS14.BI, CWSTRAT2.BAS, and CWSMENU.BAS into CWSTRAT.BAS
10. Fixed `globalCity$(City$` by replacing with `globalCity$(`
11. Remove unused sub declarations for banner and mountain.
12. Fixed `globalArmyLocrmyLoc` and similar by replacing with `globalArmyLoc` and similar
13. Minor code reformatting
14. Remove screensaver related code