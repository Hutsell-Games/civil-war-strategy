DEFINT A-Z
 
DIM SHARED ATKFAC, DEFAC, TCR
DIM SHARED aggress!, aiBoldness, armySize(40), armyCommander(40), armyExp(40), armySupply(40), armyMove(40), array(40)
DIM SHARED armyOnRailroad(2), armyLocation(40), armyName$(40), battleStats(2), borderWidth, canMove
DIM SHARED currentIncome(2), capitalCity(2), casualty&(2), chosenOption%, cityO(40), cityX(40), cityY(40), cityValue(40)
DIM SHARED cityOwner(40), currentCash(2), cityController(2), cityName$(40), colour%, currentSide, currentMonth, currentYear
DIM SHARED difficultyLevel, emancipate, eventsBalance, facesImage(1 TO 1564), fleet$(2), font$(26), fortLevel(40)
DIM SHARED graphicLevel, graphicImage(1 TO 1564), grudge, hasNavy, highlight%, history, humanPlayers, isOccupied(40), januaryCampaign
DIM SHARED leaderName$(40), leaderRating(40), menuText$(21), menuRows%, matrix(40, 7), monthes$(12), mtn(1 TO 1564)
DIM SHARED nationName$(2), navalCommerce, navyLocation(2), navySize(2), navyMove(2), northernCapital(60), orderOfMoves(40), rr(2), rrFrom(2), realism, navalRaider
DIM SHARED recruitCity(5), recruitFlag, savedGameExists, soundEffects, starX(8), starY(8), thrill, turbo!
DIM SHARED tlx%, tly%, ytrainCapacity(2), timesPlayed
DIM SHARED usAdvantage, victoryFlags(6), victoryPoints(2), windowType%, vpTotal

replaying = 0
newgame:
timesPlayed = 0
recruitFlag = 0
FOR k = 1 TO 40
	armySize(k) = 0
	armyLocation(k) = 0
	armyMove(k) = 0
	armyCommander(k) = 0
	armyName$(k) = ""
NEXT k
usAdvantage = 0
emancipate = 0
FOR k = 1 TO 2
	navySize(k) = 0
	navyLocation(k) = 0
	navyMove(k) = 0
	rr(k) = 0
	victoryPoints(k) = 0
	armyOnRailroad(k) = 0
NEXT k

savedGameExists = 1
victoryFlags(1) = 1

CALL FileManager(1)
IF _FILEEXISTS("mtn.vga") THEN
	DEF SEG = VARSEG(mtn(1))
	BLOAD "mtn.vga", VARPTR(mtn(1))
	DEF SEG
ELSE
	COLOR 15: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'": TICK 9
END IF

RESTORE
FOR k = 1 TO 26
	READ font$(k)
NEXT k

IF realism > 0 AND currentYear < 1862 THEN
		FOR i = 1 TO 2
			someString$ = STRING$(LEN(fleet$(i)), "W")
			fleet$(i) = someString$
		NEXT i
END IF

IF humanPlayers < 1 OR humanPlayers > 2 THEN humanPlayers = 1
IF humanPlayers = 2 OR currentSide = 0 THEN currentSide = 1
IF currentSide = 1 THEN eventsBalance = 7
IF currentSide = 2 THEN eventsBalance = 3
	IF turbo! < 1 THEN turbo! = 2
	IF currentSide = 1 AND difficultyLevel < 3 THEN currentCash(2) = currentCash(2) + 600 - 100 * difficultyLevel
	IF currentSide = 2 AND difficultyLevel > 3 THEN currentCash(1) = currentCash(1) + 100 * difficultyLevel


FOR i = 1 TO 2
	currentIncome(i) = currentCash(i): currentCash(i) = currentCash(i) + 50 * RND
NEXT i
chosenOption = 0

SCREEN 12
	DEF SEG = VARSEG(graphicImage(1))
	BLOAD "cwsicon.vga", VARPTR(graphicImage(1))
	DEF SEG

	PUT (100, 100), graphicImage, PSET
	GET (101, 101)-(113, 113), northernCapital
CLS
COLOR 11: LOCATE 14, 27: PRINT "VGA CIVIL WAR STRATEGY GAME"
COLOR 4: LOCATE 15, 32: PRINT "Registered Edition"
COLOR 14: LOCATE 28, 1: PRINT TAB(8); "(c) 1998 W. R. Hutsell"
LOCATE 28, 60: PRINT "v1.57"
LINE (190, 170)-(440, 260), 1, B
LINE (180, 180)-(450, 250), 7, B
CALL DrawFlags(1, -440, 0): CALL DrawFlags(2, -100, 0)
IF replaying = 0 AND soundEffects = 2 AND chosenOption = 0 THEN
IF currentSide = 1 THEN
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "MST170o1e8o0b8o1e8"
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "e8e4f#8g4f#8"
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "g4e8d2o0b8o1d2 "
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "o1e8o0b8o1e8e8e4f#8g4f#8g4a8b2g8b2MLg16a16"
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "MSb4b8b8a8g8a4a8a4f#8g4g8MLg8f#8"
	IF INKEY$ <> "" GOTO skipmusic
	PLAY "MSe8f#4f#8f#8g8a8b4.a4.g4.f#4.o0b8o1e8e8e4d8e2."
    ELSE
	CALL ShenandoahSong
    END IF
END IF
skipmusic:
CALL UnionPlus

cityName$(0) = "NONE"
OPEN "I", 1, "cities.grd"
vpTotal = usAdvantage + 200
FOR i = 1 TO 40: INPUT #1, a, cityX(i), cityY(i), cityName$(i), cityOwner(i), cityValue(i)
cityO(i) = cityOwner(i)
CALL occupy(i)
FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j: INPUT #1, fortLevel(i)
IF cityOwner(i) > 0 THEN x = cityOwner(i): cityController(x) = cityController(x) + 1: victoryPoints(x) = victoryPoints(x) + cityValue(i)
IF cityOwner(i) > 0 THEN currentCash(cityOwner(i)) = currentCash(cityOwner(i)) + cityValue(i)
vpTotal = vpTotal + cityValue(i)
NEXT i
CLOSE #1: CALL clrbot

RANDOMIZE TIMER
TICK .3
windowType = 2
highlight = 15
replaying = 1
IF humanPlayers = 2 THEN CALL Blanken
menuText$(0) = "VGA CIVILWAR STRATEGY"
menuText$(1) = "Resume Saved Game"
menuText$(2) = "Start NEW Game"
menuText$(3) = "Quit"
tlx = 33: tly = 20: colour = 5: menuRows = 3
chosenOption = 23
CALL ShowMenu(0)
IF chosenOption = 1 THEN
	CLS
	GOTO loader
	GOTO menu0
END IF
IF chosenOption = 3 THEN CLS : END
IF history = 1 THEN
	CLS
	IF _FILEEXISTS("cws.his") THEN SHELL "copy cws.his oldhist.ory"
	OPEN "O", 2, "cws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
	CLOSE #2
ELSE
	SCREEN 12: CLS
END IF
CALL DrawMap
GOTO menu0
'==========================================================================
'                              New Month
'==========================================================================
newmonth:
IF currentSide > 2 THEN currentSide = 1
someString$ = "--------> EVENTS FOR " + monthes$(currentMonth) + " " + STR$(currentYear) + " --------"
CALL scribe(someString$, 0)
CALL TurnUpdate
cityController(1) = 0: cityController(2) = 0

FOR i = 1 TO 2
	currentIncome(i) = 0
	IF currentCash(i) > 19999 THEN currentCash(i) = 19999
	IF currentCash(i) < 0 THEN currentCash(i) = 0
NEXT i
IF humanPlayers = 1 AND currentSide = 2 THEN currentIncome(1) = currentIncome(1) + usAdvantage

FOR i = 1 TO 40
	IF cityOwner(i) > 0 THEN x = cityOwner(i): cityController(x) = cityController(x) + 1: currentIncome(x) = currentIncome(x) + cityValue(i)
	armyMove(i) = 0
NEXT i

FOR i = 1 TO 2
	navyMove(i) = 0
	IF capitalCity(i) > 0 THEN currentIncome(i) = currentIncome(i) + 100
	currentCash(i) = currentCash(i) + currentIncome(i)
	IF navalCommerce > 0 AND i <> navalCommerce THEN currentCash(i) = currentCash(i) - navalRaider
NEXT i
vpTotal = currentIncome(1) + currentIncome(2)

newChosenOption = 22
IF humanPlayers = 2 THEN CALL Blanken: CALL DrawMap
CALL victor
ON ERROR GOTO 0
IF timesPlayed > 0 THEN
	FOR k = 1 TO 40
		armyLocation(k) = 0
	NEXT k
	GOTO newgame
END IF

'                              Main Menu
menu0:
CALL DrawTopBar
IF humanPlayers = 2 AND currentSide = 0 THEN currentSide = 1
IF currentCash(currentSide) < 100 AND navyLocation(currentSide) = 0 THEN hasNavy = 1

highlight = 11
colour = 4
tlx = 67: tly = 13
menuText$(0) = "Main"
menuText$(1) = "Troops": IF recruitFlag < 0 OR currentCash(currentSide) < 100 THEN menuText$(1) = "-": newChosenOption = 23
menuText$(2) = "Moves": IF canMove > 0 THEN menuText$(2) = "-": IF newChosenOption = 23 THEN newChosenOption = 24
menuText$(3) = "Ships": IF hasNavy > 0 THEN menuText$(3) = "-": IF newChosenOption = 24 THEN newChosenOption = 25
menuText$(4) = "Railroad": IF rr(currentSide) > 0 THEN menuText$(4) = "-": IF newChosenOption = 25 THEN newChosenOption = 26
menuText$(5) = "END TURN"
menuText$(6) = "Inform"
menuText$(7) = "COMMANDS"
menuText$(8) = "UTILITY"
menuText$(9) = "Files"

menuRows = 9
chosenOption = newChosenOption
CALL ShowMenu(0): CALL clrrite
SELECT CASE chosenOption ' Main Menu
	CASE 1 ' Recruit
		IF currentCash(currentSide) < 100 OR recruitFlag < 0 THEN recruitFlag = -1: GOTO menu0
		CALL RecruitArmy((currentSide))
		newChosenOption = 23
		GOTO menu0
	CASE 2 ' Move
		CALL MoveArmies
		newChosenOption = 23
		GOTO menu0
	CASE 3 ' Navy
		IF hasNavy = 0 THEN CALL ManageNavy((currentSide), 0)
		newChosenOption = 25
	CASE 4 ' Railroad
		IF rr(currentSide) = 0 THEN
			COLOR 15: LOCATE 4, 68: PRINT "RAILROAD MOVE"
			PSET (550, 20), 0
			DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5R1BF4"
			z = 9: IF currentSide = 2 THEN z = 7
			x = POINT(0): y = POINT(1)
			PAINT (x, y), z, 15
			COLOR 15: IF currentSide = 1 THEN COLOR 11
			CALL traincapacity(currentSide, limit)
			CALL clrbot: PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
			CALL railroad(currentSide)
		ELSE
			CALL clrbot: COLOR 11: PRINT "Railroad is already carrying "; armyName$(rr(currentSide)); " to "; cityName$(armyMove(rr(currentSide))); : GOTO menu0
		END IF
	CASE 5 ' End Turn
		tlx = 67: tly = 15
		highlight = 15: colour = 3: chosenOption = 23
		menuText$(0) = "End Turn"
		menuText$(1) = "Yes"
		menuText$(2) = "NOT YET"
		menuRows = 2: CALL ShowMenu(0): CALL clrrite: IF chosenOption <> 1 THEN newChosenOption = 24: GOTO menu0
		endturn: ' Line Label
		recruitFlag = 0: canMove = 0: hasNavy = 0
		IF humanPlayers = 2 THEN currentSide = currentSide + 1: IF currentSide = 2 THEN CALL Blanken: CALL DrawMap: GOTO menu0
		GOTO newmonth
	CASE 6 ' Reports
		CALL ShowReports((currentSide)): newChosenOption = 27
		CALL StartToFinish(start, fin, currentSide)
		FOR i = start TO fin
		IF armyMove(i) > 0 THEN CALL MoveUnitIcon(armyLocation(i), armyMove(i), 1)
		NEXT i
	CASE 7 ' Commands Menu
		commandsmenu: ' Line Label
		tlx = 67: tly = 13
		COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
		highlight = 15: colour = 3: newChosenOption = 24
		menuText$(0) = "Commands"
		menuText$(1) = "Cancel"
		menuText$(2) = "Fortify": IF currentCash(currentSide) < 200 THEN menuText$(2) = "-"
		menuText$(3) = "Join"
		menuText$(4) = "Supply"
		menuText$(5) = "Capital": IF capitalCity(currentSide) = 0 OR currentCash(currentSide) < 500 THEN menuText$(5) = "-"
		menuText$(6) = "Detach": IF currentSide = 1 THEN menuText$(6) = "-"
		menuText$(7) = "Army Drill"
		menuText$(8) = "Relieve"
		menuText$(9) = "MAIN MENU"
		menuRows = 9
		CALL ShowMenu(0): CALL clrrite
		newChosenOption = 28
		SELECT CASE chosenOption
			CASE 1 ' Cancel
				CALL CancelArmyMovement(currentSide): canMove = 0
				chosenOption = 22
			CASE 2 ' Fortify
				IF currentCash(currentSide) < 200 THEN COLOR 11: CALL clrbot: PRINT "Not enough money for fort"; : GOTO menu0
				CALL FortifyCity(target)
				IF currentCash(currentSide) < 200 GOTO menu0
				chosenOption = 23
				GOTO commandsmenu
			CASE 3 ' Combine
				x = currentSide
				CALL CombineArmies(x)
				IF x < 0 THEN
					CALL clrbot
					COLOR 11
					PRINT "No eligible armies in same city to combine";
					CALL stax(currentSide)
					GOTO menu0
				END IF
				chosenOption = 24
				GOTO commandsmenu
			CASE 4 ' Supply
				CALL StartToFinish(start, fin, (currentSide))
				menuText$(0) = "Supply"
				tlx = 67: tly = 5: colour = 5
				menuRows = 0
				FOR i = start TO fin
				IF armyLocation(i) = 0 OR armySupply(i) > 1 GOTO alone
				IF realism > 0 THEN
					CALL cutoff(currentSide, armyLocation(i), a)
					IF a < 1 THEN CALL clrbot: COLOR 15: PRINT nationName$(currentSide); " army in "; cityName$(armyLocation(i)); " is CUT OFF !"; : TICK turbo!: GOTO alone
				END IF
				menuRows = menuRows + 1
				max = 11: IF LEN(armyName$(i)) < 11 THEN max = LEN(armyName$(i))
				menuText$(menuRows) = LEFT$(armyName$(i), max)
				array(menuRows) = i
				alone: ' Line Label
				NEXT i
				IF menuRows = 0 THEN COLOR 11: CALL clrbot: PRINT "All eligible "; nationName$(currentSide); " armies have supplies"; : GOTO menu0
				CALL ShowMenu(6): CALL clrrite
				IF chosenOption < 0 GOTO menu0
				index = array(chosenOption)
				IF armySupply(index) < 2 THEN
				CALL ResupplyArmy(index)
				CALL DrawArmyUnit(index)
				END IF
				chosenOption = 25
				GOTO commandsmenu
			CASE 5 ' Move Capital
				IF capitalCity(currentSide) = 0 OR currentCash(currentSide) < 500 THEN CALL clrbot: COLOR 11: PRINT "Cannot move capital"; : GOTO menu0
				currentCash(currentSide) = currentCash(currentSide) - 500
				victoryPoints(3 - currentSide) = victoryPoints(3 - currentSide) + 50
				CALL clrrite
				menuText$(0) = "Capital"
				someString$ = cityName$(capitalCity(currentSide))
				index = capitalCity(currentSide): CALL newcity(index)
				IF index = 0 GOTO menu0
				capitalCity(currentSide) = index
				CALL clrbot: PRINT nationName$(currentSide); " capital moved from "; someString$; " to "; cityName$(capitalCity(currentSide));
				CALL clrrite
				CALL DrawCities
				CALL TICK(9): CALL clrbot
			CASE 6 ' Detach
				IF currentSide = 1 THEN CALL clrbot: COLOR 11: PRINT "Option not available to Union"; : GOTO menu0
				COLOR 14: LOCATE 4, 68: PRINT "DETACH UNIT"
				CALL MoveFrom(index, target): IF target < 1 OR index < 1 GOTO menu0
				IF armySize(index) < 65 THEN CALL clrbot: PRINT "Too small to detach"; : CALL TICK(turbo!): GOTO menu0
				CALL commander(2, empty): IF empty = 0 GOTO menu0
				armySupply(empty) = .3 * armySupply(index): armySupply(index) = armySupply(index) - armySupply(empty): IF armySupply(index) < 0 THEN armySupply(index) = 0
				armySize(empty) = .3 * armySize(index): armySize(index) = armySize(index) - armySize(empty)
				armyLocation(empty) = target: armyExp(empty) = armyExp(index): armyMove(empty) = 0
				armyCommander(empty) = leaderRating(empty)
				armyName$(empty) = leaderName$(empty): leaderName$(empty) = ""
				armyExp(empty) = armyExp(index)
				COLOR 11: CALL clrbot: PRINT "Unit #"; empty; " with "; : CALL CorrectArmySize(empty): PRINT " men detached under "; armyName$(empty); : CALL TICK(turbo!): IF soundEffects > 0 THEN SOUND 2222, 1
				CALL stax(currentSide)
				chosenOption = 27
				GOTO commandsmenu
			CASE 7 ' Drill
				COLOR 14: LOCATE 4, 68: PRINT "DRILL ARMY"
				CALL MoveFrom(index, target)
				IF target < 1 OR index < 1 THEN COLOR 11: CALL clrbot: PRINT "No armies remain eligible for drills in "; monthes$(currentMonth); : GOTO menu0
				IF armyExp(index) > 5 OR armyExp(index) >= armyCommander(index) THEN COLOR 12: CALL clrbot: PRINT armyName$(index); ": Army has reached maximum improvement through drilling"; : GOTO commandsmenu
				armyExp(index) = armyExp(index) + 1
				CALL clrbot: PRINT armyName$(index); " has drilled to reach experience level "; armyExp(index); : IF soundEffects > 0 THEN SOUND 2222, 1
				CALL TICK(turbo!): clrbot
				armyMove(index) = -1
				chosenOption = 28
				GOTO commandsmenu
			CASE 8 ' Relieve
				CALL relieve(currentSide)
				chosenOption = 29
				GOTO commandsmenu
			CASE ELSE ' Else
				newChosenOption = 28
				GOTO menu0
		END SELECT
		chosenOption = 21 + chosenOption: GOTO commandsmenu
	CASE 8 ' Utility Menu
		utilitymenu: ' Line Label
		newChosenOption = 29
		menuText$(0) = "Utility"
		menuText$(1) = "Side": IF humanPlayers = 2 THEN menuText$(2) = ""
		menuText$(2) = "1 Player": IF humanPlayers = 2 THEN menuText$(2) = "2 Player"
		menuText$(3) = "Graphics" + STR$(graphicLevel)
		menuText$(4) = "Noise": IF soundEffects > 0 THEN menuText$(4) = menuText$(4) + STRING$(soundEffects, "*")
		menuText$(5) = "Display" + STR$(turbo!)
		someString$ = STR$(difficultyLevel): IF currentSide = 1 THEN someString$ = STR$(6 - difficultyLevel)
		menuText$(6) = "Balance" + someString$
		menuText$(7) = "End Cond"
		someString$ = "+": IF eventsBalance = 0 THEN someString$ = ""
		menuText$(8) = "Rndom Evt " + someString$
		menuText$(9) = "Vary Start"
		someString$ = "": IF januaryCampaign = 1 THEN someString$ = "+"
		menuText$(10) = "Jan Campgn" + someString$
		someString$ = "": IF realism = 1 THEN someString$ = "+"
		menuText$(11) = "Realism " + someString$
		menuText$(12) = "Chk Links"
		someString$ = "": IF history = 1 THEN someString$ = "+"
		menuText$(13) = "History" + someString$
		menuRows = 13: tlx = 67: tly = 11
		COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
		IF humanPlayers = 1 THEN menuRows = 14: menuText$(14) = "Aggress" + STR$(aiBoldness)
		CALL ShowMenu(-1): CALL clrrite
		SELECT CASE chosenOption
			CASE 1 ' Swap Sides
				IF humanPlayers = 2 GOTO menu0
				currentSide = 3 - currentSide: COLOR 9: IF currentSide = 2 THEN COLOR 7
				CALL clrbot: PRINT "Now playing "; nationName$(currentSide); " side"; : IF soundEffects > 0 THEN SOUND 999, 1
				IF currentSide = 1 THEN eventsBalance = 7
				IF currentSide = 2 THEN eventsBalance = 3
				CALL DrawTopBar
				GOTO menu0
			CASE 2 ' Solo or 2 Player
				humanPlayers = 3 - humanPlayers: CALL clrbot: COLOR 12
				IF soundEffects > 0 THEN SOUND 999, 1
				someString$ = "Solo": IF humanPlayers = 2 THEN someString$ = "2 Player"
				PRINT someString$; " Game";
				chosenOption = 23: GOTO utilitymenu
			CASE 3 ' Graphics
				graphicLevel = graphicLevel + 1
				IF graphicLevel > 3 THEN graphicLevel = 0
				someString$ = "ROADS"
				IF graphicLevel = 0 THEN someString$ = "DISABLED"
				IF graphicLevel = 2 THEN someString$ = "CITY NAMES"
				IF graphicLevel = 3 THEN someString$ = "FULL"
				CLS
				CALL DrawMap
				CALL clrbot: COLOR 11: PRINT "Graphics : "; someString$; : IF soundEffects > 0 THEN SOUND 2700, 1
				chosenOption = 24: GOTO utilitymenu
			CASE 4 ' Sounds
				CALL clrrite: chosenOption = soundEffects + 22
				menuText$(0) = "SOUNDS"
				menuText$(1) = "Quiet"
				menuText$(2) = "Sound"
				menuText$(3) = " & Sound"
				menuRows = 3: tlx = 67: tly = 12
				CALL ShowMenu(0): CALL clrrite
				IF chosenOption < 1 GOTO menu0
				COLOR 11: CALL clrbot: PRINT "Sound Option : "; menuText$(chosenOption);
				soundEffects = chosenOption - 1
				IF soundEffects > 0 THEN SOUND 999, 1
				chosenOption = 25: GOTO utilitymenu
			CASE 5 ' Display Speed
				chosenOption = turbo! + 21
				menuText$(0) = "Display"
				menuText$(1) = "Fast"
				menuText$(2) = "Normal"
				menuText$(3) = "Slow"
				menuText$(4) = "Very Slow"
				menuText$(5) = "Reg Color": IF borderWidth > 0 THEN menuText$(5) = "Alt Color"
				tlx = 67: tly = 15: menuRows = 5
				CALL ShowMenu(0): CALL clrrite
				SELECT CASE chosenOption
					CASE IS < 1
					CASE IS < 5
						turbo! = chosenOption
						IF turbo! = 4 THEN turbo! = 8
						CALL clrbot: COLOR 11
						PRINT "Display Speed : "; menuText$(chosenOption);
					CASE 5
						borderWidth = 1 - borderWidth
						CLS
						CALL DrawMap
						CALL DrawTopBar
				END SELECT
				chosenOption = 26: GOTO utilitymenu
		CASE 6 ' Play Balance
			chosenOption = difficultyLevel + 21
			menuText$(0) = "Balance"
			menuText$(1) = "Rebel ++"
			menuText$(2) = "Rebel +"
			menuText$(3) = "Balanced"
			menuText$(4) = "Union +"
			menuText$(5) = "Union ++"
			tlx = 67: tly = 15: menuRows = 5
			CALL ShowMenu(8): CALL clrrite
			IF chosenOption < 1 GOTO menu0
			CALL clrbot
			COLOR 11: CALL clrbot: PRINT "Play Balance : "; menuText$(chosenOption);
			difficultyLevel = chosenOption
			CALL UnionPlus
			chosenOption = 27: GOTO utilitymenu
		CASE 7 ' Ending Conditions
			CALL VictoryConditionsMet
			chosenOption = 28: GOTO utilitymenu
		CASE 8 ' Random Events Options
			menuText$(0) = "Random Events"
			menuRows = 4: tlx = 30: tly = 8
			menuText$(1) = "OFF"
			menuText$(2) = "Favor Union ": IF eventsBalance = 3 THEN menuText$(2) = menuText$(2) + " "
			menuText$(3) = "Neutral     ": IF eventsBalance = 5 THEN menuText$(3) = menuText$(3) + " "
			menuText$(4) = "Favor Rebels": IF eventsBalance = 7 THEN menuText$(4) = menuText$(4) + " "
			colour = 5
			CALL ShowMenu(0)
			colour = 4

			SELECT CASE chosenOption
			CASE 1
				eventsBalance = 0: anotherString$ = ""
			CASE 2
				eventsBalance = 3
			CASE 3
				eventsBalance = 5
			CASE 4
				eventsBalance = 7
			CASE ELSE
			END SELECT
			IF chosenOption > 1 AND chosenOption < 5 THEN anotherString$ = menuText$(chosenOption)
			CALL clrbot
			someString$ = "": IF eventsBalance = 0 THEN someString$ = "OFF"
			COLOR 11: PRINT "Random Events : "; someString$; " "; anotherString$;
			COLOR 14: PRINT "			press a key";
			DO WHILE INKEY$ = "": LOOP
			CLS
			CALL DrawMap
			chosenOption = 29
			GOTO utilitymenu
		CASE 9 ' Vary Start Conditions
			CALL FileManager(1)
			currentCash(1) = currentCash(1) - 100 + 200 * RND
			currentCash(2) = currentCash(2) + 100 + 200 * RND
			aiBoldness = 5 * RND
			FOR k = 1 TO 6
				IF RND > .6 THEN
				armyLocation(k) = 0: armySize(k) = 0: armyCommander(k) = 0
				armyExp(k) = 0: armyMove(k) = 0: armySupply(k) = 0
				END IF
			NEXT k
			FOR k = 21 TO 6
				IF RND > .6 THEN
				armyLocation(k) = 0: armySize(k) = 0: armyCommander(k) = 0
				armyExp(k) = 0: armyMove(k) = 0: armySupply(k) = 0
				END IF
			NEXT k
			FOR k = 1 TO 40: CALL occupy(k): NEXT k
			navySize(1) = 10 * RND: IF navySize(1) = 0 THEN navyLocation(1) = 0
			navySize(2) = 10 * RND: IF navySize(2) > 0 THEN navyLocation(2) = 27
			FOR i = 1 TO 2
				fleet$(i) = ""
				FOR j = 1 TO navySize(i)
				someString$ = "W": IF RND > .45 * currentSide THEN someString$ = "I"
				fleet$(i) = fleet$(i) + someString$
			NEXT j
			NEXT i
			IF RND > .7 THEN capitalCity(2) = 25

			FOR k = 1 TO 40
			IF RND > .8 THEN leaderRating(k) = leaderRating(k) - 3 + 6 * RND: IF leaderRating(k) > 9 THEN leaderRating(k) = 9
			IF leaderRating(k) < 1 THEN leaderRating(k) = 1
			NEXT k
			CLS
			CALL DrawMap
			chosenOption = 30: GOTO utilitymenu
		CASE 10 ' January Campaigns
			januaryCampaign = 1 - januaryCampaign
			someString$ = "PROHIBITED": IF januaryCampaign = 1 THEN someString$ = "ALLOWED"
			COLOR 11
			CALL clrbot
			PRINT "January Campaigns : "; someString$;
			chosenOption = 31: GOTO utilitymenu
		CASE 11 ' Realism Switch
			realism = 1 - realism
			CALL clrbot: COLOR 11
			IF realism = 0 THEN
				PRINT "Recruiting FIXED :  7000 for NEW Armies   4500 for Additions";
			ELSE
				PRINT "REALISM ON: Recruiting based on CITY SIZE";
				IF currentSide = 2 AND eventsBalance = 1 AND eventsBalance < 5 THEN eventsBalance = eventsBalance + 2
				CALL UnionPlus
			END IF
			chosenOption = 32: GOTO utilitymenu
		CASE 12 ' Check Map Linkages
			CALL CheckMapIntegrity
			CALL TICK(99)
			CALL DrawMap
		CASE 13 ' History
			history = 1 - history
			someString$ = "OFF": IF history = 1 THEN someString$ = "ON"
			CALL clrbot: PRINT "History is now "; someString$;
			chosenOption = 34: GOTO utilitymenu
		CASE 14 ' Aggression
			aiBoldness = aiBoldness + 1: IF aiBoldness > 5 THEN aiBoldness = 0
			SELECT CASE aiBoldness
			CASE 0: someString$ = "PASSIVE"
			CASE 1: someString$ = "TIMID"
			CASE 2: someString$ = "CAUTIOUS"
			CASE 3: someString$ = "NORMAL"
			CASE 4: someString$ = "BOLD"
			CASE 5: someString$ = "RECKLESS"
			END SELECT
			CALL clrbot
			COLOR 11
			PRINT "Enemy Aggression : "; someString$; " ("; aiBoldness; ")";
			chosenOption = 35: GOTO utilitymenu
			CASE ELSE
		END SELECT
	CASE 9 ' Files
		IF _FILEEXISTS("*.sav") = 0 THEN savedGameExists = 0
		newgamemenu: ' Line Label
		chosenOption = 23: newChosenOption = 30: IF currentYear = 1861 THEN chosenOption = 22
		menuText$(0) = "Options"
		menuText$(1) = "Load": IF savedGameExists = 0 THEN menuText$(1) = "-": chosenOption = 23
		menuText$(2) = "Save"
		menuText$(3) = "New Game"
		menuText$(4) = "Quit"
		menuRows = 4: tlx = 67: tly = 15
		CALL ShowMenu(0): CALL clrrite
		SELECT CASE chosenOption
			CASE IS < 1: GOTO menu0
			CASE 1, 2
		loader: ' Line Label
				IF chosenOption = 1 AND savedGameExists = 0 GOTO newgamemenu
				CALL FileManager(chosenOption + 1)
				IF chosenOption = 1 THEN recruitFlag = 0: canMove = 0: hasNavy = 0
				GOTO menu0
			CASE 3
				OPEN "O", 1, "cws.cfg"
				WRITE #1, currentSide, graphicLevel, soundEffects, difficultyLevel, humanPlayers, turbo!, eventsBalance, ytrainCapacity(1), ytrainCapacity(2), januaryCampaign, realism, battleStats(1), battleStats(2), casualty&(1), casualty&(2), history, aiBoldness
				CLOSE #1
				CLS
				GOTO newgame
			CASE 4:
				chosenOption = 23
				menuText$(0) = "Quit"
				menuText$(1) = "Yes"
				menuText$(2) = "No"
				menuRows = 2: colour = 5
				tlx = 67: tly = 15
				CALL ShowMenu(0): CALL clrrite: IF chosenOption = 1 THEN END ELSE GOTO menu0
		END SELECT
