DEFINT A-Z
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB barnacle (who%)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB integrity ()
DECLARE SUB ironclad ()
DECLARE SUB normal (xbar%, vary%, result%)
DECLARE SUB relieve (who%)
DECLARE SUB retreat (active%, x%)
DECLARE SUB schooner ()
DECLARE SUB shiptype (who%, i%)
DECLARE SUB stax (who%)
DECLARE SUB tinytrain (who%, flag%)
DECLARE SUB traincapacity (who%, limit%)
DECLARE SUB topbar ()
' $INCLUDE: 'cws14.bi'

replay = 0
newgame:
pcode = 0: rflag = 0
FOR k = 1 TO 40: armysize(k) = 0: armyloc(k) = 0: armymove(k) = 0: armylead(k) = 0: armyname$(k) = "": NEXT k
usadv = 0: emancipate = 0
FOR k = 1 TO 2
navysize(k) = 0: navyloc(k) = 0: navymove(k) = 0
rr(k) = 0: victory(k) = 0: tracks(k) = 0
NEXT k

filel = 1: vicflag(1) = 1
CALL filer(1)
IF LEN(DIR$(GFXDIR + "mtn.vga")) > 0 THEN
	DEF SEG = VARSEG(mtn(1))
	BLOAD GFXDIR + "mtn.vga", VARPTR(mtn(1))
	DEF SEG
ELSE
	COLOR 15: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'": TICK 9
END IF

RESTORE
FOR k = 1 TO 26: READ font$(k): NEXT k

IF realism > 0 AND year < 1862 THEN
		FOR i = 1 TO 2
			a$ = STRING$(LEN(fleet$(i)), "W")
			fleet$(i) = a$
		NEXT i
END IF
IF player < 1 OR player > 2 THEN player = 1
IF player = 2 OR side = 0 THEN side = 1
IF side = 1 THEN randbal = 7
IF side = 2 THEN randbal = 3
	IF turbo! < 1 THEN turbo! = 2
	IF side = 1 AND difficult < 3 THEN cash(2) = cash(2) + 600 - 100 * difficult
	IF side = 2 AND difficult > 3 THEN cash(1) = cash(1) + 100 * difficult


FOR i = 1 TO 2: income(i) = cash(i): cash(i) = cash(i) + 50 * RND: NEXT i
choose = 0

SCREEN 12
	DEF SEG = VARSEG(graphic(1))
	BLOAD GFXDIR + "cwsicon.vga", VARPTR(graphic(1))
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
IF replay = 0 AND noise = 2 AND choose = 0 THEN
IF side = 1 THEN
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

city$(0) = "NONE"
OPEN "I", 1, SCNDIR + "cities.grd"
vptotal = usadv + 200
FOR i = 1 TO 40: INPUT #1, a, cityx(i), cityy(i), city$(i), cityp(i), cityv(i)
cityo(i) = cityp(i)
CALL occupy(i)
FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j: INPUT #1, fort(i)
IF cityp(i) > 0 THEN x = cityp(i): control(x) = control(x) + 1: victory(x) = victory(x) + cityv(i)
IF cityp(i) > 0 THEN cash(cityp(i)) = cash(cityp(i)) + cityv(i)
vptotal = vptotal + cityv(i)
NEXT i
CLOSE #1: CALL clrbot

CALL scriptstart
TICK .3
wtype = 2
hilite = 15
replay = 1
IF player = 2 THEN GOSUB blanken
mtx$(0) = "VGA CIVILWAR STRATEGY"
mtx$(1) = "Resume Saved Game"
mtx$(2) = "Start NEW Game"
mtx$(3) = "Quit to DOS"
tlx = 33: tly = 20: colour = 5: size = 3
choose = 23
CALL menu(0)
IF choose = 1 THEN
	CLS
	GOTO loader
END IF
IF choose = 3 THEN CLS : END
IF history = 1 THEN
	CLS
	IF LEN(DIR$("cws.his")) > 0 THEN CALL scriptshell("copy cws.his oldhist.ory")
	OPEN "O", 2, "cws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; scriptdate$; " ]"
	CLOSE #2
ELSE
	SCREEN 12: CLS
