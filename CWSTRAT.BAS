DEFINT A-Z
DECLARE SUB animate (index%, flag%)
DECLARE SUB armies ()
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB armystat (index%)
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB barnacle (who%)
DECLARE SUB battle (attack%, defend%, win%, lose%)
DECLARE SUB bub2 (limit%)
DECLARE SUB bubble (globalSize%)
DECLARE SUB cancel (globalSide%)
DECLARE SUB cannon ()
DECLARE SUB capitol ()
DECLARE SUB capture (active%, c%, s%, flag%)
DECLARE SUB center (y%, a$)
DECLARE SUB chessie ()
DECLARE SUB choices (b1%, wide%)
DECLARE SUB clrbot ()
DECLARE SUB combine (who%)
DECLARE SUB clrrite ()
DECLARE SUB commander (who%, empty%)
DECLARE SUB cutoff (who%, target%, a%)
DECLARE SUB endit ()
DECLARE SUB engine ()
DECLARE SUB evaluate (index%, x%)
DECLARE SUB events ()
DECLARE SUB filer (switch%)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB flashcity (which%)
DECLARE SUB fortify (target%)
DECLARE SUB icon (from%, dest%, kind%)
DECLARE SUB image2 (a$, s%)
DECLARE SUB integrity ()
DECLARE SUB ironclad ()
DECLARE SUB iterate ()
DECLARE SUB maptext ()
DECLARE SUB maxx ()
DECLARE SUB menu (switch%)
DECLARE SUB movefrom (index%, target%)
DECLARE SUB mxw (wide%)
DECLARE SUB navy (who%, x%)
DECLARE SUB newarmy (who%, empty%, target%)
DECLARE SUB newcity (index%)
DECLARE SUB normal (xbar%, vary%, result%)
DECLARE SUB occupy (x%)
DECLARE SUB placearmy (which%)
DECLARE SUB railroad (who%)
DECLARE SUB recruit (who%)
DECLARE SUB relieve (who%)
DECLARE SUB report (who%)
DECLARE SUB resupply (index%)
DECLARE SUB retreat (active%, x%)
DECLARE SUB roman (target%, a$)
DECLARE SUB rwin ()
DECLARE SUB schooner ()
DECLARE SUB scribe (a$, flag%)
DECLARE SUB shen ()
DECLARE SUB ships ()
DECLARE SUB shipicon (who%, flag%)
DECLARE SUB shiptype (who%, i%)
DECLARE SUB smarts ()
DECLARE SUB showcity ()
DECLARE SUB snapshot (x%, y%, flag%)
DECLARE SUB starfin (star%, fin%, who%)
DECLARE SUB stax (who%)
DECLARE SUB strong (index%)
DECLARE SUB surrender (who%)
DECLARE SUB TICK (sec!)
DECLARE SUB tinytrain (who%, flag%)
DECLARE SUB topbar ()
DECLARE SUB touchup ()
DECLARE SUB traincapacity (who%, limit%)
DECLARE SUB tupdate ()
DECLARE SUB usa ()
DECLARE SUB victor ()
DECLARE SUB void (a%, y%)

COMMON SHARED globalChoose%, globalTLX%, globalTLY%, globalSize%, globalMTX$(), globalWType%, globalColour%, globalHilite%
COMMON SHARED globalCityX(), globalCityY(), globalCityV(), globalCityP(), globalCity$(), globalLName$(), globalFileL
COMMON SHARED globalCash(), globalControl(), globalMatrix(), globalIncome(), globalAnima(), globalRating(), globalRFlag
COMMON SHARED globalNFlag, globalBold, globalTurbo!, globalRR(), globalStarX(), globalStarY(), globalMtn(), globalRRFrom()
COMMON SHARED globalImage(), globalForce$(), globalArmyLoc(), globalArmyName$(), globalPlayer, globalAggress!
COMMON SHARED globalArmySize(), globalArmyLead(), globalArmyExper(), globalSupply(), globalMonth$()
COMMON SHARED globalRCity(), globalVicFlag(), globalTracks(), globalBatWon(), globalCityO()
COMMON SHARED globalArmyMove(), globalMonth, globalYear, globalArray(), globalMFlag, globalSide, globalATKFAC, globalDEFAC, globalTCR
COMMON SHARED globalNavyLoc(), globalNavySize(), globalNavyMove(), globalOccupied(), globalVPTotal, globalFort()
COMMON SHARED globalVictory(), globalGraf, globalNoise, globalCapCity(), globalDifficult, globalUSAdv, globalBW
COMMON SHARED globalTrain(), globalFont$(), globalBrray(), globalJanCam, globalRandBal, globalRealism, globalCasualty&()
COMMON SHARED globalPCode, globalHistory, globalThrill, globalFleet$(), globalCommerce, globalRaider, globalGrudge

DIM SHARED globalCityX(40), globalCityY(40), globalCityV(40), globalCityP(40), globalCity$(40), globalLName$(40), globalRCity(5)
DIM SHARED globalCash(2), globalControl(2), globalMatrix(40, 7), globalIncome(2), globalAnima(300), globalRating(40)
DIM SHARED globalMTX$(21), globalImage(300), globalForce$(2), globalArmyLoc(40), globalArmyName$(40), globalVicFlag(6)
DIM SHARED globalArmySize(40), globalArmyLead(40), globalArmyExper(40), globalSupply(40), globalMonth$(12)
DIM SHARED globalArmyMove(40), globalArray(40), globalStarX(8), globalStarY(8), globalMtn(1 TO 1564), globalRRFrom(2)
DIM SHARED globalNavyLoc(2), globalNavySize(2), globalNavyMove(2), globalOccupied(40), globalFort(40), globalRR(2)
DIM SHARED globalVictory(2), globalCapCity(2), globalEmancipate, globalTracks(2), globalFleet$(2)
DIM SHARED globalTrain(2), globalFont$(26), globalBrray(40), globalCasualty&(2), globalBatWon(2), globalCityO(40)
DIM SHARED graphic(1 TO 1564), Ncap(60)
DIM SHARED graft(1 TO 1564)

globalReplay = 0
newgame:
globalPCode = 0
globalRFlag = 0
FOR k = 1 TO 40
	globalArmySize(k) = 0
	globalArmyLoc(k) = 0
	globalArmyMove(k) = 0
	globalArmyLead(k) = 0
	globalArmyName$(k) = ""
NEXT k
globalUSAdv = 0
globalEmancipate = 0
FOR k = 1 TO 2
	globalNavySize(k) = 0
	globalNavyLoc(k) = 0
	globalNavyMove(k) = 0
	globalRR(k) = 0
	globalVictory(k) = 0
	globalTracks(k) = 0
NEXT k

globalFileL = 1
globalVicFlag(1) = 1
CALL filer(1)
IF _FILEEXISTS("mtn.vga") THEN
	DEF SEG = VARSEG(globalMtn(1))
	BLOAD "mtn.vga", VARPTR(globalMtn(1))
	DEF SEG
ELSE
	COLOR 15: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'": CALL TICK(9)
END IF

RESTORE
FOR k = 1 TO 26
	READ globalFont$(k)
NEXT k

IF globalRealism > 0 AND globalYear < 1862 THEN
	FOR i = 1 TO 2
		a$ = STRING$(LEN(globalFleet$(i)), "W")
		globalFleet$(i) = a$
	NEXT i
END IF
iron:
IF globalPlayer < 1 OR globalPlayer > 2 THEN globalPlayer = 1
IF globalPlayer = 2 OR globalSide = 0 THEN globalSide = 1
IF globalSide = 1 THEN globalRandBal = 7
IF globalSide = 2 THEN globalRandBal = 3
IF globalTurbo! < 1 THEN globalTurbo! = 2
IF globalSide = 1 AND globalDifficult < 3 THEN globalCash(2) = globalCash(2) + 600 - 100 * globalDifficult
IF globalSide = 2 AND globalDifficult > 3 THEN globalCash(1) = globalCash(1) + 100 * globalDifficult


FOR i = 1 TO 2
	globalIncome(i) = globalCash(i)
	globalCash(i) = globalCash(i) + 50 * RND
NEXT i
globalChoose = 0

SCREEN 12
	DEF SEG = VARSEG(graphic(1))
	BLOAD "cwsicon.vga", VARPTR(graphic(1))
	DEF SEG

	PUT (100, 100), graphic, PSET
	GET (101, 101)-(113, 113), Ncap
CLS
COLOR 11: LOCATE 14, 27: PRINT "VGA CIVIL WAR STRATEGY GAME"
COLOR 4: LOCATE 15, 32: PRINT "Registered Edition"
COLOR 14: LOCATE 28, 1: PRINT TAB(8); "(c) 1998 W. R. Hutsell"
LOCATE 28, 60: PRINT "v1.57"
LINE (190, 170)-(440, 260), 1, B
LINE (180, 180)-(450, 250), 7, B
CALL flags(1, -440, 0): CALL flags(2, -100, 0)
IF globalReplay = 0 AND globalNoise = 2 AND globalChoose = 0 THEN
IF globalSide = 1 THEN
	IF INKEY$ <> "" GOTO notitle
	PLAY "MST170o1e8o0b8o1e8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "e8e4f#8g4f#8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "g4e8d2o0b8o1d2 "
	IF INKEY$ <> "" GOTO notitle
	PLAY "o1e8o0b8o1e8e8e4f#8g4f#8g4a8b2g8b2MLg16a16"
	IF INKEY$ <> "" GOTO notitle
	PLAY "MSb4b8b8a8g8a4a8a4f#8g4g8MLg8f#8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "MSe8f#4f#8f#8g8a8b4.a4.g4.f#4.o0b8o1e8e8e4d8e2."
    ELSE
	CALL shen
    END IF
END IF
notitle:
GOSUB unionplus

globalCity$(0) = "NONE"
OPEN "I", 1, "cities.grd"
globalVPTotal = globalUSAdv + 200
FOR i = 1 TO 40
	INPUT #1, a, globalCityX(i), globalCityY(i), globalCity$(i), globalCityP(i), globalCityV(i)
	globalCityO(i) = globalCityP(i)
	CALL occupy(i)
	FOR j = 1 TO 7
		INPUT #1, globalMatrix(i, j)
	NEXT j
	INPUT #1, globalFort(i)
	IF globalCityP(i) > 0 THEN 
		x = globalCityP(i)
		globalControl(x) = globalControl(x) + 1
		globalVictory(x) = globalVictory(x) + globalCityV(i)
	END IF
	IF globalCityP(i) > 0 THEN 
		globalCash(globalCityP(i)) = globalCash(globalCityP(i)) + globalCityV(i)
	END IF
globalVPTotal = globalVPTotal + globalCityV(i)
NEXT i
CLOSE #1
CALL clrbot

RANDOMIZE TIMER
TICK .3
globalWType = 2
globalHilite = 15
globalReplay = 1
IF globalPlayer = 2 THEN GOSUB blanken
globalMTX$(0) = "VGA CIVILWAR STRATEGY"
globalMTX$(1) = "Resume Saved Game"
globalMTX$(2) = "Start NEW Game"
globalMTX$(3) = "Quit"
globalTLX = 33
globalTLY = 20
globalColour = 5
globalSize = 3
globalChoose = 23
CALL menu(0)
IF globalChoose = 1 THEN
	CLS
	GOTO loader
	GOTO menu0
END IF
IF globalChoose = 3 THEN CLS : END
IF globalHistory = 1 THEN
	CLS
	IF _FILEEXISTS("cws.his") THEN SHELL "copy cws.his oldhist.ory"
	OPEN "O", 2, "cws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
	CLOSE #2
ELSE
	SCREEN 12
	CLS
END IF
CALL usa
GOTO menu0
'==========================================================================
'                              New Month
'==========================================================================
newmonth:
IF globalSide > 2 THEN globalSide = 1
a$ = "--------> EVENTS FOR " + globalMonth$(month) + " " + STR$(globalYear) + " --------"
CALL scribe(a$, 0)
CALL tupdate
globalControl(1) = 0
globalControl(2) = 0

FOR i = 1 TO 2
	globalIncome(i) = 0
	IF globalCash(i) > 19999 THEN globalCash(i) = 19999
	IF globalCash(i) < 0 THEN globalCash(i) = 0
NEXT i
IF globalPlayer = 1 AND globalSide = 2 THEN globalIncome(1) = globalIncome(1) + globalUSAdv

FOR i = 1 TO 40
IF globalCityP(i) > 0 THEN 
	x = globalCityP(i)
	globalControl(x) = globalControl(x) + 1
	globalIncome(x) = globalIncome(x) + globalCityV(i)
END IF
globalArmyMove(i) = 0
NEXT i

FOR i = 1 TO 2
	globalNavyMove(i) = 0
	IF globalCapCity(i) > 0 THEN globalIncome(i) = globalIncome(i) + 100
	globalCash(i) = globalCash(i) + globalIncome(i)
	IF globalCommerce > 0 AND i <> globalCommerce THEN globalCash(i) = globalCash(i) - globalRaider
NEXT i
globalVPTotal = globalIncome(1) + globalIncome(2)

chosit = 22
IF globalPlayer = 2 THEN GOSUB blanken: CALL usa
CALL victor
ON ERROR GOTO 0
IF globalPCode > 0 THEN
	FOR k = 1 TO 40
		globalArmyLoc(k) = 0
	NEXT k
	GOTO newgame
END IF

menu0: '                              Main Menu
CALL topbar
IF globalPlayer = 2 AND globalSide = 0 THEN globalSide = 1
IF globalCash(globalSide) < 100 AND globalNavyLoc(globalSide) = 0 THEN globalNFlag = 1

globalHilite = 11
globalColour = 4
globalTLX = 67: globalTLY = 13
globalMTX$(0) = "Main"
globalMTX$(1) = "Troops": IF globalRFlag < 0 OR globalCash(globalSide) < 100 THEN globalMTX$(1) = "-": chosit = 23
globalMTX$(2) = "Moves": IF globalMFlag > 0 THEN globalMTX$(2) = "-": IF chosit = 23 THEN chosit = 24
globalMTX$(3) = "Ships": IF globalNFlag > 0 THEN globalMTX$(3) = "-": IF chosit = 24 THEN chosit = 25
globalMTX$(4) = "Railroad": IF globalRR(globalSide) > 0 THEN globalMTX$(4) = "-": IF chosit = 25 THEN chosit = 26
globalMTX$(5) = "END TURN"
globalMTX$(6) = "Inform"
globalMTX$(7) = "COMMANDS"
globalMTX$(8) = "UTILITY"
globalMTX$(9) = "Files"

