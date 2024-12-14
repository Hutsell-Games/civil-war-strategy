1. image => globalImage
2. Remove unused CWSMENU.BAS
3. size => globalSize
4. side => globalSide
5. replay => globalReplay
6. Minor code reformatting
===
7. Remove unused line labels: iron
8. Remove unused line label code: topbar
9. Move single use rusure inline
10. Move chessie inline
===
11. clrbot => clearBottom; clrrite => clearRight; cannon => drawCannon; capitol => drawCapitol; flags => drawFlags; image2 => drawOverlayBox; integrity => checkMapIntegrity; rwin => drawRebelWin; shen => playShenandoah; shipicon => drawShipIcon; surrender => drawSurrender; usa => drawUSAMap; ironclad => drawIronclad; icon => drawArmyIcon
12. Rearrange some DECLARE SUBs
===
13. recruit => recruitArmy; battle => resolveBattle; events => specialEvents; relieve => relieveCommander; traincapacity => checkTrainCapacity; void => calculateMilitaryPresence; mxw => maxStringWidth; menu => genericMenu; sel1 => menuSelection; crsr => handleUserInput; limits => resetCurrentRow; noadjust => centerMenu; called => onRowChosen
14. Remove unused boss1 line label code
===
15. Removed unused line label: remenu
16. Minor code reformatting
17. choices => drawMenuBox; globalChoose => globalSelectedMenuOption; globalWType => globalWindowType; boxc => menuColor; wide => width; b1 => horizontalOffset; globalMTX => globalMenuText
===
18. Minor code reformatting
===
19. fortify => fortifyCity; resupply => resupplyArmy; combine => combineArmies; capture => captureCity; animate => animateArmy; endit => setEndGameConditions; engine => drawTrainEngine; filer => fileManagement; flashcity => animateFlashCity; tupdate => turnUpdate; armystat => drawArmyStat; drawArmyIcon => drawArmyMove; armies => moveArmy; armxy => drawArmyIcon; commander => assignArmyCommander; topbar => drawTopBar; evaluate => aiEvaluateArmyMoves; iterate => turnIterate; maxx => drawHallOfFame; placearmy => placeArmy; movefrom => chooseMoveArmyFrom; newarmy => createNewArmy; newcity => chooseCityMenu; showcity => drawCity; normal => calculateCasualties; occupy => checkCityOccupied; report => reportsMenu; railroad => resolveRailroadMoves; retreat => handleArmyRetreat; roman => createGenericLeaderNames; scribe => showAndSaveHistory; smarts => aiSmarts; barnacle => sinkShip; cutoff => checkCityCutoff; center => centerText; ships => drawShips; globalBrray => globalArmyMoves; bub2 => sortArmyMoves; bubble => sortMenuOptions; globalArray => globalMenuOptions
===
20. Remove cwsicon.vga, not needed; F1 Help
21. width => menuWidth (width is a QB64 keyword)
22. month => globalMonth (there are two months, globalMonth$ and globalMonth)
===
23. Reformat various comments
24. Fix issue with cannon image bleeding into rest of screen
25. Fix issue with various non-standard characters causing issues
    - TODO: Make nicer
26. Fixed issue with menu erroring out due to character width
    - Left in some debugging code in case further issues arise
27. row => selectedMenuItem; row1 => selectedMenuItem1
28. Remove unused bry, brx code.
===
29. Code reformatting
30. Updated copyright, title of game
31. Fixed railroad move drawing
32. Updated some special symbols with regular characters, replaced FI with appropriate characters
33. Symbol & Sound is now Music
34. Fixed bleeding in touchup
35. Commented out some new code I added to fix the menu bug that shouldn't be needed
===
36. Generate license file for dependencies.
37. Fix issue with loading saved game files.
===
38. Created a new dev folder to contain other developer focused documents.
39. Moved the changelogs into the dev folder.
41. Update README.md; add CONTRIBUTING.md; add screenshot of game.
===
42. chosit => highlightMenuOption.
43. Minor code reformatting.
===
44. a$ => someText$
45. Minor code reformatting.
===
46. Replace line labels dudd, nocity, noshow, notarg, fnew, and menu1 with EXIT SUB
    - In noshow's case I also took multiple IF conditions that had the same result and condensed them into a single IF
47. x in resolveBattle now attackStrength; x1 => defendStrength
48. Code reformatting
===
49. Rename dull2 and dull1 line labels to playTune2 and playTune1 to be more descriptive.
50. float1 => seShips (se for special event), mercen => seMercenaries; money => seLoan; cotton => seCotton; purse => addMoney; uprising => seUprising; riot = seRiot
51. Replace line label holdup with EXIT SUB