END IF
CALL usa
GOTO menu0
'==========================================================================
'                              New Month
'==========================================================================
newmonth:
IF side > 2 THEN side = 1
a$ = "--------> EVENTS FOR " + month$(month) + " " + STR$(year) + " --------"
CALL scribe(a$, 0)
CALL tupdate
control(1) = 0: control(2) = 0

FOR i = 1 TO 2
income(i) = 0
IF cash(i) > 19999 THEN cash(i) = 19999
IF cash(i) < 0 THEN cash(i) = 0
NEXT i
IF player = 1 AND side = 2 THEN income(1) = income(1) + usadv

FOR i = 1 TO 40
IF cityp(i) > 0 THEN x = cityp(i): control(x) = control(x) + 1: income(x) = income(x) + cityv(i)
armymove(i) = 0
NEXT i

FOR i = 1 TO 2: navymove(i) = 0: IF capcity(i) > 0 THEN income(i) = income(i) + 100
cash(i) = cash(i) + income(i)
IF commerce > 0 AND i <> commerce THEN cash(i) = cash(i) - raider
NEXT i
vptotal = income(1) + income(2)

chosit = 22
IF player = 2 THEN GOSUB blanken: CALL usa
CALL victor
ON ERROR GOTO 0
IF pcode > 0 THEN
	FOR k = 1 TO 40: armyloc(k) = 0: NEXT k
	GOTO newgame
END IF

'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
'                              Main Menu
'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
menu0:
CALL topbar
IF player = 2 AND side = 0 THEN side = 1
IF cash(side) < 100 AND navyloc(side) = 0 THEN nflag = 1

hilite = 11
colour = 4
tlx = 67: tly = 13
mtx$(0) = "Main"
mtx$(1) = "Troops": IF rflag < 0 OR cash(side) < 100 THEN mtx$(1) = "-": chosit = 23
mtx$(2) = "Moves": IF mflag > 0 THEN mtx$(2) = "-": IF chosit = 23 THEN chosit = 24
mtx$(3) = "Ships": IF nflag > 0 THEN mtx$(3) = "-": IF chosit = 24 THEN chosit = 25
mtx$(4) = "Railroad": IF rr(side) > 0 THEN mtx$(4) = "-": IF chosit = 25 THEN chosit = 26
mtx$(5) = "END TURN"
mtx$(6) = "Inform"
mtx$(7) = "COMMANDS"
mtx$(8) = "UTILITY"
mtx$(9) = "Files"

size = 9
choose = chosit
CALL menu(0): CALL clrrite
'==========================================================================
'                            Main Menu
'==========================================================================
SELECT CASE choose
	CASE 1
	IF cash(side) < 100 OR rflag < 0 THEN rflag = -1: GOTO menu0
	CALL recruit((side))
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 2
	CALL armies
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 3
	IF nflag = 0 THEN CALL navy((side), 0)
	chosit = 25
	CASE 4
IF rr(side) = 0 THEN
	COLOR 15: LOCATE 4, 68: PRINT "RAILROAD MOVE"
	PSET (550, 20), 0
	DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U9L2U5R1BF4"
	z = 9: IF side = 2 THEN z = 7
	x = POINT(0): y = POINT(1)
	PAINT (x, y), z, 15
	COLOR 15: IF side = 1 THEN COLOR 11
	CALL traincapacity(side, limit)
	CALL clrbot: PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
	CALL railroad(side)
ELSE
	CALL clrbot: COLOR 11: PRINT "Railroad is already carrying "; armyname$(rr(side)); " to "; city$(armymove(rr(side))); : GOTO menu0
END IF
'==========================================================================
	CASE 5
	tlx = 67: tly = 15
	hilite = 15: colour = 3: choose = 23
	mtx$(0) = "End Turn"
	mtx$(1) = "Yes"
	mtx$(2) = "NOT YET"
	size = 2: CALL menu(0): CALL clrrite: IF choose <> 1 THEN chosit = 24: GOTO menu0
endrnd:
	rflag = 0: mflag = 0: nflag = 0
	IF player = 2 THEN side = side + 1: IF side = 2 THEN GOSUB blanken: CALL usa: GOTO menu0
	GOTO newmonth