globalSize = 9
globalChoose = chosit
CALL menu(0)
CALL clrrite
'==========================================================================
'                            Main Menu
'==========================================================================
SELECT CASE globalChoose
	CASE 1
		IF globalCash(globalSide) < 100 OR globalRFlag < 0 THEN globalRFlag = -1: GOTO menu0
		CALL recruit((globalSide))
		chosit = 23
		GOTO menu0
	CASE 2
		CALL armies
		chosit = 23
		GOTO menu0
	CASE 3
		IF globalNFlag = 0 THEN CALL navy((globalSide), 0)
		chosit = 25
	CASE 4
		IF globalRR(globalSide) = 0 THEN
			COLOR 15: LOCATE 4, 68: PRINT "RAILROAD MOVE"
			PSET (550, 20), 0
			DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5R1BF4"
			z = 9: IF globalSide = 2 THEN z = 7
			x = POINT(0): y = POINT(1)
			PAINT (x, y), z, 15
			COLOR 15: IF globalSide = 1 THEN COLOR 11
			CALL traincapacity(globalSide, limit)
			CALL clrbot
			PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
			CALL railroad(globalSide)
		ELSE
			CALL clrbot
			COLOR 11: PRINT "Railroad is already carrying "; globalArmyName$(globalRR(globalSide)); " to "; globalCity$(globalArmyMove(globalRR(globalSide)));
			GOTO menu0
		END IF
	CASE 5
		globalTLX = 67: globalTLY = 15
		globalHilite = 15
		globalColour = 3
		globalChoose = 23
		globalMTX$(0) = "End Turn"
		globalMTX$(1) = "Yes"
		globalMTX$(2) = "NOT YET"
		globalSize = 2
		CALL menu(0)
		CALL clrrite
		IF globalChoose <> 1 THEN 
			chosit = 24
			GOTO menu0
		END IF
		endrnd:
		globalRFlag = 0
		globalMFlag = 0
		globalNFlag = 0
		IF globalPlayer = 2 THEN
			globalSide = globalSide + 1
			IF globalSide = 2 THEN 
				GOSUB blanken
				CALL usa
				GOTO menu0
			END IF
		END IF
		GOTO newmonth
	CASE 6
		CALL report((globalSide))
		chosit = 27
		CALL starfin(star, fin, globalSide)
		FOR i = star TO fin
			IF globalArmyMove(i) > 0 THEN CALL icon(globalArmyLoc(i), globalArmyMove(i), 1)
		NEXT i
	CASE 7 ' Commands
		optmen:
		globalTLX = 67
		globalTLY = 13
		COLOR 11: LOCATE globalTLY - 2, globalTLX: PRINT "esc=Main Menu"
		globalHilite = 15
		globalColour = 3
		chosit = 24
		globalMTX$(0) = "Commands"
		globalMTX$(1) = "Cancel"
		globalMTX$(2) = "Fortify": IF globalCash(globalSide) < 200 THEN globalMTX$(2) = "-"
		globalMTX$(3) = "Join"
		globalMTX$(4) = "Supply"
		globalMTX$(5) = "Capital": IF globalCapCity(globalSide) = 0 OR globalCash(globalSide) < 500 THEN globalMTX$(5) = "-"
		globalMTX$(6) = "Detach": IF globalSide = 1 THEN globalMTX$(6) = "-"
		globalMTX$(7) = "Army Drill"
		globalMTX$(8) = "Relieve"
		globalMTX$(9) = "MAIN MENU"
		globalSize = 9
		CALL menu(0)
		CALL clrrite
		chosit = 28
		SELECT CASE globalChoose
			CASE 1 ' Cancel
				CALL cancel(globalSide)
				globalMFlag = 0
				globalChoose = 22
			CASE 2 ' Fortify
				IF globalCash(globalSide) < 200 THEN 
					COLOR 11
					CALL clrbot
					PRINT "Not enough money for fort";
					GOTO menu0
				END IF
				CALL fortify(target)
				IF globalCash(globalSide) < 200 GOTO menu0
				globalChoose = 23
				GOTO optmen
			CASE 3 ' Combine
				x = globalSide
				CALL combine(x)
				IF x < 0 THEN
					CALL clrbot
					COLOR 11
					PRINT "No eligible armies in same city to combine";
					CALL stax(globalSide)
					GOTO menu0
				END IF
				globalChoose = 24
				GOTO optmen
		CASE 4 ' Supply
			CALL starfin(star, fin, (globalSide))
			globalMTX$(0) = "Supply"
			globalTLX = 67: globalTLY = 5: globalColour = 5
			globalSize = 0
			FOR i = star TO fin
				IF globalArmyLoc(i) = 0 OR globalSupply(i) > 1 THEN GOTO alone
				IF globalRealism > 0 THEN
					CALL cutoff(globalSide, globalArmyLoc(i), a)
					IF a < 1 THEN 
						CALL clrbot
						COLOR 15: PRINT globalForce$(globalSide); " army in "; globalCity$(globalArmyLoc(i)); " is CUT OFF !";
						TICK globalTurbo!
						GOTO alone
					END IF
				END IF
				globalSize = globalSize + 1
				max = 11
				IF LEN(globalArmyName$(i)) < 11 THEN max = LEN(globalArmyName$(i))
				globalMTX$(globalSize) = LEFT$(globalArmyName$(i), max)
				globalArray(globalSize) = i
			alone:
			NEXT i
			IF globalSize = 0 THEN 
				COLOR 11
				CALL clrbot
				PRINT "All eligible "; globalForce$(globalSide); " armies have supplies";
				GOTO menu0
			END IF
			CALL menu(6)
			CALL clrrite
			IF globalChoose < 0 GOTO menu0
			index = globalArray(globalChoose)
			IF globalSupply(index) < 2 THEN
			CALL resupply(index)
			CALL placearmy(index)
			END IF
			globalChoose = 25
			GOTO optmen
		CASE 5 ' Move Capital
			IF globalCapCity(globalSide) = 0 OR globalCash(globalSide) < 500 THEN 
				CALL clrbot
				COLOR 11: PRINT "Cannot move capital";
				GOTO menu0
			END IF
			globalCash(globalSide) = globalCash(globalSide) - 500
			globalVictory(3 - globalSide) = globalVictory(3 - globalSide) + 50
			CALL clrrite
			globalMTX$(0) = "Capital"
			a$ = globalCity$(globalCapCity(globalSide))
			index = globalCapCity(globalSide)
			CALL newcity(index)
			IF index = 0 GOTO menu0
			globalCapCity(globalSide) = index
			CALL clrbot: PRINT globalForce$(globalSide); " capital moved from "; a$; " to "; globalCity$(globalCapCity(globalSide));
			CALL clrrite
			CALL showcity
			CALL TICK(9)
			CALL clrbot
		CASE 6 ' Detach Army
			IF globalSide = 1 THEN 
				CALL clrbot
				COLOR 11: PRINT "Option not available to Union";
				GOTO menu0
			END IF
			COLOR 14: LOCATE 4, 68: PRINT "DETACH UNIT"
			CALL movefrom(index, target)
			IF target < 1 OR index < 1 GOTO menu0
			IF globalArmySize(index) < 65 THEN 
				CALL clrbot
				PRINT "Too small to detach";
				CALL TICK(globalTurbo!)
				GOTO menu0
			END IF
			CALL commander(2, empty)
			IF empty = 0 GOTO menu0
			globalSupply(empty) = .3 * globalSupply(index)
			globalSupply(index) = globalSupply(index) - globalSupply(empty)
			IF globalSupply(index) < 0 THEN globalSupply(index) = 0
			globalArmySize(empty) = .3 * globalArmySize(index)
			globalArmySize(index) = globalArmySize(index) - globalArmySize(empty)
			globalArmyLoc(empty) = target
			globalArmyExper(empty) = globalArmyExper(index)
			globalArmyMove(empty) = 0
			globalArmyLead(empty) = globalRating(empty)
			globalArmyName$(empty) = globalLName$(empty)
			globalLName$(empty) = ""
			globalArmyExper(empty) = globalArmyExper(index)
			COLOR 11
			CALL clrbot
			PRINT "Unit #"; empty; " with "; : CALL strong(empty): PRINT " men detached under "; globalArmyName$(empty);
			CALL TICK(globalTurbo!)
			IF globalNoise > 0 THEN SOUND 2222, 1
			CALL stax(globalSide)
			globalChoose = 27
			GOTO optmen
		CASE 7 ' Army Drill
			COLOR 14: LOCATE 4, 68: PRINT "DRILL ARMY"
			CALL movefrom(index, target)
			IF target < 1 OR index < 1 THEN 
				COLOR 11
				CALL clrbot
				PRINT "No armies remain eligible for drills in "; globalMonth$(month);
				GOTO menu0
			END IF
			IF globalArmyExper(index) > 5 OR globalArmyExper(index) >= globalArmyLead(index) THEN
				COLOR 12
				CALL clrbot
				PRINT globalArmyName$(index); ": Army has reached maximum improvement through drilling";
				GOTO optmen
			END IF
			globalArmyExper(index) = globalArmyExper(index) + 1
			CALL clrbot
			PRINT globalArmyName$(index); " has drilled to reach experience level "; globalArmyExper(index);
			IF globalNoise > 0 THEN SOUND 2222, 1
			CALL TICK(globalTurbo!): clrbot
			globalArmyMove(index) = -1
			globalChoose = 28
			GOTO optmen
		CASE 8 ' Relieve Commander
			CALL relieve(globalSide)
			globalChoose = 29
			GOTO optmen
		CASE ELSE
			chosit = 28
			GOTO menu0
      	END SELECT
		globalChoose = 21 + globalChoose
		GOTO optmen
	CASE 8 ' Utility Menu
		utile:
		chosit = 29
		globalMTX$(0) = "Utility"
		globalMTX$(1) = "Side": IF globalPlayer = 2 THEN globalMTX$(2) = ""
		globalMTX$(2) = "1 Player": IF globalPlayer = 2 THEN globalMTX$(2) = "2 Player"
		globalMTX$(3) = "Graphics" + STR$(globalGraf)
		globalMTX$(4) = "Noise": IF globalNoise > 0 THEN globalMTX$(4) = globalMTX$(4) + STRING$(globalNoise, "*")
		globalMTX$(5) = "Display" + STR$(globalTurbo!)
		a$ = STR$(globalDifficult): IF globalSide = 1 THEN a$ = STR$(6 - globalDifficult)
		globalMTX$(6) = "Balance" + a$
		globalMTX$(7) = "End Cond"
		a$ = "�": IF globalRandBal = 0 THEN a$ = ""
		globalMTX$(8) = "Rndom Evt " + a$
		globalMTX$(9) = "Vary Start"
		a$ = "": IF globalJanCam = 1 THEN a$ = "�"
		globalMTX$(10) = "Jan Campgn" + a$
		a$ = "": IF globalRealism = 1 THEN a$ = "�"
		globalMTX$(11) = "Realism " + a$
		globalMTX$(12) = "Chk Links"
		a$ = "": IF globalHistory = 1 THEN a$ = "�"
		globalMTX$(13) = "History" + a$
		globalSize = 13: globalTLX = 67: globalTLY = 11
		COLOR 11: LOCATE globalTLY - 2, globalTLX: PRINT "esc=Main Menu"
		IF globalPlayer = 1 THEN 
			globalSize = 14
			globalMTX$(14) = "Aggress" + STR$(globalBold)
		END IF
		CALL menu(-1)
		CALL clrrite
	    SELECT CASE globalChoose
	    CASE 1 ' Swap Sides
			IF globalPlayer = 2 GOTO menu0
			globalSide = 3 - globalSide
			COLOR 9
			IF globalSide = 2 THEN COLOR 7
			CALL clrbot
			PRINT "Now playing "; globalForce$(globalSide); " side";
			IF globalNoise > 0 THEN SOUND 999, 1
			IF globalSide = 1 THEN globalRandBal = 7
			IF globalSide = 2 THEN globalRandBal = 3
			CALL topbar
			GOTO menu0
	    CASE 2 ' Solo or 2 Player
			globalPlayer = 3 - globalPlayer
			CALL clrbot
			COLOR 12
			IF globalNoise > 0 THEN SOUND 999, 1
			a$ = "Solo"
			IF globalPlayer = 2 THEN a$ = "2 Player"
			PRINT a$; " Game";
			globalChoose = 23
			GOTO utile
	    CASE 3 ' Graphics
			globalGraf = globalGraf + 1
			IF globalGraf > 3 THEN globalGraf = 0
			a$ = "ROADS"
			IF globalGraf = 0 THEN a$ = "DISABLED"
			IF globalGraf = 2 THEN a$ = "CITY NAMES"
			IF globalGraf = 3 THEN a$ = "FULL"
			CLS
			CALL usa
			CALL clrbot
			COLOR 11: PRINT "Graphics : "; a$; 
			IF globalNoise > 0 THEN SOUND 2700, 1
			globalChoose = 24
	    CASE 4 ' Sounds
			CALL clrrite
			globalChoose = globalNoise + 22
			globalMTX$(0) = "SOUNDS"
			globalMTX$(1) = "Quiet"
			globalMTX$(2) = "Sound"
			globalMTX$(3) = " & Sound"
			globalSize = 3
			globalTLX = 67
			globalTLY = 12
			CALL menu(0)
			CALL clrrite
			IF globalChoose < 1 GOTO menu0
			COLOR 11
			CALL clrbot
			PRINT "Sound Option : "; globalMTX$(globalChoose);
			globalNoise = globalChoose - 1
			IF globalNoise > 0 THEN SOUND 999, 1
			globalChoose = 25
			GOTO utile
	    CASE 5 ' Display Speed
			globalChoose = globalTurbo! + 21
			globalMTX$(0) = "Display"
			globalMTX$(1) = "Fast"
			globalMTX$(2) = "Normal"
			globalMTX$(3) = "Slow"
			globalMTX$(4) = "Very Slow"
			globalMTX$(5) = "Reg Color": IF globalBW > 0 THEN globalMTX$(5) = "Alt Color"
			globalTLX = 67: globalTLY = 15: globalSize = 5
			CALL menu(0)
			CALL clrrite
			SELECT CASE globalChoose
				CASE IS < 1
				CASE IS < 5
					globalTurbo! = globalChoose
					IF globalTurbo! = 4 THEN globalTurbo! = 8
					CALL clrbot: COLOR 11
					PRINT "Display Speed : "; globalMTX$(globalChoose);
				CASE 5
					globalBW = 1 - globalBW
					CLS
					CALL usa
					CALL topbar
			END SELECT
			globalChoose = 26
			GOTO utile
	   	CASE 6 ' Play Balance
			globalChoose = globalDifficult + 21
			globalMTX$(0) = "Balance"
			globalMTX$(1) = "Rebel ++"
			globalMTX$(2) = "Rebel +"
			globalMTX$(3) = "Balanced"
			globalMTX$(4) = "Union +"
			globalMTX$(5) = "Union ++"
			globalTLX = 67
			globalTLY = 15
			globalSize = 5
			CALL menu(8)
			CALL clrrite
			IF globalChoose < 1 GOTO menu0
			CALL clrbot
			COLOR 11
			CALL clrbot
			PRINT "Play Balance : "; globalMTX$(globalChoose);
			globalDifficult = globalChoose
			GOSUB unionplus
			globalChoose = 27
			GOTO utile
	   	CASE 7 ' Ending Conditions
			CALL endit
			globalChoose = 28
			GOTO utile
	   	CASE 8 ' Random Events
			globalMTX$(0) = "Random Events"
			globalSize = 4: globalTLX = 30: globalTLY = 8
			globalMTX$(1) = "OFF"
			globalMTX$(2) = "Favor Union ": IF globalRandBal = 3 THEN globalMTX$(2) = globalMTX$(2) + " "
			globalMTX$(3) = "Neutral     ": IF globalRandBal = 5 THEN globalMTX$(3) = globalMTX$(3) + " "
			globalMTX$(4) = "Favor Rebels": IF globalRandBal = 7 THEN globalMTX$(4) = globalMTX$(4) + " "
			globalColour = 5
			CALL menu(0)
			globalColour = 4

			SELECT CASE globalChoose
			CASE 1
				globalRandBal = 0
				t$ = ""
			CASE 2
				globalRandBal = 3
			CASE 3
				globalRandBal = 5
			CASE 4
				globalRandBal = 7
			CASE ELSE
			END SELECT
			IF globalChoose > 1 AND globalChoose < 5 THEN t$ = globalMTX$(globalChoose)
			CALL clrbot
			a$ = ""
			IF globalRandBal = 0 THEN a$ = "OFF"
			COLOR 11: PRINT "Random Events : "; a$; " "; t$;
			COLOR 14: PRINT "			press a key";
			DO WHILE INKEY$ = "": LOOP
			CLS
			CALL usa
			globalChoose = 29
			GOTO utile
	   	CASE 9 ' Vary Start Conditions
			CALL filer(1)
			globalCash(1) = globalCash(1) - 100 + 200 * RND
			globalCash(2) = globalCash(2) + 100 + 200 * RND
			globalBold = 5 * RND
			FOR k = 1 TO 6
				IF RND > .6 THEN
				globalArmyLoc(k) = 0
				globalArmySize(k) = 0
				globalArmyLead(k) = 0
				globalArmyExper(k) = 0
				globalArmyMove(k) = 0
				globalSupply(k) = 0
				END IF
			NEXT k
			FOR k = 21 TO 6
				IF RND > .6 THEN
				globalArmyLoc(k) = 0
				globalArmySize(k) = 0
				globalArmyLead(k) = 0
				globalArmyExper(k) = 0
				globalArmyMove(k) = 0
				globalSupply(k) = 0
				END IF
			NEXT k
			FOR k = 1 TO 40
				CALL occupy(k)
			NEXT k
			globalNavySize(1) = 10 * RND
			IF globalNavySize(1) = 0 THEN globalNavyLoc(1) = 0
			globalNavySize(2) = 10 * RND
			IF globalNavySize(2) > 0 THEN globalNavyLoc(2) = 27
			FOR i = 1 TO 2
				globalFleet$(i) = ""
				FOR j = 1 TO globalNavySize(i)
					a$ = "W"
					IF RND > .45 * globalSide THEN a$ = "I"
					globalFleet$(i) = globalFleet$(i) + a$
				NEXT j
			NEXT i
			IF RND > .7 THEN globalCapCity(2) = 25

			FOR k = 1 TO 40
				IF RND > .8 THEN 
					globalRating(k) = globalRating(k) - 3 + 6 * RND
					IF globalRating(k) > 9 THEN globalRating(k) = 9
				END IF
				IF globalRating(k) < 1 THEN globalRating(k) = 1
			NEXT k
			CLS
			CALL usa
			globalChoose = 30
			GOTO utile
	   	CASE 10 ' January Campaigns
			globalJanCam = 1 - globalJanCam
			a$ = "PROHIBITED"
			IF globalJanCam = 1 THEN a$ = "ALLOWED"
			COLOR 11
			CALL clrbot
			PRINT "January Campaigns : "; a$;
			globalChoose = 31
			GOTO utile
	   	CASE 11 ' Realism Switch
			globalRealism = 1 - globalRealism
			CALL clrbot
			COLOR 11
			IF globalRealism = 0 THEN
				PRINT "Recruiting FIXED :  7000 for NEW Armies   4500 for Additions";
			ELSE
				PRINT "REALISM ON: Recruiting based on CITY SIZE";
				IF globalSide = 2 AND globalRandBal = 1 AND globalRandBal < 5 THEN globalRandBal = globalRandBal + 2
				GOSUB unionplus
			END IF
				globalChoose = 32
				GOTO utile
	   	CASE 12 ' Check Map Links
			CALL integrity
			CALL TICK(99)
			CALL usa
	  	CASE 13 ' History
			globalHistory = 1 - globalHistory
			a$ = "OFF"
			IF globalHistory = 1 THEN a$ = "ON"
			CALL clrbot
			PRINT "History is now "; a$;
			globalChoose = 34
			GOTO utile
	  	CASE 14 ' Aggression
			globalBold = globalBold + 1
			IF globalBold > 5 THEN globalBold = 0
			SELECT CASE globalBold
				CASE 0: a$ = "PASSIVE"
				CASE 1: a$ = "TIMID"
				CASE 2: a$ = "CAUTIOUS"
				CASE 3: a$ = "NORMAL"
				CASE 4: a$ = "BOLD"
				CASE 5: a$ = "RECKLESS"
			END SELECT
			CALL clrbot
			COLOR 11
			PRINT "Enemy Aggression : "; a$; " ("; globalBold; ")";
			globalChoose = 35
			GOTO utile
		CASE ELSE
		END SELECT
	CASE 9 ' Files
		IF NOT _FILEEXISTS("*.sav") THEN globalFileL = 0
		filex:
		globalChoose = 23
		chosit = 30
		IF globalYear = 1861 THEN globalChoose = 22
		globalMTX$(0) = "Options"
		globalMTX$(1) = "Load": IF globalFileL = 0 THEN globalMTX$(1) = "-": globalChoose = 23
		globalMTX$(2) = "Save"
		globalMTX$(3) = "New Game"
		globalMTX$(4) = "Quit"
		globalSize = 4: globalTLX = 67: globalTLY = 15
		CALL menu(0)
		CALL clrrite
		SELECT CASE globalChoose
			CASE IS < 1
				GOTO menu0
			CASE 1, 2
				loader:
				IF globalChoose = 1 AND globalFileL = 0 GOTO filex
				CALL filer(globalChoose + 1)
				IF globalChoose = 1 THEN 
					globalRFlag = 0
					globalMFlag = 0
					globalNFlag = 0
				END IF
				GOTO menu0
			CASE 3
				OPEN "O", 1, "cws.cfg"
				WRITE #1, globalSide, globalGraf, globalNoise, globalDifficult, globalPlayer, globalTurbo!, globalRandBal, globalTrain(1), globalTrain(2), globalJanCam, globalRealism, globalBatWon(1), globalBatWon(2), globalCasualty&(1), globalCasualty&(2), globalHistory, globalBold
				CLOSE #1
				CLS
				GOTO newgame
			CASE 4
				GOTO rusure
		END SELECT
	CASE 99
		GOTO endrnd
	CASE ELSE
		chosit = 22
		GOTO menu0
	END SELECT
	GOTO menu0
	'                               Subs
	topbar:
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR 11
	LOCATE 1, 10: PRINT "Input your decisions now for "; globalForce$(globalSide); " side "; : COLOR 14: PRINT globalMonth$(month); ","; globalYear; "  "
	RETURN

	rusure:
	globalChoose = 23
	globalMTX$(0) = "Quit"
	globalMTX$(1) = "Yes"
	globalMTX$(2) = "No"
	globalSize = 2: globalColour = 5
	globalTLX = 67: globalTLY = 15
	CALL menu(0)
	CALL clrrite
	IF globalChoose = 1 THEN END ELSE GOTO menu0

	unionplus:
	globalUSAdv = 120 * globalDifficult
	IF globalPlayer = 2 THEN globalUSAdv = 50 * globalDifficult
	IF globalRealism > 0 THEN globalUSAdv = globalUSAdv * .7
	RETURN

	blanken:        
	c = 1
	IF globalSide = 2 THEN c = 7
	CLS
	LINE (100, 200)-(500, 300), c, BF
	LINE (100, 200)-(500, 300), 8 - c, B
	COLOR 7: LOCATE 14, 31: PRINT " "; globalMonth$(month); globalYear
	COLOR 11: LOCATE 17, 30: PRINT globalForce$(globalSide); " PLAYER TURN"
	DO WHILE INKEY$ = "": LOOP
	RETURN

	DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
	DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
	DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
	DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
	DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
	DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
	DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"

SUB animate (index, flag)
	from = globalArmyLoc(index)
	to2 = globalArmyMove(index)
	globalArmyLoc(index) = 0
	x = globalCityX(from) - 12
	y = globalCityY(from) - 11
	x1 = .5 * (globalCityX(to2) + globalCityX(from))
	y1 = .5 * (globalCityY(to2) + globalCityY(from))

	CALL occupy(from)
	IF globalOccupied(from) > 0 THEN CALL placearmy(globalOccupied(from))
       
	IF flag > 0 GOTO already
	GET (x - 9, y - 7)-(x + 9, y + 6), globalAnima
	IF globalOccupied(from) = 0 THEN LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
	already:

	FOR i = 2 TO 8
		x1 = .1 * (i * globalCityX(to2) + (10 - i) * globalCityX(from))
		y1 = .1 * (i * globalCityY(to2) + (10 - i) * globalCityY(from))
		GET (x1 - 10, y1 - 10)-(x1 + 9, y1 + 9), globalImage
		PUT (x1 - 10, y1 - 10), globalAnima, PSET
		IF globalTurbo! > 1 THEN 
			CALL TICK(.1) 
		ELSE 
			CALL TICK(.02)
		END IF
		IF globalNoise > 0 THEN SOUND 200, .1: SOUND 50, .1
		PUT (x1 - 10, y1 - 10), globalImage, PSET
	NEXT i
	globalArmyLoc(index) = from
END SUB

SUB armies
	CALL movefrom(index, target)
	IF target > 0 AND index > 0 GOTO tent
	IF index = -1 THEN globalMFlag = 1
	GOTO dudd
	tent:
	globalTLX = 67: globalTLY = 12

	CALL armystat(index)
	COLOR 11: LOCATE 11, 68: PRINT globalCity$(target)
	globalSize = 0
	globalMTX$(0) = "To"
	FOR i = 1 TO 6
		IF globalMatrix(target, i) > 0 THEN 
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalCity$(globalMatrix(target, i))
			globalArray(globalSize) = globalMatrix(target, i)
		END IF
	NEXT i
	CALL bubble(globalSize)

	globalHilite = 10
	globalColour = 3
	CALL menu(2)
	CALL clrrite
	IF globalChoose < 0 GOTO dudd
	IF month < 3 AND globalJanCam = 0 AND globalCityP(globalArray(globalChoose)) <> globalSide THEN 
		COLOR 11
		CALL clrbot
		PRINT "No campaigns in January"; 
		CALL TICK(9)
		CALL clrbot
		GOTO dudd
	END IF

	CALL clrbot
	PRINT "Army "; index; " "; globalArmyName$(index); " is moving from "; globalCity$(target); " to "; globalCity$(globalArray(globalChoose));
	IF globalNoise > 0 THEN SOUND 2200, .5: SOUND 2900, .7
	CALL icon(target, globalArray(globalChoose), 1)
	globalArmyMove(index) = globalArray(globalChoose)
	CALL TICK(globalTurbo!)
	CALL clrbot
	CALL clrrite
dudd:
END SUB

SUB armystat (index)
	LINE (530, 60)-(639, 150), 0, BF
	COLOR 15
	LOCATE 5, 68: PRINT globalArmyName$(index)
	COLOR 9
	IF index > 20 THEN COLOR 7
	LOCATE 6, 68: PRINT "Size:"; : CALL strong(index)
	LOCATE 7, 68: PRINT "Leader:"; TAB(75); globalArmyLead(index)
	LOCATE 8, 68: PRINT "Exper:"; TAB(75); globalArmyExper(index)
	IF globalSupply(index) < 2 THEN COLOR 12
	LOCATE 9, 68: PRINT "Supply:"; TAB(75); globalSupply(index)
END SUB

SUB barnacle (who)
	globalNavySize(who) = globalNavySize(who) - 1
	IF globalNavySize(who) > 0 THEN
		globalFleet$(who) = LEFT$(globalFleet$(who), globalNavySize(who))
	ELSE
		globalFleet$(who) = ""
		globalNavyLoc(who) = 0
		globalNavySize(who) = 0
	END IF
END SUB

SUB battle (attack, defend, win, lose)
	IF globalArmySize(defend) < 1 THEN globalArmySize(defend) = 1
	IF globalArmySize(attack) < 1 THEN globalArmySize(attack) = 1

	CALL icon(globalArmyLoc(defend), 0, 9)
	LOCATE 1, 1: PRINT SPACE$(80)
	CALL clrrite
	y = 68
	COLOR 11: LOCATE 1, y: PRINT "Attacker"
	c = 9
	IF attack > 20 THEN c = 7
	COLOR c: LOCATE 2, y: PRINT globalArmyName$(attack)
	LOCATE 3, y: CALL strong(attack)
	x = .01 * globalArmySize(attack)
	IF x > globalTCR THEN x = globalTCR
	LOCATE 4, y: PRINT "Base    "; x
	IF globalArmySize(attack) / globalArmySize(defend) > .2 THEN 
		x = x + .3 * globalArmyLead(attack) + .3 * globalArmyExper(attack)
		IF x > globalTCR THEN x = globalTCR
	END IF
	IF globalArmyExper(attack) > 8 THEN 
		x = x + 1
		IF x > globalTCR THEN x = globalTCR
	END IF
	LOCATE 5, y: PRINT "Ldr/Exp "; x
	IF globalArmySize(attack) < 15 THEN 
		x = .5 * x
		IF x > globalTCR THEN x = globalTCR
	END IF
	LOCATE 6, y: PRINT "Small   "; x
	IF globalArmySize(attack) / globalArmySize(defend) <= .5 THEN 
		x = x - 2
		IF x < 1 THEN x = 1
	END IF
	IF globalArmySize(attack) / globalArmySize(defend) > 3 THEN 
		x = x + 2
		IF x > globalTCR THEN x = globalTCR
	END IF
	IF globalArmySize(attack) / globalArmySize(defend) > 10 THEN x = globalTCR
	IF globalArmySize(attack) / globalArmySize(defend) <= .2 THEN x = 1
	LOCATE 7, y: PRINT "Outman  "; x
	IF globalSupply(attack) < 1 THEN 
		x = .5 * x
		COLOR 13
	END IF
	LOCATE 8, y: PRINT "Supply  "; x: COLOR c
	IF x < 1 THEN x = 1
	'                       Adjust attack advantage
	IF attack < 21 AND globalSide = 2 AND globalDifficult > 3 THEN x = x + 2 * globalDifficult - 6
	IF attack > 20 AND globalSide = 1 AND globalDifficult < 3 THEN x = x + 6 - 2 * globalDifficult
	LOCATE 9, y: PRINT "Difclt  "; x
	IF x > globalTCR THEN x = globalTCR
	COLOR 11: LOCATE 11, y: PRINT "Attack  "; x
	LINE (530, 155)-(635, 175), 11, B

	x1 = .013 * globalArmySize(defend) + 1
	IF globalRealism = 1 THEN 
		x1 = .02 * globalArmySize(defend) + 2
		IF x1 > 20 THEN x1 = 20
	END IF
	LOCATE 13, y: PRINT "Defender"
	COLOR 16 - c: LOCATE 14, y: PRINT globalArmyName$(defend)
	LOCATE 15, y: CALL strong(defend)
	LOCATE 16, y: PRINT "Base    "; INT(.01 * globalArmySize(defend))
	LOCATE 17, y: PRINT "Defense "; x1
	IF globalArmySize(defend) / globalArmySize(attack) > .2 THEN 
		x1 = x1 + .3 * globalArmyLead(defend) + .3 * globalArmyExper(defend)
		IF x1 > globalTCR THEN x1 = globalTCR
	END IF
	IF globalArmyExper(defend) > 8 THEN 
		x1 = x1 + 1
		IF x1 > globalTCR THEN x1 = globalTCR
	END IF
	LOCATE 18, y: PRINT "Ldr/Exp "; x1
	IF globalArmySize(defend) < 15 THEN x1 = .5 * x1
	LOCATE 19, y: PRINT "Small   "; x1

	R! = globalArmySize(defend) / globalArmySize(attack)
	SELECT CASE R!
		CASE IS > 10
			x1 = globalTCR
		CASE IS > 1.5
			x1 = x1 + 2
		CASE IS < .5
			x1 = .8 * x1
		CASE IS < .2
			x1 = .5 * x1
	END SELECT
		IF x1 < 1 THEN x1 = 1
		IF x1 > globalTCR THEN x1 = globalTCR

	LOCATE 20, y: PRINT "Outman  "; x1
	IF globalSupply(defend) < 1 THEN 
		x1 = .5 * x1
		COLOR 13
	END IF
	LOCATE 21, y: PRINT "Supply  "; x1: COLOR 16 - c
	IF x1 < 1 THEN x1 = 1
	'                       Adjust defend advantage
	IF defend < 21 AND globalSide = 2 AND globalDifficult > 3 THEN x1 = x1 + 2 * globalDifficult - 6
	IF defend > 20 AND globalSide = 1 AND globalDifficult < 3 THEN x1 = x1 + 6 - 2 * globalDifficult
	LOCATE 22, y: PRINT "Difclt  "; x1

	a$ = "Fort"
	IF globalArmyMove(defend) = 0 THEN 
		x1 = x1 * (1 + globalFort(globalArmyLoc(defend)))
	END IF
	IF x1 > globalTCR THEN x1 = globalTCR
	IF globalFort(globalArmyLoc(defend)) > 0 AND globalArmyMove(defend) = 0 THEN
		COLOR 13
		a$ = "Fort+"
		IF globalFort(globalArmyLoc(defend)) = 2 THEN 
			a$ = "Fort++"
		END IF
	END IF
	LOCATE 23, y: PRINT a$; TAB(76); x1
	IF x1 > globalTCR THEN x1 = globalTCR
	COLOR 11: LOCATE 25, y: PRINT "Defend  "; x1
	LINE (530, 380)-(635, 400), 11, B

	spin = 0
	scale = x
	IF x1 > scale THEN scale = x1
	scale = scale + 1

	odds! = x / (x + x1)
	a = INT(100 * odds!)
	IF a < 1 THEN a = 1
	a$ = LTRIM$(RTRIM$(STR$(a))) + "%"
	COLOR 14: LOCATE 27, y: PRINT "Odds:  "; a$;
	LINE (530, 412)-(635, 435), 14, B
	LINE (528, 410)-(637, 437), 14, B
	DO WHILE INKEY$ = "": LOOP
	IF globalGraf > 2 THEN
		CALL cannon
		k = globalFort(globalArmyLoc(defend))
		t$ = "fort" + LTRIM$(STR$(k)) + ".vga"
		IF _FILEEXISTS(t$) THEN
			DEF SEG = VARSEG(graphic(1))
			BLOAD t$, VARPTR(graphic(1))
			DEF SEG
			PUT (550, 270), graphic, PSET
		END IF
	ELSE
		CALL clrrite
	END IF
	FOR i = 1 TO 2
		IF globalSupply(i) > 0 THEN globalSupply(i) = globalSupply(i) - 1
	NEXT i
	'---------------------------------------------------------------------------
	grapple:
	hit = 0
	hit1 = 0
	star = scale * RND
	fin = scale * RND
	IF globalNoise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	IF star <= x THEN hit = 1
	IF fin <= x1 THEN hit1 = 1

	IF hit = 0 AND hit1 = 0 GOTO grapple
	IF hit = 1 AND hit1 = 1 GOTO grapple
	win = defend
	lose = attack
	IF hit = 1 THEN 
		win = attack
		lose = defend
	END IF
	'---------------------------------------------------------------------------
	a$ = "UNION"
	IF win > 20 THEN a$ = "REBEL"
	COLOR 14: LOCATE 3, 68: PRINT a$; " VICTORY"
	LOCATE 4, 71: PRINT "in"
	LOCATE 5, 69: PRINT globalCity$(globalArmyLoc(defend))
	a = 1
	IF win > 20 THEN a = 2
	CALL flags(a, 0, 0)
	CALL clrbot
	COLOR 11: PRINT globalArmyName$(win); " defeats "; globalArmyName$(lose); " in "; globalCity$(globalArmyLoc(defend));
	CALL TICK(9)

	pct! = .01 * globalDEFAC - .03 * globalFort(globalArmyLoc(defend))
	IF win = attack THEN pct! = 1.3 * pct!
	SELECT CASE globalArmySize(defend)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = globalArmySize(attack) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killd)

	pct! = .01 * globalATKFAC + .02 * globalFort(globalArmyLoc(defend))
	IF win = defend THEN pct! = 1.5 * pct!
	SELECT CASE globalArmySize(attack)
		CASE IS > 300
			pct! = .9 * pct!
		CASE IS > 800
			pct! = .8 * pct!
	END SELECT
	xbar = globalArmySize(defend) * pct!
	vary = xbar * (1 - pct!)
	CALL normal(xbar, vary, killa)

	killa = .8 * killa + .2 * killd
	IF killa < 1 THEN killa = 1
	killd = .8 * killd + .2 * killa
	IF killd < 1 THEN killd = 1
	IF killa > 9 * killd THEN killa = 9 * killd
	IF killd > 5 * killa THEN killd = 5 * killa

	IF killa >= globalArmySize(attack) THEN killa = globalArmySize(attack) - 1
	IF killd >= globalArmySize(defend) THEN killd = globalArmySize(defend) - 1

	x = INT(100 * odds!): IF x < 1 THEN x = 1
	a$ = LTRIM$(RTRIM$(STR$(x))) + "%"

	COLOR c
	LOCATE 1, 1: PRINT "Attack Loss: ";
	PRINT LTRIM$(RTRIM$(STR$(killa)) + "00"); "/";
	CALL strong(attack)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / globalArmySize(attack)))))); "%) �";
	COLOR 16 - c: PRINT "� Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
	CALL strong(defend)
	PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killd / globalArmySize(defend)))))); "%)"

	globalMTX$(1) = " (" + LTRIM$(RTRIM$(STR$(killa) + "00")) + "/" + LTRIM$(STR$(globalArmySize(attack)) + "00") + ") "
	t$ = " (" + LTRIM$(RTRIM$(STR$(killd) + "00")) + "/" + LTRIM$(STR$(globalArmySize(defend)) + "00") + ")"
	globalMTX$(2) = t$
	IF win = defend THEN 
		globalMTX$(2) = globalMTX$(1)
		globalMTX$(1) = t$
	END IF
	globalMTX$(3) = "*" + globalArmyName$(win)
	globalMTX$(4) = globalArmyName$(lose)
	IF win = defend THEN 
		globalMTX$(3) = globalArmyName$(win)
		globalMTX$(4) = "*" + globalArmyName$(lose)
	END IF
	a$ = globalCity$(globalArmyLoc(defend)) + ": " + globalMTX$(3) + globalMTX$(1) + " defeats " + globalMTX$(4) + globalMTX$(2)
	CALL scribe(a$, 0)

	IF globalPlayer = 1 AND (globalSide = 1 AND attack > 20) OR (globalSide = 2 AND attack < 21) THEN
		COLOR 14
		CALL clrbot
		PRINT "hit any key to continue"; : DO WHILE INKEY$ = "": LOOP
	END IF

	globalArmySize(attack) = globalArmySize(attack) - killa
	globalArmySize(defend) = globalArmySize(defend) - killd
	IF globalArmySize(defend) < 1 THEN globalArmySize(defend) = 1

	s = 1
	IF attack > 2 THEN s = 2
	globalCasualty&(s) = globalCasualty&(s) + killa
	globalCasualty&(3 - s) = globalCasualty&(3 - s) + killd

	s = 1
	IF win > 20 THEN s = 2
	globalBatWon(s) = globalBatWon(s) + 1
	globalVictory(s) = globalVictory(s) + 1
	CALL icon(globalArmyLoc(defend), 0, 8)
