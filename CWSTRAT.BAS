DEFINT A-Z
 
DIM SHARED gATKFAC, gDEFAC, gTCR
DIM SHARED gAggress!, gAIBoldness, gArmySize(40), gArmyCommander(40), gArmyExp(40), gArmySupply(40), gArmyMove(40), gArray(40)
DIM SHARED gArmyOnRailroad(2), gArmyLocation(40), gArmyName$(40), gBattleStats(2), gBorderWidth, gCanMove
DIM SHARED gCurrentIncome(2), gCapitalCity(2), gCasualty&(2), gChosenOption%, gCityO(40), gCityX(40), gCityY(40), gCityValue(40)
DIM SHARED gCityOwner(40), gCurrentCash(2), gCityController(2), gCityName$(40), gColour%, gCurrentSide, gCurrentMonth, gCurrentYear
DIM SHARED gDifficultyLevel, gEmancipate, gEventsBalance, gFacesImage(1 TO 1564), gFleet$(2), gFont$(26), gFortLevel(40)
DIM SHARED gGraphicLevel, gGraphicImage(300), gGrudge, gHasNavy, gHighlight%, gHistory, gHumanPlayers, gIsOccupied(40), gJanuaryCampaign
DIM SHARED gLeaderName$(40), gLeaderRating(40), gMenuText$(21), gMenuRows%, gMatrix(40, 7), gMonthes$(12), gMtn(1 TO 1564)
DIM SHARED gNationName$(2), gNavalCommerce, gNavyLocation(2), gNavySize(2), gNavyMove(2), gUnionCapital(60), gOrderOfMoves(40)
DIM SHARED gRR(2), gRRFrom(2), gRealism, gNavalRaider 
DIM SHARED gRecruitCity(5), gRecruitFlag, gSavedGameExists, gSoundEffects, gStarX(8), gStarY(8), gThrill, gTurbo!
DIM SHARED gTLX%, gTLY%, gTrainCapacity(2), gTimesPlayed
DIM SHARED gUSAdvantage, gVictoryFlags(6), gVictoryPoints(2), gWindowType%, gVPTotal
DIM SHARED gReplaying

gReplaying = 0

CALL NewGame
CALL DrawMap
CALL Menu0
CALL NewMonth
CALL Menu0

DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"

SUB NewGame
	gTimesPlayed = 0
	gRecruitFlag = 0
	FOR k = 1 TO 40
		gArmySize(k) = 0
		gArmyLocation(k) = 0
		gArmyMove(k) = 0
		gArmyCommander(k) = 0
		gArmyName$(k) = ""
	NEXT k
	gUSAdvantage = 0
	gEmancipate = 0
	FOR k = 1 TO 2
		gNavySize(k) = 0
		gNavyLocation(k) = 0
		gNavyMove(k) = 0
		gRR(k) = 0
		gVictoryPoints(k) = 0
		gArmyOnRailroad(k) = 0
	NEXT k

	gSavedGameExists = 1
	gVictoryFlags(1) = 1

	CALL FileManager(1)
	IF _FILEEXISTS("mtn.vga") THEN
		DEF SEG = VARSEG(gMtn(1))
		BLOAD "mtn.vga", VARPTR(gMtn(1))
		DEF SEG
	ELSE
		COLOR 15: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'": TICK 9
	END IF

	RESTORE
	FOR k = 1 TO 26
		READ gFont$(k)
	NEXT k

	IF gRealism > 0 AND gCurrentYear < 1862 THEN
		FOR i = 1 TO 2
			someString$ = STRING$(LEN(gFleet$(i)), "W")
			gFleet$(i) = someString$
		NEXT i
	END IF

	IF gHumanPlayers < 1 OR gHumanPlayers > 2 THEN gHumanPlayers = 1
	IF gHumanPlayers = 2 OR gCurrentSide = 0 THEN gCurrentSide = 1
	IF gCurrentSide = 1 THEN gEventsBalance = 7
	IF gCurrentSide = 2 THEN gEventsBalance = 3
	IF gTurbo! < 1 THEN gTurbo! = 2
	IF gCurrentSide = 1 AND gDifficultyLevel < 3 THEN 
		gCurrentCash(2) = gCurrentCash(2) + 600 - 100 * gDifficultyLevel
	END IF
	IF gCurrentSide = 2 AND gDifficultyLevel > 3 THEN 
		gCurrentCash(1) = gCurrentCash(1) + 100 * gDifficultyLevel
	END IF

	FOR i = 1 TO 2
		gCurrentIncome(i) = gCurrentCash(i)
		gCurrentCash(i) = gCurrentCash(i) + 50 * RND
	NEXT i
	gChosenOption = 0

	SCREEN 12
		DEF SEG = VARSEG(gGraphicImage(1))
		BLOAD "cwsicon.vga", VARPTR(gGraphicImage(1))
		DEF SEG

		PUT (100, 100), gGraphicImage, PSET
		GET (101, 101)-(113, 113), gUnionCapital
	CLS
	COLOR 11: LOCATE 14, 27: PRINT "VGA CIVIL WAR STRATEGY GAME"
	COLOR 4: LOCATE 15, 32: PRINT "Registered Edition"
	COLOR 14: LOCATE 28, 1: PRINT TAB(8); "(c) 1998 W. R. Hutsell"
	LOCATE 28, 60: PRINT "v1.57"
	LINE (190, 170)-(440, 260), 1, B
	LINE (180, 180)-(450, 250), 7, B
	CALL DrawFlags(1, -440, 0)
	CALL DrawFlags(2, -100, 0)
	IF gReplaying = 0 AND gSoundEffects = 2 AND gChosenOption = 0 THEN
		CALL UnionSong
	END IF

	CALL UnionPlus

	gCityName$(0) = "NONE"
	OPEN "I", 1, "cities.grd"
	gVPTotal = gUSAdvantage + 200
	FOR i = 1 TO 40
		INPUT #1, a, gCityX(i), gCityY(i), gCityName$(i), gCityOwner(i), gCityValue(i)
		gCityO(i) = gCityOwner(i)
		CALL occupy(i)
		FOR j = 1 TO 7
			INPUT #1, gMatrix(i, j)
		NEXT j
		INPUT #1, gFortLevel(i)
		IF gCityOwner(i) > 0 THEN 
			x = gCityOwner(i)
			gCityController(x) = gCityController(x) + 1
			gVictoryPoints(x) = gVictoryPoints(x) + gCityValue(i)
		END IF
		IF gCityOwner(i) > 0 THEN 
			gCurrentCash(gCityOwner(i)) = gCurrentCash(gCityOwner(i)) + gCityValue(i)
		END IF
		gVPTotal = gVPTotal + gCityValue(i)
	NEXT i
	CLOSE #1
	CALL ClearBottom

	RANDOMIZE TIMER
	TICK .3
	gWindowType = 2
	gHighlight = 15
	gReplaying = 1
	IF gHumanPlayers = 2 THEN CALL Blanken
	gMenuText$(0) = "VGA CIVILWAR STRATEGY"
	gMenuText$(1) = "Resume Saved Game"
	gMenuText$(2) = "Start NEW Game"
	gMenuText$(3) = "Quit"
	gTLX = 33: gTLY = 20: gColour = 5: gMenuRows = 3
	gChosenOption = 23
	CALL ShowMenu(0)
	IF gChosenOption = 1 THEN
		CLS
		' GOTO loader
		CALL Menu0
	END IF
	IF gChosenOption = 3 THEN CLS : END
	IF gHistory = 1 THEN
		CLS
		IF _FILEEXISTS("cws.his") THEN SHELL "copy cws.his oldhist.ory"
		OPEN "O", 2, "cws.his"
		PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
		CLOSE #2
	ELSE
		SCREEN 12: CLS
	END IF
END SUB

SUB NewMonth
	IF gCurrentSide > 2 THEN gCurrentSide = 1
	someString$ = "--------> EVENTS FOR " + gMonthes$(gCurrentMonth) + " " + STR$(gCurrentYear) + " --------"
	CALL scribe(someString$, 0)
	CALL TurnUpdate
	gCityController(1) = 0
	gCityController(2) = 0

	FOR i = 1 TO 2
		gCurrentIncome(i) = 0
		IF gCurrentCash(i) > 19999 THEN gCurrentCash(i) = 19999
		IF gCurrentCash(i) < 0 THEN gCurrentCash(i) = 0
	NEXT i
	IF gHumanPlayers = 1 AND gCurrentSide = 2 THEN 
		gCurrentIncome(1) = gCurrentIncome(1) + gUSAdvantage
	END IF

	FOR i = 1 TO 40
		IF gCityOwner(i) > 0 THEN 
			x = gCityOwner(i)
			gCityController(x) = gCityController(x) + 1
			gCurrentIncome(x) = gCurrentIncome(x) + gCityValue(i)
		END IF
		gArmyMove(i) = 0
	NEXT i

	FOR i = 1 TO 2
		gNavyMove(i) = 0
		IF gCapitalCity(i) > 0 THEN 
			gCurrentIncome(i) = gCurrentIncome(i) + 100
		END IF
		gCurrentCash(i) = gCurrentCash(i) + gCurrentIncome(i)
		IF gNavalCommerce > 0 AND i <> gNavalCommerce THEN 
			gCurrentCash(i) = gCurrentCash(i) - gNavalRaider
		END IF
	NEXT i
	gVPTotal = gCurrentIncome(1) + gCurrentIncome(2)

	newChosenOption = 22
	IF gHumanPlayers = 2 THEN 
		CALL Blanken
		CALL DrawMap
	END IF
	CALL victor
	ON ERROR GOTO 0
	IF gTimesPlayed > 0 THEN
		FOR k = 1 TO 40
			gArmyLocation(k) = 0
		NEXT k
		CALL NewGame
	END IF
END SUB

SUB Menu0 ' Main Menu
	CALL DrawTopBar
	IF gHumanPlayers = 2 AND gCurrentSide = 0 THEN gCurrentSide = 1
	IF gCurrentCash(gCurrentSide) < 100 AND gNavyLocation(gCurrentSide) = 0 THEN gHasNavy = 1

	gHighlight = 11
	gColour = 4
	gTLX = 67
	gTLY = 13
	gMenuText$(0) = "Main"
	gMenuText$(1) = "Troops": IF gRecruitFlag < 0 OR gCurrentCash(gCurrentSide) < 100 THEN gMenuText$(1) = "-": newChosenOption = 23
	gMenuText$(2) = "Moves": IF gCanMove > 0 THEN gMenuText$(2) = "-": IF newChosenOption = 23 THEN newChosenOption = 24
	gMenuText$(3) = "Ships": IF gHasNavy > 0 THEN gMenuText$(3) = "-": IF newChosenOption = 24 THEN newChosenOption = 25
	gMenuText$(4) = "Railroad": IF gRR(gCurrentSide) > 0 THEN gMenuText$(4) = "-": IF newChosenOption = 25 THEN newChosenOption = 26
	gMenuText$(5) = "END TURN"
	gMenuText$(6) = "Inform"
	gMenuText$(7) = "COMMANDS"
	gMenuText$(8) = "UTILITY"
	gMenuText$(9) = "Files"

	gMenuRows = 9
	gChosenOption = newChosenOption
	CALL ShowMenu(0)
	CALL ClearRight
	SELECT CASE gChosenOption ' Main Menu
		CASE 1 ' Recruit
			IF gCurrentCash(gCurrentSide) < 100 OR gRecruitFlag < 0 THEN 
				gRecruitFlag = -1
				CALL Menu0
			END IF
			CALL RecruitArmy((gCurrentSide))
			newChosenOption = 23
			CALL Menu0
		CASE 2 ' Move
			CALL MoveArmies
			newChosenOption = 23
			CALL Menu0
		CASE 3 ' Navy
			IF gHasNavy = 0 THEN CALL ManageNavy((gCurrentSide), 0)
			newChosenOption = 25
		CASE 4 ' Railroad
			IF gRR(gCurrentSide) = 0 THEN
				COLOR 15: LOCATE 4, 68: PRINT "RAILROAD MOVE"
				PSET (550, 20), 0
				DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5R1BF4"
				IF gCurrentSide = 2 THEN z = 7 ELSE z = 9
				x = POINT(0): y = POINT(1)
				PAINT (x, y), z, 15
				IF gCurrentSide = 1 THEN COLOR 11 ELSE COLOR 15
				CALL traincapacity(gCurrentSide, limit)
				CALL ClearBottom
				PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
				CALL railroad(gCurrentSide)
			ELSE
				CALL ClearBottom
				COLOR 11: PRINT "Railroad is already carrying "; gArmyName$(gRR(gCurrentSide)); " to "; gCityName$(gArmyMove(gRR(gCurrentSide)));
				CALL Menu0
			END IF
		CASE 5 ' End Turn
			gTLX = 67: gTLY = 15
			gHighlight = 15: gColour = 3: gChosenOption = 23
			gMenuText$(0) = "End Turn"
			gMenuText$(1) = "Yes"
			gMenuText$(2) = "NOT YET"
			gMenuRows = 2
			CALL ShowMenu(0)
			CALL ClearRight
			IF gChosenOption <> 1 THEN 
				newChosenOption = 24
				CALL Menu0
			END IF
			endturn: ' Line Label
			gRecruitFlag = 0
			gCanMove = 0
			gHasNavy = 0
			IF gHumanPlayers = 2 THEN 
				gCurrentSide = gCurrentSide + 1
				IF gCurrentSide = 2 THEN 
					CALL Blanken
					CALL DrawMap
					CALL Menu0
				END IF
			END IF
			CALL NewMonth
		CASE 6 ' Reports
			CALL ShowReports((gCurrentSide)): newChosenOption = 27
			CALL StartToFinish(start, fin, gCurrentSide)
			FOR i = start TO fin
				IF gArmyMove(i) > 0 THEN 
					CALL MoveUnitIcon(gArmyLocation(i), gArmyMove(i), 1)
				END IF
			NEXT i
		CASE 7 ' Commands Menu
			CALL CommandsMenu
		CASE 8 ' Utility Menu
			CALL UtilityMenu
		CASE 9 ' Files
			IF _FILEEXISTS("*.sav") = 0 THEN gSavedGameExists = 0
			newgamemenu: ' Line Label
			gChosenOption = 23
			newChosenOption = 30
			IF gCurrentYear = 1861 THEN gChosenOption = 22
			gMenuText$(0) = "Options"
			gMenuText$(1) = "Load": IF gSavedGameExists = 0 THEN gMenuText$(1) = "-": gChosenOption = 23
			gMenuText$(2) = "Save"
			gMenuText$(3) = "New Game"
			gMenuText$(4) = "Quit"
			gMenuRows = 4: gTLX = 67: gTLY = 15
			CALL ShowMenu(0)
			CALL ClearRight
			SELECT CASE gChosenOption
				CASE IS < 1
					CALL Menu0
				CASE 1, 2
					loader: ' Line Label
					IF gChosenOption = 1 AND gSavedGameExists = 0 THEN GOTO newgamemenu
					CALL FileManager(gChosenOption + 1)
					IF gChosenOption = 1 THEN 
						gRecruitFlag = 0
						gCanMove = 0
						gHasNavy = 0
					END IF
					CALL Menu0
				CASE 3
					OPEN "O", 1, "cws.cfg"
					WRITE #1, gCurrentSide, gGraphicLevel, gSoundEffects, gDifficultyLevel, gHumanPlayers, gTurbo!, gEventsBalance, gTrainCapacity(1), gTrainCapacity(2), gJanuaryCampaign, gRealism, gBattleStats(1), gBattleStats(2), gCasualty&(1), gCasualty&(2), gHistory, gAIBoldness
					CLOSE #1
					CLS
					CALL NewGame
				CASE 4:
					gChosenOption = 23
					gMenuText$(0) = "Quit"
					gMenuText$(1) = "Yes"
					gMenuText$(2) = "No"
					gMenuRows = 2: gColour = 5
					gTLX = 67: gTLY = 15
					CALL ShowMenu(0)
					CALL ClearRight
					IF gChosenOption = 1 THEN 
						END
					ELSE 
						CALL Menu0
					END IF
			END SELECT
		CASE 99
		GOTO endturn
	CASE ELSE
		newChosenOption = 22
		CALL Menu0
	END SELECT
END SUB

SUB CommandsMenu
	gTLX = 67: gTLY = 13
	COLOR 11: LOCATE gTLY - 2, gTLX: PRINT "esc=Main Menu"
	gHighlight = 15: gColour = 3
	newChosenOption = 24
	gMenuText$(0) = "Commands"
	gMenuText$(1) = "Cancel"
	gMenuText$(2) = "Fortify": IF gCurrentCash(gCurrentSide) < 200 THEN gMenuText$(2) = "-"
	gMenuText$(3) = "Join"
	gMenuText$(4) = "Supply"
	gMenuText$(5) = "Capital": IF gCapitalCity(gCurrentSide) = 0 OR gCurrentCash(gCurrentSide) < 500 THEN gMenuText$(5) = "-"
	gMenuText$(6) = "Detach": IF gCurrentSide = 1 THEN gMenuText$(6) = "-"
	gMenuText$(7) = "Army Drill"
	gMenuText$(8) = "Relieve"
	gMenuText$(9) = "MAIN MENU"
	gMenuRows = 9
	CALL ShowMenu(0)
	CALL ClearRight
	newChosenOption = 28
	SELECT CASE gChosenOption
		CASE 1 ' Cancel
			CALL CancelArmyMovement(gCurrentSide)
			gCanMove = 0
			gChosenOption = 22
		CASE 2 ' Fortify
			IF gCurrentCash(gCurrentSide) < 200 THEN 
				CALL ClearBottom
				COLOR 11: PRINT "Not enough money for fort";
				CALL Menu0
			END IF
			CALL FortifyCity(target)
			IF gCurrentCash(gCurrentSide) < 200 THEN CALL Menu0
			gChosenOption = 23
			CALL CommandsMenu
		CASE 3 ' Combine
			x = gCurrentSide
			CALL CombineArmies(x)
			IF x < 0 THEN
				CALL ClearBottom
				COLOR 11
				PRINT "No eligible armies in same city to combine";
				CALL stax(gCurrentSide)
				CALL Menu0
			END IF
			gChosenOption = 24
			CALL CommandsMenu
		CASE 4 ' Supply
			CALL StartToFinish(start, fin, (gCurrentSide))
			gMenuText$(0) = "Supply"
			gTLX = 67: gTLY = 5: gColour = 5
			gMenuRows = 0
			FOR i = start TO fin
				IF gArmyLocation(i) = 0 OR gArmySupply(i) > 1 THEN GOTO alone
				IF gRealism > 0 THEN
					CALL cutoff(gCurrentSide, gArmyLocation(i), a)
					IF a < 1 THEN 
						CALL ClearBottom
						COLOR 15: PRINT gNationName$(gCurrentSide); " army in "; gCityName$(gArmyLocation(i)); " is CUT OFF !";
						TICK gTurbo!
						GOTO alone
					END IF
				END IF
				gMenuRows = gMenuRows + 1
				IF LEN(gArmyName$(i)) < 11 THEN max = LEN(gArmyName$(i)) ELSE max = 11
				gMenuText$(gMenuRows) = LEFT$(gArmyName$(i), max)
				gArray(gMenuRows) = i
				alone: ' Line Label
			NEXT i
			IF gMenuRows = 0 THEN 
				CALL ClearBottom
				COLOR 11: PRINT "All eligible "; gNationName$(gCurrentSide); " armies have supplies";
				CALL Menu0
			END IF
			CALL ShowMenu(6)
			CALL ClearRight
			IF gChosenOption < 0 THEN CALL Menu0
			index = gArray(gChosenOption)
			IF gArmySupply(index) < 2 THEN
			CALL ResupplyArmy(index)
			CALL DrawArmyUnit(index)
			END IF
			gChosenOption = 25
			CALL CommandsMenu
		CASE 5 ' Move Capital
			IF gCapitalCity(gCurrentSide) = 0 OR gCurrentCash(gCurrentSide) < 500 THEN 
				CALL ClearBottom
				COLOR 11: PRINT "Cannot move capital";
				CALL Menu0
			END IF
			gCurrentCash(gCurrentSide) = gCurrentCash(gCurrentSide) - 500
			gVictoryPoints(3 - gCurrentSide) = gVictoryPoints(3 - gCurrentSide) + 50
			CALL ClearRight
			gMenuText$(0) = "Capital"
			someString$ = gCityName$(gCapitalCity(gCurrentSide))
			index = gCapitalCity(gCurrentSide)
			CALL newcity(index)
			IF index = 0 THEN CALL Menu0
			gCapitalCity(gCurrentSide) = index
			CALL ClearBottom
			PRINT gNationName$(gCurrentSide); " capital moved from "; someString$; " to "; gCityName$(gCapitalCity(gCurrentSide));
			CALL ClearRight
			CALL DrawCities
			CALL TICK(9)
			CALL ClearBottom
		CASE 6 ' Detach
			IF gCurrentSide = 1 THEN 
				CALL ClearBottom
				COLOR 11: PRINT "Option not available to Union";
				CALL Menu0
			END IF
			COLOR 14: LOCATE 4, 68: PRINT "DETACH UNIT"
			CALL MoveFrom(index, target)
			IF target < 1 OR index < 1 THEN CALL Menu0
			IF gArmySize(index) < 65 THEN 
				CALL ClearBottom
				PRINT "Too small to detach";
				CALL TICK(gTurbo!)
				CALL Menu0
			END IF
			CALL commander(2, empty)
			IF empty = 0 THEN CALL Menu0
			gArmySupply(empty) = .3 * gArmySupply(index)
			gArmySupply(index) = gArmySupply(index) - gArmySupply(empty)
			IF gArmySupply(index) < 0 THEN gArmySupply(index) = 0
			gArmySize(empty) = .3 * gArmySize(index)
			gArmySize(index) = gArmySize(index) - gArmySize(empty)
			gArmyLocation(empty) = target
			gArmyExp(empty) = gArmyExp(index)
			gArmyMove(empty) = 0
			gArmyCommander(empty) = gLeaderRating(empty)
			gArmyName$(empty) = gLeaderName$(empty)
			gLeaderName$(empty) = ""
			gArmyExp(empty) = gArmyExp(index)
			CALL ClearBottom
			COLOR 11: PRINT "Unit #"; empty; " with "; : CALL CorrectArmySize(empty): PRINT " men detached under "; gArmyName$(empty);
			CALL TICK(gTurbo!)
			IF gSoundEffects > 0 THEN SOUND 2222, 1
			CALL stax(gCurrentSide)
			gChosenOption = 27
			CALL CommandsMenu
		CASE 7 ' Drill
			COLOR 14: LOCATE 4, 68: PRINT "DRILL ARMY"
			CALL MoveFrom(index, target)
			IF target < 1 OR index < 1 THEN 
				CALL ClearBottom
				COLOR 11: PRINT "No armies remain eligible for drills in "; gMonthes$(gCurrentMonth);
				CALL Menu0
			END IF
			IF gArmyExp(index) > 5 OR gArmyExp(index) >= gArmyCommander(index) THEN 
				CALL ClearBottom
				COLOR 12: PRINT gArmyName$(index); ": Army has reached maximum improvement through drilling";
				CALL CommandsMenu
			END IF
			gArmyExp(index) = gArmyExp(index) + 1
			CALL ClearBottom
			PRINT gArmyName$(index); " has drilled to reach experience level "; gArmyExp(index);
			IF gSoundEffects > 0 THEN SOUND 2222, 1
			CALL TICK(gTurbo!): ClearBottom
			gArmyMove(index) = -1
			gChosenOption = 28
			CALL CommandsMenu
		CASE 8 ' Relieve
			CALL relieve(gCurrentSide)
			gChosenOption = 29
			CALL CommandsMenu
		CASE ELSE ' Else
			newChosenOption = 28
			CALL Menu0
	END SELECT
	gChosenOption = 21 + gChosenOption
	CALL CommandsMenu
END SUB