'==========================================================================
	CASE 6
	CALL report((side)): chosit = 27
	CALL starfin(star, fin, side)
	FOR i = star TO fin
	IF armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
	NEXT i
'==========================================================================
'                            Commands
'==========================================================================
	CASE 7
optmen:
	tlx = 67: tly = 13
	COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
	hilite = 15: colour = 3: chosit = 24
	mtx$(0) = "Commands"
	mtx$(1) = "Cancel"
	mtx$(2) = "Fortify": IF cash(side) < 200 THEN mtx$(2) = "-"
	mtx$(3) = "Join"
	mtx$(4) = "Supply"
	mtx$(5) = "Capital": IF capcity(side) = 0 OR cash(side) < 500 THEN mtx$(5) = "-"
	mtx$(6) = "Detach": IF side = 1 THEN mtx$(6) = "-"
	mtx$(7) = "Army Drill"
	mtx$(8) = "Relieve"
	mtx$(9) = "MAIN MENU"
	size = 9
	CALL menu(0): CALL clrrite
	chosit = 28
     SELECT CASE choose
'---------------------------------------------------------------------------
'                               Cancel
'---------------------------------------------------------------------------
		CASE 1
	CALL cancel(side): mflag = 0
	choose = 22
'---------------------------------------------------------------------------
'                               Fortify
'---------------------------------------------------------------------------
		CASE 2
	IF cash(side) < 200 THEN COLOR 11: CALL clrbot: PRINT "Not enough money for fort"; : GOTO menu0
	CALL fortify(target)
	IF cash(side) < 200 GOTO menu0
	choose = 23
	GOTO optmen
'---------------------------------------------------------------------------
'                               Combine
'---------------------------------------------------------------------------
		CASE 3
	x = side
	CALL combine(x)
	IF x < 0 THEN
		CALL clrbot
		COLOR 11
		PRINT "No eligible armies in same city to combine";
		CALL stax(side)
		GOTO menu0
	END IF
	choose = 24
	GOTO optmen
'---------------------------------------------------------------------------
'                               Supply
'---------------------------------------------------------------------------
		CASE 4
		CALL starfin(star, fin, (side))
		mtx$(0) = "Supply"
		tlx = 67: tly = 5: colour = 5
		size = 0
		FOR i = star TO fin
		IF armyloc(i) = 0 OR supply(i) > 1 GOTO alone
		IF realism > 0 THEN
			CALL cutoff(side, armyloc(i), a)
			IF a < 1 THEN CALL clrbot: COLOR 15: PRINT force$(side); " army in "; city$(armyloc(i)); " is CUT OFF !"; : TICK turbo!: GOTO alone
		END IF
		size = size + 1
		max = 11: IF LEN(armyname$(i)) < 11 THEN max = LEN(armyname$(i))
		mtx$(size) = LEFT$(armyname$(i), max)
		array(size) = i
alone:
		NEXT i
		IF size = 0 THEN COLOR 11: CALL clrbot: PRINT "All eligible "; force$(side); " armies have supplies"; : GOTO menu0
		CALL menu(6): CALL clrrite
		IF choose < 0 GOTO menu0
		index = array(choose)
		IF supply(index) < 2 THEN
		CALL resupply(index)
		CALL placearmy(index)
		END IF
		choose = 25
		GOTO optmen
'-------------------------------------------------------------------------
'                               Move Capital
'-------------------------------------------------------------------------
		CASE 5
	IF capcity(side) = 0 OR cash(side) < 500 THEN CALL clrbot: COLOR 11: PRINT "Cannot move capital"; : GOTO menu0
	cash(side) = cash(side) - 500
	victory(3 - side) = victory(3 - side) + 50
	CALL clrrite
	mtx$(0) = "Capital"
	a$ = city$(capcity(side))
	index = capcity(side): CALL newcity(index)
	IF index = 0 GOTO menu0
	capcity(side) = index
	CALL clrbot: PRINT force$(side); " capital moved from "; a$; " to "; city$(capcity(side));
	CALL clrrite
	CALL showcity
	CALL TICK(9): CALL clrbot