END SUB

SUB combine (who)
	globalColour = 3
	target = 0
	globalHilite = 3
	globalTLX = 67: globalTLY = 2
	CALL starfin(star, fin, who)
	globalSize = 0
	FOR i = 1 TO 40
		IF globalCityP(i) = who AND globalOccupied(i) > 0 THEN
			FOR j = star TO fin
				IF globalArmyLoc(j) = i AND globalOccupied(i) <> j AND globalArmyMove(j) = 0 THEN 
					globalSize = globalSize + 1
					globalMTX$(globalSize) = globalCity$(i)
					globalArray(globalSize) = i
					EXIT FOR
				END IF
			NEXT j
		END IF
	NEXT i
	
	IF globalSize = 0 THEN who = -1: EXIT SUB
	CALL bubble(globalSize)

	IF who <> globalSide THEN 
		globalChoose = 1 + INT(globalSize * RND)
		GOTO join
	END IF
	globalMTX$(0) = "Join"
	globalChoose = 31
	globalHilite = 11
	CALL menu(9)
	CALL clrrite
	join:
	IF globalChoose < 1 THEN GOTO nocity2
	target = globalArray(globalChoose)
	CALL clrbot
	PRINT "Combining "; globalForce$(who); " armies in "; globalCity$(target);
	CALL TICK(globalTurbo!)

	globalArmySize(0) = 0
	globalArmyLead(0) = 0
	globalArmyExper(0) = 0
	globalArmyLoc(0) = target
	globalArmyName$(0) = ""
	globalSupply(0) = 0
	globalArmyMove(0) = 0

	best = 0
	x = 0
	spin = 0
	FOR j = star TO fin
		IF globalArmyMove(j) <> 0 OR globalArmyLoc(j) <> target OR globalArmySize(j) = 0 THEN GOTO dork1
		IF globalArmySize(0) + globalArmySize(j) > 1250 THEN 
			CALL clrbot
			PRINT "Cannot combine "; globalArmyName$(j); "... TOO LARGE";
			CALL TICK(globalTurbo!)
			GOTO dork1
		END IF

		IF globalArmyLead(j) > x THEN
			x = globalArmyLead(j)
			globalArmyName$(0) = globalArmyName$(j)
			globalArmyLead(0) = globalArmyLead(j)
			best = j
		END IF

		globalArmySize(0) = globalArmySize(0) + globalArmySize(j)
		IF globalArmySize(0) < 1 GOTO dork1
		pct! = (globalArmySize(j) / globalArmySize(0))
		spin = spin + 1
		globalArmyExper(0) = (1 - pct!) * globalArmyExper(0) + pct! * globalArmyExper(j)
		CALL clrbot
		PRINT globalArmyName$(j); " is combining his "; : CALL strong(j): PRINT " forces";
		CALL TICK(globalTurbo!)
		globalSupply(0) = globalSupply(0) + globalSupply(j)
		IF globalSupply(0) > 10 THEN globalSupply(0) = 10
		globalArmySize(j) = 0
		globalArmyLoc(j) = 0
		globalArmyExper(j) = 0
		globalArmyMove(j) = 0
		globalLName$(j) = globalArmyName$(j)
		globalArmyLead(j) = 0
		globalSupply(j) = 0
		globalArmyName$(j) = ""
	dork1:
	NEXT j

	CALL clrbot
	IF who <> globalSide AND spin = 0 THEN EXIT SUB
	IF spin = 0 THEN
		PRINT "No valid armies to combine at this time in "; globalCity$(target);
		TICK globalTurbo!
		EXIT SUB
	END IF
	globalArmySize(best) = globalArmySize(0)
	globalArmyLead(best) = globalArmyLead(0)
	globalArmyExper(best) = globalArmyExper(0)
	globalSupply(best) = globalSupply(0)
	globalArmyLoc(best) = target
	globalArmyName$(best) = globalArmyName$(0)
	globalLName$(best) = ""
	IF spin > 1 THEN
		PRINT "New army "; best; " of "; : CALL strong(best): PRINT " is commanded by "; globalArmyName$(best);
		globalArmyMove(best) = -1
	ELSE
		PRINT "Only 1 eligible army -- cannot combine at this time";
	END IF
	IF who = globalSide THEN CALL TICK(globalTurbo!)
	IF globalNoise > 0 THEN SOUND 4000, .7
	       
	CALL showcity
	CALL placearmy(best)
	CALL icon(target, 0, 6)
	globalOccupied(target) = best
	CALL stax(who)
nocity2:
END SUB

SUB cutoff (who, target, a)
	a = 0
	FOR j = 1 TO 6
		y = globalMatrix(target, j)
		IF y > 0 AND globalCityP(y) = who THEN a = a + 1
	NEXT j
END SUB

SUB filer (switch)
	SELECT CASE switch
		CASE 1
			OPEN "I", 1, "cwslead.dat"
			FOR i = 1 TO 40
				INPUT #1, globalLName$(i), globalRating(i)
			NEXT i
			CLOSE #1
			OPEN "I", 1, "cws.ini"
			FOR i = 0 TO 2
				INPUT #1, globalForce$(i)
			NEXT i
			FOR i = 1 TO 12
				INPUT #1, globalMonth$(i)
			NEXT i
			INPUT #1, month, globalYear
			'               set end game conditions
			FOR i = 1 TO 6
				INPUT #1, globalVicFlag(i)
			NEXT i
			globalVicFlag(3) = .4 * globalVicFlag(3)
			INPUT #1, a             ' number of Yankee armies
			FOR i = 1 TO a
				INPUT #1, globalArmyLoc(i), globalArmySize(i), globalArmyExper(i), globalSupply(i)
				globalOccupied(globalArmyLoc(i)) = i
				globalArmyName$(i) = globalLName$(i)
				globalArmyLead(i) = globalRating(i)
				globalLName$(i) = ""
			NEXT i
			INPUT #1, a             ' number of Rebel armies
			FOR i = 21 TO 20 + a
				INPUT #1, globalArmyLoc(i), globalArmySize(i), globalArmyExper(i), globalSupply(i)
				globalOccupied(globalArmyLoc(i)) = i
				globalArmyName$(i) = globalLName$(i)
				globalArmyLead(i) = globalRating(i)
				globalLName$(i) = ""
			NEXT i
			FOR i = 1 TO 2
				INPUT #1, globalCash(i)
			NEXT i
			INPUT #1, globalATKFAC, globalDEFAC, globalTCR
			INPUT #1, globalFleet$(1), globalNavyLoc(1), globalFleet$(2), globalNavyLoc(2)
			FOR k = 1 TO 2
				globalNavySize(k) = LEN(globalFleet$(k))
			NEXT k
			INPUT #1, globalCapCity(1), globalCapCity(2)
			FOR i = 1 TO 8 ' star locations on flag
				INPUT #1, globalStarX(i), globalStarY(i)
			NEXT i
			CLOSE #1
			OPEN "I", 1, "cws.cfg"
			INPUT #1, globalSide, globalGraf, globalNoise, globalDifficult, globalPlayer, globalTurbo!, globalRandBal, globalTrain(1), globalTrain(2), globalJanCam, globalRealism, globalBatWon(1), globalBatWon(2), globalCasualty&(1), globalCasualty&(2), globalHistory, globalBold
			CLOSE #1
		CASE 2
			IF NOT _FILEEXISTS("*.sav") THEN globalChoose = -1: EXIT SUB
			globalMTX$(0) = "Load"
			globalSize = 0
			FOR k = 1 TO 9
				t$ = "cws" + LTRIM$(STR$(k)) + ".sav"
				IF _FILEEXISTS(t$) THEN
					globalSize = globalSize + 1
					globalMTX$(globalSize) = t$
					globalArray(globalSize) = k
				END IF
			NEXT k
			CALL bubble((globalSize))
			globalTLX = 67: globalTLY = 14 - .5 * globalSize
			CALL menu(0)
			CALL clrrite
			IF globalChoose < 1 THEN EXIT SUB
			OPEN "I", 1, "cws" + LTRIM$(STR$(globalArray(globalChoose))) + ".sav"
			COLOR 11
			CALL clrbot
			PRINT "Loading";
			INPUT #1, month, globalYear, globalUSAdv, a
			FOR i = 1 TO 40
				INPUT #1, globalArmyName$(i), globalArmySize(i), globalArmyLead(i), globalArmyLoc(i), globalArmyExper(i), globalSupply(i), globalArmyMove(i)
				IF globalArmyLoc(i) > 0 THEN
					IF globalArmyName$(i) = globalLName$(i) THEN
						globalLName$(i) = ""
					ELSE
						who = 1
						IF i > 20 THEN who = 2
						CALL starfin(star, fin, who)
						FOR k = star TO fin
							IF globalArmyName$(i) = globalLName$(k) THEN globalLName$(k) = "": EXIT FOR
						NEXT k
					END IF
				END IF
			NEXT i
			FOR i = 1 TO 40
				INPUT #1, globalOccupied(i), globalCityP(i), globalFort(i)
				PRINT ".";
			NEXT i
			FOR i = 1 TO 2
				INPUT #1, globalCash(i), globalControl(i), globalIncome(i), globalVictory(i), globalCapCity(i)
				INPUT #1, globalFleet$(i), globalNavyLoc(i), globalNavyMove(i), globalRR(i), globalTracks(i)
				globalNavySize(i) = LEN(globalFleet$(i))
			NEXT i
			CLOSE #1
			OPEN "I", 1, "cws.cfg"
			INPUT #1, myside, globalGraf, globalNoise, globalDifficult, globalPlayer, globalTurbo!, globalRandBal, globalTrain(1), globalTrain(2), globalJanCam, globalRealism, globalBatWon(1), globalBatWon(2), globalCasualty&(1), globalCasualty&(2), globalHistory, globalBold
			CLOSE #1
			SCREEN 12
			CLS
			CLOSE #1
			CALL usa
			CALL clrbot
			FOR k = 1 TO 2
				IF globalRR(k) > 0 THEN CALL tinytrain(k, 1)
			NEXT k
			globalSide = a
		CASE 3
			globalMTX$(0) = "Save Game"
			FOR k = 1 TO 9
				globalMTX$(k) = "cws" + LTRIM$(STR$(k)) + ".sav"
				IF _FILEEXISTS(globalMTX$(k)) THEN globalMTX$(k) = globalMTX$(k) + " �"
			NEXT k
				globalTLX = 67: globalSize = 9
				CALL menu(0)
				IF globalChoose < 1 THEN 
					clrrite
					EXIT SUB
				END IF
				COLOR 11
				CALL clrbot
				PRINT "Saving";

			OPEN "O", 1, "cws" + LTRIM$(STR$(globalChoose)) + ".sav"
			WRITE #1, month, globalYear, globalUSAdv, globalSide
			FOR i = 1 TO 40
				WRITE #1, globalArmyName$(i), globalArmySize(i), globalArmyLead(i), globalArmyLoc(i), globalArmyExper(i), globalSupply(i), globalArmyMove(i)
			NEXT i
			FOR i = 1 TO 40
				WRITE #1, globalOccupied(i), globalCityP(i), globalFort(i)
				PRINT ".";
			NEXT i
			FOR i = 1 TO 2
				WRITE #1, globalCash(i), globalControl(i), globalIncome(i), globalVictory(i), globalCapCity(i)
				WRITE #1, globalFleet$(i), globalNavyLoc(i), globalNavyMove(i), globalRR(i), globalTracks(i)
			NEXT i
			CLOSE #1
		
			myside = globalSide
			IF myside < 1 OR myside > 2 THEN myside = 1
			OPEN "O", 1, "cws.cfg"
			WRITE #1, myside, globalGraf, globalNoise, globalDifficult, globalPlayer, globalTurbo!, globalRandBal, globalTrain(1), globalTrain(2), globalJanCam, globalRealism, globalBatWon(1), globalBatWon(2), globalCasualty&(1), globalCasualty&(2), globalHistory, globalBold
			CLOSE #1
			CLS
			CALL usa
	END SELECT
END SUB

SUB flashcity (which)
	FOR c = 1 TO 15 STEP 2
		CIRCLE (globalCityX(which), globalCityY(which)), 4, 0
		CIRCLE (globalCityX(which), globalCityY(which)), 3, c
		PAINT (globalCityX(which), globalCityY(which)), c, c
		CALL TICK(.1)
	NEXT c
	c = 9
	IF globalCityP(which) = 2 THEN c = 7
	IF globalCityP(which) = 0 THEN c = 12
	CIRCLE (globalCityX(which), globalCityY(which)), 4, 0
	CIRCLE (globalCityX(which), globalCityY(which)), 3, c
	PAINT (globalCityX(which), globalCityY(which)), c, c
END SUB

SUB fortify (target)
	target = 0
	globalHilite = 11
	globalTLX = 67
	globalTLY = 2
	who = globalSide
	CALL starfin(star, fin, who)
	globalSize = 0
	FOR i = star TO fin
		IF globalArmyLoc(i) > 0 AND globalFort(globalArmyLoc(i)) < 2 THEN
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalCity$(globalArmyLoc(i))
			globalArray(globalSize) = globalArmyLoc(i)
		END IF
	NEXT i
	IF globalSize = 0 THEN 
		CALL clrbot
		COLOR 11: PRINT "No cities eligible to fortify";
		EXIT SUB
	END IF
	CALL bubble(globalSize)
	globalMTX$(0) = "Fortify"
	globalChoose = 31
	CALL menu(9)
	CALL clrrite
	IF globalChoose < 0 GOTO nocity
	target = globalArray(globalChoose)
	CALL occupy(target)
	x = globalOccupied(target)
	IF x < 0 GOTO nocity
	IF globalFort(target) > 1 THEN 
		CALL clrbot
		PRINT globalCity$(target); " at MAXIMUM fortification level of 2";
		CALL TICK(4)
		GOTO nocity
	END IF
	cost = 200
	IF globalCash(globalSide) < cost THEN 
		CALL clrbot
		PRINT "Fortifications for "; globalCity$(target); " cost "; cost; " and you only have "; globalCash(globalSide);
		CALL TICK(4)
		GOTO nocity
	END IF
	COLOR 3
	globalFort(target) = globalFort(target) + 1
	globalCash(globalSide) = globalCash(globalSide) - cost
	CALL clrbot
	PRINT globalCity$(target); " fortifications increased to "; globalFort(target);
	CALL icon(target, 0, 6)
	CALL showcity
	IF globalArmyMove(x) > 0 THEN CALL icon(globalArmyLoc(x), globalArmyMove(x), 5)
	globalArmyMove(x) = -1
	CALL placearmy(x)
	CALL stax(who)
nocity:
END SUB

SUB icon (from, dest, kind)
	IF from < 1 OR from > 40 GOTO noshow
	IF dest < 0 GOTO noshow
	IF from = 999 GOTO noshow
	x = globalCityX(from) - 12: y = globalCityY(from) - 11
	x1 = globalCityX(dest): y1 = globalCityY(dest)
	SELECT CASE kind
		CASE 1
			LINE (x, y)-(x1, y1), 15, , &HF0F0
		CASE 2
			FOR i = 6 TO 8
				LINE (x - i, y - i + 3)-(x + i, y + i - 3), 14, B
			NEXT i
			CALL TICK(.1)
		CASE 3
			x = globalCityX(from)
			y = globalCityY(from)
			CALL snapshot(x, y, 0)
			FOR j = 1 TO 3
				FOR i = 4 TO 10 STEP 1
					CIRCLE (x, y), i, 4
					PAINT (x, y), 14, 4
					IF globalNoise > 0 THEN SOUND 37 + 50 * RND, .03
				NEXT i
				CALL TICK(.1)
				CALL snapshot(x, y, 1)
			NEXT j
		CASE 4
			IF globalOccupied(from) = 0 THEN LINE (x - 8, y - 6)-(x + 10, y + 8), 2, BF
			IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
			IF from = 27 OR from = 28 THEN CALL touchup
		CASE 5
			IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
		CASE 6
			x = globalCityX(from)
			y = globalCityY(from)
			CALL snapshot(x, y, 0)
			LINE (x - 9, y - 9)-(x + 9, y + 9), 15, B
			LINE (x - 10, y - 10)-(x + 10, y + 10), 15, B
			IF globalNoise > 0 THEN SOUND 3999, .3
			CALL TICK(globalTurbo! - .5)
			CALL snapshot(x, y, 1)
		CASE 7          ' draw white box
			x = globalCityX(from) - 12
			y = globalCityY(from) - 11
			GET (x - 8, y - 8)-(x + 8, y + 8), globalImage
			LINE (x - 7, y - 7)-(x + 7, y + 7), 15, B
			LINE (x - 8, y - 6)-(x + 8, y + 6), 15, B
		CASE 8     ' replace old image
			x = globalCityX(from) - 12: y = globalCityY(from) - 11
			IF x > 0 THEN PUT (x - 8, y - 8), globalImage, PSET
		CASE 9          ' draw arrow pointer
			x = globalCityX(from) - 12
			y = globalCityY(from) - 11
			GET (x - 8, y - 8)-(x + 10, y + 7), globalImage
			x = x + 7
			y = y + 5
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
noshow:
END SUB

SUB iterate
	FOR i = 1 TO 40
		IF globalArmyLoc(i) > 0 THEN CALL placearmy(i)
	NEXT i
	month = month + 2
	IF month > 12 THEN
		month = 1
		globalYear = globalYear + 1
	END IF
	s = 1
	FOR i = 1 TO 40
		IF globalArmyLoc(i) < 1 GOTO rip
		IF i > 20 THEN s = 2
		IF globalCash(s) >= .2 * globalArmySize(i) THEN
			a = 1
			IF globalRealism > 0 THEN CALL cutoff(s, globalArmyLoc(i), a)
			IF a > 0 THEN
				globalSupply(i) = globalSupply(i) + 1
				globalCash(s) = globalCash(s) - .2 * globalArmySize(i)
			END IF
		END IF
		IF (month < 7 OR month > 10) AND globalMatrix(globalArmyLoc(i), 7) < 99 THEN globalSupply(i) = globalSupply(i) - 1
		IF globalMatrix(globalArmyLoc(i), 7) = 99 AND globalNavyLoc(3 - s) = globalArmyLoc(i) THEN 
			globalSupply(i) = globalSupply(i) - 1
			CALL clrbot
			PRINT globalArmyName$(i); " is blockaded"; 
			CALL TICK(globalTurbo!)
		END IF
		COLOR 13
		IF globalSupply(i) < 1 THEN
			globalSupply(i) = 0
			CALL clrbot
			PRINT globalArmyName$(i); " is out of supplies";
			CALL placearmy(i)
			CALL TICK(globalTurbo!)
			IF RND > .8 AND globalArmySize(i) > 50 THEN globalArmySize(i) = .9 * globalArmySize(i)
		END IF
	rip:
	NEXT i
	FOR k = 1 TO 2
		CALL stax(k)
	NEXT k
	y = 0
	FOR i = 1 TO 20
		y = y + .1 * globalArmySize(i)
	NEXT i
	x = 0
	FOR i = 21 TO 40
		x = x + .1 * globalArmySize(i)
	NEXT i
	IF globalSide = 2 AND x > 0 THEN 
		globalAggress! = y / x 
	ELSE 
		globalAggress! = 1
	END IF
	IF globalSide = 1 AND y > 0 THEN 
		globalAggress! = x / y 
	ELSE 
		IF globalSide = 1 THEN 
			globalAggress! = 1
		END IF
	END IF
END SUB

SUB movefrom (index, target)
	globalColour = 3
	globalTLX = 67
	globalTLY = 5
	index = 0
	globalSize = 0
	target = 0
	who = globalSide
	CALL starfin(star, fin, who)
	FOR i = star TO fin
		IF globalArmyLoc(i) > 0 AND globalArmyMove(i) = 0 THEN 
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalCity$(globalArmyLoc(i))
			globalArray(globalSize) = globalArmyLoc(i)
		END IF
	NEXT i
	IF globalSize = 0 THEN 
		index = -1
		GOTO notarg
	END IF
	globalMTX$(0) = "From"
	CALL bubble(globalSize)
	movopt:
	globalTLX = 67
	globalTLY = 5
	globalHilite = 15
	CALL menu(1)
	CALL clrrite
	IF globalChoose < 0 THEN 
		target = 0
		GOTO notarg
	END IF
	target = globalArray(globalChoose)

	globalSize = 0
	FOR i = star TO fin
		IF globalArmyLoc(i) = target AND globalArmyMove(i) = 0 THEN 
			index = i
			globalSize = globalSize + 1
			globalMTX$(globalSize) = "Army" + STR$(i)
			globalArray(globalSize) = i
		END IF
	NEXT i
	IF globalSize = 1 GOTO notarg
	globalMTX$(0) = "Which"
	CALL bubble(globalSize)
	globalTLX = 67
	globalTLY = 15
	CALL menu(4)
	CALL clrrite
	IF globalChoose < 0 THEN 
		index = 0
		GOTO notarg
	END IF
	index = globalArray(globalChoose)
notarg:
END SUB