SUB UtilityMenu
	newChosenOption = 29
	gMenuText$(0) = "Utility"
	gMenuText$(1) = "Side": IF gHumanPlayers = 2 THEN gMenuText$(2) = ""
	gMenuText$(2) = "1 Player": IF gHumanPlayers = 2 THEN gMenuText$(2) = "2 Player"
	gMenuText$(3) = "Graphics" + STR$(gGraphicLevel)
	gMenuText$(4) = "Noise": IF gSoundEffects > 0 THEN gMenuText$(4) = gMenuText$(4) + STRING$(gSoundEffects, "*")
	gMenuText$(5) = "Display" + STR$(gTurbo!)
	someString$ = STR$(gDifficultyLevel): IF gCurrentSide = 1 THEN someString$ = STR$(6 - gDifficultyLevel)
	gMenuText$(6) = "Balance" + someString$
	gMenuText$(7) = "End Cond"
	someString$ = "+": IF gEventsBalance = 0 THEN someString$ = ""
	gMenuText$(8) = "Rndom Evt " + someString$
	gMenuText$(9) = "Vary Start"
	someString$ = "": IF gJanuaryCampaign = 1 THEN someString$ = "+"
	gMenuText$(10) = "Jan Campgn" + someString$
	someString$ = "": IF gRealism = 1 THEN someString$ = "+"
	gMenuText$(11) = "Realism " + someString$
	gMenuText$(12) = "Chk Links"
	someString$ = "": IF gHistory = 1 THEN someString$ = "+"
	gMenuText$(13) = "History" + someString$
	gMenuRows = 13: gTLX = 67: gTLY = 11
	COLOR 11: LOCATE gTLY - 2, gTLX: PRINT "esc=Main Menu"
	IF gHumanPlayers = 1 THEN 
		gMenuRows = 14: gMenuText$(14) = "Aggress" + STR$(gAIBoldness)
	END IF
	CALL ShowMenu(-1): CALL ClearRight
	SELECT CASE gChosenOption
		CASE 1 ' Swap Sides
			IF gHumanPlayers = 2 THEN CALL Menu0
			gCurrentSide = 3 - gCurrentSide: COLOR 9
			IF gCurrentSide = 2 THEN COLOR 7
			CALL ClearBottom
			PRINT "Now playing "; gNationName$(gCurrentSide); " side";
			IF gSoundEffects > 0 THEN SOUND 999, 1
			IF gCurrentSide = 1 THEN gEventsBalance = 7
			IF gCurrentSide = 2 THEN gEventsBalance = 3
			CALL DrawTopBar
			CALL Menu0
		CASE 2 ' Solo or 2 Player
			gHumanPlayers = 3 - gHumanPlayers
			CALL ClearBottom
			COLOR 12
			IF gSoundEffects > 0 THEN SOUND 999, 1
			IF gHumanPlayers = 2 THEN someString$ = "2 Player" ELSE someString$ = "Solo"
			PRINT someString$; " Game";
			gChosenOption = 23
			CALL UtilityMenu
		CASE 3 ' Graphics
			gGraphicLevel = gGraphicLevel + 1
			IF gGraphicLevel > 3 THEN gGraphicLevel = 0
			someString$ = "ROADS"
			IF gGraphicLevel = 0 THEN someString$ = "DISABLED"
			IF gGraphicLevel = 2 THEN someString$ = "CITY NAMES"
			IF gGraphicLevel = 3 THEN someString$ = "FULL"
			CLS
			CALL DrawMap
			CALL ClearBottom
			COLOR 11: PRINT "Graphics : "; someString$;
			IF gSoundEffects > 0 THEN SOUND 2700, 1
			gChosenOption = 24
			CALL UtilityMenu
		CASE 4 ' Sounds
			CALL ClearRight
			gChosenOption = gSoundEffects + 22
			gMenuText$(0) = "SOUNDS"
			gMenuText$(1) = "Quiet"
			gMenuText$(2) = "Sound"
			gMenuText$(3) = " & Sound"
			gMenuRows = 3: gTLX = 67: gTLY = 12
			CALL ShowMenu(0)
			CALL ClearRight
			IF gChosenOption < 1 THEN CALL Menu0
			CALL ClearBottom
			COLOR 11: PRINT "Sound Option : "; gMenuText$(gChosenOption);
			gSoundEffects = gChosenOption - 1
			IF gSoundEffects > 0 THEN SOUND 999, 1
			gChosenOption = 25
			CALL UtilityMenu
		CASE 5 ' Display Speed
			gChosenOption = gTurbo! + 21
			gMenuText$(0) = "Display"
			gMenuText$(1) = "Fast"
			gMenuText$(2) = "Normal"
			gMenuText$(3) = "Slow"
			gMenuText$(4) = "Very Slow"
			gMenuText$(5) = "Reg Color": IF gBorderWidth > 0 THEN gMenuText$(5) = "Alt Color"
			gTLX = 67: gTLY = 15: gMenuRows = 5
			CALL ShowMenu(0)
			CALL ClearRight
			SELECT CASE gChosenOption
				CASE IS < 1
				CASE IS < 5
					gTurbo! = gChosenOption
					IF gTurbo! = 4 THEN gTurbo! = 8
					CALL ClearBottom
					COLOR 11
					PRINT "Display Speed : "; gMenuText$(gChosenOption);
				CASE 5
					gBorderWidth = 1 - gBorderWidth
					CLS
					CALL DrawMap
					CALL DrawTopBar
			END SELECT
			gChosenOption = 26: CALL UtilityMenu
	CASE 6 ' Play Balance
		gChosenOption = gDifficultyLevel + 21
		gMenuText$(0) = "Balance"
		gMenuText$(1) = "Rebel ++"
		gMenuText$(2) = "Rebel +"
		gMenuText$(3) = "Balanced"
		gMenuText$(4) = "Union +"
		gMenuText$(5) = "Union ++"
		gTLX = 67: gTLY = 15: gMenuRows = 5
		CALL ShowMenu(8): CALL ClearRight
		IF gChosenOption < 1 THEN CALL Menu0
		CALL ClearBottom
		COLOR 11: PRINT "Play Balance : "; gMenuText$(gChosenOption);
		gDifficultyLevel = gChosenOption
		CALL UnionPlus
		gChosenOption = 27
		CALL UtilityMenu
	CASE 7 ' Ending Conditions
		CALL VictoryConditionsMet
		gChosenOption = 28
		CALL UtilityMenu
	CASE 8 ' Random Events Options
		gMenuText$(0) = "Random Events"
		gMenuRows = 4: gTLX = 30: gTLY = 8
		gMenuText$(1) = "OFF"
		gMenuText$(2) = "Favor Union ": IF gEventsBalance = 3 THEN gMenuText$(2) = gMenuText$(2) + " "
		gMenuText$(3) = "Neutral     ": IF gEventsBalance = 5 THEN gMenuText$(3) = gMenuText$(3) + " "
		gMenuText$(4) = "Favor Rebels": IF gEventsBalance = 7 THEN gMenuText$(4) = gMenuText$(4) + " "
		gColour = 5
		CALL ShowMenu(0)
		gColour = 4
		SELECT CASE gChosenOption
		CASE 1
			gEventsBalance = 0
			anotherString$ = ""
		CASE 2
			gEventsBalance = 3
		CASE 3
			gEventsBalance = 5
		CASE 4
			gEventsBalance = 7
		CASE ELSE
		END SELECT
		IF gChosenOption > 1 AND gChosenOption < 5 THEN
			anotherString$ = gMenuText$(gChosenOption)
		END IF
		CALL ClearBottom
		IF gEventsBalance = 0 THEN someString$ = "OFF" ELSE someString$ = ""
		COLOR 11: PRINT "Random Events : "; someString$; " "; anotherString$;
		COLOR 14: PRINT "			press a key";
		DO WHILE INKEY$ = "": LOOP
		CLS
		CALL DrawMap
		gChosenOption = 29
		CALL UtilityMenu
	CASE 9 ' Vary Start Conditions
		CALL FileManager(1)
		gCurrentCash(1) = gCurrentCash(1) - 100 + 200 * RND
		gCurrentCash(2) = gCurrentCash(2) + 100 + 200 * RND
		gAIBoldness = 5 * RND
		FOR k = 1 TO 6
			IF RND > .6 THEN
				gArmyLocation(k) = 0
				gArmySize(k) = 0
				gArmyCommander(k) = 0
				gArmyExp(k) = 0
				gArmyMove(k) = 0
				gArmySupply(k) = 0
			END IF
		NEXT k
		FOR k = 21 TO 6
			IF RND > .6 THEN
				gArmyLocation(k) = 0
				gArmySize(k) = 0
				gArmyCommander(k) = 0
				gArmyExp(k) = 0
				gArmyMove(k) = 0
				gArmySupply(k) = 0
			END IF
		NEXT k
		FOR k = 1 TO 40
			CALL occupy(k)
			NEXT k
		gNavySize(1) = 10 * RND
		IF gNavySize(1) = 0 THEN gNavyLocation(1) = 0
		gNavySize(2) = 10 * RND
		IF gNavySize(2) > 0 THEN gNavyLocation(2) = 27
		FOR i = 1 TO 2
			gFleet$(i) = ""
			FOR j = 1 TO gNavySize(i)
				someString$ = "W"
				IF RND > .45 * gCurrentSide THEN someString$ = "I"
				gFleet$(i) = gFleet$(i) + someString$
			NEXT j
		NEXT i
		IF RND > .7 THEN gCapitalCity(2) = 25
		FOR k = 1 TO 40
			IF RND > .8 THEN 
				gLeaderRating(k) = gLeaderRating(k) - 3 + 6 * RND
				IF gLeaderRating(k) > 9 THEN gLeaderRating(k) = 9
			END IF
			IF gLeaderRating(k) < 1 THEN gLeaderRating(k) = 1
		NEXT k
		CLS
		CALL DrawMap
		gChosenOption = 30
		CALL UtilityMenu
	CASE 10 ' January Campaigns
		gJanuaryCampaign = 1 - gJanuaryCampaign
		someString$ = "PROHIBITED"
		IF gJanuaryCampaign = 1 THEN someString$ = "ALLOWED"
		COLOR 11
		CALL ClearBottom
		PRINT "January Campaigns : "; someString$;
		gChosenOption = 31
		CALL UtilityMenu
	CASE 11 ' Realism Switch
		gRealism = 1 - gRealism
		CALL ClearBottom
		COLOR 11
		IF gRealism = 0 THEN
			PRINT "Recruiting FIXED :  7000 for NEW Armies   4500 for Additions";
		ELSE
			PRINT "REALISM ON: Recruiting based on CITY SIZE";
			IF gCurrentSide = 2 AND gEventsBalance = 1 AND gEventsBalance < 5 THEN 
				gEventsBalance = gEventsBalance + 2
			END IF
			CALL UnionPlus
		END IF
		gChosenOption = 32: CALL UtilityMenu
	CASE 12 ' Check Map Linkages
		CALL CheckMapIntegrity
		CALL TICK(99)
		CALL DrawMap
	CASE 13 ' History
		gHistory = 1 - gHistory
		someString$ = "OFF"
		IF gHistory = 1 THEN someString$ = "ON"
		CALL ClearBottom
		PRINT "History is now "; someString$;
		gChosenOption = 34
		CALL UtilityMenu
	CASE 14 ' Aggression
		gAIBoldness = gAIBoldness + 1
		IF gAIBoldness > 5 THEN gAIBoldness = 0
		SELECT CASE gAIBoldness
			CASE 0: someString$ = "PASSIVE"
			CASE 1: someString$ = "TIMID"
			CASE 2: someString$ = "CAUTIOUS"
			CASE 3: someString$ = "NORMAL"
			CASE 4: someString$ = "BOLD"
			CASE 5: someString$ = "RECKLESS"
		END SELECT
		CALL ClearBottom
		COLOR 11
		PRINT "Enemy Aggression : "; someString$; " ("; gAIBoldness; ")";
		gChosenOption = 35
		CALL UtilityMenu
	CASE ELSE
	END SELECT
END SUB

SUB blanken
	IF gCurrentSide = 2 THEN c = 7 ELSE c = 1
	CLS : LINE (100, 200)-(500, 300), c, BF
	LINE (100, 200)-(500, 300), 8 - c, B
	COLOR 7: LOCATE 14, 31: PRINT " "; gMonthes$(gCurrentMonth); gCurrentYear
	COLOR 11: LOCATE 17, 30: PRINT gNationName$(gCurrentSide); " PLAYER TURN"
	DO WHILE INKEY$ = "": LOOP
END SUB

SUB UnionPlus
	gUSAdvantage = 120 * gDifficultyLevel
	IF gHumanPlayers = 2 THEN gUSAdvantage = 50 * gDifficultyLevel
	IF gRealism > 0 THEN gUSAdvantage = gUSAdvantage * .7
END SUB

SUB MoveArmies
	CALL MoveFrom(index, target)
	IF target > 0 AND index > 0 GOTO tent
	IF index = -1 THEN gCanMove = 1
	EXIT SUB
	tent:
	gTLX = 67: gTLY = 12

	CALL ShowArmyStats(index)
	COLOR 11: LOCATE 11, 68: PRINT gCityName$(target)
	gMenuRows = 0
	gMenuText$(0) = "To"
	FOR i = 1 TO 6
		IF gMatrix(target, i) > 0 THEN 
			gMenuRows = gMenuRows + 1
			gMenuText$(gMenuRows) = gCityName$(gMatrix(target, i))
			gArray(gMenuRows) = gMatrix(target, i)
		END IF
	NEXT i
	CALL bubble(gMenuRows)

	gHighlight = 10: gColour = 3
	CALL ShowMenu(2)
	CALL ClearRight
	IF gChosenOption < 0 THEN EXIT SUB
	IF gCurrentMonth < 3 AND gJanuaryCampaign = 0 AND gCityOwner(gArray(gChosenOption)) <> gCurrentSide THEN 
		CALL ClearBottom
		COLOR 11: PRINT "No campaigns in January";
		CALL TICK(9)
		CALL ClearBottom
		EXIT SUB
	END IF

	CALL ClearBottom
	PRINT "Army "; index; " "; gArmyName$(index); " is moving from "; gCityName$(target); " to "; gCityName$(gArray(gChosenOption));
	IF gSoundEffects > 0 THEN SOUND 2200, .5: SOUND 2900, .7
	CALL MoveUnitIcon(target, gArray(gChosenOption), 1)
	gArmyMove(index) = gArray(gChosenOption)
	CALL TICK(gTurbo!)
	CALL ClearBottom
	CALL ClearRight
END SUB

SUB ShowArmyStats (index%)
	LINE (530, 60)-(639, 150), 0, BF
	COLOR 15
	LOCATE 5, 68: PRINT gArmyName$(index)
	IF index > 20 THEN COLOR 7 ELSE COLOR 9
	LOCATE 6, 68: PRINT "Size:"; : CALL CorrectArmySize(index)
	LOCATE 7, 68: PRINT "Leader:"; TAB(75); gArmyCommander(index)
	LOCATE 8, 68: PRINT "Exper:"; TAB(75); gArmyExp(index)
	IF gArmySupply(index) < 2 THEN COLOR 12
	LOCATE 9, 68: PRINT "Supply:"; TAB(75); gArmySupply(index)
END SUB

SUB ShipDestroyed (who%)
	gNavySize(who) = gNavySize(who) - 1
	IF gNavySize(who) > 0 THEN
		gFleet$(who) = LEFT$(gFleet$(who), gNavySize(who))
	ELSE
		gFleet$(who) = "": gNavyLocation(who) = 0: gNavySize(who) = 0
	END IF
END SUB

SUB ComputeBattle (attack%, defend%, win%, lose%)
	IF gArmySize(defend) < 1 THEN gArmySize(defend) = 1
	IF gArmySize(attack) < 1 THEN gArmySize(attack) = 1

	CALL MoveUnitIcon(gArmyLocation(defend), 0, 9)
	LOCATE 1, 1: PRINT SPACE$(80)
	CALL ClearRight

	y = 68
	COLOR 11
	LOCATE 1, y: PRINT "Attacker"
	IF attack > 20 THEN c = 7 ELSE c = 9
	COLOR c
	LOCATE 2, y: PRINT gArmyName$(attack)
	LOCATE 3, y: CALL CorrectArmySize(attack)
	AttackerScore = .01 * gArmySize(attack)
	IF AttackerScore > gTCR THEN AttackerScore = gTCR
	LOCATE 4, y: PRINT "Base    "; AttackerScore
	IF gArmySize(attack) / gArmySize(defend) > .2 THEN 
		AttackerScore = AttackerScore + .3 * gArmyCommander(attack) + .3 * gArmyExp(attack)
		IF AttackerScore > gTCR THEN AttackerScore = gTCR
	END IF
	IF gArmyExp(attack) > 8 THEN 
		AttackerScore = AttackerScore + 1
		IF AttackerScore > gTCR THEN AttackerScore = gTCR
	END IF
	LOCATE 5, y: PRINT "Ldr/Exp "; AttackerScore
	IF gArmySize(attack) < 15 THEN
		AttackerScore = .5 * AttackerScore
		IF AttackerScore > gTCR THEN AttackerScore = gTCR
	END IF
	LOCATE 6, y: PRINT "Small   "; AttackerScore
	IF gArmySize(attack) / gArmySize(defend) <= .5 THEN 
		AttackerScore = AttackerScore - 2
		IF AttackerScore < 1 THEN AttackerScore = 1
	END IF
	IF gArmySize(attack) / gArmySize(defend) > 3 THEN 
		AttackerScore = AttackerScore + 2
		IF AttackerScore > gTCR THEN AttackerScore = gTCR
	END IF
	IF gArmySize(attack) / gArmySize(defend) > 10 THEN 
		AttackerScore = gTCR
	END IF
	IF gArmySize(attack) / gArmySize(defend) <= .2 THEN 
		AttackerScore = 1
	END IF
	LOCATE 7, y: PRINT "Outman  "; AttackerScore
	IF gArmySupply(attack) < 1 THEN 
		AttackerScore = .5 * AttackerScore
		COLOR 13
	END IF
	LOCATE 8, y: PRINT "Supply  "; AttackerScore: COLOR c
	IF AttackerScore < 1 THEN AttackerScore = 1
	'                       Adjust attack advantage
	IF attack < 21 AND gCurrentSide = 2 AND gDifficultyLevel > 3 THEN 
		AttackerScore = AttackerScore + 2 * gDifficultyLevel - 6
	END IF
	IF attack > 20 AND gCurrentSide = 1 AND gDifficultyLevel < 3 THEN 
		AttackerScore = AttackerScore + 6 - 2 * gDifficultyLevel
	END IF
	LOCATE 9, y: PRINT "Difclt  "; AttackerScore
	IF AttackerScore > gTCR THEN AttackerScore = gTCR
	COLOR 11: LOCATE 11, y: PRINT "Attack  "; AttackerScore
	LINE (530, 155)-(635, 175), 11, B

	DefenderScore = .013 * gArmySize(defend) + 1
	IF gRealism = 1 THEN 
		DefenderScore = .02 * gArmySize(defend) + 2
		IF DefenderScore > 20 THEN DefenderScore = 20
	END IF
	LOCATE 13, y: PRINT "Defender"
	COLOR 16 - c: LOCATE 14, y: PRINT gArmyName$(defend)
	LOCATE 15, y: CALL CorrectArmySize(defend)
	LOCATE 16, y: PRINT "Base    "; INT(.01 * gArmySize(defend))
	LOCATE 17, y: PRINT "Defense "; DefenderScore
	IF gArmySize(defend) / gArmySize(attack) > .2 THEN
		DefenderScore = DefenderScore + .3 * gArmyCommander(defend) + .3 * gArmyExp(defend)
		IF DefenderScore > gTCR THEN DefenderScore = gTCR
	END IF
	IF gArmyExp(defend) > 8 THEN 
		DefenderScore = DefenderScore + 1
		IF DefenderScore > gTCR THEN DefenderScore = gTCR
	END IF
	LOCATE 18, y: PRINT "Ldr/Exp "; DefenderScore
	IF gArmySize(defend) < 15 THEN DefenderScore = .5 * DefenderScore
	LOCATE 19, y: PRINT "Small   "; DefenderScore

	R! = gArmySize(defend) / gArmySize(attack)
	SELECT CASE R!
		CASE IS > 10
			DefenderScore = gTCR
		CASE IS > 1.5
			DefenderScore = DefenderScore + 2
		CASE IS < .5
			DefenderScore = .8 * DefenderScore
		CASE IS < .2
			DefenderScore = .5 * DefenderScore
	END SELECT
		IF DefenderScore < 1 THEN DefenderScore = 1
		IF DefenderScore > gTCR THEN DefenderScore = gTCR

	LOCATE 20, y: PRINT "Outman  "; DefenderScore
	IF gArmySupply(defend) < 1 THEN 
		DefenderScore = .5 * DefenderScore
		COLOR 13
	END IF
	LOCATE 21, y: PRINT "Supply  "; DefenderScore: COLOR 16 - c
	IF DefenderScore < 1 THEN DefenderScore = 1
	'                       Adjust defend advantage
	IF defend < 21 AND gCurrentSide = 2 AND gDifficultyLevel > 3 THEN 
		DefenderScore = DefenderScore + 2 * gDifficultyLevel - 6
	END IF
	IF defend > 20 AND gCurrentSide = 1 AND gDifficultyLevel < 3 THEN 
		DefenderScore = DefenderScore + 6 - 2 * gDifficultyLevel
	END IF
	LOCATE 22, y: PRINT "Difclt  "; DefenderScore

	someString$ = "Fort"
	IF gArmyMove(defend) = 0 THEN 
		DefenderScore = DefenderScore * (1 + gFortLevel(gArmyLocation(defend)))
	END IF
	IF DefenderScore > gTCR THEN DefenderScore = gTCR
	IF gFortLevel(gArmyLocation(defend)) > 0 AND gArmyMove(defend) = 0 THEN
		COLOR 13: someString$ = "Fort+"
		IF gFortLevel(gArmyLocation(defend)) = 2 THEN someString$ = "Fort++"
	END IF
	LOCATE 23, y: PRINT someString$; TAB(76); DefenderScore
	IF DefenderScore > gTCR THEN DefenderScore = gTCR
	COLOR 11: LOCATE 25, y: PRINT "Defend  "; DefenderScore
	LINE (530, 380)-(635, 400), 11, B

	spin = 0
	scale = AttackerScore
	IF DefenderScore > scale THEN scale = DefenderScore
	scale = scale + 1

	odds! = AttackerScore / (AttackerScore + DefenderScore)
	a = INT(100 * odds!)
	IF a < 1 THEN a = 1
	someString$ = LTRIM$(RTRIM$(STR$(a))) + "%"
	COLOR 14: LOCATE 27, y: PRINT "Odds:  "; someString$;
	LINE (530, 412)-(635, 435), 14, B
	LINE (528, 410)-(637, 437), 14, B
	DO WHILE INKEY$ = "": LOOP
	IF gGraphicLevel > 2 THEN
		CALL DrawCannon
		k = gFortLevel(gArmyLocation(defend))
		anotherString$ = "fort" + LTRIM$(STR$(k)) + ".vga"
		IF _FILEEXISTS(anotherString$) THEN
			DEF SEG = VARSEG(gGraphicImage(1))
			BLOAD anotherString$, VARPTR(gGraphicImage(1))
			DEF SEG
			PUT (550, 270), gGraphicImage, PSET
		END IF
	ELSE
		CALL ClearRight
	END IF
	FOR i = 1 TO 2
		IF gArmySupply(i) > 0 THEN gArmySupply(i) = gArmySupply(i) - 1
	NEXT i
	
	grapple:
	hit = 0: hit1 = 0
	start = scale * RND
	fin = scale * RND
	IF gSoundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	IF start <= AttackerScore THEN hit = 1
	IF fin <= DefenderScore THEN hit1 = 1

	IF hit = 0 AND hit1 = 0 GOTO grapple
	IF hit = 1 AND hit1 = 1 GOTO grapple
	win = defend
	lose = attack
	IF hit = 1 THEN 
		win = attack
		lose = defend
	END IF
	
	IF win > 20 THEN someString$ = "REBEL" ELSE someString$ = "UNION"
	COLOR 14: LOCATE 3, 68: PRINT someString$; " VICTORY"
	LOCATE 4, 71: PRINT "in"
	LOCATE 5, 69: PRINT gCityName$(gArmyLocation(defend))
	IF win > 20 THEN a = 2 ELSE a = 1
	CALL DrawFlags(a, 0, 0)
	CALL ClearBottom
	COLOR 11: PRINT gArmyName$(win); " defeats "; gArmyName$(lose); " in "; gCityName$(gArmyLocation(defend));
	CALL TICK(9)
	
	pct! = .01 * gDEFAC - .03 * gFortLevel(gArmyLocation(defend))
	IF win = attack THEN pct! = 1.3 * pct!
	SELECT CASE gArmySize(defend)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = gArmySize(attack) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, DefendersKilled)
	
	pct! = .01 * gATKFAC + .02 * gFortLevel(gArmyLocation(defend))
	IF win = defend THEN pct! = 1.5 * pct!
	SELECT CASE gArmySize(attack)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = gArmySize(defend) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, AttackersKilled)
	

	AttackersKilled = .8 * AttackersKilled + .2 * DefendersKilled
	IF AttackersKilled < 1 THEN AttackersKilled = 1
	DefendersKilled = .8 * DefendersKilled + .2 * AttackersKilled
	IF DefendersKilled < 1 THEN DefendersKilled = 1
	IF AttackersKilled > 9 * DefendersKilled THEN AttackersKilled = 9 * DefendersKilled
	IF DefendersKilled > 5 * AttackersKilled THEN DefendersKilled = 5 * AttackersKilled

	IF AttackersKilled >= gArmySize(attack) THEN AttackersKilled = gArmySize(attack) - 1
	IF DefendersKilled >= gArmySize(defend) THEN DefendersKilled = gArmySize(defend) - 1
	
	AttackerScore = INT(100 * odds!)
	IF AttackerScore < 1 THEN AttackerScore = 1
	someString$ = LTRIM$(RTRIM$(STR$(AttackerScore))) + "%"

	COLOR c
	LOCATE 1, 1: PRINT "Attack Loss: ";
	PRINT LTRIM$(RTRIM$(STR$(AttackersKilled)) + "00"); "/";
	CALL CorrectArmySize(attack)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (AttackersKilled / gArmySize(attack)))))); "%)";
	COLOR 16 - c: PRINT "Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(DefendersKilled)) + "00"); "/";
	CALL CorrectArmySize(defend)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (DefendersKilled / gArmySize(defend)))))); "%)"
	
	gMenuText$(1) = " (" + LTRIM$(RTRIM$(STR$(AttackersKilled) + "00")) + "/" + LTRIM$(STR$(gArmySize(attack)) + "00") + ") "
	anotherString$ = " (" + LTRIM$(RTRIM$(STR$(DefendersKilled) + "00")) + "/" + LTRIM$(STR$(gArmySize(defend)) + "00") + ")"
	gMenuText$(2) = anotherString$
	IF win = defend THEN 
		gMenuText$(2) = gMenuText$(1)
		gMenuText$(1) = anotherString$
	END IF
	gMenuText$(3) = "*" + gArmyName$(win)
	gMenuText$(4) = gArmyName$(lose)
	IF win = defend THEN 
		gMenuText$(3) = gArmyName$(win)
		gMenuText$(4) = "*" + gArmyName$(lose)
	END IF
	someString$ = gCityName$(gArmyLocation(defend)) + ": " + gMenuText$(3) + gMenuText$(1) + " defeats " + gMenuText$(4) + gMenuText$(2)
	CALL scribe(someString$, 0)

	IF gHumanPlayers = 1 AND (gCurrentSide = 1 AND attack > 20) OR (gCurrentSide = 2 AND attack < 21) THEN
		CALL ClearBottom
		COLOR 14: PRINT "hit any key to continue"; : DO WHILE INKEY$ = "": LOOP
	END IF

	gArmySize(attack) = gArmySize(attack) - AttackersKilled
	gArmySize(defend) = gArmySize(defend) - DefendersKilled
	IF gArmySize(defend) < 1 THEN gArmySize(defend) = 1
	
	IF attack > 2 THEN s = 2 ELSE s = 1
	gCasualty&(s) = gCasualty&(s) + AttackersKilled
	gCasualty&(3 - s) = gCasualty&(3 - s) + DefendersKilled
	
	IF win > 20 THEN s = 2 ELSE s = 1
	gBattleStats(s) = gBattleStats(s) + 1
	gVictoryPoints(s) = gVictoryPoints(s) + 1
	CALL MoveUnitIcon(gArmyLocation(defend), 0, 8)