'-------------------------------------------------------------------------
'                               Detach
'-------------------------------------------------------------------------
		CASE 6
	IF side = 1 THEN CALL clrbot: COLOR 11: PRINT "Option not available to Union"; : GOTO menu0
	COLOR 14: LOCATE 4, 68: PRINT "DETACH UNIT"
	CALL movefrom(index, target): IF target < 1 OR index < 1 GOTO menu0
	IF armysize(index) < 65 THEN CALL clrbot: PRINT "Too small to detach"; : CALL TICK(turbo!): GOTO menu0
	CALL commander(2, empty): IF empty = 0 GOTO menu0
	supply(empty) = .3 * supply(index): supply(index) = supply(index) - supply(empty): IF supply(index) < 0 THEN supply(index) = 0
	armysize(empty) = .3 * armysize(index): armysize(index) = armysize(index) - armysize(empty)
	armyloc(empty) = target: armyexper(empty) = armyexper(index): armymove(empty) = 0
	armylead(empty) = rating(empty)
	armyname$(empty) = lname$(empty): lname$(empty) = ""
	armyexper(empty) = armyexper(index)
	COLOR 11: CALL clrbot: PRINT "Unit #"; empty; " with "; : CALL strong(empty): PRINT " men detached under "; armyname$(empty); : CALL TICK(turbo!): IF noise > 0 THEN SOUND 2222, 1
	CALL stax(side)
	choose = 27
	GOTO optmen
'-------------------------------------------------------------------------
'                               Drill
'-------------------------------------------------------------------------
		CASE 7
	COLOR 14: LOCATE 4, 68: PRINT "DRILL ARMY"
	CALL movefrom(index, target)
	IF target < 1 OR index < 1 THEN COLOR 11: CALL clrbot: PRINT "No armies remain eligible for drills in "; month$(month); : GOTO menu0
	IF armyexper(index) > 5 OR armyexper(index) >= armylead(index) THEN COLOR 12: CALL clrbot: PRINT armyname$(index); ": Army has reached maximum improvement through drilling"; : GOTO optmen
	armyexper(index) = armyexper(index) + 1
	CALL clrbot: PRINT armyname$(index); " has drilled to reach experience level "; armyexper(index); : IF noise > 0 THEN SOUND 2222, 1
	CALL TICK(turbo!): clrbot
	armymove(index) = -1
	choose = 28
	GOTO optmen
'-------------------------------------------------------------------------
'                               Relieve
'-------------------------------------------------------------------------
		CASE 8
		CALL relieve(side)
		choose = 29
		GOTO optmen
'-------------------------------------------------------------------------
		CASE ELSE
		chosit = 28
		GOTO menu0
      END SELECT
	choose = 21 + choose: GOTO optmen
'==========================================================================
'                               Utility Menu
'==========================================================================
	CASE 8
utile:
	chosit = 29
	mtx$(0) = "Utility"
	mtx$(1) = "Side": IF player = 2 THEN mtx$(2) = ""
	mtx$(2) = "1 Player": IF player = 2 THEN mtx$(2) = "2 Player"
	mtx$(3) = "Graphics" + STR$(graf)
	mtx$(4) = "Noise": IF noise > 0 THEN mtx$(4) = mtx$(4) + STRING$(noise, "*")
	mtx$(5) = "Display" + STR$(turbo!)
	a$ = STR$(difficult): IF side = 1 THEN a$ = STR$(6 - difficult)
	mtx$(6) = "Balance" + a$
	mtx$(7) = "End Cond"
	a$ = "û": IF randbal = 0 THEN a$ = ""
	mtx$(8) = "Rndom Evt " + a$
	mtx$(9) = "Vary Start"
	a$ = "": IF jancam = 1 THEN a$ = "û"
	mtx$(10) = "Jan Campgn" + a$
	a$ = "": IF realism = 1 THEN a$ = "û"
	mtx$(11) = "Realism " + a$
	mtx$(12) = "Chk Links"
	a$ = "": IF history = 1 THEN a$ = "û"
	mtx$(13) = "History" + a$
	size = 13: tlx = 67: tly = 11
	COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
	IF player = 1 THEN size = 14: mtx$(14) = "Aggress" + STR$(bold)
	CALL menu(-1): CALL clrrite
	    SELECT CASE choose