SUB navy (who, chx)
	DIM hit(2)
	IF chx > 0 THEN
		IF globalNavyLoc(who) < 1 THEN
			chx = 1
		ELSE
			IF globalCommerce = 3 - who AND globalRaider > 0 THEN chx = 4
			IF globalGrudge > 0 THEN chx = 3
		END IF
	END IF
	COLOR 11
	ahoy:
	cost = 100
	globalCityP(0) = who
	IF chx = 0 THEN 
		CALL clrbot
		PRINT "Funds available "; globalCash(who);
	END IF
	IF chx = 1 THEN
		IF globalCash(who) < cost THEN EXIT SUB
		IF globalNavySize(who) > 9 THEN EXIT SUB
	END IF
	globalMTX$(0) = "Ships"
	globalMTX$(1) = "Build"
	IF globalNavyLoc(who) <> 99 THEN
		IF globalCash(who) < cost OR globalNavySize(who) > 9 OR globalCityP(globalNavyLoc(who)) <> who THEN
			globalMTX$(1) = "-"
			globalChoose = 23
		END IF
	END IF
	globalMTX$(2) = "Attack"
	IF globalNavyLoc(who) <> 99 THEN
		IF globalCityP(globalNavyLoc(who)) <> 3 - who THEN
			globalMTX$(2) = "-"
			globalChoose = 22
		END IF
	ELSE
		globalMTX$(1) = "-"
		globalMTX$(2) = "-"
		globalChoose = 24
	END IF
	globalMTX$(3) = "Sail"
	IF globalNavyLoc(who) < 1 THEN 
		globalMTX$(3) = "-"
		IF chx = 3 THEN chx = 1
	END IF
	globalMTX$(4) = "Raid"
	IF globalNavySize(who) < 1 OR globalCommerce = who THEN globalMTX$(4) = "-"
	globalTLX = 67
	globalTLY = 12
	globalSize = 4
	IF globalNavyLoc(who) <> 99 THEN
		IF who = 1 AND globalNavySize(who) > 1 AND globalCityP(globalNavyLoc(who)) = 0 THEN 
			globalSize = 5
			globalMTX$(5) = "Invasion"
			CALL void(globalNavyLoc(1), defend)
			IF chx > 0 AND defend < 100 THEN chx = 5
		END IF
		IF globalRealism = 0 AND who = 2 AND globalNavySize(who) > 1 AND globalCityP(globalNavyLoc(who)) = 0 THEN 
			globalSize = 5
			globalMTX$(5) = "Invasion"
			CALL void(globalNavyLoc(1), defend)
			IF chx > 0 AND defend < 100 THEN chx = 5
		END IF
	END IF

	IF chx > 0 THEN 
		globalChoose = chx
		GOTO anchor
	END IF
	IF globalNFlag > 0 AND globalChoose <> 1 THEN EXIT SUB
	CALL menu(0)
	CALL clrrite
	anchor:
	SELECT CASE globalChoose
		CASE 1 ' Build Ship
			IF globalCash(who) < cost OR globalNavyLoc(who) = 99 GOTO ahoy
			IF chx = 1 AND globalNavySize(who) > 9 THEN EXIT SUB
			IF chx = 0 AND globalNavySize(who) > 9 THEN GOTO ahoy

			IF chx = 0 AND globalNavyLoc(who) > 0 THEN
				IF globalCityP(globalNavyLoc(who)) <> who GOTO ahoy
				IF globalMatrix(globalNavyLoc(who), 7) < 99 GOTO ahoy
			END IF
			IF chx = 1 AND RND < .07 * globalNavySize(who) THEN EXIT SUB
			a$ = "W"

			IF globalRealism > 0 AND ((globalYear < 1862) OR (globalYear = 1862 AND month < 3)) GOTO noiron
			IF globalCash(who) >= 2 * cost THEN
				globalTLX = 67: globalTLY = 12: globalColour = 9
				IF who = globalSide THEN
					globalMTX$(0) = "Type"
					globalMTX$(1) = "Wooden"
					globalMTX$(2) = "Ironclad"
					globalSize = 2
					CALL menu(0)
					CALL clrrite
					IF globalChoose < 1 GOTO ahoy
					IF globalChoose = 2 THEN 
						a$ = "I"
						cost = 2 * cost
					END IF
				ELSE
					a$ = "I"
				END IF
			END IF

			noiron:
			globalNavySize(who) = globalNavySize(who) + 1
			IF a$ = "W" THEN
				globalFleet$(who) = globalFleet$(who) + a$: a = 1
			ELSE
				globalFleet$(who) = a$ + globalFleet$(who): a = 2
			END IF
			IF globalNavySize(who) > 1 GOTO add2ship
			ships:
			globalMTX$(0) = "Port": globalSize = 0: globalTLX = 67: globalTLY = 12
			FOR i = 1 TO 40
				IF globalMatrix(i, 7) = 99 AND globalCityP(i) = who AND globalNavyLoc(3 - who) <> i THEN 
					globalSize = globalSize + 1
					globalMTX$(globalSize) = globalCity$(i): globalArray(globalSize) = i
				END IF
			NEXT i
			IF chx = 1 THEN globalChoose = 1 + INT(globalSize * RND)
			IF globalSize < 1 THEN
				globalNavySize(who) = 0
				globalFleet$(who) = ""
				IF chx = 0 THEN 
					CALL clrbot
					PRINT "NO SHIPYARDS AVAILABLE !";
					EXIT SUB
				END IF
				IF chx = 1 THEN EXIT SUB
			END IF
			IF chx = 0 THEN 
				CALL menu(9)
				CALL clrrite
			END IF

			IF globalChoose < 1 GOTO ships
			globalNavyLoc(who) = globalArray(globalChoose)
			globalCash(who) = globalCash(who) - cost
			globalNavySize(who) = 1
			x = globalCityX(globalArray(globalChoose)) + 25
			y = globalCityY(globalArray(globalChoose)) + 25
			CALL ships
			CALL clrbot
			COLOR 11: PRINT globalForce$(who); " is building NEW fleet in "; globalCity$(globalArray(globalChoose));
			PSET (400, 465), 0: CALL shipicon(who, a)
			IF globalNoise > 0 THEN SOUND 3000, 1
			CALL TICK(globalTurbo!)
			GOTO ahoy
			add2ship:
			globalCash(who) = globalCash(who) - cost
			CALL clrbot
			PRINT globalForce$(who); " navy increased to "; globalNavySize(who);
			PSET (400, 465), 0: CALL shipicon(who, a)
			CALL ships
			IF globalNoise > 0 THEN SOUND 3000, 1
			CALL TICK(globalTurbo!)
		CASE 2 ' Attack City
			IF globalNavyLoc(who) = 99 GOTO ahoy
			IF chx = 2 AND globalCityP(globalNavyLoc(who)) = who THEN EXIT SUB
			IF chx = 2 AND globalOccupied(globalNavyLoc(who)) > 0 AND RND > .5 THEN 
				chx = 3
				GOTO anchor
			END IF
			IF chx = 2 AND globalCityP(globalNavyLoc(who)) = 0 THEN 
				chx = 3
				GOTO ahoy
			END IF
			IF globalNavyLoc(who) < 1 THEN EXIT SUB
			IF who = globalSide THEN globalNFlag = 1
			IF globalCityP(globalNavyLoc(who)) <> 3 - who GOTO ahoy
			CALL clrbot
			COLOR 12: PRINT globalForce$(who); " fleet bombards "; globalCity$(globalNavyLoc(who));
			CALL icon(globalNavyLoc(who), 0, 3)
			
			target = globalNavyLoc(who)
			index = globalOccupied(target)
			IF index = 0 GOTO deserted
			pct! = .005 * globalNavySize(who) + .02 * RND
			killd = globalArmySize(index) * pct!
			IF killd < 1 THEN killd = 1
			CALL clrbot
			PRINT globalArmyName$(index); " suffered "; 100 * killd; " casualties";
			x = .5 * globalNavySize(who) + 1
			IF x > globalSupply(index) THEN x = globalSupply(index)
			globalSupply(index) = globalSupply(index) - x
			CALL TICK(globalTurbo!)
			globalArmySize(index) = globalArmySize(index) - killd
			IF globalArmySize(index) < 1 THEN globalArmySize(index) = 1
			EXIT SUB
			deserted:
			IF globalFort(target) = 0 GOTO blast
			IF RND < .7 + .03 * (globalNavySize(who) - globalFort(target)) GOTO hurt1
			CALL barnacle(who)
			CALL clrbot
			PRINT globalForce$(globalCityP(target)); " shore battery sunk an attacking ship!"; globalNavySize(who); "ship(s) left! ";
			IF globalNoise > 0 THEN SOUND 77, .5: SOUND 59, .5
			CALL TICK(globalTurbo!)
			IF globalNavySize(who) < 1 THEN
				globalNavyLoc(who) = 0
				globalFleet$(who) = ""
				GOSUB box2
				LOCATE 12, 27: PRINT globalForce$(who); " fleet eliminated"
				CALL TICK(9)
				globalVictory(3 - who) = globalVictory(3 - who) + 5
				IF who = globalSide THEN globalGrudge = 0
				GOTO sail3
			END IF
			GOTO deserted
			hurt1:
			CALL clrbot
			PRINT globalCity$(target); " fortifications damaged";
			globalFort(target) = globalFort(target) - 1
			x = globalCityX(target)
			y = globalCityY(target)
			LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
			CALL showcity
			CALL TICK(globalTurbo!)
			EXIT SUB
			blast:
			IF RND > .25 + .07 * globalNavySize(who) THEN 
				CALL clrbot
				PRINT "Citizens of "; globalCity$(target); " stand firm against the attack";
				CALL TICK(globalTurbo!)
				EXIT SUB
			END IF
			IF globalNavyLoc(who) = globalCapCity(3 - who) THEN 
				CALL clrbot
				PRINT "The CAPITAL steadfastly stands loyal";
				CALL TICK(globalTurbo!)
				EXIT SUB
			END IF
			globalCityP(globalNavyLoc(who)) = 0
			CALL clrbot
			PRINT globalCity$(globalNavyLoc(who)); " is now  NEUTRAL";
			CALL showcity
			globalVictory(who) = globalVictory(who) + globalCityV(globalNavyLoc(who))
			EXIT SUB
		CASE 3 ' Sail
			globalNavySize(who) = LEN(globalFleet$(who))
			IF globalNavySize(who) < 1 AND chx > 0 THEN EXIT SUB
			IF globalNavyLoc(who) < 1 OR globalNavySize(who) < 1 THEN 
				CALL clrbot
				PRINT "No ships remain";
				TICK 1
				GOTO ahoy
			END IF

			globalSize = 0
			FOR i = 1 TO 40
				IF globalMatrix(i, 7) > 90 AND globalNavyLoc(who) <> i THEN
					globalSize = globalSize + 1
					globalMTX$(globalSize) = globalCity$(i)
					globalArray(globalSize) = i
				END IF
			NEXT i
			IF chx = 3 THEN
				IF globalSize = 0 THEN EXIT SUB
				IF globalGrudge > 0 THEN 
					globalChoose = 1
					globalArray(1) = globalNavyLoc(3 - who)
					GOTO admiral
				END IF
				GOSUB nest
				IF globalChoose > 0 GOTO admiral ELSE EXIT SUB
			END IF
			COLOR 11: LOCATE 11, 68
			IF globalNavyLoc(who) < 41 THEN
				PRINT globalCity$(globalNavyLoc(who))
			ELSE
				PRINT "Raiding"
			END IF
			globalMTX$(0) = "To"
			globalColour = 3
			globalTLX = 67
			globalTLY = 12
		
			CALL menu(9)
			CALL clrrite
			IF globalChoose < 1 THEN EXIT SUB
			admiral:
			IF globalArray(globalChoose) = globalNavyLoc(who) THEN EXIT SUB
			IF globalArray(globalChoose) < 1 THEN EXIT SUB
			IF globalNavySize(who) < 1 GOTO ships
			IF who = globalSide THEN globalNFlag = 1
			GOSUB box2
			LOCATE 10, 25: PRINT globalForce$(who); " fleet of"; globalNavySize(who); "ship(s) is sailing"
			LOCATE 11, 25: PRINT "From ";
			IF globalNavyLoc(who) < 41 THEN
				PRINT globalCity$(globalNavyLoc(who));
			ELSE
				PRINT "Raiding";
			END IF
			PRINT " to ";
			IF globalArray(globalChoose) <> 99 THEN
				PRINT globalCity$(globalArray(globalChoose));
			ELSE
				PRINT "Raid Commerce";
			END IF

			FOR i = 1 TO globalNavySize(who)
				PSET (120 + 41 * i, 210), 0
				CALL shiptype(who, i)
			NEXT i
			IF globalGraf > 2 THEN
				a = ASC(LEFT$(globalFleet$(who), 1))
				SELECT CASE a
					CASE 73
						CALL ironclad
					CASE 87
						CALL schooner
				END SELECT
				TICK 2 * globalTurbo!
			ELSE
				TICK globalTurbo!
			END IF
			globalNavyLoc(who) = globalArray(globalChoose)
			IF globalNavyLoc(1) = globalNavyLoc(2) GOTO pirate
			GOTO sail3
		CASE 4 ' Raid Commerce
			globalNavySize(who) = LEN(globalFleet$(who))
			IF globalNavySize(who) < 1 AND chx > 0 THEN EXIT SUB
			IF globalNavySize(who) < 1 OR globalCommerce = who GOTO ahoy

			IF who = globalSide THEN globalNFlag = 1
			GOSUB box2
			LOCATE 10, 25: PRINT globalForce$(who); " fleet of"; globalNavySize(who); "ship(s) is sailing"
			LOCATE 11, 25: PRINT "to RAID "; globalForce$(3 - who); " COMMERCE !"

			FOR i = 1 TO globalNavySize(who)
				PSET (120 + 41 * i, 210), 0
				CALL shiptype(who, i)
			NEXT i
			IF globalGraf > 2 THEN
				a = ASC(LEFT$(globalFleet$(who), 1))
				SELECT CASE a
					CASE 73
						CALL ironclad
					CASE 87
						CALL schooner
				END SELECT
				TICK 2 * globalTurbo!
			ELSE
				TICK globalTurbo!
			END IF
			globalNavyLoc(who) = 99
			globalCommerce = who
			IF globalNavyLoc(1) = globalNavyLoc(2) GOTO pirate
			CLS
			CALL usa
			EXIT SUB
		CASE 5 ' Invasion
			CALL commander((who), empty)
			IF chx > 0 AND empty = 0 THEN 
				chx = 3
				GOTO anchor
			END IF
			x = 35
			CALL barnacle(who)
			c = globalNavyLoc(who)
			CALL newarmy((who), empty, c)
			globalCash(who) = globalCash(who) + 100     'compensate for cost of recruiting new army
			CALL capture(empty, c, who, 0)
			globalArmySize(empty) = x
			IF who = globalSide THEN globalNFlag = 1
			EXIT SUB
		CASE ELSE ' Exit
			EXIT SUB
		END SELECT
		GOTO ahoy
		pirate: ' Ship vs. Ship 
		CLS
		LOCATE 1, 30: COLOR 11: PRINT "NAVAL COMBAT"
		FOR k = 1 TO 2
			hit(k) = 10
			IF RIGHT$(globalFleet$(k), 1) = "I" THEN hit(k) = 20
		NEXT k
		cannon:
		LOCATE 9, 1: PRINT SPACE$(79)
		LOCATE 15, 1: PRINT SPACE$(79)
		x = 10
		y = 100
		COLOR 9: LOCATE 5, 25: PRINT "UNION"; globalNavySize(1); "ship(s)"
		GOSUB boxes
		COLOR 1
		FOR i = 1 TO globalNavySize(1)
			x = x + 50: PSET (x, y)
			CALL shiptype(1, i)
		NEXT i
		COLOR 11: LOCATE 11, 22: PRINT "CONFEDERATES "; globalNavySize(2); "ship(s)"
		LINE (10, 180)-(530, 210), 1, BF
		LINE (10, 180)-(530, 210), 11, B
		x = 10
		y = 200
		COLOR 1
		FOR i = 1 TO globalNavySize(2)
			x = x + 50: PSET (x, y)
			CALL shiptype(2, i)
		NEXT i
		COLOR 11
		wave:
		globalMTX$(0) = "Options"
		globalMTX$(1) = "Attack"
		globalMTX$(2) = "Retreat"
		IF chx > 0 THEN 
			globalChoose = 1
			GOTO powder
		END IF
		
		globalSize = 2
		globalColour = 3
		globalHilite = 14
		globalTLX = 50
		globalTLY = 18
		CALL menu(0)
		powder:
		SELECT CASE globalChoose
			CASE 1
				firemore:
				IF globalNoise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
				pct! = 0
				a$ = RIGHT$(globalFleet$(who), 1)
				IF a$ <> RIGHT$(globalFleet$(3 - who), 1) THEN
					IF a$ = "I" THEN pct! = .1 ELSE pct! = -.1
				END IF
				IF RND <= .5 + pct! GOTO hitem ELSE GOTO hitme1
				GOTO firemore
				hitem:
				hit(3 - who) = hit(3 - who) - 1
				GOSUB showhit
				IF hit(3 - who) > 0 GOTO firemore
				x = 10 + 50 * globalNavySize(3 - who)
				y = 90
				IF who = 1 THEN y = 190
				GOSUB xout
				LOCATE 17, 5: PRINT globalForce$(3 - who); " ship SUNK!"
				CALL TICK(globalTurbo! + 1)
				GOSUB clr1
				CALL barnacle(3 - who)
				IF globalNavySize(3 - who) < 1 THEN
					LOCATE 19, 5: COLOR 12
					PRINT globalForce$(3 - who); " fleet DEFEATED"
					CALL TICK(globalTurbo!)
					globalNavyLoc(3 - who) = 0
					globalFleet$(3 - who) = ""
					globalVictory(3 - who) = globalVictory(3 - who) + 10
					IF who = globalSide THEN globalGrudge = 1 ELSE globalGrudge = 0
					GOTO sail3
				END IF
				hit(3 - who) = 10
				IF RIGHT$(globalFleet$(3 - who), 1) = "I" THEN hit(3 - who) = 20
				GOTO cannon
				hitme1:
				hit(who) = hit(who) - 1
				GOSUB showhit
				IF hit(who) > 0 GOTO firemore
				x = 10 + 50 * globalNavySize(who)
				y = 190
				IF who = 1 THEN y = 90
				GOSUB xout
				LOCATE 17, 5: PRINT "One of the "; globalForce$(who); " ships was SUNK!"
				CALL TICK(globalTurbo!)
				GOSUB clr1
				CALL barnacle(who)
				IF globalNavySize(who) < 1 THEN
					LOCATE 19, 5: COLOR 12
					PRINT "Attacking "; globalForce$(who); " fleet has been ELIMINATED !"
					CALL TICK(globalTurbo!)
					globalNavyLoc(who) = 0: globalFleet$(who) = ""
					globalVictory(who) = globalVictory(who) + 10
					IF who <> globalSide THEN globalGrudge = 1 ELSE globalGrudge = 0
					GOTO sail3
				END IF
				hit(who) = 10
				IF RIGHT$(globalFleet$(who), 1) = "I" THEN hit(who) = 20
				GOTO cannon
			CASE 2
				target = 0
				FOR i = 1 TO 40
					IF globalCityP(i) = who THEN 
						IF i <> globalNavyLoc(who) AND globalMatrix(i, 7) = 99 THEN
							target = i
							IF RND > .3 GOTO found1
						END IF
					END IF
				NEXT i
				found1:
				CALL clrbot
				COLOR 11: PRINT globalForce$(who); " is retreating to "; globalCity$(target);
				CALL TICK(globalTurbo!)
				globalNavyLoc(who) = target
				GOTO sail3
			CASE ELSE
				GOTO wave
		END SELECT
		GOTO pirate
		'---------------------------------------------------------------------------
		'                               Subs
		'---------------------------------------------------------------------------
		showhit:
		LOCATE 9, 6 * globalNavySize(1): PRINT hit(1); " ";
		LOCATE 15, 6 * globalNavySize(2): PRINT hit(2); " ";
		IF globalNoise = 0 THEN TICK .1 * globalTurbo!
		RETURN
		clr1:
		LOCATE 17, 1: PRINT SPACE$(60): RETURN
		nest:
		best = 0
		x = 0
		FOR i = 1 TO globalSize
			target = globalArray(i)
			IF globalCityP(target) = 0 GOTO neutral

			IF target = globalNavyLoc(3 - who) THEN 
				IF globalNavySize(who) >= globalNavySize(3 - who) AND RND > .1 THEN 
					globalChoose = i
					RETURN
				END IF
			END IF
			IF globalCityP(target) <> who THEN
				best = i
				x = x + 1
				IF RND > .8 THEN 
					globalChoose = best
					RETURN
				END IF
			END IF
		neutral:
		NEXT i
		IF best = 0 THEN
			globalChoose = 1 + INT(RND * globalSize)
		ELSE
			globalChoose = best
		END IF

		IF who = 2 AND globalNavyLoc(2) = 30 THEN 
			IF RND > .5 THEN 
				globalChoose = 30
				RETURN
			END IF
		END IF
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
		globalCommerce = 0
		FOR k = 1 TO 2
			IF globalNavyLoc(k) = 99 THEN globalCommerce = k
		NEXT k
		CLS 
		CALL usa
END SUB

SUB newarmy (who, empty, target)
	globalSupply(empty) = 3 + 5 * RND
	IF who = 1 THEN globalSupply(empty) = globalSupply(empty) + 2
	globalArmyExper(empty) = 1
	IF who = 2 THEN globalArmyExper(empty) = 2
	globalArmyLead(empty) = globalRating(empty)
	globalArmyName$(empty) = globalLName$(empty)
	globalLName$(empty) = ""
	COLOR 12
	CALL clrbot
	PRINT "Placing NEW army "; empty; globalArmyName$(empty); " in "; globalCity$(target);

	x = 70
	IF globalRealism > 0 THEN x = 3 * globalCityV(target) + 33
	CALL cutoff(who, target, a)
	IF a < 1 THEN x = x \ 3
	globalOccupied(target) = empty
	globalArmySize(empty) = x
	PRINT " Size = "; : CALL strong(empty)
	globalCash(who) = globalCash(who) - 100
	IF globalNoise > 0 THEN SOUND 2222, .5
	globalArmyLoc(empty) = target
	CALL placearmy(empty)
	CALL TICK(globalTurbo! - .5)
	globalArmyMove(empty) = -1
END SUB

SUB newcity (index)
	globalMTX$(1) = "  "
	globalMTX$(3) = "  "
	globalSize = 3
	a$ = globalCity$(index)
	morecap:
	globalTLX = 68
	globalTLY = 15
	globalColour = 3
	globalChoose = 23
	globalMTX$(2) = globalCity$(index)
	CALL menu(3)
	CALL clrrite
	SELECT CASE globalChoose
		CASE IS = -27
			index = 0
			EXIT SUB
		CASE IS < 1
			a$ = CHR$(ABS(globalChoose))
			x = 0
			FOR k = 1 TO 40
				IF LEFT$(globalCity$(k), 1) = a$ THEN
					y = index
					index = k
					spin2:
					IF globalCityP(index) = globalSide GOTO morecap
					index = index + 1
					IF index > 40 THEN index = 1
					x = x + 1
					IF x < 39 GOTO spin2
					index = y
					GOTO morecap
				END IF
			NEXT k
			GOTO morecap
		CASE 1
			minus1:
			index = index - 1
			IF index < 1 THEN index = 40
			IF globalCityP(index) <> globalSide GOTO minus1 ELSE GOTO morecap
		CASE 2
			GOTO fnew
		CASE 3
			plus1:
			index = index + 1
			IF index > 40 THEN index = 1
			IF globalCityP(index) <> globalSide GOTO plus1 ELSE GOTO morecap
		CASE ELSE
			index = 0
		END SELECT
fnew:
END SUB

SUB normal (xbar, vary, result)
	' NOTE : vary is VARIANCE
	pct! = 0
	FOR k = 1 TO 12
		pct! = pct! + RND
	NEXT k
	pct! = pct! - 5.5
	result = xbar + pct! * SQR(vary)
END SUB

SUB placearmy (which)
	who = 1
	IF which > 20 THEN who = 2
	x = globalCityX(globalArmyLoc(which)) - 12
	y = globalCityY(globalArmyLoc(which)) - 11
	CALL armyxy(x, y, who)
	IF globalSupply(which) < 1 THEN
		x = x - 3
		y = y + 4
		PSET (x, y), 13: DRAW "C11S8"
		DRAW globalFont$(19)
		DRAW "S4"
	END IF
END SUB

