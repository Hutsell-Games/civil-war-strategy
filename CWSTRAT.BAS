DEFINT A-Z
DECLARE SUB drawArmy (x%, y%, z%)
DECLARE SUB sinkShip (who%)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB integrity ()
DECLARE SUB ironclad ()
DECLARE SUB generateNormalRandom (xbar%, variance%, result%)
DECLARE SUB relieve (who%)
DECLARE SUB retreat (active%, x%)
DECLARE SUB schooner ()
DECLARE SUB shiptype (who%, i%)
DECLARE SUB stax (who%)
DECLARE SUB tinytrain (who%, flag%)
DECLARE SUB traincapacity (who%, limit%)
DECLARE SUB topbar ()
DIM SHARED graphic(1 TO 1564), Ncap(60)
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
IF _FILEEXISTS("mtn.vga") THEN
	DEF SEG = VARSEG(mtn(1))
	BLOAD "mtn.vga", VARPTR(mtn(1))
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
iron:
IF player < 1 OR player > 2 THEN player = 1
IF player = 2 OR side = 0 THEN side = 1
IF side = 1 THEN randbal = 7
IF side = 2 THEN randbal = 3
	IF turbo! < 1 THEN turbo! = 2
	IF side = 1 AND difficult < 3 THEN cash(2) = cash(2) + 600 - 100 * difficult
	IF side = 2 AND difficult > 3 THEN cash(1) = cash(1) + 100 * difficult


FOR i = 1 TO 2: income(i) = cash(i): cash(i) = cash(i) + 50 * RND: NEXT i
choose = 0
a$ = COMMAND$: IF a$ <> "" OR replay > 0 GOTO notitle2

notitle2:
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
OPEN "I", 1, "cities.grd"
vptotal = usadv + 200
FOR i = 1 TO 40: INPUT #1, a, cityx(i), cityy(i), city$(i), cityp(i), cityv(i)
cityo(i) = cityp(i)
CALL occupy(i)
FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j: INPUT #1, fort(i)
IF cityp(i) > 0 THEN x = cityp(i): control(x) = control(x) + 1: victory(x) = victory(x) + cityv(i)
IF cityp(i) > 0 THEN cash(cityp(i)) = cash(cityp(i)) + cityv(i)
vptotal = vptotal + cityv(i)
NEXT i
CLOSE #1: CALL clearBottom

RANDOMIZE TIMER
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
	GOTO menu0
END IF
IF choose = 3 THEN CLS : END
IF history = 1 THEN
	CLS
	IF _FILEEXISTS("cws.his") THEN SHELL "copy cws.his oldhist.ory"
	OPEN "O", 2, "cws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; DATE$; " ]"
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
menuText$(0) = "Main"
menuText$(1) = "Troops": IF rflag < 0 OR cash(side) < 100 THEN menuText$(1) = "-": chosit = 23
menuText$(2) = "Moves": IF mflag > 0 THEN menuText$(2) = "-": IF chosit = 23 THEN chosit = 24
menuText$(3) = "Ships": IF nflag > 0 THEN menuText$(3) = "-": IF chosit = 24 THEN chosit = 25
menuText$(4) = "Railroad": IF rr(side) > 0 THEN menuText$(4) = "-": IF chosit = 25 THEN chosit = 26
menuText$(5) = "END TURN"
menuText$(6) = "Inform"
menuText$(7) = "COMMANDS"
menuText$(8) = "UTILITY"
menuText$(9) = "Files"

size = 9
choose = chosit
CALL menu(0): CALL clearRight
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
	DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5R1BF4"
	z = 9: IF side = 2 THEN z = 7
	x = POINT(0): y = POINT(1)
	PAINT (x, y), z, 15
	COLOR 15: IF side = 1 THEN COLOR 11
	CALL traincapacity(side, limit)
	CALL clearBottom: PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
	CALL railroad(side)
ELSE
	CALL clearBottom: COLOR 11: PRINT "Railroad is already carrying "; armyname$(rr(side)); " to "; city$(armymove(rr(side))); : GOTO menu0
END IF
'==========================================================================
	CASE 5
	tlx = 67: tly = 15
	hilite = 15: colour = 3: choose = 23
	menuText$(0) = "End Turn"
	menuText$(1) = "Yes"
	menuText$(2) = "NOT YET"
	size = 2: CALL menu(0): CALL clearRight: IF choose <> 1 THEN chosit = 24: GOTO menu0
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
	menuText$(0) = "Commands"
	menuText$(1) = "Cancel"
	menuText$(2) = "Fortify": IF cash(side) < 200 THEN menuText$(2) = "-"
	menuText$(3) = "Join"
	menuText$(4) = "Supply"
	menuText$(5) = "Capital": IF capcity(side) = 0 OR cash(side) < 500 THEN menuText$(5) = "-"
	menuText$(6) = "Detach": IF side = 1 THEN menuText$(6) = "-"
	menuText$(7) = "Army Drill"
	menuText$(8) = "Relieve"
	menuText$(9) = "MAIN MENU"
	size = 9
	CALL menu(0): CALL clearRight
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
	IF cash(side) < 200 THEN COLOR 11: CALL clearBottom: PRINT "Not enough money for fort"; : GOTO menu0
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
		CALL clearBottom
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
		menuText$(0) = "Supply"
		tlx = 67: tly = 5: colour = 5
		size = 0
		FOR i = star TO fin
		IF armyloc(i) = 0 OR supply(i) > 1 GOTO alone
		IF realism > 0 THEN
			CALL cutoff(side, armyloc(i), a)
			IF a < 1 THEN CALL clearBottom: COLOR 15: PRINT force$(side); " army in "; city$(armyloc(i)); " is CUT OFF !"; : TICK turbo!: GOTO alone
		END IF
		size = size + 1
		max = 11: IF LEN(armyname$(i)) < 11 THEN max = LEN(armyname$(i))
		menuText$(size) = LEFT$(armyname$(i), max)
		array(size) = i
alone:
		NEXT i
		IF size = 0 THEN COLOR 11: CALL clearBottom: PRINT "All eligible "; force$(side); " armies have supplies"; : GOTO menu0
		CALL menu(6): CALL clearRight
		IF choose < 0 GOTO menu0
		index = array(choose)
		IF supply(index) < 2 THEN
		CALL resupplyArmy(index)
		CALL placearmy(index)
		END IF
		choose = 25
		GOTO optmen
'-------------------------------------------------------------------------
'                               Move Capital
'-------------------------------------------------------------------------
		CASE 5
	IF capcity(side) = 0 OR cash(side) < 500 THEN CALL clearBottom: COLOR 11: PRINT "Cannot move capital"; : GOTO menu0
	cash(side) = cash(side) - 500
	victory(3 - side) = victory(3 - side) + 50
	CALL clearRight
	menuText$(0) = "Capital"
	a$ = city$(capcity(side))
	index = capcity(side): CALL newcity(index)
	IF index = 0 GOTO menu0
	capcity(side) = index
	CALL clearBottom: PRINT force$(side); " capital moved from "; a$; " to "; city$(capcity(side));
	CALL clearRight
	CALL showcity
	CALL TICK(9): CALL clearBottom
'-------------------------------------------------------------------------
'                               Detach
'-------------------------------------------------------------------------
		CASE 6
	IF side = 1 THEN CALL clearBottom: COLOR 11: PRINT "Option not available to Union"; : GOTO menu0
	COLOR 14: LOCATE 4, 68: PRINT "DETACH UNIT"
	CALL movefrom(index, target): IF target < 1 OR index < 1 GOTO menu0
	IF armysize(index) < 65 THEN CALL clearBottom: PRINT "Too small to detach"; : CALL TICK(turbo!): GOTO menu0
	CALL commander(2, empty): IF empty = 0 GOTO menu0
	supply(empty) = .3 * supply(index): supply(index) = supply(index) - supply(empty): IF supply(index) < 0 THEN supply(index) = 0
	armysize(empty) = .3 * armysize(index): armysize(index) = armysize(index) - armysize(empty)
	armyloc(empty) = target: armyexper(empty) = armyexper(index): armymove(empty) = 0
	armylead(empty) = rating(empty)
	armyname$(empty) = lname$(empty): lname$(empty) = ""
	armyexper(empty) = armyexper(index)
	COLOR 11: CALL clearBottom: PRINT "Unit #"; empty; " with "; : CALL strong(empty): PRINT " men detached under "; armyname$(empty); : CALL TICK(turbo!): IF noise > 0 THEN SOUND 2222, 1
	CALL stax(side)
	choose = 27
	GOTO optmen
'-------------------------------------------------------------------------
'                               Drill
'-------------------------------------------------------------------------
		CASE 7
	COLOR 14: LOCATE 4, 68: PRINT "DRILL ARMY"
	CALL movefrom(index, target)
	IF target < 1 OR index < 1 THEN COLOR 11: CALL clearBottom: PRINT "No armies remain eligible for drills in "; month$(month); : GOTO menu0
	IF armyexper(index) > 5 OR armyexper(index) >= armylead(index) THEN COLOR 12: CALL clearBottom: PRINT armyname$(index); ": Army has reached maximum improvement through drilling"; : GOTO optmen
	armyexper(index) = armyexper(index) + 1
	CALL clearBottom: PRINT armyname$(index); " has drilled to reach experience level "; armyexper(index); : IF noise > 0 THEN SOUND 2222, 1
	CALL TICK(turbo!): clearBottom
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
	menuText$(0) = "Utility"
	menuText$(1) = "Side": IF player = 2 THEN menuText$(2) = ""
	menuText$(2) = "1 Player": IF player = 2 THEN menuText$(2) = "2 Player"
	menuText$(3) = "Graphics" + STR$(graf)
	menuText$(4) = "Noise": IF noise > 0 THEN menuText$(4) = menuText$(4) + STRING$(noise, "*")
	menuText$(5) = "Display" + STR$(turbo!)
	a$ = STR$(difficult): IF side = 1 THEN a$ = STR$(6 - difficult)
	menuText$(6) = "Balance" + a$
	menuText$(7) = "End Cond"
	a$ = "û": IF randbal = 0 THEN a$ = ""
	menuText$(8) = "Rndom Evt " + a$
	menuText$(9) = "Vary Start"
	a$ = "": IF jancam = 1 THEN a$ = "û"
	menuText$(10) = "Jan Campgn" + a$
	a$ = "": IF realism = 1 THEN a$ = "û"
	menuText$(11) = "Realism " + a$
	menuText$(12) = "Chk Links"
	a$ = "": IF history = 1 THEN a$ = "û"
	menuText$(13) = "History" + a$
	size = 13: tlx = 67: tly = 11
	COLOR 11: LOCATE tly - 2, tlx: PRINT "esc=Main Menu"
	IF player = 1 THEN size = 14: menuText$(14) = "Aggress" + STR$(bold)
	CALL menu(-1): CALL clearRight
	    SELECT CASE choose
'-------------------------------------------------------------------------
'                               Swap Sides
'-------------------------------------------------------------------------
	    CASE 1
		IF player = 2 GOTO menu0
		side = 3 - side: COLOR 9: IF side = 2 THEN COLOR 7
		CALL clearBottom: PRINT "Now playing "; force$(side); " side"; : IF noise > 0 THEN SOUND 999, 1
		IF side = 1 THEN randbal = 7
		IF side = 2 THEN randbal = 3
		CALL topbar
		GOTO menu0
'-------------------------------------------------------------------------
'                               Solo or 2 Player
'-------------------------------------------------------------------------
	    CASE 2
		player = 3 - player: CALL clearBottom: COLOR 12
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
		CALL clearBottom: COLOR 11: PRINT "Graphics : "; a$; : IF noise > 0 THEN SOUND 2700, 1
		choose = 24: GOTO utile
'-------------------------------------------------------------------------
'                               Sounds
'-------------------------------------------------------------------------
	    CASE 4
		CALL clearRight: choose = noise + 22
		menuText$(0) = "SOUNDS"
		menuText$(1) = "Quiet"
		menuText$(2) = "Sound"
		menuText$(3) = " & Sound"
		size = 3: tlx = 67: tly = 12
		CALL menu(0): CALL clearRight
		IF choose < 1 GOTO menu0
		COLOR 11: CALL clearBottom: PRINT "Sound Option : "; menuText$(choose);
		noise = choose - 1
		IF noise > 0 THEN SOUND 999, 1
		choose = 25: GOTO utile