END SUB

SUB CombineArmies (who%)
	gColour = 3: target = 0: gHighlight = 3
	gTLX = 67: gTLY = 2
	CALL StartToFinish(start, fin, who)
	gMenuRows = 0
	FOR i = 1 TO 40
		IF gCityOwner(i) = who AND gIsOccupied(i) > 0 THEN
			FOR j = start TO fin
				IF gArmyLocation(j) = i AND gIsOccupied(i) <> j AND gArmyMove(j) = 0 THEN 
					gMenuRows = gMenuRows + 1
					gMenuText$(gMenuRows) = gCityName$(i)
					gArray(gMenuRows) = i
					EXIT FOR
				END IF
			NEXT j
		END IF
	NEXT i
		
	IF gMenuRows = 0 THEN who = -1: EXIT SUB
	CALL bubble(gMenuRows)

	IF who <> gCurrentSide THEN 
		gChosenOption = 1 + INT(gMenuRows * RND)
		GOTO join
	END IF
	gMenuText$(0) = "Join"
	gChosenOption = 31: gHighlight = 11
	CALL ShowMenu(9)
	CALL ClearRight
	join:
	IF gChosenOption < 1 THEN EXIT SUB
	target = gArray(gChosenOption)
	CALL ClearBottom
	PRINT "Combining "; gNationName$(who); " armies in "; gCityName$(target);
	CALL TICK(gTurbo!)

	gArmySize(0) = 0
	gArmyCommander(0) = 0
	gArmyExp(0) = 0
	gArmyLocation(0) = target
	gArmyName$(0) = ""
	gArmySupply(0) = 0
	gArmyMove(0) = 0

	best = 0
	x = 0
	spin = 0
	FOR j = start TO fin
		IF gArmyMove(j) <> 0 OR gArmyLocation(j) <> target OR gArmySize(j) = 0 GOTO cannotcombinearmies
		IF gArmySize(0) + gArmySize(j) > 1250 THEN 
			CALL ClearBottom
			PRINT "Cannot combine "; gArmyName$(j); "... TOO LARGE";
			CALL TICK(gTurbo!)
			GOTO cannotcombinearmies
		END IF

		IF gArmyCommander(j) > x THEN
			x = gArmyCommander(j)
			gArmyName$(0) = gArmyName$(j)
			gArmyCommander(0) = gArmyCommander(j)
			best = j
		END IF

		gArmySize(0) = gArmySize(0) + gArmySize(j)
		IF gArmySize(0) < 1 GOTO cannotcombinearmies
		pct! = (gArmySize(j) / gArmySize(0))
		spin = spin + 1
		gArmyExp(0) = (1 - pct!) * gArmyExp(0) + pct! * gArmyExp(j)
		CALL ClearBottom
		PRINT gArmyName$(j); " is combining his "; : CALL CorrectArmySize(j): PRINT " forces";
		CALL TICK(gTurbo!)
		gArmySupply(0) = gArmySupply(0) + gArmySupply(j)
		IF gArmySupply(0) > 10 THEN gArmySupply(0) = 10
		gArmySize(j) = 0
		gArmyLocation(j) = 0
		gArmyExp(j) = 0
		gArmyMove(j) = 0
		gLeaderName$(j) = gArmyName$(j)
		gArmyCommander(j) = 0
		gArmySupply(j) = 0
		gArmyName$(j) = ""
	cannotcombinearmies:
	NEXT j

	CALL ClearBottom
	IF who <> gCurrentSide AND spin = 0 THEN EXIT SUB
	IF spin = 0 THEN
		PRINT "No valid armies to combine at this time in "; gCityName$(target);
		TICK gTurbo!
		EXIT SUB
	END IF
	gArmySize(best) = gArmySize(0)
	gArmyCommander(best) = gArmyCommander(0)
	gArmyExp(best) = gArmyExp(0)
	gArmySupply(best) = gArmySupply(0)
	gArmyLocation(best) = target
	gArmyName$(best) = gArmyName$(0)
	gLeaderName$(best) = ""
	IF spin > 1 THEN
		PRINT "New army "; best; " of "; : CALL CorrectArmySize(best): PRINT " is commanded by "; gArmyName$(best);
		gArmyMove(best) = -1
	ELSE
		PRINT "Only 1 eligible army -- cannot combine at this time";
	END IF
	IF who = gCurrentSide THEN CALL TICK(gTurbo!)
	IF gSoundEffects > 0 THEN SOUND 4000, .7
			
	CALL DrawCities
	CALL DrawArmyUnit(best)
	CALL MoveUnitIcon(target, 0, 6)
	gIsOccupied(target) = best
	CALL stax(who)
END SUB

SUB cutoff (who%, target%, a%)
	a = 0
	FOR j = 1 TO 6
		y = gMatrix(target, j)
		IF y > 0 AND gCityOwner(y) = who THEN a = a + 1
	NEXT j
END SUB

SUB FileManager (switch%)
	SELECT CASE switch
		CASE 1
			OPEN "I", 1, "cwslead.dat"
			FOR i = 1 TO 40: INPUT #1, gLeaderName$(i), gLeaderRating(i): NEXT i
			CLOSE #1
			OPEN "I", 1, "cws.ini"
			FOR i = 0 TO 2: INPUT #1, gNationName$(i): NEXT i
			FOR i = 1 TO 12: INPUT #1, gMonthes$(i): NEXT i
			INPUT #1, gCurrentMonth, gCurrentYear
			'               set end game conditions
			FOR i = 1 TO 6: INPUT #1, gVictoryFlags(i): NEXT i
			gVictoryFlags(3) = .4 * gVictoryFlags(3)
			INPUT #1, a             ' number of Yankee armies
			FOR i = 1 TO a
				INPUT #1, gArmyLocation(i), gArmySize(i), gArmyExp(i), gArmySupply(i): gIsOccupied(gArmyLocation(i)) = i: gArmyName$(i) = gLeaderName$(i): gArmyCommander(i) = gLeaderRating(i): gLeaderName$(i) = ""
			NEXT i
			INPUT #1, a             ' number of Rebel armies
			FOR i = 21 TO 20 + a
				INPUT #1, gArmyLocation(i), gArmySize(i), gArmyExp(i), gArmySupply(i)
				gIsOccupied(gArmyLocation(i)) = i: gArmyName$(i) = gLeaderName$(i): gArmyCommander(i) = gLeaderRating(i): gLeaderName$(i) = ""
			NEXT i
			FOR i = 1 TO 2: INPUT #1, gCurrentCash(i): NEXT i
			INPUT #1, gATKFAC, gDEFAC, gTCR
			INPUT #1, gFleet$(1), gNavyLocation(1), gFleet$(2), gNavyLocation(2)
			FOR k = 1 TO 2: gNavySize(k) = LEN(gFleet$(k)): NEXT k
			INPUT #1, gCapitalCity(1), gCapitalCity(2)

			FOR i = 1 TO 8: INPUT #1, gStarX(i), gStarY(i): NEXT i  ' star locations on flag
			CLOSE #1
			OPEN "I", 1, "cws.cfg"
			INPUT #1, gCurrentSide, gGraphicLevel, gSoundEffects, gDifficultyLevel, gHumanPlayers, gTurbo!, gEventsBalance, gTrainCapacity(1), gTrainCapacity(2), gJanuaryCampaign, gRealism, gBattleStats(1), gBattleStats(2), gCasualty&(1), gCasualty&(2), gHistory, gAIBoldness
			CLOSE #1
		CASE 2
			IF _FILEEXISTS("*.sav") = 0 THEN gChosenOption = -1: EXIT SUB
			gMenuText$(0) = "Load"
			gMenuRows = 0
			FOR k = 1 TO 9
				anotherString$ = "cws" + LTRIM$(STR$(k)) + ".sav"
				IF _FILEEXISTS(anotherString$) THEN
					gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = anotherString$: gArray(gMenuRows) = k
				END IF
			NEXT k
			CALL bubble((gMenuRows))
			gTLX = 67: gTLY = 14 - .5 * gMenuRows
			CALL ShowMenu(0)
			CALL ClearRight
			IF gChosenOption < 1 THEN EXIT SUB
			OPEN "I", 1, "cws" + LTRIM$(STR$(gArray(gChosenOption))) + ".sav"
			CALL ClearBottom
			COLOR 11: PRINT "Loading";
			INPUT #1, gCurrentMonth, gCurrentYear, gUSAdvantage, a
			FOR i = 1 TO 40: INPUT #1, gArmyName$(i), gArmySize(i), gArmyCommander(i), gArmyLocation(i), gArmyExp(i), gArmySupply(i), gArmyMove(i)
			IF gArmyLocation(i) > 0 THEN
				IF gArmyName$(i) = gLeaderName$(i) THEN
					gLeaderName$(i) = ""
				ELSE
					IF i > 20 THEN who = 2 ELSE who = 1
					CALL StartToFinish(start, fin, who)
					FOR k = start TO fin
					IF gArmyName$(i) = gLeaderName$(k) THEN gLeaderName$(k) = "": EXIT FOR
					NEXT k
				END IF
			END IF
			NEXT i
			FOR i = 1 TO 40: INPUT #1, gIsOccupied(i), gCityOwner(i), gFortLevel(i): PRINT "."; : NEXT i
			FOR i = 1 TO 2: INPUT #1, gCurrentCash(i), gCityController(i), gCurrentIncome(i), gVictoryPoints(i), gCapitalCity(i)
			INPUT #1, gFleet$(i), gNavyLocation(i), gNavyMove(i), gRR(i), gArmyOnRailroad(i)
			gNavySize(i) = LEN(gFleet$(i))
			NEXT i
			
			CLOSE #1
			OPEN "I", 1, "cws.cfg"
			INPUT #1, playersSide, gGraphicLevel, gSoundEffects, gDifficultyLevel, gHumanPlayers, gTurbo!, gEventsBalance, gTrainCapacity(1), gTrainCapacity(2), gJanuaryCampaign, gRealism, gBattleStats(1), gBattleStats(2), gCasualty&(1), gCasualty&(2), gHistory, gAIBoldness
			CLOSE #1
			SCREEN 12: CLS
			CLOSE #1
			CALL DrawMap
			CALL ClearBottom
			FOR k = 1 TO 2
			IF gRR(k) > 0 THEN CALL tinytrain(k, 1)
			NEXT k
			gCurrentSide = a
		CASE 3
			gMenuText$(0) = "Save Game"
			FOR k = 1 TO 9
			gMenuText$(k) = "cws" + LTRIM$(STR$(k)) + ".sav"
			IF _FILEEXISTS(gMenuText$(k)) THEN gMenuText$(k) = gMenuText$(k) + " +"
			NEXT k
			gTLX = 67: gMenuRows = 9
			CALL ShowMenu(0)
			IF gChosenOption < 1 THEN ClearRight: EXIT SUB
			CALL ClearBottom
			COLOR 11: PRINT "Saving";

			OPEN "O", 1, "cws" + LTRIM$(STR$(gChosenOption)) + ".sav"
			WRITE #1, gCurrentMonth, gCurrentYear, gUSAdvantage, gCurrentSide
			FOR i = 1 TO 40: WRITE #1, gArmyName$(i), gArmySize(i), gArmyCommander(i), gArmyLocation(i), gArmyExp(i), gArmySupply(i), gArmyMove(i)
			NEXT i
			FOR i = 1 TO 40: WRITE #1, gIsOccupied(i), gCityOwner(i), gFortLevel(i): PRINT "."; : NEXT i
			FOR i = 1 TO 2: WRITE #1, gCurrentCash(i), gCityController(i), gCurrentIncome(i), gVictoryPoints(i), gCapitalCity(i)
			WRITE #1, gFleet$(i), gNavyLocation(i), gNavyMove(i), gRR(i), gArmyOnRailroad(i)
			NEXT i
			CLOSE #1
			
			playersSide = gCurrentSide
			IF playersSide < 1 OR playersSide > 2 THEN playersSide = 1
			OPEN "O", 1, "cws.cfg"
			WRITE #1, playersSide, gGraphicLevel, gSoundEffects, gDifficultyLevel, gHumanPlayers, gTurbo!, gEventsBalance, gTrainCapacity(1), gTrainCapacity(2), gJanuaryCampaign, gRealism, gBattleStats(1), gBattleStats(2), gCasualty&(1), gCasualty&(2), gHistory, gAIBoldness
			CLOSE #1
			CLS : CALL DrawMap
	END SELECT
END SUB

SUB FortifyCity (target%)
	target = 0: gHighlight = 11
	gTLX = 67: gTLY = 2
	who = gCurrentSide
	CALL StartToFinish(start, fin, who)
	gMenuRows = 0
	FOR i = start TO fin
	IF gArmyLocation(i) > 0 AND gFortLevel(gArmyLocation(i)) < 2 THEN
		gMenuRows = gMenuRows + 1
		gMenuText$(gMenuRows) = gCityName$(gArmyLocation(i))
		gArray(gMenuRows) = gArmyLocation(i)
	END IF
	NEXT i
	IF gMenuRows = 0 THEN CALL ClearBottom: COLOR 11: PRINT "No cities eligible to fortify"; : EXIT SUB
	CALL bubble(gMenuRows)
	gMenuText$(0) = "Fortify"
		gChosenOption = 31
		CALL ShowMenu(9): CALL ClearRight
		IF gChosenOption < 0 THEN EXIT SUB
		target = gArray(gChosenOption): CALL occupy(target): x = gIsOccupied(target): IF x < 0 THEN EXIT SUB
		IF gFortLevel(target) > 1 THEN CALL ClearBottom: PRINT gCityName$(target); " at MAXIMUM fortification level of 2"; : CALL TICK(4): EXIT SUB
		cost = 200
		IF gCurrentCash(gCurrentSide) < cost THEN CALL ClearBottom: PRINT "Fortifications for "; gCityName$(target); " cost "; cost; " and you only have "; gCurrentCash(gCurrentSide); : CALL TICK(4): EXIT SUB
		COLOR 3
		gFortLevel(target) = gFortLevel(target) + 1
		gCurrentCash(gCurrentSide) = gCurrentCash(gCurrentSide) - cost
		CALL ClearBottom: PRINT gCityName$(target); " fortifications increased to "; gFortLevel(target);
		CALL MoveUnitIcon(target, 0, 6)
		CALL DrawCities
		IF gArmyMove(x) > 0 THEN CALL MoveUnitIcon(gArmyLocation(x), gArmyMove(x), 5)
		gArmyMove(x) = -1
		CALL DrawArmyUnit(x)
		CALL stax(who)
END SUB

SUB MoveUnitIcon (from%, dest%, kind%)
	IF from < 1 OR from > 40 THEN EXIT SUB
	IF dest < 0 THEN EXIT SUB
	IF from = 999 THEN EXIT SUB
	x = gCityX(from) - 12: y = gCityY(from) - 11
	x1 = gCityX(dest): y1 = gCityY(dest)
	SELECT CASE kind
		CASE 1
		LINE (x, y)-(x1, y1), 15, , &HF0F0
		
		CASE 2
		FOR i = 6 TO 8
		LINE (x - i, y - i + 3)-(x + i, y + i - 3), 14, B
		NEXT i
		CALL TICK(.1)
		
		CASE 3
		x = gCityX(from): y = gCityY(from)
		CALL snapshot(x, y, 0)
		FOR j = 1 TO 3
		FOR i = 4 TO 10 STEP 1
		CIRCLE (x, y), i, 4
		PAINT (x, y), 14, 4
		IF gSoundEffects > 0 THEN SOUND 37 + 50 * RND, .03
		NEXT i
		CALL TICK(.1)
		CALL snapshot(x, y, 1)
		NEXT j
		
		CASE 4
		IF gIsOccupied(from) = 0 THEN LINE (x - 8, y - 6)-(x + 10, y + 8), 2, BF
		IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
		IF from = 27 OR from = 28 THEN CALL TouchupMap

		CASE 5
		IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0

		CASE 6
		x = gCityX(from): y = gCityY(from)
		CALL snapshot(x, y, 0)
		LINE (x - 9, y - 9)-(x + 9, y + 9), 15, B
		LINE (x - 10, y - 10)-(x + 10, y + 10), 15, B
		IF gSoundEffects > 0 THEN SOUND 3999, .3
		CALL TICK(gTurbo! - .5)
		CALL snapshot(x, y, 1)
		CASE 7          ' draw white box
		x = gCityX(from) - 12: y = gCityY(from) - 11
		GET (x - 8, y - 8)-(x + 8, y + 8), gGraphicImage
		LINE (x - 7, y - 7)-(x + 7, y + 7), 15, B
		LINE (x - 8, y - 6)-(x + 8, y + 6), 15, B
			CASE 8     ' replace old image
		x = gCityX(from) - 12: y = gCityY(from) - 11
		IF x > 0 THEN PUT (x - 8, y - 8), gGraphicImage, PSET
		
		CASE 9          ' draw arrow pointer
		x = gCityX(from) - 12: y = gCityY(from) - 11
		GET (x - 8, y - 8)-(x + 10, y + 7), gGraphicImage
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
	FOR i = 1 TO 40
		IF gArmyLocation(i) > 0 THEN CALL DrawArmyUnit(i)
	NEXT i

	gCurrentMonth = gCurrentMonth + 2
	IF gCurrentMonth > 12 THEN 
		gCurrentMonth = 1
		gCurrentYear = gCurrentYear + 1
	END IF

	s = 1
	FOR i = 1 TO 40
		IF gArmyLocation(i) < 1 GOTO skiparmy
		IF i > 20 THEN s = 2
		IF gCurrentCash(s) >= .2 * gArmySize(i) THEN
			a = 1
			IF gRealism > 0 THEN CALL cutoff(s, gArmyLocation(i), a)
			IF a > 0 THEN
				gArmySupply(i) = gArmySupply(i) + 1
				gCurrentCash(s) = gCurrentCash(s) - .2 * gArmySize(i)
			END IF
		END IF
	IF (gCurrentMonth < 7 OR gCurrentMonth > 10) AND gMatrix(gArmyLocation(i), 7) < 99 THEN 
		gArmySupply(i) = gArmySupply(i) - 1
	END IF
	IF gMatrix(gArmyLocation(i), 7) = 99 AND gNavyLocation(3 - s) = gArmyLocation(i) THEN 
		gArmySupply(i) = gArmySupply(i) - 1: CALL ClearBottom: PRINT gArmyName$(i); " is blockaded";
		CALL TICK(gTurbo!)
	END IF
	COLOR 13
	IF gArmySupply(i) < 1 THEN
		gArmySupply(i) = 0
		CALL ClearBottom
		PRINT gArmyName$(i); " is out of supplies";
		CALL DrawArmyUnit(i)
		CALL TICK(gTurbo!)
		IF RND > .8 AND gArmySize(i) > 50 THEN gArmySize(i) = .9 * gArmySize(i)
	END IF
	skiparmy:
	NEXT i
	FOR k = 1 TO 2
		CALL stax(k)
		NEXT k
	y = 0
	FOR i = 1 TO 20
		y = y + .1 * gArmySize(i)
	NEXT i
	x = 0
	FOR i = 21 TO 40
		x = x + .1 * gArmySize(i)
	NEXT i
	IF gCurrentSide = 2 AND x > 0 THEN gAggress! = y / x ELSE gAggress! = 1
	IF gCurrentSide = 1 AND y > 0 THEN gAggress! = x / y ELSE IF gCurrentSide = 1 THEN gAggress! = 1
END SUB

SUB MoveFrom (index%, target%)
	gColour = 3: gTLX = 67: gTLY = 5: index = 0: gMenuRows = 0: target = 0
	who = gCurrentSide: CALL StartToFinish(start, fin, who)
	FOR i = start TO fin
	IF gArmyLocation(i) > 0 AND gArmyMove(i) = 0 THEN gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = gCityName$(gArmyLocation(i)): gArray(gMenuRows) = gArmyLocation(i)
	NEXT i
	IF gMenuRows = 0 THEN index = -1: EXIT SUB
	gMenuText$(0) = "From"
	CALL bubble(gMenuRows)
	gTLX = 67: gTLY = 5
		gHighlight = 15: CALL ShowMenu(1): CALL ClearRight
		IF gChosenOption < 0 THEN target = 0: EXIT SUB
		target = gArray(gChosenOption)

		gMenuRows = 0
		FOR i = start TO fin
		IF gArmyLocation(i) = target AND gArmyMove(i) = 0 THEN index = i: gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = "Army" + STR$(i): gArray(gMenuRows) = i
		NEXT i
		IF gMenuRows = 1 THEN EXIT SUB
		gMenuText$(0) = "Which"
		CALL bubble(gMenuRows)
		gTLX = 67: gTLY = 15: CALL ShowMenu(4): CALL ClearRight
		IF gChosenOption < 0 THEN index = 0: EXIT SUB
		index = gArray(gChosenOption)
END SUB