SUB railroad (who)
	SELECT CASE globalRR(who)
		CASE 0
			IF who = globalSide GOTO human
			CALL starfin(star, fin, who)
			max = 32767
			index = 0
			FOR i = star TO fin
				IF globalArmyLoc(i) = 0 OR globalArmyMove(i) <> 0 GOTO puter
				x = 0
				FOR j = 1 TO 6
					from = globalMatrix(globalArmyLoc(i), j)
					IF from > 0 AND globalCityP(from) <> who THEN x = x + 1
				NEXT j
				IF globalOccupied(globalCapCity(who)) > 0 AND x > 1 GOTO puter
				CALL void(globalArmyLoc(i), defend)
				IF globalVicFlag(5) > 0 AND globalOccupied(globalCapCity(who)) = 0 THEN
					IF defend > max THEN defend = max - 1
				END IF
				IF defend < max THEN 
					target = globalArmyLoc(i)
					GOSUB route
					IF x > 1 THEN max = defend: index = i
				END IF
			puter:  
			NEXT i
		IF index = 0 OR max > .3 * globalArmySize(index) GOTO toot
		CALL traincapacity(who, limit)
		IF globalArmySize(index) > limit THEN GOTO toot
		from = globalArmyLoc(index)
		x1 = 0
		FOR i = 1 TO 40
			IF globalCityP(i) <> who GOTO puted
			CALL void(i, defend)
			IF defend = 0 OR defend > 3 * globalArmySize(index) GOTO puted
			IF globalOccupied(i) > 0 GOTO puted
			target = i
			GOSUB route
			IF x = 0 GOTO puted
			IF globalSide = 1 AND globalCityY(i) < globalCityY(from) THEN x1 = i
			IF globalSide = 2 AND globalCityY(i) > globalCityY(from) THEN x1 = i
			IF globalFort(i) > 0 AND globalOccupied(i) = 0 THEN x1 = i: EXIT FOR
		puted:
		NEXT i
		IF globalVicFlag(5) > 0 AND globalOccupied(globalCapCity(who)) = 0 THEN
			GOSUB route
			IF x > 0 THEN
				CALL void(globalCapCity(who), defend)
				IF defend > 0 THEN x1 = globalCapCity(who)
			END IF
		END IF
		IF x1 > 0 GOTO haul ELSE GOTO toot
		human:
		CALL movefrom(index, a)
		IF a < 1 OR index < 1 THEN 
			COLOR 11
			CALL clrbot
			PRINT "Railroad move not allowed";
			GOTO toot
		END IF
		x = 1
		IF index > 20 THEN x = 2
		CALL traincapacity(who, limit)
		IF globalArmySize(index) > limit THEN 
			CALL clrbot
			PRINT "Too many troops for railroad capacity";
			GOTO toot
		END IF
		
		target = globalArmyLoc(index)
		GOSUB route
		IF x > 1 GOTO aboard
		CALL clrbot
		PRINT "Track from "; globalCity$(target); " is blocked";
		GOTO toot
		aboard:
		CALL clrbot
		PRINT "Select destination for "; globalArmyName$(index); " from "; globalCity$(target);
		globalMTX$(0) = "To"
		from = target
		x1 = from
		IF from = 0 GOTO toot
		CALL newcity(x1)
		IF x1 = from OR x1 = 0 GOTO toot

		target = x1
		GOSUB route
		IF x > 1 GOTO haul
		CALL clrbot
		PRINT globalArmyName$(index); "'s train cannot go to "; globalCity$(x1); " - select another city";
		CALL TICK(9)
		GOTO aboard
		haul:
		COLOR 11
		CALL clrbot
		PRINT globalArmyName$(index); " is taking the train from "; globalCity$(from); " to "; globalCity$(x1);
		globalTracks(who) = globalArmyLoc(index)
		from = globalArmyLoc(index)
		globalRRFrom(who) = from
		globalRR(who) = index
		globalArmyLoc(index) = 0
		globalArmyMove(index) = x1
		CALL tinytrain(who, 1)
		IF globalNoise > 0 THEN SOUND 2222, 1
		CALL engine

		CALL occupy(from)
		IF globalOccupied(from) > 0 THEN CALL placearmy(globalOccupied(from))
		GOTO toot

		CASE IS > 0
			CALL tinytrain(who, 0)
			CALL occupy(globalRRFrom(who))
			IF globalOccupied(globalRRFrom(who)) > 0 THEN CALL placearmy(globalOccupied(globalRRFrom(who)))

			index = globalRR(who)
			globalTracks(who) = globalArmyMove(index)
			CALL tinytrain(who, 1)

			globalRR(who) = 0
			globalArmyLoc(index) = globalArmyMove(index)
			globalArmyMove(index) = -1
			COLOR 11
			CALL clrbot
			PRINT "Train with "; globalArmyName$(index); " has arrived in "; globalCity$(globalArmyLoc(index));
			IF globalNoise > 0 THEN SOUND 1200, 2
			CALL TICK(globalTurbo!)
			x = globalCityX(globalArmyLoc(index)) - 12
			y = globalCityY(globalArmyLoc(index)) - 11
			LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
			IF globalCityP(globalArmyLoc(index)) <> who THEN CALL capture(index, globalArmyLoc(index), who, 0)
			CALL placearmy(index)
			IF globalOccupied(globalArmyLoc(index)) > 0 THEN CALL stax(who): GOTO toot
			CALL occupy(globalArmyLoc(index)): CALL placearmy(index)
			GOTO toot
	END SELECT

	route:
	x = 0
	FOR j = 1 TO 6
		y = globalMatrix(target, j)
		IF y > 0 AND globalCityP(y) = who THEN
			x = x + 1
			FOR m = 1 TO 6
				z = globalMatrix(y, m)
				IF z > 0 AND z <> target AND globalCityP(z) = who THEN x = x + 1
			NEXT m
		END IF
	NEXT j
	RETURN

	toot:
	IF who = globalSide THEN CALL TICK(9)
	CALL clrrite
	clrbot
END SUB

SUB recruit (who)
	IF globalCash(who) < 100 GOTO menu1
	globalSize = 0: COLOR 12
	globalMTX$(0) = "Recruit"
	IF who = globalSide AND globalRFlag > 0 THEN 
		FOR i = 1 TO globalRFlag
			x = globalRCity(i)
			globalMTX$(i) = globalCity$(x)
			globalArray(i) = x
		NEXT i
		globalSize = globalRFlag
		GOTO alldone
	END IF
	max = 4
	IF RND > .8 THEN max = max - 1
	IF globalDifficult < 3 THEN max = max + 1

	FOR i = 1 TO 40
		IF globalControl(who) > 0 THEN 
			pct! = .6 * max / globalControl(who) 
		ELSE 
			pct! = .3
		END IF
		IF globalSize = 0 AND i > 20 THEN pct! = .3
		IF globalSize < 2 AND i > 30 THEN pct! = .3
		globalArray(i) = 0
		IF globalOccupied(i) > 0 AND globalCityP(i) = who THEN pct! = .4
		IF RND < pct! AND globalCityP(i) = who THEN
			IF globalRealism > 0 AND globalCityO(i) = 3 - who GOTO foe
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalCity$(i)
			globalArray(globalSize) = i
			IF globalSize > max - 1 GOTO alldone
		END IF
	foe:
	NEXT i
	alldone:
	IF globalSize = 0 GOTO menu1
	IF who = globalSide AND globalRFlag = 0 THEN 
		FOR i = 1 TO globalSize
			globalRCity(i) = globalArray(i)
		NEXT i
		globalRFlag = globalSize
	END IF
	CALL bubble(globalSize)
	'............................................................................
	levy:
	IF globalCash(who) < 100 GOTO menu1
	IF (who = globalSide) OR (globalPlayer = 2) THEN 
		CALL clrbot
		PRINT globalForce$(who); " funds available "; globalCash(who);
	END IF
	globalTLX = 67
	globalTLY = 12
	globalColour = 3
	IF who <> globalSide THEN
		GOSUB randsel
		GOTO auto1
	END IF
      
	IF globalChoose > 0 THEN globalChoose = 21 + globalChoose
	CALL menu(2)
	CALL clrrite
	IF globalChoose < 1 GOTO menu1
	auto1:
	empty = 0
	index = globalArray(globalChoose)
	CALL occupy(index)
	IF globalOccupied(index) > 0 THEN
		i = globalOccupied(index)
		GOTO add2
	END IF
	CALL commander((who), empty)
       
	IF who <> globalSide AND empty = 0 GOTO menu1
	IF empty = 0 GOTO levy
	globalArmyLoc(empty) = index
	GOSUB playb
	CALL newarmy(who, empty, index)
	GOTO levy
	'............................................................................
	add2:
	target = globalArray(globalChoose)
	x = 45
	a$ = ""
	IF globalRealism > 0 THEN
		x = 2 * globalCityV(globalArmyLoc(i)) + 20
		CALL cutoff(who, target, a)
		IF a < 1 THEN x = x \ 3
		a$ = " ISOLATED !"
	END IF
	globalArmySize(i) = globalArmySize(i) + x

	GOSUB playb
	globalCash(who) = globalCash(who) - 100
	from = globalArmyLoc(i)
	x = globalCityX(from) - 12
	y = globalCityY(from) - 11
	GET (x - 9, y - 7)-(x + 9, y + 6), globalAnima
	CALL icon(globalArmyLoc(i), 0, 2)
	IF globalNoise > 0 THEN SOUND 2222, 1
	COLOR 11
	CALL clrbot
	PRINT "Army "; i; globalArmyName$(i); " in "; globalCity$(globalArmyLoc(i)); " strength increased to "; : CALL strong(i)
	IF a$ <> "" THEN PRINT a$;
	PUT (x - 9, y - 7), globalAnima, PSET
	CALL TICK(globalTurbo! - .5)
	GOTO levy
	randsel:
	globalChoose = 0: x = 0
	FOR i = 1 TO globalSize
		target = globalArray(i)
		LOCATE 14 + i, 69
		x = globalOccupied(target)
		IF x = 0 XOR globalArmySize(x) < 155 THEN globalChoose = i
	NEXT i

	IF globalChoose = 0 THEN globalChoose = 1 + INT(RND * globalSize)
	IF globalRealism > 0 THEN
		x = 0
		FOR i = 1 TO globalSize
			target = globalArray(i)
			IF globalOccupied(target) = 0 THEN
				y = 3 * globalCityV(target) + 33
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			ELSE
				y = 2 * globalCityV(target) + 20
				CALL cutoff(who, target, a)
				IF a < 1 THEN y = y \ 3
			END IF
			IF y > x AND RND > .5 THEN x = y: globalChoose = i
		NEXT i
	END IF
	IF globalCash(who) < 100 THEN globalChoose = globalSize
	RETURN
	playb:
	IF globalSide = 1 AND globalDifficult < 3 THEN globalArmySize(empty) = globalArmySize(empty) + 15 - 5 * globalDifficult
	IF globalSide = 2 AND globalDifficult > 3 THEN globalArmySize(empty) = globalArmySize(empty) + 5 * globalDifficult - 15
	RETURN
menu1:
END SUB

SUB shiptype (who, i)
	a = 1
	IF MID$(globalFleet$(who), i, 1) = "I" THEN a = 2
	CALL shipicon(who, a)
END SUB