'-------------------------------------------------------------------------
'                               Display Speed
'-------------------------------------------------------------------------
	    CASE 5
		choose = turbo! + 21
		menuText$(0) = "Display"
		menuText$(1) = "Fast"
		menuText$(2) = "Normal"
		menuText$(3) = "Slow"
		menuText$(4) = "Very Slow"
		menuText$(5) = "Reg Color": IF bw > 0 THEN menuText$(5) = "Alt Color"
		tlx = 67: tly = 15: size = 5
		CALL menu(0): CALL clearRight
		SELECT CASE choose
			CASE IS < 1
			CASE IS < 5
				turbo! = choose
				IF turbo! = 4 THEN turbo! = 8
				CALL clearBottom: COLOR 11
				PRINT "Display Speed : "; menuText$(choose);
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
		menuText$(0) = "Balance"
		menuText$(1) = "Rebel ++"
		menuText$(2) = "Rebel +"
		menuText$(3) = "Balanced"
		menuText$(4) = "Union +"
		menuText$(5) = "Union ++"
		tlx = 67: tly = 15: size = 5
		CALL menu(8): CALL clearRight
		IF choose < 1 GOTO menu0
		CALL clearBottom
		COLOR 11: CALL clearBottom: PRINT "Play Balance : "; menuText$(choose);
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
		 menuText$(0) = "Random Events"
		 size = 4: tlx = 30: tly = 8
		 menuText$(1) = "OFF"
		 menuText$(2) = "Favor Union ": IF randbal = 3 THEN menuText$(2) = menuText$(2) + " "
		 menuText$(3) = "Neutral     ": IF randbal = 5 THEN menuText$(3) = menuText$(3) + " "
		 menuText$(4) = "Favor Rebels": IF randbal = 7 THEN menuText$(4) = menuText$(4) + " "
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
		 IF choose > 1 AND choose < 5 THEN t$ = menuText$(choose)
		 CALL clearBottom
		 a$ = "": IF randbal = 0 THEN a$ = "OFF"
		 COLOR 11: PRINT "Random Events : "; a$; " "; t$;
		 COLOR 14: PRINT "			press a key";
		 DO WHILE INKEY$ = "": LOOP
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
		FOR k = 21 TO 6
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
		CALL clearBottom
		PRINT "January Campaigns : "; a$;
		choose = 31: GOTO utile
'-------------------------------------------------------------------------
'                               Realism Switch
'-------------------------------------------------------------------------
	   CASE 11
		realism = 1 - realism
		CALL clearBottom: COLOR 11
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
		CALL clearBottom: PRINT "History is now "; a$;
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
		CALL clearBottom
		COLOR 11
		PRINT "Enemy Aggression : "; a$; " ("; bold; ")";
		choose = 35: GOTO utile
		CASE ELSE
	   END SELECT
'==========================================================================
'                               Files
'==========================================================================
	CASE 9
	IF _FILEEXISTS("*.sav") THEN filel = 0
filex:
	choose = 23: chosit = 30: IF year = 1861 THEN choose = 22
	menuText$(0) = "Options"
	menuText$(1) = "Load": IF filel = 0 THEN menuText$(1) = "-": choose = 23
	menuText$(2) = "Save"
	menuText$(3) = "New Game"
	menuText$(4) = "Quit to DOS"
	size = 4: tlx = 67: tly = 15
	CALL menu(0): CALL clearRight
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
topbar:
LOCATE 1, 1: PRINT SPACE$(80);
COLOR 11
LOCATE 1, 10: PRINT "Input your decisions now for "; force$(side); " side "; : COLOR 14: PRINT month$(month); ","; year; "  "
RETURN
'............................................................................
rusure:
choose = 23
menuText$(0) = "Quit"
menuText$(1) = "Yes"
menuText$(2) = "No"
size = 2: colour = 5
tlx = 67: tly = 15
CALL menu(0): CALL clearRight: IF choose = 1 THEN END ELSE GOTO menu0
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
		DO WHILE INKEY$ = "": LOOP
		RETURN
'............................................................................
DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"

SUB animate (index, flag)
    ' Store the current and target locations of the army
    from = armyloc(index)
    to2 = armymove(index)
    armyloc(index) = 0

    ' Calculate the initial coordinates for animation
    x = cityx(from) - 12
    y = cityy(from) - 11
    x1 = .5 * (cityx(to2) + cityx(from))
    y1 = .5 * (cityy(to2) + cityy(from))

    ' Place the army in the current location if occupied
    CALL occupy(from)
    IF occupied(from) > 0 THEN CALL placearmy(occupied(from))
       
    ' Skip the animation setup if flag is set
    IF flag > 0 GOTO already

    ' Capture the current screen area for animation
	GET (x - 9, y - 7)-(x + 9, y + 6), anima
	IF occupied(from) = 0 THEN LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF

    already:
    ' Animate the movement of the army
	FOR i = 2 TO 8
	x1 = .1 * (i * cityx(to2) + (10 - i) * cityx(from))
	y1 = .1 * (i * cityy(to2) + (10 - i) * cityy(from))
	GET (x1 - 10, y1 - 10)-(x1 + 9, y1 + 9), image
	PUT (x1 - 10, y1 - 10), anima, PSET
	IF turbo! > 1 THEN CALL TICK(.1) ELSE CALL TICK(.02)
	IF noise > 0 THEN SOUND 200, .1: SOUND 50, .1
	PUT (x1 - 10, y1 - 10), image, PSET
	NEXT i

    ' Restore the army's original location
	armyloc(index) = from
END SUB

' This subroutine handles the movement of armies from one city to another.
' It first determines the target city and then displays a menu of possible destinations.
' If a valid destination is chosen, it updates the army's location and animates the movement.

SUB armies
    ' Determine the target city for the army movement
    CALL movefrom(index, target)
    IF target > 0 AND index > 0 GOTO tent
	IF index = -1 THEN mflag = 1
	GOTO dudd

    tent:
    tlx = 67
    tly = 12

    ' Display the army's status
    CALL armystat(index)
    COLOR 11
    LOCATE 11, 68
    PRINT city$(target)
    size = 0
    menuText$(0) = "To"

    ' Populate the menu with possible destination cities
    FOR i = 1 TO 6
        IF matrix(target, i) > 0 THEN
            size = size + 1
            menuText$(size) = city$(matrix(target, i))
            array(size) = matrix(target, i)
        END IF
    NEXT i
    CALL bubbleSortMenuText(size)

    ' Display the menu and handle the user's choice
    hilite = 10
    colour = 3
    CALL menu(2)
    CALL clearRight
    IF choose < 0 GOTO dudd
    IF month < 3 AND jancam = 0 AND cityp(array(choose)) <> side THEN
        COLOR 11
        CALL clearBottom
        PRINT "No campaigns in January"
        CALL TICK(9)
        CALL clearBottom
        GOTO dudd
    END IF

    ' Update the army's location and animate the movement
    CALL clearBottom
    PRINT "Army "; index; " "; armyname$(index); " is moving from "; city$(target); " to "; city$(array(choose))
    IF noise > 0 THEN
        SOUND 2200, .5
        SOUND 2900, .7
    END IF
    CALL icon(target, array(choose), 1)
    armymove(index) = array(choose)
    CALL TICK(turbo!)
    CALL clearBottom
    CALL clearRight

dudd:
END SUB

SUB armystat (index)
LINE (530, 60)-(639, 150), 0, BF
COLOR 15
LOCATE 5, 68: PRINT armyname$(index)
COLOR 9: IF index > 20 THEN COLOR 7
LOCATE 6, 68: PRINT "Size:"; : CALL strong(index)
LOCATE 7, 68: PRINT "Leader:"; TAB(75); armylead(index)
LOCATE 8, 68: PRINT "Exper:"; TAB(75); armyexper(index)
IF supply(index) < 2 THEN COLOR 12
LOCATE 9, 68: PRINT "Supply:"; TAB(75); supply(index)
END SUB

SUB sinkShip (who)
navysize(who) = navysize(who) - 1
IF navysize(who) > 0 THEN
	fleet$(who) = LEFT$(fleet$(who), navysize(who))
ELSE
	fleet$(who) = "": navyloc(who) = 0: navysize(who) = 0
END IF
END SUB