'==========================================================================
	CASE 99
	GOTO endturn
CASE ELSE
	newChosenOption = 22
	GOTO menu0
END SELECT
GOTO menu0

DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"

SUB blanken
	c = 1: IF currentSide = 2 THEN c = 7
	CLS : LINE (100, 200)-(500, 300), c, BF
	LINE (100, 200)-(500, 300), 8 - c, B
	COLOR 7: LOCATE 14, 31: PRINT " "; monthes$(currentMonth); currentYear
	COLOR 11: LOCATE 17, 30: PRINT nationName$(currentSide); " PLAYER TURN"
	DO WHILE INKEY$ = "": LOOP
END SUB

SUB UnionPlus
	usAdvantage = 120 * difficultyLevel: IF humanPlayers = 2 THEN usAdvantage = 50 * difficultyLevel
	IF realism > 0 THEN usAdvantage = usAdvantage * .7
END SUB

SUB MoveArmies
	CALL MoveFrom(index, target): IF target > 0 AND index > 0 GOTO tent
		IF index = -1 THEN canMove = 1
		EXIT SUB
	tent:
	tlx = 67: tly = 12

	CALL ShowArmyStats(index)
	COLOR 11: LOCATE 11, 68: PRINT cityName$(target)
	menuRows = 0
	menuText$(0) = "To"
	FOR i = 1 TO 6: IF matrix(target, i) > 0 THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(matrix(target, i)): array(menuRows) = matrix(target, i)
	NEXT i
	CALL bubble(menuRows)

	highlight = 10: colour = 3: CALL ShowMenu(2): CALL clrrite
	IF chosenOption < 0 THEN EXIT SUB
	IF currentMonth < 3 AND januaryCampaign = 0 AND cityOwner(array(chosenOption)) <> currentSide THEN COLOR 11: CALL clrbot: PRINT "No campaigns in January"; : CALL TICK(9): CALL clrbot: EXIT SUB

	CALL clrbot: PRINT "Army "; index; " "; armyName$(index); " is moving from "; cityName$(target); " to "; cityName$(array(chosenOption));
	IF soundEffects > 0 THEN SOUND 2200, .5: SOUND 2900, .7
	CALL MoveUnitIcon(target, array(chosenOption), 1)
	armyMove(index) = array(chosenOption): CALL TICK(turbo!): CALL clrbot
	CALL clrrite
END SUB

SUB ShowArmyStats (index%)
	LINE (530, 60)-(639, 150), 0, BF
	COLOR 15
	LOCATE 5, 68: PRINT armyName$(index)
	COLOR 9: IF index > 20 THEN COLOR 7
	LOCATE 6, 68: PRINT "Size:"; : CALL CorrectArmySize(index)
	LOCATE 7, 68: PRINT "Leader:"; TAB(75); armyCommander(index)
	LOCATE 8, 68: PRINT "Exper:"; TAB(75); armyExp(index)
	IF armySupply(index) < 2 THEN COLOR 12
	LOCATE 9, 68: PRINT "Supply:"; TAB(75); armySupply(index)
END SUB

SUB ShipDestroyed (who%)
	navySize(who) = navySize(who) - 1
	IF navySize(who) > 0 THEN
		fleet$(who) = LEFT$(fleet$(who), navySize(who))
	ELSE
		fleet$(who) = "": navyLocation(who) = 0: navySize(who) = 0
	END IF
END SUB

SUB battle (attack%, defend%, win%, lose%)
	IF armySize(defend) < 1 THEN armySize(defend) = 1
	IF armySize(attack) < 1 THEN armySize(attack) = 1

	CALL MoveUnitIcon(armyLocation(defend), 0, 9)
	LOCATE 1, 1: PRINT SPACE$(80)
	CALL clrrite: y = 68: COLOR 11: LOCATE 1, y: PRINT "Attacker"
	c = 9: IF attack > 20 THEN c = 7
	COLOR c: LOCATE 2, y: PRINT armyName$(attack)
	LOCATE 3, y: CALL CorrectArmySize(attack)
	x = .01 * armySize(attack): IF x > TCR THEN x = TCR
	LOCATE 4, y: PRINT "Base    "; x
	IF armySize(attack) / armySize(defend) > .2 THEN x = x + .3 * armyCommander(attack) + .3 * armyExp(attack): IF x > TCR THEN x = TCR
	IF armyExp(attack) > 8 THEN x = x + 1: IF x > TCR THEN x = TCR
	LOCATE 5, y: PRINT "Ldr/Exp "; x
	IF armySize(attack) < 15 THEN x = .5 * x: IF x > TCR THEN x = TCR
	LOCATE 6, y: PRINT "Small   "; x
	IF armySize(attack) / armySize(defend) <= .5 THEN x = x - 2: IF x < 1 THEN x = 1
	IF armySize(attack) / armySize(defend) > 3 THEN x = x + 2: IF x > TCR THEN x = TCR
	IF armySize(attack) / armySize(defend) > 10 THEN x = TCR
	IF armySize(attack) / armySize(defend) <= .2 THEN x = 1
	LOCATE 7, y: PRINT "Outman  "; x
	IF armySupply(attack) < 1 THEN x = .5 * x: COLOR 13
	LOCATE 8, y: PRINT "Supply  "; x: COLOR c
	IF x < 1 THEN x = 1
	'                       Adjust attack advantage
	IF attack < 21 AND currentSide = 2 AND difficultyLevel > 3 THEN x = x + 2 * difficultyLevel - 6
	IF attack > 20 AND currentSide = 1 AND difficultyLevel < 3 THEN x = x + 6 - 2 * difficultyLevel
	LOCATE 9, y: PRINT "Difclt  "; x
	IF x > TCR THEN x = TCR
	COLOR 11: LOCATE 11, y: PRINT "Attack  "; x
	LINE (530, 155)-(635, 175), 11, B

	x1 = .013 * armySize(defend) + 1: IF realism = 1 THEN x1 = .02 * armySize(defend) + 2: IF x1 > 20 THEN x1 = 20
	LOCATE 13, y: PRINT "Defender"
	COLOR 16 - c: LOCATE 14, y: PRINT armyName$(defend)
	LOCATE 15, y: CALL CorrectArmySize(defend)
	LOCATE 16, y: PRINT "Base    "; INT(.01 * armySize(defend))
	LOCATE 17, y: PRINT "Defense "; x1
	IF armySize(defend) / armySize(attack) > .2 THEN x1 = x1 + .3 * armyCommander(defend) + .3 * armyExp(defend): IF x1 > TCR THEN x1 = TCR
	IF armyExp(defend) > 8 THEN x1 = x1 + 1: IF x1 > TCR THEN x1 = TCR
	LOCATE 18, y: PRINT "Ldr/Exp "; x1
	IF armySize(defend) < 15 THEN x1 = .5 * x1
	LOCATE 19, y: PRINT "Small   "; x1

	R! = armySize(defend) / armySize(attack)
	SELECT CASE R!
		CASE IS > 10
			x1 = TCR
		CASE IS > 1.5
			x1 = x1 + 2
		CASE IS < .5
			x1 = .8 * x1
		CASE IS < .2
			x1 = .5 * x1
	END SELECT
		IF x1 < 1 THEN x1 = 1
		IF x1 > TCR THEN x1 = TCR

	LOCATE 20, y: PRINT "Outman  "; x1
	IF armySupply(defend) < 1 THEN x1 = .5 * x1: COLOR 13
	LOCATE 21, y: PRINT "Supply  "; x1: COLOR 16 - c
	IF x1 < 1 THEN x1 = 1
	'                       Adjust defend advantage
	IF defend < 21 AND currentSide = 2 AND difficultyLevel > 3 THEN x1 = x1 + 2 * difficultyLevel - 6
	IF defend > 20 AND currentSide = 1 AND difficultyLevel < 3 THEN x1 = x1 + 6 - 2 * difficultyLevel
	LOCATE 22, y: PRINT "Difclt  "; x1

	someString$ = "Fort": IF armyMove(defend) = 0 THEN x1 = x1 * (1 + fortLevel(armyLocation(defend)))
	IF x1 > TCR THEN x1 = TCR
	IF fortLevel(armyLocation(defend)) > 0 AND armyMove(defend) = 0 THEN
		COLOR 13: someString$ = "Fort+"
		IF fortLevel(armyLocation(defend)) = 2 THEN someString$ = "Fort++"
	END IF
	LOCATE 23, y: PRINT someString$; TAB(76); x1
	IF x1 > TCR THEN x1 = TCR
	COLOR 11: LOCATE 25, y: PRINT "Defend  "; x1
	LINE (530, 380)-(635, 400), 11, B

	spin = 0
	scale = x: IF x1 > scale THEN scale = x1
	scale = scale + 1

	odds! = x / (x + x1): a = INT(100 * odds!): IF a < 1 THEN a = 1
	someString$ = LTRIM$(RTRIM$(STR$(a))) + "%"
	COLOR 14: LOCATE 27, y: PRINT "Odds:  "; someString$;
	LINE (530, 412)-(635, 435), 14, B
	LINE (528, 410)-(637, 437), 14, B
	DO WHILE INKEY$ = "": LOOP
	IF graphicLevel > 2 THEN
		CALL DrawCannon
		k = fortLevel(armyLocation(defend))
		anotherString$ = "fort" + LTRIM$(STR$(k)) + ".vga"
		IF _FILEEXISTS(anotherString$) THEN
			DEF SEG = VARSEG(graphicImage(1))
			BLOAD anotherString$, VARPTR(graphicImage(1))
			DEF SEG
			PUT (550, 270), graphicImage, PSET
		END IF
	ELSE
		CALL clrrite
	END IF
	FOR i = 1 TO 2: IF armySupply(i) > 0 THEN armySupply(i) = armySupply(i) - 1
	NEXT i
	'---------------------------------------------------------------------------
	grapple:
	hit = 0: hit1 = 0
	start = scale * RND: fin = scale * RND
	IF soundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	IF start <= x THEN hit = 1
	IF fin <= x1 THEN hit1 = 1

	IF hit = 0 AND hit1 = 0 GOTO grapple
	IF hit = 1 AND hit1 = 1 GOTO grapple
	win = defend: lose = attack: IF hit = 1 THEN win = attack: lose = defend
	'---------------------------------------------------------------------------
	someString$ = "UNION": IF win > 20 THEN someString$ = "REBEL"
	COLOR 14: LOCATE 3, 68: PRINT someString$; " VICTORY"
	LOCATE 4, 71: PRINT "in"
	LOCATE 5, 69: PRINT cityName$(armyLocation(defend))
	a = 1: IF win > 20 THEN a = 2
	CALL DrawFlags(a, 0, 0)
	CALL clrbot: COLOR 11: PRINT armyName$(win); " defeats "; armyName$(lose); " in "; cityName$(armyLocation(defend)); : CALL TICK(9)
	'===========================================================================
	pct! = .01 * DEFAC - .03 * fortLevel(armyLocation(defend)): IF win = attack THEN pct! = 1.3 * pct!
	SELECT CASE armySize(defend)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armySize(attack) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killd)
	'...........................................................................
	pct! = .01 * ATKFAC + .02 * fortLevel(armyLocation(defend)): IF win = defend THEN pct! = 1.5 * pct!
	SELECT CASE armySize(attack)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = armySize(defend) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killa)
	'===========================================================================

	killa = .8 * killa + .2 * killd: IF killa < 1 THEN killa = 1
	killd = .8 * killd + .2 * killa: IF killd < 1 THEN killd = 1
	IF killa > 9 * killd THEN killa = 9 * killd
	IF killd > 5 * killa THEN killd = 5 * killa

	IF killa >= armySize(attack) THEN killa = armySize(attack) - 1
	IF killd >= armySize(defend) THEN killd = armySize(defend) - 1
	'---------------------------------------------------------------------------
	x = INT(100 * odds!): IF x < 1 THEN x = 1
	someString$ = LTRIM$(RTRIM$(STR$(x))) + "%"

	COLOR c
	LOCATE 1, 1: PRINT "Attack Loss: ";
	PRINT LTRIM$(RTRIM$(STR$(killa)) + "00"); "/";
	CALL CorrectArmySize(attack)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / armySize(attack)))))); "%)";
	COLOR 16 - c: PRINT "Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
	CALL CorrectArmySize(defend)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killd / armySize(defend)))))); "%)"
	'---------------------------------------------------------------------------
	menuText$(1) = " (" + LTRIM$(RTRIM$(STR$(killa) + "00")) + "/" + LTRIM$(STR$(armySize(attack)) + "00") + ") "
	anotherString$ = " (" + LTRIM$(RTRIM$(STR$(killd) + "00")) + "/" + LTRIM$(STR$(armySize(defend)) + "00") + ")"
	menuText$(2) = anotherString$
	IF win = defend THEN menuText$(2) = menuText$(1): menuText$(1) = anotherString$
	menuText$(3) = "*" + armyName$(win): menuText$(4) = armyName$(lose)
	IF win = defend THEN menuText$(3) = armyName$(win): menuText$(4) = "*" + armyName$(lose)
	someString$ = cityName$(armyLocation(defend)) + ": " + menuText$(3) + menuText$(1) + " defeats " + menuText$(4) + menuText$(2)
	CALL scribe(someString$, 0)

	IF humanPlayers = 1 AND (currentSide = 1 AND attack > 20) OR (currentSide = 2 AND attack < 21) THEN
	COLOR 14: CALL clrbot: PRINT "hit any key to continue"; : DO WHILE INKEY$ = "": LOOP
	END IF

	armySize(attack) = armySize(attack) - killa
	armySize(defend) = armySize(defend) - killd
	IF armySize(defend) < 1 THEN armySize(defend) = 1
	'---------------------------------------------------------------------------
	s = 1: IF attack > 2 THEN s = 2
	casualty&(s) = casualty&(s) + killa
	casualty&(3 - s) = casualty&(3 - s) + killd
	'---------------------------------------------------------------------------
	s = 1: IF win > 20 THEN s = 2
	battleStats(s) = battleStats(s) + 1
	victoryPoints(s) = victoryPoints(s) + 1
	CALL MoveUnitIcon(armyLocation(defend), 0, 8)
END SUB

SUB CombineArmies (who%)
		colour = 3: target = 0: highlight = 3
		tlx = 67: tly = 2
		CALL StartToFinish(start, fin, who)
		menuRows = 0
		FOR i = 1 TO 40
			IF cityOwner(i) = who AND isOccupied(i) > 0 THEN
				FOR j = start TO fin
				IF armyLocation(j) = i AND isOccupied(i) <> j AND armyMove(j) = 0 THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(i): array(menuRows) = i: EXIT FOR
				NEXT j
			END IF
		NEXT i
		
		IF menuRows = 0 THEN who = -1: EXIT SUB
		CALL bubble(menuRows)

		IF who <> currentSide THEN chosenOption = 1 + INT(menuRows * RND): GOTO join
		menuText$(0) = "Join"
			chosenOption = 31: highlight = 11
			CALL ShowMenu(9): CALL clrrite
	join:
			IF chosenOption < 1 THEN EXIT SUB
			target = array(chosenOption)
			CALL clrbot: PRINT "Combining "; nationName$(who); " armies in "; cityName$(target); :  CALL TICK(turbo!)

			armySize(0) = 0: armyCommander(0) = 0: armyExp(0) = 0: armyLocation(0) = target
			armyName$(0) = "": armySupply(0) = 0: armyMove(0) = 0
	'...........................................................................
			best = 0: x = 0: spin = 0
			FOR j = start TO fin
			IF armyMove(j) <> 0 OR armyLocation(j) <> target OR armySize(j) = 0 GOTO cannotcombinearmies
			IF armySize(0) + armySize(j) > 1250 THEN CALL clrbot: PRINT "Cannot combine "; armyName$(j); "... TOO LARGE"; : CALL TICK(turbo!): GOTO cannotcombinearmies

			IF armyCommander(j) > x THEN
				x = armyCommander(j)
				armyName$(0) = armyName$(j)
				armyCommander(0) = armyCommander(j)
				best = j
			END IF

			armySize(0) = armySize(0) + armySize(j)
			IF armySize(0) < 1 GOTO cannotcombinearmies
			pct! = (armySize(j) / armySize(0))
			spin = spin + 1
			armyExp(0) = (1 - pct!) * armyExp(0) + pct! * armyExp(j)
			CALL clrbot: PRINT armyName$(j); " is combining his "; : CALL CorrectArmySize(j): PRINT " forces"; : CALL TICK(turbo!)
			armySupply(0) = armySupply(0) + armySupply(j)
			IF armySupply(0) > 10 THEN armySupply(0) = 10
			armySize(j) = 0: armyLocation(j) = 0: armyExp(j) = 0: armyMove(j) = 0
			leaderName$(j) = armyName$(j)
			armyCommander(j) = 0: armySupply(j) = 0: armyName$(j) = ""
	cannotcombinearmies:
			NEXT j

			CALL clrbot
			IF who <> currentSide AND spin = 0 THEN EXIT SUB
			IF spin = 0 THEN
					PRINT "No valid armies to combine at this time in "; cityName$(target);
					TICK turbo!
					EXIT SUB
			END IF
			armySize(best) = armySize(0): armyCommander(best) = armyCommander(0)
			armyExp(best) = armyExp(0): armySupply(best) = armySupply(0)
			armyLocation(best) = target
			armyName$(best) = armyName$(0)
			leaderName$(best) = ""
			IF spin > 1 THEN
			PRINT "New army "; best; " of "; : CALL CorrectArmySize(best): PRINT " is commanded by "; armyName$(best);
			armyMove(best) = -1
			ELSE
			PRINT "Only 1 eligible army -- cannot combine at this time";
			END IF
			IF who = currentSide THEN CALL TICK(turbo!)
			IF soundEffects > 0 THEN SOUND 4000, .7
			
			CALL DrawCities
			CALL DrawArmyUnit(best)
			CALL MoveUnitIcon(target, 0, 6)
			isOccupied(target) = best
			CALL stax(who)
END SUB

SUB cutoff (who%, target%, a%)
	a = 0
	FOR j = 1 TO 6
	y = matrix(target, j)
	IF y > 0 AND cityOwner(y) = who THEN a = a + 1
	NEXT j
END SUB

SUB FileManager (switch%)
	SELECT CASE switch
		CASE 1
		OPEN "I", 1, "cwslead.dat"
		FOR i = 1 TO 40: INPUT #1, leaderName$(i), leaderRating(i): NEXT i
		CLOSE #1
		OPEN "I", 1, "cws.ini"
		FOR i = 0 TO 2: INPUT #1, nationName$(i): NEXT i
		FOR i = 1 TO 12: INPUT #1, monthes$(i): NEXT i
		INPUT #1, currentMonth, currentYear
	'               set end game conditions
		FOR i = 1 TO 6: INPUT #1, victoryFlags(i): NEXT i
		victoryFlags(3) = .4 * victoryFlags(3)
		INPUT #1, a             ' number of Yankee armies
	FOR i = 1 TO a
		INPUT #1, armyLocation(i), armySize(i), armyExp(i), armySupply(i): isOccupied(armyLocation(i)) = i: armyName$(i) = leaderName$(i): armyCommander(i) = leaderRating(i): leaderName$(i) = ""
	NEXT i
		INPUT #1, a             ' number of Rebel armies
	FOR i = 21 TO 20 + a
		INPUT #1, armyLocation(i), armySize(i), armyExp(i), armySupply(i)
		isOccupied(armyLocation(i)) = i: armyName$(i) = leaderName$(i): armyCommander(i) = leaderRating(i): leaderName$(i) = ""
	NEXT i
	FOR i = 1 TO 2: INPUT #1, currentCash(i): NEXT i
		INPUT #1, ATKFAC, DEFAC, TCR
		INPUT #1, fleet$(1), navyLocation(1), fleet$(2), navyLocation(2)
		FOR k = 1 TO 2: navySize(k) = LEN(fleet$(k)): NEXT k
		INPUT #1, capitalCity(1), capitalCity(2)

	FOR i = 1 TO 8: INPUT #1, starX(i), starY(i): NEXT i  ' star locations on flag
		CLOSE #1
		OPEN "I", 1, "cws.cfg"
		INPUT #1, currentSide, graphicLevel, soundEffects, difficultyLevel, humanPlayers, turbo!, eventsBalance, ytrainCapacity(1), ytrainCapacity(2), januaryCampaign, realism, battleStats(1), battleStats(2), casualty&(1), casualty&(2), history, aiBoldness
		CLOSE #1

		CASE 2
		IF _FILEEXISTS("*.sav") = 0 THEN chosenOption = -1: EXIT SUB
		menuText$(0) = "Load"
		menuRows = 0
		FOR k = 1 TO 9
			anotherString$ = "cws" + LTRIM$(STR$(k)) + ".sav"
			IF _FILEEXISTS(anotherString$) THEN
				menuRows = menuRows + 1: menuText$(menuRows) = anotherString$: array(menuRows) = k
			END IF
		NEXT k
		CALL bubble((menuRows))
		tlx = 67: tly = 14 - .5 * menuRows
		CALL ShowMenu(0)
		CALL clrrite
		IF chosenOption < 1 THEN EXIT SUB
		OPEN "I", 1, "cws" + LTRIM$(STR$(array(chosenOption))) + ".sav"
		COLOR 11: CALL clrbot: PRINT "Loading";
		INPUT #1, currentMonth, currentYear, usAdvantage, a
		FOR i = 1 TO 40: INPUT #1, armyName$(i), armySize(i), armyCommander(i), armyLocation(i), armyExp(i), armySupply(i), armyMove(i)
		IF armyLocation(i) > 0 THEN
			IF armyName$(i) = leaderName$(i) THEN
				leaderName$(i) = ""
			ELSE
				who = 1: IF i > 20 THEN who = 2
				CALL StartToFinish(start, fin, who)
				FOR k = start TO fin
				IF armyName$(i) = leaderName$(k) THEN leaderName$(k) = "": EXIT FOR
				NEXT k
			END IF
		END IF
		NEXT i
		FOR i = 1 TO 40: INPUT #1, isOccupied(i), cityOwner(i), fortLevel(i): PRINT "."; : NEXT i
		FOR i = 1 TO 2: INPUT #1, currentCash(i), cityController(i), currentIncome(i), victoryPoints(i), capitalCity(i)
		INPUT #1, fleet$(i), navyLocation(i), navyMove(i), rr(i), armyOnRailroad(i)
		navySize(i) = LEN(fleet$(i))
		NEXT i
		
		CLOSE #1
		OPEN "I", 1, "cws.cfg"
		INPUT #1, playersSide, graphicLevel, soundEffects, difficultyLevel, humanPlayers, turbo!, eventsBalance, ytrainCapacity(1), ytrainCapacity(2), januaryCampaign, realism, battleStats(1), battleStats(2), casualty&(1), casualty&(2), history, aiBoldness
		CLOSE #1
		SCREEN 12: CLS
		CLOSE #1: CALL DrawMap: CALL clrbot
		FOR k = 1 TO 2
		IF rr(k) > 0 THEN CALL tinytrain(k, 1)
		NEXT k
		currentSide = a

		CASE 3
		menuText$(0) = "Save Game"
		FOR k = 1 TO 9
		menuText$(k) = "cws" + LTRIM$(STR$(k)) + ".sav"
		IF _FILEEXISTS(menuText$(k)) THEN menuText$(k) = menuText$(k) + " +"
		NEXT k
		tlx = 67: menuRows = 9
		CALL ShowMenu(0)
		IF chosenOption < 1 THEN clrrite: EXIT SUB
		COLOR 11: CALL clrbot: PRINT "Saving";

		OPEN "O", 1, "cws" + LTRIM$(STR$(chosenOption)) + ".sav"
		WRITE #1, currentMonth, currentYear, usAdvantage, currentSide
		FOR i = 1 TO 40: WRITE #1, armyName$(i), armySize(i), armyCommander(i), armyLocation(i), armyExp(i), armySupply(i), armyMove(i)
		NEXT i
		FOR i = 1 TO 40: WRITE #1, isOccupied(i), cityOwner(i), fortLevel(i): PRINT "."; : NEXT i
		FOR i = 1 TO 2: WRITE #1, currentCash(i), cityController(i), currentIncome(i), victoryPoints(i), capitalCity(i)
		WRITE #1, fleet$(i), navyLocation(i), navyMove(i), rr(i), armyOnRailroad(i)
		NEXT i
		CLOSE #1
		
		playersSide = currentSide
		IF playersSide < 1 OR playersSide > 2 THEN playersSide = 1
		OPEN "O", 1, "cws.cfg"
		WRITE #1, playersSide, graphicLevel, soundEffects, difficultyLevel, humanPlayers, turbo!, eventsBalance, ytrainCapacity(1), ytrainCapacity(2), januaryCampaign, realism, battleStats(1), battleStats(2), casualty&(1), casualty&(2), history, aiBoldness
		CLOSE #1
		CLS : CALL DrawMap
	END SELECT
END SUB

SUB FortifyCity (target%)
	target = 0: highlight = 11
	tlx = 67: tly = 2
	who = currentSide
	CALL StartToFinish(start, fin, who)
	menuRows = 0
	FOR i = start TO fin
	IF armyLocation(i) > 0 AND fortLevel(armyLocation(i)) < 2 THEN
		menuRows = menuRows + 1
		menuText$(menuRows) = cityName$(armyLocation(i))
		array(menuRows) = armyLocation(i)
	END IF
	NEXT i
	IF menuRows = 0 THEN CALL clrbot: COLOR 11: PRINT "No cities eligible to fortify"; : EXIT SUB
	CALL bubble(menuRows)
	menuText$(0) = "Fortify"
		chosenOption = 31
		CALL ShowMenu(9): CALL clrrite
		IF chosenOption < 0 THEN EXIT SUB
		target = array(chosenOption): CALL occupy(target): x = isOccupied(target): IF x < 0 THEN EXIT SUB
		IF fortLevel(target) > 1 THEN CALL clrbot: PRINT cityName$(target); " at MAXIMUM fortification level of 2"; : CALL TICK(4): EXIT SUB
		cost = 200
		IF currentCash(currentSide) < cost THEN CALL clrbot: PRINT "Fortifications for "; cityName$(target); " cost "; cost; " and you only have "; currentCash(currentSide); : CALL TICK(4): EXIT SUB
		COLOR 3
		fortLevel(target) = fortLevel(target) + 1
		currentCash(currentSide) = currentCash(currentSide) - cost
		CALL clrbot: PRINT cityName$(target); " fortifications increased to "; fortLevel(target);
		CALL MoveUnitIcon(target, 0, 6)
		CALL DrawCities
		IF armyMove(x) > 0 THEN CALL MoveUnitIcon(armyLocation(x), armyMove(x), 5)
		armyMove(x) = -1
		CALL DrawArmyUnit(x)
		CALL stax(who)
END SUB