SUB showcity
	FOR i = 1 TO 40
		c = 9
		IF globalCityP(i) = 2 THEN c = 7
		IF globalCityP(i) = 0 THEN c = 12
		x = globalCityX(i)
		y = globalCityY(i)
		IF i = globalCapCity(1) OR i = globalCapCity(2) THEN
			PUT (x - 6, y - 6), Ncap, PSET
			LINE (x + 9, y - 4)-(x + 15, y + 4), 0, BF
			LINE (x + 8, y - 5)-(x + 13, y + 2), 3, BF
			PSET (x + 8, y - 4)
			IF globalFort(i) = 1 THEN DRAW "BR2C0e1D6BL1R2"
			IF globalFort(i) = 2 THEN DRAW "C0e1R1F1D1G3R3"
		ELSE
			IF globalFort(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
			IF globalFort(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
			CIRCLE (globalCityX(i), globalCityY(i)), 4, 0
			CIRCLE (globalCityX(i), globalCityY(i)), 3, c
			PAINT (globalCityX(i), globalCityY(i)), c, c
		END IF
		IF globalGraf = 0 GOTO nocon
			FOR j = 1 TO 6
				IF globalMatrix(i, j) > 0 THEN CALL icon(i, globalMatrix(i, j), 11)
			NEXT j
	nocon:
	NEXT i
END SUB

SUB smarts
	CALL events
	slush = 0
	who = 3 - globalSide
	c = 9
	IF globalSide = 1 THEN c = 15
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR c: LOCATE 1, 10: PRINT globalForce$(who); " Side is making decisions";
	CALL starfin(star, fin, who)
	'==========================================================================
	'                       Check Supply
	'==========================================================================
	FOR i = star TO fin
		IF globalArmyLoc(i) > 0 AND globalSupply(i) < 1 THEN CALL resupply(i)
	NEXT i
	'==========================================================================
	'                       Fortify Capital or Other City
	'==========================================================================
	cost = 200
	IF cost > globalCash(who) GOTO signup

	target = 0
	IF globalOccupied(globalCapCity(who)) = 0 OR globalFort(globalCapCity(who)) > 1 GOTO city2
	target = globalCapCity(who)
	IF globalCityP(target) = who GOTO capital ELSE GOTO city2
	IF target > 0 GOTO capital

	city2:
	IF 1 + RND < globalBold + globalAggress! GOTO signup
	target = 0
	FOR i = star TO fin
		x = globalArmyLoc(i): IF x = 0 OR globalArmyMove(globalOccupied(x)) < 0 OR globalArmyMove(i) < 0 GOTO endlook
		IF globalFort(x) > 1 GOTO endlook
		CALL void(x, defend)
		IF defend > globalArmySize(i) THEN 
			target = globalArmyLoc(i)
			GOTO capital
		END IF
	endlook:
	NEXT i

	capital:
	IF target = 0 GOTO signup
	IF globalFort(target) > 1 GOTO signup
	globalFort(target) = globalFort(target) + 1
	x = globalOccupied(target)
	globalArmyMove(x) = -1
	globalCash(who) = globalCash(who) - cost
	CALL clrbot
	PRINT globalCity$(target); " fortifications increased to "; globalFort(target);
	CALL icon(target, 0, 6)
	CALL showcity
	IF who = 1 AND globalNavySize(1) < 1 AND RND > .5 AND globalCash < 222 GOTO signup
	IF 3 * RND > 1 + globalAggress! AND globalCash(who) >= cost GOTO city2
	'==========================================================================
	'                       Recruit New Armies
	'==========================================================================
	signup:
	IF who = 1 AND globalNavySize(1) < 1 AND globalCash(1) > 100 THEN 
		CALL navy(1, 1)
		IF globalCash(who) < 100 GOTO isok
	END IF
	GOSUB enufarmies
	IF x > 2 + 3 * globalSide + 3 * RND GOTO isok
	IF globalNavySize(who) < 5 AND globalCash(who) > 100 AND globalNavyLoc(who) <> 99 THEN 
		IF globalCityP(globalNavyLoc(who)) = who THEN 
			slush = slush + 100
			globalCash(who) = globalCash(who) - 100
			IF globalCash(who) < 100 GOTO isok
		END IF
	END IF
	CALL recruit(who)
	'==========================================================================
	'                         Naval Commands
	'==========================================================================
	isok:
	globalCash(who) = globalCash(who) + slush
	dock:
	IF globalSide = 2 AND globalNavyLoc(1) = 0 AND globalNavySize(1) < 1 AND globalCityP(30) = 1 AND globalCash(1) > 100 THEN 
		globalNavyLoc(1) = 30
		CALL navy(1, 1)
		GOTO movenavy
	END IF
	IF globalNavyLoc(who) = 99 THEN
		IF RND < .9 THEN CALL navy(who, 3)
		GOTO movearmy
	END IF
	IF globalCash(who) < 100 OR globalNavySize(who) > 9 OR globalCityP(globalNavyLoc(who)) <> who GOTO movenavy
	CALL navy(who, 1)

	movenavy:
	IF globalNavySize(who) = 0 THEN globalNavyLoc(who) = 0
	IF globalNavyLoc(who) = 0 GOTO movearmy
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	'                     move ships & prohibit further action this turn
	'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	IF globalNavyLoc(who) <> 99 THEN
		IF globalCityP(globalNavyLoc(who)) = who THEN CALL navy(who, 3): GOTO movearmy   'move ships & prohibit further action this turn
		IF globalCityP(globalNavyLoc(who)) = 0 THEN CALL navy(who, 3): GOTO movearmy
	ELSE
		IF RND < .5 THEN CALL navy(who, 3)
		GOTO movearmy
	END IF

	IF globalCityP(globalNavyLoc(who)) <> who THEN
		IF globalOccupied(globalNavyLoc(who)) = 0 OR RND > .3 THEN
			CALL navy(who, 2) 'attack
		ELSE
			CALL navy(who, 3) 'move
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
	a = who
	CALL combine(a)
	CALL railroad(who)
	'---------------------------------------------------------------------------
	'                               Top Priority
	'---------------------------------------------------------------------------
	FOR i = star TO fin
		target = globalArmyLoc(i)
		IF globalArmyLoc(i) < 1 OR globalArmyMove(i) < 0 GOTO deadman
		x = globalArmySize(i)
		IF globalSupply(i) < 1 AND RND > .1 GOTO deadman

		globalChoose = 0

		CALL void(target, defend)

		IF defend > 0 AND target = globalCapCity(who) AND globalOccupied(target) = i GOTO deadman   'hold capital
		IF target <> globalCapCity(who) GOTO nocap
		IF globalVicFlag(5) = 0 GOTO nocap
		FOR j = 1 TO 6
			k = globalMatrix(target, j)
			IF j = 0 GOTO nocap
			CALL void(k, flag)
			IF flag > 0 GOTO deadman
		NEXT j
		nocap:
		CALL evaluate(i, best)
		IF best = 0 GOTO deadman
		move9:
		IF best = 0 THEN globalChoose = 1 + INT((j - 1) * RND)
		IF globalChoose = 0 THEN globalChoose = best
		globalArmyMove(i) = globalMatrix(target, globalChoose)

		IF globalCityP(globalArmyMove(i)) = who THEN 
			y = globalOccupied(globalArmyMove(i))
			IF y > 0 THEN 
				IF globalArmyMove(y) = x THEN 
					globalArmyMove(i) = 0
					GOTO deadman  ' eliminate crossing moves
				END IF
			END IF
		END IF
		IF month = 1 AND globalJanCam = 0 AND globalCityP(globalArmyMove(i)) <> who THEN 
			globalArmyMove(i) = 0
			GOTO deadman
		END IF

		IF globalTurbo! > 1 THEN
			COLOR c
			CALL clrbot
			PRINT globalArmyName$(i); " plans to move from "; globalCity$(globalArmyLoc(i)); " to "; globalCity$(globalArmyMove(i));
		END IF
		CALL icon(globalArmyLoc(i), globalArmyMove(i), 1)
		CALL icon(globalArmyLoc(i), globalArmyMove(i), 9)
		CALL TICK(globalTurbo! - 1)
		PUT (globalCityX(globalArmyLoc(i)) - 20, globalCityY(globalArmyLoc(i)) - 19), globalImage, PSET
	deadman:
	NEXT i
	FOR i = star TO fin
		IF globalArmyMove(i) = 0 AND globalArmyExper(i) < 6 AND globalArmyExper(i) < globalArmyLead(i) THEN
			globalArmyExper(i) = globalArmyExper(i) + 1

			IF globalTurbo! > 1 THEN
				CALL clrbot
				PRINT globalArmyName$(i); " has drilled to reach experience level "; globalArmyExper(i);
			END IF
			globalArmyMove(i) = -1
			CALL TICK(globalTurbo! - 1)
		END IF
	NEXT i
	EXIT SUB
	'---------------------------------------------------------------------------
	enufarmies:
	CALL starfin(star, fin, 3 - who)
	FOR i = star TO fin
		IF globalArmyLoc(i) > 0 THEN y = y + .1 * globalArmySize(i)
	NEXT i
	CALL starfin(star, fin, who)
	x = 0
	z = 0
	FOR i = star TO fin
		IF globalArmyLoc(i) > 0 THEN 
			x = x + 1
			z = z + .1 * globalArmySize(i)
		END IF
	NEXT i
	IF y > z THEN x = x - 2
	IF y > 2 * z THEN x = 0
	RETURN
END SUB

SUB snapshot (x, y, flag)
	IF flag = 0 THEN GET (x - 10, y - 10)-(x + 10, y + 10), globalImage
	IF flag = 1 THEN PUT (x - 10, y - 10), globalImage, PSET
END SUB

SUB strong (index)
	a$ = LTRIM$(RTRIM$(STR$(globalArmySize(index)))) + "00"
	PRINT a$;
END SUB

SUB tinytrain (who, flag)
	IF globalTracks(who) = 0 THEN EXIT SUB
	from = globalTracks(who)
	x = globalCityX(from) - 12
	y = globalCityY(from) - 11
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

SUB tupdate
	flag = 0
	IF globalPlayer = 1 THEN
		CALL smarts
	ELSE
		FOR i = 1 TO 40
			IF globalArmyLoc(i) > 0 AND globalArmyMove(i) > 0 THEN CALL icon(globalArmyLoc(i), globalArmyMove(i), 1)
		NEXT i
	END IF
	COLOR 14: LOCATE 1, 1: PRINT SPACE$(80);
	LOCATE 1, 20: PRINT "Update for "; globalMonth$(month); ","; globalYear
	CALL clrbot: PRINT "press any key for "; globalMonth$(month); ","; globalYear; " events";
	DO WHILE INKEY$ = "": LOOP
	GOSUB upbox
	'==========================================================================
	'                       Assign Time of Action
	'==========================================================================
	FOR i = 1 TO 2
		IF globalRR(i) > 0 THEN 
			CALL railroad(i)
			LINE (5, 17)-(100, 63), 3, BF: LINE (5, 17)-(100, 63), 0, B
			CALL engine
		END IF
	NEXT i

	FOR i = 1 TO 40
		globalBrray(i) = 999
		IF globalArmyMove(i) < 0 THEN globalArmyMove(i) = 0
		IF globalArmyLoc(i) > 0 AND globalArmyMove(i) > 0 THEN globalBrray(i) = INT(4 + 4 * RND) * 100 + i
		IF globalSupply(i) < 1 AND globalArmyMove(i) > 0 THEN globalBrray(i) = 900 + i
		SELECT CASE globalArmySize(i)         'bigger armies move slower
			CASE IS > 400
				IF globalBrray(i) < 900 THEN globalBrray(i) = globalBrray(i) + 100: x = 2
			CASE IS > 800
				IF globalBrray(i) < 800 THEN globalBrray(i) = globalBrray(i) + 200: x = 3
			CASE IS > 1000
				IF globalBrray(i) < 700 THEN globalBrray(i) = globalBrray(i) + 300: x = 4
			CASE ELSE
				x = 1
		END SELECT
		IF globalBrray(i) <> 999 AND globalArmyLead(i) > 10 * RND THEN
				globalBrray(i) = globalBrray(i) - 100 * (globalArmyLead(i) \ 2)
				IF globalBrray(i) < 100 THEN globalBrray(i) = 100 + i
		END IF
	NEXT i

	CALL bub2(40)
	'==========================================================================
	'                       Begin Main Loop
	'==========================================================================
	FOR j = 1 TO 40
		flag = 0
		IF globalBrray(j) = 999 GOTO allthru
		active = INT(globalBrray(j) / 100)
		active = globalBrray(j) - 100 * active
		s = 1
		IF active > 20 THEN s = 2
		IF globalArmyMove(active) < 1 GOTO digin
		COLOR 11
		CALL clrbot
		PRINT globalArmyName$(active); " is moving to "; globalCity$(globalArmyMove(active));

		globalSupply(active) = globalSupply(active) - 1
		IF globalSupply(active) < 0 THEN 
			globalSupply(active) = 0
			CALL TICK(globalTurbo!)
			CALL clrbot
			PRINT globalArmyName$(active); " is out of supplies !";
		END IF
		CALL placearmy(active)
		CALL icon(globalArmyLoc(active), globalArmyMove(active), 5)

		CALL animate(active, 0)

		target = globalArmyMove(active)
		IF globalOccupied(target) = 0 GOTO easy
		IF (s = 1 AND globalOccupied(target) < 21) OR (s = 2 AND globalOccupied(target) > 20) THEN
			GOTO friend
		ELSE
			GOTO enemy
		END IF
		friend: ' Join Forces
		COLOR 11
		CALL clrbot
		PRINT globalArmyName$(active); " and "; globalArmyName$(globalOccupied(target)); " meet in "; globalCity$(target);
		CALL TICK(globalTurbo!)
		CALL icon(globalArmyMove(active), 0, 6)
		CALL clrbot
		GOTO easy

		enemy: ' Attack
		CALL icon(target, 0, 3)
		defend = globalOccupied(target)

		COLOR 11
		CALL clrbot
		PRINT globalArmyName$(active); " attacks "; globalArmyName$(defend); " in "; globalCity$(globalArmyLoc(defend));
		CALL TICK(globalTurbo! - 1)
		IF globalArmySize(defend) > 0 THEN 
			CALL battle(active, defend, win, lose)
			flag = 1
			IF globalGraf > 0 THEN GOSUB upbox
		END IF
		IF globalArmyExper(win) < 10 THEN globalArmyExper(win) = globalArmyExper(win) + 1

		IF globalArmySize(lose) < 2 THEN
			CALL clrbot
			a$ = globalArmyName$(lose) + "'s army is crushed in " + globalCity$(globalArmyLoc(defend))
			CALL scribe(a$, 2)
			index = lose
			GOTO crushed
		END IF

		CALL clrrite
		'==========================================================================
		'                       Attacker Loses
		'==========================================================================
		IF win = active GOTO kickbutt
		globalArmyMove(active) = globalArmyLoc(active)
		globalArmyLoc(active) = target
		COLOR 11
		CALL clrbot
		PRINT globalArmyName$(active); " withdrew to "; globalCity$(globalArmyMove(active));

		CALL placearmy(globalArmyLoc(active))
		CALL animate(active, 1)

		globalArmyLoc(active) = globalArmyMove(active)
		CALL placearmy(globalArmyLoc(active))
		CALL placearmy(active)
		globalOccupied(globalArmyLoc(active)) = active
		globalArmyMove(active) = -2
			
		IF 11 * RND > globalArmyLead(defend) THEN 
			CALL icon(globalArmyLoc(defend), globalArmyMove(defend), 4)
			IF globalArmyMove(defend) > 0 THEN globalArmyMove(defend) = -2
		END IF

		CALL TICK(globalTurbo!)
		GOTO digin
		'==========================================================================
		'                       Defender Retreats
		'==========================================================================
		kickbutt:
		CALL icon(globalArmyLoc(active), target, 4)
		IF globalArmyMove(defend) > 0 THEN CALL icon(target, globalArmyMove(defend), 4)

		CALL retreat(defend, flee)
		IF flee > 0 THEN
			move2 = flee
			GOTO outta
		END IF

		best = 0
		flee = 0
		FOR i = 1 TO 6
			x = globalMatrix(target, i)
			IF x > 0 AND (globalCityP(x) = 3 - s) AND globalCityV(x) > best THEN
				IF best = 0 THEN
					flee = i
					best = globalCityV(x)
				ELSE
					IF globalOccupied(x) = 0 THEN 
						flee = i
						best = globalCityV(x)
					END IF
				END IF
			END IF
		NEXT i
		IF flee = 0 GOTO deadmeat
		move2 = globalMatrix(target, flee)
		outta:
		CALL placearmy(defend)                  ' in old city

		globalArmyMove(defend) = move2
		CALL animate(defend, 0)                 ' animate retreat
		
		globalArmyLoc(defend) = move2
		globalOccupied(move2) = defend
		CALL clrbot
		PRINT globalArmyName$(defend) + " is withdrawing to " + globalCity$(move2);

		CALL placearmy(defend)                  ' in new city
		
		CALL icon(target, 0, 6)
		globalArmyMove(defend) = -2
		GOTO holdon

		deadmeat:
		index = defend
		a$ = globalArmyName$(index) + " surrenders to " + globalArmyName$(active) + " in " + globalCity$(globalArmyLoc(index))
		CALL scribe(a$, 2)
		crushed:
		IF globalGraf > 2 THEN 
			CALL surrender(index)
			COLOR 14: LOCATE 3, 68: PRINT globalArmyName$(index): LOCATE 4, 68: PRINT "surrenders !"
		END IF
		x = 1
		IF index > 20 THEN x = 2
		IF globalNoise > 1 AND x <> globalSide THEN PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"
		IF globalArmyMove(index) > 0 THEN CALL icon(globalArmyLoc(index), globalArmyMove(index), 4)
		globalVictory(3 - s) = globalVictory(3 - s) + 25
		globalArmyLoc(index) = 0
		globalLName$(index) = ""
		globalArmyName$(index) = ""
		globalArmySize(index) = 0
		globalArmyLead(index) = 0
		globalArmyExper(index) = 0
		globalArmyMove(index) = 0
		globalSupply(index) = 0
		globalSupply(active) = globalSupply(active) + globalSupply(index)
		globalSupply(index) = 0
		IF globalSupply(active) > 10 THEN globalSupply(active) = 10
		CALL TICK(9)
		CALL clrrite
		IF globalArmyLoc(active) = 0 GOTO digin
		'---------------------------------------------------------------------------
		'                       check for more defenders !
		'---------------------------------------------------------------------------
		holdon:
		CALL occupy(target)
		IF globalOccupied(target) = 0 GOTO easy
		COLOR 11
		CALL clrbot
		PRINT "There are still defenders in "; globalCity$(target);
		CALL TICK(99)
		GOTO enemy
		'==========================================================================
		'                       Move Into New City
		'==========================================================================
		easy:
		CALL icon(globalArmyLoc(active), target, 4)
		globalArmyLoc(active) = target
		globalArmyMove(active) = -2
		CALL occupy(globalArmyLoc(active))
		CALL placearmy(active)
		'---------------------------------------------------------------------------
		'                            City Capture
		'---------------------------------------------------------------------------
		IF globalCityP(globalArmyLoc(active)) = s GOTO horde
		c = globalArmyLoc(active)
		IF globalPlayer = 1 AND s = globalSide AND globalFort(c) > 0 AND flag = 0 THEN
			globalTLX = 67
			globalTLY = 15
			globalHilite = 15
			globalColour = 3
			globalMTX$(0) = "Raze ?"
			globalMTX$(1) = "No"
			globalMTX$(2) = "Yes"
			globalSize = 2
			CALL menu(0)
			CALL clrrite
			IF globalChoose = 2 GOTO smoke
		END IF
		IF globalPlayer = 1 AND s <> globalSide AND globalFort(c) > 0 AND flag = 0 THEN
			IF globalRealism > 0 AND globalCityY(c) > 150 THEN
				smoke:
				globalFort(c) = 0
				x = globalCityX(c)
				y = globalCityY(c)
				LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
				CALL showcity
				CALL clrbot
				PRINT globalArmyName$(active); " has destroyed the forts at "; globalCity$(c);
				TICK 3
			END IF
		END IF
		CALL capture(active, c, s, flag)
		horde:
		IF globalSupply(active) < 10 THEN 
			globalSupply(active) = globalSupply(active) + 1
			IF RND > .8 GOTO horde
		END IF
	digin:
	NEXT j
	GOTO allthru

	upbox:
	LINE (450, 318)-(526, 420), 1, BF
	LINE (527, 315)-(527, 439), 10
	COLOR 14: LOCATE 23, 50: PRINT "�������������ͻ"
	LOCATE 24, 50: PRINT "� U P D A T E �"
	LOCATE 25, 50: PRINT "�������������ͼ"
	RETURN

	allthru:
	IF globalNavySize(globalCommerce) < 1 THEN globalCommerce = 0
	IF globalCommerce > 0 THEN
		CALL clrbot
		IF RND < .8 + .02 * globalNavySize(globalCommerce) THEN
			globalRaider = .05 * globalNavySize(globalCommerce) * (1 + RND) * (globalIncome(3 - globalCommerce))
			IF globalRaider < 1 THEN globalRaider = 1
			IF globalRaider / globalIncome(3 - globalCommerce) > .3 THEN globalRaider = .3 * globalIncome(3 - globalCommerce)
			COLOR 15: PRINT globalForce$(globalCommerce); " raiders have sunk $"; globalRaider; " of "; globalForce$(3 - globalCommerce); " commerce";
			a = 1
			IF LEFT$(globalFleet$(globalCommerce), 1) = "I" THEN a = 2
			PSET (500, 465), 0: CALL shipicon(globalCommerce, a)
			IF globalNoise > 0 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
			IF globalCommerce = globalSide THEN globalGrudge = 1
			TICK 9
		ELSE
			globalRaider = 0
			CALL barnacle(globalCommerce)
			COLOR 15: PRINT globalForce$(globalCommerce); " raiders have lost a ship ("; globalNavySize(globalCommerce); " remain)";
			IF globalNoise > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
			IF globalNavyLoc(globalCommerce) > 0 THEN
				TICK 9
				GOTO allthru
			ELSE
				globalCommerce = 0
				LINE (447, 291)-(525, 335), 1, BF
				FOR k = 1 TO 5
					CIRCLE (480, 315), 4 * k, 11
				NEXT k
				TICK 9
				LINE (447, 291)-(525, 335), 1, BF
			END IF
		END IF
	END IF

	CALL touchup
	CALL ships
	CALL iterate

	CALL clrbot
	LINE (390, 350)-(520, 400), 1, BF
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(globalMonth$(month), 3)); ","; globalYear
	globalVictory(1) = .8 * globalVictory(1) + .3 * (globalIncome(1) + globalControl(1))
	IF globalControl(1) > 29 THEN 
		globalVictory(1) = globalVictory(1) + 50
		IF globalControl(1) > 34 THEN globalVictory(1) = globalVictory(1) + 100
	END IF
	IF globalSide = 2 AND globalControl(1) < 11 THEN globalAggress! = globalAggress! + .7

	IF globalVictory(1) < 1 THEN globalVictory(1) = 0
	globalVictory(2) = .8 * globalVictory(2) + .3 * (globalIncome(2) + globalControl(2))
	IF globalControl(2) > 29 THEN 
		globalVictory(2) = globalVictory(2) + 50
		IF globalControl(2) > 34 THEN globalVictory(2) = globalVictory(1) + 100
	END IF
	IF globalSide = 1 AND globalControl(2) < 11 THEN globalAggress! = globalAggress! + .7
	IF globalPlayer = 2 THEN 
		CALL clrbot
		COLOR 14: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
	END IF
END SUB

' CWSTRAT2.BAS
SUB armyxy (x, y, z)
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

SUB bub2 (limit)
	DO
		swaps% = FALSE
		FOR i = 1 TO limit - 1
			IF globalBrray(i) > globalBrray(i + 1) THEN
				SWAP globalBrray(i), globalBrray(i + 1)
				swaps% = i
			END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB bubble (limit)
	DO
		swaps% = FALSE
		FOR i = 1 TO limit - 1
			IF globalMTX$(i) > globalMTX$(i + 1) THEN
				SWAP globalMTX$(i), globalMTX$(i + 1)
				SWAP globalArray(i), globalArray(i + 1)
				swaps% = i
			END IF
		NEXT i
	LOOP WHILE swaps%
END SUB

SUB cancel (globalSide)
	CALL starfin(star, fin, (globalSide))
	counter:
	CALL clrrite
	globalSize = 0
	FOR j = star TO fin
		a$ = globalArmyName$(j)
		IF LEN(a$) > 10 THEN 
			x = INSTR(a$, " ")
			a$ = RIGHT$(a$, LEN(a$) - x)
		END IF
		IF globalArmyLoc(j) > 0 AND globalArmyMove(j) > 0 THEN 
			globalSize = globalSize + 1
			globalMTX$(globalSize) = a$
			globalArray(globalSize) = globalArmyLoc(j)
		END IF
	NEXT j
	CALL bubble(globalSize)
	globalTLX = 67
	globalTLY = 2
	globalWType = 2
	globalMTX$(0) = "Cancel"
	IF globalSize < 1 THEN 
		CALL clrbot
		COLOR 11: PRINT "No units have orders to cancel";
		EXIT SUB
	END IF
	CALL menu(1)
	SELECT CASE globalChoose
		CASE 1 TO globalSize
			target = globalArray(globalChoose)
			
			FOR i = star TO fin
				IF globalArmyLoc(i) = target THEN 
					x = INSTR(globalArmyName$(i), globalMTX$(globalChoose))
					IF x > 0 AND globalArmyMove(i) > 0 THEN index = i
				END IF
			NEXT i

			CALL clrbot
			COLOR 11: PRINT globalArmyName$(index); " has cancelled move to "; globalCity$(globalArmyMove(index));
			CALL TICK(globalTurbo + 1)
			CALL icon(globalArmyLoc(index), globalArmyMove(index), 4)
			globalArmyMove(index) = 0
			IF globalNoise > 0 THEN SOUND 2999, .5
			CALL stax(globalSide)
		CASE ELSE
		GOTO finix
	END SELECT
	finix:
	CALL clrrite
END SUB

SUB cannon
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

SUB capitol
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
	IF globalNoise = 2 THEN PLAY "T130MFMSO2f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4"
	LOCATE 20, 20: PRINT CHR$(34); "... and that the government of the people,"
	IF globalNoise = 2 THEN PLAY "o2b-8.a16g8.g16g8.a16b-8.a16b-8.g16f8.g16f8.d16f4"
	LOCATE 21, 20: PRINT "by the people, for the people,"
	IF globalNoise = 2 THEN PLAY "f8.f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4b-4MNo3c4c4o2b-4a4b-2"
	LOCATE 22, 20: PRINT "shall not perish from the earth."; CHR$(34)
	LOCATE 25, 40: PRINT "- Abraham Lincoln"
	FOR i = -565 TO 50 STEP 50: CALL flags(1, i, 0): NEXT i
	IF globalNoise = 2 THEN PLAY "P2f4..e-16d8.f16b-8.o3c16d2o2b-2g4..a16b-8.a16b-8.g16f2d2": PLAY "f4..e-16d8.f16b-8.o3c16d2o2b-4b-4o3c4c4o2b-4a4b-2.."
END SUB

SUB capture (active, c, s, flag)
	globalCityP(c) = s
	CALL clrbot
	a$ = globalArmyName$(active) + " has captured " + globalCity$(c)
	COLOR 11: PRINT globalArmyName$(active) + " has captured " + globalCity$(c);
	IF active < 21 AND globalNoise > 1 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	IF active > 20 AND globalNoise > 1 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	IF c <> globalCapCity(3 - s) THEN CALL flashcity(c)
	globalVictory(s) = globalVictory(s) + globalCityV(c)
	IF c = globalCapCity(3 - s) THEN
		globalVictory(s) = globalVictory(s) + 100
		globalVictory(3 - s) = globalVictory(3 - s) - 100
		a$ = globalForce$(3 - s) + " CAPITAL captured !"
		CALL scribe(a$, 1)
		CALL image2(globalCity$(globalCapCity(3 - s)) + " has fallen!", 4)
		globalCapCity(3 - s) = 0
		CALL flashcity(c)
	END IF
	IF globalFort(c) > 0 AND flag > 0 THEN 
		globalFort(c) = globalFort(c) - 1
		x = globalCityX(c)
		y = globalCityY(c)
		LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
		CALL showcity
	END IF
END SUB

SUB center (y, a$)
	x = LEN(a$)
	x = 26 - x \ 2
	LOCATE y, 7 + x: PRINT a$
END SUB

SUB chessie
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

SUB clrbot
	LOCATE 29, 1: PRINT SPACE$(79);
	LOCATE 29, 1
END SUB

SUB clrrite
	VIEW (528, 1)-(639, 450)
	CLS 1
	VIEW
END SUB

SUB commander (who, empty)
	empty = 0
	CALL starfin(star, fin, who)
	FOR i = star TO fin
		IF globalArmyLoc(i) = 0 AND globalLName$(i) <> "" THEN empty = i: EXIT SUB
	NEXT i

'                 generic leaders if set list is exhausted
	FOR i = star TO fin
		IF globalArmyLoc(i) = 0 THEN
			x = i
			CALL roman(x, a$)
			empty = i
			globalLName$(i) = a$
			globalRating(i) = 1 + 8 * RND
			EXIT SUB
		END IF
	NEXT i
	CALL clrbot
	PRINT "No more "; globalForce$(who); " commanders available";
	CALL TICK(globalTurbo!)
END SUB

SUB endit
	a$ = STR$(ABS(globalVicFlag(3)) * 2.5) + "% Cities"
	t$ = STR$(ABS(globalVicFlag(3)) * 2.5) + "% Total Income"
	globalMTX$(8) = "Time: " + globalMonth$(globalVicFlag(1)) + STR$(ABS(globalVicFlag(2)))
	globalMTX$(9) = RTRIM$(STR$(ABS(globalVicFlag(6)))) + ":1 Force Ratio"
	COLOR 15: LOCATE 1, 1: PRINT "Press ENTER to toggle ending conditions";
	COLOR 14: PRINT "				ESC when done"
	what4:
	FOR i = 2 TO 6
		IF globalVicFlag(i) > 0 THEN globalMTX$(i - 1) = "� " ELSE globalMTX$(i - 1) = "  "
	NEXT i
	globalChoose = chosit
	globalMTX$(0) = "Victory Conditions"
	globalMTX$(1) = globalMTX$(1) + globalMTX$(8)
	globalMTX$(2) = globalMTX$(2) + a$
	globalMTX$(3) = globalMTX$(3) + t$
	globalMTX$(4) = globalMTX$(4) + "Capital Captured"
	globalMTX$(5) = globalMTX$(5) + globalMTX$(9)
	globalMTX$(6) = "DONE"
	globalWType = 2
	globalColour = 3
	globalSize = 6
	globalHilite = 14
	CALL menu(0)
	chosit = 21 + globalChoose
	SELECT CASE globalChoose
		CASE 1
			globalVicFlag(2) = -globalVicFlag(2)
		CASE 2 TO 5
			globalVicFlag(globalChoose + 1) = -globalVicFlag(globalChoose + 1)
		CASE ELSE
			GOTO cheer
	END SELECT
	GOTO what4
	cheer:
	CLS
	CALL usa
END SUB

SUB engine
	IF globalRR(1) + globalRR(2) = 0 GOTO notrain
	LINE (5, 17)-(100, 63), 3, BF
	LINE (5, 17)-(100, 47), 0, B
	LINE (5, 47)-(100, 63), 0, B

	FOR i = 1 TO 2
		IF globalRR(i) = 0 GOTO notrane
		PSET (15, 25), 3
		c = 9
		IF i = 2 THEN c = 15
		PSET (60, 25), 3
		DRAW "C0S4R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5BF4"
		x = POINT(0): y = POINT(1): PAINT (x, y), c, 0
		LOCATE 4, 6 * (i - 1) + 2: PRINT LEFT$(globalCity$(globalArmyMove(globalRR(i))), 5)
	notrane:
	NEXT i

notrain:
END SUB

SUB evaluate (index, x)
	from = globalArmyLoc(index)
	x = 200
	IF globalAggress! > 1.5 THEN 
		x = 80
		IF globalAggress! > 2 THEN 
			x = 20
			IF globalAggress! > 3 THEN x = 5
		END IF
	END IF
	CALL void(from, defend)
	IF defend = 0 THEN x = 0
	IF globalBold > 1 THEN x = .5 * x

	best = globalArmySize(index)

	FOR j = 1 TO 6
		globalArray(j) = -1
		a = globalMatrix(from, j)
		IF a > 0 THEN 
			IF globalOccupied(a) > 0 THEN 
				best = best - globalArmySize(globalOccupied(a))
				y = 1
			END IF
		END IF
	NEXT j
	best = .01 * best
	IF globalBold > 0 THEN best = best + 20 * globalBold

	CALL starfin(star, fin, 3 - globalSide)

	FOR j = 1 TO 6
		y = -1
		a = globalMatrix(from, j)
		IF a = 0 THEN 
			max = j - 1
			GOTO alleval
		END IF
      
		c = globalOccupied(a)
		FOR k = star TO fin
			IF globalArmyLoc(k) > 0 THEN 
				IF globalArmyMove(k) = a AND c = 0 GOTO alle
			END IF
		NEXT k
		
		y = best - x * globalFort(from) - globalCityV(from) + 30 * RND
		IF globalFort(from) > 0 THEN 
			IF index = globalOccupied(from) THEN 
				y = y - 25
				IF globalRealism > 0 THEN y = y - 50
			END IF
		END IF
		IF a = globalCapCity(globalSide) THEN 
			IF globalVicFlag(5) > 0 THEN y = y + 200
		END IF
		IF globalCityP(a) <> 3 - globalSide THEN 
			y = y + 5 * globalCityV(a) + 10 * globalFort(a)
		END IF
		IF globalCityP(a) <> globalSide GOTO ourn
		IF c = 0 THEN y = y + 10 * globalCityV(a): GOTO ourn
		x1 = 1
		IF globalFort(a) = 1 THEN 
			x1 = 2
			IF globalFort(a) = 3 THEN x1 = 3
		END IF

		IF globalArmySize(c) > 0 THEN
			odds! = globalArmySize(index) / (x1 * globalArmySize(c))
			IF globalRealism > 1 THEN odds! = .8 * odds!
		ELSE
			odds! = 5
		END IF

		IF globalArmySize(index) < 15 THEN y = y - 300: odds! = .1
		IF globalBold < 3 AND globalArmySize(index) < 40 AND odds! < .8 THEN y = 0
		IF globalRealism > 0 THEN y = y - 15
		IF odds! < .5 THEN y = y - 200
		IF globalBold = 0 AND RND > .9 THEN 
			y = y + 10 * (globalArmyLead(index) - globalArmyLead(c) + globalArmyExper(index) - globalArmyLead(index))
		END IF
		IF globalSupply(index) < 1 THEN y = y - 100
		SELECT CASE odds! + .5 * globalBold
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
				y = y + .5 * (globalArmySize(index) - globalArmySize(c)) + 50 * RND
		END SELECT
		ourn:
		IF globalCityP(a) = 3 - globalSide AND c > 0 AND globalArmyMove(c) = 0 THEN y = y - globalArmySize(c)
		IF globalSide = 1 AND globalCityY(a) < globalCityY(from) THEN y = y + 2
		IF globalSide = 2 AND globalCityY(a) > globalCityY(from) THEN y = y + 2

		FOR k = 1 TO 6
			m = globalMatrix(a, k)
			IF m = 0 GOTO tally3
			IF globalCityP(m) = 0 THEN y = y + 3 * globalCityV(m) + 4 * globalFort(m)
			IF globalCityP(m) = globalSide THEN y = y + 3 * globalCityV(m) + 4 * globalFort(m)
			IF globalCityP(m) = globalSide AND c > 0 THEN
				odds! = 5 - 4 * RND
				IF globalArmySize(c) > 0 THEN odds! = globalArmySize(index) / globalArmySize(c) ELSE odds! = 5
				IF odds! < 1 THEN y = y - 2
			END IF
			IF globalCityP(m) = globalCapCity(globalSide) THEN y = y + 50
		tally3:
		NEXT k

		globalArray(j) = y
		alle:
	NEXT j
	max = 6
	alleval:
	x = 0
	best = 0
	FOR j = 1 TO max
		IF globalArray(j) < 0 GOTO allof
		IF globalArray(j) > x THEN x = globalArray(j): best = j
	allof:
	NEXT j
	IF defend > globalArmySize(index) AND globalArray(best) < 50 THEN best = 0
	x = best
END SUB

SUB events ' Special Events
	IF globalRealism > 0 AND globalYear = 1862 AND month < 3 THEN
		COLOR 14
		CALL clrbot
		PRINT "SPECIAL DEVELOPMENT : IRONCLAD ships now available";
		IF globalNoise > 0 THEN 
			FOR k = 1 TO 5
				SOUND 140, 1: SOUND 37, 1
			NEXT k
		END IF
		DO WHILE INKEY$ = "": LOOP
		EXIT SUB
	END IF
	IF globalRandBal = 0 THEN EXIT SUB
	plus = globalDifficult
	IF globalSide = 1 THEN plus = 6 - globalDifficult
	pct! = .005 * (globalYear - 1860) * plus * plus
	IF pct! > .9 THEN pct! = .9
	IF RND > pct! THEN EXIT SUB

	CALL clrbot
	COLOR 14: PRINT "SPECIAL EVENT...";
	who = 1
	IF RND > .1 * globalRandBal THEN who = 2

	SELECT CASE who
		CASE 1 ' good for South
			IF globalYear = 1864 AND month = 1 THEN globalVictory(2) = globalVictory(2) + 50
			IF globalYear = 1865 AND month = 1 THEN globalVictory(2) = globalVictory(2) + 100
			IF RND > .9 THEN GOSUB riot: EXIT SUB

			CALL clrbot
			IF RND > .2 OR globalNavySize(2) > 9 GOTO mercen
			IF globalNavySize(2) > 0 AND globalNavyLoc(2) <> 99 THEN 
				empty = globalNavyLoc(2)
				GOTO float1
			END IF
			empty = 0
			FOR i = 1 TO 40
				IF globalCityP(i) = 2 AND globalMatrix(i, 7) = 99 AND globalNavyLoc(1) <> i THEN empty = i: EXIT FOR
			NEXT i
			IF empty = 0 GOTO mercen
			float1:
			CALL scribe("England has given ships to the South", 2)
			globalNavySize(2) = globalNavySize(2) + 2 * plus
			IF globalNavySize(2) > 10 THEN globalNavySize(2) = 10
			x = globalNavySize(2) - LEN(globalFleet$(2))
			globalFleet$(2) = globalFleet$(2) + STRING$(x, "W")
			globalNavyLoc(2) = empty: CALL ships
			GOTO dull1
			mercen:
			IF RND > .1 OR globalControl(2) < 30 GOTO money
			a$ = "French"
			IF RND > .5 THEN a$ = "British"
			CALL scribe(a$ + " mercenaries join " + globalArmyName$(index) + "'s army", 2)
			globalArmySize(index) = globalArmySize(index) + 100 * plus
			globalArmyExper(index) = 10
			globalSupply(index) = 10
			GOTO dull1
			money:
			IF RND > .3 OR globalControl(2) < 12 GOTO cotton
			CALL scribe("The South has obtained a loan from Europe", 2)
			GOTO purse
			cotton:
			IF RND > .5 OR globalControl(2) < 12 GOTO uprising
			CALL scribe("Cash from cotton sales fill the Rebel Treasury", 2)
			purse:
			globalCash(2) = globalCash(2) + 100 * plus
			GOTO dull1
			uprising:
			pct! = .9
			a$ = "Union troops diverted to fight Western Indian uprisings"
			IF RND > .5 THEN a$ = "Union 90-day enlistees return home"
			IF globalYear = 1864 AND month > 5 THEN 
				a$ = "20% of Union forces take furloughs to vote in 1864 elections"
				pct! = .8
			END IF
			CALL scribe(a$, 2)
			FOR k = 1 TO 20
				globalArmySize(k) = pct! * globalArmySize(k)
			NEXT k
			GOTO dull1
			'----------------------------------------------------------------------------
			riot:
			IF globalRealism = 0 THEN RETURN
			IF globalControl(who) = 1 THEN EXIT SUB
			FOR k = 1 TO 99
				x = 1 + INT(40 * RND)
				IF globalCityO(x) <> who AND globalCityP(x) = who AND globalOccupied(x) = 0 THEN
					CALL clrbot
					COLOR 15
					PRINT " Riots have broken out in "; globalCity$(x);
					globalCityP(x) = 0
					CALL showcity
					TICK globalTurbo!
					CALL clrbot
					CALL image2(globalCity$(x) + " is now NEUTRAL !", 4)
					TICK globalTurbo!
					RETURN
				END IF
			NEXT k
			RETURN
		CASE 2 ' good for Union
			IF RND > .1 OR globalNavyLoc(1) = 0 OR globalNavySize(1) > 9 GOTO event2
			IF RND > .95 THEN 
				GOSUB riot
				EXIT SUB
			END IF
			CALL scribe("Union shipworks have produced extra ships", 2)
			globalNavySize(1) = globalNavySize(1) + plus
			IF globalNavySize(1) > 10 THEN globalNavySize(1) = 10
			x = globalNavySize(1) - LEN(globalFleet$(1))
			globalFleet$(1) = globalFleet$(1) + STRING$(x, "W")
			GOTO dull2
			event2:
			IF RND < .7 GOTO abe
			CALL scribe("Volunteer troops swell the Union ranks", 2)
			x = 0
			FOR i = 1 TO 20
				x = x + 1
				IF x > 5 GOTO dull2
				IF globalArmySize(i) > 0 AND RND > .5 THEN globalArmySize(i) = globalArmySize(i) * 1.1 + plus
			NEXT i
			GOTO dull2
			abe:
			IF globalEmancipate = 0 AND globalYear > 1862 THEN
				globalEmancipate = 1
				CALL scribe("Abraham Lincoln announces the Emancipation Proclamation", 2)
				globalVictory(1) = globalVictory(1) + 100: globalVictory(2) = globalVictory(2) - 100
				CALL usa
				GOTO dull2
			END IF
			IF globalYear = 1864 AND month = 11 THEN
				CALL scribe("Lincoln has been reelected", 2)
				globalVictory(2) = .5 * globalVictory(2)
				GOTO dull2
			END IF
			IF RND > .5 THEN
				CALL scribe("Wealthy Unionists give generously to the Federal Cause", 2)
				globalCash(1) = globalCash(1) + 100 * plus
				GOTO dull2
			END IF
			IF RND > .5 AND globalYear > 1861 THEN
				CALL scribe("Rebel deserters leave the battlefield to go home", 2)
				FOR i = 21 TO 40
					globalArmySize(i) = .92 * globalArmySize(i)
				NEXT i
				GOTO dull2
			END IF
			IF RND > .5 AND globalYear > 1861 THEN
				CALL scribe("Union soldiers now have repeating rifles", 2)
				FOR i = 1 TO 20
					IF globalArmyExper(i) < 9 THEN globalArmyExper(i) = globalArmyExper(i) + 2
				NEXT i
			END IF
			CALL scribe("Secretary of War Stanton predicts the end of the Rebellion", 2)
			globalVictory(1) = globalVictory(1) + 10: GOTO dull2
		CASE ELSE
	END SELECT

	dull2:
	IF globalNoise = 2 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	DO WHILE INKEY$ = "": LOOP: EXIT SUB
	dull1:
	IF globalNoise = 2 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	DO WHILE INKEY$ = "": LOOP
END SUB

SUB flags (who, w, a)
	x = 585 + w
	y = 200
	IF w = 0 THEN y = 180
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

SUB image2 (a$, s)
	DIM g2(1 TO 8000)
	globalMTX$(1) = a$
	globalTLX = 32 - LEN(a$) \ 2
	globalTLY = 10: globalSize = 1
	CALL mxw(wide)
	IF wide > 59 THEN 
		wide = 59
		a$ = LEFT$(a$, 59)
	END IF
	x = 8 * (globalTLX + wide)
	y = 16 * (globalTLY + 1)
	GET (8 * globalTLX - 4, 16 * globalTLY - 3)-(8 * (globalTLX + wide + 1) + 15, 16 * (globalTLY + 3) + 7), g2
	VIEW (8 * globalTLX - 4, 16 * globalTLY - 3)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + 3) + 4)
	CLS 1
	VIEW
	LINE (8 * globalTLX, 16 * globalTLY - 1)-(8 * (globalTLX + wide + 1) + 15, 16 * (globalTLY + 3) + 7), 0, BF
	LINE (8 * globalTLX - 4, 16 * globalTLY - 3)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + 3)), s, BF
	LINE (8 * globalTLX - 4, 16 * globalTLY - 3)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + 3)), 15, B
	COLOR 14
	LOCATE globalTLY + 2, globalTLX + 2: PRINT a$
	CALL TICK(9)
	PUT (8 * globalTLX - 4, 16 * globalTLY - 3), g2, PSET