SUB battle (attack, defend, win, lose)
    ' Ensure minimum army size
    IF armysize(defend) < 1 THEN armysize(defend) = 1
    IF armysize(attack) < 1 THEN armysize(attack) = 1

    ' Display attacker information
    CALL icon(armyloc(defend), 0, 9)
    LOCATE 1, 1: PRINT SPACE$(80)
    CALL clearRight: y = 68: COLOR 11: LOCATE 1, y: PRINT "Attacker"
    c = 9: IF attack > 20 THEN c = 7
    COLOR c: LOCATE 2, y: PRINT armyname$(attack)
    LOCATE 3, y: CALL strong(attack)
    x = .01 * armysize(attack): IF x > TCR THEN x = TCR
    LOCATE 4, y: PRINT "Base    "; x
    IF armysize(attack) / armysize(defend) > .2 THEN x = x + .3 * armylead(attack) + .3 * armyexper(attack): IF x > TCR THEN x = TCR
    IF armyexper(attack) > 8 THEN x = x + 1: IF x > TCR THEN x = TCR
    LOCATE 5, y: PRINT "Ldr/Exp "; x
    IF armysize(attack) < 15 THEN x = .5 * x: IF x > TCR THEN x = TCR
    LOCATE 6, y: PRINT "Small   "; x
    IF armysize(attack) / armysize(defend) <= .5 THEN x = x - 2: IF x < 1 THEN x = 1
    IF armysize(attack) / armysize(defend) > 3 THEN x = x + 2: IF x > TCR THEN x = TCR
    IF armysize(attack) / armysize(defend) > 10 THEN x = TCR
    IF armysize(attack) / armysize(defend) <= .2 THEN x = 1
    LOCATE 7, y: PRINT "Outman  "; x
    IF supply(attack) < 1 THEN x = .5 * x: COLOR 13
    LOCATE 8, y: PRINT "Supply  "; x: COLOR c
    IF x < 1 THEN x = 1

    ' Adjust attack advantage based on difficulty and side
    IF attack < 21 AND side = 2 AND difficult > 3 THEN x = x + 2 * difficult - 6
    IF attack > 20 AND side = 1 AND difficult < 3 THEN x = x + 6 - 2 * difficult
    LOCATE 9, y: PRINT "Difclt  "; x
    IF x > TCR THEN x = TCR
    COLOR 11: LOCATE 11, y: PRINT "Attack  "; x
    LINE (530, 155)-(635, 175), 11, B

    ' Display defender information
    x1 = .013 * armysize(defend) + 1: IF realism = 1 THEN x1 = .02 * armysize(defend) + 2: IF x1 > 20 THEN x1 = 20
    LOCATE 13, y: PRINT "Defender"
    COLOR 16 - c: LOCATE 14, y: PRINT armyname$(defend)
    LOCATE 15, y: CALL strong(defend)
    LOCATE 16, y: PRINT "Base    "; INT(.01 * armysize(defend))
    LOCATE 17, y: PRINT "Defense "; x1
    IF armysize(defend) / armysize(attack) > .2 THEN x1 = x1 + .3 * armylead(defend) + .3 * armyexper(defend): IF x1 > TCR THEN x1 = TCR
    IF armyexper(defend) > 8 THEN x1 = x1 + 1: IF x1 > TCR THEN x1 = TCR
    LOCATE 18, y: PRINT "Ldr/Exp "; x1
    IF armysize(defend) < 15 THEN x1 = .5 * x1
    LOCATE 19, y: PRINT "Small   "; x1

    ' Adjust defender advantage based on army size ratio
    R! = armysize(defend) / armysize(attack)
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
    IF supply(defend) < 1 THEN x1 = .5 * x1: COLOR 13
    LOCATE 21, y: PRINT "Supply  "; x1: COLOR 16 - c
    IF x1 < 1 THEN x1 = 1
    
    ' Adjust defend advantage based on difficulty and side
    IF defend < 21 AND side = 2 AND difficult > 3 THEN x1 = x1 + 2 * difficult - 6
    IF defend > 20 AND side = 1 AND difficult < 3 THEN x1 = x1 + 6 - 2 * difficult
    LOCATE 22, y: PRINT "Difclt  "; x1

    ' Fortification adjustments
    a$ = "Fort": IF armymove(defend) = 0 THEN x1 = x1 * (1 + fort(armyloc(defend)))
    IF x1 > TCR THEN x1 = TCR
    IF fort(armyloc(defend)) > 0 AND armymove(defend) = 0 THEN
        COLOR 13: a$ = "Fort+"
        IF fort(armyloc(defend)) = 2 THEN a$ = "Fort++"
    END IF
    LOCATE 23, y: PRINT a$; TAB(76); x1
    IF x1 > TCR THEN x1 = TCR
    COLOR 11: LOCATE 25, y: PRINT "Defend  "; x1
    LINE (530, 380)-(635, 400), 11, B

    ' Calculate battle odds
    spin = 0
    scale = x: IF x1 > scale THEN scale = x1
    scale = scale + 1
    
    odds! = x / (x + x1): a = INT(100 * odds!): IF a < 1 THEN a = 1
    a$ = LTRIM$(RTRIM$(STR$(a))) + "%"
    COLOR 14: LOCATE 27, y: PRINT "Odds:  "; a$;
    LINE (530, 412)-(635, 435), 14, B
    LINE (528, 410)-(637, 437), 14, B
    DO WHILE INKEY$ = "": LOOP
    IF graf > 2 THEN
        CALL bubbleSortMenuText
        k = fort(armyloc(defend))
        t$ = "fort" + LTRIM$(STR$(k)) + ".vga"
        IF _FILEEXISTS(t$) THEN
            DEF SEG = VARSEG(graphic(1))
            BLOAD t$, VARPTR(graphic(1))
            DEF SEG
            PUT (550, 270), graphic, PSET
        END IF
    ELSE
        CALL clearRight
    END IF
    FOR i = 1 TO 2: IF supply(i) > 0 THEN supply(i) = supply(i) - 1
    NEXT i

    ' Determine battle outcome
    grapple:
    hit = 0: hit1 = 0
    star = scale * RND: fin = scale * RND
    IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
    IF star <= x THEN hit = 1
    IF fin <= x1 THEN hit1 = 1
    
    IF hit = 0 AND hit1 = 0 GOTO grapple
    IF hit = 1 AND hit1 = 1 GOTO grapple
    win = defend: lose = attack: IF hit = 1 THEN win = attack: lose = defend

    ' Display battle result
    a$ = "UNION": IF win > 20 THEN a$ = "REBEL"
    COLOR 14: LOCATE 3, 68: PRINT a$; " VICTORY"
    LOCATE 4, 71: PRINT "in"
    LOCATE 5, 69: PRINT city$(armyloc(defend))
    a = 1: IF win > 20 THEN a = 2
    CALL flags(a, 0, 0)
    CALL clearBottom: COLOR 11: PRINT armyname$(win); " defeats "; armyname$(lose); " in "; city$(armyloc(defend)); : CALL TICK(9)

    ' Calculate casualties
    pct! = .01 * DEFAC - .03 * fort(armyloc(defend)): IF win = attack THEN pct! = 1.3 * pct!
    SELECT CASE armysize(defend)
        CASE IS > 300
            pct! = .9 * pct!
        CASE IS > 800
            pct! = .8 * pct!
    END SELECT
    xbar = armysize(attack) * pct!
    variance = xbar * (1 - pct!)
    CALL generateNormalRandom(xbar, variance, killd)
    
    pct! = .01 * ATKFAC + .02 * fort(armyloc(defend)): IF win = defend THEN pct! = 1.5 * pct!
    SELECT CASE armysize(attack)
        CASE IS > 300
            pct! = .9 * pct!
        CASE IS > 800
            pct! = .8 * pct!
    END SELECT
    xbar = armysize(defend) * pct!
    variance = xbar * (1 - pct!)
    CALL generateNormalRandom(xbar, variance, killa)

    ' Adjust casualties
    killa = .8 * killa + .2 * killd: IF killa < 1 THEN killa = 1
    killd = .8 * killd + .2 * killa: IF killd < 1 THEN killd = 1
    IF killa > 9 * killd THEN killa = 9 * killd
    IF killd > 5 * killa THEN killd = 5 * killa
    
    IF killa >= armysize(attack) THEN killa = armysize(attack) - 1
    IF killd >= armysize(defend) THEN killd = armysize(defend) - 1

    ' Display casualties
    x = INT(100 * odds!): IF x < 1 THEN x = 1
    a$ = LTRIM$(RTRIM$(STR$(x))) + "%"

    COLOR c
    LOCATE 1, 1: PRINT "Attack Loss: ";
    PRINT LTRIM$(RTRIM$(STR$(killa)) + "00"); "/";
    CALL strong(attack)
    PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killa / armysize(attack)))))); "%) ²";
    COLOR 16 - c: PRINT "² Defend Loss: "; : PRINT LTRIM$(RTRIM$(STR$(killd)) + "00"); "/";
    CALL strong(defend)
    PRINT " ("; LTRIM$(RTRIM$(STR$(INT(100 * (killd / armysize(defend)))))); "%)"

    ' Update battle results
    menuText$(1) = " (" + LTRIM$(RTRIM$(STR$(killa) + "00")) + "/" + LTRIM$(STR$(armysize(attack)) + "00") + ") "
    t$ = " (" + LTRIM$(RTRIM$(STR$(killd) + "00")) + "/" + LTRIM$(STR$(armysize(defend)) + "00") + ")"
    menuText$(2) = t$
    IF win = defend THEN menuText$(2) = menuText$(1): menuText$(1) = t$
    menuText$(3) = "*" + armyname$(win): menuText$(4) = armyname$(lose)
    IF win = defend THEN menuText$(3) = armyname$(win): menuText$(4) = "*" + armyname$(lose)
    a$ = city$(armyloc(defend)) + ": " + menuText$(3) + menuText$(1) + " defeats " + menuText$(4) + menuText$(2)
    CALL scribe(a$, 0)

    ' Wait for player input if necessary
    IF player = 1 AND (side = 1 AND attack > 20) OR (side = 2 AND attack < 21) THEN
    COLOR 14: CALL clearBottom: PRINT "hit any key to continue"; : DO WHILE INKEY$ = "": LOOP
    END IF

    ' Update army sizes
    armysize(attack) = armysize(attack) - killa
    armysize(defend) = armysize(defend) - killd
    IF armysize(defend) < 1 THEN armysize(defend) = 1

    ' Update casualties and victories
    s = 1: IF attack > 2 THEN s = 2
    casualty&(s) = casualty&(s) + killa
    casualty&(3 - s) = casualty&(3 - s) + killd

    s = 1: IF win > 20 THEN s = 2
    batwon(s) = batwon(s) + 1
    victory(s) = victory(s) + 1
    CALL icon(armyloc(defend), 0, 8)
END SUB

SUB combine (who)
    ' Initialize variables
	colour = 3: target = 0: hilite = 3
	tlx = 67: tly = 2
	CALL starfin(star, fin, who)
	size = 0

    ' Loop through cities to find eligible armies to combine
	FOR i = 1 TO 40
		IF cityp(i) = who AND occupied(i) > 0 THEN
			FOR j = star TO fin
                IF armyloc(j) = i AND occupied(i) <> j AND armymove(j) = 0 THEN
                    size = size + 1
                    menuText$(size) = city$(i)
                    array(size) = i
                    EXIT FOR
                END IF
			NEXT j
		END IF
	NEXT i
	
    ' Exit if no eligible armies found
	IF size = 0 THEN who = -1: EXIT SUB
	CALL bubbleSortMenuText(size)

    ' Randomly choose an army if not the player's side
	IF who <> side THEN choose = 1 + INT(size * RND): GOTO join
	menuText$(0) = "Join"
		choose = 31: hilite = 11
		CALL menu(9): CALL clearRight

join:
    ' Exit if no valid choice made
		IF choose < 1 GOTO nocity2
		target = array(choose)
		CALL clearBottom: PRINT "Combining "; force$(who); " armies in "; city$(target); :  CALL TICK(turbo!)

    ' Initialize temporary army variables
		armysize(0) = 0: armylead(0) = 0: armyexper(0) = 0: armyloc(0) = target
		armyname$(0) = "": supply(0) = 0: armymove(0) = 0

    ' Combine eligible armies
		best = 0: x = 0: spin = 0
		FOR j = star TO fin
		IF armymove(j) <> 0 OR armyloc(j) <> target OR armysize(j) = 0 GOTO dork1
        IF armysize(0) + armysize(j) > 1250 THEN
            CALL clearBottom: PRINT "Cannot combine "; armyname$(j); "... TOO LARGE"; : CALL TICK(turbo!): GOTO dork1
        END IF

        ' Update best leader and combine army attributes
		IF armylead(j) > x THEN
			x = armylead(j)
			armyname$(0) = armyname$(j)
			armylead(0) = armylead(j)
			best = j
		END IF

		armysize(0) = armysize(0) + armysize(j)
		IF armysize(0) < 1 GOTO dork1
		pct! = (armysize(j) / armysize(0))
		spin = spin + 1
		armyexper(0) = (1 - pct!) * armyexper(0) + pct! * armyexper(j)
		CALL clearBottom: PRINT armyname$(j); " is combining his "; : CALL strong(j): PRINT " forces"; : CALL TICK(turbo!)
		supply(0) = supply(0) + supply(j)
		IF supply(0) > 10 THEN supply(0) = 10
		armysize(j) = 0: armyloc(j) = 0: armyexper(j) = 0: armymove(j) = 0
		lname$(j) = armyname$(j)
		armylead(j) = 0: supply(j) = 0: armyname$(j) = ""
dork1:
		NEXT j

    ' Finalize combined army
		CALL clearBottom
		IF who <> side AND spin = 0 THEN EXIT SUB
		IF spin = 0 THEN
				PRINT "No valid armies to combine at this time in "; city$(target);
				TICK turbo!
				EXIT SUB
		END IF
		armysize(best) = armysize(0): armylead(best) = armylead(0)
		armyexper(best) = armyexper(0): supply(best) = supply(0)
		armyloc(best) = target
		armyname$(best) = armyname$(0)
		lname$(best) = ""
		IF spin > 1 THEN
		PRINT "New army "; best; " of "; : CALL strong(best): PRINT " is commanded by "; armyname$(best);
		armymove(best) = -1
		ELSE
		PRINT "Only 1 eligible army -- cannot combine at this time";
		END IF
		IF who = side THEN CALL TICK(turbo!)
		IF noise > 0 THEN SOUND 4000, .7
	       
    ' Update city and army status
		CALL showcity
		CALL placearmy(best)
		CALL icon(target, 0, 6)
		occupied(target) = best
		CALL stax(who)
nocity2:
END SUB

SUB cutoff (who, target, a)
a = 0
FOR j = 1 TO 6
y = matrix(target, j)
IF y > 0 AND cityp(y) = who THEN a = a + 1
NEXT j
END SUB

SUB filer (switch)
SELECT CASE switch
	CASE 1
	OPEN "I", 1, "cwslead.dat"
	FOR i = 1 TO 40: INPUT #1, lname$(i), rating(i): NEXT i
	CLOSE #1
	OPEN "I", 1, "cws.ini"
	FOR i = 0 TO 2: INPUT #1, force$(i): NEXT i
	FOR i = 1 TO 12: INPUT #1, month$(i): NEXT i
	INPUT #1, month, year
'               set end game conditions
	FOR i = 1 TO 6: INPUT #1, vicflag(i): NEXT i
	vicflag(3) = .4 * vicflag(3)
	INPUT #1, a             ' number of Yankee armies
FOR i = 1 TO a
	INPUT #1, armyloc(i), armysize(i), armyexper(i), supply(i): occupied(armyloc(i)) = i: armyname$(i) = lname$(i): armylead(i) = rating(i): lname$(i) = ""
NEXT i
	INPUT #1, a             ' number of Rebel armies
FOR i = 21 TO 20 + a
	INPUT #1, armyloc(i), armysize(i), armyexper(i), supply(i)
	occupied(armyloc(i)) = i: armyname$(i) = lname$(i): armylead(i) = rating(i): lname$(i) = ""
NEXT i
FOR i = 1 TO 2: INPUT #1, cash(i): NEXT i
	INPUT #1, ATKFAC, DEFAC, TCR
	INPUT #1, fleet$(1), navyloc(1), fleet$(2), navyloc(2)
	FOR k = 1 TO 2: navysize(k) = LEN(fleet$(k)): NEXT k
	INPUT #1, capcity(1), capcity(2)