'-------------------------------------------------------------------------
'                               Swap Sides
'-------------------------------------------------------------------------
	    CASE 1
		IF player = 2 GOTO menu0
		side = 3 - side: COLOR 9: IF side = 2 THEN COLOR 7
		CALL clrbot: PRINT "Now playing "; force$(side); " side"; : IF noise > 0 THEN SOUND 999, 1
		IF side = 1 THEN randbal = 7
		IF side = 2 THEN randbal = 3
		CALL topbar
		GOTO menu0
'-------------------------------------------------------------------------
'                               Solo or 2 Player
'-------------------------------------------------------------------------
	    CASE 2
		player = 3 - player: CALL clrbot: COLOR 12
		IF noise > 0 THEN SOUND 999, 1
		a$ = "Solo": IF player = 2 THEN a$ = "2 Player"
		PRINT a$; " Game";
		choose = 23: GOTO utile
'-------------------------------------------------------------------------
'                               Graphics
'-------------------------------------------------------------------------
	    CASE 3
		graf = graf + 1
		IF graf > 3 THEN graf = 0
		a$ = "ROADS"
		IF graf = 0 THEN a$ = "DISABLED"
		IF graf = 2 THEN a$ = "CITY NAMES"
		IF graf = 3 THEN a$ = "FULL"
		CLS
		CALL usa
		CALL clrbot: COLOR 11: PRINT "Graphics : "; a$; : IF noise > 0 THEN SOUND 2700, 1
		choose = 24: GOTO utile
'-------------------------------------------------------------------------
'                               Sounds
'-------------------------------------------------------------------------
	    CASE 4
		CALL clrrite: choose = noise + 22
		mtx$(0) = "SOUNDS"
		mtx$(1) = "Quiet"
		mtx$(2) = "Sound"
		mtx$(3) = " & Sound"
		size = 3: tlx = 67: tly = 12
		CALL menu(0): CALL clrrite
		IF choose < 1 GOTO menu0
		COLOR 11: CALL clrbot: PRINT "Sound Option : "; mtx$(choose);
		noise = choose - 1
		IF noise > 0 THEN SOUND 999, 1
		choose = 25: GOTO utile
'-------------------------------------------------------------------------
'                               Display Speed
'-------------------------------------------------------------------------
	    CASE 5
		choose = turbo! + 21
		mtx$(0) = "Display"
		mtx$(1) = "Fast"
		mtx$(2) = "Normal"
		mtx$(3) = "Slow"
		mtx$(4) = "Very Slow"
		mtx$(5) = "Reg Color": IF bw > 0 THEN mtx$(5) = "Alt Color"
		tlx = 67: tly = 15: size = 5
		CALL menu(0): CALL clrrite
		SELECT CASE choose
			CASE IS < 1
			CASE IS < 5
				turbo! = choose
				IF turbo! = 4 THEN turbo! = 8
				CALL clrbot: COLOR 11
				PRINT "Display Speed : "; mtx$(choose);
			CASE 5
				bw = 1 - bw
				CLS
				CALL usa
				CALL topbar
		END SELECT
		choose = 26: GOTO utile
'-------------------------------------------------------------------------
'                               Play Balance
'-------------------------------------------------------------------------
	   CASE 6
		choose = difficult + 21
		mtx$(0) = "Balance"
		mtx$(1) = "Rebel ++"
		mtx$(2) = "Rebel +"
		mtx$(3) = "Balanced"
		mtx$(4) = "Union +"
		mtx$(5) = "Union ++"
		tlx = 67: tly = 15: size = 5
		CALL menu(8): CALL clrrite
		IF choose < 1 GOTO menu0
		CALL clrbot
		COLOR 11: CALL clrbot: PRINT "Play Balance : "; mtx$(choose);
		difficult = choose
		GOSUB unionplus
		choose = 27: GOTO utile
'-------------------------------------------------------------------------
'                               Ending Conditions
'-------------------------------------------------------------------------
	   CASE 7
		CALL endit
		choose = 28: GOTO utile