END SUB

SUB integrity
	CLS
	COLOR 15
	x = 0: y = 0
	FOR i = 1 TO 40
		FOR j = 1 TO 6
			IF globalMatrix(i, j) = 0 GOTO done
			index = globalMatrix(i, j)
			FOR k = 1 TO 6
				IF globalMatrix(index, k) = i GOTO ret
				IF globalMatrix(index, k) = 0 THEN 
					globalMatrix(index, k) = i
					PRINT "+ Adding return route from "; globalCity$(index); " to "; globalCity$(i)
					y = y + 1
					GOTO ret
				END IF
			NEXT k
			x = x + 1
			PRINT "Error in CITIES.GRD entry for city #"; i; globalCity$(index); ": no return route to "; globalCity$(i)
			TICK 1
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
		FOR j = 1 TO LEN(globalCity$(k))
			a = globalCityX(k) + 6 * (j - 4) - 3
			x = ASC(MID$(UCASE$(globalCity$(k)), j, 1)) - 64
			IF a > 527 GOTO nextc
			PSET (a, globalCityY(k) + 12), 10
			
			IF globalMatrix(k, 7) < 90 THEN
				IF globalBW = 0 THEN DRAW "S4C0" ELSE DRAW "S4C7"
			ELSE
				DRAW "C10"
			END IF
			IF x > 0 AND x < 27 THEN DRAW globalFont$(x)
		NEXT j
	nextc:
	NEXT k
END SUB

SUB maxx
	COLOR 14: LOCATE 28, 1: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
	SCREEN 0: COLOR 14, 5: CLS : COLOR 11, 0

	LOCATE 2, 7: PRINT STRING$(57, "�")
	LOCATE 9, 7: PRINT STRING$(57, "�")
	FOR i = 1 TO 6
		LOCATE 2 + i, 7: PRINT "�"; SPACE$(55); "�"
	NEXT i

	OPEN "I", 1, "hiscore.cws"
	FOR s = 1 TO 2
		COLOR 14, 4: LOCATE 3, 30 * (s - 1) + 10: PRINT globalForce$(s); " HALL of FAME"
		COLOR 15, 0
		FOR i = 1 TO 5
			INPUT #1, globalCity$(5 * (s - 1) + i), globalMatrix(s, i)
			LOCATE 3 + i, 30 * (s - 1) + 8: PRINT i, globalCity$(5 * (s - 1) + i), globalMatrix(s, i)
		NEXT i
	NEXT s
	CLOSE #1
		      
	FOR s = 1 TO 2
		FOR i = 1 TO 5
			IF globalVictory(s) < globalMatrix(s, i) GOTO oldskor
			FOR j = 5 TO i + 1 STEP -1
				globalMatrix(s, j) = globalMatrix(s, j - 1)
				globalCity$(5 * (s - 1) + j) = globalCity$(5 * (s - 1) + j - 1)
			NEXT j

			COLOR 15, 1
			IF s = 2 THEN COLOR 4, 7
			FOR k = 12 TO 14
				LOCATE k, 1: PRINT SPACE$(80);
			NEXT k
			LOCATE 12, 1: PRINT "Congratulations ! Score of"; globalVictory(s)
			PRINT "New Entry into "; globalForce$(s); " HALL of FAME in place "; i
			IF globalPlayer = 1 AND s <> globalSide THEN 
				a$ = "COMPUTER": PRINT a$; " was "; globalForce$(s); " commander"
				GOTO automate
			END IF
			who4:
			PRINT "What is name of "; globalForce$(s); " commander"; : INPUT a$
			IF a$ = "" GOTO who4
			automate:
			globalCity$(5 * (s - 1) + i) = a$
			globalMatrix(s, i) = globalVictory(s)
			GOTO foun
		oldskor:
		NEXT i
	foun:
	NEXT s
	       
	OPEN "O", 1, "hiscore.cws"
	FOR s = 1 TO 2
		FOR i = 1 TO 5
			WRITE #1, globalCity$(5 * (s - 1) + i), globalMatrix(s, i)
		NEXT i
	NEXT s
	CLOSE #1
	PRINT "Game Over": DO WHILE INKEY$ = "": LOOP
	globalPCode = 1
END SUB

SUB occupy (x)
	globalOccupied(x) = 0
	FOR i = 1 TO 40
		IF globalArmyLoc(i) = x THEN globalOccupied(x) = i: GOTO holdup
	NEXT i
holdup:
END SUB

SUB relieve (who)
	globalColour = 3
	target = 0
	globalHilite = 3
	globalTLX = 67
	globalTLY = 2
	CALL starfin(star, fin, who)
	globalSize = 0
	FOR i = star TO fin
		IF globalArmySize(i) > 0 AND globalArmyLoc(i) > 0 AND globalArmyMove(i) = 0 THEN
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalArmyName$(i)
			IF LEN(globalMTX$(globalSize)) > 11 THEN globalMTX$(globalSize) = LEFT$(globalMTX$(globalSize), 11)
			globalArray(globalSize) = i
		END IF
	NEXT i

	IF globalSize = 0 THEN EXIT SUB
	CALL bubble(globalSize)
	globalMTX$(0) = "Relieve"
	globalChoose = 31
	globalHilite = 11
	CALL menu(6)
	CALL clrrite

	IF globalChoose < 1 THEN EXIT SUB
	index = globalArray(globalChoose)
	CALL icon(globalArmyLoc(index), 0, 9)

	t$ = globalArmyName$(index)
	globalLName$(index) = t$

	globalSize = 0
	FOR i = star TO fin
		IF globalLName$(i) <> "" THEN
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalLName$(i)
			IF LEN(globalMTX$(globalSize)) > 11 THEN globalMTX$(globalSize) = LEFT$(globalMTX$(globalSize), 11)
			globalArray(globalSize) = i
		END IF
	NEXT i
	CALL bubble(globalSize)

	have2:
	globalMTX$(0) = "New Leader"
	globalTLX = 67
	globalTLY = 2
	CALL menu(0)
	CALL clrrite
	IF globalChoose < 1 GOTO have2
	globalArmyMove(index) = -1
	globalArmyLead(index) = globalRating(globalArray(globalChoose))
	IF globalArmyLead(index) > 0 THEN globalArmyLead(index) = globalArmyLead(index) - 1
	IF globalArmyExper(index) > 0 THEN globalArmyExper(index) = globalArmyExper(index) - 1
	COLOR 15
	CALL clrbot
	PRINT globalLName$(globalArray(globalChoose)); " has replaced "; t$; " in "; globalCity$(globalArmyLoc(index));
	TICK 9
	globalArmyName$(index) = globalLName$(globalArray(globalChoose))
	globalLName$(globalArray(globalChoose)) = ""
	CALL icon(globalArmyLoc(index), 0, 8)
	CALL clrbot
END SUB

SUB report (who)
	DIM summ(40)
	IF who = -1 GOTO frep
	IF who > 100 GOTO batrep
	globalMTX$(0) = "Information"
	globalMTX$(1) = globalForce$(globalSide) + " Armies"
	globalMTX$(2) = globalForce$(3 - globalSide) + " Armies"
	globalMTX$(3) = "Cities"
	globalMTX$(4) = "Force Summary"
	globalMTX$(5) = "Intelligence"
	globalMTX$(6) = "Battles": globalSize = 6
	IF _FILEEXISTS("cws.his") THEN globalMTX$(7) = "Recap": globalSize = 7
	CALL menu(0)
	SELECT CASE globalChoose
		CASE IS < 0
			CLS
			CALL usa
			EXIT SUB
		CASE 2: who = 3 - globalSide
		CASE 3: GOTO cityrep
		CASE 4: GOTO frep
		CASE 5: GOTO srep
		CASE 6: GOTO batrep
		CASE 7: GOTO recap
		CASE ELSE
	END SELECT
	'..........................................................................
	'                               Army Report
	'..........................................................................
	IF globalChoose < 0 GOTO endrep
	IF globalChoose = 4 GOTO frep
	CALL starfin(star, fin, who)
	CLS
	LOCATE 1, 1
	c = 9
	IF who = 2 THEN c = 15
	COLOR c
	PRINT " Report for "; globalForce$(who); " Forces"; TAB(30); globalMonth$(month); ","; globalYear; TAB(49); : COLOR 14: PRINT " Victory Points "; globalVictory(who);
	IF c = 15 THEN c = 7
	x = globalVictory(who) + globalVictory(3 - who)
	IF x = 0 THEN
		PRINT
	ELSE
		y = (globalVictory(who) / x) * 100
		PRINT "("; y; " %)";
	END IF
	CALL armyxy(215, 8, who)
	COLOR c: PRINT globalControl(who); "/ 40"; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(globalControl(who) * 2.5 + .5): PRINT x; "%)";
	PRINT TAB(50); : COLOR 12: PRINT "Capital: "; globalCity$(globalCapCity(who))
	y = globalVPTotal
	IF globalCapCity(1) > 0 THEN y = y + 100
	IF globalCapCity(2) > 0 THEN y = y + 100
	PRINT globalIncome(who); "/"; y; TAB(15); "INCOME"; TAB(40); "("; : x = (globalIncome(who) / globalVPTotal) * 100: PRINT x; "%)   "; : COLOR 14: PRINT "Cash:"; globalCash(who)
	COLOR 11: PRINT " #      Name             Size  Location   Ldr Exp Suply Move To"
	x = 0
	FOR i = star TO fin
		COLOR c
		IF globalArmyLoc(i) < 1 GOTO deadeye
		x = x + globalArmySize(i)
		PRINT i; TAB(5); globalArmyName$(i); TAB(25); : y = CSRLIN
		CALL strong(i): PRINT TAB(32); globalCity$(globalArmyLoc(i));
		IF who <> globalSide THEN PRINT : GOTO deadeye
		PRINT TAB(43); globalArmyLead(i); TAB(47); globalArmyExper(i); TAB(52); globalSupply(i);
		PRINT TAB(57); : IF globalArmyMove(i) > -1 THEN PRINT globalCity$(globalArmyMove(i)) ELSE PRINT "Resting"
		IF globalFort(globalArmyLoc(i)) > 0 THEN LOCATE y, 68: PRINT "FORT +"; globalFort(globalArmyLoc(i))
	deadeye:
	NEXT i
	PRINT " "; STRING$(70, "�")
	PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(INT(globalAggress! * x))); "00 ]"
	PRINT " "; STRING$(70, "�")
	PRINT " "; globalForce$(who); " NAVY has "; globalNavySize(who); " ship(s) ";
	x = 0
	FOR k = 1 TO globalNavySize(who)
		IF MID$(globalFleet$(who), k, 1) = "I" THEN x = x + 1
	NEXT k
	IF x > 0 THEN PRINT "("; x; "Ironclads) ";
	IF globalNavyLoc(who) > 0 AND globalNavyLoc(who) < 99 THEN PRINT "in "; globalCity$(globalNavyLoc(who)) ELSE PRINT
	IF globalRR(who) > 0 THEN COLOR 14: PRINT " Army #"; globalRR(who); globalArmyName$(globalRR(who)); " on train to "; globalCity$(globalArmyMove(globalRR(who)));
	LINE (0, 0)-(639, 449), 15, B
	LINE (0, 62)-(639, 62), 15
	GOTO endrep
	'..........................................................................
	'                               City Report
	'..........................................................................
	cityrep:
	CLS
	LOCATE 1, 1: COLOR 14
	PRINT "City Report"; TAB(20); globalMonth$(month); ","; globalYear: COLOR 15
	PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"
	LINE (1, 30)-(630, 30), 15
	FOR i = 1 TO 20
		COLOR 4
		a$ = "neutral"
		IF globalCityP(i) = 1 THEN COLOR 9: a$ = "UNION"
		IF globalCityP(i) = 2 THEN COLOR 7: a$ = "REBEL"
		LOCATE 2 + i, 1: PRINT i; TAB(6); globalCity$(i); TAB(18); a$; TAB(29); globalCityV(i)
	NEXT i

	FOR i = 21 TO 40
		COLOR 4
		a$ = "neutral"
		IF globalCityP(i) = 1 THEN COLOR 9: a$ = "UNION"
		IF globalCityP(i) = 2 THEN COLOR 7: a$ = "REBEL"
		LOCATE i - 18, 41: PRINT i; TAB(46); globalCity$(i); TAB(58); a$; TAB(69); globalCityV(i)
	NEXT i
	LINE (1, 360)-(630, 360), 15
	COLOR 9: LOCATE 24, 1: PRINT "Side    No. Cities   Income    Cash"
	COLOR 9: PRINT globalForce$(1); TAB(12); globalControl(1); TAB(23); globalIncome(1); TAB(32); globalCash(1)
	COLOR 7: PRINT globalForce$(2); TAB(12); globalControl(2); TAB(23); globalIncome(2); TAB(32); globalCash(2)
	COLOR 4: PRINT globalForce$(0); TAB(12); 40 - globalControl(1) - globalControl(2)
	LINE (1, 382)-(630, 382), 15
	GOTO endrep
	'..........................................................................
	'                               Intelligence
	'..........................................................................
	srep:
	c = 9
	IF globalSide = 2 THEN c = 7
	CALL usa
	CALL starfin(star, fin, globalSide)
	FOR k = star TO fin
		IF globalArmySize(k) > 0 THEN
			COLOR c
			x = globalCityX(globalArmyLoc(k))
			y = globalCityY(globalArmyLoc(k))
			z = 10
			IF globalArmySize(k) < 1000 THEN z = 9
			x = x / 8 - 2: y = y / 16
			IF y > 26 THEN y = 26
			FOR j = 0 TO 3
			LOCATE y + j, x: PRINT SPACE$(z);
			NEXT j
			LOCATE y, x: PRINT "Siz:"; : CALL strong(k)
			LOCATE y + 1, x: PRINT "Ldr:"; globalArmyLead(k)
			LOCATE y + 2, x: PRINT "Xpr:"; globalArmyExper(k)
			LOCATE y + 3, x: PRINT "Sup:"; globalSupply(k);
			LINE (8 * (x - 1) - 1, 16 * (y - 1) - 1)-(8 * (x + z - 1) + 1, 16 * (y + 3) + 1), 15, B
			TICK 1
		END IF
	NEXT k
	GOTO endrep
	'..........................................................................
	'                               Force Summary
	'..........................................................................
	frep:
	FOR k = 1 TO 40
		IF globalOccupied(k) > 0 THEN
			FOR j = 1 TO 40
				IF globalArmyLoc(j) = k THEN summ(k) = summ(k) + globalArmySize(j)
			NEXT j
		END IF
	NEXT k

	CLS
	CALL usa
	FOR k = 1 TO 40
		IF summ(k) > 0 THEN
			c = 9
			IF globalCityP(k) = 2 THEN c = 7
			COLOR c
			LOCATE INT(globalCityY(k) / 16 + 1), globalCityX(k) / 8: PRINT summ(k)
		END IF
	NEXT k
	COLOR 14: LOCATE 1, 20: PRINT "Total Forces in Cities (100's)"
	GOTO endrep
	'..........................................................................
	'                               Battle Report
	'..........................................................................
	batrep:
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
	LOCATE 14, 38: PRINT globalBatWon(1)
	LOCATE 14, 45: PRINT globalBatWon(2)
	LOCATE 17, 38: PRINT INT(.1 * globalCasualty&(1))
	LOCATE 17, 45: PRINT INT(.1 * globalCasualty&(2))
	IF globalHistory > 0 AND who > 2 THEN
		OPEN "O", #1, "battsumm"
		PRINT #1, " SIDE      BATTLES WON       LOSSES"
		FOR k = 1 TO 2
		a$ = " ": IF globalThrill = k THEN a$ = "*"
		PRINT #1, a$; globalForce$(k), globalBatWon(k), 100 * globalCasualty&(k)
		NEXT k
		CLOSE #1
	END IF
	GOTO endrep
	'..........................................................................
	'                               Recap (History)
	'..........................................................................
	recap:
	CLS
	x = 0
	OPEN "I", 2, "cws.his"
	DO WHILE NOT EOF(2)
	INPUT #2, a$
	COLOR 7: IF INSTR(a$, "[") THEN COLOR 15
	IF INSTR(a$, ">") THEN COLOR 14
	IF INSTR(a$, "..") THEN COLOR 11
	IF INSTR(a$, "!") THEN COLOR 12
	LOCATE 29, 1: PRINT a$
	x = x + 1
	IF x > 27 THEN TICK .4
	LOOP
	CLOSE #2

	endrep:
	COLOR 14: LOCATE 29, 29: PRINT "press a key";
	DO WHILE INKEY$ = "": LOOP
	IF who < 3 THEN
		CLS
		CALL usa
	END IF
END SUB

SUB resupply (index)
	who = 1
	IF index > 20 THEN who = 2
	IF globalRealism > 0 THEN
		CALL cutoff(who, globalArmyLoc(index), a)
		IF a < 1 THEN EXIT SUB
	END IF
	IF globalArmySize(index) > 0 THEN x = globalCash(who) / globalArmySize(index) * 10
	y = x + globalSupply(index)
	IF y > 5 THEN x = 5 - globalSupply(index)
	IF x < 1 THEN
		CALL clrbot
		PRINT "Not enough funds in the Treasury to globalSupply "; globalArmyName$(index);
		GOTO nocash
	END IF
	globalSupply(index) = globalSupply(index) + x
	globalCash(who) = globalCash(who) - .1 * x * globalArmySize(index)
	CALL clrbot
	PRINT globalArmyName$(index); " has received supplies ";
	IF globalNoise > 0 THEN SOUND 4500, .5
	nocash:
	CALL TICK(globalTurbo!)
	IF globalCash(who) < 0 THEN globalCash(who) = 0
END SUB

SUB retreat (defend, x)
	x = 0
	IF globalPlayer = 1 THEN
		IF (globalSide = 1 AND defend > 20) OR (globalSide = 2 AND defend < 21) THEN EXIT SUB
	END IF

	globalHilite = 13
	globalColour = 3
	globalTLX = 67
	globalTLY = 5
	globalSize = 0
	y = globalArmyLoc(defend)
	who = 1
	IF defend > 20 THEN who = 2
	FOR k = 1 TO 6
		IF globalMatrix(y, k) > 0 AND globalCityP(globalMatrix(y, k)) = who THEN 
			globalSize = globalSize + 1
			globalMTX$(globalSize) = globalCity$(globalMatrix(y, k))
			globalArray(globalSize) = globalMatrix(y, k)
		END IF
	NEXT k
	IF globalSize = 0 THEN EXIT SUB
	IF globalSize = 1 THEN x = globalArray(1): EXIT SUB
	globalMTX$(0) = "Retreat"
	CALL bubble(globalSize)
	CALL menu(9)
	CALL clrrite
	IF globalChoose < 0 OR globalChoose > globalSize THEN x = 0: EXIT SUB
	x = globalArray(globalChoose)
END SUB

SUB roman (target, a$)
	a$ = "Union "
	IF target > 20 THEN a$ = "Rebel "
	IF target > 20 THEN target = target - 20
	IF target > 10 THEN a$ = a$ + "X": target = target - 10
	SELECT CASE target
		CASE IS < 4
			x = target
			GOSUB add1s
		CASE 4
			a$ = a$ + "IV"
		CASE 5 TO 8
			a$ = a$ + "V"
			x = target - 5
			GOSUB add1s
		CASE 9
			a$ = a$ + "IX"
		CASE 10
			a$ = a$ + "X"
	END SELECT
	EXIT SUB

	add1s:
	IF x > 0 THEN 
		FOR k = 1 TO x
			a$ = a$ + "I"
		NEXT k
	END IF
	RETURN
END SUB