FOR i = 1 TO 8: INPUT #1, starx(i), stary(i): NEXT i  ' star locations on flag
	CLOSE #1
	OPEN "I", 1, "cws.cfg"
	INPUT #1, side, graf, noise, difficult, player, turbo!, randbal, train(1), train(2), jancam, realism, batwon(1), batwon(2), casualty&(1), casualty&(2), history, bold
	CLOSE #1

	CASE 2
	IF _FILEEXISTS("*.sav") THEN choose = -1: EXIT SUB
	menuText$(0) = "Load"
	size = 0
	FOR k = 1 TO 9
		t$ = "cws" + LTRIM$(STR$(k)) + ".sav"
		IF _FILEEXISTS(t$) THEN
			size = size + 1: menuText$(size) = t$: array(size) = k
		END IF
	NEXT k
	CALL bubbleSortMenuText((size))
	tlx = 67: tly = 14 - .5 * size
	CALL menu(0)
	CALL clearRight
	IF choose < 1 THEN EXIT SUB
	OPEN "I", 1, "cws" + LTRIM$(STR$(array(choose))) + ".sav"
	COLOR 11: CALL clearBottom: PRINT "Loading";
	INPUT #1, month, year, usadv, a
	FOR i = 1 TO 40: INPUT #1, armyname$(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	IF armyloc(i) > 0 THEN
		IF armyname$(i) = lname$(i) THEN
			lname$(i) = ""
		ELSE
			who = 1: IF i > 20 THEN who = 2
			CALL starfin(star, fin, who)
			FOR k = star TO fin
			IF armyname$(i) = lname$(k) THEN lname$(k) = "": EXIT FOR
			NEXT k
		END IF
	END IF
	NEXT i
	FOR i = 1 TO 40: INPUT #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: INPUT #1, cash(i), control(i), income(i), victory(i), capcity(i)
	INPUT #1, fleet$(i), navyloc(i), navymove(i), rr(i), tracks(i)
	navysize(i) = LEN(fleet$(i))
	NEXT i
       
	CLOSE #1
	OPEN "I", 1, "cws.cfg"
	INPUT #1, myside, graf, noise, difficult, player, turbo!, randbal, train(1), train(2), jancam, realism, batwon(1), batwon(2), casualty&(1), casualty&(2), history, bold
	CLOSE #1
	SCREEN 12: CLS
	CLOSE #1: CALL usa: CALL clearBottom
	FOR k = 1 TO 2
	IF rr(k) > 0 THEN CALL tinytrain(k, 1)
	NEXT k
	side = a

	CASE 3
	menuText$(0) = "Save Game"
	FOR k = 1 TO 9
	menuText$(k) = "cws" + LTRIM$(STR$(k)) + ".sav"
	IF _FILEEXISTS(menuText$(k))) THEN menuText$(k) = menuText$(k) + " û"
	NEXT k
	tlx = 67: size = 9
	CALL menu(0)
	IF choose < 1 THEN clearRight: EXIT SUB
	COLOR 11: CALL clearBottom: PRINT "Saving";

	OPEN "O", 1, "cws" + LTRIM$(STR$(choose)) + ".sav"
	WRITE #1, month, year, usadv, side
	FOR i = 1 TO 40: WRITE #1, armyname$(i), armysize(i), armylead(i), armyloc(i), armyexper(i), supply(i), armymove(i)
	NEXT i
	FOR i = 1 TO 40: WRITE #1, occupied(i), cityp(i), fort(i): PRINT "."; : NEXT i
	FOR i = 1 TO 2: WRITE #1, cash(i), control(i), income(i), victory(i), capcity(i)
	WRITE #1, fleet$(i), navyloc(i), navymove(i), rr(i), tracks(i)
	NEXT i
	CLOSE #1
       
	myside = side
	IF myside < 1 OR myside > 2 THEN myside = 1
	OPEN "O", 1, "cws.cfg"
	WRITE #1, myside, graf, noise, difficult, player, turbo!, randbal, train(1), train(2), jancam, realism, batwon(1), batwon(2), casualty&(1), casualty&(2), history, bold
	CLOSE #1
	CLS : CALL usa
END SELECT
END SUB

SUB flashcity (which)
FOR c = 1 TO 15 STEP 2
CIRCLE (cityx(which), cityy(which)), 4, 0
CIRCLE (cityx(which), cityy(which)), 3, c
PAINT (cityx(which), cityy(which)), c, c
CALL TICK(.1)
NEXT c
c = 9: IF cityp(which) = 2 THEN c = 7
IF cityp(which) = 0 THEN c = 12
CIRCLE (cityx(which), cityy(which)), 4, 0
CIRCLE (cityx(which), cityy(which)), 3, c
PAINT (cityx(which), cityy(which)), c, c
END SUB

SUB fortify (target)
	target = 0: hilite = 11
	tlx = 67: tly = 2
	who = side
	CALL starfin(star, fin, who)
	size = 0
	FOR i = star TO fin
	IF armyloc(i) > 0 AND fort(armyloc(i)) < 2 THEN
		size = size + 1
		menuText$(size) = city$(armyloc(i))
		array(size) = armyloc(i)
	END IF
	NEXT i
	IF size = 0 THEN CALL clearBottom: COLOR 11: PRINT "No cities eligible to fortify"; : EXIT SUB
	CALL bubbleSortMenuText(size)
	menuText$(0) = "Fortify"
		choose = 31
		CALL menu(9): CALL clearRight
		IF choose < 0 GOTO nocity
		target = array(choose): CALL occupy(target): x = occupied(target): IF x < 0 GOTO nocity
		IF fort(target) > 1 THEN CALL clearBottom: PRINT city$(target); " at MAXIMUM fortification level of 2"; : CALL TICK(4): GOTO nocity
		cost = 200
		IF cash(side) < cost THEN CALL clearBottom: PRINT "Fortifications for "; city$(target); " cost "; cost; " and you only have "; cash(side); : CALL TICK(4): GOTO nocity
		COLOR 3
		fort(target) = fort(target) + 1
		cash(side) = cash(side) - cost
		CALL clearBottom: PRINT city$(target); " fortifications increased to "; fort(target);
		CALL icon(target, 0, 6)
		CALL showcity
		IF armymove(x) > 0 THEN CALL icon(armyloc(x), armymove(x), 5)
		armymove(x) = -1
		CALL placearmy(x)
		CALL stax(who)
nocity:
END SUB

SUB icon (from, dest, kind)
IF from < 1 OR from > 40 GOTO noshow
IF dest < 0 GOTO noshow
IF from = 999 GOTO noshow
x = cityx(from) - 12: y = cityy(from) - 11
x1 = cityx(dest): y1 = cityy(dest)
SELECT CASE kind
	CASE 1
	LINE (x, y)-(x1, y1), 15, , &HF0F0
       
	CASE 2
	FOR i = 6 TO 8
	LINE (x - i, y - i + 3)-(x + i, y + i - 3), 14, B
	NEXT i
	CALL TICK(.1)
       
	CASE 3
	x = cityx(from): y = cityy(from)
	CALL snapshot(x, y, 0)
	FOR j = 1 TO 3
	FOR i = 4 TO 10 STEP 1
	CIRCLE (x, y), i, 4
	PAINT (x, y), 14, 4
	IF noise > 0 THEN SOUND 37 + 50 * RND, .03
	NEXT i
	CALL TICK(.1)
	CALL snapshot(x, y, 1)
	NEXT j
       
	CASE 4
	IF occupied(from) = 0 THEN LINE (x - 8, y - 6)-(x + 10, y + 8), 2, BF
	IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0
	IF from = 27 OR from = 28 THEN CALL touchup

	CASE 5
	IF x1 + y1 > 0 THEN LINE (x, y)-(x1, y1), 2, , &HF0F0

	CASE 6
	x = cityx(from): y = cityy(from)
	CALL snapshot(x, y, 0)
	LINE (x - 9, y - 9)-(x + 9, y + 9), 15, B
	LINE (x - 10, y - 10)-(x + 10, y + 10), 15, B
	IF noise > 0 THEN SOUND 3999, .3
	CALL TICK(turbo! - .5)
	CALL snapshot(x, y, 1)
	CASE 7          ' draw white box
	x = cityx(from) - 12: y = cityy(from) - 11
	GET (x - 8, y - 8)-(x + 8, y + 8), image
	LINE (x - 7, y - 7)-(x + 7, y + 7), 15, B
	LINE (x - 8, y - 6)-(x + 8, y + 6), 15, B
	     CASE 8     ' replace old image
	x = cityx(from) - 12: y = cityy(from) - 11
	IF x > 0 THEN PUT (x - 8, y - 8), image, PSET
       
	CASE 9          ' draw arrow pointer
	x = cityx(from) - 12: y = cityy(from) - 11
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
noshow:
END SUB

SUB iterate
'---------------------------------------------------------------------------
FOR i = 1 TO 40: IF armyloc(i) > 0 THEN CALL placearmy(i)
NEXT i
'---------------------------------------------------------------------------
month = month + 2
IF month > 12 THEN month = 1: year = year + 1
'---------------------------------------------------------------------------
s = 1
FOR i = 1 TO 40: IF armyloc(i) < 1 GOTO rip
IF i > 20 THEN s = 2
IF cash(s) >= .2 * armysize(i) THEN
	a = 1: IF realism > 0 THEN CALL cutoff(s, armyloc(i), a)
	IF a > 0 THEN
		supply(i) = supply(i) + 1
		cash(s) = cash(s) - .2 * armysize(i)
	END IF
END IF
IF (month < 7 OR month > 10) AND matrix(armyloc(i), 7) < 99 THEN supply(i) = supply(i) - 1
IF matrix(armyloc(i), 7) = 99 AND navyloc(3 - s) = armyloc(i) THEN supply(i) = supply(i) - 1: CALL clearBottom: PRINT armyname$(i); " is blockaded"; : CALL TICK(turbo!)
COLOR 13
IF supply(i) < 1 THEN
	supply(i) = 0
	CALL clearBottom
	PRINT armyname$(i); " is out of supplies";
	CALL placearmy(i)
	CALL TICK(turbo!)
	IF RND > .8 AND armysize(i) > 50 THEN armysize(i) = .9 * armysize(i)
END IF
rip:
NEXT i
FOR k = 1 TO 2: CALL stax(k): NEXT k
y = 0: FOR i = 1 TO 20: y = y + .1 * armysize(i): NEXT i
x = 0: FOR i = 21 TO 40: x = x + .1 * armysize(i): NEXT i
IF side = 2 AND x > 0 THEN aggress! = y / x ELSE aggress! = 1
IF side = 1 AND y > 0 THEN aggress! = x / y ELSE IF side = 1 THEN aggress! = 1
END SUB

SUB movefrom (index, target)
	colour = 3: tlx = 67: tly = 5: index = 0: size = 0: target = 0
	who = side: CALL starfin(star, fin, who)
	FOR i = star TO fin
	IF armyloc(i) > 0 AND armymove(i) = 0 THEN size = size + 1: menuText$(size) = city$(armyloc(i)): array(size) = armyloc(i)
	NEXT i
	IF size = 0 THEN index = -1: GOTO notarg
	menuText$(0) = "From"
	CALL bubbleSortMenuText(size)
movopt:
	tlx = 67: tly = 5
		hilite = 15: CALL menu(1): CALL clearRight
		IF choose < 0 THEN target = 0: GOTO notarg
		target = array(choose)

		size = 0
		FOR i = star TO fin
		IF armyloc(i) = target AND armymove(i) = 0 THEN index = i: size = size + 1: menuText$(size) = "Army" + STR$(i): array(size) = i
		NEXT i
		IF size = 1 GOTO notarg
		menuText$(0) = "Which"
		CALL bubbleSortMenuText(size)
		tlx = 67: tly = 15: CALL menu(4): CALL clearRight
		IF choose < 0 THEN index = 0: GOTO notarg
		index = array(choose)
notarg:
END SUB

SUB navy (who, chx)
DIM hit(2)
IF chx > 0 THEN
	IF navyloc(who) < 1 THEN
		chx = 1
	ELSE
		IF commerce = 3 - who AND raider > 0 THEN chx = 4
		IF grudge > 0 THEN chx = 3
	END IF
END IF
COLOR 11
ahoy:
cost = 100: cityp(0) = who
IF chx = 0 THEN CALL clearBottom: PRINT "Funds available "; cash(who);
IF chx = 1 THEN
	IF cash(who) < cost THEN EXIT SUB
	IF navysize(who) > 9 THEN EXIT SUB