SUB MoveUnitIcon (from%, dest%, kind%)
	IF from < 1 OR from > 40 THEN EXIT SUB
	IF dest < 0 THEN EXIT SUB
	IF from = 999 THEN EXIT SUB
	x = cityX(from) - 12: y = cityY(from) - 11
	x1 = cityX(dest): y1 = cityY(dest)
	SELECT CASE kind
		CASE 1
		LINE (x, y)-(x1, y1), 15, , &HF0F0
		
		CASE 2
		FOR i = 6 TO 8
		LINE (x - i, y - i + 3)-(x + i, y + i - 3), 14, B
		NEXT i
		CALL TICK(.1)
		
		CASE 3
		x = cityX(from): y = cityY(from)
		CALL snapshot(x, y, 0)
		FOR j = 1 TO 3
		FOR i = 4 TO 10 STEP 1
		CIRCLE (x, y), i, 4
		PAINT (x, y), 14, 4
		IF soundEffects > 0 THEN SOUND 37 + 50 * RND, .03
		NEXT i
		CALL TICK(.1)
		CALL snapshot(x, y, 1)
		NEXT j
		
		CASE 4
		IF isOccupied(from) = 0 THEN LINE (x - 8, y - 6)-(x + 10, y + 8), 2, BF
		IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
		IF from = 27 OR from = 28 THEN CALL TouchupMap

		CASE 5
		IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0

		CASE 6
		x = cityX(from): y = cityY(from)
		CALL snapshot(x, y, 0)
		LINE (x - 9, y - 9)-(x + 9, y + 9), 15, B
		LINE (x - 10, y - 10)-(x + 10, y + 10), 15, B
		IF soundEffects > 0 THEN SOUND 3999, .3
		CALL TICK(turbo! - .5)
		CALL snapshot(x, y, 1)
		CASE 7          ' draw white box
		x = cityX(from) - 12: y = cityY(from) - 11
		GET (x - 8, y - 8)-(x + 8, y + 8), image
		LINE (x - 7, y - 7)-(x + 7, y + 7), 15, B
		LINE (x - 8, y - 6)-(x + 8, y + 6), 15, B
			CASE 8     ' replace old image
		x = cityX(from) - 12: y = cityY(from) - 11
		IF x > 0 THEN PUT (x - 8, y - 8), image, PSET
		
		CASE 9          ' draw arrow pointer
		x = cityX(from) - 12: y = cityY(from) - 11
		GET (x - 8, y - 8)-(x + 10, y + 7), image
		x = x + 7: y = y + 5
		LINE (x + 2, y)-(x + 2, y - 8), 12
		LINE -(x, y - 6), 12
		LINE -(x - 5, y - 11), 12
		LINE -(x - 10, y - 6), 12
		LINE -(x - 6, y - 2), 12
		LINE -(x - 10, y), 12
		LINE -(x + 1, y), 12
		PAINT (x - 2, y - 1), 15, 12

		CASE 11
		LINE (x + 12, y + 11)-(x1, y1), 0, , &H1111

		CASE ELSE
	END SELECT
END SUB

SUB ProcessTurn
	'---------------------------------------------------------------------------
	FOR i = 1 TO 40: IF armyLocation(i) > 0 THEN CALL DrawArmyUnit(i)
	NEXT i
	'---------------------------------------------------------------------------
	currentMonth = currentMonth + 2
	IF currentMonth > 12 THEN currentMonth = 1: currentYear = currentYear + 1
	'---------------------------------------------------------------------------
	s = 1
	FOR i = 1 TO 40: IF armyLocation(i) < 1 GOTO skiparmy
	IF i > 20 THEN s = 2
	IF currentCash(s) >= .2 * armySize(i) THEN
		a = 1: IF realism > 0 THEN CALL cutoff(s, armyLocation(i), a)
		IF a > 0 THEN
			armySupply(i) = armySupply(i) + 1
			currentCash(s) = currentCash(s) - .2 * armySize(i)
		END IF
	END IF
	IF (currentMonth < 7 OR currentMonth > 10) AND matrix(armyLocation(i), 7) < 99 THEN armySupply(i) = armySupply(i) - 1
	IF matrix(armyLocation(i), 7) = 99 AND navyLocation(3 - s) = armyLocation(i) THEN armySupply(i) = armySupply(i) - 1: CALL clrbot: PRINT armyName$(i); " is blockaded"; : CALL TICK(turbo!)
	COLOR 13
	IF armySupply(i) < 1 THEN
		armySupply(i) = 0
		CALL clrbot
		PRINT armyName$(i); " is out of supplies";
		CALL DrawArmyUnit(i)
		CALL TICK(turbo!)
		IF RND > .8 AND armySize(i) > 50 THEN armySize(i) = .9 * armySize(i)
	END IF
	skiparmy:
	NEXT i
	FOR k = 1 TO 2: CALL stax(k): NEXT k
	y = 0: FOR i = 1 TO 20: y = y + .1 * armySize(i): NEXT i
	x = 0: FOR i = 21 TO 40: x = x + .1 * armySize(i): NEXT i
	IF currentSide = 2 AND x > 0 THEN aggress! = y / x ELSE aggress! = 1
	IF currentSide = 1 AND y > 0 THEN aggress! = x / y ELSE IF currentSide = 1 THEN aggress! = 1
END SUB

SUB MoveFrom (index%, target%)
	colour = 3: tlx = 67: tly = 5: index = 0: menuRows = 0: target = 0
	who = currentSide: CALL StartToFinish(start, fin, who)
	FOR i = start TO fin
	IF armyLocation(i) > 0 AND armyMove(i) = 0 THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(armyLocation(i)): array(menuRows) = armyLocation(i)
	NEXT i
	IF menuRows = 0 THEN index = -1: EXIT SUB
	menuText$(0) = "From"
	CALL bubble(menuRows)
	tlx = 67: tly = 5
		highlight = 15: CALL ShowMenu(1): CALL clrrite
		IF chosenOption < 0 THEN target = 0: EXIT SUB
		target = array(chosenOption)

		menuRows = 0
		FOR i = start TO fin
		IF armyLocation(i) = target AND armyMove(i) = 0 THEN index = i: menuRows = menuRows + 1: menuText$(menuRows) = "Army" + STR$(i): array(menuRows) = i
		NEXT i
		IF menuRows = 1 THEN EXIT SUB
		menuText$(0) = "Which"
		CALL bubble(menuRows)
		tlx = 67: tly = 15: CALL ShowMenu(4): CALL clrrite
		IF chosenOption < 0 THEN index = 0: EXIT SUB
		index = array(chosenOption)
END SUB