SUB ManageNavy (who%, chx%)
	DIM hit(2)
	IF chx > 0 THEN
		IF gNavyLocation(who) < 1 THEN
			chx = 1
		ELSE
			IF gNavalCommerce = 3 - who AND gNavalRaider > 0 THEN chx = 4
			IF gGrudge > 0 THEN chx = 3
		END IF
	END IF
	COLOR 11
	labelmanagenavy:
	cost = 100: gCityOwner(0) = who
	IF chx = 0 THEN CALL ClearBottom: PRINT "Funds available "; gCurrentCash(who);
	IF chx = 1 THEN
		IF gCurrentCash(who) < cost THEN EXIT SUB
		IF gNavySize(who) > 9 THEN EXIT SUB
	END IF
	gMenuText$(0) = "Ships"
	gMenuText$(1) = "Build"
	IF gNavyLocation(who) <> 99 THEN
	IF gCurrentCash(who) < cost OR gNavySize(who) > 9 OR gCityOwner(gNavyLocation(who)) <> who THEN gMenuText$(1) = "-": gChosenOption = 23
	END IF
	gMenuText$(2) = "Attack"
	IF gNavyLocation(who) <> 99 THEN
	IF gCityOwner(gNavyLocation(who)) <> 3 - who THEN gMenuText$(2) = "-": gChosenOption = 22
	ELSE
	gMenuText$(1) = "-": gMenuText$(2) = "-": gChosenOption = 24
	END IF
	gMenuText$(3) = "Sail": IF gNavyLocation(who) < 1 THEN gMenuText$(3) = "-": IF chx = 3 THEN chx = 1
	gMenuText$(4) = "Raid": IF gNavySize(who) < 1 OR gNavalCommerce = who THEN gMenuText$(4) = "-"
	gTLX = 67: gTLY = 12: gMenuRows = 4
	IF gNavyLocation(who) <> 99 THEN
	IF who = 1 AND gNavySize(who) > 1 AND gCityOwner(gNavyLocation(who)) = 0 THEN gMenuRows = 5: gMenuText$(5) = "Invasion": CALL void(gNavyLocation(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
	IF gRealism = 0 AND who = 2 AND gNavySize(who) > 1 AND gCityOwner(gNavyLocation(who)) = 0 THEN gMenuRows = 5: gMenuText$(5) = "Invasion": CALL void(gNavyLocation(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
	END IF

	IF chx > 0 THEN gChosenOption = chx: GOTO anchor
	IF gHasNavy > 0 AND gChosenOption <> 1 THEN EXIT SUB
	CALL ShowMenu(0): CALL ClearRight
	anchor:
	'---------------------------------------------------------------------------
	SELECT CASE gChosenOption
	'---------------------------------------------------------------------------
	'                               Build Ship
	'---------------------------------------------------------------------------
		CASE 1
		IF gCurrentCash(who) < cost OR gNavyLocation(who) = 99 GOTO labelmanagenavy
		IF chx = 1 AND gNavySize(who) > 9 THEN EXIT SUB
		IF chx = 0 AND gNavySize(who) > 9 THEN GOTO labelmanagenavy

		IF chx = 0 AND gNavyLocation(who) > 0 THEN
			IF gCityOwner(gNavyLocation(who)) <> who GOTO labelmanagenavy
			IF gMatrix(gNavyLocation(who), 7) < 99 GOTO labelmanagenavy
		END IF
		IF chx = 1 AND RND < .07 * gNavySize(who) THEN EXIT SUB
		someString$ = "W"

		IF gRealism > 0 AND ((gCurrentYear < 1862) OR (gCurrentYear = 1862 AND gCurrentMonth < 3)) GOTO noiron
		IF gCurrentCash(who) >= 2 * cost THEN
			gTLX = 67: gTLY = 12: gColour = 9
			IF who = gCurrentSide THEN
				gMenuText$(0) = "Type"
				gMenuText$(1) = "Wooden"
				gMenuText$(2) = "Ironclad"
				gMenuRows = 2
				CALL ShowMenu(0)
				CALL ClearRight
				IF gChosenOption < 1 GOTO labelmanagenavy
				IF gChosenOption = 2 THEN someString$ = "I": cost = 2 * cost
			ELSE
				someString$ = "I"
			END IF
		END IF

	noiron:
		gNavySize(who) = gNavySize(who) + 1
		IF someString$ = "W" THEN
			gFleet$(who) = gFleet$(who) + someString$: a = 1
		ELSE
			gFleet$(who) = someString$ + gFleet$(who): a = 2
		END IF
		IF gNavySize(who) > 1 GOTO add2ship
	ships:
		gMenuText$(0) = "Port": gMenuRows = 0: gTLX = 67: gTLY = 12
		FOR i = 1 TO 40: IF gMatrix(i, 7) = 99 AND gCityOwner(i) = who AND gNavyLocation(3 - who) <> i THEN gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = gCityName$(i): gArray(gMenuRows) = i
		NEXT i
		IF chx = 1 THEN gChosenOption = 1 + INT(gMenuRows * RND)
		IF gMenuRows < 1 THEN
			gNavySize(who) = 0: gFleet$(who) = ""
			IF chx = 0 THEN CALL ClearBottom: PRINT "NO SHIPYARDS AVAILABLE !"; : EXIT SUB
			IF chx = 1 THEN EXIT SUB
		END IF
		IF chx = 0 THEN CALL ShowMenu(9): CALL ClearRight

		IF gChosenOption < 1 GOTO ships
		gNavyLocation(who) = gArray(gChosenOption)
		gCurrentCash(who) = gCurrentCash(who) - cost: gNavySize(who) = 1
		x = gCityX(gArray(gChosenOption)) + 25: y = gCityY(gArray(gChosenOption)) + 25: CALL ships
		CALL ClearBottom: COLOR 11: PRINT gNationName$(who); " is building NEW fleet in "; gCityName$(gArray(gChosenOption));
		PSET (400, 465), 0: CALL DrawShipIcon(who, a)
		IF gSoundEffects > 0 THEN SOUND 3000, 1
		CALL TICK(gTurbo!)
		GOTO labelmanagenavy
	add2ship:
		gCurrentCash(who) = gCurrentCash(who) - cost
		CALL ClearBottom: PRINT gNationName$(who); " navy increased to "; gNavySize(who);
		PSET (400, 465), 0: CALL DrawShipIcon(who, a)
		CALL ships
		IF gSoundEffects > 0 THEN SOUND 3000, 1
		CALL TICK(gTurbo!)
	'---------------------------------------------------------------------------
	'                               Attack City
	'---------------------------------------------------------------------------
		CASE 2
		IF gNavyLocation(who) = 99 GOTO labelmanagenavy
		IF chx = 2 AND gCityOwner(gNavyLocation(who)) = who THEN EXIT SUB
		IF chx = 2 AND gIsOccupied(gNavyLocation(who)) > 0 AND RND > .5 THEN chx = 3: GOTO anchor
		IF chx = 2 AND gCityOwner(gNavyLocation(who)) = 0 THEN chx = 3: GOTO labelmanagenavy
		IF gNavyLocation(who) < 1 THEN EXIT SUB
		IF who = gCurrentSide THEN gHasNavy = 1
		IF gCityOwner(gNavyLocation(who)) <> 3 - who GOTO labelmanagenavy
		CALL ClearBottom: COLOR 12: PRINT gNationName$(who); " fleet bombards "; gCityName$(gNavyLocation(who));
		CALL MoveUnitIcon(gNavyLocation(who), 0, 3)
			
		target = gNavyLocation(who): index = gIsOccupied(target): IF index = 0 GOTO deserted
		pct! = .005 * gNavySize(who) + .02 * RND: DefendersKilled = gArmySize(index) * pct!: IF DefendersKilled < 1 THEN DefendersKilled = 1
		CALL ClearBottom: PRINT gArmyName$(index); " suffered "; 100 * DefendersKilled; " casualties";
		x = .5 * gNavySize(who) + 1: IF x > gArmySupply(index) THEN x = gArmySupply(index)
		gArmySupply(index) = gArmySupply(index) - x
		CALL TICK(gTurbo!)
		gArmySize(index) = gArmySize(index) - DefendersKilled: IF gArmySize(index) < 1 THEN gArmySize(index) = 1
		EXIT SUB
	deserted:
		IF gFortLevel(target) = 0 GOTO bombardcity
		IF RND < .7 + .03 * (gNavySize(who) - gFortLevel(target)) GOTO damagedfortifications
		CALL ShipDestroyed(who)
		CALL ClearBottom
		PRINT gNationName$(gCityOwner(target)); " shore battery sunk an attacking ship!"; gNavySize(who); "ship(s) left! ";
		IF gSoundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5
		CALL TICK(gTurbo!)
		IF gNavySize(who) < 1 THEN
			gNavyLocation(who) = 0: gFleet$(who) = "": GOSUB box2
			LOCATE 12, 27: PRINT gNationName$(who); " fleet eliminated"
			CALL TICK(9)
			gVictoryPoints(3 - who) = gVictoryPoints(3 - who) + 5
			IF who = gCurrentSide THEN gGrudge = 0
			GOTO sail3
		END IF
		GOTO deserted
	damagedfortifications:
		CALL ClearBottom: PRINT gCityName$(target); " fortifications damaged";
		gFortLevel(target) = gFortLevel(target) - 1: x = gCityX(target): y = gCityY(target): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
		CALL DrawCities
		CALL TICK(gTurbo!)
		EXIT SUB
	bombardcity:
		IF RND > .25 + .07 * gNavySize(who) THEN CALL ClearBottom: PRINT "Citizens of "; gCityName$(target); " stand firm against the attack"; : CALL TICK(gTurbo!): EXIT SUB
		IF gNavyLocation(who) = gCapitalCity(3 - who) THEN CALL ClearBottom: PRINT "The CAPITAL steadfastly stands loyal"; : CALL TICK(gTurbo!): EXIT SUB
		gCityOwner(gNavyLocation(who)) = 0
		CALL ClearBottom: PRINT gCityName$(gNavyLocation(who)); " is now  NEUTRAL";
		CALL DrawCities
		gVictoryPoints(who) = gVictoryPoints(who) + gCityValue(gNavyLocation(who))
		EXIT SUB
	'---------------------------------------------------------------------------
	'                               Sail
	'---------------------------------------------------------------------------
		CASE 3
		gNavySize(who) = LEN(gFleet$(who))
		IF gNavySize(who) < 1 AND chx > 0 THEN EXIT SUB
		IF gNavyLocation(who) < 1 OR gNavySize(who) < 1 THEN CALL ClearBottom: PRINT "No ships remain"; : TICK 1: GOTO labelmanagenavy

		gMenuRows = 0
		FOR i = 1 TO 40: IF gMatrix(i, 7) > 90 AND gNavyLocation(who) <> i THEN gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = gCityName$(i): gArray(gMenuRows) = i
		NEXT i
		IF chx = 3 THEN
			IF gMenuRows = 0 THEN EXIT SUB
			IF gGrudge > 0 THEN gChosenOption = 1: gArray(1) = gNavyLocation(3 - who): GOTO admiral
			GOSUB nest: IF gChosenOption > 0 GOTO admiral ELSE EXIT SUB
		END IF
		COLOR 11: LOCATE 11, 68
		IF gNavyLocation(who) < 41 THEN
			PRINT gCityName$(gNavyLocation(who))
		ELSE
			PRINT "Raiding"
		END IF
		gMenuText$(0) = "To"
		gColour = 3: gTLX = 67: gTLY = 12
		
		CALL ShowMenu(9): CALL ClearRight: IF gChosenOption < 1 THEN EXIT SUB
	admiral:
		IF gArray(gChosenOption) = gNavyLocation(who) THEN EXIT SUB
		IF gArray(gChosenOption) < 1 THEN EXIT SUB
		IF gNavySize(who) < 1 GOTO ships
		IF who = gCurrentSide THEN gHasNavy = 1
		GOSUB box2
		LOCATE 10, 25: PRINT gNationName$(who); " fleet of"; gNavySize(who); "ship(s) is sailing"
		LOCATE 11, 25: PRINT "From ";
		IF gNavyLocation(who) < 41 THEN
			PRINT gCityName$(gNavyLocation(who));
		ELSE
			PRINT "Raiding";
		END IF
		PRINT " to ";
		IF gArray(gChosenOption) <> 99 THEN
			PRINT gCityName$(gArray(gChosenOption));
		ELSE
			PRINT "Raid Commerce";
		END IF

		FOR i = 1 TO gNavySize(who)
			PSET (120 + 41 * i, 210), 0
			CALL ShipType(who, i)
		NEXT i
		IF gGraphicLevel > 2 THEN
			a = ASC(LEFT$(gFleet$(who), 1))
			SELECT CASE a
				CASE 73
					CALL DrawIronclad
				CASE 87
					CALL DrawSchooner
			END SELECT
			TICK 2 * gTurbo!
		ELSE
			TICK gTurbo!
		END IF
		gNavyLocation(who) = gArray(gChosenOption)
		IF gNavyLocation(1) = gNavyLocation(2) GOTO navalbattle
		GOTO sail3
	'---------------------------------------------------------------------------
	'                               Raid Commerce
	'---------------------------------------------------------------------------
		CASE 4
		gNavySize(who) = LEN(gFleet$(who))
		IF gNavySize(who) < 1 AND chx > 0 THEN EXIT SUB
		IF gNavySize(who) < 1 OR gNavalCommerce = who GOTO labelmanagenavy

		IF who = gCurrentSide THEN gHasNavy = 1
		GOSUB box2
		LOCATE 10, 25: PRINT gNationName$(who); " fleet of"; gNavySize(who); "ship(s) is sailing"
		LOCATE 11, 25: PRINT "to RAID "; gNationName$(3 - who); " COMMERCE !"

		FOR i = 1 TO gNavySize(who)
			PSET (120 + 41 * i, 210), 0
			CALL ShipType(who, i)
		NEXT i
		IF gGraphicLevel > 2 THEN
			a = ASC(LEFT$(gFleet$(who), 1))
			SELECT CASE a
				CASE 73
					CALL DrawIronclad
				CASE 87
					CALL DrawSchooner
			END SELECT
			TICK 2 * gTurbo!
		ELSE
			TICK gTurbo!
		END IF
		gNavyLocation(who) = 99: gNavalCommerce = who
		IF gNavyLocation(1) = gNavyLocation(2) GOTO navalbattle
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
		c = gNavyLocation(who): CALL CreateNewArmy((who), empty, c)
		gCurrentCash(who) = gCurrentCash(who) + 100     'compensate for cost of recruiting new army
		CALL DrawCityCaptured(empty, c, who, 0)
		gArmySize(empty) = x
		IF who = gCurrentSide THEN gHasNavy = 1
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
		IF RIGHT$(gFleet$(k), 1) = "I" THEN hit(k) = 20
		NEXT k
	drawnavalbattle:
		LOCATE 9, 1: PRINT SPACE$(79)
		LOCATE 15, 1: PRINT SPACE$(79)
		x = 10: y = 100
		COLOR 9: LOCATE 5, 25: PRINT "UNION"; gNavySize(1); "ship(s)"
		GOSUB boxes
		COLOR 1
		FOR i = 1 TO gNavySize(1)
		x = x + 50: PSET (x, y)
		CALL ShipType(1, i)
		NEXT i
		COLOR 11: LOCATE 11, 22: PRINT "CONFEDERATES "; gNavySize(2); "ship(s)"
		LINE (10, 180)-(530, 210), 1, BF
		LINE (10, 180)-(530, 210), 11, B
		x = 10: y = 200
		COLOR 1
		FOR i = 1 TO gNavySize(2)
		x = x + 50: PSET (x, y)
		CALL ShipType(2, i)
		NEXT i
		COLOR 11
	navalbattleoptions:
		gMenuText$(0) = "Options"
		gMenuText$(1) = "Attack"
		gMenuText$(2) = "Retreat"
		IF chx > 0 THEN gChosenOption = 1: GOTO powder
		
		gMenuRows = 2: gColour = 3: gHighlight = 14: gTLX = 50: gTLY = 18: CALL ShowMenu(0)
	powder:
		SELECT CASE gChosenOption
		CASE 1
	firemore:
		IF gSoundEffects > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
		pct! = 0: someString$ = RIGHT$(gFleet$(who), 1)
		IF someString$ <> RIGHT$(gFleet$(3 - who), 1) THEN
			IF someString$ = "I" THEN pct! = .1 ELSE pct! = -.1
		END IF
		IF RND <= .5 + pct! GOTO hitem ELSE GOTO hitme1
		GOTO firemore
	hitem:
		hit(3 - who) = hit(3 - who) - 1: GOSUB showhit: IF hit(3 - who) > 0 GOTO firemore
		x = 10 + 50 * gNavySize(3 - who)
		y = 90: IF who = 1 THEN y = 190
		GOSUB xout
		LOCATE 17, 5: PRINT gNationName$(3 - who); " ship SUNK!": CALL TICK(gTurbo! + 1): GOSUB clr1
		CALL ShipDestroyed(3 - who)
		IF gNavySize(3 - who) < 1 THEN
			LOCATE 19, 5: COLOR 12
			PRINT gNationName$(3 - who); " fleet DEFEATED"
			CALL TICK(gTurbo!)
			gNavyLocation(3 - who) = 0: gFleet$(3 - who) = ""
			gVictoryPoints(3 - who) = gVictoryPoints(3 - who) + 10
			IF who = gCurrentSide THEN gGrudge = 1 ELSE gGrudge = 0
			GOTO sail3
		END IF
		hit(3 - who) = 10
		IF RIGHT$(gFleet$(3 - who), 1) = "I" THEN hit(3 - who) = 20
		GOTO drawnavalbattle
	hitme1:
		hit(who) = hit(who) - 1: GOSUB showhit: IF hit(who) > 0 GOTO firemore
		x = 10 + 50 * gNavySize(who)
		y = 190: IF who = 1 THEN y = 90
		GOSUB xout
		LOCATE 17, 5: PRINT "One of the "; gNationName$(who); " ships was SUNK!": CALL TICK(gTurbo!): GOSUB clr1
		CALL ShipDestroyed(who)
		IF gNavySize(who) < 1 THEN
			LOCATE 19, 5: COLOR 12
			PRINT "Attacking "; gNationName$(who); " fleet has been ELIMINATED !"
			CALL TICK(gTurbo!)
			gNavyLocation(who) = 0: gFleet$(who) = ""
			gVictoryPoints(who) = gVictoryPoints(who) + 10
			IF who <> gCurrentSide THEN gGrudge = 1 ELSE gGrudge = 0
			GOTO sail3
		END IF
		hit(who) = 10
		IF RIGHT$(gFleet$(who), 1) = "I" THEN hit(who) = 20
		GOTO drawnavalbattle

		CASE 2
		target = 0
		FOR i = 1 TO 40
		IF gCityOwner(i) = who THEN IF i <> gNavyLocation(who) AND gMatrix(i, 7) = 99 THEN target = i: IF RND > .3 GOTO found1
		NEXT i
	found1:
		CALL ClearBottom: COLOR 11: PRINT gNationName$(who); " is retreating to "; gCityName$(target); : CALL TICK(gTurbo!)
		gNavyLocation(who) = target
		GOTO sail3
		CASE ELSE
		GOTO navalbattleoptions
		END SELECT
		GOTO navalbattle
	'---------------------------------------------------------------------------
	'                               Subs
	'---------------------------------------------------------------------------
	showhit:
		LOCATE 9, 6 * gNavySize(1): PRINT hit(1); " ";
		LOCATE 15, 6 * gNavySize(2): PRINT hit(2); " ";
		IF gSoundEffects = 0 THEN TICK .1 * gTurbo!
		RETURN
	clr1:
		LOCATE 17, 1: PRINT SPACE$(60): RETURN
	nest:
		best = 0: x = 0
		FOR i = 1 TO gMenuRows
		target = gArray(i)
		IF gCityOwner(target) = 0 GOTO neutral

		IF target = gNavyLocation(3 - who) THEN IF gNavySize(who) >= gNavySize(3 - who) AND RND > .1 THEN gChosenOption = i: RETURN
		IF gCityOwner(target) <> who THEN
			best = i: x = x + 1
			IF RND > .8 THEN gChosenOption = best: RETURN
		END IF
	neutral:
		NEXT i
		IF best = 0 THEN
			gChosenOption = 1 + INT(RND * gMenuRows)
		ELSE
			gChosenOption = best
		END IF

		IF who = 2 AND gNavyLocation(2) = 30 THEN IF RND > .5 THEN gChosenOption = 30: RETURN
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
		gNavalCommerce = 0
		FOR k = 1 TO 2
		IF gNavyLocation(k) = 99 THEN gNavalCommerce = k
		NEXT k
		CLS : CALL DrawMap
END SUB

SUB CreateNewArmy (who%, empty%, target%)
	gArmySupply(empty) = 3 + 5 * RND: IF who = 1 THEN gArmySupply(empty) = gArmySupply(empty) + 2
	gArmyExp(empty) = 1: IF who = 2 THEN gArmyExp(empty) = 2
	gArmyCommander(empty) = gLeaderRating(empty)
	gArmyName$(empty) = gLeaderName$(empty): gLeaderName$(empty) = ""
	COLOR 12: CALL ClearBottom: PRINT "Placing NEW army "; empty; gArmyName$(empty); " in "; gCityName$(target);

	x = 70: IF gRealism > 0 THEN x = 3 * gCityValue(target) + 33
	CALL cutoff(who, target, a): IF a < 1 THEN x = x \ 3
	gIsOccupied(target) = empty: gArmySize(empty) = x
	PRINT " Size = "; : CALL CorrectArmySize(empty)
	gCurrentCash(who) = gCurrentCash(who) - 100: IF gSoundEffects > 0 THEN SOUND 2222, .5
	gArmyLocation(empty) = target: CALL DrawArmyUnit(empty)
	CALL TICK(gTurbo! - .5)
	gArmyMove(empty) = -1
END SUB

SUB newcity (index%)
			gMenuText$(1) = "  "
			gMenuText$(3) = "  "
			gMenuRows = 3: someString$ = gCityName$(index)
	morecap:
			gTLX = 68: gTLY = 15: gColour = 3: gChosenOption = 23
			gMenuText$(2) = gCityName$(index)
			CALL ShowMenu(3): CALL ClearRight
			SELECT CASE gChosenOption
			CASE IS = -27
			index = 0: EXIT SUB
			CASE IS < 1
			someString$ = CHR$(ABS(gChosenOption))
			x = 0
			FOR k = 1 TO 40
			IF LEFT$(gCityName$(k), 1) = someString$ THEN
				y = index: index = k
	spin2:
				IF gCityOwner(index) = gCurrentSide GOTO morecap
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
			IF gCityOwner(index) <> gCurrentSide GOTO minus1 ELSE GOTO morecap
			CASE 2
			EXIT SUB
			CASE 3
	plus1:
			index = index + 1: IF index > 40 THEN index = 1
			IF gCityOwner(index) <> gCurrentSide GOTO plus1 ELSE GOTO morecap
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
	SELECT CASE gRR(who)
		CASE 0
		IF who = gCurrentSide GOTO human
		CALL StartToFinish(start, fin, who): max = 32767
		index = 0
		FOR i = start TO fin: IF gArmyLocation(i) = 0 OR gArmyMove(i) <> 0 GOTO puter
		x = 0: FOR j = 1 TO 6: from = gMatrix(gArmyLocation(i), j): IF from > 0 AND gCityOwner(from) <> who THEN x = x + 1
		NEXT j
		IF gIsOccupied(gCapitalCity(who)) > 0 AND x > 1 GOTO puter
		CALL void(gArmyLocation(i), defend)
		IF gVictoryFlags(5) > 0 AND gIsOccupied(gCapitalCity(who)) = 0 THEN IF defend > max THEN defend = max - 1
		IF defend < max THEN target = gArmyLocation(i): GOSUB route: IF x > 1 THEN max = defend: index = i
	puter:  NEXT i
		IF index = 0 OR max > .3 * gArmySize(index) GOTO toot
		CALL traincapacity(who, limit)
		IF gArmySize(index) > limit THEN GOTO toot
		from = gArmyLocation(index)
		x1 = 0: FOR i = 1 TO 40: IF gCityOwner(i) <> who GOTO puted
		CALL void(i, defend): IF defend = 0 OR defend > 3 * gArmySize(index) GOTO puted
		IF gIsOccupied(i) > 0 GOTO puted
		target = i
		GOSUB route: IF x = 0 GOTO puted
		IF gCurrentSide = 1 AND gCityY(i) < gCityY(from) THEN x1 = i
		IF gCurrentSide = 2 AND gCityY(i) > gCityY(from) THEN x1 = i
		IF gFortLevel(i) > 0 AND gIsOccupied(i) = 0 THEN x1 = i: EXIT FOR
	puted:  NEXT i
		IF gVictoryFlags(5) > 0 AND gIsOccupied(gCapitalCity(who)) = 0 THEN
			GOSUB route
			IF x > 0 THEN
				CALL void(gCapitalCity(who), defend)
				IF defend > 0 THEN x1 = gCapitalCity(who)
			END IF
		END IF
		IF x1 > 0 GOTO confirmrrdestination ELSE GOTO toot
	human:
		CALL MoveFrom(index, a): IF a < 1 OR index < 1 THEN COLOR 11: CALL ClearBottom: PRINT "Railroad move not allowed"; : GOTO toot
		x = 1: IF index > 20 THEN x = 2
		CALL traincapacity(who, limit)
		IF gArmySize(index) > limit THEN CALL ClearBottom: PRINT "Too many troops for railroad capacity"; : GOTO toot
		
		target = gArmyLocation(index): GOSUB route: IF x > 1 GOTO chooserrdestination
		CALL ClearBottom: PRINT "Track from "; gCityName$(target); " is blocked"; : GOTO toot
	chooserrdestination:
		CALL ClearBottom: PRINT "Select destination for "; gArmyName$(index); " from "; gCityName$(target);
		gMenuText$(0) = "To": from = target: x1 = from: IF from = 0 GOTO toot
		CALL newcity(x1): IF x1 = from OR x1 = 0 GOTO toot

		target = x1: GOSUB route: IF x > 1 GOTO confirmrrdestination
		CALL ClearBottom: PRINT gArmyName$(index); "'s train cannot go to "; gCityName$(x1); " - select another city"; : CALL TICK(9)
		GOTO chooserrdestination
	confirmrrdestination:
		COLOR 11: CALL ClearBottom: PRINT gArmyName$(index); " is taking the train from "; gCityName$(from); " to "; gCityName$(x1);
		gArmyOnRailroad(who) = gArmyLocation(index)
		from = gArmyLocation(index)
		gRRFrom(who) = from
		gRR(who) = index: gArmyLocation(index) = 0: gArmyMove(index) = x1
		CALL tinytrain(who, 1)
		IF gSoundEffects > 0 THEN SOUND 2222, 1
		CALL engine

		CALL occupy(from)
		IF gIsOccupied(from) > 0 THEN CALL DrawArmyUnit(gIsOccupied(from))
		GOTO toot

		CASE IS > 0
		CALL tinytrain(who, 0)
		CALL occupy(gRRFrom(who))
		IF gIsOccupied(gRRFrom(who)) > 0 THEN CALL DrawArmyUnit(gIsOccupied(gRRFrom(who)))

		index = gRR(who)
		gArmyOnRailroad(who) = gArmyMove(index)
		CALL tinytrain(who, 1)

		gRR(who) = 0: gArmyLocation(index) = gArmyMove(index): gArmyMove(index) = -1
		COLOR 11: CALL ClearBottom: PRINT "Train with "; gArmyName$(index); " has arrived in "; gCityName$(gArmyLocation(index)); : IF gSoundEffects > 0 THEN SOUND 1200, 2
		CALL TICK(gTurbo!)
		x = gCityX(gArmyLocation(index)) - 12: y = gCityY(gArmyLocation(index)) - 11
		LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
		IF gCityOwner(gArmyLocation(index)) <> who THEN CALL DrawCityCaptured(index, gArmyLocation(index), who, 0)
		CALL DrawArmyUnit(index)
		IF gIsOccupied(gArmyLocation(index)) > 0 THEN CALL stax(who): GOTO toot
		CALL occupy(gArmyLocation(index)): CALL DrawArmyUnit(index)
		GOTO toot
	END SELECT

	route:
		x = 0: FOR j = 1 TO 6
		y = gMatrix(target, j)
		IF y > 0 AND gCityOwner(y) = who THEN
		x = x + 1
			FOR m = 1 TO 6
			z = gMatrix(y, m)
			IF z > 0 AND z <> target AND gCityOwner(z) = who THEN x = x + 1
			NEXT m
		END IF
	NEXT j
	RETURN

	toot:
		IF who = gCurrentSide THEN CALL TICK(9)
		CALL ClearRight
		ClearBottom
END SUB

SUB RecruitArmy (who%)
		IF gCurrentCash(who) < 100 THEN EXIT SUB
		gMenuRows = 0: COLOR 12
		gMenuText$(0) = "Recruit"
		IF who = gCurrentSide AND gRecruitFlag > 0 THEN FOR i = 1 TO gRecruitFlag: x = gRecruitCity(i): gMenuText$(i) = gCityName$(x): gArray(i) = x: NEXT i: gMenuRows = gRecruitFlag: GOTO alldone
		max = 4: IF RND > .8 THEN max = max - 1
		IF gDifficultyLevel < 3 THEN max = max + 1

		FOR i = 1 TO 40
		IF gCityController(who) > 0 THEN pct! = .6 * max / gCityController(who) ELSE pct! = .3
		IF gMenuRows = 0 AND i > 20 THEN pct! = .3
		IF gMenuRows < 2 AND i > 30 THEN pct! = .3
		gArray(i) = 0
		IF gIsOccupied(i) > 0 AND gCityOwner(i) = who THEN pct! = .4
		IF RND < pct! AND gCityOwner(i) = who THEN
			IF gRealism > 0 AND gCityO(i) = 3 - who GOTO foe
			gMenuRows = gMenuRows + 1
			gMenuText$(gMenuRows) = gCityName$(i)
			gArray(gMenuRows) = i
			IF gMenuRows > max - 1 GOTO alldone
		END IF
	foe:
		NEXT i
	alldone:
		IF gMenuRows = 0 THEN EXIT SUB
		IF who = gCurrentSide AND gRecruitFlag = 0 THEN FOR i = 1 TO gMenuRows: gRecruitCity(i) = gArray(i): NEXT i: gRecruitFlag = gMenuRows
		CALL bubble(gMenuRows)
	'............................................................................
	levy:
		IF gCurrentCash(who) < 100 THEN EXIT SUB
		IF (who = gCurrentSide) OR (gHumanPlayers = 2) THEN CALL ClearBottom: PRINT gNationName$(who); " funds available "; gCurrentCash(who);
		gTLX = 67: gTLY = 12: gColour = 3
		IF who <> gCurrentSide THEN GOSUB randsel: GOTO auto1
		
		IF gChosenOption > 0 THEN gChosenOption = 21 + gChosenOption
		CALL ShowMenu(2): CALL ClearRight
		IF gChosenOption < 1 THEN EXIT SUB
	auto1:
		empty = 0
		index = gArray(gChosenOption)
		CALL occupy(index)
		IF gIsOccupied(index) > 0 THEN i = gIsOccupied(index): GOTO add2
		CALL commander((who), empty)
		
		IF who <> gCurrentSide AND empty = 0 THEN EXIT SUB
		IF empty = 0 GOTO levy
		gArmyLocation(empty) = index
		GOSUB playb
		CALL CreateNewArmy(who, empty, index)
		GOTO levy
	'............................................................................
	add2:
		target = gArray(gChosenOption)
		x = 45: someString$ = ""
		IF gRealism > 0 THEN
			x = 2 * gCityValue(gArmyLocation(i)) + 20
			CALL cutoff(who, target, a)
			IF a < 1 THEN x = x \ 3: someString$ = " ISOLATED !"
		END IF
		gArmySize(i) = gArmySize(i) + x

		GOSUB playb
		gCurrentCash(who) = gCurrentCash(who) - 100
		from = gArmyLocation(i): x = gCityX(from) - 12: y = gCityY(from) - 11
		GET (x - 9, y - 7)-(x + 9, y + 6), anima
		CALL MoveUnitIcon(gArmyLocation(i), 0, 2)
		IF gSoundEffects > 0 THEN SOUND 2222, 1
		COLOR 11: CALL ClearBottom: PRINT "Army "; i; gArmyName$(i); " in "; gCityName$(gArmyLocation(i)); " strength increased to "; : CALL CorrectArmySize(i)
		IF someString$ <> "" THEN PRINT someString$;
		PUT (x - 9, y - 7), anima, PSET
		CALL TICK(gTurbo! - .5)
		GOTO levy
	randsel:
			gChosenOption = 0: x = 0
			FOR i = 1 TO gMenuRows
			target = gArray(i)
			LOCATE 14 + i, 69
			x = gIsOccupied(target)
			IF x = 0 XOR gArmySize(x) < 155 THEN gChosenOption = i
			NEXT i

		IF gChosenOption = 0 THEN gChosenOption = 1 + INT(RND * gMenuRows)
		IF gRealism > 0 THEN
			x = 0
			FOR i = 1 TO gMenuRows
			target = gArray(i)
			IF gIsOccupied(target) = 0 THEN
				y = 3 * gCityValue(target) + 33
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			ELSE
				y = 2 * gCityValue(target) + 20
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			END IF
			IF y > x AND RND > .5 THEN x = y: gChosenOption = i
			NEXT i
		END IF
		IF gCurrentCash(who) < 100 THEN gChosenOption = gMenuRows
		RETURN
	playb:
		IF gCurrentSide = 1 AND gDifficultyLevel < 3 THEN gArmySize(empty) = gArmySize(empty) + 15 - 5 * gDifficultyLevel
		IF gCurrentSide = 2 AND gDifficultyLevel > 3 THEN gArmySize(empty) = gArmySize(empty) + 5 * gDifficultyLevel - 15
		RETURN
END SUB

SUB ShipType (who%, i%)
	a = 1: IF MID$(gFleet$(who), i, 1) = "I" THEN a = 2
	CALL DrawShipIcon(who, a)
END SUB

SUB ComputerPlayer
	CALL SpecialEvents
	slush = 0: who = 3 - gCurrentSide
	c = 9: IF gCurrentSide = 1 THEN c = 15
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR c: LOCATE 1, 10: PRINT gNationName$(who); " Side is making decisions";
	CALL StartToFinish(start, fin, who)
	'==========================================================================
	'                       Check Supply
	'==========================================================================
	FOR i = start TO fin: IF gArmyLocation(i) > 0 AND gArmySupply(i) < 1 THEN CALL ResupplyArmy(i)
	NEXT i
	'==========================================================================
	'                       Fortify Capital or Other City
	'==========================================================================
	cost = 200
	IF cost > gCurrentCash(who) GOTO signup

	target = 0: IF gIsOccupied(gCapitalCity(who)) = 0 OR gFortLevel(gCapitalCity(who)) > 1 GOTO city2
	target = gCapitalCity(who)
	IF gCityOwner(target) = who GOTO capital ELSE GOTO city2
	IF target > 0 GOTO capital

	city2:
	IF 1 + RND < gAIBoldness + gAggress! GOTO signup
	target = 0: FOR i = start TO fin
	x = gArmyLocation(i): IF x = 0 OR gArmyMove(gIsOccupied(x)) < 0 OR gArmyMove(i) < 0 GOTO endlook
	IF gFortLevel(x) > 1 GOTO endlook
		CALL void(x, defend): IF defend > gArmySize(i) THEN target = gArmyLocation(i): GOTO capital
	endlook:
	NEXT i

	capital:
		IF target = 0 GOTO signup
		IF gFortLevel(target) > 1 GOTO signup
		gFortLevel(target) = gFortLevel(target) + 1
		x = gIsOccupied(target): gArmyMove(x) = -1
		gCurrentCash(who) = gCurrentCash(who) - cost
		CALL ClearBottom: PRINT gCityName$(target); " fortifications increased to "; gFortLevel(target);
		CALL MoveUnitIcon(target, 0, 6)
		CALL DrawCities
		IF who = 1 AND gNavySize(1) < 1 AND RND > .5 AND gCurrentCash < 222 GOTO signup
		IF 3 * RND > 1 + gAggress! AND gCurrentCash(who) >= cost GOTO city2
	'==========================================================================
	'                       Recruit New Armies
	'==========================================================================
	signup:
	IF who = 1 AND gNavySize(1) < 1 AND gCurrentCash(1) > 100 THEN CALL ManageNavy(1, 1): IF gCurrentCash(who) < 100 GOTO isok
	GOSUB enufarmies
	IF x > 2 + 3 * gCurrentSide + 3 * RND GOTO isok
	IF gNavySize(who) < 5 AND gCurrentCash(who) > 100 AND gNavyLocation(who) <> 99 THEN IF gCityOwner(gNavyLocation(who)) = who THEN slush = slush + 100: gCurrentCash(who) = gCurrentCash(who) - 100: IF gCurrentCash(who) < 100 GOTO isok
	CALL RecruitArmy(who)
	'==========================================================================
	'                         Naval Commands
	'==========================================================================
	isok:
		gCurrentCash(who) = gCurrentCash(who) + slush
		IF gCurrentSide = 2 AND gNavyLocation(1) = 0 AND gNavySize(1) < 1 AND gCityOwner(30) = 1 AND gCurrentCash(1) > 100 THEN gNavyLocation(1) = 30: CALL ManageNavy(1, 1): GOTO movenavy
		IF gNavyLocation(who) = 99 THEN
			IF RND < .9 THEN CALL ManageNavy(who, 3)
			GOTO movearmy
		END IF
		IF gCurrentCash(who) < 100 OR gNavySize(who) > 9 OR gCityOwner(gNavyLocation(who)) <> who GOTO movenavy
		CALL ManageNavy(who, 1)
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	movenavy:
		IF gNavySize(who) = 0 THEN gNavyLocation(who) = 0
		IF gNavyLocation(who) = 0 GOTO movearmy
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	'                     move ships & prohibit further action this turn
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		IF gNavyLocation(who) <> 99 THEN
			IF gCityOwner(gNavyLocation(who)) = who THEN CALL ManageNavy(who, 3): GOTO movearmy   'move ships & prohibit further action this turn
			IF gCityOwner(gNavyLocation(who)) = 0 THEN CALL ManageNavy(who, 3): GOTO movearmy
		ELSE
			IF RND < .5 THEN CALL ManageNavy(who, 3)
			GOTO movearmy
		END IF

		IF gCityOwner(gNavyLocation(who)) <> who THEN
			IF gIsOccupied(gNavyLocation(who)) = 0 OR RND > .3 THEN
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
	target = gArmyLocation(i)
	IF gArmyLocation(i) < 1 OR gArmyMove(i) < 0 GOTO deadman
	x = gArmySize(i): IF gArmySupply(i) < 1 AND RND > .1 GOTO deadman

	gChosenOption = 0

	CALL void(target, defend)

	IF defend > 0 AND target = gCapitalCity(who) AND gIsOccupied(target) = i GOTO deadman   'hold capital
	IF target <> gCapitalCity(who) GOTO nocap
	IF gVictoryFlags(5) = 0 GOTO nocap
		FOR j = 1 TO 6
		k = gMatrix(target, j): IF j = 0 GOTO nocap
		CALL void(k, flag): IF flag > 0 GOTO deadman
		NEXT j
	nocap:
	CALL evaluate(i, best): IF best = 0 GOTO deadman
	move9:
		IF best = 0 THEN gChosenOption = 1 + INT((j - 1) * RND)
		IF gChosenOption = 0 THEN gChosenOption = best
		gArmyMove(i) = gMatrix(target, gChosenOption)

		IF gCityOwner(gArmyMove(i)) = who THEN y = gIsOccupied(gArmyMove(i)): IF y > 0 THEN IF gArmyMove(y) = x THEN gArmyMove(i) = 0: GOTO deadman  ' eliminate crossing moves
		IF gCurrentMonth = 1 AND gJanuaryCampaign = 0 AND gCityOwner(gArmyMove(i)) <> who THEN gArmyMove(i) = 0: GOTO deadman

		IF gTurbo! > 1 THEN
			COLOR c: CALL ClearBottom
			PRINT gArmyName$(i); " plans to move from "; gCityName$(gArmyLocation(i)); " to "; gCityName$(gArmyMove(i));
		END IF
			CALL MoveUnitIcon(gArmyLocation(i), gArmyMove(i), 1)
			CALL MoveUnitIcon(gArmyLocation(i), gArmyMove(i), 9)
		CALL TICK(gTurbo! - 1)
		PUT (gCityX(gArmyLocation(i)) - 20, gCityY(gArmyLocation(i)) - 19), gGraphicImage, PSET
	deadman:
	NEXT i
		FOR i = start TO fin
		IF gArmyMove(i) = 0 AND gArmyExp(i) < 6 AND gArmyExp(i) < gArmyCommander(i) THEN
			gArmyExp(i) = gArmyExp(i) + 1

			IF gTurbo! > 1 THEN
			CALL ClearBottom
				PRINT gArmyName$(i); " has drilled to reach experience level "; gArmyExp(i);
			END IF
			gArmyMove(i) = -1
			CALL TICK(gTurbo! - 1)
		END IF
		NEXT i
	EXIT SUB
	'---------------------------------------------------------------------------
	enufarmies:
	CALL StartToFinish(start, fin, 3 - who)
	FOR i = start TO fin
		IF gArmyLocation(i) > 0 THEN y = y + .1 * gArmySize(i)
	NEXT i
	CALL StartToFinish(start, fin, who)
	x = 0: z = 0: FOR i = start TO fin: IF gArmyLocation(i) > 0 THEN x = x + 1: z = z + .1 * gArmySize(i)
	NEXT i
	IF y > z THEN x = x - 2
	IF y > 2 * z THEN x = 0
	RETURN
	'---------------------------------------------------------------------------
END SUB

SUB snapshot (x%, y%, flag%)
	IF flag = 0 THEN GET (x - 10, y - 10)-(x + 10, y + 10), gGraphicImage
	IF flag = 1 THEN PUT (x - 10, y - 10), gGraphicImage, PSET
END SUB

SUB CorrectArmySize (index%)
	someString$ = LTRIM$(RTRIM$(STR$(gArmySize(index)))) + "00"
	PRINT someString$;
END SUB

SUB tinytrain (who%, flag%)
		IF gArmyOnRailroad(who) = 0 THEN EXIT SUB
		from = gArmyOnRailroad(who)
		x = gCityX(from) - 12: y = gCityY(from) - 11
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
	IF gHumanPlayers = 1 THEN
		CALL ComputerPlayer
	ELSE
		FOR i = 1 TO 40
			IF gArmyLocation(i) > 0 AND gArmyMove(i) > 0 THEN 
				CALL MoveUnitIcon(gArmyLocation(i), gArmyMove(i), 1)
			END IF
		NEXT i
	END IF
	COLOR 14: LOCATE 1, 1: PRINT SPACE$(80);
	LOCATE 1, 20: PRINT "Update for "; gMonthes$(gCurrentMonth); ","; gCurrentYear
	CALL ClearBottom: PRINT "press any key for "; gMonthes$(gCurrentMonth); ","; gCurrentYear; " events";
	DO WHILE INKEY$ = "": LOOP
	CALL TurnUpdateBox
	'==========================================================================
	'                       Assign Time of Action
	'==========================================================================
	FOR i = 1 TO 2
		IF gRR(i) > 0 THEN 
			CALL railroad(i): LINE (5, 17)-(100, 63), 3, BF: LINE (5, 17)-(100, 63), 0, B: CALL engine
		END IF
	NEXT i

	FOR i = 1 TO 40
		gOrderOfMoves(i) = 999
		IF gArmyMove(i) < 0 THEN gArmyMove(i) = 0
		IF gArmyLocation(i) > 0 AND gArmyMove(i) > 0 THEN 
			gOrderOfMoves(i) = INT(4 + 4 * RND) * 100 + i
		END IF
		IF gArmySupply(i) < 1 AND gArmyMove(i) > 0 THEN 
			gOrderOfMoves(i) = 900 + i
		END IF
		SELECT CASE gArmySize(i)         'bigger armies move slower
			CASE IS > 400
				IF gOrderOfMoves(i) < 900 THEN 
					gOrderOfMoves(i) = gOrderOfMoves(i) + 100
					x = 2
				END IF
			CASE IS > 800
				IF gOrderOfMoves(i) < 800 THEN 
					gOrderOfMoves(i) = gOrderOfMoves(i) + 200
					x = 3
				END IF
			CASE IS > 1000
				IF gOrderOfMoves(i) < 700 THEN 
					gOrderOfMoves(i) = gOrderOfMoves(i) + 300
					x = 4
				END IF
			CASE ELSE
				x = 1
		END SELECT
		IF gOrderOfMoves(i) <> 999 AND gArmyCommander(i) > 10 * RND THEN
				gOrderOfMoves(i) = gOrderOfMoves(i) - 100 * (gArmyCommander(i) \ 2)
				IF gOrderOfMoves(i) < 100 THEN gOrderOfMoves(i) = 100 + i
		END IF
	NEXT i

	CALL SortArmyMoves(40)
	'==========================================================================
	'                       Begin Main Loop
	'==========================================================================
	FOR j = 1 TO 40
		flag = 0
		IF gOrderOfMoves(j) = 999 GOTO allthru
		active = INT(gOrderOfMoves(j) / 100)
		active = gOrderOfMoves(j) - 100 * active
		IF active > 20 THEN s = 2 ELSE s = 1
	IF gArmyMove(active) < 1 GOTO digin
	COLOR 11: CALL ClearBottom: PRINT gArmyName$(active); " is moving to "; gCityName$(gArmyMove(active));

	gArmySupply(active) = gArmySupply(active) - 1
	IF gArmySupply(active) < 0 THEN 
		gArmySupply(active) = 0
		CALL TICK(gTurbo!)
		CALL ClearBottom
		PRINT gArmyName$(active); " is out of supplies !";
	END IF

	CALL DrawArmyUnit(active)
	CALL MoveUnitIcon(gArmyLocation(active), gArmyMove(active), 5)

	CALL AnimateMovement(active, 0)
	'==========================================================================
	target = gArmyMove(active)
	IF gIsOccupied(target) = 0 GOTO moveintonewcity
	IF (s = 1 AND gIsOccupied(target) < 21) OR (s = 2 AND gIsOccupied(target) > 20) THEN
		GOTO friendlyarmiesmeet 
	ELSE 
		GOTO enemyarmiesbattle
	END IF
	'==========================================================================
	'                         Join Forces
	'==========================================================================
	friendlyarmiesmeet:
	COLOR 11: CALL ClearBottom: PRINT gArmyName$(active); " and "; gArmyName$(gIsOccupied(target)); " meet in "; gCityName$(target);
	CALL TICK(gTurbo!)
	CALL MoveUnitIcon(gArmyMove(active), 0, 6)
	CALL ClearBottom
	GOTO moveintonewcity
	'==========================================================================
	'                       Attack
	'==========================================================================
	enemyarmiesbattle:
	CALL MoveUnitIcon(target, 0, 3)
	defend = gIsOccupied(target)

	COLOR 11: CALL ClearBottom: PRINT gArmyName$(active); " attacks "; gArmyName$(defend); " in "; gCityName$(gArmyLocation(defend));
	CALL TICK(gTurbo! - 1)
	IF gArmySize(defend) > 0 THEN 
		CALL ComputeBattle(active, defend, win, lose)
		flag = 1
		IF gGraphicLevel > 0 THEN CALL TurnUpdateBox
	END IF
	IF gArmyExp(win) < 10 THEN gArmyExp(win) = gArmyExp(win) + 1

	IF gArmySize(lose) < 2 THEN
		CALL ClearBottom
		someString$ = gArmyName$(lose) + "'s army is crushed in " + gCityName$(gArmyLocation(defend))
		CALL scribe(someString$, 2)
		index = lose
		GOTO crushed
	END IF

	CALL ClearRight
	'==========================================================================
	'                       Attacker Loses
	'==========================================================================
	IF win = active GOTO defenderretreats
	gArmyMove(active) = gArmyLocation(active)
	gArmyLocation(active) = target
	COLOR 11: CALL ClearBottom: PRINT gArmyName$(active); " withdrew to "; gCityName$(gArmyMove(active));

	CALL DrawArmyUnit(gArmyLocation(active))
	CALL AnimateMovement(active, 1)

	gArmyLocation(active) = gArmyMove(active)
	CALL DrawArmyUnit(gArmyLocation(active))
	CALL DrawArmyUnit(active)
	gIsOccupied(gArmyLocation(active)) = active
	gArmyMove(active) = -2
			
	IF 11 * RND > gArmyCommander(defend) THEN 
		CALL MoveUnitIcon(gArmyLocation(defend), gArmyMove(defend), 4)
		IF gArmyMove(defend) > 0 THEN gArmyMove(defend) = -2
	END IF

	CALL TICK(gTurbo!)
	GOTO digin
	'==========================================================================
	'                       Defender Retreats
	'==========================================================================
	defenderretreats:
		CALL MoveUnitIcon(gArmyLocation(active), target, 4)
		IF gArmyMove(defend) > 0 THEN 
			CALL MoveUnitIcon(target, gArmyMove(defend), 4)
		END IF

		CALL retreat(defend, flee)
		IF flee > 0 THEN move2 = flee: GOTO outta

		best = 0
		flee = 0
		FOR i = 1 TO 6
			x = gMatrix(target, i)
			IF x > 0 AND (gCityOwner(x) = 3 - s) AND gCityValue(x) > best THEN
				IF best = 0 THEN
					flee = i
					best = gCityValue(x)
				ELSE
					IF gIsOccupied(x) = 0 THEN 
						flee = i
						best = gCityValue(x)
					END IF
				END IF
			END IF
		NEXT i
		IF flee = 0 GOTO defendersurrenders
		move2 = gMatrix(target, flee)
	outta:
		CALL DrawArmyUnit(defend)                  ' in old city

		gArmyMove(defend) = move2
		CALL AnimateMovement(defend, 0)                 ' animate retreat
		
		gArmyLocation(defend) = move2
		gIsOccupied(move2) = defend
		CALL ClearBottom
		PRINT gArmyName$(defend) + " is withdrawing to " + gCityName$(move2);

		CALL DrawArmyUnit(defend)                  ' in new city
		
		CALL MoveUnitIcon(target, 0, 6)
		gArmyMove(defend) = -2
		GOTO checkmoredefenders

	defendersurrenders:
		index = defend
		someString$ = gArmyName$(index) + " surrenders to " + gArmyName$(active) + " in " + gCityName$(gArmyLocation(index))
		CALL scribe(someString$, 2)
	crushed:
		IF gGraphicLevel > 2 THEN 
			CALL DrawArmySurrender(index)
			COLOR 14: LOCATE 3, 68: PRINT gArmyName$(index): LOCATE 4, 68: PRINT "surrenders !"
		END IF
		IF index > 20 THEN x = 2 ELSE x = 1
		IF gSoundEffects > 1 AND x <> gCurrentSide THEN PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"
		IF gArmyMove(index) > 0 THEN 
			CALL MoveUnitIcon(gArmyLocation(index), gArmyMove(index), 4)
		END IF
		gVictoryPoints(3 - s) = gVictoryPoints(3 - s) + 25
		gArmyLocation(index) = 0
		gLeaderName$(index) = ""
		gArmyName$(index) = ""
		gArmySize(index) = 0
		gArmyCommander(index) = 0
		gArmyExp(index) = 0
		gArmyMove(index) = 0
		gArmySupply(index) = 0
		gArmySupply(active) = gArmySupply(active) + gArmySupply(index)
		gArmySupply(index) = 0
		IF gArmySupply(active) > 10 THEN gArmySupply(active) = 10
		CALL TICK(9)
		CALL ClearRight
		IF gArmyLocation(active) = 0 GOTO digin
	'---------------------------------------------------------------------------
	'                       check for more defenders !
	'---------------------------------------------------------------------------
	checkmoredefenders:
		CALL occupy(target)
		IF gIsOccupied(target) = 0 GOTO moveintonewcity
		COLOR 11: CALL ClearBottom: PRINT "There are still defenders in "; gCityName$(target);
		CALL TICK(99)
		GOTO enemyarmiesbattle
	'==========================================================================
	'                       Move Into New City
	'==========================================================================
	moveintonewcity:
	CALL MoveUnitIcon(gArmyLocation(active), target, 4)
	gArmyLocation(active) = target: gArmyMove(active) = -2
	CALL occupy(gArmyLocation(active))
	CALL DrawArmyUnit(active)
	'---------------------------------------------------------------------------
	'                            City Capture
	'---------------------------------------------------------------------------
		IF gCityOwner(gArmyLocation(active)) = s GOTO horde
		c = gArmyLocation(active)
		IF gHumanPlayers = 1 AND s = gCurrentSide AND gFortLevel(c) > 0 AND flag = 0 THEN
			gTLX = 67: gTLY = 15
			gHighlight = 15: gColour = 3
			gMenuText$(0) = "Raze ?"
			gMenuText$(1) = "No"
			gMenuText$(2) = "Yes"
			gMenuRows = 2
			CALL ShowMenu(0)
			CALL ClearRight
			IF gChosenOption = 2 GOTO razefort
		END IF
		IF gHumanPlayers = 1 AND s <> gCurrentSide AND gFortLevel(c) > 0 AND flag = 0 THEN
			IF gRealism > 0 AND gCityY(c) > 150 THEN
	razefort:
				gFortLevel(c) = 0
				x = gCityX(c)
				y = gCityY(c)
				LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
				CALL DrawCities
				CALL ClearBottom
				PRINT gArmyName$(active); " has destroyed the forts at "; gCityName$(c);
				TICK 3
			END IF
		END IF
		CALL DrawCityCaptured(active, c, s, flag)
	horde:
	IF gArmySupply(active) < 10 THEN 
		gArmySupply(active) = gArmySupply(active) + 1
		IF RND > .8 GOTO horde
	END IF
	digin:
	NEXT j
	GOTO allthru

	allthru:
	IF gNavySize(gNavalCommerce) < 1 THEN gNavalCommerce = 0
	IF gNavalCommerce > 0 THEN
		CALL ClearBottom
		IF RND < .8 + .02 * gNavySize(gNavalCommerce) THEN
			gNavalRaider = .05 * gNavySize(gNavalCommerce) * (1 + RND) * (gCurrentIncome(3 - gNavalCommerce))
			IF gNavalRaider < 1 THEN gNavalRaider = 1
			IF gNavalRaider / gCurrentIncome(3 - gNavalCommerce) > .3 THEN 
				gNavalRaider = .3 * gCurrentIncome(3 - gNavalCommerce)
			END IF
			COLOR 15: PRINT gNationName$(gNavalCommerce); " raiders have sunk $"; gNavalRaider; " of "; gNationName$(3 - gNavalCommerce); " commerce";
			IF LEFT$(gFleet$(gNavalCommerce), 1) = "I" THEN a = 2 ELSE a = 1
			PSET (500, 465), 0: CALL DrawShipIcon(gNavalCommerce, a)
			IF gSoundEffects > 0 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
			IF gNavalCommerce = gCurrentSide THEN gGrudge = 1
			TICK 9
		ELSE
			gNavalRaider = 0
			CALL ShipDestroyed(gNavalCommerce)
			COLOR 15: PRINT gNationName$(gNavalCommerce); " raiders have lost a ship ("; gNavySize(gNavalCommerce); " remain)";
			IF gSoundEffects > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
			IF gNavyLocation(gNavalCommerce) > 0 THEN
				TICK 9
				GOTO allthru
			ELSE
				gNavalCommerce = 0
				LINE (447, 291)-(525, 335), 1, BF
				FOR k = 1 TO 5: CIRCLE (480, 315), 4 * k, 11: NEXT k
				TICK 9
				LINE (447, 291)-(525, 335), 1, BF
			END IF
		END IF
	END IF

	CALL TouchupMap
	CALL ships
	CALL ProcessTurn

	CALL ClearBottom
	LINE (390, 350)-(520, 400), 1, BF
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(gMonthes$(gCurrentMonth), 3)); ","; gCurrentYear
	gVictoryPoints(1) = .8 * gVictoryPoints(1) + .3 * (gCurrentIncome(1) + gCityController(1))
	IF gCityController(1) > 29 THEN 
		gVictoryPoints(1) = gVictoryPoints(1) + 50
		IF gCityController(1) > 34 THEN gVictoryPoints(1) = gVictoryPoints(1) + 100
	END IF
	IF gCurrentSide = 2 AND gCityController(1) < 11 THEN gAggress! = gAggress! + .7

	IF gVictoryPoints(1) < 1 THEN gVictoryPoints(1) = 0
	gVictoryPoints(2) = .8 * gVictoryPoints(2) + .3 * (gCurrentIncome(2) + gCityController(2))
	IF gCityController(2) > 29 THEN 
		gVictoryPoints(2) = gVictoryPoints(2) + 50
		IF gCityController(2) > 34 THEN gVictoryPoints(2) = gVictoryPoints(1) + 100
	END IF
	IF gCurrentSide = 1 AND gCityController(2) < 11 THEN gAggress! = gAggress! + .7
	IF gHumanPlayers = 2 THEN CALL ClearBottom: COLOR 14: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
END SUB

SUB TurnUpdateBox
	LINE (450, 318)-(526, 420), 1, BF
	LINE (527, 315)-(527, 439), 10
	COLOR 14: LOCATE 23, 50: PRINT "============="
	LOCATE 24, 50: PRINT "| U P D A T E |"
	LOCATE 25, 50: PRINT "============="
END SUB

'============================================================================
'                GENmenu 3.05 : Generic Menu Main Module Level  12/91
'                Updated to Use Graphic Screens 8, 9, 12
'============================================================================
'       gTLX  = top left x  (if zero, automatically centered)
'       gTLY = top left y   (if zero, automatically centered)
'       gMenuRows = # rows (current maximum=20)
'       gMenuText$() = text for menu
'                gMenuText$(0) = heading (blank defaults to M E N U)
'                gMenuText$(1-size) are options
'       gChosenOption = option selected (row #)
'            -1 indicates ESC key pressed
'            entering with gChosenOption+21 causes gChosenOption to be default entry
'       gWindowType = window type (0 = no line; 1=single line;
'                            2=double line
'               if >10 then 10's digit=box color  1's digit= window type

SUB GenericMenu (b1%, wide%)
	boxc = gColour: IF gWindowType > 10 THEN boxc = INT(gWindowType / 10): gWindowType = gWindowType - 10 * boxc
	COLOR boxc
	VIEW (8 * gTLX - 6, 16 * gTLY - 11)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + gMenuRows + 2) + 8)
	CLS 1
	VIEW
	LINE (8 * gTLX - 6, 16 * gTLY - 11)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + gMenuRows + 2) + 8), gColour, B
	LINE (8 * gTLX - 2, 16 * (gTLY + 1) + 3)-(8 * (gTLX + wide + 1) + 3, 16 * (gTLY + 1) + 6), gColour, B
	IF ABS(gWindowType) = 2 THEN
	LINE (8 * gTLX - 2, 16 * gTLY - 8)-(8 * (gTLX + wide + 1) + 3, 16 * (gTLY + gMenuRows + 2) + 4), gColour, B
	END IF
	COLOR gColour

	LOCATE gTLY + 1, gTLX + b1: PRINT gMenuText$(0)
	FOR i = 1 TO gMenuRows
	LOCATE gTLY + 2 + i, gTLX + 2: PRINT gMenuText$(i);
	NEXT i