END IF
menuText$(0) = "Ships"
menuText$(1) = "Build"
IF navyloc(who) <> 99 THEN
IF cash(who) < cost OR navysize(who) > 9 OR cityp(navyloc(who)) <> who THEN menuText$(1) = "-": choose = 23
END IF
menuText$(2) = "Attack"
IF navyloc(who) <> 99 THEN
IF cityp(navyloc(who)) <> 3 - who THEN menuText$(2) = "-": choose = 22
ELSE
menuText$(1) = "-": menuText$(2) = "-": choose = 24
END IF
menuText$(3) = "Sail": IF navyloc(who) < 1 THEN menuText$(3) = "-": IF chx = 3 THEN chx = 1
menuText$(4) = "Raid": IF navysize(who) < 1 OR commerce = who THEN menuText$(4) = "-"
tlx = 67: tly = 12: size = 4
IF navyloc(who) <> 99 THEN
IF who = 1 AND navysize(who) > 1 AND cityp(navyloc(who)) = 0 THEN size = 5: menuText$(5) = "Invasion": CALL void(navyloc(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
IF realism = 0 AND who = 2 AND navysize(who) > 1 AND cityp(navyloc(who)) = 0 THEN size = 5: menuText$(5) = "Invasion": CALL void(navyloc(1), defend): IF chx > 0 AND defend < 100 THEN chx = 5
END IF

IF chx > 0 THEN choose = chx: GOTO anchor
IF nflag > 0 AND choose <> 1 THEN EXIT SUB
CALL menu(0): CALL clearRight
anchor:
'---------------------------------------------------------------------------
SELECT CASE choose
'---------------------------------------------------------------------------
'                               Build Ship
'---------------------------------------------------------------------------
	CASE 1
	IF cash(who) < cost OR navyloc(who) = 99 GOTO ahoy
	IF chx = 1 AND navysize(who) > 9 THEN EXIT SUB
	IF chx = 0 AND navysize(who) > 9 THEN GOTO ahoy

	IF chx = 0 AND navyloc(who) > 0 THEN
		IF cityp(navyloc(who)) <> who GOTO ahoy
		IF matrix(navyloc(who), 7) < 99 GOTO ahoy
	END IF
	IF chx = 1 AND RND < .07 * navysize(who) THEN EXIT SUB
	a$ = "W"

	IF realism > 0 AND ((year < 1862) OR (year = 1862 AND month < 3)) GOTO noiron
	IF cash(who) >= 2 * cost THEN
		tlx = 67: tly = 12: colour = 9
		IF who = side THEN
			menuText$(0) = "Type"
			menuText$(1) = "Wooden"
			menuText$(2) = "Ironclad"
			size = 2
			CALL menu(0)
			CALL clearRight
			IF choose < 1 GOTO ahoy
			IF choose = 2 THEN a$ = "I": cost = 2 * cost
		ELSE
			a$ = "I"
		END IF
	END IF

noiron:
	navysize(who) = navysize(who) + 1
	IF a$ = "W" THEN
		fleet$(who) = fleet$(who) + a$: a = 1
	ELSE
		fleet$(who) = a$ + fleet$(who): a = 2
	END IF
	IF navysize(who) > 1 GOTO add2ship
ships:
	menuText$(0) = "Port": size = 0: tlx = 67: tly = 12
	FOR i = 1 TO 40: IF matrix(i, 7) = 99 AND cityp(i) = who AND navyloc(3 - who) <> i THEN size = size + 1: menuText$(size) = city$(i): array(size) = i
	NEXT i
	IF chx = 1 THEN choose = 1 + INT(size * RND)
	IF size < 1 THEN
		navysize(who) = 0: fleet$(who) = ""
		IF chx = 0 THEN CALL clearBottom: PRINT "NO SHIPYARDS AVAILABLE !"; : EXIT SUB
		IF chx = 1 THEN EXIT SUB
	END IF
	IF chx = 0 THEN CALL menu(9): CALL clearRight

	IF choose < 1 GOTO ships
	navyloc(who) = array(choose)
	cash(who) = cash(who) - cost: navysize(who) = 1
	x = cityx(array(choose)) + 25: y = cityy(array(choose)) + 25: CALL drawShips
	CALL clearBottom: COLOR 11: PRINT force$(who); " is building NEW fleet in "; city$(array(choose));
	PSET (400, 465), 0: CALL shipicon(who, a)
	IF noise > 0 THEN SOUND 3000, 1
	CALL TICK(turbo!)
	GOTO ahoy
add2ship:
	cash(who) = cash(who) - cost
	CALL clearBottom: PRINT force$(who); " navy increased to "; navysize(who);
	PSET (400, 465), 0: CALL shipicon(who, a)
	CALL drawShips
	IF noise > 0 THEN SOUND 3000, 1
	CALL TICK(turbo!)
'---------------------------------------------------------------------------
'                               Attack City
'---------------------------------------------------------------------------
	CASE 2
	IF navyloc(who) = 99 GOTO ahoy
	IF chx = 2 AND cityp(navyloc(who)) = who THEN EXIT SUB
	IF chx = 2 AND occupied(navyloc(who)) > 0 AND RND > .5 THEN chx = 3: GOTO anchor
	IF chx = 2 AND cityp(navyloc(who)) = 0 THEN chx = 3: GOTO ahoy
	IF navyloc(who) < 1 THEN EXIT SUB
	IF who = side THEN nflag = 1
	IF cityp(navyloc(who)) <> 3 - who GOTO ahoy
	CALL clearBottom: COLOR 12: PRINT force$(who); " fleet bombards "; city$(navyloc(who));
	CALL icon(navyloc(who), 0, 3)
	      
	target = navyloc(who): index = occupied(target): IF index = 0 GOTO deserted
	pct! = .005 * navysize(who) + .02 * RND: killd = armysize(index) * pct!: IF killd < 1 THEN killd = 1
	CALL clearBottom: PRINT armyname$(index); " suffered "; 100 * killd; " casualties";
	x = .5 * navysize(who) + 1: IF x > supply(index) THEN x = supply(index)
	supply(index) = supply(index) - x
	CALL TICK(turbo!)
	armysize(index) = armysize(index) - killd: IF armysize(index) < 1 THEN armysize(index) = 1
	EXIT SUB
deserted:
	IF fort(target) = 0 GOTO blast
	IF RND < .7 + .03 * (navysize(who) - fort(target)) GOTO hurt1
	CALL sinkShip(who)
	CALL clearBottom
	PRINT force$(cityp(target)); " shore battery sunk an attacking ship!"; navysize(who); "ship(s) left! ";
	IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5
	CALL TICK(turbo!)
	IF navysize(who) < 1 THEN
		navyloc(who) = 0: fleet$(who) = "": GOSUB box2
		LOCATE 12, 27: PRINT force$(who); " fleet eliminated"
		CALL TICK(9)
		victory(3 - who) = victory(3 - who) + 5
		IF who = side THEN grudge = 0
		GOTO sail3
	END IF
	GOTO deserted
hurt1:
	CALL clearBottom: PRINT city$(target); " fortifications damaged";
	fort(target) = fort(target) - 1: x = cityx(target): y = cityy(target): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
	CALL showcity
	CALL TICK(turbo!)
	EXIT SUB
blast:
	IF RND > .25 + .07 * navysize(who) THEN CALL clearBottom: PRINT "Citizens of "; city$(target); " stand firm against the attack"; : CALL TICK(turbo!): EXIT SUB
	IF navyloc(who) = capcity(3 - who) THEN CALL clearBottom: PRINT "The CAPITAL steadfastly stands loyal"; : CALL TICK(turbo!): EXIT SUB
	cityp(navyloc(who)) = 0
	CALL clearBottom: PRINT city$(navyloc(who)); " is now  NEUTRAL";
	CALL showcity
	victory(who) = victory(who) + cityv(navyloc(who))
	EXIT SUB
'---------------------------------------------------------------------------
'                               Sail
'---------------------------------------------------------------------------
	CASE 3
	navysize(who) = LEN(fleet$(who))
	IF navysize(who) < 1 AND chx > 0 THEN EXIT SUB
	IF navyloc(who) < 1 OR navysize(who) < 1 THEN CALL clearBottom: PRINT "No ships remain"; : TICK 1: GOTO ahoy

	size = 0
	FOR i = 1 TO 40: IF matrix(i, 7) > 90 AND navyloc(who) <> i THEN size = size + 1: menuText$(size) = city$(i): array(size) = i
	NEXT i
	IF chx = 3 THEN
		IF size = 0 THEN EXIT SUB
		IF grudge > 0 THEN choose = 1: array(1) = navyloc(3 - who): GOTO admiral
		GOSUB nest: IF choose > 0 GOTO admiral ELSE EXIT SUB
	END IF
	COLOR 11: LOCATE 11, 68
	IF navyloc(who) < 41 THEN
		PRINT city$(navyloc(who))
	ELSE
		PRINT "Raiding"
	END IF
	menuText$(0) = "To"
	colour = 3: tlx = 67: tly = 12
      
	CALL menu(9): CALL clearRight: IF choose < 1 THEN EXIT SUB
admiral:
	IF array(choose) = navyloc(who) THEN EXIT SUB
	IF array(choose) < 1 THEN EXIT SUB
	IF navysize(who) < 1 GOTO ships
	IF who = side THEN nflag = 1
	GOSUB box2
	LOCATE 10, 25: PRINT force$(who); " fleet of"; navysize(who); "ship(s) is sailing"
	LOCATE 11, 25: PRINT "From ";
	IF navyloc(who) < 41 THEN
		PRINT city$(navyloc(who));
	ELSE
		PRINT "Raiding";
	END IF
	PRINT " to ";
	IF array(choose) <> 99 THEN
		PRINT city$(array(choose));
	ELSE
		PRINT "Raid Commerce";
	END IF

	FOR i = 1 TO navysize(who)
		PSET (120 + 41 * i, 210), 0
		CALL shiptype(who, i)
	NEXT i
	IF graf > 2 THEN
		a = ASC(LEFT$(fleet$(who), 1))
		SELECT CASE a
			CASE 73
				CALL ironclad
			CASE 87
				CALL schooner
		END SELECT
		TICK 2 * turbo!
	ELSE
		TICK turbo!
	END IF
	navyloc(who) = array(choose)
	IF navyloc(1) = navyloc(2) GOTO pirate
	GOTO sail3
'---------------------------------------------------------------------------
'                               Raid Commerce
'---------------------------------------------------------------------------
	CASE 4
	navysize(who) = LEN(fleet$(who))
	IF navysize(who) < 1 AND chx > 0 THEN EXIT SUB
	IF navysize(who) < 1 OR commerce = who GOTO ahoy

	IF who = side THEN nflag = 1
	GOSUB box2
	LOCATE 10, 25: PRINT force$(who); " fleet of"; navysize(who); "ship(s) is sailing"
	LOCATE 11, 25: PRINT "to RAID "; force$(3 - who); " COMMERCE !"

	FOR i = 1 TO navysize(who)
		PSET (120 + 41 * i, 210), 0
		CALL shiptype(who, i)
	NEXT i
	IF graf > 2 THEN
		a = ASC(LEFT$(fleet$(who), 1))
		SELECT CASE a
			CASE 73
				CALL ironclad
			CASE 87
				CALL schooner
		END SELECT
		TICK 2 * turbo!
	ELSE
		TICK turbo!
	END IF
	navyloc(who) = 99: commerce = who
	IF navyloc(1) = navyloc(2) GOTO pirate
	CLS : CALL usa
	EXIT SUB
'---------------------------------------------------------------------------
'                               Invasion
'---------------------------------------------------------------------------
	CASE 5
	CALL commander((who), empty)
	IF chx > 0 AND empty = 0 THEN chx = 3: GOTO anchor
	x = 35
	CALL sinkShip(who)
	c = navyloc(who): CALL newarmy((who), empty, c)
	cash(who) = cash(who) + 100     'compensate for cost of recruiting new army
	CALL capture(empty, c, who, 0)
	armysize(empty) = x
	IF who = side THEN nflag = 1
	EXIT SUB
'---------------------------------------------------------------------------
'                               Exit
'---------------------------------------------------------------------------
	CASE ELSE
	EXIT SUB
END SELECT
GOTO ahoy
'---------------------------------------------------------------------------
'                               Ship vs. Ship
'---------------------------------------------------------------------------
pirate:
	CLS : LOCATE 1, 30: COLOR 11: PRINT "NAVAL COMBAT"
	FOR k = 1 TO 2
	hit(k) = 10
	IF RIGHT$(fleet$(k), 1) = "I" THEN hit(k) = 20
	NEXT k
cannon:
	LOCATE 9, 1: PRINT SPACE$(79)
	LOCATE 15, 1: PRINT SPACE$(79)
	x = 10: y = 100
	COLOR 9: LOCATE 5, 25: PRINT "UNION"; navysize(1); "ship(s)"
	GOSUB boxes
	COLOR 1
	FOR i = 1 TO navysize(1)
	x = x + 50: PSET (x, y)
	CALL shiptype(1, i)
	NEXT i
	COLOR 11: LOCATE 11, 22: PRINT "CONFEDERATES "; navysize(2); "ship(s)"
	LINE (10, 180)-(530, 210), 1, BF
	LINE (10, 180)-(530, 210), 11, B
	x = 10: y = 200
	COLOR 1
	FOR i = 1 TO navysize(2)
	x = x + 50: PSET (x, y)
	CALL shiptype(2, i)
	NEXT i
	COLOR 11
wave:
	menuText$(0) = "Options"
	menuText$(1) = "Attack"
	menuText$(2) = "Retreat"
	IF chx > 0 THEN choose = 1: GOTO powder
      
	size = 2: colour = 3: hilite = 14: tlx = 50: tly = 18: CALL menu(0)
powder:
	SELECT CASE choose
	 CASE 1
firemore:
	 IF noise > 0 THEN SOUND 77, .5: SOUND 59, .5: CALL TICK(.1)
	 pct! = 0: a$ = RIGHT$(fleet$(who), 1)
	 IF a$ <> RIGHT$(fleet$(3 - who), 1) THEN
		IF a$ = "I" THEN pct! = .1 ELSE pct! = -.1
	 END IF
	 IF RND <= .5 + pct! GOTO hitem ELSE GOTO hitme1
	 GOTO firemore
hitem:
	 hit(3 - who) = hit(3 - who) - 1: GOSUB showhit: IF hit(3 - who) > 0 GOTO firemore
	 x = 10 + 50 * navysize(3 - who)
	 y = 90: IF who = 1 THEN y = 190
	 GOSUB xout
	 LOCATE 17, 5: PRINT force$(3 - who); " ship SUNK!": CALL TICK(turbo! + 1): GOSUB clr1
	 CALL sinkShip(3 - who)
	 IF navysize(3 - who) < 1 THEN
		LOCATE 19, 5: COLOR 12
		PRINT force$(3 - who); " fleet DEFEATED"
		CALL TICK(turbo!)
		navyloc(3 - who) = 0: fleet$(3 - who) = ""
		victory(3 - who) = victory(3 - who) + 10
		IF who = side THEN grudge = 1 ELSE grudge = 0
		GOTO sail3
	 END IF
	 hit(3 - who) = 10
	 IF RIGHT$(fleet$(3 - who), 1) = "I" THEN hit(3 - who) = 20
	 GOTO cannon
hitme1:
	 hit(who) = hit(who) - 1: GOSUB showhit: IF hit(who) > 0 GOTO firemore
	 x = 10 + 50 * navysize(who)
	 y = 190: IF who = 1 THEN y = 90
	 GOSUB xout
	 LOCATE 17, 5: PRINT "One of the "; force$(who); " ships was SUNK!": CALL TICK(turbo!): GOSUB clr1
	 CALL sinkShip(who)
	 IF navysize(who) < 1 THEN
		LOCATE 19, 5: COLOR 12
		PRINT "Attacking "; force$(who); " fleet has been ELIMINATED !"
		CALL TICK(turbo!)
		navyloc(who) = 0: fleet$(who) = ""
		victory(who) = victory(who) + 10
		IF who <> side THEN grudge = 1 ELSE grudge = 0
		GOTO sail3
	 END IF
	 hit(who) = 10
	 IF RIGHT$(fleet$(who), 1) = "I" THEN hit(who) = 20
	 GOTO cannon

	 CASE 2
	 target = 0
	 FOR i = 1 TO 40
	 IF cityp(i) = who THEN IF i <> navyloc(who) AND matrix(i, 7) = 99 THEN target = i: IF RND > .3 GOTO found1
	 NEXT i
found1:
	 CALL clearBottom: COLOR 11: PRINT force$(who); " is retreating to "; city$(target); : CALL TICK(turbo!)
	 navyloc(who) = target
	 GOTO sail3
	 CASE ELSE
	 GOTO wave
	 END SELECT
	 GOTO pirate
'---------------------------------------------------------------------------
'                               Subs
'---------------------------------------------------------------------------
showhit:
	 LOCATE 9, 6 * navysize(1): PRINT hit(1); " ";
	 LOCATE 15, 6 * navysize(2): PRINT hit(2); " ";
	 IF noise = 0 THEN TICK .1 * turbo!
	 RETURN
clr1:
	LOCATE 17, 1: PRINT SPACE$(60): RETURN
nest:
	best = 0: x = 0
	FOR i = 1 TO size
	target = array(i)
	IF cityp(target) = 0 GOTO neutral

	IF target = navyloc(3 - who) THEN IF navysize(who) >= navysize(3 - who) AND RND > .1 THEN choose = i: RETURN
	IF cityp(target) <> who THEN
		best = i: x = x + 1
		IF RND > .8 THEN choose = best: RETURN
	END IF
neutral:
	NEXT i
	IF best = 0 THEN
		choose = 1 + INT(RND * size)
	ELSE
		choose = best
	END IF

	IF who = 2 AND navyloc(2) = 30 THEN IF RND > .5 THEN choose = 30: RETURN
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
	commerce = 0
	FOR k = 1 TO 2
	IF navyloc(k) = 99 THEN commerce = k
	NEXT k
	CLS : CALL usa
END SUB

SUB newarmy (who, empty, target)
	supply(empty) = 3 + 5 * RND: IF who = 1 THEN supply(empty) = supply(empty) + 2
	armyexper(empty) = 1: IF who = 2 THEN armyexper(empty) = 2
	armylead(empty) = rating(empty)
	armyname$(empty) = lname$(empty): lname$(empty) = ""
	COLOR 12: CALL clearBottom: PRINT "Placing NEW army "; empty; armyname$(empty); " in "; city$(target);

	x = 70: IF realism > 0 THEN x = 3 * cityv(target) + 33
	CALL cutoff(who, target, a): IF a < 1 THEN x = x \ 3
	occupied(target) = empty: armysize(empty) = x
	PRINT " Size = "; : CALL strong(empty)
	cash(who) = cash(who) - 100: IF noise > 0 THEN SOUND 2222, .5
	armyloc(empty) = target: CALL placearmy(empty)
	CALL TICK(turbo! - .5)
	armymove(empty) = -1
END SUB

SUB newcity (index)
		menuText$(1) = "  "
		menuText$(3) = "  "
		size = 3: a$ = city$(index)
morecap:
		tlx = 68: tly = 15: colour = 3: choose = 23
		menuText$(2) = city$(index)
		CALL menu(3): CALL clearRight
	       SELECT CASE choose
		CASE IS = -27
		index = 0: EXIT SUB
		CASE IS < 1
		a$ = CHR$(ABS(choose))
		x = 0
		FOR k = 1 TO 40
		IF LEFT$(city$(k), 1) = a$ THEN
			y = index: index = k
spin2:
			IF cityp(index) = side GOTO morecap
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
		IF cityp(index) <> side GOTO minus1 ELSE GOTO morecap
		CASE 2
		GOTO fnew
		CASE 3
plus1:
		index = index + 1: IF index > 40 THEN index = 1
		IF cityp(index) <> side GOTO plus1 ELSE GOTO morecap
		CASE ELSE
		index = 0
		END SELECT
fnew:
END SUB

' The normal subroutine generates a normally distributed random number 
' based on the given mean (xbar) and variance. It uses the 
' Box-Muller transform to approximate a normal distribution.
SUB generateNormalRandom (xbar, variance, result)
    pct! = 0
    FOR k = 1 TO 12: pct! = pct! + RND: NEXT k
    pct! = pct! - 5.5
    result = xbar + pct! * SQR(variance)
END SUB

SUB placearmy (which)
who = 1: IF which > 20 THEN who = 2
x = cityx(armyloc(which)) - 12
y = cityy(armyloc(which)) - 11
CALL drawArmy(x, y, who)
IF supply(which) < 1 THEN
	x = x - 3: y = y + 4
	PSET (x, y), 13: DRAW "C11S8"
	DRAW font$(19)
	DRAW "S4"
END IF
END SUB

SUB railroad (who)
SELECT CASE rr(who)
	CASE 0
	IF who = side GOTO human
	CALL starfin(star, fin, who): max = 32767
	index = 0
	FOR i = star TO fin: IF armyloc(i) = 0 OR armymove(i) <> 0 GOTO puter
	x = 0: FOR j = 1 TO 6: from = matrix(armyloc(i), j): IF from > 0 AND cityp(from) <> who THEN x = x + 1
	NEXT j
	IF occupied(capcity(who)) > 0 AND x > 1 GOTO puter
	CALL void(armyloc(i), defend)
	IF vicflag(5) > 0 AND occupied(capcity(who)) = 0 THEN IF defend > max THEN defend = max - 1
	IF defend < max THEN target = armyloc(i): GOSUB route: IF x > 1 THEN max = defend: index = i
puter:  NEXT i
	IF index = 0 OR max > .3 * armysize(index) GOTO toot
	CALL traincapacity(who, limit)
	IF armysize(index) > limit THEN GOTO toot
	from = armyloc(index)
	x1 = 0: FOR i = 1 TO 40: IF cityp(i) <> who GOTO puted
	CALL void(i, defend): IF defend = 0 OR defend > 3 * armysize(index) GOTO puted
	IF occupied(i) > 0 GOTO puted
	target = i
	GOSUB route: IF x = 0 GOTO puted
	IF side = 1 AND cityy(i) < cityy(from) THEN x1 = i
	IF side = 2 AND cityy(i) > cityy(from) THEN x1 = i
	IF fort(i) > 0 AND occupied(i) = 0 THEN x1 = i: EXIT FOR
puted:  NEXT i
	IF vicflag(5) > 0 AND occupied(capcity(who)) = 0 THEN
		GOSUB route
		IF x > 0 THEN
			CALL void(capcity(who), defend)
			IF defend > 0 THEN x1 = capcity(who)
		END IF
	END IF
	IF x1 > 0 GOTO haul ELSE GOTO toot
human:
	CALL movefrom(index, a): IF a < 1 OR index < 1 THEN COLOR 11: CALL clearBottom: PRINT "Railroad move not allowed"; : GOTO toot
	x = 1: IF index > 20 THEN x = 2
	CALL traincapacity(who, limit)
	IF armysize(index) > limit THEN CALL clearBottom: PRINT "Too many troops for railroad capacity"; : GOTO toot
	
	target = armyloc(index): GOSUB route: IF x > 1 GOTO aboard
	CALL clearBottom: PRINT "Track from "; city$(target); " is blocked"; : GOTO toot
aboard:
	CALL clearBottom: PRINT "Select destination for "; armyname$(index); " from "; city$(target);
	menuText$(0) = "To": from = target: x1 = from: IF from = 0 GOTO toot
	CALL newcity(x1): IF x1 = from OR x1 = 0 GOTO toot

	target = x1: GOSUB route: IF x > 1 GOTO haul
	CALL clearBottom: PRINT armyname$(index); "'s train cannot go to "; city$(x1); " - select another city"; : CALL TICK(9)
	GOTO aboard
haul:
	COLOR 11: CALL clearBottom: PRINT armyname$(index); " is taking the train from "; city$(from); " to "; city$(x1);
	tracks(who) = armyloc(index)
	from = armyloc(index)
	rrfrom(who) = from
	rr(who) = index: armyloc(index) = 0: armymove(index) = x1
	CALL tinytrain(who, 1)
	IF noise > 0 THEN SOUND 2222, 1
	CALL engine

	CALL occupy(from)
       IF occupied(from) > 0 THEN CALL placearmy(occupied(from))
	GOTO toot

	CASE IS > 0
	CALL tinytrain(who, 0)
	CALL occupy(rrfrom(who))
	IF occupied(rrfrom(who)) > 0 THEN CALL placearmy(occupied(rrfrom(who)))

	index = rr(who)
	tracks(who) = armymove(index)
	CALL tinytrain(who, 1)

	rr(who) = 0: armyloc(index) = armymove(index): armymove(index) = -1
	COLOR 11: CALL clearBottom: PRINT "Train with "; armyname$(index); " has arrived in "; city$(armyloc(index)); : IF noise > 0 THEN SOUND 1200, 2
	CALL TICK(turbo!)
	x = cityx(armyloc(index)) - 12: y = cityy(armyloc(index)) - 11
	LINE (x - 9, y - 8)-(x + 10, y + 8), 2, BF
	IF cityp(armyloc(index)) <> who THEN CALL capture(index, armyloc(index), who, 0)
	CALL placearmy(index)
	IF occupied(armyloc(index)) > 0 THEN CALL stax(who): GOTO toot
	CALL occupy(armyloc(index)): CALL placearmy(index)
	GOTO toot
END SELECT

route:
	x = 0: FOR j = 1 TO 6
	y = matrix(target, j)
	IF y > 0 AND cityp(y) = who THEN
	x = x + 1
		FOR m = 1 TO 6
		z = matrix(y, m)
		IF z > 0 AND z <> target AND cityp(z) = who THEN x = x + 1
		NEXT m
	END IF
NEXT j
RETURN

toot:
	IF who = side THEN CALL TICK(9)
	CALL clearRight
	clearBottom
END SUB

SUB recruit (who)
	IF cash(who) < 100 GOTO menu1
	size = 0: COLOR 12
	menuText$(0) = "Recruit"
	IF who = side AND rflag > 0 THEN FOR i = 1 TO rflag: x = rcity(i): menuText$(i) = city$(x): array(i) = x: NEXT i: size = rflag: GOTO alldone
	max = 4: IF RND > .8 THEN max = max - 1
	IF difficult < 3 THEN max = max + 1

	FOR i = 1 TO 40
	IF control(who) > 0 THEN pct! = .6 * max / control(who) ELSE pct! = .3
	IF size = 0 AND i > 20 THEN pct! = .3
	IF size < 2 AND i > 30 THEN pct! = .3
	array(i) = 0
	IF occupied(i) > 0 AND cityp(i) = who THEN pct! = .4
	IF RND < pct! AND cityp(i) = who THEN
		IF realism > 0 AND cityo(i) = 3 - who GOTO foe
		size = size + 1
		menuText$(size) = city$(i)
		array(size) = i
		IF size > max - 1 GOTO alldone
	END IF
foe:
	NEXT i
alldone:
	IF size = 0 GOTO menu1
	IF who = side AND rflag = 0 THEN FOR i = 1 TO size: rcity(i) = array(i): NEXT i: rflag = size
	CALL bubbleSortMenuText(size)
'............................................................................
levy:
	IF cash(who) < 100 GOTO menu1
	IF (who = side) OR (player = 2) THEN CALL clearBottom: PRINT force$(who); " funds available "; cash(who);
	tlx = 67: tly = 12: colour = 3
	IF who <> side THEN GOSUB randsel: GOTO auto1
      
	IF choose > 0 THEN choose = 21 + choose
	CALL menu(2): CALL clearRight
	IF choose < 1 GOTO menu1
auto1:
	empty = 0
	index = array(choose)
	CALL occupy(index)
	IF occupied(index) > 0 THEN i = occupied(index): GOTO add2
	CALL commander((who), empty)
       
	IF who <> side AND empty = 0 GOTO menu1
	IF empty = 0 GOTO levy
	armyloc(empty) = index
	GOSUB playb
	CALL newarmy(who, empty, index)
	GOTO levy
'............................................................................
add2:
	target = array(choose)
	x = 45: a$ = ""
	IF realism > 0 THEN
		x = 2 * cityv(armyloc(i)) + 20
		CALL cutoff(who, target, a)
		IF a < 1 THEN x = x \ 3: a$ = " ISOLATED !"
	END IF
	armysize(i) = armysize(i) + x

	GOSUB playb
	cash(who) = cash(who) - 100
	from = armyloc(i): x = cityx(from) - 12: y = cityy(from) - 11
	GET (x - 9, y - 7)-(x + 9, y + 6), anima
	CALL icon(armyloc(i), 0, 2)
	IF noise > 0 THEN SOUND 2222, 1
	COLOR 11: CALL clearBottom: PRINT "Army "; i; armyname$(i); " in "; city$(armyloc(i)); " strength increased to "; : CALL strong(i)
	IF a$ <> "" THEN PRINT a$;
	PUT (x - 9, y - 7), anima, PSET
	CALL TICK(turbo! - .5)
	GOTO levy
randsel:
		choose = 0: x = 0
		FOR i = 1 TO size
		target = array(i)
		LOCATE 14 + i, 69
		x = occupied(target)
		IF x = 0 XOR armysize(x) < 155 THEN choose = i
		NEXT i

	IF choose = 0 THEN choose = 1 + INT(RND * size)
	IF realism > 0 THEN
		x = 0
		FOR i = 1 TO size
		target = array(i)
		IF occupied(target) = 0 THEN
			y = 3 * cityv(target) + 33
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		ELSE
			y = 2 * cityv(target) + 20
			CALL cutoff(who, target, a)
			IF a < 1 THEN y = y \ 3
		END IF
		IF y > x AND RND > .5 THEN x = y: choose = i
		NEXT i
	END IF
	IF cash(who) < 100 THEN choose = size
	RETURN
playb:
	IF side = 1 AND difficult < 3 THEN armysize(empty) = armysize(empty) + 15 - 5 * difficult
	IF side = 2 AND difficult > 3 THEN armysize(empty) = armysize(empty) + 5 * difficult - 15
	RETURN
menu1:
END SUB

SUB shiptype (who, i)
a = 1: IF MID$(fleet$(who), i, 1) = "I" THEN a = 2
CALL shipicon(who, a)
END SUB

SUB showcity
FOR i = 1 TO 40
c = 9: IF cityp(i) = 2 THEN c = 7
IF cityp(i) = 0 THEN c = 12
x = cityx(i): y = cityy(i)
IF i = capcity(1) OR i = capcity(2) THEN
	PUT (x - 6, y - 6), Ncap, PSET
	LINE (x + 9, y - 4)-(x + 15, y + 4), 0, BF
	LINE (x + 8, y - 5)-(x + 13, y + 2), 3, BF
	PSET (x + 8, y - 4)
	IF fort(i) = 1 THEN DRAW "BR2C0e1D6BL1R2"
	IF fort(i) = 2 THEN DRAW "C0e1R1F1D1G3R3"
ELSE
	IF fort(i) = 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, B
	IF fort(i) > 1 THEN LINE (x - 5, y - 5)-(x + 5, y + 5), 0, BF
	CIRCLE (cityx(i), cityy(i)), 4, 0
	CIRCLE (cityx(i), cityy(i)), 3, c
	PAINT (cityx(i), cityy(i)), c, c
END IF
IF graf = 0 GOTO nocon
	FOR j = 1 TO 6: IF matrix(i, j) > 0 THEN CALL icon(i, matrix(i, j), 11)
	NEXT j
nocon:
NEXT i
END SUB

SUB smarts
CALL events
slush = 0: who = 3 - side
c = 9: IF side = 1 THEN c = 15
LOCATE 1, 1: PRINT SPACE$(80);
COLOR c: LOCATE 1, 10: PRINT force$(who); " Side is making decisions";
CALL starfin(star, fin, who)
'==========================================================================
'                       Check Supply
'==========================================================================
FOR i = star TO fin: IF armyloc(i) > 0 AND supply(i) < 1 THEN CALL resupplyArmy(i)
NEXT i
'==========================================================================
'                       Fortify Capital or Other City
'==========================================================================
cost = 200
IF cost > cash(who) GOTO signup

target = 0: IF occupied(capcity(who)) = 0 OR fort(capcity(who)) > 1 GOTO city2
target = capcity(who)
IF cityp(target) = who GOTO capital ELSE GOTO city2
IF target > 0 GOTO capital

city2:
IF 1 + RND < bold + aggress! GOTO signup
target = 0: FOR i = star TO fin
x = armyloc(i): IF x = 0 OR armymove(occupied(x)) < 0 OR armymove(i) < 0 GOTO endlook
IF fort(x) > 1 GOTO endlook
	CALL void(x, defend): IF defend > armysize(i) THEN target = armyloc(i): GOTO capital
endlook:
NEXT i

capital:
	IF target = 0 GOTO signup
	IF fort(target) > 1 GOTO signup
	fort(target) = fort(target) + 1
	x = occupied(target): armymove(x) = -1
	cash(who) = cash(who) - cost
	CALL clearBottom: PRINT city$(target); " fortifications increased to "; fort(target);
	CALL icon(target, 0, 6)
	CALL showcity
	IF who = 1 AND navysize(1) < 1 AND RND > .5 AND cash < 222 GOTO signup
	IF 3 * RND > 1 + aggress! AND cash(who) >= cost GOTO city2
'==========================================================================
'                       Recruit New Armies
'==========================================================================
signup:
IF who = 1 AND navysize(1) < 1 AND cash(1) > 100 THEN CALL navy(1, 1): IF cash(who) < 100 GOTO isok
GOSUB enufarmies
IF x > 2 + 3 * side + 3 * RND GOTO isok
IF navysize(who) < 5 AND cash(who) > 100 AND navyloc(who) <> 99 THEN IF cityp(navyloc(who)) = who THEN slush = slush + 100: cash(who) = cash(who) - 100: IF cash(who) < 100 GOTO isok
CALL recruit(who)
'==========================================================================
'                         Naval Commands
'==========================================================================
isok:
	cash(who) = cash(who) + slush
dock:
	IF side = 2 AND navyloc(1) = 0 AND navysize(1) < 1 AND cityp(30) = 1 AND cash(1) > 100 THEN navyloc(1) = 30: CALL navy(1, 1): GOTO movenavy
	IF navyloc(who) = 99 THEN
		IF RND < .9 THEN CALL navy(who, 3)
		GOTO movearmy
	END IF
	IF cash(who) < 100 OR navysize(who) > 9 OR cityp(navyloc(who)) <> who GOTO movenavy
	CALL navy(who, 1)
'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
movenavy:
	IF navysize(who) = 0 THEN navyloc(who) = 0
	IF navyloc(who) = 0 GOTO movearmy
'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'                     move ships & prohibit further action this turn
'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	IF navyloc(who) <> 99 THEN
		IF cityp(navyloc(who)) = who THEN CALL navy(who, 3): GOTO movearmy   'move ships & prohibit further action this turn
		IF cityp(navyloc(who)) = 0 THEN CALL navy(who, 3): GOTO movearmy
	ELSE
		IF RND < .5 THEN CALL navy(who, 3)
		GOTO movearmy
	END IF

	IF cityp(navyloc(who)) <> who THEN
		IF occupied(navyloc(who)) = 0 OR RND > .3 THEN
			CALL navy(who, 2) 'attack
		ELSE
			CALL navy(who, 3) 'move
		END IF
	END IF
'==========================================================================
'                       Give Move Orders to Each Army
'==========================================================================
movearmy:
	CALL drawShips
'---------------------------------------------------------------------------
'                               Check to Combine
'---------------------------------------------------------------------------
a = who: CALL combine(a)
CALL railroad(who)
'---------------------------------------------------------------------------
'                               Top Priority
'---------------------------------------------------------------------------
FOR i = star TO fin
target = armyloc(i)
IF armyloc(i) < 1 OR armymove(i) < 0 GOTO deadman
x = armysize(i): IF supply(i) < 1 AND RND > .1 GOTO deadman

choose = 0

CALL void(target, defend)

IF defend > 0 AND target = capcity(who) AND occupied(target) = i GOTO deadman   'hold capital
IF target <> capcity(who) GOTO nocap
IF vicflag(5) = 0 GOTO nocap
	FOR j = 1 TO 6
	k = matrix(target, j): IF j = 0 GOTO nocap
	CALL void(k, flag): IF flag > 0 GOTO deadman
	NEXT j
nocap:
CALL evaluate(i, best): IF best = 0 GOTO deadman
move9:
	IF best = 0 THEN choose = 1 + INT((j - 1) * RND)
	IF choose = 0 THEN choose = best
	armymove(i) = matrix(target, choose)

	IF cityp(armymove(i)) = who THEN y = occupied(armymove(i)): IF y > 0 THEN IF armymove(y) = x THEN armymove(i) = 0: GOTO deadman  ' eliminate crossing moves
	IF month = 1 AND jancam = 0 AND cityp(armymove(i)) <> who THEN armymove(i) = 0: GOTO deadman

	IF turbo! > 1 THEN
		COLOR c: CALL clearBottom
		PRINT armyname$(i); " plans to move from "; city$(armyloc(i)); " to "; city$(armymove(i));
	END IF
		CALL icon(armyloc(i), armymove(i), 1)
		CALL icon(armyloc(i), armymove(i), 9)
	CALL TICK(turbo! - 1)
	PUT (cityx(armyloc(i)) - 20, cityy(armyloc(i)) - 19), image, PSET
deadman:
NEXT i
	FOR i = star TO fin
	IF armymove(i) = 0 AND armyexper(i) < 6 AND armyexper(i) < armylead(i) THEN
		armyexper(i) = armyexper(i) + 1

		IF turbo! > 1 THEN
		CALL clearBottom
			PRINT armyname$(i); " has drilled to reach experience level "; armyexper(i);
		END IF
		armymove(i) = -1
		CALL TICK(turbo! - 1)
	END IF
	NEXT i
EXIT SUB
'---------------------------------------------------------------------------
enufarmies:
CALL starfin(star, fin, 3 - who)
FOR i = star TO fin
	IF armyloc(i) > 0 THEN y = y + .1 * armysize(i)
NEXT i
CALL starfin(star, fin, who)
x = 0: z = 0: FOR i = star TO fin: IF armyloc(i) > 0 THEN x = x + 1: z = z + .1 * armysize(i)
NEXT i
IF y > z THEN x = x - 2
IF y > 2 * z THEN x = 0
RETURN
'---------------------------------------------------------------------------
END SUB

SUB snapshot (x, y, flag)
IF flag = 0 THEN GET (x - 10, y - 10)-(x + 10, y + 10), image
IF flag = 1 THEN PUT (x - 10, y - 10), image, PSET
END SUB

SUB strong (index)
a$ = LTRIM$(RTRIM$(STR$(armysize(index)))) + "00"
PRINT a$;
END SUB

SUB tinytrain (who, flag)
	IF tracks(who) = 0 THEN EXIT SUB
	from = tracks(who)
	x = cityx(from) - 12: y = cityy(from) - 11
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
IF player = 1 THEN
	CALL smarts
ELSE
	FOR i = 1 TO 40
	IF armyloc(i) > 0 AND armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
	NEXT i
END IF
COLOR 14: LOCATE 1, 1: PRINT SPACE$(80);
LOCATE 1, 20: PRINT "Update for "; month$(month); ","; year
CALL clearBottom: PRINT "press any key for "; month$(month); ","; year; " events";
DO WHILE INKEY$ = "": LOOP
GOSUB upbox
'==========================================================================
'                       Assign Time of Action
'==========================================================================
FOR i = 1 TO 2: IF rr(i) > 0 THEN CALL railroad(i): LINE (5, 17)-(100, 63), 3, BF: LINE (5, 17)-(100, 63), 0, B: CALL engine
NEXT i

FOR i = 1 TO 40
brray(i) = 999
IF armymove(i) < 0 THEN armymove(i) = 0
IF armyloc(i) > 0 AND armymove(i) > 0 THEN brray(i) = INT(4 + 4 * RND) * 100 + i
IF supply(i) < 1 AND armymove(i) > 0 THEN brray(i) = 900 + i
SELECT CASE armysize(i)         'bigger armies move slower
	CASE IS > 400
		IF brray(i) < 900 THEN brray(i) = brray(i) + 100: x = 2
	CASE IS > 800
		IF brray(i) < 800 THEN brray(i) = brray(i) + 200: x = 3
	CASE IS > 1000
		IF brray(i) < 700 THEN brray(i) = brray(i) + 300: x = 4
	CASE ELSE
		x = 1
END SELECT
IF brray(i) <> 999 AND armylead(i) > 10 * RND THEN
		brray(i) = brray(i) - 100 * (armylead(i) \ 2)
		IF brray(i) < 100 THEN brray(i) = 100 + i
END IF
NEXT i

CALL bubbleSort(40)
'==========================================================================
'                       Begin Main Loop
'==========================================================================
FOR j = 1 TO 40
flag = 0
IF brray(j) = 999 GOTO allthru
active = INT(brray(j) / 100): active = brray(j) - 100 * active: s = 1: IF active > 20 THEN s = 2
IF armymove(active) < 1 GOTO digin
COLOR 11: CALL clearBottom: PRINT armyname$(active); " is moving to "; city$(armymove(active));

supply(active) = supply(active) - 1: IF supply(active) < 0 THEN supply(active) = 0: CALL TICK(turbo!): CALL clearBottom: PRINT armyname$(active); " is out of supplies !";

CALL placearmy(active)
CALL icon(armyloc(active), armymove(active), 5)

CALL animate(active, 0)
'==========================================================================
target = armymove(active)
IF occupied(target) = 0 GOTO easy
IF (s = 1 AND occupied(target) < 21) OR (s = 2 AND occupied(target) > 20) GOTO friend ELSE GOTO enemy
'==========================================================================
'                         Join Forces
'==========================================================================
friend:
COLOR 11: CALL clearBottom: PRINT armyname$(active); " and "; armyname$(occupied(target)); " meet in "; city$(target); : CALL TICK(turbo!)
CALL icon(armymove(active), 0, 6)
CALL clearBottom
GOTO easy
'==========================================================================
'                       Attack
'==========================================================================
enemy:
CALL icon(target, 0, 3)
defend = occupied(target)

COLOR 11: CALL clearBottom: PRINT armyname$(active); " attacks "; armyname$(defend); " in "; city$(armyloc(defend)); : CALL TICK(turbo! - 1)
IF armysize(defend) > 0 THEN CALL battle(active, defend, win, lose): flag = 1: IF graf > 0 THEN GOSUB upbox
IF armyexper(win) < 10 THEN armyexper(win) = armyexper(win) + 1

IF armysize(lose) < 2 THEN
	CALL clearBottom
	a$ = armyname$(lose) + "'s army is crushed in " + city$(armyloc(defend))
	CALL scribe(a$, 2)
	index = lose: GOTO crushed
END IF

CALL clearRight
'==========================================================================
'                       Attacker Loses
'==========================================================================
IF win = active GOTO kickbutt
armymove(active) = armyloc(active)
armyloc(active) = target
COLOR 11: CALL clearBottom: PRINT armyname$(active); " withdrew to "; city$(armymove(active));

CALL placearmy(armyloc(active))
CALL animate(active, 1)

armyloc(active) = armymove(active)
CALL placearmy(armyloc(active))
CALL placearmy(active)
occupied(armyloc(active)) = active
armymove(active) = -2
	      
IF 11 * RND > armylead(defend) THEN CALL icon(armyloc(defend), armymove(defend), 4): IF armymove(defend) > 0 THEN armymove(defend) = -2

CALL TICK(turbo!): GOTO digin
'==========================================================================
'                       Defender Retreats
'==========================================================================
kickbutt:
	CALL icon(armyloc(active), target, 4)
	IF armymove(defend) > 0 THEN CALL icon(target, armymove(defend), 4)

	CALL retreat(defend, flee): IF flee > 0 THEN move2 = flee: GOTO outta

	best = 0: flee = 0
	FOR i = 1 TO 6
	x = matrix(target, i)
	IF x > 0 AND (cityp(x) = 3 - s) AND cityv(x) > best THEN
		IF best = 0 THEN
			flee = i: best = cityv(x)
		ELSE
			IF occupied(x) = 0 THEN flee = i: best = cityv(x)
		END IF
	END IF
	NEXT i
	IF flee = 0 GOTO deadmeat
	move2 = matrix(target, flee)
outta:
	CALL placearmy(defend)                  ' in old city

	armymove(defend) = move2
	CALL animate(defend, 0)                 ' animate retreat
       
	armyloc(defend) = move2
	occupied(move2) = defend
	CALL clearBottom
	PRINT armyname$(defend) + " is withdrawing to " + city$(move2);

	CALL placearmy(defend)                  ' in new city
       
	CALL icon(target, 0, 6)
	armymove(defend) = -2
	GOTO holdon

deadmeat:
	index = defend
	a$ = armyname$(index) + " surrenders to " + armyname$(active) + " in " + city$(armyloc(index))
	CALL scribe(a$, 2)
crushed:
	IF graf > 2 THEN CALL surrender(index): COLOR 14: LOCATE 3, 68: PRINT armyname$(index): LOCATE 4, 68: PRINT "surrenders !"
	x = 1: IF index > 20 THEN x = 2
	IF noise > 1 AND x <> side THEN PLAY "MFMST220o3e4g8g2.g8g8g8o4c2"
	IF armymove(index) > 0 THEN CALL icon(armyloc(index), armymove(index), 4)
	victory(3 - s) = victory(3 - s) + 25
	armyloc(index) = 0: lname$(index) = "": armyname$(index) = ""
	armysize(index) = 0: armylead(index) = 0
	armyexper(index) = 0: armymove(index) = 0: supply(index) = 0
	supply(active) = supply(active) + supply(index): supply(index) = 0
	IF supply(active) > 10 THEN supply(active) = 10
	CALL TICK(9): CALL clearRight
	IF armyloc(active) = 0 GOTO digin
'---------------------------------------------------------------------------
'                       check for more defenders !
'---------------------------------------------------------------------------
holdon:
	CALL occupy(target): IF occupied(target) = 0 GOTO easy
	COLOR 11: CALL clearBottom: PRINT "There are still defenders in "; city$(target); : CALL TICK(99)
	GOTO enemy
'==========================================================================
'                       Move Into New City
'==========================================================================
easy:
CALL icon(armyloc(active), target, 4)
armyloc(active) = target: armymove(active) = -2
CALL occupy(armyloc(active))
CALL placearmy(active)
'---------------------------------------------------------------------------
'                            City Capture
'---------------------------------------------------------------------------
	IF cityp(armyloc(active)) = s GOTO horde
	c = armyloc(active)
	IF player = 1 AND s = side AND fort(c) > 0 AND flag = 0 THEN
		tlx = 67: tly = 15
		hilite = 15: colour = 3
		menuText$(0) = "Raze ?"
		menuText$(1) = "No"
		menuText$(2) = "Yes"
		size = 2
		CALL menu(0)
		CALL clearRight
		IF choose = 2 GOTO smoke
	END IF
	IF player = 1 AND s <> side AND fort(c) > 0 AND flag = 0 THEN
		IF realism > 0 AND cityy(c) > 150 THEN
smoke:
			fort(c) = 0
			x = cityx(c)
			y = cityy(c)
			LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF
			CALL showcity
			CALL clearBottom
			PRINT armyname$(active); " has destroyed the forts at "; city$(c);
			TICK 3
		END IF
	END IF
	CALL capture(active, c, s, flag)
horde:
IF supply(active) < 10 THEN supply(active) = supply(active) + 1: IF RND > .8 GOTO horde
digin:
NEXT j
GOTO allthru

upbox:
LINE (450, 318)-(526, 420), 1, BF
LINE (527, 315)-(527, 439), 10
COLOR 14: LOCATE 23, 50: PRINT "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍ»"
LOCATE 24, 50: PRINT "º U P D A T E º"
LOCATE 25, 50: PRINT "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍ¼"
RETURN

allthru:
IF navysize(commerce) < 1 THEN commerce = 0
IF commerce > 0 THEN
	CALL clearBottom
	IF RND < .8 + .02 * navysize(commerce) THEN
		raider = .05 * navysize(commerce) * (1 + RND) * (income(3 - commerce))
		IF raider < 1 THEN raider = 1
		IF raider / income(3 - commerce) > .3 THEN raider = .3 * income(3 - commerce)
		COLOR 15: PRINT force$(commerce); " raiders have sunk $"; raider; " of "; force$(3 - commerce); " commerce";
		a = 1: IF LEFT$(fleet$(commerce), 1) = "I" THEN a = 2
		PSET (500, 465), 0: CALL shipicon(commerce, a)
		IF noise > 0 THEN PLAY "t210l8o4co3bo4l4co3ccL8gfego4co3bo4c"
		IF commerce = side THEN grudge = 1
		TICK 9
	ELSE
		raider = 0
		CALL sinkShip(commerce)
		COLOR 15: PRINT force$(commerce); " raiders have lost a ship ("; navysize(commerce); " remain)";
		IF noise > 0 THEN SOUND 590, .5: SOUND 999, .5: SOUND 1999, .5
		IF navyloc(commerce) > 0 THEN
			TICK 9
			GOTO allthru
		ELSE
			commerce = 0
			LINE (447, 291)-(525, 335), 1, BF
			FOR k = 1 TO 5: CIRCLE (480, 315), 4 * k, 11: NEXT k
			TICK 9
			LINE (447, 291)-(525, 335), 1, BF
		END IF
	END IF
END IF

CALL touchup: CALL drawShips: CALL iterate

CALL clearBottom
LINE (390, 350)-(520, 400), 1, BF
COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(month$(month), 3)); ","; year
victory(1) = .8 * victory(1) + .3 * (income(1) + control(1))
IF control(1) > 29 THEN victory(1) = victory(1) + 50: IF control(1) > 34 THEN victory(1) = victory(1) + 100
IF side = 2 AND control(1) < 11 THEN aggress! = aggress! + .7

IF victory(1) < 1 THEN victory(1) = 0
victory(2) = .8 * victory(2) + .3 * (income(2) + control(2))
IF control(2) > 29 THEN victory(2) = victory(2) + 50: IF control(2) > 34 THEN victory(2) = victory(1) + 100
IF side = 1 AND control(2) < 11 THEN aggress! = aggress! + .7
IF player = 2 THEN CALL clearBottom: COLOR 14: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
END SUB