SUB ManageNavy (who%, chx%)
	DIM hit(2)
	IF chx > 0 THEN
		IF navyLocation(who) < 1 THEN
			chx = 1
		ELSE
			IF navalCommerce = 3 - who AND navalRaider > 0 THEN chx = 4
			IF grudge > 0 THEN chx = 3
		END IF
	END IF
	COLOR 11
	labelmanagenavy:
	cost = 100: cityOwner(0) = who
	IF chx = 0 THEN CALL clrbot: PRINT "Funds available "; currentCash(who);
	IF chx = 1 THEN
		IF currentCash(who) < cost THEN EXIT SUB
		IF navySize(who) > 9 THEN EXIT SUB
	END IF
	menuText$(0) = "Ships"
	menuText$(1) = "Build"
	IF navyLocation(who) <> 99 THEN
	IF currentCash(who) < cost OR navySize(who) > 9 OR cityOwner(navyLocation(who)) <> who THEN menuText$(1) = "-": chosenOption = 23
	END IF
	menuText$(2) = "Attack"
	IF navyLocation(who) <> 99 THEN
	IF cityOwner(navyLocation(who)) <> 3 - who THEN menuText$(2) = "-": chosenOption = 22
	ELSE
	menuText$(1) = "-": menuText$(2) = "-": chosenOption = 24
	END IF
	menuText$(3) = "Sail": IF navyLocation(who) < 1 THEN menuText$(3) = "-": IF chx = 3 THEN chx = 1
	menuText$(4) = "Raid": IF navySize(who) < 1 OR navalCommerce = who THEN menuText$(4) = "-"
	tlx = 67: tly = 12: menuRows = 4
	IF navyLocation(who) <> 99 THEN
	IF who = 1 AND navySize(who) > 1 AND cityOwner(navyLocation(who)) = 0 THEN menuRows = 5: menuText$(5) = "Invasion": CALL void(navyLocation(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
	IF realism = 0 AND who = 2 AND navySize(who) > 1 AND cityOwner(navyLocation(who)) = 0 THEN menuRows = 5: menuText$(5) = "Invasion": CALL void(navyLocation(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
	END IF

	IF chx > 0 THEN chosenOption = chx: GOTO anchor
	IF hasNavy > 0 AND chosenOption <> 1 THEN EXIT SUB
	CALL ShowMenu(0): CALL clrrite
	anchor:
	'---------------------------------------------------------------------------
	SELECT CASE chosenOption
	'---------------------------------------------------------------------------
	'                               Build Ship
	'---------------------------------------------------------------------------
		CASE 1
		IF currentCash(who) < cost OR navyLocation(who) = 99 GOTO labelmanagenavy
		IF chx = 1 AND navySize(who) > 9 THEN EXIT SUB
		IF chx = 0 AND navySize(who) > 9 THEN GOTO labelmanagenavy

		IF chx = 0 AND navyLocation(who) > 0 THEN
			IF cityOwner(navyLocation(who)) <> who GOTO labelmanagenavy
			IF matrix(navyLocation(who), 7) < 99 GOTO labelmanagenavy
		END IF
		IF chx = 1 AND RND < .07 * navySize(who) THEN EXIT SUB
		someString$ = "W"

		IF realism > 0 AND ((currentYear < 1862) OR (currentYear = 1862 AND currentMonth < 3)) GOTO noiron
		IF currentCash(who) >= 2 * cost THEN
			tlx = 67: tly = 12: colour = 9
			IF who = currentSide THEN
				menuText$(0) = "Type"
				menuText$(1) = "Wooden"
				menuText$(2) = "Ironclad"
				menuRows = 2
				CALL ShowMenu(0)
				CALL clrrite
				IF chosenOption < 1 GOTO labelmanagenavy
				IF chosenOption = 2 THEN someString$ = "I": cost = 2 * cost
			ELSE
				someString$ = "I"
			END IF
		END IF

	noiron:
		navySize(who) = navySize(who) + 1
		IF someString$ = "W" THEN
			fleet$(who) = fleet$(who) + someString$: a = 1
		ELSE
			fleet$(who) = someString$ + fleet$(who): a = 2
		END IF
		IF navySize(who) > 1 GOTO add2ship
	ships:
		menuText$(0) = "Port": menuRows = 0: tlx = 67: tly = 12
		FOR i = 1 TO 40: IF matrix(i, 7) = 99 AND cityOwner(i) = who AND navyLocation(3 - who) <> i THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(i): array(menuRows) = i
		NEXT i
		IF chx = 1 THEN chosenOption = 1 + INT(menuRows * RND)
		IF menuRows < 1 THEN
			navySize(who) = 0: fleet$(who) = ""
			IF chx = 0 THEN CALL clrbot: PRINT "NO SHIPYARDS AVAILABLE !"; : EXIT SUB
			IF chx = 1 THEN EXIT SUB
		END IF
		IF chx = 0 THEN CALL ShowMenu(9): CALL clrrite

		IF chosenOption < 1 GOTO ships
		navyLocation(who) = array(chosenOption)
		currentCash(who) = currentCash(who) - cost: navySize(who) = 1
		x = cityX(array(chosenOption)) + 25: y = cityY(array(chosenOption)) + 25: CALL ships
		CALL clrbot: COLOR 11: PRINT nationName$(who); " is building NEW fleet in "; cityName$(array(chosenOption));
		PSET (400, 465), 0: CALL DrawShipIcon(who, a)
		IF soundEffects > 0 THEN SOUND 3000, 1
		CALL TICK(turbo!)
		GOTO labelmanagenavy
	add2ship:
		currentCash(who) = currentCash(who) - cost
		CALL clrbot: PRINT nationName$(who); " navy increased to "; navySize(who);
		PSET (400, 465), 0: CALL DrawShipIcon(who, a)
		CALL ships
		IF soundEffects > 0 THEN SOUND 3000, 1
		CALL TICK(turbo!)
	'---------------------------------------------------------------------------
	'                               Attack City
	'---------------------------------------------------------------------------
		CASE 2
		IF navyLocation(who) = 99 GOTO labelmanagenavy
		IF chx = 2 AND cityOwner(navyLocation(who)) = who THEN EXIT SUB
		IF chx = 2 AND isOccupied(navyLocation(who)) > 0 AND RND > .5 THEN chx = 3: GOTO anchor
		IF chx = 2 AND cityOwner(navyLocation(who)) = 0 THEN chx = 3: GOTO labelmanagenavy
		IF navyLocation(who) < 1 THEN EXIT SUB
		IF who = currentSide THEN hasNavy = 1
		IF cityOwner(navyLocation(who)) <> 3 - who GOTO labelmanagenavy
		CALL clrbot: COLOR 12: PRINT nationName$(who); " fleet bombards "; cityName$(navyLocation(who));
		CALL MoveUnitIcon(navyLocation(who), 0, 3)
			
		target = navyLocation(who): index = isOccupied(target): IF index = 0 GOTO deserted
		pct! = .005 * navySize(who) + .02 * RND: killd = armySize(index) * pct!: IF killd < 1 THEN killd = 1
		CALL clrbot: PRINT armyName$(index); " suffered "; 100 * killd; " casualties";
		x = .5 * navySize(who) + 1: IF x > armySupply(index) THEN x = armySupply(index)
		armySupply(index) = armySupply(index) - x
		CALL TICK(turbo!)
		armySize(index) = armySize(index) - killd: IF armySize(index) < 1 THEN armySize(index) = 1
		EXIT SUB
	deserted:
		IF fortLevel(target) = 0 GOTO bombardcity
		IF RND < .7 + .03 * (navySize(who) - fortLevel(target)) GOTO damagedfortifications
		CALL ShipDestroyed(who)
		CALL clrbot
		PRINT nationName$(cityOwner(target)); " shore battery sunk an attacking ship!"; navySize(who); "ship(s) left! ";
		IF soundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5
		CALL TICK(turbo!)
		IF navySize(who) < 1 THEN
			navyLocation(who) = 0: fleet$(who) = "": GOSUB box2
			LOCATE 12, 27: PRINT nationName$(who); " fleet eliminated"
			CALL TICK(9)
			victoryPoints(3 - who) = victoryPoints(3 - who) + 5
			IF who = currentSide THEN grudge = 0
			GOTO sail3
		END IF
		GOTO deserted
	damagedfortifications:
		CALL clrbot: PRINT cityName$(target); " fortifications damaged";
		fortLevel(target) = fortLevel(target) - 1: x = cityX(target): y = cityY(target): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
		CALL DrawCities
		CALL TICK(turbo!)
		EXIT SUB
	bombardcity:
		IF RND > .25 + .07 * navySize(who) THEN CALL clrbot: PRINT "Citizens of "; cityName$(target); " stand firm against the attack"; : CALL TICK(turbo!): EXIT SUB
		IF navyLocation(who) = capitalCity(3 - who) THEN CALL clrbot: PRINT "The CAPITAL steadfastly stands loyal"; : CALL TICK(turbo!): EXIT SUB
		cityOwner(navyLocation(who)) = 0
		CALL clrbot: PRINT cityName$(navyLocation(who)); " is now  NEUTRAL";
		CALL DrawCities
		victoryPoints(who) = victoryPoints(who) + cityValue(navyLocation(who))
		EXIT SUB
	'---------------------------------------------------------------------------
	'                               Sail
	'---------------------------------------------------------------------------
		CASE 3
		navySize(who) = LEN(fleet$(who))
		IF navySize(who) < 1 AND chx > 0 THEN EXIT SUB
		IF navyLocation(who) < 1 OR navySize(who) < 1 THEN CALL clrbot: PRINT "No ships remain"; : TICK 1: GOTO labelmanagenavy

		menuRows = 0
		FOR i = 1 TO 40: IF matrix(i, 7) > 90 AND navyLocation(who) <> i THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(i): array(menuRows) = i
		NEXT i
		IF chx = 3 THEN
			IF menuRows = 0 THEN EXIT SUB
			IF grudge > 0 THEN chosenOption = 1: array(1) = navyLocation(3 - who): GOTO admiral
			GOSUB nest: IF chosenOption > 0 GOTO admiral ELSE EXIT SUB
		END IF
		COLOR 11: LOCATE 11, 68
		IF navyLocation(who) < 41 THEN
			PRINT cityName$(navyLocation(who))
		ELSE
			PRINT "Raiding"
		END IF
		menuText$(0) = "To"
		colour = 3: tlx = 67: tly = 12
		
		CALL ShowMenu(9): CALL clrrite: IF chosenOption < 1 THEN EXIT SUB
	admiral:
		IF array(chosenOption) = navyLocation(who) THEN EXIT SUB
		IF array(chosenOption) < 1 THEN EXIT SUB
		IF navySize(who) < 1 GOTO ships
		IF who = currentSide THEN hasNavy = 1
		GOSUB box2
		LOCATE 10, 25: PRINT nationName$(who); " fleet of"; navySize(who); "ship(s) is sailing"
		LOCATE 11, 25: PRINT "From ";
		IF navyLocation(who) < 41 THEN
			PRINT cityName$(navyLocation(who));
		ELSE
			PRINT "Raiding";
		END IF
		PRINT " to ";
		IF array(chosenOption) <> 99 THEN
			PRINT cityName$(array(chosenOption));
		ELSE
			PRINT "Raid Commerce";
		END IF

		FOR i = 1 TO navySize(who)
			PSET (120 + 41 * i, 210), 0
			CALL ShipType(who, i)
		NEXT i
		IF graphicLevel > 2 THEN
			a = ASC(LEFT$(fleet$(who), 1))
			SELECT CASE a
				CASE 73
					CALL DrawIronclad
				CASE 87
					CALL DrawSchooner
			END SELECT
			TICK 2 * turbo!
		ELSE
			TICK turbo!
		END IF
		navyLocation(who) = array(chosenOption)
		IF navyLocation(1) = navyLocation(2) GOTO navalbattle
		GOTO sail3
	'---------------------------------------------------------------------------
	'                               Raid Commerce
	'---------------------------------------------------------------------------
		CASE 4
		navySize(who) = LEN(fleet$(who))
		IF navySize(who) < 1 AND chx > 0 THEN EXIT SUB
		IF navySize(who) < 1 OR navalCommerce = who GOTO labelmanagenavy

		IF who = currentSide THEN hasNavy = 1
		GOSUB box2
		LOCATE 10, 25: PRINT nationName$(who); " fleet of"; navySize(who); "ship(s) is sailing"
		LOCATE 11, 25: PRINT "to RAID "; nationName$(3 - who); " COMMERCE !"

		FOR i = 1 TO navySize(who)
			PSET (120 + 41 * i, 210), 0
			CALL ShipType(who, i)
		NEXT i
		IF graphicLevel > 2 THEN
			a = ASC(LEFT$(fleet$(who), 1))
			SELECT CASE a
				CASE 73
					CALL DrawIronclad
				CASE 87
					CALL DrawSchooner
			END SELECT
			TICK 2 * turbo!
		ELSE
			TICK turbo!
		END IF
		navyLocation(who) = 99: navalCommerce = who
		IF navyLocation(1) = navyLocation(2) GOTO navalbattle
		CLS : CALL DrawMap
		EXIT SUB
	'---------------------------------------------------------------------------
	'                               Invasion
	'---------------------------------------------------------------------------
		CASE 5
		CALL commander((who), empty)
		IF chx > 0 AND empty = 0 THEN chx = 3: GOTO anchor
		x = 35
		CALL ShipDestroyed(who)
		c = navyLocation(who): CALL CreateNewArmy((who), empty, c)
		currentCash(who) = currentCash(who) + 100     'compensate for cost of recruiting new army
		CALL DrawCityCaptured(empty, c, who, 0)
		armySize(empty) = x
		IF who = currentSide THEN hasNavy = 1
		EXIT SUB
	'---------------------------------------------------------------------------
	'                               Exit
	'---------------------------------------------------------------------------
		CASE ELSE
		EXIT SUB
	END SELECT
	GOTO labelmanagenavy
	'---------------------------------------------------------------------------
	'                               Ship vs. Ship
	'---------------------------------------------------------------------------
	navalbattle:
		CLS : LOCATE 1, 30: COLOR 11: PRINT "NAVAL COMBAT"
		FOR k = 1 TO 2
		hit(k) = 10
		IF RIGHT$(fleet$(k), 1) = "I" THEN hit(k) = 20
		NEXT k
	drawnavalbattle:
		LOCATE 9, 1: PRINT SPACE$(79)
		LOCATE 15, 1: PRINT SPACE$(79)
		x = 10: y = 100
		COLOR 9: LOCATE 5, 25: PRINT "UNION"; navySize(1); "ship(s)"
		GOSUB boxes
		COLOR 1
		FOR i = 1 TO navySize(1)
		x = x + 50: PSET (x, y)
		CALL ShipType(1, i)
		NEXT i
		COLOR 11: LOCATE 11, 22: PRINT "CONFEDERATES "; navySize(2); "ship(s)"
		LINE (10, 180)-(530, 210), 1, BF
		LINE (10, 180)-(530, 210), 11, B
		x = 10: y = 200
		COLOR 1
		FOR i = 1 TO navySize(2)
		x = x + 50: PSET (x, y)
		CALL ShipType(2, i)
		NEXT i
		COLOR 11
	navalbattleoptions:
		menuText$(0) = "Options"
		menuText$(1) = "Attack"
		menuText$(2) = "Retreat"
		IF chx > 0 THEN chosenOption = 1: GOTO powder
		
		menuRows = 2: colour = 3: highlight = 14: tlx = 50: tly = 18: CALL ShowMenu(0)
	powder:
		SELECT CASE chosenOption
		CASE 1
	firemore:
		IF soundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
		pct! = 0: someString$ = RIGHT$(fleet$(who), 1)
		IF someString$ <> RIGHT$(fleet$(3 - who), 1) THEN
			IF someString$ = "I" THEN pct! = .1 ELSE pct! = -.1
		END IF
		IF RND <= .5 + pct! GOTO hitem ELSE GOTO hitme1
		GOTO firemore
	hitem:
		hit(3 - who) = hit(3 - who) - 1: GOSUB showhit: IF hit(3 - who) > 0 GOTO firemore
		x = 10 + 50 * navySize(3 - who)
		y = 90: IF who = 1 THEN y = 190
		GOSUB xout
		LOCATE 17, 5: PRINT nationName$(3 - who); " ship SUNK!": CALL TICK(turbo! + 1): GOSUB clr1
		CALL ShipDestroyed(3 - who)
		IF navySize(3 - who) < 1 THEN
			LOCATE 19, 5: COLOR 12
			PRINT nationName$(3 - who); " fleet DEFEATED"
			CALL TICK(turbo!)
			navyLocation(3 - who) = 0: fleet$(3 - who) = ""
			victoryPoints(3 - who) = victoryPoints(3 - who) + 10
			IF who = currentSide THEN grudge = 1 ELSE grudge = 0
			GOTO sail3
		END IF
		hit(3 - who) = 10
		IF RIGHT$(fleet$(3 - who), 1) = "I" THEN hit(3 - who) = 20
		GOTO drawnavalbattle
	hitme1:
		hit(who) = hit(who) - 1: GOSUB showhit: IF hit(who) > 0 GOTO firemore
		x = 10 + 50 * navySize(who)
		y = 190: IF who = 1 THEN y = 90
		GOSUB xout
		LOCATE 17, 5: PRINT "One of the "; nationName$(who); " ships was SUNK!": CALL TICK(turbo!): GOSUB clr1
		CALL ShipDestroyed(who)
		IF navySize(who) < 1 THEN
			LOCATE 19, 5: COLOR 12
			PRINT "Attacking "; nationName$(who); " fleet has been ELIMINATED !"
			CALL TICK(turbo!)
			navyLocation(who) = 0: fleet$(who) = ""
			victoryPoints(who) = victoryPoints(who) + 10
			IF who <> currentSide THEN grudge = 1 ELSE grudge = 0
			GOTO sail3
		END IF
		hit(who) = 10
		IF RIGHT$(fleet$(who), 1) = "I" THEN hit(who) = 20
		GOTO drawnavalbattle

		CASE 2
		target = 0
		FOR i = 1 TO 40
		IF cityOwner(i) = who THEN IF i <> navyLocation(who) AND matrix(i, 7) = 99 THEN target = i: IF RND > .3 GOTO found1
		NEXT i
	found1:
		CALL clrbot: COLOR 11: PRINT nationName$(who); " is retreating to "; cityName$(target); : CALL TICK(turbo!)
		navyLocation(who) = target
		GOTO sail3
		CASE ELSE
		GOTO navalbattleoptions
		END SELECT
		GOTO navalbattle
	'---------------------------------------------------------------------------
	'                               Subs
	'---------------------------------------------------------------------------
	showhit:
		LOCATE 9, 6 * navySize(1): PRINT hit(1); " ";
		LOCATE 15, 6 * navySize(2): PRINT hit(2); " ";
		IF soundEffects = 0 THEN TICK .1 * turbo!
		RETURN
	clr1:
		LOCATE 17, 1: PRINT SPACE$(60): RETURN
	nest:
		best = 0: x = 0
		FOR i = 1 TO menuRows
		target = array(i)
		IF cityOwner(target) = 0 GOTO neutral

		IF target = navyLocation(3 - who) THEN IF navySize(who) >= navySize(3 - who) AND RND > .1 THEN chosenOption = i: RETURN
		IF cityOwner(target) <> who THEN
			best = i: x = x + 1
			IF RND > .8 THEN chosenOption = best: RETURN
		END IF
	neutral:
		NEXT i
		IF best = 0 THEN
			chosenOption = 1 + INT(RND * menuRows)
		ELSE
			chosenOption = best
		END IF

		IF who = 2 AND navyLocation(2) = 30 THEN IF RND > .5 THEN chosenOption = 30: RETURN
		RETURN
	boxes:
		LINE (10, 80)-(530, 110), 1, BF
		LINE (10, 80)-(530, 110), 11, B
		RETURN
	box2:
		CLS
		LINE (100, 110)-(550, 240), 1, B
		LINE (95, 115)-(555, 235), 7, B
		RETURN
	xout:
			PSET (x, y)
			DRAW "S5C15G5F5G3H5G5H3E5H5E3F5E5F3"
			PAINT (x - 3, y + 1), 12, 15
		RETURN
	sail3:
		navalCommerce = 0
		FOR k = 1 TO 2
		IF navyLocation(k) = 99 THEN navalCommerce = k
		NEXT k
		CLS : CALL DrawMap
END SUB

SUB CreateNewArmy (who%, empty%, target%)
	armySupply(empty) = 3 + 5 * RND: IF who = 1 THEN armySupply(empty) = armySupply(empty) + 2
	armyExp(empty) = 1: IF who = 2 THEN armyExp(empty) = 2
	armyCommander(empty) = leaderRating(empty)
	armyName$(empty) = leaderName$(empty): leaderName$(empty) = ""
	COLOR 12: CALL clrbot: PRINT "Placing NEW army "; empty; armyName$(empty); " in "; cityName$(target);

	x = 70: IF realism > 0 THEN x = 3 * cityValue(target) + 33
	CALL cutoff(who, target, a): IF a < 1 THEN x = x \ 3
	isOccupied(target) = empty: armySize(empty) = x
	PRINT " Size = "; : CALL CorrectArmySize(empty)
	currentCash(who) = currentCash(who) - 100: IF soundEffects > 0 THEN SOUND 2222, .5
	armyLocation(empty) = target: CALL DrawArmyUnit(empty)
	CALL TICK(turbo! - .5)
	armyMove(empty) = -1
END SUB

SUB newcity (index%)
			menuText$(1) = "  "
			menuText$(3) = "  "
			menuRows = 3: someString$ = cityName$(index)
	morecap:
			tlx = 68: tly = 15: colour = 3: chosenOption = 23
			menuText$(2) = cityName$(index)
			CALL ShowMenu(3): CALL clrrite
			SELECT CASE chosenOption
			CASE IS = -27
			index = 0: EXIT SUB
			CASE IS < 1
			someString$ = CHR$(ABS(chosenOption))
			x = 0
			FOR k = 1 TO 40
			IF LEFT$(cityName$(k), 1) = someString$ THEN
				y = index: index = k
	spin2:
				IF cityOwner(index) = currentSide GOTO morecap
					index = index + 1
					IF index > 40 THEN index = 1
					x = x + 1: IF x < 39 GOTO spin2
					index = y: GOTO morecap
			END IF
			NEXT k
			GOTO morecap
			CASE 1
	minus1:
			index = index - 1: IF index < 1 THEN index = 40
			IF cityOwner(index) <> currentSide GOTO minus1 ELSE GOTO morecap
			CASE 2
			EXIT SUB
			CASE 3
	plus1:
			index = index + 1: IF index > 40 THEN index = 1
			IF cityOwner(index) <> currentSide GOTO plus1 ELSE GOTO morecap
			CASE ELSE
			index = 0
			END SELECT
END SUB

SUB normal (xbar%, vary%, result%)
	' NOTE : vary is VARIANCE
	pct! = 0
	FOR k = 1 TO 12: pct! = pct! + RND: NEXT k
	pct! = pct! - 5.5
	result = xbar + pct! * SQR(vary)
END SUB

SUB railroad (who%)
	SELECT CASE rr(who)
		CASE 0
		IF who = currentSide GOTO human
		CALL StartToFinish(start, fin, who): max = 32767
		index = 0
		FOR i = start TO fin: IF armyLocation(i) = 0 OR armyMove(i) <> 0 GOTO puter
		x = 0: FOR j = 1 TO 6: from = matrix(armyLocation(i), j): IF from > 0 AND cityOwner(from) <> who THEN x = x + 1
		NEXT j
		IF isOccupied(capitalCity(who)) > 0 AND x > 1 GOTO puter
		CALL void(armyLocation(i), defend)
		IF victoryFlags(5) > 0 AND isOccupied(capitalCity(who)) = 0 THEN IF defend > max THEN defend = max - 1
		IF defend < max THEN target = armyLocation(i): GOSUB route: IF x > 1 THEN max = defend: index = i
	puter:  NEXT i
		IF index = 0 OR max > .3 * armySize(index) GOTO toot
		CALL traincapacity(who, limit)
		IF armySize(index) > limit THEN GOTO toot
		from = armyLocation(index)
		x1 = 0: FOR i = 1 TO 40: IF cityOwner(i) <> who GOTO puted
		CALL void(i, defend): IF defend = 0 OR defend > 3 * armySize(index) GOTO puted
		IF isOccupied(i) > 0 GOTO puted
		target = i
		GOSUB route: IF x = 0 GOTO puted
		IF currentSide = 1 AND cityY(i) < cityY(from) THEN x1 = i
		IF currentSide = 2 AND cityY(i) > cityY(from) THEN x1 = i
		IF fortLevel(i) > 0 AND isOccupied(i) = 0 THEN x1 = i: EXIT FOR
	puted:  NEXT i
		IF victoryFlags(5) > 0 AND isOccupied(capitalCity(who)) = 0 THEN
			GOSUB route
			IF x > 0 THEN
				CALL void(capitalCity(who), defend)
				IF defend > 0 THEN x1 = capitalCity(who)
			END IF
		END IF
		IF x1 > 0 GOTO confirmrrdestination ELSE GOTO toot
	human:
		CALL MoveFrom(index, a): IF a < 1 OR index < 1 THEN COLOR 11: CALL clrbot: PRINT "Railroad move not allowed"; : GOTO toot
		x = 1: IF index > 20 THEN x = 2
		CALL traincapacity(who, limit)
		IF armySize(index) > limit THEN CALL clrbot: PRINT "Too many troops for railroad capacity"; : GOTO toot
		
		target = armyLocation(index): GOSUB route: IF x > 1 GOTO chooserrdestination
		CALL clrbot: PRINT "Track from "; cityName$(target); " is blocked"; : GOTO toot
	chooserrdestination:
		CALL clrbot: PRINT "Select destination for "; armyName$(index); " from "; cityName$(target);
		menuText$(0) = "To": from = target: x1 = from: IF from = 0 GOTO toot
		CALL newcity(x1): IF x1 = from OR x1 = 0 GOTO toot

		target = x1: GOSUB route: IF x > 1 GOTO confirmrrdestination
		CALL clrbot: PRINT armyName$(index); "'s train cannot go to "; cityName$(x1); " - select another city"; : CALL TICK(9)
		GOTO chooserrdestination
	confirmrrdestination:
		COLOR 11: CALL clrbot: PRINT armyName$(index); " is taking the train from "; cityName$(from); " to "; cityName$(x1);
		armyOnRailroad(who) = armyLocation(index)
		from = armyLocation(index)
		rrFrom(who) = from
		rr(who) = index: armyLocation(index) = 0: armyMove(index) = x1
		CALL tinytrain(who, 1)
		IF soundEffects > 0 THEN SOUND 2222, 1
		CALL engine

		CALL occupy(from)
		IF isOccupied(from) > 0 THEN CALL DrawArmyUnit(isOccupied(from))
		GOTO toot

		CASE IS > 0
		CALL tinytrain(who, 0)
		CALL occupy(rrFrom(who))
		IF isOccupied(rrFrom(who)) > 0 THEN CALL DrawArmyUnit(isOccupied(rrFrom(who)))

		index = rr(who)
		armyOnRailroad(who) = armyMove(index)
		CALL tinytrain(who, 1)

		rr(who) = 0: armyLocation(index) = armyMove(index): armyMove(index) = -1
		COLOR 11: CALL clrbot: PRINT "Train with "; armyName$(index); " has arrived in "; cityName$(armyLocation(index)); : IF soundEffects > 0 THEN SOUND 1200, 2
		CALL TICK(turbo!)
		x = cityX(armyLocation(index)) - 12: y = cityY(armyLocation(index)) - 11
		LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
		IF cityOwner(armyLocation(index)) <> who THEN CALL DrawCityCaptured(index, armyLocation(index), who, 0)
		CALL DrawArmyUnit(index)
		IF isOccupied(armyLocation(index)) > 0 THEN CALL stax(who): GOTO toot
		CALL occupy(armyLocation(index)): CALL DrawArmyUnit(index)
		GOTO toot
	END SELECT

	route:
		x = 0: FOR j = 1 TO 6
		y = matrix(target, j)
		IF y > 0 AND cityOwner(y) = who THEN
		x = x + 1
			FOR m = 1 TO 6
			z = matrix(y, m)
			IF z > 0 AND z <> target AND cityOwner(z) = who THEN x = x + 1
			NEXT m
		END IF
	NEXT j
	RETURN

	toot:
		IF who = currentSide THEN CALL TICK(9)
		CALL clrrite
		clrbot
END SUB

SUB RecruitArmy (who%)
		IF currentCash(who) < 100 THEN EXIT SUB
		menuRows = 0: COLOR 12
		menuText$(0) = "Recruit"
		IF who = currentSide AND recruitFlag > 0 THEN FOR i = 1 TO recruitFlag: x = recruitCity(i): menuText$(i) = cityName$(x): array(i) = x: NEXT i: menuRows = recruitFlag: GOTO alldone
		max = 4: IF RND > .8 THEN max = max - 1
		IF difficultyLevel < 3 THEN max = max + 1

		FOR i = 1 TO 40
		IF cityController(who) > 0 THEN pct! = .6 * max / cityController(who) ELSE pct! = .3
		IF menuRows = 0 AND i > 20 THEN pct! = .3
		IF menuRows < 2 AND i > 30 THEN pct! = .3
		array(i) = 0
		IF isOccupied(i) > 0 AND cityOwner(i) = who THEN pct! = .4
		IF RND < pct! AND cityOwner(i) = who THEN
			IF realism > 0 AND cityO(i) = 3 - who GOTO foe
			menuRows = menuRows + 1
			menuText$(menuRows) = cityName$(i)
			array(menuRows) = i
			IF menuRows > max - 1 GOTO alldone
		END IF
	foe:
		NEXT i
	alldone:
		IF menuRows = 0 THEN EXIT SUB
		IF who = currentSide AND recruitFlag = 0 THEN FOR i = 1 TO menuRows: recruitCity(i) = array(i): NEXT i: recruitFlag = menuRows
		CALL bubble(menuRows)
	'............................................................................
	levy:
		IF currentCash(who) < 100 THEN EXIT SUB
		IF (who = currentSide) OR (humanPlayers = 2) THEN CALL clrbot: PRINT nationName$(who); " funds available "; currentCash(who);
		tlx = 67: tly = 12: colour = 3
		IF who <> currentSide THEN GOSUB randsel: GOTO auto1
		
		IF chosenOption > 0 THEN chosenOption = 21 + chosenOption
		CALL ShowMenu(2): CALL clrrite
		IF chosenOption < 1 THEN EXIT SUB
	auto1:
		empty = 0
		index = array(chosenOption)
		CALL occupy(index)
		IF isOccupied(index) > 0 THEN i = isOccupied(index): GOTO add2
		CALL commander((who), empty)
		
		IF who <> currentSide AND empty = 0 THEN EXIT SUB
		IF empty = 0 GOTO levy
		armyLocation(empty) = index
		GOSUB playb
		CALL CreateNewArmy(who, empty, index)
		GOTO levy
	'............................................................................
	add2:
		target = array(chosenOption)
		x = 45: someString$ = ""
		IF realism > 0 THEN
			x = 2 * cityValue(armyLocation(i)) + 20
			CALL cutoff(who, target, a)
			IF a < 1 THEN x = x \ 3: someString$ = " ISOLATED !"
		END IF
		armySize(i) = armySize(i) + x

		GOSUB playb
		currentCash(who) = currentCash(who) - 100
		from = armyLocation(i): x = cityX(from) - 12: y = cityY(from) - 11
		GET (x - 9, y - 7)-(x + 9, y + 6), anima
		CALL MoveUnitIcon(armyLocation(i), 0, 2)
		IF soundEffects > 0 THEN SOUND 2222, 1
		COLOR 11: CALL clrbot: PRINT "Army "; i; armyName$(i); " in "; cityName$(armyLocation(i)); " strength increased to "; : CALL CorrectArmySize(i)
		IF someString$ <> "" THEN PRINT someString$;
		PUT (x - 9, y - 7), anima, PSET
		CALL TICK(turbo! - .5)
		GOTO levy
	randsel:
			chosenOption = 0: x = 0
			FOR i = 1 TO menuRows
			target = array(i)
			LOCATE 14 + i, 69
			x = isOccupied(target)
			IF x = 0 XOR armySize(x) < 155 THEN chosenOption = i
			NEXT i

		IF chosenOption = 0 THEN chosenOption = 1 + INT(RND * menuRows)
		IF realism > 0 THEN
			x = 0
			FOR i = 1 TO menuRows
			target = array(i)
			IF isOccupied(target) = 0 THEN
				y = 3 * cityValue(target) + 33
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			ELSE
				y = 2 * cityValue(target) + 20
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			END IF
			IF y > x AND RND > .5 THEN x = y: chosenOption = i
			NEXT i
		END IF
		IF currentCash(who) < 100 THEN chosenOption = menuRows
		RETURN
	playb:
		IF currentSide = 1 AND difficultyLevel < 3 THEN armySize(empty) = armySize(empty) + 15 - 5 * difficultyLevel
		IF currentSide = 2 AND difficultyLevel > 3 THEN armySize(empty) = armySize(empty) + 5 * difficultyLevel - 15
		RETURN
END SUB

SUB ShipType (who%, i%)
	a = 1: IF MID$(fleet$(who), i, 1) = "I" THEN a = 2
	CALL DrawShipIcon(who, a)
END SUB

SUB ComputerPlayer
	CALL SpecialEvents
	slush = 0: who = 3 - currentSide
	c = 9: IF currentSide = 1 THEN c = 15
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR c: LOCATE 1, 10: PRINT nationName$(who); " Side is making decisions";
	CALL StartToFinish(start, fin, who)
	'==========================================================================
	'                       Check Supply
	'==========================================================================
	FOR i = start TO fin: IF armyLocation(i) > 0 AND armySupply(i) < 1 THEN CALL ResupplyArmy(i)
	NEXT i
	'==========================================================================
	'                       Fortify Capital or Other City
	'==========================================================================
	cost = 200
	IF cost > currentCash(who) GOTO signup

	target = 0: IF isOccupied(capitalCity(who)) = 0 OR fortLevel(capitalCity(who)) > 1 GOTO city2
	target = capitalCity(who)
	IF cityOwner(target) = who GOTO capital ELSE GOTO city2
	IF target > 0 GOTO capital

	city2:
	IF 1 + RND < aiBoldness + aggress! GOTO signup
	target = 0: FOR i = start TO fin
	x = armyLocation(i): IF x = 0 OR armyMove(isOccupied(x)) < 0 OR armyMove(i) < 0 GOTO endlook
	IF fortLevel(x) > 1 GOTO endlook
		CALL void(x, defend): IF defend > armySize(i) THEN target = armyLocation(i): GOTO capital
	endlook:
	NEXT i

	capital:
		IF target = 0 GOTO signup
		IF fortLevel(target) > 1 GOTO signup
		fortLevel(target) = fortLevel(target) + 1
		x = isOccupied(target): armyMove(x) = -1
		currentCash(who) = currentCash(who) - cost
		CALL clrbot: PRINT cityName$(target); " fortifications increased to "; fortLevel(target);
		CALL MoveUnitIcon(target, 0, 6)
		CALL DrawCities
		IF who = 1 AND navySize(1) < 1 AND RND > .5 AND currentCash < 222 GOTO signup
		IF 3 * RND > 1 + aggress! AND currentCash(who) >= cost GOTO city2
	'==========================================================================
	'                       Recruit New Armies
	'==========================================================================
	signup:
	IF who = 1 AND navySize(1) < 1 AND currentCash(1) > 100 THEN CALL ManageNavy(1, 1): IF currentCash(who) < 100 GOTO isok
	GOSUB enufarmies
	IF x > 2 + 3 * currentSide + 3 * RND GOTO isok
	IF navySize(who) < 5 AND currentCash(who) > 100 AND navyLocation(who) <> 99 THEN IF cityOwner(navyLocation(who)) = who THEN slush = slush + 100: currentCash(who) = currentCash(who) - 100: IF currentCash(who) < 100 GOTO isok
	CALL RecruitArmy(who)
	'==========================================================================
	'                         Naval Commands
	'==========================================================================
	isok:
		currentCash(who) = currentCash(who) + slush
		IF currentSide = 2 AND navyLocation(1) = 0 AND navySize(1) < 1 AND cityOwner(30) = 1 AND currentCash(1) > 100 THEN navyLocation(1) = 30: CALL ManageNavy(1, 1): GOTO movenavy
		IF navyLocation(who) = 99 THEN
			IF RND < .9 THEN CALL ManageNavy(who, 3)
			GOTO movearmy
		END IF
		IF currentCash(who) < 100 OR navySize(who) > 9 OR cityOwner(navyLocation(who)) <> who GOTO movenavy
		CALL ManageNavy(who, 1)
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	movenavy:
		IF navySize(who) = 0 THEN navyLocation(who) = 0
		IF navyLocation(who) = 0 GOTO movearmy
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	'                     move ships & prohibit further action this turn
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		IF navyLocation(who) <> 99 THEN
			IF cityOwner(navyLocation(who)) = who THEN CALL ManageNavy(who, 3): GOTO movearmy   'move ships & prohibit further action this turn
			IF cityOwner(navyLocation(who)) = 0 THEN CALL ManageNavy(who, 3): GOTO movearmy
		ELSE
			IF RND < .5 THEN CALL ManageNavy(who, 3)
			GOTO movearmy
		END IF

		IF cityOwner(navyLocation(who)) <> who THEN
			IF isOccupied(navyLocation(who)) = 0 OR RND > .3 THEN
				CALL ManageNavy(who, 2) 'attack
			ELSE
				CALL ManageNavy(who, 3) 'move
			END IF
		END IF
	'==========================================================================
	'                       Give Move Orders to Each Army
	'==========================================================================
	movearmy:
		CALL ships
	'---------------------------------------------------------------------------
	'                               Check to Combine
	'---------------------------------------------------------------------------
	a = who: CALL CombineArmies(a)
	CALL railroad(who)
	'---------------------------------------------------------------------------
	'                               Top Priority
	'---------------------------------------------------------------------------
	FOR i = start TO fin
	target = armyLocation(i)
	IF armyLocation(i) < 1 OR armyMove(i) < 0 GOTO deadman
	x = armySize(i): IF armySupply(i) < 1 AND RND > .1 GOTO deadman

	chosenOption = 0

	CALL void(target, defend)

	IF defend > 0 AND target = capitalCity(who) AND isOccupied(target) = i GOTO deadman   'hold capital
	IF target <> capitalCity(who) GOTO nocap
	IF victoryFlags(5) = 0 GOTO nocap
		FOR j = 1 TO 6
		k = matrix(target, j): IF j = 0 GOTO nocap
		CALL void(k, flag): IF flag > 0 GOTO deadman
		NEXT j
	nocap:
	CALL evaluate(i, best): IF best = 0 GOTO deadman
	move9:
		IF best = 0 THEN chosenOption = 1 + INT((j - 1) * RND)
		IF chosenOption = 0 THEN chosenOption = best
		armyMove(i) = matrix(target, chosenOption)

		IF cityOwner(armyMove(i)) = who THEN y = isOccupied(armyMove(i)): IF y > 0 THEN IF armyMove(y) = x THEN armyMove(i) = 0: GOTO deadman  ' eliminate crossing moves
		IF currentMonth = 1 AND januaryCampaign = 0 AND cityOwner(armyMove(i)) <> who THEN armyMove(i) = 0: GOTO deadman

		IF turbo! > 1 THEN
			COLOR c: CALL clrbot
			PRINT armyName$(i); " plans to move from "; cityName$(armyLocation(i)); " to "; cityName$(armyMove(i));
		END IF
			CALL MoveUnitIcon(armyLocation(i), armyMove(i), 1)
			CALL MoveUnitIcon(armyLocation(i), armyMove(i), 9)
		CALL TICK(turbo! - 1)
		PUT (cityX(armyLocation(i)) - 20, cityY(armyLocation(i)) - 19), image, PSET
	deadman:
	NEXT i
		FOR i = start TO fin
		IF armyMove(i) = 0 AND armyExp(i) < 6 AND armyExp(i) < armyCommander(i) THEN
			armyExp(i) = armyExp(i) + 1

			IF turbo! > 1 THEN
			CALL clrbot
				PRINT armyName$(i); " has drilled to reach experience level "; armyExp(i);
			END IF
			armyMove(i) = -1
			CALL TICK(turbo! - 1)
		END IF
		NEXT i
	EXIT SUB
	'---------------------------------------------------------------------------
	enufarmies:
	CALL StartToFinish(start, fin, 3 - who)
	FOR i = start TO fin
		IF armyLocation(i) > 0 THEN y = y + .1 * armySize(i)
	NEXT i
	CALL StartToFinish(start, fin, who)
	x = 0: z = 0: FOR i = start TO fin: IF armyLocation(i) > 0 THEN x = x + 1: z = z + .1 * armySize(i)
	NEXT i
	IF y > z THEN x = x - 2
	IF y > 2 * z THEN x = 0
	RETURN
	'---------------------------------------------------------------------------
END SUB

SUB snapshot (x%, y%, flag%)
	IF flag = 0 THEN GET (x - 10, y - 10)-(x + 10, y + 10), image
	IF flag = 1 THEN PUT (x - 10, y - 10), image, PSET
END SUB

SUB CorrectArmySize (index%)
	someString$ = LTRIM$(RTRIM$(STR$(armySize(index)))) + "00"
	PRINT someString$;
END SUB

SUB tinytrain (who%, flag%)
		IF armyOnRailroad(who) = 0 THEN EXIT SUB
		from = armyOnRailroad(who)
		x = cityX(from) - 12: y = cityY(from) - 11
	SELECT CASE flag
		CASE IS > 0
		LINE (x - 8, y - 6)-(x + 10, y + 7), 10, BF
		PSET (x - 6, y - 2), 3: c = 9: IF who = 2 THEN c = 15
		DRAW "C0S2R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5BF4S4"
		x = POINT(0): y = POINT(1): PAINT (x, y), c, 0
		CASE ELSE
		LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
	END SELECT
END SUB

SUB TurnUpdate
	flag = 0
	IF humanPlayers = 1 THEN
		CALL ComputerPlayer
	ELSE
		FOR i = 1 TO 40
		IF armyLocation(i) > 0 AND armyMove(i) > 0 THEN CALL MoveUnitIcon(armyLocation(i), armyMove(i), 1)
		NEXT i
	END IF
	COLOR 14: LOCATE 1, 1: PRINT SPACE$(80);
	LOCATE 1, 20: PRINT "Update for "; monthes$(currentMonth); ","; currentYear
	CALL clrbot: PRINT "press any key for "; monthes$(currentMonth); ","; currentYear; " events";
	DO WHILE INKEY$ = "": LOOP
	GOSUB turnupdatebox
	'==========================================================================
	'                       Assign Time of Action
	'==========================================================================
	FOR i = 1 TO 2: IF rr(i) > 0 THEN CALL railroad(i): LINE (5, 17)-(100, 63), 3, BF: LINE (5, 17)-(100, 63), 0, B: CALL engine
	NEXT i

	FOR i = 1 TO 40
	orderOfMoves(i) = 999
	IF armyMove(i) < 0 THEN armyMove(i) = 0
	IF armyLocation(i) > 0 AND armyMove(i) > 0 THEN orderOfMoves(i) = INT(4 + 4 * RND) * 100 + i
	IF armySupply(i) < 1 AND armyMove(i) > 0 THEN orderOfMoves(i) = 900 + i
	SELECT CASE armySize(i)         'bigger armies move slower
		CASE IS > 400
			IF orderOfMoves(i) < 900 THEN orderOfMoves(i) = orderOfMoves(i) + 100: x = 2
		CASE IS > 800
			IF orderOfMoves(i) < 800 THEN orderOfMoves(i) = orderOfMoves(i) + 200: x = 3
		CASE IS > 1000
			IF orderOfMoves(i) < 700 THEN orderOfMoves(i) = orderOfMoves(i) + 300: x = 4
		CASE ELSE
			x = 1
	END SELECT
	IF orderOfMoves(i) <> 999 AND armyCommander(i) > 10 * RND THEN
			orderOfMoves(i) = orderOfMoves(i) - 100 * (armyCommander(i) \ 2)
			IF orderOfMoves(i) < 100 THEN orderOfMoves(i) = 100 + i
	END IF
	NEXT i

	CALL SortArmyMoves(40)
	'==========================================================================
	'                       Begin Main Loop
	'==========================================================================
	FOR j = 1 TO 40
	flag = 0
	IF orderOfMoves(j) = 999 GOTO allthru
	active = INT(orderOfMoves(j) / 100): active = orderOfMoves(j) - 100 * active: s = 1: IF active > 20 THEN s = 2
	IF armyMove(active) < 1 GOTO digin
	COLOR 11: CALL clrbot: PRINT armyName$(active); " is moving to "; cityName$(armyMove(active));

	armySupply(active) = armySupply(active) - 1: IF armySupply(active) < 0 THEN armySupply(active) = 0: CALL TICK(turbo!): CALL clrbot: PRINT armyName$(active); " is out of supplies !";

	CALL DrawArmyUnit(active)
	CALL MoveUnitIcon(armyLocation(active), armyMove(active), 5)

	CALL AnimateMovement(active, 0)
	'==========================================================================
	target = armyMove(active)
	IF isOccupied(target) = 0 GOTO moveintonewcity
	IF (s = 1 AND isOccupied(target) < 21) OR (s = 2 AND isOccupied(target) > 20) GOTO friendlyarmiesmeet ELSE GOTO enemyarmiesbattle
	'==========================================================================
	'                         Join Forces
	'==========================================================================
	friendlyarmiesmeet:
	COLOR 11: CALL clrbot: PRINT armyName$(active); " and "; armyName$(isOccupied(target)); " meet in "; cityName$(target); : CALL TICK(turbo!)
	CALL MoveUnitIcon(armyMove(active), 0, 6)
	CALL clrbot
	GOTO moveintonewcity
	'==========================================================================
	'                       Attack
	'==========================================================================
	enemyarmiesbattle:
	CALL MoveUnitIcon(target, 0, 3)
	defend = isOccupied(target)

	COLOR 11: CALL clrbot: PRINT armyName$(active); " attacks "; armyName$(defend); " in "; cityName$(armyLocation(defend)); : CALL TICK(turbo! - 1)
	IF armySize(defend) > 0 THEN CALL battle(active, defend, win, lose): flag = 1: IF graphicLevel > 0 THEN GOSUB turnupdatebox
	IF armyExp(win) < 10 THEN armyExp(win) = armyExp(win) + 1

	IF armySize(lose) < 2 THEN
		CALL clrbot
		someString$ = armyName$(lose) + "'s army is crushed in " + cityName$(armyLocation(defend))
		CALL scribe(someString$, 2)
		index = lose: GOTO crushed
	END IF

	CALL clrrite
	'==========================================================================
	'                       Attacker Loses
	'==========================================================================
	IF win = active GOTO defenderretreats
	armyMove(active) = armyLocation(active)
	armyLocation(active) = target
	COLOR 11: CALL clrbot: PRINT armyName$(active); " withdrew to "; cityName$(armyMove(active));

	CALL DrawArmyUnit(armyLocation(active))
	CALL AnimateMovement(active, 1)

	armyLocation(active) = armyMove(active)
	CALL DrawArmyUnit(armyLocation(active))
	CALL DrawArmyUnit(active)
	isOccupied(armyLocation(active)) = active
	armyMove(active) = -2
			
	IF 11 * RND > armyCommander(defend) THEN CALL MoveUnitIcon(armyLocation(defend), armyMove(defend), 4): IF armyMove(defend) > 0 THEN armyMove(defend) = -2

	CALL TICK(turbo!): GOTO digin
	'==========================================================================
	'                       Defender Retreats
	'==========================================================================
	defenderretreats:
		CALL MoveUnitIcon(armyLocation(active), target, 4)
		IF armyMove(defend) > 0 THEN CALL MoveUnitIcon(target, armyMove(defend), 4)

		CALL retreat(defend, flee): IF flee > 0 THEN move2 = flee: GOTO outta

		best = 0: flee = 0
		FOR i = 1 TO 6
		x = matrix(target, i)
		IF x > 0 AND (cityOwner(x) = 3 - s) AND cityValue(x) > best THEN
			IF best = 0 THEN
				flee = i: best = cityValue(x)
			ELSE
				IF isOccupied(x) = 0 THEN flee = i: best = cityValue(x)
			END IF
		END IF
		NEXT i
		IF flee = 0 GOTO defendersurrenders
		move2 = matrix(target, flee)
	outta:
		CALL DrawArmyUnit(defend)                  ' in old city

		armyMove(defend) = move2
		CALL AnimateMovement(defend, 0)                 ' animate retreat
		
		armyLocation(defend) = move2
		isOccupied(move2) = defend
		CALL clrbot
		PRINT armyName$(defend) + " is withdrawing to " + cityName$(move2);

		CALL DrawArmyUnit(defend)                  ' in new city
		
		CALL MoveUnitIcon(target, 0, 6)
		armyMove(defend) = -2
		GOTO checkmoredefenders

	defendersurrenders:
		index = defend
		someString$ = armyName$(index) + " surrenders to " + armyName$(active) + " in " + cityName$(armyLocation(index))
		CALL scribe(someString$, 2)
	crushed:
		IF graphicLevel > 2 THEN CALL DrawArmySurrender(index): COLOR 14: LOCATE 3, 68: PRINT armyName$(index): LOCATE 4, 68: PRINT "surrenders !"
		x = 1: IF index > 20 THEN x = 2
		IF soundEffects > 1 AND x <> currentSide THEN PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"
		IF armyMove(index) > 0 THEN CALL MoveUnitIcon(armyLocation(index), armyMove(index), 4)
		victoryPoints(3 - s) = victoryPoints(3 - s) + 25
		armyLocation(index) = 0: leaderName$(index) = "": armyName$(index) = ""
		armySize(index) = 0: armyCommander(index) = 0
		armyExp(index) = 0: armyMove(index) = 0: armySupply(index) = 0
		armySupply(active) = armySupply(active) + armySupply(index): armySupply(index) = 0
		IF armySupply(active) > 10 THEN armySupply(active) = 10
		CALL TICK(9): CALL clrrite
		IF armyLocation(active) = 0 GOTO digin
	'---------------------------------------------------------------------------
	'                       check for more defenders !
	'---------------------------------------------------------------------------
	checkmoredefenders:
		CALL occupy(target): IF isOccupied(target) = 0 GOTO moveintonewcity
		COLOR 11: CALL clrbot: PRINT "There are still defenders in "; cityName$(target); : CALL TICK(99)
		GOTO enemyarmiesbattle
	'==========================================================================
	'                       Move Into New City
	'==========================================================================
	moveintonewcity:
	CALL MoveUnitIcon(armyLocation(active), target, 4)
	armyLocation(active) = target: armyMove(active) = -2
	CALL occupy(armyLocation(active))
	CALL DrawArmyUnit(active)
	'---------------------------------------------------------------------------
	'                            City Capture
	'---------------------------------------------------------------------------
		IF cityOwner(armyLocation(active)) = s GOTO horde
		c = armyLocation(active)
		IF humanPlayers = 1 AND s = currentSide AND fortLevel(c) > 0 AND flag = 0 THEN
			tlx = 67: tly = 15
			highlight = 15: colour = 3
			menuText$(0) = "Raze ?"
			menuText$(1) = "No"
			menuText$(2) = "Yes"
			menuRows = 2
			CALL ShowMenu(0)
			CALL clrrite
			IF chosenOption = 2 GOTO razefort
		END IF
		IF humanPlayers = 1 AND s <> currentSide AND fortLevel(c) > 0 AND flag = 0 THEN
			IF realism > 0 AND cityY(c) > 150 THEN
	razefort:
				fortLevel(c) = 0
				x = cityX(c)
				y = cityY(c)
				LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
				CALL DrawCities
				CALL clrbot
				PRINT armyName$(active); " has destroyed the forts at "; cityName$(c);
				TICK 3
			END IF
		END IF
		CALL DrawCityCaptured(active, c, s, flag)
	horde:
	IF armySupply(active) < 10 THEN armySupply(active) = armySupply(active) + 1: IF RND > .8 GOTO horde
	digin:
	NEXT j
	GOTO allthru

	turnupdatebox:
	LINE (450, 318)-(526, 420), 1, BF
	LINE (527, 315)-(527, 439), 10
	COLOR 14: LOCATE 23, 50: PRINT "============="
	LOCATE 24, 50: PRINT "| U P D A T E |"
	LOCATE 25, 50: PRINT "============="
	RETURN

	allthru:
	IF navySize(navalCommerce) < 1 THEN navalCommerce = 0
	IF navalCommerce > 0 THEN
		CALL clrbot
		IF RND < .8 + .02 * navySize(navalCommerce) THEN
			navalRaider = .05 * navySize(navalCommerce) * (1 + RND) * (currentIncome(3 - navalCommerce))
			IF navalRaider < 1 THEN navalRaider = 1
			IF navalRaider / currentIncome(3 - navalCommerce) > .3 THEN navalRaider = .3 * currentIncome(3 - navalCommerce)
			COLOR 15: PRINT nationName$(navalCommerce); " raiders have sunk $"; navalRaider; " of "; nationName$(3 - navalCommerce); " commerce";
			a = 1: IF LEFT$(fleet$(navalCommerce), 1) = "I" THEN a = 2
			PSET (500, 465), 0: CALL DrawShipIcon(navalCommerce, a)
			IF soundEffects > 0 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
			IF navalCommerce = currentSide THEN grudge = 1
			TICK 9
		ELSE
			navalRaider = 0
			CALL ShipDestroyed(navalCommerce)
			COLOR 15: PRINT nationName$(navalCommerce); " raiders have lost a ship ("; navySize(navalCommerce); " remain)";
			IF soundEffects > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
			IF navyLocation(navalCommerce) > 0 THEN
				TICK 9
				GOTO allthru
			ELSE
				navalCommerce = 0
				LINE (447, 291)-(525, 335), 1, BF
				FOR k = 1 TO 5: CIRCLE (480, 315), 4 * k, 11: NEXT k
				TICK 9
				LINE (447, 291)-(525, 335), 1, BF
			END IF
		END IF
	END IF

	CALL TouchupMap: CALL ships: CALL ProcessTurn

	CALL clrbot
	LINE (390, 350)-(520, 400), 1, BF
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(monthes$(currentMonth), 3)); ","; currentYear
	victoryPoints(1) = .8 * victoryPoints(1) + .3 * (currentIncome(1) + cityController(1))
	IF cityController(1) > 29 THEN victoryPoints(1) = victoryPoints(1) + 50: IF cityController(1) > 34 THEN victoryPoints(1) = victoryPoints(1) + 100
	IF currentSide = 2 AND cityController(1) < 11 THEN aggress! = aggress! + .7

	IF victoryPoints(1) < 1 THEN victoryPoints(1) = 0
	victoryPoints(2) = .8 * victoryPoints(2) + .3 * (currentIncome(2) + cityController(2))
	IF cityController(2) > 29 THEN victoryPoints(2) = victoryPoints(2) + 50: IF cityController(2) > 34 THEN victoryPoints(2) = victoryPoints(1) + 100
	IF currentSide = 1 AND cityController(2) < 11 THEN aggress! = aggress! + .7
	IF humanPlayers = 2 THEN CALL clrbot: COLOR 14: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
END SUB

'============================================================================
'                GENmenu 3.05 : Generic Menu Main Module Level  12/91
'                Updated to Use Graphic Screens 8, 9, 12
'============================================================================
'       tlx  = top left x  (if zero, automatically centered)
'       tly = top left y   (if zero, automatically centered)
'       menuRows = # rows (current maximum=20)
'       menuText$() = text for menu
'                menuText$(0) = heading (blank defaults to M E N U)
'                menuText$(1-size) are options
'       chosenOption = option selected (row #)
'            -1 indicates ESC key pressed
'            entering with chosenOption+21 causes chosenOption to be default entry
'       windowType = window type (0 = no line; 1=single line;
'                            2=double line
'               if >10 then 10's digit=box color  1's digit= window type

SUB GenericMenu (b1%, wide%)
	boxc = colour: IF windowType > 10 THEN boxc = INT(windowType / 10): windowType = windowType - 10 * boxc
	COLOR boxc
	VIEW (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 7, 16 * (tly + menuRows + 2) + 8)
	CLS 1
	VIEW
	LINE (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 7, 16 * (tly + menuRows + 2) + 8), colour, B
	LINE (8 * tlx - 2, 16 * (tly + 1) + 3)-(8 * (tlx + wide + 1) + 3, 16 * (tly + 1) + 6), colour, B
	IF ABS(windowType) = 2 THEN
	LINE (8 * tlx - 2, 16 * tly - 8)-(8 * (tlx + wide + 1) + 3, 16 * (tly + menuRows + 2) + 4), colour, B
	END IF
	COLOR colour

	LOCATE tly + 1, tlx + b1: PRINT menuText$(0)
	FOR i = 1 TO menuRows
	LOCATE tly + 2 + i, tlx + 2: PRINT menuText$(i);
	NEXT i
END SUB

SUB ShowMenu (switch%)
		IF colour = 0 THEN colour = 7
		LOCATE 1, 1, 0
		IF menuText$(0) = "" THEN menuText$(0) = "M E N U"

		IF wide = 0 THEN CALL MenuMaxWidth(wide)
		IF tlx = 0 THEN GOSUB noadjust
		IF chosenOption < 21 THEN chosenOption = 1
		IF chosenOption > 21 THEN chosenOption = chosenOption - 21
		IF chosenOption > 21 THEN chosenOption = 1
		row = chosenOption: IF row < 1 THEN row = 1
		IF row > menuRows THEN row = 1
		chosenOption = row
		row1 = row
		
		IF tly = 0 THEN tly = INT(11.5 - .5 * menuRows)
		IF tly + menuRows > 26 THEN tly = 26 - menuRows
		
		brx = tlx + wide + 1
		bry = tly + menuRows + 3
		
		boxc = colour: IF windowType > 10 THEN boxc = INT(windowType / 10): windowType = windowType - 10 * boxc

		COLOR boxc

		VIEW (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 7, 16 * (tly + menuRows + 2) + 8)
		CLS 1
		VIEW
		LINE (8 * tlx - 6, 16 * tly - 11)-(8 * (tlx + wide + 1) + 7, 16 * (tly + menuRows + 2) + 8), colour, B
		LINE (8 * tlx - 2, 16 * (tly + 1) + 3)-(8 * (tlx + wide + 1) + 3, 16 * (tly + 1) + 6), colour, B
		IF ABS(windowType) = 2 THEN
			LINE (8 * tlx - 2, 16 * tly - 8)-(8 * (tlx + wide + 1) + 3, 16 * (tly + menuRows + 2) + 4), colour, B
		END IF

		COLOR colour
		b1 = INT(.5 * (wide - LEN(menuText$(0))) + .5) + 1

		CALL GenericMenu(b1, wide)
	sel1:
		SELECT CASE switch
			CASE 1: CALL MoveUnitIcon(array(row), 0, 7)
			CASE 2: CALL MoveUnitIcon(array(row), 0, 9)
				target = isOccupied(array(row))
				IF target > 0 THEN
				flag = 1
				anotherString$ = armyName$(target)
				IF LEN(anotherString$) > wide THEN anotherString$ = LEFT$(anotherString$, wide)
				COLOR 12
				LOCATE tly + 2 + row, tlx + 2: PRINT SPACE$(wide);
				LOCATE tly + 2 + row, tlx + 2: PRINT anotherString$;
				LOCATE tly + 4 + menuRows, tlx + 1: PRINT SPACE$(12);
				LOCATE tly + 4 + menuRows, tlx + 1: PRINT "Size"; armySize(target);
				x = POS(0): y = CSRLIN: LOCATE y, x - 1: PRINT "00";
				ELSE
				flag = 0
				LOCATE tly + 4 + menuRows, tlx + 1: PRINT SPACE$(12);
				END IF
			CASE 4: CALL ShowArmyStats(array(row))
			CASE 5: COLOR 11: CALL clrbot: PRINT armyName$(index); "  Exp="; armyExp(index); " Cash="; currentCash(currentSide);
			CASE 6: CALL MoveUnitIcon(armyLocation(array(row)), 0, 9)
			CASE 8
				IF graphicLevel > 2 AND row > 0 THEN
					LINE (548, 148)-(592, 216), 15, B
					a = row: IF currentSide = 1 THEN a = 6 - row
					anotherString$ = "face" + LTRIM$(STR$(a)) + ".vga"
					IF _FILEEXISTS(anotherString$) THEN
						DEF SEG = VARSEG(facesImage(1))
						BLOAD anotherString$, VARPTR(facesImage(1))
						DEF SEG
						PUT (550, 150), facesImage, PSET
						IF currentSide = 2 THEN
							PAINT (560, 160), 8, 0
							PAINT (570, 155), 7, 0
						END IF
					END IF
				END IF
			CASE 9: CALL MoveUnitIcon(array(row), 0, 9)
		END SELECT
		IF flag = 0 THEN
			COLOR highlight
			LOCATE tly + 2 + row, tlx + 2
			PRINT menuText$(row)
			IF borderWidth > 0 THEN LINE (8 * (tlx + 1), 16 * (tly + row + 1))-(8 * (tlx + LEN(menuText$(row)) + 1) - 1, 16 * (tly + row + 2) - 1), highlight, B
		END IF
		GOSUB crsr
		IF switch <> 3 GOTO reglr
		IF someString$ = "H" THEN chosenOption = 1: GOTO called
		IF ASC(someString$) = 13 THEN chosenOption = 2: GOTO called
		IF someString$ = "P" THEN chosenOption = 3: GOTO called
	reglr:
		IF ASC(someString$) = 13 GOTO called
		IF switch = 2 THEN LOCATE tly + 2 + row1, tlx + 2: PRINT SPACE$(wide);
		COLOR colour
		LOCATE tly + 2 + row1, tlx + 2: PRINT menuText$(row1)

		SELECT CASE switch
			CASE 1, 2, 9
				IF menuText$(row1) <> "EXIT" THEN CALL MoveUnitIcon(array(row1), 0, 8)
			CASE 6
				IF menuText$(row1) <> "EXIT" THEN CALL MoveUnitIcon(armyLocation(array(row1)), 0, 8)
		END SELECT

		chosenOption = row
		GOTO sel1
	crsr:   someString$ = INKEY$: IF someString$ = "" GOTO crsr
		IF ASC(someString$) = 13 THEN RETURN
		IF LEN(someString$) = 2 GOTO arrows
		IF switch = 3 THEN chosenOption = -ASC(UCASE$(someString$)): GOTO called
		IF ASC(someString$) = 27 THEN chosenOption = -1: GOTO called
			row1 = row
			FOR k = 1 TO menuRows
			c1$ = UCASE$(LEFT$(LTRIM$(menuText$(k)), 1))
			IF c1$ = UCASE$(someString$) THEN chosenOption = k: GOSUB limits: GOTO called
			NEXT k
		GOTO crsr
	arrows:
		someString$ = RIGHT$(someString$, 1)
		row1 = row
		IF someString$ = "H" THEN row = row - 1: GOSUB limits: RETURN
		IF someString$ = "I" THEN row = 1: GOSUB limits: RETURN
		IF someString$ = "P" THEN row = row + 1: GOSUB limits: RETURN
		IF someString$ = "Q" THEN row = menuRows: GOSUB limits: RETURN
		IF someString$ = ";" AND switch = 0 THEN
			SCREEN 0: CLS
			SHELL "cwsdoc.com"
			SCREEN 12: CALL DrawMap
			CALL GenericMenu(b1, wide)
			CALL DrawTopBar
			RETURN
		END IF
		IF someString$ = "=" AND switch = 0 THEN
			CLS
			CALL DrawMap
			CALL GenericMenu(b1, wide)
			CALL DrawTopBar
			RETURN
		END IF
		IF someString$ = "A" AND switch = 0 THEN
			chosenOption = 99
			GOTO called
			RETURN
		END IF
		IF someString$ = ">" AND switch = 0 THEN
			CALL ShowReports(-1)
			CALL GenericMenu(b1, wide)
			CALL DrawTopBar
			RETURN
		END IF
		RETURN

	limits:
		IF row > menuRows THEN row = 1
		IF row < 1 THEN row = menuRows
		RETURN
	noadjust:
		IF tlx = 0 THEN tlx = INT(40.5 - .5 * wide)
		RETURN
	called:
		IF soundEffects > 0 THEN SOUND 700, .5
		COLOR colour
		tlx = 0: tly = 0
		SELECT CASE switch
		CASE 1, 2, 9
			CALL MoveUnitIcon(array(row), 0, 8)
		CASE 6
			CALL MoveUnitIcon(armyLocation(array(row)), 0, 8)
		END SELECT
		VIEW
END SUB

SUB MenuMaxWidth (wide%)
	wide = LEN(menuText$(0)) + 1
	FOR i = 1 TO menuRows
	x = LEN(menuText$(i))
	IF x > wide THEN wide = x
	NEXT i
END SUB

SUB armyxy (x%, y%, z%)
	LINE (x - 5, y - 3)-(x + 10, y + 8), 0, BF
	SELECT CASE z
		CASE 1
		LINE (x - 7, y - 5)-(x + 7, y + 5), 4, BF
		LINE (x - 7, y - 5)-(x - 1, y), 1, BF
		LINE (x, y - 2)-(x + 7, y - 1), 7, B
		LINE (x - 7, y + 2)-(x + 7, y + 3), 7, B
		LINE (x - 8, y - 6)-(x + 8, y + 6), 0, B
		CASE 2
		LINE (x - 7, y - 5)-(x + 7, y + 5), 4, BF
		LINE (x - 8, y - 6)-(x + 8, y + 6), 0, B
		LINE (x - 7, y - 4)-(x + 6, y + 5), 9
		LINE (x - 7, y + 4)-(x + 6, y - 5), 9
		LINE (x - 7, y - 5)-(x + 7, y + 5), 9
		LINE (x - 7, y + 5)-(x + 7, y - 5), 9
		CASE ELSE
	END SELECT
END SUB

SUB SortArmyMoves (limit%)
	DO
		swaps% = FALSE
		FOR i = 1 TO limit - 1
		IF orderOfMoves(i) > orderOfMoves(i + 1) THEN
			SWAP orderOfMoves(i), orderOfMoves(i + 1)
			swaps% = i
		END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB bubble (limit%)
	DO
		swaps% = FALSE
		FOR i = 1 TO limit - 1
		IF menuText$(i) > menuText$(i + 1) THEN
			SWAP menuText$(i), menuText$(i + 1)
			SWAP array(i), array(i + 1)
			swaps% = i
		END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB CancelArmyMovement (currentSide%)
	CALL StartToFinish(start, fin, (currentSide))

	CALL clrrite
		menuRows = 0
		FOR j = start TO fin
		someString$ = armyName$(j): IF LEN(someString$) > 10 THEN x = INSTR(someString$, " "): someString$ = RIGHT$(someString$, LEN(someString$) - x)
		IF armyLocation(j) > 0 AND armyMove(j) > 0 THEN menuRows = menuRows + 1: menuText$(menuRows) = someString$: array(menuRows) = armyLocation(j)
		NEXT j
		CALL bubble(menuRows)
		tlx = 67: tly = 2: windowType = 2
		menuText$(0) = "Cancel"
		IF menuRows < 1 THEN CALL clrbot: COLOR 11: PRINT "No units have orders to cancel"; : EXIT SUB
		CALL ShowMenu(1)
		SELECT CASE chosenOption
		CASE 1 TO menuRows
			target = array(chosenOption)
			
			FOR i = start TO fin
			IF armyLocation(i) = target THEN x = INSTR(armyName$(i), menuText$(chosenOption)): IF x > 0 AND armyMove(i) > 0 THEN index = i
			NEXT i

			CALL clrbot: COLOR 11: PRINT armyName$(index); " has cancelled move to "; cityName$(armyMove(index)); : CALL TICK(turbo + 1)
			CALL MoveUnitIcon(armyLocation(index), armyMove(index), 4)
			armyMove(index) = 0: IF soundEffects > 0 THEN SOUND 2999, .5
			CALL stax(currentSide)
		CASE ELSE
			GOTO finix
		END SELECT
	finix:
		CALL clrrite
END SUB

SUB center (y%, someString$)
	x = LEN(someString$)
	x = 26 - x \ 2
	LOCATE y, 7 + x: PRINT someString$
END SUB

SUB clrbot
	LOCATE 29, 1: PRINT SPACE$(79);
	LOCATE 29, 1
END SUB

SUB clrrite
	VIEW (528, 1)-(639, 450)
	CLS 1
	VIEW
END SUB

SUB commander (who%, empty%)
	empty = 0
	CALL StartToFinish(start, fin, who)
	FOR i = start TO fin
	IF armyLocation(i) = 0 AND leaderName$(i) <> "" THEN empty = i: EXIT SUB
	NEXT i

	'                 generic leaders if set list is exhausted
	FOR i = start TO fin
	IF armyLocation(i) = 0 THEN
		x = i
		CALL MakeRomanNumerals(x, someString$)
		empty = i
		leaderName$(i) = someString$
		leaderRating(i) = 1 + 8 * RND
		EXIT SUB
	END IF
	NEXT i
	CALL clrbot: PRINT "No more "; nationName$(who); " commanders available"; : CALL TICK(turbo!)
END SUB

SUB VictoryConditionsMet
		someString$ = STR$(ABS(victoryFlags(3)) * 2.5) + "% Cities"
		anotherString$ = STR$(ABS(victoryFlags(3)) * 2.5) + "% Total Income"
		menuText$(8) = "Time: " + monthes$(victoryFlags(1)) + STR$(ABS(victoryFlags(2)))
		menuText$(9) = RTRIM$(STR$(ABS(victoryFlags(6)))) + ":1 Force Ratio"
		COLOR 15: LOCATE 1, 1: PRINT "Press ENTER to toggle ending conditions";
		COLOR 14: PRINT "				ESC when done"
	showvictoryconditionsbox:
		FOR i = 2 TO 6: IF victoryFlags(i) > 0 THEN menuText$(i - 1) = "+ " ELSE menuText$(i - 1) = "  "
		NEXT i
		chosenOption = newChosenOption
		menuText$(0) = "Victory Conditions"
		menuText$(1) = menuText$(1) + menuText$(8)
		menuText$(2) = menuText$(2) + someString$
		menuText$(3) = menuText$(3) + anotherString$
		menuText$(4) = menuText$(4) + "Capital Captured"
		menuText$(5) = menuText$(5) + menuText$(9)
		menuText$(6) = "DONE"
		windowType = 2: colour = 3: menuRows = 6: highlight = 14
		CALL ShowMenu(0)
		newChosenOption = 21 + chosenOption
	SELECT CASE chosenOption
		CASE 1
		victoryFlags(2) = -victoryFlags(2)
		CASE 2 TO 5
		victoryFlags(chosenOption + 1) = -victoryFlags(chosenOption + 1)
		CASE ELSE
		GOTO cheer
	END SELECT
		GOTO showvictoryconditionsbox
	cheer:
		CLS
		CALL DrawMap
END SUB

SUB engine
	IF rr(1) + rr(2) = 0 THEN EXIT SUB
	LINE (5, 17)-(100, 63), 3, BF
	LINE (5, 17)-(100, 47), 0, B
	LINE (5, 47)-(100, 63), 0, B

	FOR i = 1 TO 2
	IF rr(i) = 0 GOTO notrane
	PSET (15, 25), 3: c = 9: IF i = 2 THEN c = 15: PSET (60, 25), 3
	DRAW "C0S4R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5BF4"
	x = POINT(0): y = POINT(1): PAINT (x, y), c, 0
	LOCATE 4, 6 * (i - 1) + 2: PRINT LEFT$(cityName$(armyMove(rr(i))), 5)
	notrane:
	NEXT i
END SUB

SUB evaluate (index%, x%)
	from = armyLocation(index)
	x = 200: IF aggress! > 1.5 THEN x = 80: IF aggress! > 2 THEN x = 20: IF aggress! > 3 THEN x = 5
	CALL void(from, defend): IF defend = 0 THEN x = 0
	IF aiBoldness > 1 THEN x = .5 * x

	best = armySize(index)

	FOR j = 1 TO 6: array(j) = -1
	a = matrix(from, j): IF a > 0 THEN IF isOccupied(a) > 0 THEN best = best - armySize(isOccupied(a)): y = 1
	NEXT j: best = .01 * best
	IF aiBoldness > 0 THEN best = best + 20 * aiBoldness

	CALL StartToFinish(start, fin, 3 - currentSide)

	FOR j = 1 TO 6
		y = -1: a = matrix(from, j): IF a = 0 THEN max = j - 1: GOTO alleval
		
		c = isOccupied(a)
		FOR k = start TO fin: IF armyLocation(k) > 0 THEN IF armyMove(k) = a AND c = 0 GOTO alle
		NEXT k
		
		y = best - x * fortLevel(from) - cityValue(from) + 30 * RND
		IF fortLevel(from) > 0 THEN IF index = isOccupied(from) THEN y = y - 25: IF realism > 0 THEN y = y - 50
		IF a = capitalCity(currentSide) THEN IF victoryFlags(5) > 0 THEN y = y + 200
		IF cityOwner(a) <> 3 - currentSide THEN y = y + 5 * cityValue(a) + 10 * fortLevel(a)
		IF cityOwner(a) <> currentSide GOTO ourn
		IF c = 0 THEN y = y + 10 * cityValue(a): GOTO ourn
		x1 = 1: IF fortLevel(a) = 1 THEN x1 = 2: IF fortLevel(a) = 3 THEN x1 = 3

		IF armySize(c) > 0 THEN
			odds! = armySize(index) / (x1 * armySize(c))
			IF realism > 1 THEN odds! = .8 * odds!
		ELSE
			odds! = 5
		END IF

		IF armySize(index) < 15 THEN y = y - 300: odds! = .1
		IF aiBoldness < 3 AND armySize(index) < 40 AND odds! < .8 THEN y = 0
		IF realism > 0 THEN y = y - 15
		IF odds! < .5 THEN y = y - 200
		IF aiBoldness = 0 AND RND > .9 THEN y = y + 10 * (armyCommander(index) - armyCommander(c) + armyExp(index) - armyCommander(index))
		IF armySupply(index) < 1 THEN y = y - 100
		SELECT CASE odds! + .5 * aiBoldness
			CASE IS < .3
			y = -9999
			CASE IS < .5
			y = y - 300
			CASE IS <= .8
			y = y - 20
			CASE .8 TO 1.2
			y = y - 5
			CASE 1.2 TO 1.5
			y = y + 10
			CASE ELSE
			y = y + .5 * (armySize(index) - armySize(c)) + 50 * RND
		END SELECT
	ourn:
		IF cityOwner(a) = 3 - currentSide AND c > 0 AND armyMove(c) = 0 THEN y = y - armySize(c)
		IF currentSide = 1 AND cityY(a) < cityY(from) THEN y = y + 2
		IF currentSide = 2 AND cityY(a) > cityY(from) THEN y = y + 2
	'---------------------------------------------------------------------------
		FOR k = 1 TO 6: m = matrix(a, k): IF m = 0 GOTO tally3
		IF cityOwner(m) = 0 THEN y = y + 3 * cityValue(m) + 4 * fortLevel(m)
		IF cityOwner(m) = currentSide THEN y = y + 3 * cityValue(m) + 4 * fortLevel(m)
		IF cityOwner(m) = currentSide AND c > 0 THEN
			odds! = 5 - 4 * RND
			IF armySize(c) > 0 THEN odds! = armySize(index) / armySize(c) ELSE odds! = 5
			IF odds! < 1 THEN y = y - 2
		END IF
		IF cityOwner(m) = capitalCity(currentSide) THEN y = y + 50
	tally3:
		NEXT k
	'---------------------------------------------------------------------------
		array(j) = y
	alle:
	NEXT j: max = 6
	alleval:
	x = 0: best = 0
	FOR j = 1 TO max
	IF array(j) < 0 GOTO allof
		IF array(j) > x THEN x = array(j): best = j
	allof:
	NEXT j
		IF defend > armySize(index) AND array(best) < 50 THEN best = 0
		x = best
END SUB

SUB SpecialEvents
	'==========================================================================
	'                              Special Events
	'==========================================================================
	IF realism > 0 AND currentYear = 1862 AND currentMonth < 3 THEN
		COLOR 14: CALL clrbot
		PRINT "SPECIAL DEVELOPMENT : IRONCLAD ships now available";
		IF soundEffects > 0 THEN FOR k = 1 TO 5: SOUND 140, 1: SOUND 37, 1: NEXT k
		DO WHILE INKEY$ = "": LOOP
		EXIT SUB
	END IF
	IF eventsBalance = 0 THEN EXIT SUB
	plus = difficultyLevel: IF currentSide = 1 THEN plus = 6 - difficultyLevel
	pct! = .005 * (currentYear - 1860) * plus * plus: IF pct! > .9 THEN pct! = .9
	IF RND > pct! THEN EXIT SUB

	CALL clrbot: COLOR 14: PRINT "SPECIAL EVENT...";
	who = 1: IF RND > .1 * eventsBalance THEN who = 2

	SELECT CASE who
	'----------------------------------------------------------------------------
	'                               good for South
	'----------------------------------------------------------------------------
		CASE 1
		IF currentYear = 1864 AND currentMonth = 1 THEN victoryPoints(2) = victoryPoints(2) + 50
		IF currentYear = 1865 AND currentMonth = 1 THEN victoryPoints(2) = victoryPoints(2) + 100
		IF RND > .9 THEN GOSUB riotsincity: EXIT SUB

		CALL clrbot
		IF RND > .2 OR navySize(2) > 9 GOTO mercenariesjoin
		IF navySize(2) > 0 AND navyLocation(2) <> 99 THEN empty = navyLocation(2): GOTO englandgivesships
			empty = 0
			FOR i = 1 TO 40
			IF cityOwner(i) = 2 AND matrix(i, 7) = 99 AND navyLocation(1) <> i THEN empty = i: EXIT FOR
			NEXT i
		IF empty = 0 GOTO mercenariesjoin
	englandgivesships:
		CALL scribe("England has given ships to the South", 2)
		navySize(2) = navySize(2) + 2 * plus
		IF navySize(2) > 10 THEN navySize(2) = 10
		x = navySize(2) - LEN(fleet$(2))
		fleet$(2) = fleet$(2) + STRING$(x, "W")
		navyLocation(2) = empty: CALL ships
		GOTO southeventmusic
	mercenariesjoin:
		IF RND > .1 OR cityController(2) < 30 GOTO europeloan
		someString$ = "French": IF RND > .5 THEN someString$ = "British"
		CALL scribe(someString$ + " mercenaries join " + armyName$(index) + "'s army", 2)
		armySize(index) = armySize(index) + 100 * plus
		armyExp(index) = 10: armySupply(index) = 10
		GOTO southeventmusic
	europeloan:
		IF RND > .3 OR cityController(2) < 12 GOTO cottonsales
			CALL scribe("The South has obtained a loan from Europe", 2)
			GOTO skipcottonsales
	cottonsales:
		IF RND > .5 OR cityController(2) < 12 GOTO nativeuprising
		CALL scribe("Cash from cotton sales fill the Rebel Treasury", 2)
	skipcottonsales:
		currentCash(2) = currentCash(2) + 100 * plus
		GOTO southeventmusic
	nativeuprising:
		pct! = .9
		someString$ = "Union troops diverted to fight Western Indian uprisings"
		IF RND > .5 THEN someString$ = "Union 90-day enlistees return home"
		IF currentYear = 1864 AND currentMonth > 5 THEN someString$ = "20% of Union forces take furloughs to vote in 1864 elections": pct! = .8
		CALL scribe(someString$, 2)
		FOR k = 1 TO 20
		armySize(k) = pct! * armySize(k)
		NEXT k
		GOTO southeventmusic
	'----------------------------------------------------------------------------
	riotsincity:
		IF realism = 0 THEN RETURN
		IF cityController(who) = 1 THEN EXIT SUB
		FOR k = 1 TO 99
		x = 1 + INT(40 * RND)
			IF cityO(x) <> who AND cityOwner(x) = who AND isOccupied(x) = 0 THEN
				CALL clrbot: COLOR 15
				PRINT " Riots have broken out in "; cityName$(x);
				cityOwner(x) = 0
				CALL DrawCities
				TICK turbo!
				CALL clrbot
				CALL image2(cityName$(x) + " is now NEUTRAL !", 4)
				TICK turbo!
				RETURN
			END IF
		NEXT k
		RETURN
	'----------------------------------------------------------------------------
	'                               good for Union
	'----------------------------------------------------------------------------
		CASE 2
		IF RND > .1 OR navyLocation(1) = 0 OR navySize(1) > 9 GOTO unionvolunteers
		IF RND > .95 THEN GOSUB riotsincity: EXIT SUB
		CALL scribe("Union shipworks have produced extra ships", 2)
		navySize(1) = navySize(1) + plus
		IF navySize(1) > 10 THEN navySize(1) = 10
		x = navySize(1) - LEN(fleet$(1))
		fleet$(1) = fleet$(1) + STRING$(x, "W")
		GOTO northeventmusic
	unionvolunteers:
		IF RND < .7 GOTO emancipated
		CALL scribe("Volunteer troops swell the Union ranks", 2)
		x = 0: FOR i = 1 TO 20: x = x + 1: IF x > 5 GOTO northeventmusic
		IF armySize(i) > 0 AND RND > .5 THEN armySize(i) = armySize(i) * 1.1 + plus
		NEXT i: GOTO northeventmusic
	emancipated:
		IF emancipate = 0 AND currentYear > 1862 THEN

			emancipate = 1
			CALL scribe("Abraham Lincoln announces the Emancipation Proclamation", 2)
			victoryPoints(1) = victoryPoints(1) + 100: victoryPoints(2) = victoryPoints(2) - 100
			CALL DrawMap
			GOTO northeventmusic
		END IF
		IF currentYear = 1864 AND currentMonth = 11 THEN
			CALL scribe("Lincoln has been reelected", 2)
			victoryPoints(2) = .5 * victoryPoints(2)
			GOTO northeventmusic
		END IF
		IF RND > .5 THEN
			CALL scribe("Wealthy Unionists give generously to the Federal Cause", 2)
			currentCash(1) = currentCash(1) + 100 * plus
			GOTO northeventmusic
		END IF
		IF RND > .5 AND currentYear > 1861 THEN
			CALL scribe("Rebel deserters leave the battlefield to go home", 2)
			FOR i = 21 TO 40: armySize(i) = .92 * armySize(i): NEXT i: GOTO northeventmusic
		END IF
		IF RND > .5 AND currentYear > 1861 THEN
			CALL scribe("Union soldiers now have repeating rifles", 2)
			FOR i = 1 TO 20
				IF armyExp(i) < 9 THEN armyExp(i) = armyExp(i) + 2
			NEXT i
		END IF
			CALL scribe("Secretary of War Stanton predicts the end of the Rebellion", 2)
			victoryPoints(1) = victoryPoints(1) + 10: GOTO northeventmusic
		CASE ELSE
	END SELECT

	northeventmusic:
		IF soundEffects = 2 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
		DO WHILE INKEY$ = "": LOOP: EXIT SUB
	southeventmusic:
		IF soundEffects = 2 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
		DO WHILE INKEY$ = "": LOOP
END SUB

SUB DrawFlags (who%, w%, a%)
	x = 585 + w: y = 200: IF w = 0 THEN y = 180
	IF a <> 0 THEN y = a
	SELECT CASE who
		CASE 1
		LINE (x - 17, y - 15)-(x + 17, y + 7), 4, BF
		FOR i = -13 TO 9 STEP 5
		LINE (x - 17, y + i)-(x + 17, y + i - 1), 7, B
		NEXT i
		LINE (x - 17, y - 15)-(x, y), 1, BF
		IF w = 0 THEN COLOR 9: LOCATE 10, 70: PRINT "U N I O N"
		FOR i = -16 TO -1 STEP 3
			FOR j = -14 TO -1 STEP 4: PSET (x + i, y + j), 7: NEXT j
		NEXT i
		CASE 2
		LINE (x - 17, y - 15)-(x + 17, y + 7), 4, BF
		LINE (x - 17, y - 13)-(x + 15, y + 7), 7
		LINE (x - 15, y - 15)-(x + 17, y + 5), 7

		LINE (x - 17, y + 7)-(x + 17, y - 15), 1
		LINE (x - 17, y + 6)-(x + 16, y - 15), 1
		LINE (x - 16, y + 7)-(x + 17, y - 14), 1
		LINE (x - 17, y + 5)-(x + 15, y - 15), 7
		LINE (x - 15, y + 7)-(x + 17, y - 13), 7

		LINE (x - 17, y - 15)-(x + 17, y + 7), 1
		LINE (x - 17, y - 14)-(x + 16, y + 7), 1
		LINE (x - 16, y - 15)-(x + 17, y + 6), 1
		LINE (x - 17, y - 15)-(x + 17, y + 7), 4, B

		IF w = 0 THEN COLOR 4: LOCATE 10, 70: PRINT "R E B E L"
		CASE ELSE
	END SELECT
END SUB

SUB image2 (someString$, s%)
	DIM g2(1 TO 8000)
	menuText$(1) = someString$
	tlx = 32 - LEN(someString$) \ 2
	tly = 10: menuRows = 1
	CALL MenuMaxWidth(wide)
	IF wide > 59 THEN wide = 59: someString$ = LEFT$(someString$, 59)
	x = 8 * (tlx + wide)
	y = 16 * (tly + 1)
		GET (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 15, 16 * (tly + 3) + 7), g2
		VIEW (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3) + 4)
		CLS 1
		VIEW
		LINE (8 * tlx, 16 * tly - 1)-(8 * (tlx + wide + 1) + 15, 16 * (tly + 3) + 7), 0, BF
		LINE (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3)), s, BF
		LINE (8 * tlx - 4, 16 * tly - 3)-(8 * (tlx + wide + 1) + 7, 16 * (tly + 3)), 15, B
		COLOR 14
		LOCATE tly + 2, tlx + 2: PRINT someString$
		CALL TICK(9)
		PUT (8 * tlx - 4, 16 * tly - 3), g2, PSET
END SUB

SUB CheckMapIntegrity
	CLS : COLOR 15
	x = 0: y = 0
	FOR i = 1 TO 40
	FOR j = 1 TO 6: IF matrix(i, j) = 0 GOTO done
		index = matrix(i, j)
		FOR k = 1 TO 6
		IF matrix(index, k) = i GOTO ret
		IF matrix(index, k) = 0 THEN matrix(index, k) = i: PRINT "+ Adding return route from "; cityName$(index); " to "; cityName$(i): y = y + 1: GOTO ret
		NEXT k
		x = x + 1: PRINT "Error in CITIES.GRD entry for city #"; i; cityName$(index); ": no return route to "; cityName$(i): TICK 1
	ret:
	NEXT j
	done:
	NEXT i
	IF x + y = 0 THEN PRINT "ALL MAP LINKS ARE OK": EXIT SUB
	IF y > 0 THEN PRINT "* "; y; " fixes made to provide RETURN ROUTES"
	IF x > 0 THEN PRINT "** "; x; " UNRESOLVED RETURN ROUTES"
END SUB

SUB maptext
	FOR k = 1 TO 40
		FOR j = 1 TO LEN(cityName$(k))
		a = cityX(k) + 6 * (j - 4) - 3
		x = ASC(MID$(UCASE$(cityName$(k)), j, 1)) - 64
		IF a > 527 GOTO nextc
		PSET (a, cityY(k) + 12), 10
		
		IF matrix(k, 7) < 90 THEN
			IF borderWidth = 0 THEN DRAW "S4C0" ELSE DRAW "S4C7"
		ELSE
			DRAW "C10"
		END IF
		IF x > 0 AND x < 27 THEN DRAW font$(x)
		NEXT j
	nextc:
	NEXT k
END SUB

SUB HallOfFame
	COLOR 14: LOCATE 28, 1: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
	SCREEN 0: COLOR 14, 5: CLS : COLOR 11, 0

	LOCATE 2, 7: PRINT STRING$(57, "+")
	LOCATE 9, 7: PRINT STRING$(57, "+")
	FOR i = 1 TO 6: LOCATE 2 + i, 7: PRINT "+"; SPACE$(55); "+": NEXT i

			OPEN "I", 1, "hiscore.cws"
			FOR s = 1 TO 2
			COLOR 14, 4: LOCATE 3, 30 * (s - 1) + 10: PRINT nationName$(s); " HALL of FAME"
			COLOR 15, 0: FOR i = 1 TO 5
			INPUT #1, cityName$(5 * (s - 1) + i), matrix(s, i)
			LOCATE 3 + i, 30 * (s - 1) + 8: PRINT i, cityName$(5 * (s - 1) + i), matrix(s, i)
			NEXT i: NEXT s: CLOSE #1
				
				FOR s = 1 TO 2: FOR i = 1 TO 5
				IF victoryPoints(s) < matrix(s, i) GOTO oldskor
					FOR j = 5 TO i + 1 STEP -1
					matrix(s, j) = matrix(s, j - 1)
					cityName$(5 * (s - 1) + j) = cityName$(5 * (s - 1) + j - 1)
					NEXT j

				COLOR 15, 1: IF s = 2 THEN COLOR 4, 7
				FOR k = 12 TO 14: LOCATE k, 1: PRINT SPACE$(80); : NEXT k
				LOCATE 12, 1: PRINT "Congratulations ! Score of"; victoryPoints(s)
				PRINT "New Entry into "; nationName$(s); " HALL of FAME in place "; i
				IF humanPlayers = 1 AND s <> currentSide THEN someString$ = "COMPUTER": PRINT someString$; " was "; nationName$(s); " commander": GOTO automate
	who4:
				PRINT "What is name of "; nationName$(s); " commander"; : INPUT someString$: IF someString$ = "" GOTO who4
	automate:
				cityName$(5 * (s - 1) + i) = someString$
				matrix(s, i) = victoryPoints(s): GOTO foun
	oldskor:
				NEXT i
	foun:
				NEXT s
			
			OPEN "O", 1, "hiscore.cws"
			FOR s = 1 TO 2
				FOR i = 1 TO 5
				WRITE #1, cityName$(5 * (s - 1) + i), matrix(s, i)
				NEXT i
			NEXT s: CLOSE #1: PRINT "Game Over": DO WHILE INKEY$ = "": LOOP: timesPlayed = 1
END SUB

SUB occupy (x%)
	isOccupied(x) = 0
	FOR i = 1 TO 40
	IF armyLocation(i) = x THEN isOccupied(x) = i: EXIT SUB
	NEXT i
END SUB

SUB relieve (who%)
	colour = 3: target = 0: highlight = 3
	tlx = 67: tly = 2
	CALL StartToFinish(start, fin, who)
	menuRows = 0
	FOR i = start TO fin
	IF armySize(i) > 0 AND armyLocation(i) > 0 AND armyMove(i) = 0 THEN
		menuRows = menuRows + 1
		menuText$(menuRows) = armyName$(i)
		IF LEN(menuText$(menuRows)) > 11 THEN menuText$(menuRows) = LEFT$(menuText$(menuRows), 11)
		array(menuRows) = i
	END IF
	NEXT i

	IF menuRows = 0 THEN EXIT SUB
	CALL bubble(menuRows)
	menuText$(0) = "Relieve"
	chosenOption = 31: highlight = 11
	CALL ShowMenu(6): CALL clrrite

	IF chosenOption < 1 THEN EXIT SUB
	index = array(chosenOption)
	CALL MoveUnitIcon(armyLocation(index), 0, 9)

	anotherString$ = armyName$(index)
	leaderName$(index) = anotherString$

	menuRows = 0
	FOR i = start TO fin
	IF leaderName$(i) <> "" THEN
		menuRows = menuRows + 1
		menuText$(menuRows) = leaderName$(i)
		IF LEN(menuText$(menuRows)) > 11 THEN menuText$(menuRows) = LEFT$(menuText$(menuRows), 11)
		array(menuRows) = i
	END IF
	NEXT i
	CALL bubble(menuRows)

	selectnewleader:
	menuText$(0) = "New Leader"
	tlx = 67: tly = 2
	CALL ShowMenu(0): CALL clrrite
	IF chosenOption < 1 GOTO selectnewleader
	armyMove(index) = -1
	armyCommander(index) = leaderRating(array(chosenOption))
	IF armyCommander(index) > 0 THEN armyCommander(index) = armyCommander(index) - 1
	IF armyExp(index) > 0 THEN armyExp(index) = armyExp(index) - 1
	COLOR 15: CALL clrbot: PRINT leaderName$(array(chosenOption)); " has replaced "; anotherString$; " in "; cityName$(armyLocation(index)); : TICK 9
	armyName$(index) = leaderName$(array(chosenOption))
	leaderName$(array(chosenOption)) = ""
	CALL MoveUnitIcon(armyLocation(index), 0, 8)
	CALL clrbot
END SUB

SUB ShowReports (who%)
	DIM summ(40)
	IF who = -1 GOTO forcesummary
	IF who > 100 GOTO battlereport
	menuText$(0) = "Information"
	menuText$(1) = nationName$(currentSide) + " Armies"
	menuText$(2) = nationName$(3 - currentSide) + " Armies"
	menuText$(3) = "Cities"
	menuText$(4) = "Force Summary"
	menuText$(5) = "Intelligence"
	menuText$(6) = "Battles": menuRows = 6
	IF _FILEEXISTS("cws.his") THEN menuText$(7) = "Recap": menuRows = 7
	CALL ShowMenu(0)
	SELECT CASE chosenOption
	CASE IS < 0
		CLS
		CALL DrawMap
		EXIT SUB
	CASE 2: who = 3 - currentSide
	CASE 3: GOTO cityreport
	CASE 4: GOTO forcesummary
	CASE 5: GOTO srep
	CASE 6: GOTO battlereport
	CASE 7: GOTO recap
	CASE ELSE
	END SELECT
	'..........................................................................
	'                               Army Report
	'..........................................................................
	IF chosenOption < 0 GOTO endrep
	IF chosenOption = 4 GOTO forcesummary
	CALL StartToFinish(start, fin, who)
	CLS : LOCATE 1, 1: c = 9: IF who = 2 THEN c = 15
	COLOR c
	PRINT " Report for "; nationName$(who); " Forces"; TAB(30); monthes$(currentMonth); ","; currentYear; TAB(49); : COLOR 14: PRINT " Victory Points "; victoryPoints(who);
	IF c = 15 THEN c = 7
	x = victoryPoints(who) + victoryPoints(3 - who)
	IF x = 0 THEN
		PRINT
	ELSE
		y = (victoryPoints(who) / x) * 100
		PRINT "("; y; " %)";
	END IF
	CALL armyxy(215, 8, who)
	COLOR c: PRINT cityController(who); "/ 40"; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(cityController(who) * 2.5 + .5): PRINT x; "%)";
	PRINT TAB(50); : COLOR 12: PRINT "Capital: "; cityName$(capitalCity(who))
	y = vpTotal: IF capitalCity(1) > 0 THEN y = y + 100
	IF capitalCity(2) > 0 THEN y = y + 100
	PRINT currentIncome(who); "/"; y; TAB(15); "INCOME"; TAB(40); "("; : x = (currentIncome(who) / vpTotal) * 100: PRINT x; "%)   "; : COLOR 14: PRINT "Cash:"; currentCash(who)
	COLOR 11: PRINT " #      Name             Size  Location   Ldr Exp Suply Move To"
	x = 0: FOR i = start TO fin
	COLOR c
	IF armyLocation(i) < 1 GOTO deadeye
	x = x + armySize(i)
	PRINT i; TAB(5); armyName$(i); TAB(25); : y = CSRLIN
	CALL CorrectArmySize(i): PRINT TAB(32); cityName$(armyLocation(i));
	IF who <> currentSide THEN PRINT : GOTO deadeye
	PRINT TAB(43); armyCommander(i); TAB(47); armyExp(i); TAB(52); armySupply(i);
	PRINT TAB(57); : IF armyMove(i) > -1 THEN PRINT cityName$(armyMove(i)) ELSE PRINT "Resting"
	IF fortLevel(armyLocation(i)) > 0 THEN LOCATE y, 68: PRINT "FORT +"; fortLevel(armyLocation(i))
	deadeye:
	NEXT i
	PRINT " "; STRING$(70, "+")
	PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(INT(aggress! * x))); "00 ]"
	PRINT " "; STRING$(70, "+")
	PRINT " "; nationName$(who); " NAVY has "; navySize(who); " ship(s) ";
	x = 0
	FOR k = 1 TO navySize(who)
		IF MID$(fleet$(who), k, 1) = "I" THEN x = x + 1
	NEXT k
	IF x > 0 THEN PRINT "("; x; "Ironclads) ";
	IF navyLocation(who) > 0 AND navyLocation(who) < 99 THEN PRINT "in "; cityName$(navyLocation(who)) ELSE PRINT
	IF rr(who) > 0 THEN COLOR 14: PRINT " Army #"; rr(who); armyName$(rr(who)); " on train to "; cityName$(armyMove(rr(who)));
	LINE (0, 0)-(639, 449), 15, B
	LINE (0, 62)-(639, 62), 15
	GOTO endrep
	'..........................................................................
	'                               City Report
	'..........................................................................
	cityreport:
	CLS : LOCATE 1, 1: COLOR 14
	PRINT "City Report"; TAB(20); monthes$(currentMonth); ","; currentYear: COLOR 15
	PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"
	LINE (1, 30)-(630, 30), 15
	FOR i = 1 TO 20: COLOR 4: someString$ = "neutral": IF cityOwner(i) = 1 THEN COLOR 9: someString$ = "UNION"
	IF cityOwner(i) = 2 THEN COLOR 7: someString$ = "REBEL"
	LOCATE 2 + i, 1: PRINT i; TAB(6); cityName$(i); TAB(18); someString$; TAB(29); cityValue(i)
	NEXT i

	FOR i = 21 TO 40: COLOR 4: someString$ = "neutral": IF cityOwner(i) = 1 THEN COLOR 9: someString$ = "UNION"
	IF cityOwner(i) = 2 THEN COLOR 7: someString$ = "REBEL"
	LOCATE i - 18, 41: PRINT i; TAB(46); cityName$(i); TAB(58); someString$; TAB(69); cityValue(i)
	NEXT i
	LINE (1, 360)-(630, 360), 15
	COLOR 9: LOCATE 24, 1: PRINT "Side    No. Cities   Income    Cash"
	COLOR 9: PRINT nationName$(1); TAB(12); cityController(1); TAB(23); currentIncome(1); TAB(32); currentCash(1)
	COLOR 7: PRINT nationName$(2); TAB(12); cityController(2); TAB(23); currentIncome(2); TAB(32); currentCash(2)
	COLOR 4: PRINT nationName$(0); TAB(12); 40 - cityController(1) - cityController(2)
	LINE (1, 382)-(630, 382), 15
	GOTO endrep
	'..........................................................................
	'                               Intelligence
	'..........................................................................
	srep:
	c = 9: IF currentSide = 2 THEN c = 7
	CALL DrawMap
	CALL StartToFinish(start, fin, currentSide)
	FOR k = start TO fin
		IF armySize(k) > 0 THEN
		COLOR c
		x = cityX(armyLocation(k))
		y = cityY(armyLocation(k))
		z = 10: IF armySize(k) < 1000 THEN z = 9
		x = x / 8 - 2: y = y / 16
		IF y > 26 THEN y = 26
		FOR j = 0 TO 3
		LOCATE y + j, x: PRINT SPACE$(z);
		NEXT j
		LOCATE y, x: PRINT "Siz:"; : CALL CorrectArmySize(k)
		LOCATE y + 1, x: PRINT "Ldr:"; armyCommander(k)
		LOCATE y + 2, x: PRINT "Xpr:"; armyExp(k)
		LOCATE y + 3, x: PRINT "Sup:"; armySupply(k);
		LINE (8 * (x - 1) - 1, 16 * (y - 1) - 1)-(8 * (x + z - 1) + 1, 16 * (y + 3) + 1), 15, B
		TICK 1
	END IF
	NEXT k
	GOTO endrep
	'..........................................................................
	'                               Force Summary
	'..........................................................................
	forcesummary:
	FOR k = 1 TO 40
		IF isOccupied(k) > 0 THEN
			FOR j = 1 TO 40
			IF armyLocation(j) = k THEN summ(k) = summ(k) + armySize(j)
			NEXT j
		END IF
	NEXT k

	CLS : CALL DrawMap
	FOR k = 1 TO 40
	IF summ(k) > 0 THEN
		c = 9: IF cityOwner(k) = 2 THEN c = 7
		COLOR c
		LOCATE INT(cityY(k) / 16 + 1), cityX(k) / 8: PRINT summ(k)
	END IF
	NEXT k
	COLOR 14: LOCATE 1, 20: PRINT "Total Forces in Cities (100's)"
	GOTO endrep
	'..........................................................................
	'                               Battle Report
	'..........................................................................
	battlereport:
	VIEW (200, 123)-(400, 284)
	CLS 1
	VIEW
	LINE (200, 123)-(400, 284), 15, B
	COLOR 14
	LOCATE 9, 32: PRINT "BATTLE SUMMARY"
	CALL armyxy(320, 160, 1)
	CALL armyxy(370, 160, 2)
	LINE (200, 176)-(400, 230), 15, B
	LINE (200, 230)-(400, 284), 15, B
	LINE (290, 176)-(345, 284), 15, B
	LOCATE 13, 27: PRINT "BATTLES"
	LOCATE 14, 27: PRINT "WON"
	LOCATE 16, 27: PRINT "MEN LOST"
	LOCATE 17, 27: PRINT "(1000's)"
	LOCATE 14, 38: PRINT battleStats(1)
	LOCATE 14, 45: PRINT battleStats(2)
	LOCATE 17, 38: PRINT INT(.1 * casualty&(1))
	LOCATE 17, 45: PRINT INT(.1 * casualty&(2))
	IF history > 0 AND who > 2 THEN
		OPEN "O", #1, "battsumm"
		PRINT #1, " SIDE      BATTLES WON       LOSSES"
		FOR k = 1 TO 2
		someString$ = " ": IF thrill = k THEN someString$ = "*"
		PRINT #1, someString$; nationName$(k), battleStats(k), 100 * casualty&(k)
		NEXT k
		CLOSE #1
	END IF
	GOTO endrep
	'..........................................................................
	'                               Recap (History)
	'..........................................................................
	recap:
	CLS : x = 0
	OPEN "I", 2, "cws.his"
	DO WHILE NOT EOF(2)
	INPUT #2, someString$
	COLOR 7: IF INSTR(someString$, "[") THEN COLOR 15
	IF INSTR(someString$, ">") THEN COLOR 14
	IF INSTR(someString$, "..") THEN COLOR 11
	IF INSTR(someString$, "!") THEN COLOR 12
	LOCATE 29, 1: PRINT someString$
	x = x + 1
	IF x > 27 THEN TICK .4
	LOOP
	CLOSE #2

	endrep:
	COLOR 14: LOCATE 29, 29: PRINT "press a key";
	DO WHILE INKEY$ = "": LOOP
	IF who < 3 THEN
		CLS
		CALL DrawMap
	END IF