END SUB

SUB ShowMenu (switch%)
		IF gColour = 0 THEN gColour = 7
		LOCATE 1, 1, 0
		IF gMenuText$(0) = "" THEN gMenuText$(0) = "M E N U"

		IF wide = 0 THEN CALL MenuMaxWidth(wide)
		IF gTLX = 0 THEN GOSUB noadjust
		IF gChosenOption < 21 THEN gChosenOption = 1
		IF gChosenOption > 21 THEN gChosenOption = gChosenOption - 21
		IF gChosenOption > 21 THEN gChosenOption = 1
		row = gChosenOption: IF row < 1 THEN row = 1
		IF row > gMenuRows THEN row = 1
		gChosenOption = row
		row1 = row
		
		IF gTLY = 0 THEN gTLY = INT(11.5 - .5 * gMenuRows)
		IF gTLY + gMenuRows > 26 THEN gTLY = 26 - gMenuRows
		
		brx = gTLX + wide + 1
		bry = gTLY + gMenuRows + 3
		
		boxc = gColour: IF gWindowType > 10 THEN boxc = INT(gWindowType / 10): gWindowType = gWindowType - 10 * boxc

		COLOR boxc

		VIEW (8 * gTLX - 6, 16 * gTLY - 11)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + gMenuRows + 2) + 8)
		CLS 1
		VIEW
		LINE (8 * gTLX - 6, 16 * gTLY - 11)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + gMenuRows + 2) + 8), gColour, B
		LINE (8 * gTLX - 2, 16 * (gTLY + 1) + 3)-(8 * (gTLX + wide + 1) + 3, 16 * (gTLY + 1) + 6), gColour, B
		IF ABS(gWindowType) = 2 THEN
			LINE (8 * gTLX - 2, 16 * gTLY - 8)-(8 * (gTLX + wide + 1) + 3, 16 * (gTLY + gMenuRows + 2) + 4), gColour, B
		END IF

		COLOR gColour
		b1 = INT(.5 * (wide - LEN(gMenuText$(0))) + .5) + 1

		CALL GenericMenu(b1, wide)
	sel1:
		SELECT CASE switch
			CASE 1: CALL MoveUnitIcon(gArray(row), 0, 7)
			CASE 2: CALL MoveUnitIcon(gArray(row), 0, 9)
				target = gIsOccupied(gArray(row))
				IF target > 0 THEN
				flag = 1
				anotherString$ = gArmyName$(target)
				IF LEN(anotherString$) > wide THEN anotherString$ = LEFT$(anotherString$, wide)
				COLOR 12
				LOCATE gTLY + 2 + row, gTLX + 2: PRINT SPACE$(wide);
				LOCATE gTLY + 2 + row, gTLX + 2: PRINT anotherString$;
				LOCATE gTLY + 4 + gMenuRows, gTLX + 1: PRINT SPACE$(12);
				LOCATE gTLY + 4 + gMenuRows, gTLX + 1: PRINT "Size"; gArmySize(target);
				x = POS(0): y = CSRLIN: LOCATE y, x - 1: PRINT "00";
				ELSE
				flag = 0
				LOCATE gTLY + 4 + gMenuRows, gTLX + 1: PRINT SPACE$(12);
				END IF
			CASE 4: CALL ShowArmyStats(gArray(row))
			CASE 5: COLOR 11: CALL ClearBottom: PRINT gArmyName$(index); "  Exp="; gArmyExp(index); " Cash="; gCurrentCash(gCurrentSide);
			CASE 6: CALL MoveUnitIcon(gArmyLocation(gArray(row)), 0, 9)
			CASE 8
				IF gGraphicLevel > 2 AND row > 0 THEN
					LINE (548, 148)-(592, 216), 15, B
					a = row: IF gCurrentSide = 1 THEN a = 6 - row
					anotherString$ = "face" + LTRIM$(STR$(a)) + ".vga"
					IF _FILEEXISTS(anotherString$) THEN
						DEF SEG = VARSEG(gFacesImage(1))
						BLOAD anotherString$, VARPTR(gFacesImage(1))
						DEF SEG
						PUT (550, 150), gFacesImage, PSET
						IF gCurrentSide = 2 THEN
							PAINT (560, 160), 8, 0
							PAINT (570, 155), 7, 0
						END IF
					END IF
				END IF
			CASE 9: CALL MoveUnitIcon(gArray(row), 0, 9)
		END SELECT
		IF flag = 0 THEN
			COLOR gHighlight
			LOCATE gTLY + 2 + row, gTLX + 2
			PRINT gMenuText$(row)
			IF gBorderWidth > 0 THEN LINE (8 * (gTLX + 1), 16 * (gTLY + row + 1))-(8 * (gTLX + LEN(gMenuText$(row)) + 1) - 1, 16 * (gTLY + row + 2) - 1), gHighlight, B
		END IF
		GOSUB crsr
		IF switch <> 3 GOTO reglr
		IF someString$ = "H" THEN gChosenOption = 1: GOTO called
		IF ASC(someString$) = 13 THEN gChosenOption = 2: GOTO called
		IF someString$ = "P" THEN gChosenOption = 3: GOTO called
	reglr:
		IF ASC(someString$) = 13 GOTO called
		IF switch = 2 THEN LOCATE gTLY + 2 + row1, gTLX + 2: PRINT SPACE$(wide);
		COLOR gColour
		LOCATE gTLY + 2 + row1, gTLX + 2: PRINT gMenuText$(row1)

		SELECT CASE switch
			CASE 1, 2, 9
				IF gMenuText$(row1) <> "EXIT" THEN CALL MoveUnitIcon(gArray(row1), 0, 8)
			CASE 6
				IF gMenuText$(row1) <> "EXIT" THEN CALL MoveUnitIcon(gArmyLocation(gArray(row1)), 0, 8)
		END SELECT

		gChosenOption = row
		GOTO sel1
	crsr:   someString$ = INKEY$: IF someString$ = "" GOTO crsr
		IF ASC(someString$) = 13 THEN RETURN
		IF LEN(someString$) = 2 GOTO arrows
		IF switch = 3 THEN gChosenOption = -ASC(UCASE$(someString$)): GOTO called
		IF ASC(someString$) = 27 THEN gChosenOption = -1: GOTO called
			row1 = row
			FOR k = 1 TO gMenuRows
			c1$ = UCASE$(LEFT$(LTRIM$(gMenuText$(k)), 1))
			IF c1$ = UCASE$(someString$) THEN gChosenOption = k: GOSUB limits: GOTO called
			NEXT k
		GOTO crsr
	arrows:
		someString$ = RIGHT$(someString$, 1)
		row1 = row
		IF someString$ = "H" THEN row = row - 1: GOSUB limits: RETURN
		IF someString$ = "I" THEN row = 1: GOSUB limits: RETURN
		IF someString$ = "P" THEN row = row + 1: GOSUB limits: RETURN
		IF someString$ = "Q" THEN row = gMenuRows: GOSUB limits: RETURN
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
			gChosenOption = 99
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
		IF row > gMenuRows THEN row = 1
		IF row < 1 THEN row = gMenuRows
		RETURN
	noadjust:
		IF gTLX = 0 THEN gTLX = INT(40.5 - .5 * wide)
		RETURN
	called:
		IF gSoundEffects > 0 THEN SOUND 700, .5
		COLOR gColour
		gTLX = 0: gTLY = 0
		SELECT CASE switch
		CASE 1, 2, 9
			CALL MoveUnitIcon(gArray(row), 0, 8)
		CASE 6
			CALL MoveUnitIcon(gArmyLocation(gArray(row)), 0, 8)
		END SELECT
		VIEW