'-------------------------------------------------------------------------
'                           Random Events Options
'-------------------------------------------------------------------------
	   CASE 8
		 mtx$(0) = "Random Events"
		 size = 4: tlx = 30: tly = 8
		 mtx$(1) = "OFF"
		 mtx$(2) = "Favor Union ": IF randbal = 3 THEN mtx$(2) = mtx$(2) + " "
		 mtx$(3) = "Neutral     ": IF randbal = 5 THEN mtx$(3) = mtx$(3) + " "
		 mtx$(4) = "Favor Rebels": IF randbal = 7 THEN mtx$(4) = mtx$(4) + " "
		 colour = 5
		 CALL menu(0)
		 colour = 4

		 SELECT CASE choose
		 CASE 1
		 randbal = 0: t$ = ""
		 CASE 2
		 randbal = 3
		 CASE 3
		 randbal = 5
		 CASE 4
		 randbal = 7
		 CASE ELSE
		 END SELECT
		 IF choose > 1 AND choose < 5 THEN t$ = mtx$(choose)
		 CALL clrbot
		 a$ = "": IF randbal = 0 THEN a$ = "OFF"
		 COLOR 11: PRINT "Random Events : "; a$; " "; t$;
		 COLOR 14: PRINT "			press a key";
		 CALL announce(1, "R"): DO WHILE INKEY$ = "": LOOP
		 CLS
		 CALL usa
		 choose = 29
		 GOTO utile
'-------------------------------------------------------------------------
'                              Vary Start Conditions
'-------------------------------------------------------------------------
	   CASE 9
		CALL filer(1)
		cash(1) = cash(1) - 100 + 200 * RND
		cash(2) = cash(2) + 100 + 200 * RND
		bold = 5 * RND
		FOR k = 1 TO 6
			IF RND > .6 THEN
			armyloc(k) = 0: armysize(k) = 0: armylead(k) = 0
			armyexper(k) = 0: armymove(k) = 0: supply(k) = 0
			END IF
		NEXT k
		FOR k = 21 TO 26
			IF RND > .6 THEN
			armyloc(k) = 0: armysize(k) = 0: armylead(k) = 0
			armyexper(k) = 0: armymove(k) = 0: supply(k) = 0
			END IF
		NEXT k
		FOR k = 1 TO 40: CALL occupy(k): NEXT k
		navysize(1) = 10 * RND: IF navysize(1) = 0 THEN navyloc(1) = 0
		navysize(2) = 10 * RND: IF navysize(2) > 0 THEN navyloc(2) = 27
		FOR i = 1 TO 2
			fleet$(i) = ""
			FOR j = 1 TO navysize(i)
			a$ = "W": IF RND > .45 * side THEN a$ = "I"
			fleet$(i) = fleet$(i) + a$
		NEXT j
		NEXT i
		IF RND > .7 THEN capcity(2) = 25

		FOR k = 1 TO 40
		IF RND > .8 THEN rating(k) = rating(k) - 3 + 6 * RND: IF rating(k) > 9 THEN rating(k) = 9
		IF rating(k) < 1 THEN rating(k) = 1
		NEXT k
		CLS
		CALL usa
		choose = 30: GOTO utile
'-------------------------------------------------------------------------
'                               January Campaigns
'-------------------------------------------------------------------------
	   CASE 10
		jancam = 1 - jancam
		a$ = "PROHIBITED": IF jancam = 1 THEN a$ = "ALLOWED"
		COLOR 11
		CALL clrbot
		PRINT "January Campaigns : "; a$;
		choose = 31: GOTO utile
'-------------------------------------------------------------------------
'                               Realism Switch
'-------------------------------------------------------------------------
	   CASE 11
		realism = 1 - realism
		CALL clrbot: COLOR 11
	IF realism = 0 THEN
		PRINT "Recruiting FIXED :  7000 for NEW Armies   4500 for Additions";
	ELSE
		PRINT "REALISM ON: Recruiting based on CITY SIZE";
		IF side = 2 AND randbal = 1 AND randbal < 5 THEN randbal = randbal + 2
		GOSUB unionplus
	END IF
		choose = 32: GOTO utile
'-------------------------------------------------------------------------
'                               Check Map Linakges
'-------------------------------------------------------------------------
	   CASE 12
		CALL integrity
		CALL TICK(99)
		CALL usa