END SUB

SUB ResupplyArmy (index%)
			who = 1: IF index > 20 THEN who = 2
			IF realism > 0 THEN
				CALL cutoff(who, armyLocation(index), a)
				IF a < 1 THEN EXIT SUB
			END IF
			IF armySize(index) > 0 THEN x = currentCash(who) / armySize(index) * 10
			y = x + armySupply(index): IF y > 5 THEN x = 5 - armySupply(index)
			IF x < 1 THEN CALL clrbot: PRINT "Not enough funds in the Treasury to supply "; armyName$(index); : GOTO nocash
			armySupply(index) = armySupply(index) + x: currentCash(who) = currentCash(who) - .1 * x * armySize(index)
			CALL clrbot: PRINT armyName$(index); " has received supplies "; : IF soundEffects > 0 THEN SOUND 4500, .5
	nocash:
			CALL TICK(turbo!): IF currentCash(who) < 0 THEN currentCash(who) = 0
END SUB

SUB retreat (defend%, x%)
	x = 0
	IF humanPlayers = 1 THEN
		IF (currentSide = 1 AND defend > 20) OR (currentSide = 2 AND defend < 21) THEN EXIT SUB
	END IF

	highlight = 13: colour = 3: tlx = 67: tly = 5: menuRows = 0
	y = armyLocation(defend)
	who = 1: IF defend > 20 THEN who = 2
	FOR k = 1 TO 6
		IF matrix(y, k) > 0 AND cityOwner(matrix(y, k)) = who THEN menuRows = menuRows + 1: menuText$(menuRows) = cityName$(matrix(y, k)): array(menuRows) = matrix(y, k)
	NEXT k
		IF menuRows = 0 THEN EXIT SUB
		IF menuRows = 1 THEN x = array(1): EXIT SUB
		menuText$(0) = "Retreat"
		CALL bubble(menuRows)
		CALL ShowMenu(9)
		CALL clrrite
		IF chosenOption < 0 OR chosenOption > menuRows THEN x = 0: EXIT SUB
		x = array(chosenOption)