END SUB

SUB MenuMaxWidth (wide%)
	wide = LEN(gMenuText$(0)) + 1
	FOR i = 1 TO gMenuRows
	x = LEN(gMenuText$(i))
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
		IF gOrderOfMoves(i) > gOrderOfMoves(i + 1) THEN
			SWAP gOrderOfMoves(i), gOrderOfMoves(i + 1)
			swaps% = i
		END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB bubble (limit%)
	DO
		swaps% = FALSE
		FOR i = 1 TO limit - 1
		IF gMenuText$(i) > gMenuText$(i + 1) THEN
			SWAP gMenuText$(i), gMenuText$(i + 1)
			SWAP gArray(i), gArray(i + 1)
			swaps% = i
		END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB CancelArmyMovement (gCurrentSide%)
	CALL StartToFinish(start, fin, (gCurrentSide))

	CALL ClearRight
		gMenuRows = 0
		FOR j = start TO fin
		someString$ = gArmyName$(j): IF LEN(someString$) > 10 THEN x = INSTR(someString$, " "): someString$ = RIGHT$(someString$, LEN(someString$) - x)
		IF gArmyLocation(j) > 0 AND gArmyMove(j) > 0 THEN gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = someString$: gArray(gMenuRows) = gArmyLocation(j)
		NEXT j
		CALL bubble(gMenuRows)
		gTLX = 67: gTLY = 2: gWindowType = 2
		gMenuText$(0) = "Cancel"
		IF gMenuRows < 1 THEN CALL ClearBottom: COLOR 11: PRINT "No units have orders to cancel"; : EXIT SUB
		CALL ShowMenu(1)
		SELECT CASE gChosenOption
		CASE 1 TO gMenuRows
			target = gArray(gChosenOption)
			
			FOR i = start TO fin
			IF gArmyLocation(i) = target THEN x = INSTR(gArmyName$(i), gMenuText$(gChosenOption)): IF x > 0 AND gArmyMove(i) > 0 THEN index = i
			NEXT i

			CALL ClearBottom: COLOR 11: PRINT gArmyName$(index); " has cancelled move to "; gCityName$(gArmyMove(index)); : CALL TICK(turbo + 1)
			CALL MoveUnitIcon(gArmyLocation(index), gArmyMove(index), 4)
			gArmyMove(index) = 0: IF gSoundEffects > 0 THEN SOUND 2999, .5
			CALL stax(gCurrentSide)
		CASE ELSE
			GOTO finix
		END SELECT
	finix:
		CALL ClearRight
END SUB

SUB center (y%, someString$)
	x = LEN(someString$)
	x = 26 - x \ 2
	LOCATE y, 7 + x: PRINT someString$
END SUB

SUB ClearBottom
	LOCATE 29, 1: PRINT SPACE$(79);
	LOCATE 29, 1
END SUB

SUB ClearRight
	VIEW (528, 1)-(639, 450)
	CLS 1
	VIEW
END SUB

SUB commander (who%, empty%)
	empty = 0
	CALL StartToFinish(start, fin, who)
	FOR i = start TO fin
	IF gArmyLocation(i) = 0 AND gLeaderName$(i) <> "" THEN empty = i: EXIT SUB
	NEXT i

	'                 generic leaders if set list is exhausted
	FOR i = start TO fin
	IF gArmyLocation(i) = 0 THEN
		x = i
		CALL MakeRomanNumerals(x, someString$)
		empty = i
		gLeaderName$(i) = someString$
		gLeaderRating(i) = 1 + 8 * RND
		EXIT SUB
	END IF
	NEXT i
	CALL ClearBottom: PRINT "No more "; gNationName$(who); " commanders available"; : CALL TICK(gTurbo!)
END SUB

SUB VictoryConditionsMet
		someString$ = STR$(ABS(gVictoryFlags(3)) * 2.5) + "% Cities"
		anotherString$ = STR$(ABS(gVictoryFlags(3)) * 2.5) + "% Total Income"
		gMenuText$(8) = "Time: " + gMonthes$(gVictoryFlags(1)) + STR$(ABS(gVictoryFlags(2)))
		gMenuText$(9) = RTRIM$(STR$(ABS(gVictoryFlags(6)))) + ":1 Force Ratio"
		COLOR 15: LOCATE 1, 1: PRINT "Press ENTER to toggle ending conditions";
		COLOR 14: PRINT "				ESC when done"
	showvictoryconditionsbox:
		FOR i = 2 TO 6: IF gVictoryFlags(i) > 0 THEN gMenuText$(i - 1) = "+ " ELSE gMenuText$(i - 1) = "  "
		NEXT i
		gChosenOption = newChosenOption
		gMenuText$(0) = "Victory Conditions"
		gMenuText$(1) = gMenuText$(1) + gMenuText$(8)
		gMenuText$(2) = gMenuText$(2) + someString$
		gMenuText$(3) = gMenuText$(3) + anotherString$
		gMenuText$(4) = gMenuText$(4) + "Capital Captured"
		gMenuText$(5) = gMenuText$(5) + gMenuText$(9)
		gMenuText$(6) = "DONE"
		gWindowType = 2: gColour = 3: gMenuRows = 6: gHighlight = 14
		CALL ShowMenu(0)
		newChosenOption = 21 + gChosenOption
	SELECT CASE gChosenOption
		CASE 1
		gVictoryFlags(2) = -gVictoryFlags(2)
		CASE 2 TO 5
		gVictoryFlags(gChosenOption + 1) = -gVictoryFlags(gChosenOption + 1)
		CASE ELSE
		GOTO cheer
	END SELECT
		GOTO showvictoryconditionsbox
	cheer:
		CLS
		CALL DrawMap
END SUB

SUB engine
	IF gRR(1) + gRR(2) = 0 THEN EXIT SUB
	LINE (5, 17)-(100, 63), 3, BF
	LINE (5, 17)-(100, 47), 0, B
	LINE (5, 47)-(100, 63), 0, B

	FOR i = 1 TO 2
	IF gRR(i) = 0 GOTO notrane
	PSET (15, 25), 3: c = 9: IF i = 2 THEN c = 15: PSET (60, 25), 3
	DRAW "C0S4R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5BF4"
	x = POINT(0): y = POINT(1): PAINT (x, y), c, 0
	LOCATE 4, 6 * (i - 1) + 2: PRINT LEFT$(gCityName$(gArmyMove(gRR(i))), 5)
	notrane:
	NEXT i
END SUB