SUB rwin
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

	FOR i = 1 TO 6
		LINE (x + 19 * i - 12, y + 7)-(x + 19 * i - 12 + 2, y + 40), 15, BF
	NEXT i

	IF globalNoise < 2 GOTO relee
	PLAY "MBMS T120"
	PLAY "O3 L16 g e L8 c c L16 c d e f L8 g g g e a a a. L16 g a8. g a b"
	PLAY "O4 L16 c d e4. c O3 g O4 c4. O3 g e g4. d e c4 P8"
	PLAY "L16 g e L8 c c L16 c d e f L8 g g g e a a a. L16 g a8. g a b"
	PLAY "O4 L16 c d e4. c O3 g O4 c4. O3 g e g4. d e c4."
	PLAY "L16 T150 g a b T120 O4 L8 c e d. c16 O3 a O4 c4 O3 a O4 d4."
	PLAY "O3 a O4 d4. O3 T150 L16 g a b T120 L8 O4 c e d. c16"
	PLAY "L8 O3 a b O4 c. O3 a16 g e O4 c. O3 e16 e d4 e c4. e d4. a"
	PLAY "L8 g e O4 c. e16 d c4 O3 e c4. e d4. a g e O4 e4. c16 d c4"

	GOTO relee

	stars:
	FOR i = 1 TO 8
		x = globalStarX(i): y = globalStarY(i)
		PSET (x, y), 0
		LINE (x + 2, y - 1)-(x + 8, y + 16), 15
		LINE -(x - 6, y + 2): LINE -(x - 20, y + 16)
		LINE -(x - 14, y - 1): LINE -(x - 30, y - 9)
		LINE -(x - 12, y - 9): LINE -(x - 6, y - 25)
		LINE -(x, y - 9): LINE -(x + 16, y - 9)
		LINE -(x + 2, y - 1): PAINT (x, y), 15
	NEXT i
	RETURN
relee:
END SUB

SUB scribe (a$, flag)
	SELECT CASE flag
			CASE 1: CALL clrbot: PRINT a$;
			CASE 2: CALL image2(a$, 4)
	END SELECT
	IF globalHistory > 0 THEN
		OPEN "A", 2, "cws.his"
		a$ = LTRIM$(RTRIM$(a$))
		PRINT #2, a$
		CLOSE #2
	END IF
END SUB

SUB shen '                       Shenandoah
	IF globalNoise = 2 THEN
		IF INKEY$ <> "" THEN globalChoose = 1: EXIT SUB
		PLAY "T90MFMNo1c4f8f8f4."
		IF INKEY$ <> "" THEN globalChoose = 1: EXIT SUB
		PLAY "g8a8b-8o2d8c4."
		IF INKEY$ <> "" THEN globalChoose = 1: EXIT SUB
		PLAY "MLf8e8MNd4.c8d8c8o1a8o2c4.c4d8d8d4."
		IF INKEY$ <> "" THEN globalChoose = 1: EXIT SUB
		PLAY "o1a8o2c8o1a8g8f4.g4a4.f8"
		IF INKEY$ <> "" THEN globalChoose = 1: EXIT SUB
		PLAY "a8o2d8c4.o1f8g8a4.f8g4f2."
	END IF
END SUB

SUB shipicon (who, flag)
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
		IF globalNavySize(s) = 0 OR globalNavyLoc(s) = 0 THEN globalNavyLoc(s) = 0: GOTO sink
		IF globalNavyLoc(s) = 30 THEN x = 515: y = 268: GOTO float
		IF globalNavyLoc(s) = 28 THEN x = 517: y = 172: GOTO float
		IF globalNavyLoc(s) = 17 THEN x = 380: y = 425: GOTO float
		IF globalNavyLoc(s) = 99 THEN x = 495: y = 310: GOTO float
		x = globalCityX(globalNavyLoc(s)) + 25: y = globalCityY(globalNavyLoc(s)) + 25
		IF globalNavyLoc(s) = 24 THEN y = y + 5: x = x - 5
		float:
			PSET (x, y), 1
			a = 1: IF LEFT$(globalFleet$(s), 1) = "I" THEN a = 2
			CALL shipicon(s, a)
		sink:
	NEXT s
END SUB

SUB starfin (star, fin, who)
	star = 1
	fin = 20
	IF who = 2 THEN 
		star = 21
		fin = 40
	END IF
END SUB

SUB stax (who)
	CALL starfin(star, fin, who)
	FOR i = star TO fin
		IF globalArmySize(i) > 0 AND globalOccupied(globalArmyLoc(i)) <> i THEN
			target = globalArmyLoc(i)
			x = globalCityX(target) - 12: y = globalCityY(target) - 12
			CIRCLE (x, y), 3, 14
		END IF
	NEXT i
END SUB

SUB surrender (who)
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

	CALL flags(3 - s, 26, 0)
	IF who < 99 THEN CALL TICK(globalTurbo!)
END SUB

SUB TICK (sec!)
	start! = TIMER
	DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP
END SUB

SUB topbar
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR 11
	LOCATE 1, 10: PRINT "Input your decisions now for "; globalForce$(globalSide); " globalSide "; : COLOR 14: PRINT globalMonth$(month); ","; globalYear; "  "

	CALL flags((globalSide), 0, 0)
	COLOR 4
	IF globalBW > 0 THEN COLOR 7
	LOCATE 6, 68: PRINT "Difficulty "; LTRIM$(RTRIM$(STR$(globalDifficult)))
	LOCATE 7, 68: PRINT "Funds:"; globalCash(globalSide);

	FOR i = 1 TO 2
		IF globalVictory(i) < 0 THEN globalVictory(i) = 0
	NEXT i
	x = globalVictory(1) + globalVictory(2): y = 0
	c = 9
	IF globalSide = 2 THEN c = 7
	LINE (580, 15)-(580, 35), 15
	LINE (530, 20)-(630, 30), 8 - c, BF
	IF x > 0 THEN y = 100 * (globalVictory(globalSide) / x)

	LINE (530, 20)-(530 + y, 30), c, BF
	COLOR c: LOCATE 4, 68: PRINT "VP :"; globalVictory(globalSide)

	LOCATE 5, 68: PRINT "("; y; "%)"

	a$ = "  Snd"
	IF globalNoise < 2 THEN 
		a$ = "   Snd"
		IF globalNoise = 0 THEN a$ = "      "
	END IF
	IF globalGraf > 0 THEN a$ = a$ + " G" + LTRIM$(STR$(globalGraf))
	a$ = a$ + STR$(globalPlayer)
	COLOR 15: LOCATE 1, 68: PRINT "F1 =  H E L P";
	COLOR c
	LOCATE 26, 68: PRINT "F3 Redrw Scrn"
	LOCATE 27, 68: PRINT "F7 End Turn"
	LOCATE 28, 68: PRINT a$
END SUB

SUB touchup
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

SUB traincapacity (who, limit)
	IF globalRealism = 0 THEN limit = globalTrain(who): EXIT SUB
	x = 11
	IF globalSide = 2 THEN x = 23
	limit = globalTrain(who) + 5 * (globalControl(who) - x)
	x = 2 * globalTrain(who)
	IF limit > x THEN limit = x
	IF limit < x \ 4 THEN limit = x \ 4
END SUB

SUB usa
	SCREEN 12
	LINE (1, 16)-(527, 440), 10, B
	PAINT (200, 200), 2, 10
	COLOR 10
	'==========================  Mountains =================================
	IF _FILEEXISTS("mtn.vga") THEN
		PUT (380, 30), globalMtn, PSET
		PUT (270, 200), globalMtn, PSET
		PUT (310, 160), globalMtn, PSET
		PUT (350, 120), globalMtn, PSET
		PUT (200, 185), globalMtn, PSET
		PUT (250, 130), globalMtn, PSET
		PUT (320, 80), globalMtn, PSET
		PUT (30, 150), globalMtn, PSET
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
	CALL chessie
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

	CALL showcity
	PSET (493, 280), 1
	IF globalNavyLoc(1) = 30 OR globalNavyLoc(2) = 30 THEN
		DRAW "C11U7R4D3L3BR6BU3D7BU4R3U3D7BR3U7BD4BR4BU4D7R4"
		LINE (485, 241)-(525, 270), 11, B
	END IF

	IF globalGraf > 1 THEN CALL maptext
	IF globalCommerce > 0 THEN
		LINE (447, 291)-(525, 317), 4, BF: LINE (447, 291)-(525, 317), 10, B
		y = 312
		a$ = "COMMERCE"
		FOR j = 1 TO LEN(a$)
			x = ASC(MID$(UCASE$(a$), j, 1)) - 64
			PSET (440 + 10 * j, y), 0: DRAW globalFont$(x)
		NEXT j
	ELSE
		LINE (447, 291)-(525, 335), 1, BF
	END IF

	FOR i = 1 TO 40
		IF globalArmyLoc(i) > 0 THEN CALL placearmy(i)
	NEXT i

	FOR k = 1 TO 2
		CALL stax(k)
	NEXT k

	IF globalPlayer = 2 GOTO nosee
	FOR i = 1 TO 40
		IF globalArmyLoc(i) > 0 AND globalArmyMove(i) > 0 THEN CALL icon(globalArmyLoc(i), globalArmyMove(i), 1)
	NEXT i
	nosee:
	CALL ships
	CALL engine
	COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(globalMonth$(month), 3)); ","; globalYear
END SUB

SUB victor
	x = 0
	FOR j = 1 TO 20
		IF globalArmyLoc(j) > 0 THEN x = x + globalArmySize(j)
	NEXT j
	y = 0
	FOR j = 21 TO 40
		IF globalArmyLoc(j) > 0 THEN y = y + globalArmySize(j)
	NEXT j

	CALL clrbot
	COLOR 14
	IF globalVicFlag(2) > 0 AND globalYear >= globalVicFlag(2) AND month < globalVicFlag(1) THEN
		a$ = "Time almost expired (" + globalMonth$(globalVicFlag(1)) + "," + STR$(globalVicFlag(2)) + ")"
		CALL image2(a$, 4)
	END IF
    FOR i = 1 TO 2
		IF (i = 1 AND y = 0) OR (i = 2 AND x = 0) THEN 
			j = 7
			globalVictory(i) = globalVictory(i) + 300
			GOTO finis
		END IF

		IF globalYear >= globalVicFlag(2) AND month >= globalVicFlag(1) AND globalVicFlag(2) > 0 THEN 
			j = 2
			GOTO finis
		END IF
		IF globalControl(i) >= globalVicFlag(3) AND globalVicFlag(3) > 0 THEN 
			j = 3
			GOTO finis
		END IF
		IF globalIncome(i) / (globalIncome(1) + globalIncome(2)) >= .01 * globalVicFlag(4) AND globalVicFlag(4) > 0 THEN 
			j = 4
			GOTO finis
		END IF
		IF globalVicFlag(5) > 0 AND globalCapCity(3 - i) = 0 AND globalCapCity(i) > 0 THEN 
			j = 5
			GOTO finis
		END IF

		IF globalVicFlag(6) > 0 THEN
			IF i = 1 THEN
				IF y = 0 THEN j = 7: GOTO finis
				IF x / y > globalVicFlag(6) THEN j = 6: GOTO finis
			END IF
			IF i = 2 THEN
				IF x = 0 THEN j = 7: GOTO finis
				IF y / x > globalVicFlag(6) THEN j = 6: GOTO finis
			END IF
		END IF

		CALL clrbot
		COLOR 14
		IF globalVicFlag(3) > 0 AND globalControl(i) >= .9 * globalVicFlag(3) THEN
			a$ = globalForce$(i) + " side almost controls" + STR$(globalVicFlag(3)) + " cities"
			CALL image2(a$, 4)
		END IF

		IF globalVicFlag(4) > 0 AND globalIncome(i) / (globalIncome(1) + globalIncome(2)) >= .009 * globalVicFlag(4) THEN
			a$ = globalForce$(i) + " side close to" + STR$(globalVicFlag(4)) + " % of total income"
			CALL image2(a$, 4)
		END IF

		IF globalVicFlag(6) > 0 AND x > 0 AND y > 0 THEN
			IF (i = 1 AND x / y > .9 * globalVicFlag(6)) OR (i = 2 AND y / x > .9 * globalVicFlag(6)) THEN
			a$ = globalForce$(i) + "side close to" + STR$(globalVicFlag(6)) + ":1 strength ratio"
			CALL image2(a$, 4)
			END IF
		END IF
		GOTO stale

		finis:
		SELECT CASE j
			CASE IS < 3
			a$ = "TIME EXPIRED"
			CASE 3
			a$ = STR$(2.5 * globalVicFlag(3)) + "% CITIES CONTROLLED"
			CASE 4
			a$ = STR$(globalVicFlag(4)) + " % OF TOTAL INCOME"
			CASE 5
			a$ = "CAPITAL CAPTURED"
			CASE 6
			a$ = STR$(globalVicFlag(6)) + ":1 ARMY STRENGTH RATIO"
			CASE 7
			a$ = "ENEMY ANNIHILATED"
		END SELECT
		CLS
		c = 1
		IF i = 2 THEN c = 7
		LINE (0, 0)-(639, 479), 4, BF
		LINE (0, 40)-(550, 460), 0, BF
		CALL usa
		LINE (70, 140)-(485, 265), 0, BF
		LINE (50, 120)-(465, 250), c, BF
		LINE (50, 120)-(465, 250), 4, B
		COLOR 14
		t$ = globalForce$(i) + " SIDE IS WINNING"
		IF j = 2 THEN 
			CALL center(10, "Confederates will win a technical victory")
		ELSE 
			CALL center(10, t$)
		END IF

		COLOR 15
		t$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"
		CALL center(12, t$)
		CALL center(14, a$)

		globalMTX$(0) = "End Game"
		globalMTX$(1) = "Yes"
		globalMTX$(2) = "No-Override"
		globalSize = 2: globalColour = 4
		globalTLX = 27: globalTLY = 18
		globalHilite = 15
		IF j = 7 THEN globalSize = 1
		CALL menu(0)

		IF globalChoose <> 1 AND j < 7 THEN
			play4ever:
			globalVicFlag(j) = globalVicFlag(j) + 1
			IF j = 5 THEN globalVicFlag(j) = 0
			CLS
			CALL usa
			EXIT SUB
		END IF
		globalMTX$(0) = "Options"
		globalMTX$(1) = "Quit this Game"
		globalMTX$(2) = "Play More"
		IF globalPlayer = 1 THEN globalMTX$(2) = "No - Press Onward to " + globalCity$(globalCapCity(3 - globalSide))
		globalSize = 2
		globalColour = 8
		globalTLX = 27
		globalTLY = 18
		IF j <> 7 THEN
			CALL menu(0)
			IF globalChoose <> 1 GOTO play4ever
		ELSE
			globalVictory(i) = globalVictory(i) + 100
		END IF

		globalThrill = i
		CALL usa
		CALL report(100 + globalSide)
		IF j = 2 THEN 
			FOR k = 1 TO 2
				globalVictory(k) = .7 * globalVictory(k)
			NEXT k
			CALL rwin
			GOTO death
		END IF

		IF i = 1 THEN 
			CALL capitol
			COLOR 15: LOCATE 2, 27: t$ = "UNION VICTORY  VP's=" + STR$(globalVictory(1)): PRINT t$
			GOTO death
		END IF
		IF i = 2 THEN 
			CALL rwin
			COLOR 15: LOCATE 2, 27: t$ = "REBEL VICTORY  VP's=" + STR$(globalVictory(2)): PRINT t$
		END IF
		death:
		COLOR 14: LOCATE 4, 40 - .5 * LEN(a$)
		IF globalHistory > 0 THEN
			CALL scribe(t$, 0)
			CALL scribe(a$, 0)
		END IF
		PRINT a$: CALL maxx
		EXIT SUB
	stale:
	NEXT i
END SUB

SUB void (a, y)
	y = 0
	FOR j = 1 TO 6
		x = globalMatrix(a, j)
		IF x = 0 GOTO tally5
		IF globalCityP(x) = globalSide AND globalOccupied(x) > 0 THEN y = y + globalArmySize(globalOccupied(x))
		FOR k = 1 TO 6
			m = globalMatrix(x, k)
			IF m = 0 OR m = a GOTO tally4
			IF globalCityP(m) = globalSide AND globalOccupied(m) > 0 THEN y = y + .1 * globalArmySize(globalOccupied(m))
		tally4:
		NEXT k
	NEXT j
tally5:
END SUB

' CWSMENU.BAS
'============================================================================
'                GENmenu 3.05 : Generic Menu Main Module Level  12/91
'                Updated to Use Graphic Screens 8, 9, 12
'============================================================================
'       globalTLX  = top left x  (if zero, automatically centered)
'       globalTLY = top left y   (if zero, automatically centered)
'       globalSize = # rows (current maximum=20)
'       globalMTX$() = text for menu
'                globalMTX$(0) = heading (blank defaults to M E N U)
'                globalMTX$(1-globalSize) are options
'       globalChoose = option selected (row #)
'            -1 indicates ESC key pressed
'            entering with globalChoose+21 causes globalChoose to be default entry
'       globalWType = window type (0 = no line; 1=single line;
'                            2=double line
'               if >10 then 10's digit=box color  1's digit= window type

SUB choices (b1, wide)
	boxc = globalColour
	IF globalWType > 10 THEN 
		boxc = INT(globalWType / 10)
		globalWType = globalWType - 10 * boxc
	END IF
	COLOR boxc
	VIEW (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + globalSize + 2) + 8)
	CLS 1
	VIEW
	LINE (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + globalSize + 2) + 8), globalColour, B
	LINE (8 * globalTLX - 2, 16 * (globalTLY + 1) + 3)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + 1) + 6), globalColour, B
	IF ABS(globalWType) = 2 THEN
		LINE (8 * globalTLX - 2, 16 * globalTLY - 8)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + globalSize + 2) + 4), globalColour, B
	END IF
	COLOR globalColour

	LOCATE globalTLY + 1, globalTLX + b1: PRINT globalMTX$(0)
	FOR i = 1 TO globalSize
		LOCATE globalTLY + 2 + i, globalTLX + 2: PRINT globalMTX$(i);
	NEXT i
END SUB

SUB ironclad
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

SUB menu (switch%)
	remenu:
	IF globalColour = 0 THEN globalColour = 7
	LOCATE 1, 1, 0
	IF globalMTX$(0) = "" THEN globalMTX$(0) = "M E N U"

	IF wide = 0 THEN CALL mxw(wide)
	IF globalTLX = 0 THEN GOSUB noadjust
	IF globalChoose < 21 THEN globalChoose = 1
	IF globalChoose > 21 THEN globalChoose = globalChoose - 21
	IF globalChoose > 21 THEN globalChoose = 1
	row = globalChoose: IF row < 1 THEN row = 1
	IF row > globalSize THEN row = 1
	globalChoose = row
	row1 = row
       
	IF globalTLY = 0 THEN globalTLY = INT(11.5 - .5 * globalSize)
	IF globalTLY + globalSize > 26 THEN globalTLY = 26 - globalSize
       
	brx = globalTLX + wide + 1
	bry = globalTLY + globalSize + 3
       
	boxc = globalColour
	IF globalWType > 10 THEN 
		boxc = INT(globalWType / 10)
		globalWType = globalWType - 10 * boxc
	END IF

	COLOR boxc

	VIEW (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + globalSize + 2) + 8)
	CLS 1
	VIEW
	LINE (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + globalSize + 2) + 8), globalColour, B
	LINE (8 * globalTLX - 2, 16 * (globalTLY + 1) + 3)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + 1) + 6), globalColour, B
	IF ABS(globalWType) = 2 THEN
		LINE (8 * globalTLX - 2, 16 * globalTLY - 8)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + globalSize + 2) + 4), globalColour, B
	END IF

	COLOR globalColour
	b1 = INT(.5 * (wide - LEN(globalMTX$(0))) + .5) + 1

	CALL choices(b1, wide)
	sel1:
	SELECT CASE switch
		CASE 1:
			CALL icon(globalArray(row), 0, 7)
		CASE 2: 
			CALL icon(globalArray(row), 0, 9)
			target = globalOccupied(globalArray(row))
			IF target > 0 THEN
				flag = 1
				t$ = globalArmyName$(target)
				IF LEN(t$) > wide THEN t$ = LEFT$(t$, wide)
				COLOR 12
				LOCATE globalTLY + 2 + row, globalTLX + 2: PRINT SPACE$(wide);
				LOCATE globalTLY + 2 + row, globalTLX + 2: PRINT t$;
				LOCATE globalTLY + 4 + globalSize, globalTLX + 1: PRINT SPACE$(12);
				LOCATE globalTLY + 4 + globalSize, globalTLX + 1: PRINT "Size"; globalArmySize(target);
				x = POS(0): y = CSRLIN: LOCATE y, x - 1: PRINT "00";
			ELSE
				flag = 0
				LOCATE globalTLY + 4 + globalSize, globalTLX + 1: PRINT SPACE$(12);
			END IF
		CASE 4:
			CALL armystat(globalArray(row))
		CASE 5:
			COLOR 11
			CALL clrbot
			PRINT globalArmyName$(index); "  Exp="; globalArmyExper(index); " Cash="; globalCash(globalSide);
		CASE 6:
			CALL icon(globalArmyLoc(globalArray(row)), 0, 9)
		CASE 8
			IF globalGraf > 2 AND row > 0 THEN
				LINE (548, 148)-(592, 216), 15, B
				a = row
				IF globalSide = 1 THEN a = 6 - row
				t$ = "face" + LTRIM$(STR$(a)) + ".vga"
				IF _FILEEXISTS(t$) THEN
					DEF SEG = VARSEG(graft(1))
					BLOAD t$, VARPTR(graft(1))
					DEF SEG
					PUT (550, 150), graft, PSET
					IF globalSide = 2 THEN
						PAINT (560, 160), 8, 0
						PAINT (570, 155), 7, 0
					END IF
				END IF
			END IF
		CASE 9
			CALL icon(globalArray(row), 0, 9)
	END SELECT
	IF flag = 0 THEN
		COLOR globalHilite
		LOCATE globalTLY + 2 + row, globalTLX + 2
		PRINT globalMTX$(row)
		IF globalBW > 0 THEN 
			LINE (8 * (globalTLX + 1), 16 * (globalTLY + row + 1))-(8 * (globalTLX + LEN(globalMTX$(row)) + 1) - 1, 16 * (globalTLY + row + 2) - 1), globalHilite, B
		END IF
	END IF
	GOSUB crsr
	IF switch <> 3 GOTO reglr
	IF a$ = "H" THEN globalChoose = 1: GOTO called
	IF ASC(a$) = 13 THEN globalChoose = 2: GOTO called
	IF a$ = "P" THEN globalChoose = 3: GOTO called
	reglr:
	IF ASC(a$) = 13 GOTO called
	IF switch = 2 THEN LOCATE globalTLY + 2 + row1, globalTLX + 2: PRINT SPACE$(wide);
	COLOR globalColour
	LOCATE globalTLY + 2 + row1, globalTLX + 2: PRINT globalMTX$(row1)

	SELECT CASE switch
		CASE 1, 2, 9
			IF globalMTX$(row1) <> "EXIT" THEN CALL icon(globalArray(row1), 0, 8)
		CASE 6
			IF globalMTX$(row1) <> "EXIT" THEN CALL icon(globalArmyLoc(globalArray(row1)), 0, 8)
	END SELECT

	globalChoose = row
	GOTO sel1
	crsr:
	a$ = INKEY$
	IF a$ = "" GOTO crsr
	IF ASC(a$) = 13 THEN RETURN
	IF LEN(a$) = 2 GOTO arrows
	IF switch = 3 THEN globalChoose = -ASC(UCASE$(a$)): GOTO called
	IF ASC(a$) = 27 THEN globalChoose = -1: GOTO called
	row1 = row
	FOR k = 1 TO globalSize
		c1$ = UCASE$(LEFT$(LTRIM$(globalMTX$(k)), 1))
		IF c1$ = UCASE$(a$) THEN
			globalChoose = k
			GOSUB limits
			GOTO called
		END IF
	NEXT k
	GOTO crsr
	arrows:
	a$ = RIGHT$(a$, 1)
	row1 = row
	 IF a$ = "H" THEN row = row - 1: GOSUB limits: RETURN
	 IF a$ = "I" THEN row = 1: GOSUB limits: RETURN
	 IF a$ = "P" THEN row = row + 1: GOSUB limits: RETURN
	 IF a$ = "Q" THEN row = globalSize: GOSUB limits: RETURN
	 IF a$ = "=" AND switch = 0 THEN
		CLS
		CALL usa
		CALL choices(b1, wide)
		CALL topbar
		RETURN
	 END IF
	 IF a$ = "A" AND switch = 0 THEN
		globalChoose = 99
		GOTO called
		RETURN
	 END IF
	 IF a$ = ">" AND switch = 0 THEN
		CALL report(-1)
		CALL choices(b1, wide)
		CALL topbar
		RETURN
	 END IF
	 RETURN

	limits:
	IF row > globalSize THEN row = 1
	IF row < 1 THEN row = globalSize
	RETURN
	noadjust:
	IF globalTLX = 0 THEN globalTLX = INT(40.5 - .5 * wide)
	RETURN
	boss1:
	CLS
	CALL usa
	GOTO remenu
	called:
	IF globalNoise > 0 THEN SOUND 700, .5
	COLOR globalColour
	globalTLX = 0: globalTLY = 0
	SELECT CASE switch
	CASE 1, 2, 9
		CALL icon(globalArray(row), 0, 8)
	CASE 6
		CALL icon(globalArmyLoc(globalArray(row)), 0, 8)
	END SELECT
	VIEW
END SUB

SUB mxw (wide)
	wide = LEN(globalMTX$(0)) + 1
	FOR i = 1 TO globalSize
		x = LEN(globalMTX$(i))
		IF x > wide THEN wide = x
	NEXT i
END SUB

SUB schooner
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