END SUB

SUB MakeRomanNumerals (target%, someString$)
	someString$ = "Union ": IF target > 20 THEN someString$ = "Rebel "
	IF target > 20 THEN target = target - 20
	IF target > 10 THEN someString$ = someString$ + "X": target = target - 10
	SELECT CASE target
		CASE IS < 4
		x = target: GOSUB add1s
		CASE 4
		someString$ = someString$ + "IV"
		CASE 5 TO 8
		someString$ = someString$ + "V"
		x = target - 5
		GOSUB add1s
		CASE 9
		someString$ = someString$ + "IX"
		CASE 10
		someString$ = someString$ + "X"
	END SELECT
	EXIT SUB

	add1s:
	IF x > 0 THEN FOR k = 1 TO x: someString$ = someString$ + "I": NEXT k
	RETURN

END SUB

SUB DrawRebelWin
	LINE (2, 2)-(637, 239), 4, BF
	COLOR 15: LINE (2, 40)-(597, 239): LINE -(637, 239): LINE -(637, 199): LINE -(40, 2): LINE -(2, 2): LINE -(2, 40)
	COLOR 15: LINE (2, 199)-(2, 239): LINE -(40, 239): LINE -(637, 40): LINE -(637, 2): LINE -(597, 2): LINE -(2, 199)
	LINE (242, 95)-(395, 145), 4, BF
	PAINT (4, 20), 1, 15

	LINE (2, 239)-(637, 438), 2, BF
	GOSUB stars

	'                               landscape
	PSET (1, 240)
	DRAW "s14BR68C0E6U1E3R2E4R10F2R7F2R5E3R12F7R4F2E3R5E3R9F4"
	DRAW "C0R6F2R5F1R3F3L44F2L42E1H1L29E2R1BH5BL3BR5"
	PAINT (300, 230), 5, 0
	PSET (2, 330)
	DRAW "C0D18U1R32E4R26E2R27E5R20E2R1E2U1E2U2E4H4L5H2L9H1L5H3L4H2L5H1L3H2L12H4"
	DRAW "C0D1F4R5F2R3F2R4F5R5F3L13G1L8G2L24G1L30G1L18D21"
	DRAW "BE5": x = POINT(0): y = POINT(1) + 5: PAINT (x, y), 9, 0
	DRAW "BU12C11R21F1R2BR2BD6C11R9E1R9E1R6BH7C11R9E1R9BF5C11R9E1R1E1R10"
	LINE (1, 1)-(638, 440), 14, B
	LINE (2, 2)-(637, 439), 14, B

	'                               mansion
	x = 100: y = 240
	CIRCLE (x + 50, y + 40), 80, 0, , , .2
	PAINT (x + 50, y + 40), 6, 0
	LINE (x + 95, y - 14)-(x + 102, y + 8), 8, BF
	LINE (x + 100, y - 14)-(x + 102, y + 8), 7, BF
	LINE (x, y)-(x + 100, y + 36), 7, BF
	FOR i = 1 TO 6: LINE (x + 17 * i, y + 6)-(x + 17 * i + 4, y + 32), 0, BF: NEXT i
	LINE (x + 12, y + 18)-(x + 98, y + 22), 7, BF
	LINE (x + 50, y + 20)-(x + 57, y + 36), 8, BF
	LINE (x + 100, y + 36)-(x + 105, y + 39), 7
	LINE -(x + 5, y + 39), 7: LINE -(x, y + 38), 7

	LINE (x, y)-(x - 7, y - 7), 8: LINE -(x - 14, y + 5), 8
	LINE -(x - 14, y + 33), 8: LINE -(x, y + 36), 8: LINE -(x, y), 8
	COLOR 10: LINE (x - 5, y - 7)-(x + 95, y - 7): LINE -(x + 107, y + 7)
	LINE -(x + 7, y + 7): LINE -(x - 5, y - 7)
	PAINT (x, y - 3), 10
	PAINT (x - 5, y + 15), 8

	FOR i = 1 TO 6: LINE (x + 19 * i - 12, y + 7)-(x + 19 * i - 12 + 2, y + 40), 15, BF: NEXT i

	IF soundEffects < 2 THEN EXIT SUB
	PLAY "MBMS T120"
	PLAY "O3 L16 g e L8 c c L16 c d e f L8 g g g e a a a. L16 g a8. g a b"
	PLAY "O4 L16 c d e4. c O3 g O4 c4. O3 g e g4. d e c4 P8"
	PLAY "L16 g e L8 c c L16 c d e f L8 g g g e a a a. L16 g a8. g a b"
	PLAY "O4 L16 c d e4. c O3 g O4 c4. O3 g e g4. d e c4."
	PLAY "L16 T150 g a b T120 O4 L8 c e d. c16 O3 a O4 c4 O3 a O4 d4."
	PLAY "O3 a O4 d4. O3 T150 L16 g a b T120 L8 O4 c e d. c16"
	PLAY "L8 O3 a b O4 c. O3 a16 g e O4 c. O3 e16 e d4 e c4. e d4. a"
	PLAY "L8 g e O4 c. e16 d c4 O3 e c4. e d4. a g e O4 e4. c16 d c4"

	EXIT SUB

	stars:
	FOR i = 1 TO 8
	x = starX(i): y = starY(i)
	PSET (x, y), 0
	LINE (x + 2, y - 1)-(x + 8, y + 16), 15
	LINE -(x - 6, y + 2): LINE -(x - 20, y + 16)
	LINE -(x - 14, y - 1): LINE -(x - 30, y - 9)
	LINE -(x - 12, y - 9): LINE -(x - 6, y - 25)
	LINE -(x, y - 9): LINE -(x + 16, y - 9)
	LINE -(x + 2, y - 1): PAINT (x, y), 15
	NEXT i
	RETURN
END SUB