SUB evaluate (index%, x%)
	from = gArmyLocation(index)
	x = 200: IF gAggress! > 1.5 THEN x = 80: IF gAggress! > 2 THEN x = 20: IF gAggress! > 3 THEN x = 5
	CALL void(from, defend): IF defend = 0 THEN x = 0
	IF gAIBoldness > 1 THEN x = .5 * x

	best = gArmySize(index)

	FOR j = 1 TO 6: gArray(j) = -1
	a = gMatrix(from, j): IF a > 0 THEN IF gIsOccupied(a) > 0 THEN best = best - gArmySize(gIsOccupied(a)): y = 1
	NEXT j: best = .01 * best
	IF gAIBoldness > 0 THEN best = best + 20 * gAIBoldness

	CALL StartToFinish(start, fin, 3 - gCurrentSide)

	FOR j = 1 TO 6
		y = -1: a = gMatrix(from, j): IF a = 0 THEN max = j - 1: GOTO alleval
		
		c = gIsOccupied(a)
		FOR k = start TO fin: IF gArmyLocation(k) > 0 THEN IF gArmyMove(k) = a AND c = 0 GOTO alle
		NEXT k
		
		y = best - x * gFortLevel(from) - gCityValue(from) + 30 * RND
		IF gFortLevel(from) > 0 THEN IF index = gIsOccupied(from) THEN y = y - 25: IF gRealism > 0 THEN y = y - 50
		IF a = gCapitalCity(gCurrentSide) THEN IF gVictoryFlags(5) > 0 THEN y = y + 200
		IF gCityOwner(a) <> 3 - gCurrentSide THEN y = y + 5 * gCityValue(a) + 10 * gFortLevel(a)
		IF gCityOwner(a) <> gCurrentSide GOTO ourn
		IF c = 0 THEN y = y + 10 * gCityValue(a): GOTO ourn
		x1 = 1: IF gFortLevel(a) = 1 THEN x1 = 2: IF gFortLevel(a) = 3 THEN x1 = 3

		IF gArmySize(c) > 0 THEN
			odds! = gArmySize(index) / (x1 * gArmySize(c))
			IF gRealism > 1 THEN odds! = .8 * odds!
		ELSE
			odds! = 5
		END IF

		IF gArmySize(index) < 15 THEN y = y - 300: odds! = .1
		IF gAIBoldness < 3 AND gArmySize(index) < 40 AND odds! < .8 THEN y = 0
		IF gRealism > 0 THEN y = y - 15
		IF odds! < .5 THEN y = y - 200
		IF gAIBoldness = 0 AND RND > .9 THEN y = y + 10 * (gArmyCommander(index) - gArmyCommander(c) + gArmyExp(index) - gArmyCommander(index))
		IF gArmySupply(index) < 1 THEN y = y - 100
		SELECT CASE odds! + .5 * gAIBoldness
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
			y = y + .5 * (gArmySize(index) - gArmySize(c)) + 50 * RND
		END SELECT
	ourn:
		IF gCityOwner(a) = 3 - gCurrentSide AND c > 0 AND gArmyMove(c) = 0 THEN y = y - gArmySize(c)
		IF gCurrentSide = 1 AND gCityY(a) < gCityY(from) THEN y = y + 2
		IF gCurrentSide = 2 AND gCityY(a) > gCityY(from) THEN y = y + 2
	'---------------------------------------------------------------------------
		FOR k = 1 TO 6: m = gMatrix(a, k): IF m = 0 GOTO tally3
		IF gCityOwner(m) = 0 THEN y = y + 3 * gCityValue(m) + 4 * gFortLevel(m)
		IF gCityOwner(m) = gCurrentSide THEN y = y + 3 * gCityValue(m) + 4 * gFortLevel(m)
		IF gCityOwner(m) = gCurrentSide AND c > 0 THEN
			odds! = 5 - 4 * RND
			IF gArmySize(c) > 0 THEN odds! = gArmySize(index) / gArmySize(c) ELSE odds! = 5
			IF odds! < 1 THEN y = y - 2
		END IF
		IF gCityOwner(m) = gCapitalCity(gCurrentSide) THEN y = y + 50
	tally3:
		NEXT k
	'---------------------------------------------------------------------------
		gArray(j) = y
	alle:
	NEXT j: max = 6
	alleval:
	x = 0: best = 0
	FOR j = 1 TO max
	IF gArray(j) < 0 GOTO allof
		IF gArray(j) > x THEN x = gArray(j): best = j
	allof:
	NEXT j
		IF defend > gArmySize(index) AND gArray(best) < 50 THEN best = 0
		x = best
END SUB

SUB SpecialEvents
	'==========================================================================
	'                              Special Events
	'==========================================================================
	IF gRealism > 0 AND gCurrentYear = 1862 AND gCurrentMonth < 3 THEN
		COLOR 14: CALL ClearBottom
		PRINT "SPECIAL DEVELOPMENT : IRONCLAD ships now available";
		IF gSoundEffects > 0 THEN FOR k = 1 TO 5: SOUND 140, 1: SOUND 37, 1: NEXT k
		DO WHILE INKEY$ = "": LOOP
		EXIT SUB
	END IF
	IF gEventsBalance = 0 THEN EXIT SUB
	plus = gDifficultyLevel: IF gCurrentSide = 1 THEN plus = 6 - gDifficultyLevel
	pct! = .005 * (gCurrentYear - 1860) * plus * plus: IF pct! > .9 THEN pct! = .9
	IF RND > pct! THEN EXIT SUB

	CALL ClearBottom: COLOR 14: PRINT "SPECIAL EVENT...";
	who = 1: IF RND > .1 * gEventsBalance THEN who = 2

	SELECT CASE who
	'----------------------------------------------------------------------------
	'                               good for South
	'----------------------------------------------------------------------------
		CASE 1
		IF gCurrentYear = 1864 AND gCurrentMonth = 1 THEN gVictoryPoints(2) = gVictoryPoints(2) + 50
		IF gCurrentYear = 1865 AND gCurrentMonth = 1 THEN gVictoryPoints(2) = gVictoryPoints(2) + 100
		IF RND > .9 THEN GOSUB riotsincity: EXIT SUB

		CALL ClearBottom
		IF RND > .2 OR gNavySize(2) > 9 GOTO mercenariesjoin
		IF gNavySize(2) > 0 AND gNavyLocation(2) <> 99 THEN empty = gNavyLocation(2): GOTO englandgivesships
			empty = 0
			FOR i = 1 TO 40
			IF gCityOwner(i) = 2 AND gMatrix(i, 7) = 99 AND gNavyLocation(1) <> i THEN empty = i: EXIT FOR
			NEXT i
		IF empty = 0 GOTO mercenariesjoin
	englandgivesships:
		CALL scribe("England has given ships to the South", 2)
		gNavySize(2) = gNavySize(2) + 2 * plus
		IF gNavySize(2) > 10 THEN gNavySize(2) = 10
		x = gNavySize(2) - LEN(gFleet$(2))
		gFleet$(2) = gFleet$(2) + STRING$(x, "W")
		gNavyLocation(2) = empty: CALL ships
		GOTO southeventmusic
	mercenariesjoin:
		IF RND > .1 OR gCityController(2) < 30 GOTO europeloan
		someString$ = "French": IF RND > .5 THEN someString$ = "British"
		CALL scribe(someString$ + " mercenaries join " + gArmyName$(index) + "'s army", 2)
		gArmySize(index) = gArmySize(index) + 100 * plus
		gArmyExp(index) = 10: gArmySupply(index) = 10
		GOTO southeventmusic
	europeloan:
		IF RND > .3 OR gCityController(2) < 12 GOTO cottonsales
			CALL scribe("The South has obtained a loan from Europe", 2)
			GOTO skipcottonsales
	cottonsales:
		IF RND > .5 OR gCityController(2) < 12 GOTO nativeuprising
		CALL scribe("Cash from cotton sales fill the Rebel Treasury", 2)
	skipcottonsales:
		gCurrentCash(2) = gCurrentCash(2) + 100 * plus
		GOTO southeventmusic
	nativeuprising:
		pct! = .9
		someString$ = "Union troops diverted to fight Western Indian uprisings"
		IF RND > .5 THEN someString$ = "Union 90-day enlistees return home"
		IF gCurrentYear = 1864 AND gCurrentMonth > 5 THEN someString$ = "20% of Union forces take furloughs to vote in 1864 elections": pct! = .8
		CALL scribe(someString$, 2)
		FOR k = 1 TO 20
		gArmySize(k) = pct! * gArmySize(k)
		NEXT k
		GOTO southeventmusic
	'----------------------------------------------------------------------------
	riotsincity:
		IF gRealism = 0 THEN RETURN
		IF gCityController(who) = 1 THEN EXIT SUB
		FOR k = 1 TO 99
		x = 1 + INT(40 * RND)
			IF gCityO(x) <> who AND gCityOwner(x) = who AND gIsOccupied(x) = 0 THEN
				CALL ClearBottom: COLOR 15
				PRINT " Riots have broken out in "; gCityName$(x);
				gCityOwner(x) = 0
				CALL DrawCities
				TICK gTurbo!
				CALL ClearBottom
				CALL image2(gCityName$(x) + " is now NEUTRAL !", 4)
				TICK gTurbo!
				RETURN
			END IF
		NEXT k
		RETURN
	'----------------------------------------------------------------------------
	'                               good for Union
	'----------------------------------------------------------------------------
		CASE 2
		IF RND > .1 OR gNavyLocation(1) = 0 OR gNavySize(1) > 9 GOTO unionvolunteers
		IF RND > .95 THEN GOSUB riotsincity: EXIT SUB
		CALL scribe("Union shipworks have produced extra ships", 2)
		gNavySize(1) = gNavySize(1) + plus
		IF gNavySize(1) > 10 THEN gNavySize(1) = 10
		x = gNavySize(1) - LEN(gFleet$(1))
		gFleet$(1) = gFleet$(1) + STRING$(x, "W")
		GOTO northeventmusic
	unionvolunteers:
		IF RND < .7 GOTO emancipated
		CALL scribe("Volunteer troops swell the Union ranks", 2)
		x = 0: FOR i = 1 TO 20: x = x + 1: IF x > 5 GOTO northeventmusic
		IF gArmySize(i) > 0 AND RND > .5 THEN gArmySize(i) = gArmySize(i) * 1.1 + plus
		NEXT i: GOTO northeventmusic
	emancipated:
		IF gEmancipate = 0 AND gCurrentYear > 1862 THEN

			gEmancipate = 1
			CALL scribe("Abraham Lincoln announces the Emancipation Proclamation", 2)
			gVictoryPoints(1) = gVictoryPoints(1) + 100: gVictoryPoints(2) = gVictoryPoints(2) - 100
			CALL DrawMap
			GOTO northeventmusic
		END IF
		IF gCurrentYear = 1864 AND gCurrentMonth = 11 THEN
			CALL scribe("Lincoln has been reelected", 2)
			gVictoryPoints(2) = .5 * gVictoryPoints(2)
			GOTO northeventmusic
		END IF
		IF RND > .5 THEN
			CALL scribe("Wealthy Unionists give generously to the Federal Cause", 2)
			gCurrentCash(1) = gCurrentCash(1) + 100 * plus
			GOTO northeventmusic
		END IF
		IF RND > .5 AND gCurrentYear > 1861 THEN
			CALL scribe("Rebel deserters leave the battlefield to go home", 2)
			FOR i = 21 TO 40: gArmySize(i) = .92 * gArmySize(i): NEXT i: GOTO northeventmusic
		END IF
		IF RND > .5 AND gCurrentYear > 1861 THEN
			CALL scribe("Union soldiers now have repeating rifles", 2)
			FOR i = 1 TO 20
				IF gArmyExp(i) < 9 THEN gArmyExp(i) = gArmyExp(i) + 2
			NEXT i
		END IF
			CALL scribe("Secretary of War Stanton predicts the end of the Rebellion", 2)
			gVictoryPoints(1) = gVictoryPoints(1) + 10: GOTO northeventmusic
		CASE ELSE
	END SELECT

	northeventmusic:
		IF gSoundEffects = 2 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
		DO WHILE INKEY$ = "": LOOP: EXIT SUB
	southeventmusic:
		IF gSoundEffects = 2 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
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
	gMenuText$(1) = someString$
	gTLX = 32 - LEN(someString$) \ 2
	gTLY = 10: gMenuRows = 1
	CALL MenuMaxWidth(wide)
	IF wide > 59 THEN wide = 59: someString$ = LEFT$(someString$, 59)
	x = 8 * (gTLX + wide)
	y = 16 * (gTLY + 1)
		GET (8 * gTLX - 4, 16 * gTLY - 3)-(8 * (gTLX + wide + 1) + 15, 16 * (gTLY + 3) + 7), g2
		VIEW (8 * gTLX - 4, 16 * gTLY - 3)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + 3) + 4)
		CLS 1
		VIEW
		LINE (8 * gTLX, 16 * gTLY - 1)-(8 * (gTLX + wide + 1) + 15, 16 * (gTLY + 3) + 7), 0, BF
		LINE (8 * gTLX - 4, 16 * gTLY - 3)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + 3)), s, BF
		LINE (8 * gTLX - 4, 16 * gTLY - 3)-(8 * (gTLX + wide + 1) + 7, 16 * (gTLY + 3)), 15, B
		COLOR 14
		LOCATE gTLY + 2, gTLX + 2: PRINT someString$
		CALL TICK(9)
		PUT (8 * gTLX - 4, 16 * gTLY - 3), g2, PSET
END SUB

SUB CheckMapIntegrity
	CLS : COLOR 15
	x = 0: y = 0
	FOR i = 1 TO 40
	FOR j = 1 TO 6: IF gMatrix(i, j) = 0 GOTO done
		index = gMatrix(i, j)
		FOR k = 1 TO 6
		IF gMatrix(index, k) = i GOTO ret
		IF gMatrix(index, k) = 0 THEN gMatrix(index, k) = i: PRINT "+ Adding return route from "; gCityName$(index); " to "; gCityName$(i): y = y + 1: GOTO ret
		NEXT k
		x = x + 1: PRINT "Error in CITIES.GRD entry for city #"; i; gCityName$(index); ": no return route to "; gCityName$(i): TICK 1
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
		FOR j = 1 TO LEN(gCityName$(k))
		a = gCityX(k) + 6 * (j - 4) - 3
		x = ASC(MID$(UCASE$(gCityName$(k)), j, 1)) - 64
		IF a > 527 GOTO nextc
		PSET (a, gCityY(k) + 12), 10
		
		IF gMatrix(k, 7) < 90 THEN
			IF gBorderWidth = 0 THEN DRAW "S4C0" ELSE DRAW "S4C7"
		ELSE
			DRAW "C10"
		END IF
		IF x > 0 AND x < 27 THEN DRAW gFont$(x)
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
			COLOR 14, 4: LOCATE 3, 30 * (s - 1) + 10: PRINT gNationName$(s); " HALL of FAME"
			COLOR 15, 0: FOR i = 1 TO 5
			INPUT #1, gCityName$(5 * (s - 1) + i), gMatrix(s, i)
			LOCATE 3 + i, 30 * (s - 1) + 8: PRINT i, gCityName$(5 * (s - 1) + i), gMatrix(s, i)
			NEXT i: NEXT s: CLOSE #1
				
				FOR s = 1 TO 2: FOR i = 1 TO 5
				IF gVictoryPoints(s) < gMatrix(s, i) GOTO oldskor
					FOR j = 5 TO i + 1 STEP -1
					gMatrix(s, j) = gMatrix(s, j - 1)
					gCityName$(5 * (s - 1) + j) = gCityName$(5 * (s - 1) + j - 1)
					NEXT j

				COLOR 15, 1: IF s = 2 THEN COLOR 4, 7
				FOR k = 12 TO 14: LOCATE k, 1: PRINT SPACE$(80); : NEXT k
				LOCATE 12, 1: PRINT "Congratulations ! Score of"; gVictoryPoints(s)
				PRINT "New Entry into "; gNationName$(s); " HALL of FAME in place "; i
				IF gHumanPlayers = 1 AND s <> gCurrentSide THEN someString$ = "COMPUTER": PRINT someString$; " was "; gNationName$(s); " commander": GOTO automate
	who4:
				PRINT "What is name of "; gNationName$(s); " commander"; : INPUT someString$: IF someString$ = "" GOTO who4
	automate:
				gCityName$(5 * (s - 1) + i) = someString$
				gMatrix(s, i) = gVictoryPoints(s): GOTO foun
	oldskor:
				NEXT i
	foun:
				NEXT s
			
			OPEN "O", 1, "hiscore.cws"
			FOR s = 1 TO 2
				FOR i = 1 TO 5
				WRITE #1, gCityName$(5 * (s - 1) + i), gMatrix(s, i)
				NEXT i
			NEXT s: CLOSE #1: PRINT "Game Over": DO WHILE INKEY$ = "": LOOP: gTimesPlayed = 1
END SUB

SUB occupy (x%)
	gIsOccupied(x) = 0
	FOR i = 1 TO 40
	IF gArmyLocation(i) = x THEN gIsOccupied(x) = i: EXIT SUB
	NEXT i
END SUB

SUB relieve (who%)
	gColour = 3: target = 0: gHighlight = 3
	gTLX = 67: gTLY = 2
	CALL StartToFinish(start, fin, who)
	gMenuRows = 0
	FOR i = start TO fin
	IF gArmySize(i) > 0 AND gArmyLocation(i) > 0 AND gArmyMove(i) = 0 THEN
		gMenuRows = gMenuRows + 1
		gMenuText$(gMenuRows) = gArmyName$(i)
		IF LEN(gMenuText$(gMenuRows)) > 11 THEN gMenuText$(gMenuRows) = LEFT$(gMenuText$(gMenuRows), 11)
		gArray(gMenuRows) = i
	END IF
	NEXT i

	IF gMenuRows = 0 THEN EXIT SUB
	CALL bubble(gMenuRows)
	gMenuText$(0) = "Relieve"
	gChosenOption = 31: gHighlight = 11
	CALL ShowMenu(6): CALL ClearRight

	IF gChosenOption < 1 THEN EXIT SUB
	index = gArray(gChosenOption)
	CALL MoveUnitIcon(gArmyLocation(index), 0, 9)

	anotherString$ = gArmyName$(index)
	gLeaderName$(index) = anotherString$

	gMenuRows = 0
	FOR i = start TO fin
	IF gLeaderName$(i) <> "" THEN
		gMenuRows = gMenuRows + 1
		gMenuText$(gMenuRows) = gLeaderName$(i)
		IF LEN(gMenuText$(gMenuRows)) > 11 THEN gMenuText$(gMenuRows) = LEFT$(gMenuText$(gMenuRows), 11)
		gArray(gMenuRows) = i
	END IF
	NEXT i
	CALL bubble(gMenuRows)

	selectnewleader:
	gMenuText$(0) = "New Leader"
	gTLX = 67: gTLY = 2
	CALL ShowMenu(0): CALL ClearRight
	IF gChosenOption < 1 GOTO selectnewleader
	gArmyMove(index) = -1
	gArmyCommander(index) = gLeaderRating(gArray(gChosenOption))
	IF gArmyCommander(index) > 0 THEN gArmyCommander(index) = gArmyCommander(index) - 1
	IF gArmyExp(index) > 0 THEN gArmyExp(index) = gArmyExp(index) - 1
	COLOR 15: CALL ClearBottom: PRINT gLeaderName$(gArray(gChosenOption)); " has replaced "; anotherString$; " in "; gCityName$(gArmyLocation(index)); : TICK 9
	gArmyName$(index) = gLeaderName$(gArray(gChosenOption))
	gLeaderName$(gArray(gChosenOption)) = ""
	CALL MoveUnitIcon(gArmyLocation(index), 0, 8)
	CALL ClearBottom
END SUB

SUB ShowReports (who%)
	DIM summ(40)
	IF who = -1 GOTO forcesummary
	IF who > 100 GOTO battlereport
	gMenuText$(0) = "Information"
	gMenuText$(1) = gNationName$(gCurrentSide) + " Armies"
	gMenuText$(2) = gNationName$(3 - gCurrentSide) + " Armies"
	gMenuText$(3) = "Cities"
	gMenuText$(4) = "Force Summary"
	gMenuText$(5) = "Intelligence"
	gMenuText$(6) = "Battles": gMenuRows = 6
	IF _FILEEXISTS("cws.his") THEN gMenuText$(7) = "Recap": gMenuRows = 7
	CALL ShowMenu(0)
	SELECT CASE gChosenOption
	CASE IS < 0
		CLS
		CALL DrawMap
		EXIT SUB
	CASE 2: who = 3 - gCurrentSide
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
	IF gChosenOption < 0 GOTO endrep
	IF gChosenOption = 4 GOTO forcesummary
	CALL StartToFinish(start, fin, who)
	CLS : LOCATE 1, 1: c = 9: IF who = 2 THEN c = 15
	COLOR c
	PRINT " Report for "; gNationName$(who); " Forces"; TAB(30); gMonthes$(gCurrentMonth); ","; gCurrentYear; TAB(49); : COLOR 14: PRINT " Victory Points "; gVictoryPoints(who);
	IF c = 15 THEN c = 7
	x = gVictoryPoints(who) + gVictoryPoints(3 - who)
	IF x = 0 THEN
		PRINT
	ELSE
		y = (gVictoryPoints(who) / x) * 100
		PRINT "("; y; " %)";
	END IF
	CALL armyxy(215, 8, who)
	COLOR c: PRINT gCityController(who); "/ 40"; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(gCityController(who) * 2.5 + .5): PRINT x; "%)";
	PRINT TAB(50); : COLOR 12: PRINT "Capital: "; gCityName$(gCapitalCity(who))
	y = gVPTotal: IF gCapitalCity(1) > 0 THEN y = y + 100
	IF gCapitalCity(2) > 0 THEN y = y + 100
	PRINT gCurrentIncome(who); "/"; y; TAB(15); "INCOME"; TAB(40); "("; : x = (gCurrentIncome(who) / gVPTotal) * 100: PRINT x; "%)   "; : COLOR 14: PRINT "Cash:"; gCurrentCash(who)
	COLOR 11: PRINT " #      Name             Size  Location   Ldr Exp Suply Move To"
	x = 0: FOR i = start TO fin
	COLOR c
	IF gArmyLocation(i) < 1 GOTO deadeye
	x = x + gArmySize(i)
	PRINT i; TAB(5); gArmyName$(i); TAB(25); : y = CSRLIN
	CALL CorrectArmySize(i): PRINT TAB(32); gCityName$(gArmyLocation(i));
	IF who <> gCurrentSide THEN PRINT : GOTO deadeye
	PRINT TAB(43); gArmyCommander(i); TAB(47); gArmyExp(i); TAB(52); gArmySupply(i);
	PRINT TAB(57); : IF gArmyMove(i) > -1 THEN PRINT gCityName$(gArmyMove(i)) ELSE PRINT "Resting"
	IF gFortLevel(gArmyLocation(i)) > 0 THEN LOCATE y, 68: PRINT "FORT +"; gFortLevel(gArmyLocation(i))
	deadeye:
	NEXT i
	PRINT " "; STRING$(70, "+")
	PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(INT(gAggress! * x))); "00 ]"
	PRINT " "; STRING$(70, "+")
	PRINT " "; gNationName$(who); " NAVY has "; gNavySize(who); " ship(s) ";
	x = 0
	FOR k = 1 TO gNavySize(who)
		IF MID$(gFleet$(who), k, 1) = "I" THEN x = x + 1
	NEXT k
	IF x > 0 THEN PRINT "("; x; "Ironclads) ";
	IF gNavyLocation(who) > 0 AND gNavyLocation(who) < 99 THEN PRINT "in "; gCityName$(gNavyLocation(who)) ELSE PRINT
	IF gRR(who) > 0 THEN COLOR 14: PRINT " Army #"; gRR(who); gArmyName$(gRR(who)); " on train to "; gCityName$(gArmyMove(gRR(who)));
	LINE (0, 0)-(639, 449), 15, B
	LINE (0, 62)-(639, 62), 15
	GOTO endrep
	'..........................................................................
	'                               City Report
	'..........................................................................
	cityreport:
	CLS : LOCATE 1, 1: COLOR 14
	PRINT "City Report"; TAB(20); gMonthes$(gCurrentMonth); ","; gCurrentYear: COLOR 15
	PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"
	LINE (1, 30)-(630, 30), 15
	FOR i = 1 TO 20: COLOR 4: someString$ = "neutral": IF gCityOwner(i) = 1 THEN COLOR 9: someString$ = "UNION"
	IF gCityOwner(i) = 2 THEN COLOR 7: someString$ = "REBEL"
	LOCATE 2 + i, 1: PRINT i; TAB(6); gCityName$(i); TAB(18); someString$; TAB(29); gCityValue(i)
	NEXT i

	FOR i = 21 TO 40: COLOR 4: someString$ = "neutral": IF gCityOwner(i) = 1 THEN COLOR 9: someString$ = "UNION"
	IF gCityOwner(i) = 2 THEN COLOR 7: someString$ = "REBEL"
	LOCATE i - 18, 41: PRINT i; TAB(46); gCityName$(i); TAB(58); someString$; TAB(69); gCityValue(i)
	NEXT i
	LINE (1, 360)-(630, 360), 15
	COLOR 9: LOCATE 24, 1: PRINT "Side    No. Cities   Income    Cash"
	COLOR 9: PRINT gNationName$(1); TAB(12); gCityController(1); TAB(23); gCurrentIncome(1); TAB(32); gCurrentCash(1)
	COLOR 7: PRINT gNationName$(2); TAB(12); gCityController(2); TAB(23); gCurrentIncome(2); TAB(32); gCurrentCash(2)
	COLOR 4: PRINT gNationName$(0); TAB(12); 40 - gCityController(1) - gCityController(2)
	LINE (1, 382)-(630, 382), 15
	GOTO endrep
	'..........................................................................
	'                               Intelligence
	'..........................................................................
	srep:
	c = 9: IF gCurrentSide = 2 THEN c = 7
	CALL DrawMap
	CALL StartToFinish(start, fin, gCurrentSide)
	FOR k = start TO fin
		IF gArmySize(k) > 0 THEN
		COLOR c
		x = gCityX(gArmyLocation(k))
		y = gCityY(gArmyLocation(k))
		z = 10: IF gArmySize(k) < 1000 THEN z = 9
		x = x / 8 - 2: y = y / 16
		IF y > 26 THEN y = 26
		FOR j = 0 TO 3
		LOCATE y + j, x: PRINT SPACE$(z);
		NEXT j
		LOCATE y, x: PRINT "Siz:"; : CALL CorrectArmySize(k)
		LOCATE y + 1, x: PRINT "Ldr:"; gArmyCommander(k)
		LOCATE y + 2, x: PRINT "Xpr:"; gArmyExp(k)
		LOCATE y + 3, x: PRINT "Sup:"; gArmySupply(k);
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
		IF gIsOccupied(k) > 0 THEN
			FOR j = 1 TO 40
			IF gArmyLocation(j) = k THEN summ(k) = summ(k) + gArmySize(j)
			NEXT j
		END IF
	NEXT k

	CLS : CALL DrawMap
	FOR k = 1 TO 40
	IF summ(k) > 0 THEN
		c = 9: IF gCityOwner(k) = 2 THEN c = 7
		COLOR c
		LOCATE INT(gCityY(k) / 16 + 1), gCityX(k) / 8: PRINT summ(k)
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
	LOCATE 14, 38: PRINT gBattleStats(1)
	LOCATE 14, 45: PRINT gBattleStats(2)
	LOCATE 17, 38: PRINT INT(.1 * gCasualty&(1))
	LOCATE 17, 45: PRINT INT(.1 * gCasualty&(2))
	IF gHistory > 0 AND who > 2 THEN
		OPEN "O", #1, "battsumm"
		PRINT #1, " SIDE      BATTLES WON       LOSSES"
		FOR k = 1 TO 2
		someString$ = " ": IF gThrill = k THEN someString$ = "*"
		PRINT #1, someString$; gNationName$(k), gBattleStats(k), 100 * gCasualty&(k)
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
			IF gRealism > 0 THEN
				CALL cutoff(who, gArmyLocation(index), a)
				IF a < 1 THEN EXIT SUB
			END IF
			IF gArmySize(index) > 0 THEN x = gCurrentCash(who) / gArmySize(index) * 10
			y = x + gArmySupply(index): IF y > 5 THEN x = 5 - gArmySupply(index)
			IF x < 1 THEN CALL ClearBottom: PRINT "Not enough funds in the Treasury to supply "; gArmyName$(index); : GOTO nocash
			gArmySupply(index) = gArmySupply(index) + x: gCurrentCash(who) = gCurrentCash(who) - .1 * x * gArmySize(index)
			CALL ClearBottom: PRINT gArmyName$(index); " has received supplies "; : IF gSoundEffects > 0 THEN SOUND 4500, .5
	nocash:
			CALL TICK(gTurbo!): IF gCurrentCash(who) < 0 THEN gCurrentCash(who) = 0