'-------------------------------------------------------------------------
'                               History
'-------------------------------------------------------------------------
	   CASE 13
		history = 1 - history
		a$ = "OFF": IF history = 1 THEN a$ = "ON"
		CALL clrbot: PRINT "History is now "; a$;
		choose = 34: GOTO utile
'-------------------------------------------------------------------------
'                               Aggression
'-------------------------------------------------------------------------
	   CASE 14
		bold = bold + 1: IF bold > 5 THEN bold = 0
		SELECT CASE bold
		CASE 0: a$ = "PASSIVE"
		CASE 1: a$ = "TIMID"
		CASE 2: a$ = "CAUTIOUS"
		CASE 3: a$ = "NORMAL"
		CASE 4: a$ = "BOLD"
		CASE 5: a$ = "RECKLESS"
		END SELECT
		CALL clrbot
		COLOR 11
		PRINT "Enemy Aggression : "; a$; " ("; bold; ")";
		choose = 35: GOTO utile
		CASE ELSE
	   END SELECT
'==========================================================================
'                               Files
'==========================================================================
	CASE 9
	IF LEN(DIR$("*.sav")) = 0 THEN filel = 0
filex:
	choose = 23: chosit = 30: IF year = 1861 THEN choose = 22
	mtx$(0) = "Options"
	mtx$(1) = "Load": IF filel = 0 THEN mtx$(1) = "-": choose = 23
	mtx$(2) = "Save"
	mtx$(3) = "New Game"
	mtx$(4) = "Quit to DOS"
	size = 4: tlx = 67: tly = 15
	CALL menu(0): CALL clrrite
	SELECT CASE choose
		CASE IS < 1: GOTO menu0
		CASE 1, 2
loader:
			IF choose = 1 AND filel = 0 GOTO filex
			CALL filer(choose + 1)
			IF choose = 1 THEN rflag = 0: mflag = 0: nflag = 0
			GOTO menu0
		CASE 3
			OPEN "O", 1, "cws.cfg"
			WRITE #1, side, graf, noise, difficult, player, turbo!, randbal, train(1), train(2), jancam, realism, batwon(1), batwon(2), casualty&(1), casualty&(2), history, bold
			CLOSE #1
			CLS
			GOTO newgame
		CASE 4: GOTO rusure
	END SELECT
'==========================================================================
	CASE 99
	GOTO endrnd
CASE ELSE
	chosit = 22
	GOTO menu0
END SELECT
GOTO menu0
'............................................................................
'                               Subs
'............................................................................
rusure:
choose = 23
mtx$(0) = "Quit"
mtx$(1) = "Yes"
mtx$(2) = "No"
size = 2: colour = 5
tlx = 67: tly = 15
CALL menu(0): CALL clrrite: IF choose = 1 THEN END ELSE GOTO menu0
'............................................................................
unionplus: usadv = 120 * difficult: IF player = 2 THEN usadv = 50 * difficult
	   IF realism > 0 THEN usadv = usadv * .7
	   RETURN
'............................................................................
blanken:        c = 1: IF side = 2 THEN c = 7
		CLS : LINE (100, 200)-(500, 300), c, BF
		LINE (100, 200)-(500, 300), 8 - c, B
		COLOR 7: LOCATE 14, 31: PRINT " "; month$(month); year
		COLOR 11: LOCATE 17, 30: PRINT force$(side); " PLAYER TURN"
		CALL announce(1, "T"): DO WHILE INKEY$ = "": LOOP
		RETURN
'............................................................................
DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"

' $INCLUDE: 'cwstrat1.bm'
' $INCLUDE: 'cwstrat2.bm'
' $INCLUDE: 'cwsmenu.bm'
' $INCLUDE: 'drawings/map.bm'
' $INCLUDE: 'drawings/schooner.bm'
' $INCLUDE: 'drawings/ironclad.bm'
' $INCLUDE: 'drawings/cannon.bm'
' $INCLUDE: 'drawings/capitol.bm'
' $INCLUDE: 'drawings/rwin.bm'
' $INCLUDE: 'drawings/surrender.bm'
' $INCLUDE: 'drawings/icons.bm'
' $INCLUDE: 'qb64.bm'
' $INCLUDE: 'script.bm'