SUB scribe (someString$, flag%)
	SELECT CASE flag
			CASE 1: CALL clrbot: PRINT someString$;
			CASE 2: CALL image2(someString$, 4)
	END SELECT
	IF history > 0 THEN
		OPEN "A", 2, "cws.his"
		someString$ = LTRIM$(RTRIM$(someString$))
		PRINT #2, someString$
		CLOSE #2
	END IF
END SUB

SUB ShenandoahSong
	'                       Shenandoah
	IF soundEffects = 2 THEN
		IF INKEY$ <> "" THEN chosenOption = 1: EXIT SUB
		PLAY "T90MFMNo1c4f8f8f4."
		IF INKEY$ <> "" THEN chosenOption = 1: EXIT SUB
		PLAY "g8a8b-8o2d8c4."
		IF INKEY$ <> "" THEN chosenOption = 1: EXIT SUB
		PLAY "MLf8e8MNd4.c8d8c8o1a8o2c4.c4d8d8d4."
		IF INKEY$ <> "" THEN chosenOption = 1: EXIT SUB
		PLAY "o1a8o2c8o1a8g8f4.g4a4.f8"
		IF INKEY$ <> "" THEN chosenOption = 1: EXIT SUB
		PLAY "a8o2d8c4.o1f8g8a4.f8g4f2."
	END IF
END SUB

SUB DrawShipIcon (who%, flag%)
		x = POINT(0) - 10: y = POINT(1) - 10
		CIRCLE (x, y), 18, 9, , , .4
		PAINT (x + 3, y + 4), 9, 9
		CIRCLE (x, y), 18, 10, , , .4
	SELECT CASE flag
	CASE 1                          'wooden ship
		DRAW "BF5R5D1C4L20C0H1R22E1L9": DRAW "BL6": DRAW "C0L10H1L1H2": DRAW "BR9D2"
		DRAW "C0U9": DRAW "BR13": DRAW "C0D9BU7R3"
		DRAW "C0L7BL5C0L7BD3BL2BD1BL1BD1C0R11BR3": DRAW "C0R10BL12"
		PSET (x + 8, y - 1)
		GOSUB jack

	CASE 2                          'ironclad
		DRAW "BL15BD4E1"
		DRAW "C0R30H1L2C8L24E1R1"
		DRAW "C8E1R18F1L19BR4C6C5C4C3C2C1": DRAW "C0R2BR3C0R2BR3C0R2"
		DRAW "BU3BL10D1": DRAW "C0U4R1D4BR9"
		PSET (x + 8, y - 1)
		GOSUB jack
	CASE ELSE
	END SELECT
	EXIT SUB
	jack:
		SELECT CASE who
		CASE 1
		DRAW "C4R7BU1C7L6BU1C1R3C4R3BU1C7L2BL1C1L3"
		CASE 2
		DRAW "C4R4U1L4U1R4U1L4C3F4BU4C3G4BD2BR2BU1"
		END SELECT
		RETURN
END SUB

SUB ships
	FOR s = 1 TO 2
	IF navySize(s) = 0 OR navyLocation(s) = 0 THEN navyLocation(s) = 0: GOTO sink
	IF navyLocation(s) = 30 THEN x = 515: y = 268: GOTO float
	IF navyLocation(s) = 28 THEN x = 517: y = 172: GOTO float
	IF navyLocation(s) = 17 THEN x = 380: y = 425: GOTO float
	IF navyLocation(s) = 99 THEN x = 495: y = 310: GOTO float
	x = cityX(navyLocation(s)) + 25: y = cityY(navyLocation(s)) + 25
	IF navyLocation(s) = 24 THEN y = y + 5: x = x - 5
	float:
		PSET (x, y), 1
		a = 1: IF LEFT$(fleet$(s), 1) = "I" THEN a = 2
		CALL DrawShipIcon(s, a)
	sink:
	NEXT s
END SUB

SUB StartToFinish (start%, fin%, who%)
	start = 1: fin = 20: IF who = 2 THEN start = 21: fin = 40
END SUB

SUB stax (who%)
	CALL StartToFinish(start, fin, who)
	FOR i = start TO fin
	IF armySize(i) > 0 AND isOccupied(armyLocation(i)) <> i THEN
		target = armyLocation(i)
		x = cityX(target) - 12: y = cityY(target) - 12
		CIRCLE (x, y), 3, 14
	END IF
	NEXT i
END SUB

SUB TICK (sec!)
	start! = TIMER
	DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP
END SUB

SUB DrawTopBar
		LOCATE 1, 1: PRINT SPACE$(80);
		COLOR 11
		LOCATE 1, 10: PRINT "Input your decisions now for "; nationName$(currentSide); " side "; : COLOR 14: PRINT monthes$(currentMonth); ","; currentYear; "  "

		CALL DrawFlags((currentSide), 0, 0)
		COLOR 4: IF borderWidth > 0 THEN COLOR 7
		LOCATE 6, 68: PRINT "Difficulty "; LTRIM$(RTRIM$(STR$(difficultyLevel)))
		LOCATE 7, 68: PRINT "Funds:"; currentCash(currentSide);

		FOR i = 1 TO 2: IF victoryPoints(i) < 0 THEN victoryPoints(i) = 0
		NEXT i
		x = victoryPoints(1) + victoryPoints(2): y = 0
		c = 9: IF currentSide = 2 THEN c = 7
		LINE (580, 15)-(580, 35), 15
		LINE (530, 20)-(630, 30), 8 - c, BF
		IF x > 0 THEN y = 100 * (victoryPoints(currentSide) / x)

		LINE (530, 20)-(530 + y, 30), c, BF
		COLOR c: LOCATE 4, 68: PRINT "VP :"; victoryPoints(currentSide)

		LOCATE 5, 68: PRINT "("; y; "%)"

	someString$ = "  Snd": IF soundEffects < 2 THEN someString$ = "   Snd": IF soundEffects = 0 THEN someString$ = "      "
	IF graphicLevel > 0 THEN someString$ = someString$ + " G" + LTRIM$(STR$(graphicLevel))
	someString$ = someString$ + STR$(humanPlayers)
	COLOR 15: LOCATE 1, 68: PRINT "F1 =  H E L P";
	COLOR c
	LOCATE 26, 68: PRINT "F3 Redrw Scrn"
	LOCATE 27, 68: PRINT "F7 End Turn"
	LOCATE 28, 68: PRINT someString$
END SUB

SUB TouchupMap

	LINE (500, 170)-(490, 165), 10 'Norfolk Coast
	LINE -(495, 160), 10
	LINE -(490, 155), 10
	LINE -(485, 150), 10

	PAINT (502, 160), 1, 10

	LINE (145, 375)-(145, 405), 10   'Mobile border

	LINE (291, 111)-(301, 101), 1
	LINE -(316, 96), 1
	LINE -(331, 76), 1
	LINE -(345, 51), 1
	LINE -(351, 30), 1
	LINE -(370, 35), 1

	LINE (381, 81)-(431, 66), 1  'Potomac River
	LINE -(456, 81), 1
	LINE -(471, 111), 1

	LINE (115, 165)-(105, 170), 1  'Paducah
	LINE -(105, 190), 1
	LINE (106, 170)-(91, 140), 1   'Missouri R

	LINE (105, 190)-(150, 190), 10
	LINE (120, 160)-(130, 200), 1  'Tenn River

	LINE (60, 295)-(65, 325), 1 'Vicksburg
	LINE -(65, 335), 1


	LINE (195, 125)-(170, 130), 1
	LINE -(165, 135), 1

	LINE (50, 375)-(60, 395), 1

	LINE (60, 395)-(105, 405), 1
	LINE -(110, 420), 1

	LINE (291, 265)-(350, 340), 1   'Savannah R.

	LINE (1, 80)-(15, 77), 1    'Missouri River
	LINE -(25, 95), 1
	LINE -(50, 98), 1
	LINE -(75, 96), 1

	LINE (71, 90)-(61, 95), 1
	LINE -(56, 85), 1

	LINE (110, 398)-(105, 398), 10
	LINE -(90, 396), 10
	LINE -(90, 400), 10
	LINE -(105, 402), 10
	LINE -(120, 415), 10
	LINE -(115, 420), 10
	PAINT (108, 400), 1, 10

	LINE (66, 375)-(52, 375), 10
END SUB

SUB traincapacity (who%, limit%)
	IF realism = 0 THEN limit = ytrainCapacity(who): EXIT SUB
	x = 11: IF currentSide = 2 THEN x = 23
	limit = ytrainCapacity(who) + 5 * (cityController(who) - x)
	x = 2 * ytrainCapacity(who)
	IF limit > x THEN limit = x
	IF limit < x \ 4 THEN limit = x \ 4
END SUB

SUB victor
		x = 0: FOR j = 1 TO 20: IF armyLocation(j) > 0 THEN x = x + armySize(j)
		NEXT j
		y = 0: FOR j = 21 TO 40: IF armyLocation(j) > 0 THEN y = y + armySize(j)
		NEXT j

		CALL clrbot: COLOR 14
		IF victoryFlags(2) > 0 AND currentYear >= victoryFlags(2) AND currentMonth < victoryFlags(1) THEN
			someString$ = "Time almost expired (" + monthes$(victoryFlags(1)) + "," + STR$(victoryFlags(2)) + ")"
			CALL image2(someString$, 4)
		END IF
		FOR i = 1 TO 2
		IF (i = 1 AND y = 0) OR (i = 2 AND x = 0) THEN j = 7: victoryPoints(i) = victoryPoints(i) + 300: GOTO finis

		IF currentYear >= victoryFlags(2) AND currentMonth >= victoryFlags(1) AND victoryFlags(2) > 0 THEN j = 2: GOTO finis
		IF cityController(i) >= victoryFlags(3) AND victoryFlags(3) > 0 THEN j = 3: GOTO finis
		IF currentIncome(i) / (currentIncome(1) + currentIncome(2)) >= .01 * victoryFlags(4) AND victoryFlags(4) > 0 THEN j = 4: GOTO finis
		IF victoryFlags(5) > 0 AND capitalCity(3 - i) = 0 AND capitalCity(i) > 0 THEN j = 5: GOTO finis

		IF victoryFlags(6) > 0 THEN
			IF i = 1 THEN
				IF y = 0 THEN j = 7: GOTO finis
				IF x / y > victoryFlags(6) THEN j = 6: GOTO finis
			END IF
			IF i = 2 THEN
				IF x = 0 THEN j = 7: GOTO finis
				IF y / x > victoryFlags(6) THEN j = 6: GOTO finis
			END IF
		END IF

		CALL clrbot: COLOR 14
		IF victoryFlags(3) > 0 AND cityController(i) >= .9 * victoryFlags(3) THEN
			someString$ = nationName$(i) + " side almost controls" + STR$(victoryFlags(3)) + " cities"
			CALL image2(someString$, 4)
		END IF

		IF victoryFlags(4) > 0 AND currentIncome(i) / (currentIncome(1) + currentIncome(2)) >= .009 * victoryFlags(4) THEN
			someString$ = nationName$(i) + " side close to" + STR$(victoryFlags(4)) + " % of total income"
			CALL image2(someString$, 4)
		END IF

		IF victoryFlags(6) > 0 AND x > 0 AND y > 0 THEN
			IF (i = 1 AND x / y > .9 * victoryFlags(6)) OR (i = 2 AND y / x > .9 * victoryFlags(6)) THEN
			someString$ = nationName$(i) + "side close to" + STR$(victoryFlags(6)) + ":1 strength ratio"
			CALL image2(someString$, 4)
			END IF
		END IF
		GOTO stale

	finis:
		SELECT CASE j
			CASE IS < 3
			someString$ = "TIME EXPIRED"
			CASE 3
			someString$ = STR$(2.5 * victoryFlags(3)) + "% CITIES CONTROLLED"
			CASE 4
			someString$ = STR$(victoryFlags(4)) + " % OF TOTAL INCOME"
			CASE 5
			someString$ = "CAPITAL CAPTURED"
			CASE 6
			someString$ = STR$(victoryFlags(6)) + ":1 ARMY STRENGTH RATIO"
			CASE 7
			someString$ = "ENEMY ANNIHILATED"
	END SELECT
		CLS
		c = 1: IF i = 2 THEN c = 7
		LINE (0, 0)-(639, 479), 4, BF
		LINE (0, 40)-(550, 460), 0, BF
		CALL DrawMap
		LINE (70, 140)-(485, 265), 0, BF
		LINE (50, 120)-(465, 250), c, BF
		LINE (50, 120)-(465, 250), 4, B
		COLOR 14
		anotherString$ = nationName$(i) + " SIDE IS WINNING"
		IF j = 2 THEN CALL center(10, "Confederates will win a technical victory") ELSE CALL center(10, anotherString$)

		COLOR 15
		anotherString$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"
		CALL center(12, anotherString$)
		CALL center(14, someString$)

		menuText$(0) = "End Game"
		menuText$(1) = "Yes"
		menuText$(2) = "No-Override"
		menuRows = 2: colour = 4
		tlx = 27: tly = 18
		highlight = 15
		IF j = 7 THEN menuRows = 1
		CALL ShowMenu(0)

		IF chosenOption <> 1 AND j < 7 THEN
	play4ever:
				victoryFlags(j) = victoryFlags(j) + 1
				IF j = 5 THEN victoryFlags(j) = 0
				CLS
				CALL DrawMap
				EXIT SUB
		END IF
		menuText$(0) = "Options"
		menuText$(1) = "Quit this Game"
		menuText$(2) = "Play More"
		IF humanPlayers = 1 THEN menuText$(2) = "No - Press Onward to " + cityName$(capitalCity(3 - currentSide))
		menuRows = 2: colour = 8
		tlx = 27: tly = 18
		IF j <> 7 THEN
			CALL ShowMenu(0)
			IF chosenOption <> 1 GOTO play4ever
		ELSE
			victoryPoints(i) = victoryPoints(i) + 100
		END IF

		thrill = i
		CALL DrawMap: CALL ShowReports(100 + currentSide)
		IF j = 2 THEN FOR k = 1 TO 2: victoryPoints(k) = .7 * victoryPoints(k): NEXT k: CALL DrawRebelWin: GOTO death

		IF i = 1 THEN CALL DrawUnionWin: COLOR 15: LOCATE 2, 27: anotherString$ = "UNION VICTORY  VP's=" + STR$(victoryPoints(1)): PRINT anotherString$: GOTO death
		IF i = 2 THEN CALL DrawRebelWin: COLOR 15: LOCATE 2, 27: anotherString$ = "REBEL VICTORY  VP's=" + STR$(victoryPoints(2)): PRINT anotherString$
	death:
		COLOR 14: LOCATE 4, 40 - .5 * LEN(someString$)
		IF history > 0 THEN
			CALL scribe(anotherString$, 0)
			CALL scribe(someString$, 0)
		END IF
		PRINT someString$: CALL HallOfFame
		EXIT SUB
	stale:
		NEXT i
END SUB

SUB void (a%, y%)
	y = 0
	FOR j = 1 TO 6
	x = matrix(a, j): IF x = 0 THEN EXIT SUB
	IF cityOwner(x) = currentSide AND isOccupied(x) > 0 THEN y = y + armySize(isOccupied(x))
		FOR k = 1 TO 6: m = matrix(x, k): IF m = 0 OR m = a GOTO tally4
		IF cityOwner(m) = currentSide AND isOccupied(m) > 0 THEN y = y + .1 * armySize(isOccupied(m))
	tally4:
		NEXT k
	NEXT j
END SUB

SUB AnimateCityFlash (which%)
	FOR c = 1 TO 15 STEP 2
	CIRCLE (cityX(which), cityY(which)), 4, 0
	CIRCLE (cityX(which), cityY(which)), 3, c
	PAINT (cityX(which), cityY(which)), c, c
	CALL TICK(.1)
	NEXT c
	c = 9: IF cityOwner(which) = 2 THEN c = 7
	IF cityOwner(which) = 0 THEN c = 12
	CIRCLE (cityX(which), cityY(which)), 4, 0
	CIRCLE (cityX(which), cityY(which)), 3, c
	PAINT (cityX(which), cityY(which)), c, c
END SUB

SUB AnimateMovement (index%, flag%)
	from = armyLocation(index): to2 = armyMove(index): armyLocation(index) = 0
	x = cityX(from) - 12
	y = cityY(from) - 11
	x1 = .5 * (cityX(to2) + cityX(from))
	y1 = .5 * (cityY(to2) + cityY(from))

	CALL occupy(from): IF isOccupied(from) > 0 THEN CALL DrawArmyUnit(isOccupied(from))
		
	IF flag > 0 GOTO already
		GET (x - 9, y - 7)-(x + 9, y + 6), anima
		IF isOccupied(from) = 0 THEN LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
	already:

		FOR i = 2 TO 8
		x1 = .1 * (i * cityX(to2) + (10 - i) * cityX(from))
		y1 = .1 * (i * cityY(to2) + (10 - i) * cityY(from))
		GET (x1 - 10, y1 - 10)-(x1 + 9, y1 + 9), image
		PUT (x1 - 10, y1 - 10), anima, PSET
		IF turbo! > 1 THEN CALL TICK(.1) ELSE CALL TICK(.02)
		IF soundEffects > 0 THEN SOUND 200, .1: SOUND 50, .1
		PUT (x1 - 10, y1 - 10), image, PSET
		NEXT i
		armyLocation(index) = from
END SUB

SUB DrawCityCaptured (active%, c%, s%, flag%)
	cityOwner(c) = s: CALL clrbot
	someString$ = armyName$(active) + " has captured " + cityName$(c)
	COLOR 11: PRINT armyName$(active) + " has captured " + cityName$(c);
	IF active < 21 AND soundEffects > 1 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	IF active > 20 AND soundEffects > 1 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	IF c <> capitalCity(3 - s) THEN CALL AnimateCityFlash(c)
	victoryPoints(s) = victoryPoints(s) + cityValue(c)
	IF c = capitalCity(3 - s) THEN
		victoryPoints(s) = victoryPoints(s) + 100
		victoryPoints(3 - s) = victoryPoints(3 - s) - 100
		someString$ = nationName$(3 - s) + " CAPITAL captured !"
		CALL scribe(someString$, 1)
		CALL image2(cityName$(capitalCity(3 - s)) + " has fallen!", 4)
		capitalCity(3 - s) = 0
		CALL AnimateCityFlash(c)
	END IF
	IF fortLevel(c) > 0 AND flag > 0 THEN fortLevel(c) = fortLevel(c) - 1: x = cityX(c): y = cityY(c): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF: CALL DrawCities
END SUB

SUB DrawArmySurrender (who%)
	SCREEN 12
	s = 1: c = 1: COLOR 0: w = 514
	IF who > 20 THEN c = 7: s = 2
	'               background
	LINE (w + 15, 440)-(w + 125, 16), 2, BF
	LINE (w + 15, 16)-(w + 125, 290), 3, BF
	LINE (w + 14, 16)-(w + 125, 440), c, B
	x = 77: y = 280
	CIRCLE (w + x + 10, y + 30), 30, 4, , , .1
	PAINT (w + x + 10, y + 30), 6, 4
	LINE (w + x, y + 28)-(w + x + 6, y + 28): LINE -(w + x + 6, y + 8)
	LINE -(w + x + 8, y + 8): LINE -(w + x + 8, y + 28)
	LINE -(w + x + 12, y + 28): LINE -(w + x + 12, y + 12)
	LINE -(w + x + 15, y + 12): LINE -(w + x + 15, y + 30)
	LINE -(w + x + 18, y + 30): LINE -(w + x + 18, y + 20)
	LINE -(w + x + 21, y + 21): LINE -(w + x + 21, y + 32)
	LINE -(w + x + 25, y + 32): LINE -(w + x + 25, y + 17)
	LINE -(w + x + 27, y + 17): LINE -(w + x + 25, y - 10)
	LINE -(w + x + 19, y - 14): LINE -(w + x + 15, y - 5)
	LINE -(w + x + 12, y - 12): LINE -(w + x + 8, y - 15)
	LINE -(w + x + 6, y - 15): LINE -(w + x + 6, y - 11)
	LINE -(w + x + 3, y - 14): LINE -(w + x + 2, y - 14)
	LINE -(w + x + 1, y - 10): LINE -(w + x - 3, y - 11)
	LINE -(w + x - 3, y + 15): LINE -(w + x, y + 15)
	LINE -(w + x, y - 3): LINE -(w + x + 2, y - 3)
	LINE -(w + x, y + 28)
	PAINT (w + x + 10, y), 8 - c, 0

	CIRCLE (w + x + 7, y - 10), 3, 0: PAINT (w + x + 7, y - 10), 0, 0
	CIRCLE (w + x + 20, y - 8), 3, 0: PAINT (w + x + 20, y - 8), 0, 0

	LINE (w + x + 5, y - 30)-(w + x + 6, y - 9)
	LINE (w + x + 20, y)-(w + x + 35, y + 30)
	LINE (w + x + 20, y + 1)-(w + x + 35, y + 31)
	LINE (w + x + 22, y - 31)-(w + x + 21, y - 8)
	LINE (w + x - 1, y - 28)-(w + x, y - 8)
	'                       boot
	CIRCLE (w + 37, 425), 22, 8, , , .3
	PAINT (w + 37, 430), 8, 8
	LINE (w + 26, 426)-(w + 46, 426)
	LINE -(w + 46, 423): LINE -(w + 36, 419)
	LINE -(w + 36, 397): LINE -(w + 26, 397)
	LINE -(w + 26, 426)
	PAINT (w + 27, 399), 0, 0
	'                       arm
	LINE (w + 26, 397)-(w + 25, 396): LINE -(w + 24, 374)
	LINE -(w + 25, 346): LINE (w + 25, 346)-(w + 22, 341)
	LINE -(w + 46, 341): LINE -(w + 46, 349)
	LINE -(w + 41, 365): LINE -(w + 41, 380)
	LINE -(w + 36, 398)
	PAINT (w + 30, 350), c, 0
	'                       saber
	LINE (w + 55, 288)-(w + 58, 360), 14, BF
	LINE (w + 55, 288)-(w + 55, 360), 14
	LINE (w + 56, 361)-(w + 55, 360), 14
	LINE (w + 57, 361)-(w + 58, 350), 14
	LINE (w + 58, 350)-(w + 58, 288), 14
	LINE (w + 55, 272)-(w + 62, 288), 6, B
	LINE (w + 56, 273)-(w + 61, 287), 6, B
	LINE (w + 57, 274)-(w + 60, 286), 6, B
			
	LINE (w + 54, 295)-(w + 60, 305), 12, BF
	LINE (w + 53, 294)-(w + 61, 306), 0, B
	LINE (w + 57, 303)-(w + 61, 303)
	LINE (w + 57, 298)-(w + 61, 298)
	LINE (w + 34, 310)-(w + 46, 312), c, BF
	LINE (w + 25, 380)-(w + 35, 378)
	LINE (w + 25, 365)-(w + 34, 366)
	'                       shoulder
	COLOR 0
	LINE (w + 53, 297)-(w + 31, 305): LINE -(w + 25, 270)
	LINE -(w + 18, 270): LINE -(w + 16, 275)
	LINE -(w + 21, 309): LINE -(w + 28, 316)
	LINE -(w + 52, 306): LINE -(w + 53, 298)
	PAINT (w + 20, 280), c, 0
	LINE (w + 30, 310)-(w + 32, 305): LINE -(w + 25, 307)
	LINE (w + 46, 298)-(w + 47, 275)
	LINE (w + 47, 275)-(w + 41, 269)
	LINE (w + 41, 269)-(w + 25, 269)
	PAINT (w + 45, 275), c, 0
	CIRCLE (w + 40, 275), 1, 14
	CIRCLE (w + 40, 285), 1, 14
	CIRCLE (w + 40, 295), 1, 14

	LINE (w + 21, 306)-(w + 18, 340)
	LINE (w + 18, 340)-(w + 47, 340)
	LINE (w + 46, 310)-(w + 48, 339)
	PAINT (w + 30, 330), c, 0
	LINE (w + 46, 312)-(w + 21, 316), 0, BF
	LINE (w + 25, 312)-(w + 35, 313), c, BF

	LINE (w + 30, 268)-(w + 41, 264), 12, BF
	LINE (w + 30, 263)-(w + 41, 263), 0
	LINE (w + 30, 264)-(w + 26, 260): LINE -(w + 25, 248)
	LINE -(w + 28, 243): LINE -(w + 46, 243)
	LINE -(w + 48, 245): LINE -(w + 48, 248)
	LINE -(w + 51, 254): LINE -(w + 51, 255)
	LINE -(w + 48, 256): LINE -(w + 48, 261)
	LINE -(w + 46, 263): LINE -(w + 39, 263)
	PAINT (w + 40, 250), 12, 0

	LINE (w + 16, 242)-(w + 57, 241), 0, BF
	LINE (w + 45, 240)-(w + 28, 240)
	LINE -(w + 31, 232): LINE -(w + 45, 232)
	LINE -(w + 48, 240)
	PAINT (w + 40, 235), c, 0

	LINE (w + 80, 303)-(w + 81, 200), 6, BF

	LINE (w + 48, 251)-(w + 44, 250), 0, B
	LINE (w + 29, 263)-(w + 43, 266)
	LINE -(w + 46, 266): LINE -(w + 48, 263)
	LINE -(w + 48, 260): LINE -(w + 37, 258)
	LINE -(w + 36, 255): LINE -(w + 37, 250)
	LINE -(w + 39, 246): LINE -(w + 40, 243)
	c = 0: IF s = 2 THEN c = 15: LINE (547, 263)-(558, 263), 15
	PAINT (w + 33, 250), c, 0
	PAINT (w + 42, 264), c, 0

	CALL DrawFlags(3 - s, 26, 0)
	IF who < 99 THEN CALL TICK(turbo!)
END SUB

SUB DrawArmyUnit (which%)
	who = 1: IF which > 20 THEN who = 2
	x = cityX(armyLocation(which)) - 12
	y = cityY(armyLocation(which)) - 11
	CALL armyxy(x, y, who)
	IF armySupply(which) < 1 THEN
		x = x - 3: y = y + 4
		PSET (x, y), 13: DRAW "C11S8"
		DRAW font$(19)
		DRAW "S4"
	END IF
END SUB

SUB DrawCannon
	CALL clrrite
	LINE (528, 80)-(639, 310), 3, BF
	LINE (528, 310)-(639, 435), 2, BF
	LINE (528, 405)-(639, 420), 0, BF
	PSET (580, 380), 0

	DRAW "BR15"
	x = POINT(0): y = POINT(1): CIRCLE (x, y), 25, 1, , , 1.4
	CIRCLE (x + 5, y), 29, 1, 4, 1.5, 1.4
	CIRCLE (x, y), 29, 1, , , 1.4
	DRAW "BR20"
	x = POINT(0): y = POINT(1): PAINT (x, y), 3, 1
	DRAW "BR3BU7"
	x = POINT(0): y = POINT(1): PAINT (x, y), 5, 1
	DRAW "BL15C7G4L50H1L12H1L7H3U1H1U4E5R6E1R13E1R52F3D2R1E1R1F2D5G3H2G2BL2"
	DRAW "BH2C6"
	x = POINT(0): y = POINT(1): PAINT (x, y), 7
	DRAW "BD2R4C0G4L50H1L12H1L7H3U1H1U4E5R6E1R13E1R52F3D2R1E1R1F2D5G3H2G2BR5U3"
	DRAW "C8G2H2G6L15G1L32H1L1H1L19H3E2R2F1R6"
	DRAW "E2R4F1R6E1R58F1G2BL9BH2BU5BR3C15H1L48G1L13G1L4"
	DRAW "BD3BF3BR9"
	x = POINT(0): y = POINT(1): PAINT (x, y), 8
	DRAW "BR34BE1BR7BL5BD8C6R16F5D1F4D6F7R17D7L30H18L8H4L18H3U5R33BR17BD5"
	x = POINT(0): y = POINT(1): PAINT (x, y), 6
	DRAW "BU5C8F8D7F6R1F1R16D7E3U7G3E2BE2C8L16H6U8C8G3BE3C8H8G6BR5"
	x = POINT(0): y = POINT(1): PAINT (x, y), 8
	DRAW "BL38"
	x = POINT(0): y = POINT(1): CIRCLE (x, y), 30, 4, , , 1.4
	CIRCLE (x + 5, y), 35, 4, 4, 1.5, 1.4
	CIRCLE (x, y), 35, 4, , , 1.4
	CIRCLE (x, y), 8, 4, , , 1.4: PAINT (x, y), 1, 4: PAINT (x, y), 0, 4
	DRAW "BR23"
	x = POINT(0): y = POINT(1): PAINT (x, y), 1, 4: PAINT (x, y), 4, 4
	DRAW "BR5BU7"
	x = POINT(0): y = POINT(1): PAINT (x, y), 1, 4: PAINT (x, y), 0, 4
	DRAW "BU22BL28"
	DRAW "C4D20R1U19BD37C4D20L1U21BH2BL1BH1C4G12F1E11BU3BH2"
	DRAW "BU3BL1C4L13U1R15BR1BU3C4H12E1F11BF5BE4C4E11F1G11BD3C4R13D1L10D3BL3BD1C4"
	DRAW "F12G1H12BL33BH13BU3BH2BU1BE1BR2BU1BE1BR1"
	DRAW "BL5BU5C8E4U1"
	DRAW "H4E3H3U3E3H6L3G7F1H7E2U2E2H7L7G9D6F8G3L1H3L5G7D4F4R2D3F3R2G5D4L4G4D5F8D2"
	DRAW "R5F9E3F5R6E6H4E2F6R3E8F1E4H5U2H3U1H1U7E4H7BL5"
	x = POINT(0): y = POINT(1): PAINT (x, y), 8, 8
	DRAW "BR9BD6C15H8L1H2L12G1F5L8G4F4R3G3D1G2D3F2E5G1D8R4E3D6F3E12H1U1H1U6E5BH6BU4"
	DRAW "BD15"
	x = POINT(0): y = POINT(1): PAINT (x, y), 14, 15