END SUB

SUB retreat (defend%, x%)
	x = 0
	IF gHumanPlayers = 1 THEN
		IF (gCurrentSide = 1 AND defend > 20) OR (gCurrentSide = 2 AND defend < 21) THEN EXIT SUB
	END IF

	gHighlight = 13: gColour = 3: gTLX = 67: gTLY = 5: gMenuRows = 0
	y = gArmyLocation(defend)
	who = 1: IF defend > 20 THEN who = 2
	FOR k = 1 TO 6
		IF gMatrix(y, k) > 0 AND gCityOwner(gMatrix(y, k)) = who THEN gMenuRows = gMenuRows + 1: gMenuText$(gMenuRows) = gCityName$(gMatrix(y, k)): gArray(gMenuRows) = gMatrix(y, k)
	NEXT k
		IF gMenuRows = 0 THEN EXIT SUB
		IF gMenuRows = 1 THEN x = gArray(1): EXIT SUB
		gMenuText$(0) = "Retreat"
		CALL bubble(gMenuRows)
		CALL ShowMenu(9)
		CALL ClearRight
		IF gChosenOption < 0 OR gChosenOption > gMenuRows THEN x = 0: EXIT SUB
		x = gArray(gChosenOption)
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

	IF gSoundEffects < 2 THEN EXIT SUB
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
	x = gStarX(i): y = gStarY(i)
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
			CASE 1: CALL ClearBottom: PRINT someString$;
			CASE 2: CALL image2(someString$, 4)
	END SELECT
	IF gHistory > 0 THEN
		OPEN "A", 2, "cws.his"
		someString$ = LTRIM$(RTRIM$(someString$))
		PRINT #2, someString$
		CLOSE #2
	END IF
END SUB

SUB ShenandoahSong
	IF gSoundEffects = 2 THEN
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
		PLAY "T90MFMNo1c4f8f8f4."
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
		PLAY "g8a8b-8o2d8c4."
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
		PLAY "MLf8e8MNd4.c8d8c8o1a8o2c4.c4d8d8d4."
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
		PLAY "o1a8o2c8o1a8g8f4.g4a4.f8"
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
		PLAY "a8o2d8c4.o1f8g8a4.f8g4f2."
	END IF
END SUB

SUB UnionSong
	IF gCurrentSide = 1 THEN
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "MST170o1e8o0b8o1e8"
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "e8e4f#8g4f#8"
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "g4e8d2o0b8o1d2 "
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "o1e8o0b8o1e8e8e4f#8g4f#8g4a8b2g8b2MLg16a16"
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "MSb4b8b8a8g8a4a8a4f#8g4g8MLg8f#8"
		IF INKEY$ <> "" THEN gChosenOption = 1: EXIT SUB
			PLAY "MSe8f#4f#8f#8g8a8b4.a4.g4.f#4.o0b8o1e8e8e4d8e2."
	ELSE
		CALL ShenandoahSong
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
	IF gNavySize(s) = 0 OR gNavyLocation(s) = 0 THEN gNavyLocation(s) = 0: GOTO sink
	IF gNavyLocation(s) = 30 THEN x = 515: y = 268: GOTO float
	IF gNavyLocation(s) = 28 THEN x = 517: y = 172: GOTO float
	IF gNavyLocation(s) = 17 THEN x = 380: y = 425: GOTO float
	IF gNavyLocation(s) = 99 THEN x = 495: y = 310: GOTO float
	x = gCityX(gNavyLocation(s)) + 25: y = gCityY(gNavyLocation(s)) + 25
	IF gNavyLocation(s) = 24 THEN y = y + 5: x = x - 5
	float:
		PSET (x, y), 1
		a = 1: IF LEFT$(gFleet$(s), 1) = "I" THEN a = 2
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
	IF gArmySize(i) > 0 AND gIsOccupied(gArmyLocation(i)) <> i THEN
		target = gArmyLocation(i)
		x = gCityX(target) - 12: y = gCityY(target) - 12
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
		LOCATE 1, 10: PRINT "Input your decisions now for "; gNationName$(gCurrentSide); " side "; : COLOR 14: PRINT gMonthes$(gCurrentMonth); ","; gCurrentYear; "  "

		CALL DrawFlags((gCurrentSide), 0, 0)
		COLOR 4: IF gBorderWidth > 0 THEN COLOR 7
		LOCATE 6, 68: PRINT "Difficulty "; LTRIM$(RTRIM$(STR$(gDifficultyLevel)))
		LOCATE 7, 68: PRINT "Funds:"; gCurrentCash(gCurrentSide);

		FOR i = 1 TO 2: IF gVictoryPoints(i) < 0 THEN gVictoryPoints(i) = 0
		NEXT i
		x = gVictoryPoints(1) + gVictoryPoints(2): y = 0
		c = 9: IF gCurrentSide = 2 THEN c = 7
		LINE (580, 15)-(580, 35), 15
		LINE (530, 20)-(630, 30), 8 - c, BF
		IF x > 0 THEN y = 100 * (gVictoryPoints(gCurrentSide) / x)

		LINE (530, 20)-(530 + y, 30), c, BF
		COLOR c: LOCATE 4, 68: PRINT "VP :"; gVictoryPoints(gCurrentSide)

		LOCATE 5, 68: PRINT "("; y; "%)"

	someString$ = "  Snd": IF gSoundEffects < 2 THEN someString$ = "   Snd": IF gSoundEffects = 0 THEN someString$ = "      "
	IF gGraphicLevel > 0 THEN someString$ = someString$ + " G" + LTRIM$(STR$(gGraphicLevel))
	someString$ = someString$ + STR$(gHumanPlayers)
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
	IF gRealism = 0 THEN limit = gTrainCapacity(who): EXIT SUB
	x = 11: IF gCurrentSide = 2 THEN x = 23
	limit = gTrainCapacity(who) + 5 * (gCityController(who) - x)
	x = 2 * gTrainCapacity(who)
	IF limit > x THEN limit = x
	IF limit < x \ 4 THEN limit = x \ 4
END SUB

SUB victor
		x = 0: FOR j = 1 TO 20: IF gArmyLocation(j) > 0 THEN x = x + gArmySize(j)
		NEXT j
		y = 0: FOR j = 21 TO 40: IF gArmyLocation(j) > 0 THEN y = y + gArmySize(j)
		NEXT j

		CALL ClearBottom: COLOR 14
		IF gVictoryFlags(2) > 0 AND gCurrentYear >= gVictoryFlags(2) AND gCurrentMonth < gVictoryFlags(1) THEN
			someString$ = "Time almost expired (" + gMonthes$(gVictoryFlags(1)) + "," + STR$(gVictoryFlags(2)) + ")"
			CALL image2(someString$, 4)
		END IF
		FOR i = 1 TO 2
		IF (i = 1 AND y = 0) OR (i = 2 AND x = 0) THEN j = 7: gVictoryPoints(i) = gVictoryPoints(i) + 300: GOTO finis

		IF gCurrentYear >= gVictoryFlags(2) AND gCurrentMonth >= gVictoryFlags(1) AND gVictoryFlags(2) > 0 THEN j = 2: GOTO finis
		IF gCityController(i) >= gVictoryFlags(3) AND gVictoryFlags(3) > 0 THEN j = 3: GOTO finis
		IF gCurrentIncome(i) / (gCurrentIncome(1) + gCurrentIncome(2)) >= .01 * gVictoryFlags(4) AND gVictoryFlags(4) > 0 THEN j = 4: GOTO finis
		IF gVictoryFlags(5) > 0 AND gCapitalCity(3 - i) = 0 AND gCapitalCity(i) > 0 THEN j = 5: GOTO finis

		IF gVictoryFlags(6) > 0 THEN
			IF i = 1 THEN
				IF y = 0 THEN j = 7: GOTO finis
				IF x / y > gVictoryFlags(6) THEN j = 6: GOTO finis
			END IF
			IF i = 2 THEN
				IF x = 0 THEN j = 7: GOTO finis
				IF y / x > gVictoryFlags(6) THEN j = 6: GOTO finis
			END IF
		END IF

		CALL ClearBottom: COLOR 14
		IF gVictoryFlags(3) > 0 AND gCityController(i) >= .9 * gVictoryFlags(3) THEN
			someString$ = gNationName$(i) + " side almost controls" + STR$(gVictoryFlags(3)) + " cities"
			CALL image2(someString$, 4)
		END IF

		IF gVictoryFlags(4) > 0 AND gCurrentIncome(i) / (gCurrentIncome(1) + gCurrentIncome(2)) >= .009 * gVictoryFlags(4) THEN
			someString$ = gNationName$(i) + " side close to" + STR$(gVictoryFlags(4)) + " % of total income"
			CALL image2(someString$, 4)
		END IF

		IF gVictoryFlags(6) > 0 AND x > 0 AND y > 0 THEN
			IF (i = 1 AND x / y > .9 * gVictoryFlags(6)) OR (i = 2 AND y / x > .9 * gVictoryFlags(6)) THEN
			someString$ = gNationName$(i) + "side close to" + STR$(gVictoryFlags(6)) + ":1 strength ratio"
			CALL image2(someString$, 4)
			END IF
		END IF
		GOTO stale

	finis:
		SELECT CASE j
			CASE IS < 3
			someString$ = "TIME EXPIRED"
			CASE 3
			someString$ = STR$(2.5 * gVictoryFlags(3)) + "% CITIES CONTROLLED"
			CASE 4
			someString$ = STR$(gVictoryFlags(4)) + " % OF TOTAL INCOME"
			CASE 5
			someString$ = "CAPITAL CAPTURED"
			CASE 6
			someString$ = STR$(gVictoryFlags(6)) + ":1 ARMY STRENGTH RATIO"
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
		anotherString$ = gNationName$(i) + " SIDE IS WINNING"
		IF j = 2 THEN CALL center(10, "Confederates will win a technical victory") ELSE CALL center(10, anotherString$)

		COLOR 15
		anotherString$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"
		CALL center(12, anotherString$)
		CALL center(14, someString$)

		gMenuText$(0) = "End Game"
		gMenuText$(1) = "Yes"
		gMenuText$(2) = "No-Override"
		gMenuRows = 2: gColour = 4
		gTLX = 27: gTLY = 18
		gHighlight = 15
		IF j = 7 THEN gMenuRows = 1
		CALL ShowMenu(0)

		IF gChosenOption <> 1 AND j < 7 THEN
	play4ever:
				gVictoryFlags(j) = gVictoryFlags(j) + 1
				IF j = 5 THEN gVictoryFlags(j) = 0
				CLS
				CALL DrawMap
				EXIT SUB
		END IF
		gMenuText$(0) = "Options"
		gMenuText$(1) = "Quit this Game"
		gMenuText$(2) = "Play More"
		IF gHumanPlayers = 1 THEN gMenuText$(2) = "No - Press Onward to " + gCityName$(gCapitalCity(3 - gCurrentSide))
		gMenuRows = 2: gColour = 8
		gTLX = 27: gTLY = 18
		IF j <> 7 THEN
			CALL ShowMenu(0)
			IF gChosenOption <> 1 GOTO play4ever
		ELSE
			gVictoryPoints(i) = gVictoryPoints(i) + 100
		END IF

		gThrill = i
		CALL DrawMap: CALL ShowReports(100 + gCurrentSide)
		IF j = 2 THEN FOR k = 1 TO 2: gVictoryPoints(k) = .7 * gVictoryPoints(k): NEXT k: CALL DrawRebelWin: GOTO death

		IF i = 1 THEN CALL DrawUnionWin: COLOR 15: LOCATE 2, 27: anotherString$ = "UNION VICTORY  VP's=" + STR$(gVictoryPoints(1)): PRINT anotherString$: GOTO death
		IF i = 2 THEN CALL DrawRebelWin: COLOR 15: LOCATE 2, 27: anotherString$ = "REBEL VICTORY  VP's=" + STR$(gVictoryPoints(2)): PRINT anotherString$
	death:
		COLOR 14: LOCATE 4, 40 - .5 * LEN(someString$)
		IF gHistory > 0 THEN
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
	x = gMatrix(a, j): IF x = 0 THEN EXIT SUB
	IF gCityOwner(x) = gCurrentSide AND gIsOccupied(x) > 0 THEN y = y + gArmySize(gIsOccupied(x))
		FOR k = 1 TO 6: m = gMatrix(x, k): IF m = 0 OR m = a GOTO tally4
		IF gCityOwner(m) = gCurrentSide AND gIsOccupied(m) > 0 THEN y = y + .1 * gArmySize(gIsOccupied(m))
	tally4:
		NEXT k
	NEXT j
END SUB

SUB AnimateCityFlash (which%)
	FOR c = 1 TO 15 STEP 2
	CIRCLE (gCityX(which), gCityY(which)), 4, 0
	CIRCLE (gCityX(which), gCityY(which)), 3, c
	PAINT (gCityX(which), gCityY(which)), c, c
	CALL TICK(.1)
	NEXT c
	c = 9: IF gCityOwner(which) = 2 THEN c = 7
	IF gCityOwner(which) = 0 THEN c = 12
	CIRCLE (gCityX(which), gCityY(which)), 4, 0
	CIRCLE (gCityX(which), gCityY(which)), 3, c
	PAINT (gCityX(which), gCityY(which)), c, c
END SUB

SUB AnimateMovement (index%, flag%)
	from = gArmyLocation(index): to2 = gArmyMove(index): gArmyLocation(index) = 0
	x = gCityX(from) - 12
	y = gCityY(from) - 11
	x1 = .5 * (gCityX(to2) + gCityX(from))
	y1 = .5 * (gCityY(to2) + gCityY(from))

	CALL occupy(from): IF gIsOccupied(from) > 0 THEN CALL DrawArmyUnit(gIsOccupied(from))
		
	IF flag > 0 GOTO already
		GET (x - 9, y - 7)-(x + 9, y + 6), anima
		IF gIsOccupied(from) = 0 THEN LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
	already:

		FOR i = 2 TO 8
		x1 = .1 * (i * gCityX(to2) + (10 - i) * gCityX(from))
		y1 = .1 * (i * gCityY(to2) + (10 - i) * gCityY(from))
		GET (x1 - 10, y1 - 10)-(x1 + 9, y1 + 9), gGraphicImage
		PUT (x1 - 10, y1 - 10), anima, PSET
		IF gTurbo! > 1 THEN CALL TICK(.1) ELSE CALL TICK(.02)
		IF gSoundEffects > 0 THEN SOUND 200, .1: SOUND 50, .1
		PUT (x1 - 10, y1 - 10), gGraphicImage, PSET
		NEXT i
		gArmyLocation(index) = from
END SUB

SUB DrawCityCaptured (active%, c%, s%, flag%)
	gCityOwner(c) = s: CALL ClearBottom
	someString$ = gArmyName$(active) + " has captured " + gCityName$(c)
	COLOR 11: PRINT gArmyName$(active) + " has captured " + gCityName$(c);
	IF active < 21 AND gSoundEffects > 1 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	IF active > 20 AND gSoundEffects > 1 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	IF c <> gCapitalCity(3 - s) THEN CALL AnimateCityFlash(c)
	gVictoryPoints(s) = gVictoryPoints(s) + gCityValue(c)
	IF c = gCapitalCity(3 - s) THEN
		gVictoryPoints(s) = gVictoryPoints(s) + 100
		gVictoryPoints(3 - s) = gVictoryPoints(3 - s) - 100
		someString$ = gNationName$(3 - s) + " CAPITAL captured !"
		CALL scribe(someString$, 1)
		CALL image2(gCityName$(gCapitalCity(3 - s)) + " has fallen!", 4)
		gCapitalCity(3 - s) = 0
		CALL AnimateCityFlash(c)
	END IF
	IF gFortLevel(c) > 0 AND flag > 0 THEN gFortLevel(c) = gFortLevel(c) - 1: x = gCityX(c): y = gCityY(c): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF: CALL DrawCities
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
	IF who < 99 THEN CALL TICK(gTurbo!)
END SUB

SUB DrawArmyUnit (which%)
	who = 1: IF which > 20 THEN who = 2
	x = gCityX(gArmyLocation(which)) - 12
	y = gCityY(gArmyLocation(which)) - 11
	CALL armyxy(x, y, who)
	IF gArmySupply(which) < 1 THEN
		x = x - 3: y = y + 4
		PSET (x, y), 13: DRAW "C11S8"
		DRAW gFont$(19)
		DRAW "S4"
	END IF
END SUB

SUB DrawCannon
	CALL ClearRight
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
	c = 9: IF gCityOwner(i) = 2 THEN c = 7
	IF gCityOwner(i) = 0 THEN c = 12
	x = gCityX(i): y = gCityY(i)
	IF i = gCapitalCity(1) OR i = gCapitalCity(2) THEN
		PUT (x - 6, y - 6), gUnionCapital, PSET
		LINE (x + 9, y - 4)-(x + 15, y + 4), 0, BF
		LINE (x + 8, y - 5)-(x + 13, y + 2), 3, BF
		PSET (x + 8, y - 4)
		IF gFortLevel(i) = 1 THEN DRAW "BR2C0e1D6BL1R2"
		IF gFortLevel(i) = 2 THEN DRAW "C0e1R1F1D1G3R3"
	ELSE
		IF gFortLevel(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
		IF gFortLevel(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
		CIRCLE (gCityX(i), gCityY(i)), 4, 0
		CIRCLE (gCityX(i), gCityY(i)), 3, c
		PAINT (gCityX(i), gCityY(i)), c, c
	END IF
	IF gGraphicLevel = 0 GOTO nocon
		FOR j = 1 TO 6: IF gMatrix(i, j) > 0 THEN CALL MoveUnitIcon(i, gMatrix(i, j), 11)
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
		PUT (380, 30), gMtn, PSET
		PUT (270, 200), gMtn, PSET
		PUT (310, 160), gMtn, PSET
		PUT (350, 120), gMtn, PSET
		PUT (200, 185), gMtn, PSET
		PUT (250, 130), gMtn, PSET
		PUT (320, 80), gMtn, PSET
		PUT (30, 150), gMtn, PSET
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
	IF gNavyLocation(1) = 30 OR gNavyLocation(2) = 30 THEN
		DRAW "C11U7R4D3L3BR6BU3D7BU4R3U3D7BR3U7BD4BR4BU4D7R4"
		LINE (485, 241)-(525, 270), 11, B
	END IF

	IF gGraphicLevel > 1 THEN CALL maptext
	IF gNavalCommerce > 0 THEN
	LINE (447, 291)-(525, 317), 4, BF: LINE (447, 291)-(525, 317), 10, B
	y = 312
	someString$ = "COMMERCE"
	FOR j = 1 TO LEN(someString$): x = ASC(MID$(UCASE$(someString$), j, 1)) - 64
	PSET (440 + 10 * j, y), 0: DRAW gFont$(x)
	NEXT j
	ELSE
	LINE (447, 291)-(525, 335), 1, BF
	END IF

	FOR i = 1 TO 40
	IF gArmyLocation(i) > 0 THEN CALL DrawArmyUnit(i)
	NEXT i

	FOR k = 1 TO 2
	CALL stax(k)
	NEXT k

	IF gHumanPlayers = 2 GOTO nosee
	FOR i = 1 TO 40: IF gArmyLocation(i) > 0 AND gArmyMove(i) > 0 THEN CALL MoveUnitIcon(gArmyLocation(i), gArmyMove(i), 1)
	NEXT i
	nosee:
	CALL ships
	CALL engine
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(gMonthes$(gCurrentMonth), 3)); ","; gCurrentYear
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
	IF gSoundEffects = 2 THEN PLAY "T130MFMSO2f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4"
	LOCATE 20, 20: PRINT CHR$(34); "... and that the government of the people,"
	IF gSoundEffects = 2 THEN PLAY "o2b-8.a16g8.g16g8.a16b-8.a16b-8.g16f8.g16f8.d16f4"
	LOCATE 21, 20: PRINT "by the people, for the people,"
	IF gSoundEffects = 2 THEN PLAY "f8.f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4b-4MNo3c4c4o2b-4a4b-2"
	LOCATE 22, 20: PRINT "shall not perish from the earth."; CHR$(34)
	LOCATE 25, 40: PRINT "- Abraham Lincoln"
	FOR i = -565 TO 50 STEP 50: CALL DrawFlags(1, i, 0): NEXT i
	IF gSoundEffects = 2 THEN PLAY "P2f4..e-16d8.f16b-8.o3c16d2o2b-2g4..a16b-8.a16b-8.g16f2d2": PLAY "f4..e-16d8.f16b-8.o3c16d2o2b-4b-4o3c4c4o2b-4a4b-2.."
END SUB