END SUB

SUB DrawChesapeake
	COLOR 10
	LINE (500, 185)-(505, 180): LINE -(505, 175)
	LINE -(500, 170): LINE -(490, 165)
	LINE -(495, 160): LINE -(490, 155)
	LINE -(485, 150): LINE -(495, 155)
	LINE -(495, 145): LINE -(490, 140)
	LINE -(485, 130): LINE -(470, 120)
	LINE -(470, 110): LINE -(475, 120)
	LINE -(485, 120): LINE -(485, 115)
	LINE -(480, 100): LINE -(485, 90)
	LINE -(495, 80): LINE -(500, 80)
	LINE -(500, 85): LINE -(495, 90)
	LINE -(495, 100): LINE -(495, 115)
	LINE -(500, 120): LINE -(500, 130)
	LINE -(515, 135): LINE -(515, 140)
	LINE -(510, 160): LINE -(520, 145)
	LINE -(525, 120): LINE -(525, 115)
	LINE -(515, 85): LINE -(527, 95)
	PAINT (500, 400), 1, 10
	PAINT (510, 110), 2
END SUB

SUB DrawCities
	FOR i = 1 TO 40
	c = 9: IF cityOwner(i) = 2 THEN c = 7
	IF cityOwner(i) = 0 THEN c = 12
	x = cityX(i): y = cityY(i)
	IF i = capitalCity(1) OR i = capitalCity(2) THEN
		PUT (x - 6, y - 6), northernCapital, PSET
		LINE (x + 9, y - 4)-(x + 15, y + 4), 0, BF
		LINE (x + 8, y - 5)-(x + 13, y + 2), 3, BF
		PSET (x + 8, y - 4)
		IF fortLevel(i) = 1 THEN DRAW "BR2C0e1D6BL1R2"
		IF fortLevel(i) = 2 THEN DRAW "C0e1R1F1D1G3R3"
	ELSE
		IF fortLevel(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
		IF fortLevel(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
		CIRCLE (cityX(i), cityY(i)), 4, 0
		CIRCLE (cityX(i), cityY(i)), 3, c
		PAINT (cityX(i), cityY(i)), c, c
	END IF
	IF graphicLevel = 0 GOTO nocon
		FOR j = 1 TO 6: IF matrix(i, j) > 0 THEN CALL MoveUnitIcon(i, matrix(i, j), 11)
		NEXT j
	nocon:
	NEXT i
END SUB

SUB DrawMap
	SCREEN 12
	LINE (1, 16)-(527, 440), 10, B
	PAINT (200, 200), 2, 10
	COLOR 10
	'==========================  Mountains =================================
	IF _FILEEXISTS("mtn.vga") THEN
		PUT (380, 30), mtn, PSET
		PUT (270, 200), mtn, PSET
		PUT (310, 160), mtn, PSET
		PUT (350, 120), mtn, PSET
		PUT (200, 185), mtn, PSET
		PUT (250, 130), mtn, PSET
		PUT (320, 80), mtn, PSET
		PUT (30, 150), mtn, PSET
		LINE (30, 150)-(70, 190), 2, BF
	END IF
	'===========================  Kentucky =================================
	LINE (105, 190)-(150, 190)
	LINE -(150, 185)
	LINE -(290, 185)
	LINE (276, 185)-(301, 175)
	LINE -(305, 160)
	LINE -(310, 155)
	LINE -(305, 145)
	LINE -(300, 125)
	LINE -(290, 110)

	LINE -(275, 95), 1
	LINE -(270, 95), 1
	LINE -(260, 100), 1
	LINE -(250, 100), 1
	LINE -(240, 90), 1
	LINE -(235, 85), 1
	LINE -(230, 85), 1
	LINE -(220, 90), 1
	LINE -(220, 100), 1
	LINE -(210, 105), 1
	LINE -(205, 115), 1
	LINE -(195, 125), 1
	LINE -(170, 130), 1
	LINE -(165, 135), 1
	LINE -(130, 140), 1
	LINE -(120, 150), 1
	LINE -(120, 160), 1
	LINE -(115, 165), 1
	LINE -(105, 170), 1
	LINE -(105, 190), 1
	'===========================  Tennessee =================================
	LINE (290, 185)-(320, 185)
	LINE -(320, 185)
	LINE -(315, 195)
	LINE -(302, 210)
	LINE -(290, 215)
	LINE -(275, 230)
	LINE -(260, 241)
	LINE -(260, 241)
	LINE -(70, 241)

	LINE (105, 190)-(95, 200), 1
	LINE -(80, 220), 1
	LINE -(70, 241), 1
	'===========================  Mississippi =================================
	LINE (143, 241)-(145, 405)
	LINE -(135, 400)
	LINE -(125, 400)
	LINE -(115, 405)
	LINE -(110, 400)
	LINE -(110, 390)
	LINE -(115, 380)
	LINE -(115, 375)
	LINE -(50, 375)
	LINE (115, 375)-(60, 375)

	LINE (70, 241)-(65, 280), 1
	LINE -(60, 295), 1
	LINE -(65, 325), 1
	LINE -(65, 335), 1
	LINE -(50, 375), 1
	'===========================  Alabama =================================
	LINE (215, 241)-(232, 375)
	LINE (176, 395)-(181, 410)
	LINE -(166, 415)
	LINE -(161, 400)
	LINE -(156, 405)
	LINE -(146, 405)
	LINE (176, 395)-(176, 385)
	LINE -(231, 385)
	'===========================  Georgia & Florida ============================
	LINE (261, 241)-(296, 241)
	LINE -(291, 265)
	LINE -(350, 340)
	LINE -(336, 390)
	LINE -(366, 440)
	LINE (336, 385)-(325, 385)   'Fla /Ga Border
	LINE -(320, 388)
	LINE -(245, 388)
	LINE -(230, 385)
	LINE (180, 410)-(195, 410)
	LINE -(215, 415)
	LINE -(225, 425)
	LINE -(255, 420)
	LINE -(265, 420)
	LINE -(270, 425)
	LINE -(275, 440)
	LINE (347, 409)-(343, 409)
	LINE -(343, 431)
	LINE -(346, 431)
	LINE -(346, 412)
	LINE -(349, 412)
	LINE (347, 411)-(350, 411), 1

	LINE (353, 333)-(358, 336), 10, B
	'===========================  South Carolina ================================
	LINE (290, 241)-(305, 240)
	LINE -(345, 240)
	LINE -(350, 250)
	LINE -(380, 250)
	LINE -(415, 280)
	LINE -(385, 315)
	LINE -(380, 320)
	LINE -(375, 325)
	LINE -(350, 330)
	LINE -(350, 340)
	'===========================  North Carolina ================================
	LINE (320, 185)-(500, 185)
	LINE -(505, 190)
	LINE -(490, 195)
	LINE -(490, 205)
	LINE -(505, 205)
	LINE -(500, 215)
	LINE -(485, 220)
	LINE -(490, 225)
	LINE -(500, 225)
	LINE -(500, 230)
	LINE -(490, 235)
	LINE -(488, 240)
	LINE -(480, 241)
	LINE -(460, 250)
	LINE -(455, 255)
	LINE -(440, 265)
	LINE -(439, 270)
	LINE -(425, 278)
	LINE -(415, 280)
	LINE (510, 190)-(513, 200), , B
	LINE (510, 206)-(510, 226)
	LINE -(500, 236)
	LINE -(502, 241)
	LINE -(512, 228)
	LINE -(512, 208)
	LINE -(510, 206)

	'=========================== Chesapeake ====================================
	CALL DrawChesapeake
	'=============== Ohio, Pennslyvania, Maryland, Virginia =====================
	LINE (291, 111)-(301, 101), 1
	LINE -(316, 96), 1
	LINE -(331, 76), 1
	LINE -(345, 51), 1
	LINE -(351, 30), 1
	LINE -(370, 35), 1

	LINE (351, 16)-(351, 54)
	LINE -(527, 54)
	LINE (381, 54)-(381, 81)
	LINE -(431, 66)
	LINE -(456, 81)
	LINE -(471, 111)
	LINE (226, 85)-(226, 16)
	'=============== Louisiana, Arkansas, Missouri =============================
	LINE (50, 375)-(60, 395), 1
	LINE -(105, 405), 1
	LINE -(110, 420), 1
	LINE -(125, 438), 1
	LINE (110, 398)-(105, 398)

	LINE -(90, 396)
	LINE -(90, 400)


	LINE -(105, 402)
	LINE -(120, 415)
	LINE -(115, 420)
	LINE -(125, 435)
	LINE -(120, 440)
	LINE -(110, 425)
	LINE -(100, 435)
	LINE -(90, 440)
	LINE -(50, 430)
	LINE -(25, 435)
	LINE -(1, 435)
	'----------------------------------
	PAINT (250, 430), 1, 10
	PAINT (110, 439), 1, 10
	PAINT (50, 439), 1, 10
	'----------------------------------
	LINE (1, 300)-(61, 300)       'Ark
	LINE (91, 205)-(71, 205)
	LINE -(76, 190)
	LINE -(71, 185)
	LINE -(1, 185)

	LINE (106, 170)-(91, 140), 1    'Missouri
	LINE -(71, 120), 1
	LINE -(76, 110), 1
	LINE -(76, 95), 1
	LINE -(71, 90), 1
	LINE -(61, 95), 1
	LINE -(56, 85), 1
	LINE -(50, 35), 1
	LINE -(46, 20), 1

	LINE -(38, 16)

	LINE (46, 20)-(61, 17), 1        'Illinois

	LINE (150, 17)-(150, 110)
	LINE -(147, 125), 1
	LINE -(140, 138), 1
	'========================== Rivers =========================================

	LINE (1, 80)-(15, 77), 1    'Missouri River
	LINE -(25, 95), 1
	LINE -(50, 98), 1
	LINE -(75, 96), 1

	LINE (120, 160)-(130, 200), 1  'Tenn River
	LINE -(135, 240), 1
	LINE -(130, 247), 1
	LINE -(160, 250), 1
	LINE -(200, 260), 1
	LINE -(240, 244), 1
	LINE -(245, 240), 1
	LINE -(270, 200), 1

	LINE (120, 160)-(140, 200), 1  'Cumberland River
	LINE -(160, 210), 1
	LINE -(200, 208), 1
	LINE -(240, 170), 1

	LINE (161, 400)-(155, 320), 1  'Tombigbee River
	LINE -(145, 300), 1

	LINE (161, 400)-(170, 370), 1  'Alabama River
	LINE -(200, 350), 1

	LINE (230, 425)-(231, 385), 1  'Chattahoochee River
	LINE -(233, 350), 1
	LINE -(240, 330), 1
	LINE -(270, 290), 1

	LINE (381, 81)-(431, 66), 1   'Potomac River
	LINE -(456, 81), 1
	LINE -(471, 111), 1

	LINE (485, 150)-(455, 145), 1   'James River
	LINE -(400, 150), 1

	LINE (489, 200)-(415, 185), 1   'Roanoke River
	LINE -(400, 160), 1

	LINE (296, 241)-(291, 265), 1   'Savannah River
	LINE -(350, 340), 1

	LINE (438, 271)-(430, 235), 1  'Cape Fear River
	LINE -(420, 205), 1

	LINE (500, 80)-(498, 50), 1 'Susquehanna River
	LINE -(470, 30), 1

	LINE (405, 290)-(360, 240), 1 'Pee Dee River

	LINE (400, 300)-(350, 280), 1 'Santee River

	LINE (270, 423)-(280, 410), 1 'Suwanee River
	LINE -(290, 390), 1

	LINE (342, 370)-(300, 350), 1 'Altamaha River

	LINE (50, 370)-(1, 330), 1 'Red River

	LINE (65, 280)-(1, 240), 1 'Arkansas River

	LINE (430, 66)-(400, 100), 1 ' Shenandoah River
	LINE -(380, 120), 1

	CALL DrawCities
	PSET (493, 280), 1
	IF navyLocation(1) = 30 OR navyLocation(2) = 30 THEN
		DRAW "C11U7R4D3L3BR6BU3D7BU4R3U3D7BR3U7BD4BR4BU4D7R4"
		LINE (485, 241)-(525, 270), 11, B
	END IF

	IF graphicLevel > 1 THEN CALL maptext
	IF navalCommerce > 0 THEN
	LINE (447, 291)-(525, 317), 4, BF: LINE (447, 291)-(525, 317), 10, B
	y = 312
	someString$ = "COMMERCE"
	FOR j = 1 TO LEN(someString$): x = ASC(MID$(UCASE$(someString$), j, 1)) - 64
	PSET (440 + 10 * j, y), 0: DRAW font$(x)
	NEXT j
	ELSE
	LINE (447, 291)-(525, 335), 1, BF
	END IF

	FOR i = 1 TO 40
	IF armyLocation(i) > 0 THEN CALL DrawArmyUnit(i)
	NEXT i

	FOR k = 1 TO 2
	CALL stax(k)
	NEXT k

	IF humanPlayers = 2 GOTO nosee
	FOR i = 1 TO 40: IF armyLocation(i) > 0 AND armyMove(i) > 0 THEN CALL MoveUnitIcon(armyLocation(i), armyMove(i), 1)
	NEXT i
	nosee:
	CALL ships
	CALL engine
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(monthes$(currentMonth), 3)); ","; currentYear
END SUB

SUB DrawIronclad
	SCREEN 12
	LINE (1, 240)-(639, 309), 3, BF
	LINE (639, 309)-(1, 479), 1, BF

	COLOR 7
	LINE (478, 368)-(174, 389): LINE -(86, 363): LINE -(78, 353)
	LINE -(161, 337): LINE -(162, 337): LINE -(406, 326): LINE -(478, 368)
	PAINT (300, 350), 7

	COLOR 15
	LINE (427, 358)-(203, 373): LINE -(247, 322): LINE -(205, 312)
	LINE -(167, 342): LINE -(203, 373): LINE -(246, 323): LINE -(401, 318)
	LINE -(427, 358): LINE -(400, 318): LINE -(363, 306): LINE -(204, 312)
	PAINT (300, 315), 7, 15
	PAINT (200, 325), 8, 15
	PAINT (300, 325), 8, 15

	COLOR 7
	LINE (77, 353)-(76, 363): LINE -(84, 370): LINE -(85, 363)
	LINE -(84, 369): LINE -(169, 396): LINE -(170, 389): LINE -(168, 396)
	LINE -(477, 375): LINE -(478, 369)
	PAINT (80, 363), 7
	PAINT (150, 385), 8, 7
	PAINT (190, 390), 0, 7

	COLOR 0
	LINE (299, 261)-(294, 254): LINE -(303, 250): LINE -(299, 243)
	LINE -(316, 243): LINE -(321, 247): LINE -(326, 241): LINE -(335, 240)
	LINE -(345, 240): LINE -(357, 246): LINE -(366, 241): LINE -(381, 245)
	LINE -(384, 253): LINE -(398, 248): LINE -(410, 248): LINE -(413, 259)
	LINE -(424, 264): LINE -(425, 254): LINE -(444, 258): LINE -(445, 270)
	LINE -(436, 277): LINE -(426, 281): LINE -(418, 270): LINE -(411, 272)
	LINE -(400, 263): LINE -(392, 275): LINE -(374, 270): LINE -(370, 262)
	LINE -(357, 257): LINE -(345, 256): LINE -(335, 257): LINE -(335, 262)
	LINE -(324, 257): LINE -(317, 258): LINE -(309, 257): LINE -(305, 262)
	LINE -(300, 261)
	PAINT (320, 250), 0

	LINE (211, 341)-(196, 357): LINE -(179, 346)
	LINE -(194, 335): LINE -(211, 341)
	PAINT (190, 350), 0
	LINE (211, 341)-(225, 330), 7: LINE -(209, 324), 7: LINE -(188, 340), 0

	FOR k = 0 TO 3
	x = 260 + 40 * k: y = 344 - 2 * k
	LINE (x, y)-(x + 2, y + 20): LINE -(x + 17, y + 19): LINE -(x + 15, y)
	LINE -(x, y)
	PAINT (x + 10, 350), 0
	LINE (x, y)-(x + 15, y), 7: LINE -(x + 13, y - 14), 7: LINE -(x - 2, y - 14), 7: LINE -(x, y)
	NEXT k

	COLOR 8
	LINE (168, 340)-(85, 355): LINE -(91, 361): LINE -(173, 386): LINE -(466, 366)
	LINE -(414, 334)

	LINE (358, 307)-(382, 315): LINE -(249, 320): LINE -(220, 314)
	LINE -(358, 307)

	LINE (314, 255)-(330, 314), 8, BF
	LINE (297, 310)-(309, 262), 8, BF
	LINE (323, 257)-(329, 314), 0, BF
	LINE (303, 310)-(308, 262), 0, BF
	LINE (319, 257)-(320, 315), 15, BF
	LINE (300, 262)-(301, 312), 15, BF

	LINE (96, 297)-(94, 357), 8, BF
	LINE (98, 299)-(106, 317), 4, BF
	LINE (107, 304)-(110, 319), 9, BF
	LINE (111, 300)-(114, 312), 15, BF

	y = 387: FOR x = 180 TO 470 STEP 15: y = y - 1: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	y = 360: FOR x = 90 TO 170 STEP 15: y = y + 4: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	y = 373: FOR x = 216 TO 250 STEP 7: y = y - 8: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	y = 373: FOR x = 205 TO 243 STEP 7: y = y - 8: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	y = 350: FOR x = 172 TO 200 STEP 9: y = y - 8: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	y = 310: FOR x = 397 TO 425 STEP 8: y = y + 11: LINE (x, y)-(x + 1, y + 1), 0, BF: NEXT x
	COLOR 11
	LINE (70, 361)-(68, 369): LINE -(106, 384): LINE -(166, 394)
	LINE -(210, 385): LINE -(255, 391): LINE -(219, 394)
	LINE -(242, 402): LINE -(202, 405): LINE -(162, 402)
	LINE -(121, 387)
	PAINT (190, 400), 3, 11

	LINE (331, 391)-(365, 387)
	LINE -(403, 375): LINE -(446, 382): LINE -(471, 384)
	LINE -(446, 391): LINE -(478, 395): LINE -(449, 407)
	LINE -(445, 406): LINE -(414, 395): LINE -(412, 395)
	LINE -(369, 396): LINE -(323, 391)
	PAINT (390, 390), 3, 11

	LINE (476, 379)-(531, 372)
	LINE (420, 329)-(497, 327), 3
	LINE -(464, 340): LINE -(535, 343), 3
	LINE (141, 337)-(67, 349): LINE -(58, 372)

	LINE (525, 405)-(587, 392): LINE -(628, 402): LINE -(588, 415)
	LINE -(563, 409): LINE -(562, 409): LINE -(527, 423)
	LINE -(540, 410): LINE -(523, 406)
	PAINT (560, 405), 9, 11

	LINE (106, 320)-(101, 318), 0, BF
	LINE (110, 313)-(114, 315), 0, BF
END SUB

SUB DrawSchooner
	SCREEN 12
	LINE (1, 240)-(639, 309), 3, BF
	LINE (639, 309)-(1, 479), 1, BF
	COLOR 6
	LINE (243, 241)-(247, 395), , BF
	LINE (369, 395)-(373, 241), , BF
	LINE (183, 395)-(435, 400), , BF
	LINE (188, 395)-(107, 356): LINE -(106, 360): LINE -(173, 392)
	LINE -(182, 419): LINE -(191, 429): LINE -(230, 426): LINE -(275, 432)
	LINE -(314, 418): LINE -(354, 431): LINE -(390, 421): LINE -(390, 422)
	LINE -(413, 427): LINE -(437, 419): LINE -(447, 401): LINE -(447, 377)
	LINE -(401, 377): LINE -(399, 396)
	PAINT (300, 415), 6

	LINE (378, 290)-(434, 262): LINE -(432, 258): LINE -(377, 286)
	LINE -(378, 290)
	PAINT (380, 286), 6

	LINE (378, 346)-(456, 336): LINE -(457, 340): LINE -(376, 350)
	LINE -(378, 346)
	PAINT (382, 347), 6


	COLOR 15
	LINE (109, 355)-(131, 361)
	LINE -(239, 259): LINE -(239, 256): LINE -(109, 355)
	PAINT (140, 340)

	LINE (238, 268)-(256, 273)
	LINE -(241, 295): LINE -(240, 309): LINE -(250, 322)
	LINE -(226, 321): LINE -(220, 299): LINE -(227, 284)
	LINE -(239, 269)
	PAINT (245, 275), 15

	LINE (232, 327)-(225, 350): LINE -(233, 385): LINE -(251, 387)
	LINE -(242, 352): LINE -(243, 345): LINE -(249, 333)
	LINE -(232, 327)
	PAINT (235, 335), 15

	LINE (381, 268)-(368, 286)
	LINE -(366, 303): LINE -(374, 317): LINE -(350, 315)
	LINE -(347, 297): LINE -(361, 264): LINE -(381, 268)
	PAINT (365, 275), 15

	LINE (379, 335)-(360, 328)
	LINE -(351, 347): LINE -(355, 367)
	LINE -(357, 382): LINE -(378, 386): LINE -(368, 373)
	LINE -(369, 345): LINE -(379, 334)
	PAINT (360, 345), 15

	LINE (379, 290)-(406, 342): LINE -(456, 336): LINE -(435, 289)
	LINE -(433, 264): LINE -(378, 291)
	PAINT (410, 325), 15

	FOR k = 260 TO 400 STEP 25
	CIRCLE (k, 405), 3, 0
	PAINT (k, 405), 0
	NEXT k

	COLOR 11
	LINE (247, 437)-(290, 422): LINE -(314, 416): LINE -(334, 423)
	LINE -(305, 432): LINE -(287, 430): LINE -(286, 430)
	LINE -(267, 441): LINE -(225, 439): LINE -(225, 438)
	LINE -(246, 437)
	PAINT (300, 425), 3, 11

	LINE (362, 428)-(385, 419)
	LINE -(394, 421): LINE -(375, 437): LINE -(354, 432)
	LINE -(345, 429): LINE -(362, 428)
	PAINT (370, 430), 3, 11

	LINE (16, 383)-(43, 379)
	LINE -(44, 379): LINE -(78, 385): LINE -(16, 384)
	PAINT (40, 383), 9, 11

	LINE (173, 440)-(204, 431): LINE -(227, 431): LINE -(210, 439)
	LINE -(175, 441): LINE -(173, 440)
	PAINT (200, 435), 11

	LINE (445, 417)-(552, 409)
	LINE -(599, 416): LINE -(539, 415): LINE -(468, 415)
	PAINT (550, 411), 9, 11

	LINE (509, 349)-(540, 351)
	LINE -(541, 351)
	LINE -(517, 343): LINE -(509, 349)
	PAINT (520, 347), 3, 11

	LINE (577, 342)-(598, 343)
	LINE (275, 340)-(287, 342), 9

	LINE (149, 346)-(188, 345), 9
	LINE (24, 337)-(72, 338), 3

	COLOR 7
	LINE (227, 354)-(236, 383): LINE -(246, 386): LINE -(239, 356)
	LINE -(233, 357): LINE -(227, 354)
	PAINT (238, 365), 7

	LINE (223, 301)-(231, 321): LINE -(244, 321): LINE -(237, 308): LINE -(240, 303)
	LINE -(223, 301)
	PAINT (236, 312), 7

	LINE (349, 299)-(353, 313): LINE -(370, 316)
	LINE -(363, 302): LINE -(364, 303): LINE -(350, 300)
	PAINT (360, 310), 7

	LINE (356, 359)-(359, 380): LINE -(375, 385): LINE -(366, 372): LINE -(368, 364)
	LINE -(356, 360)
	PAINT (360, 370), 7

	LINE (393, 302)-(394, 302): LINE -(409, 323)
	LINE -(417, 309): LINE -(434, 325): LINE -(429, 304): LINE -(428, 291)
	LINE -(410, 296): LINE -(400, 290): LINE -(394, 302)
	PAINT (420, 300), 7

	COLOR 0
	LINE (247, 256)-(291, 394)
	LINE (247, 256)-(284, 394)
	LINE (244, 256)-(191, 394)
	LINE (244, 256)-(184, 394)

	LINE (371, 257)-(321, 394)
	LINE (371, 257)-(314, 394)
	LINE (375, 257)-(431, 378)
	LINE (375, 257)-(438, 378)

	LINE (375, 258)-(434, 259)

	COLOR 8
	LINE (180, 400)-(183, 415): LINE -(192, 426): LINE -(212, 426)
	LINE -(202, 421): LINE -(210, 414): LINE -(191, 408): LINE -(201, 402)
	LINE -(180, 400)
	PAINT (185, 410), 8

	LINE (445, 381)-(445, 400): LINE -(435, 417)
	LINE -(413, 424): LINE -(422, 413): LINE -(418, 404): LINE -(434, 401)
	LINE -(427, 393): LINE -(435, 391): LINE -(437, 384): LINE -(445, 382)
	PAINT (440, 388), 8

	LINE (186, 425)-(155, 429), 11: LINE -(146, 433), 11
	LINE (150, 417)-(116, 425), 11
	LINE (123, 452)-(153, 460), 11
	LINE (297, 463)-(319, 468), 11

	FOR k = 1 TO 4
	x = 185 + 200 * RND
	LINE (x, 390)-(x + 2, 392), 12, BF: LINE (x - 2, 392)-(x + 4, 394), 8, BF
	NEXT k
END SUB

SUB DrawUnionWin
	SCREEN 12
	CLS
	LINE (1, 1)-(639, 150), 4, BF
	LINE (1, 150)-(639, 300), 15, BF
	LINE (1, 300)-(639, 450), 1, BF
	x = 0
	LINE (150, 190)-(500, 254), 7, B
	LINE (270, 190)-(370, 254), 7, B
	LINE (270, 185)-(370, 175), 7, B
	LINE (280, 173)-(360, 168), 7, B
	LINE (270, 235)-(370, 254), 7, B
	CIRCLE (320, 150), 74, 7, .2, 2.95, 2.1
	LINE (285, 138)-(355, 168), 7, B
	lwing:
	PSET (180 + 120 * x, 200), 0

	DRAW "C7ER1E1R1E1R1E1R1E1R1E1R1E1R1E1R1E1R1E1R1E1R1F1R1F1R1F1"
	DRAW "R1F1R1F1R1F1R1F1R1F1R1F1R1F1R1F1R1F1L47D4R48U3D51L4U17L41D17L3U47"
	FOR i = 1 TO 7: DRAW "BR6R2D25L2U25": NEXT i
	DRAW "BD33R2"
	FOR i = 1 TO 5: DRAW "L40BR40D3": NEXT i
	x = x + 1: IF x < 3 GOTO lwing
	PSET (270, 190), 0
	FOR i = 1 TO 3: DRAW "C7BR6R2D45L2U45": NEXT i
	PSET (344, 190), 0
	FOR i = 1 TO 3: DRAW "C7BR6R2D45L2U45": NEXT i
	PSET (283, 140), 0
	FOR i = 1 TO 11: DRAW "C7BR6R2D25L2U25": NEXT i
	PSET (283, 120), 0
	FOR i = 1 TO 11: DRAW "C7BR6R2D15L2U15": NEXT i
	LINE (315, 55)-(325, 77), 7, B
	LINE (318, 57)-(322, 75), 7, B
	PSET (315, 53), 0
	DRAW "S3C7R13U6L13D5BU5C7U2E1U2E2U3H2U3H1E3U2H1U2E2U2E2F2D2F4D3R2E2F1G4L1D7F1D2F1D1G2"
	LINE (140, 270)-(510, 430), 14, BF
	COLOR 15
	IF soundEffects = 2 THEN PLAY "T130MFMSO2f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4"
	LOCATE 20, 20: PRINT CHR$(34); "... and that the government of the people,"
	IF soundEffects = 2 THEN PLAY "o2b-8.a16g8.g16g8.a16b-8.a16b-8.g16f8.g16f8.d16f4"
	LOCATE 21, 20: PRINT "by the people, for the people,"
	IF soundEffects = 2 THEN PLAY "f8.f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4b-4MNo3c4c4o2b-4a4b-2"
	LOCATE 22, 20: PRINT "shall not perish from the earth."; CHR$(34)
	LOCATE 25, 40: PRINT "- Abraham Lincoln"
	FOR i = -565 TO 50 STEP 50: CALL DrawFlags(1, i, 0): NEXT i
	IF soundEffects = 2 THEN PLAY "P2f4..e-16d8.f16b-8.o3c16d2o2b-2g4..a16b-8.a16b-8.g16f2d2": PLAY "f4..e-16d8.f16b-8.o3c16d2o2b-4b-4o3c4c4o2b-4a4b-2.."
END SUB