DEFINT A-Z
DECLARE SUB armyxy (x%, y%, z%)
DECLARE SUB center (y%, a$)
DECLARE SUB flags (who%, w%, a%)
DECLARE SUB image2 (a$, s%)
DECLARE SUB maptext ()
DECLARE SUB mountain (xx%, yy%)
DECLARE SUB mxw (wide%)
DECLARE SUB roman (target%, a$)
DECLARE SUB stax (who%)
' $INCLUDE: 'cws14.bi'

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
	IF brray(i) > brray(i + 1) THEN
		SWAP brray(i), brray(i + 1)
		swaps% = i
	END IF
	NEXT i
LOOP WHILE swaps%
END SUB

SUB bubble (limit)
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

SUB cancel (side)
CALL starfin(star, fin, (side))
counter:
CALL clrrite
	size = 0
	FOR j = star TO fin
	a$ = armyname$(j): IF LEN(a$) > 10 THEN x = INSTR(a$, " "): a$ = RIGHT$(a$, LEN(a$) - x)
	IF armyloc(j) > 0 AND armymove(j) > 0 THEN size = size + 1: menuText$(size) = a$: array(size) = armyloc(j)
	NEXT j
	CALL bubble(size)
	tlx = 67: tly = 2: wtype = 2
	menuText$(0) = "Cancel"
	IF size < 1 THEN CALL clrbot: COLOR 11: PRINT "No units have orders to cancel"; : EXIT SUB
	CALL menu(1)
	SELECT CASE choose
	 CASE 1 TO size
		target = array(choose)
	       
		FOR i = star TO fin
		IF armyloc(i) = target THEN x = INSTR(armyname$(i), menuText$(choose)): IF x > 0 AND armymove(i) > 0 THEN index = i
		NEXT i

		CALL clrbot: COLOR 11: PRINT armyname$(index); " has cancelled move to "; city$(armymove(index)); : CALL TICK(turbo + 1)
		CALL icon(armyloc(index), armymove(index), 4)
		armymove(index) = 0: IF noise > 0 THEN SOUND 2999, .5
		CALL stax(side)
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
IF noise = 2 THEN PLAY "T130MFMSO2f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4"
LOCATE 20, 20: PRINT CHR$(34); "... and that the government of the people,"
IF noise = 2 THEN PLAY "o2b-8.a16g8.g16g8.a16b-8.a16b-8.g16f8.g16f8.d16f4"
LOCATE 21, 20: PRINT "by the people, for the people,"
IF noise = 2 THEN PLAY "f8.f16f8.f16f8.e-16d8.f16b-8.o3c16d8.d16d8.c16o2b-4b-4MNo3c4c4o2b-4a4b-2"
LOCATE 22, 20: PRINT "shall not perish from the earth."; CHR$(34)
LOCATE 25, 40: PRINT "- Abraham Lincoln"
FOR i = -565 TO 50 STEP 50: CALL flags(1, i, 0): NEXT i
IF noise = 2 THEN PLAY "P2f4..e-16d8.f16b-8.o3c16d2o2b-2g4..a16b-8.a16b-8.g16f2d2": PLAY "f4..e-16d8.f16b-8.o3c16d2o2b-4b-4o3c4c4o2b-4a4b-2.."
END SUB

SUB capture (active, c, s, flag)
	cityp(c) = s: CALL clrbot
	a$ = armyname$(active) + " has captured " + city$(c)
	COLOR 11: PRINT armyname$(active) + " has captured " + city$(c);
	IF active < 21 AND noise > 1 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	IF active > 20 AND noise > 1 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	IF c <> capcity(3 - s) THEN CALL flashcity(c)
	victory(s) = victory(s) + cityv(c)
	IF c = capcity(3 - s) THEN
		victory(s) = victory(s) + 100
		victory(3 - s) = victory(3 - s) - 100
		a$ = force$(3 - s) + " CAPITAL captured !"
		CALL scribe(a$, 1)
		CALL image2(city$(capcity(3 - s)) + " has fallen!", 4)
		IF graf = 3 THEN CALL burn(3 - s)
		capcity(3 - s) = 0
		CALL flashcity(c)
	END IF
	IF fort(c) > 0 AND flag > 0 THEN fort(c) = fort(c) - 1: x = cityx(c): y = cityy(c): LINE (x - 5, y - 5)-(x + 5, y + 5), 2, BF: CALL showcity
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
	IF armyloc(i) = 0 AND lname$(i) <> "" THEN empty = i: EXIT SUB
	NEXT i

'                 generic leaders if set list is exhausted
	FOR i = star TO fin
	IF armyloc(i) = 0 THEN
		x = i
		CALL roman(x, a$)
		empty = i
		lname$(i) = a$
		rating(i) = 1 + 8 * RND
		EXIT SUB
	END IF
	NEXT i
	CALL clrbot: PRINT "No more "; force$(who); " commanders available"; : CALL TICK(turbo!)
END SUB

SUB endit
	a$ = STR$(ABS(vicflag(3)) * 2.5) + "% Cities"
	t$ = STR$(ABS(vicflag(3)) * 2.5) + "% Total Income"
	menuText$(8) = "Time: " + month$(vicflag(1)) + STR$(ABS(vicflag(2)))
	menuText$(9) = RTRIM$(STR$(ABS(vicflag(6)))) + ":1 Force Ratio"
	COLOR 15: LOCATE 1, 1: PRINT "Press ENTER to toggle ending conditions";
	COLOR 14: PRINT "				ESC when done"
what4:
	FOR i = 2 TO 6: IF vicflag(i) > 0 THEN menuText$(i - 1) = "û " ELSE menuText$(i - 1) = "  "
	NEXT i
	choose = chosit
	menuText$(0) = "Victory Conditions"
	menuText$(1) = menuText$(1) + menuText$(8)
	menuText$(2) = menuText$(2) + a$
	menuText$(3) = menuText$(3) + t$
	menuText$(4) = menuText$(4) + "Capital Captured"
	menuText$(5) = menuText$(5) + menuText$(9)
	menuText$(6) = "DONE"
	wtype = 2: colour = 3: size = 6: hilite = 14
	CALL menu(0)
	chosit = 21 + choose
SELECT CASE choose
	CASE 1
	vicflag(2) = -vicflag(2)
	CASE 2 TO 5
	vicflag(choose + 1) = -vicflag(choose + 1)
	CASE ELSE
	GOTO cheer
END SELECT
	GOTO what4
cheer:
	CLS
	CALL usa
END SUB

SUB engine
IF rr(1) + rr(2) = 0 GOTO notrain
LINE (5, 17)-(100, 63), 3, BF
LINE (5, 17)-(100, 47), 0, B
LINE (5, 47)-(100, 63), 0, B

FOR i = 1 TO 2
IF rr(i) = 0 GOTO notrane
PSET (15, 25), 3: c = 9: IF i = 2 THEN c = 15: PSET (60, 25), 3
DRAW "C0S4R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5BF4"
x = POINT(0): y = POINT(1): PAINT (x, y), c, 0
LOCATE 4, 6 * (i - 1) + 2: PRINT LEFT$(city$(armymove(rr(i))), 5)
notrane:
NEXT i

notrain:
END SUB

SUB evaluate (index, x)
from = armyloc(index)
x = 200: IF aggress! > 1.5 THEN x = 80: IF aggress! > 2 THEN x = 20: IF aggress! > 3 THEN x = 5
CALL void(from, defend): IF defend = 0 THEN x = 0
IF bold > 1 THEN x = .5 * x

best = armysize(index)

FOR j = 1 TO 6: array(j) = -1
a = matrix(from, j): IF a > 0 THEN IF occupied(a) > 0 THEN best = best - armysize(occupied(a)): y = 1
NEXT j: best = .01 * best
IF bold > 0 THEN best = best + 20 * bold

CALL starfin(star, fin, 3 - side)

FOR j = 1 TO 6
	y = -1: a = matrix(from, j): IF a = 0 THEN max = j - 1: GOTO alleval
      
	c = occupied(a)
	FOR k = star TO fin: IF armyloc(k) > 0 THEN IF armymove(k) = a AND c = 0 GOTO alle
	NEXT k
	
	y = best - x * fort(from) - cityv(from) + 30 * RND
	IF fort(from) > 0 THEN IF index = occupied(from) THEN y = y - 25: IF realism > 0 THEN y = y - 50
	IF a = capcity(side) THEN IF vicflag(5) > 0 THEN y = y + 200
	IF cityp(a) <> 3 - side THEN y = y + 5 * cityv(a) + 10 * fort(a)
	IF cityp(a) <> side GOTO ourn
	   IF c = 0 THEN y = y + 10 * cityv(a): GOTO ourn
	   x1 = 1: IF fort(a) = 1 THEN x1 = 2: IF fort(a) = 3 THEN x1 = 3

	   IF armysize(c) > 0 THEN
		odds! = armysize(index) / (x1 * armysize(c))
		IF realism > 1 THEN odds! = .8 * odds!
	   ELSE
		odds! = 5
	   END IF

	   IF armysize(index) < 15 THEN y = y - 300: odds! = .1
	   IF bold < 3 AND armysize(index) < 40 AND odds! < .8 THEN y = 0
	   IF realism > 0 THEN y = y - 15
	   IF odds! < .5 THEN y = y - 200
	   IF bold = 0 AND RND > .9 THEN y = y + 10 * (armylead(index) - armylead(c) + armyexper(index) - armylead(index))
	   IF supply(index) < 1 THEN y = y - 100
	   SELECT CASE odds! + .5 * bold
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
		y = y + .5 * (armysize(index) - armysize(c)) + 50 * RND
	   END SELECT
ourn:
	IF cityp(a) = 3 - side AND c > 0 AND armymove(c) = 0 THEN y = y - armysize(c)
	IF side = 1 AND cityy(a) < cityy(from) THEN y = y + 2
	IF side = 2 AND cityy(a) > cityy(from) THEN y = y + 2
'---------------------------------------------------------------------------
	FOR k = 1 TO 6: m = matrix(a, k): IF m = 0 GOTO tally3
	IF cityp(m) = 0 THEN y = y + 3 * cityv(m) + 4 * fort(m)
	IF cityp(m) = side THEN y = y + 3 * cityv(m) + 4 * fort(m)
	IF cityp(m) = side AND c > 0 THEN
		odds! = 5 - 4 * RND
		IF armysize(c) > 0 THEN odds! = armysize(index) / armysize(c) ELSE odds! = 5
		IF odds! < 1 THEN y = y - 2
	END IF
	IF cityp(m) = capcity(side) THEN y = y + 50
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
	IF defend > armysize(index) AND array(best) < 50 THEN best = 0
	x = best
END SUB

SUB events
'==========================================================================
'                              Special Events
'==========================================================================
IF realism > 0 AND year = 1862 AND month < 3 THEN
	COLOR 14: CALL clrbot
	PRINT "SPECIAL DEVELOPMENT : IRONCLAD ships now available";
	IF noise > 0 THEN FOR k = 1 TO 5: SOUND 140, 1: SOUND 37, 1: NEXT k
	DO WHILE INKEY$ = "": LOOP
	EXIT SUB
END IF
IF randbal = 0 THEN EXIT SUB
plus = difficult: IF side = 1 THEN plus = 6 - difficult
pct! = .005 * (year - 1860) * plus * plus: IF pct! > .9 THEN pct! = .9
IF RND > pct! THEN EXIT SUB

CALL clrbot: COLOR 14: PRINT "SPECIAL EVENT...";
who = 1: IF RND > .1 * randbal THEN who = 2

SELECT CASE who
'----------------------------------------------------------------------------
'                               good for South
'----------------------------------------------------------------------------
	CASE 1
	IF year = 1864 AND month = 1 THEN victory(2) = victory(2) + 50
	IF year = 1865 AND month = 1 THEN victory(2) = victory(2) + 100
	IF RND > .9 THEN GOSUB riot: EXIT SUB

	CALL clrbot
	IF RND > .2 OR navysize(2) > 9 GOTO mercen
	IF navysize(2) > 0 AND navyloc(2) <> 99 THEN empty = navyloc(2): GOTO float1
		empty = 0
		FOR i = 1 TO 40
		IF cityp(i) = 2 AND matrix(i, 7) = 99 AND navyloc(1) <> i THEN empty = i: EXIT FOR
		NEXT i
	IF empty = 0 GOTO mercen
float1:
	CALL scribe("England has given ships to the South", 2)
	navysize(2) = navysize(2) + 2 * plus
	IF navysize(2) > 10 THEN navysize(2) = 10
	x = navysize(2) - LEN(fleet$(2))
	fleet$(2) = fleet$(2) + STRING$(x, "W")
	navyloc(2) = empty: CALL ships
	GOTO dull1
mercen:
	IF RND > .1 OR control(2) < 30 GOTO money
	a$ = "French": IF RND > .5 THEN a$ = "British"
	CALL scribe(a$ + " mercenaries join " + armyname$(index) + "'s army", 2)
	armysize(index) = armysize(index) + 100 * plus
	armyexper(index) = 10: supply(index) = 10
	GOTO dull1
money:
	IF RND > .3 OR control(2) < 12 GOTO cotton
		CALL scribe("The South has obtained a loan from Europe", 2)
		GOTO purse
cotton:
	IF RND > .5 OR control(2) < 12 GOTO uprising
	CALL scribe("Cash from cotton sales fill the Rebel Treasury", 2)
purse:
	cash(2) = cash(2) + 100 * plus
	GOTO dull1
uprising:
	pct! = .9
	a$ = "Union troops diverted to fight Western Indian uprisings"
	IF RND > .5 THEN a$ = "Union 90-day enlistees return home"
	IF year = 1864 AND month > 5 THEN a$ = "20% of Union forces take furloughs to vote in 1864 elections": pct! = .8
	CALL scribe(a$, 2)
	FOR k = 1 TO 20
	armysize(k) = pct! * armysize(k)
	NEXT k
	GOTO dull1
'----------------------------------------------------------------------------
riot:
	IF realism = 0 THEN RETURN
	IF control(who) = 1 THEN EXIT SUB
	FOR k = 1 TO 99
	x = 1 + INT(40 * RND)
		IF cityo(x) <> who AND cityp(x) = who AND occupied(x) = 0 THEN
			CALL clrbot: COLOR 15
			PRINT " Riots have broken out in "; city$(x);
			cityp(x) = 0
			CALL showcity
			TICK turbo!
			CALL clrbot
			CALL image2(city$(x) + " is now NEUTRAL !", 4)
			TICK turbo!
			RETURN
		END IF
	NEXT k
	RETURN
'----------------------------------------------------------------------------
'                               good for Union
'----------------------------------------------------------------------------
	CASE 2
	IF RND > .1 OR navyloc(1) = 0 OR navysize(1) > 9 GOTO event2
	IF RND > .95 THEN GOSUB riot: EXIT SUB
	CALL scribe("Union shipworks have produced extra ships", 2)
	navysize(1) = navysize(1) + plus
	IF navysize(1) > 10 THEN navysize(1) = 10
	x = navysize(1) - LEN(fleet$(1))
	fleet$(1) = fleet$(1) + STRING$(x, "W")
	GOTO dull2
event2:
	IF RND < .7 GOTO abe
	CALL scribe("Volunteer troops swell the Union ranks", 2)
	x = 0: FOR i = 1 TO 20: x = x + 1: IF x > 5 GOTO dull2
	IF armysize(i) > 0 AND RND > .5 THEN armysize(i) = armysize(i) * 1.1 + plus
	NEXT i: GOTO dull2
abe:
	IF emancipate = 0 AND year > 1862 THEN

		emancipate = 1
		CALL scribe("Abraham Lincoln announces the Emancipation Proclamation", 2)
		victory(1) = victory(1) + 100: victory(2) = victory(2) - 100
		SHELL "abelinco.exe"
		CALL usa
		GOTO dull2
	END IF
	IF year = 1864 AND month = 11 THEN
		CALL scribe("Lincoln has been reelected", 2)
		victory(2) = .5 * victory(2)
		GOTO dull2
	END IF
	IF RND > .5 THEN
		CALL scribe("Wealthy Unionists give generously to the Federal Cause", 2)
		cash(1) = cash(1) + 100 * plus
		GOTO dull2
	END IF
	IF RND > .5 AND year > 1861 THEN
		CALL scribe("Rebel deserters leave the battlefield to go home", 2)
		FOR i = 21 TO 40: armysize(i) = .92 * armysize(i): NEXT i: GOTO dull2
	END IF
	IF RND > .5 AND year > 1861 THEN
		CALL scribe("Union soldiers now have repeating rifles", 2)
		FOR i = 1 TO 20
			IF armyexper(i) < 9 THEN armyexper(i) = armyexper(i) + 2
		NEXT i
	END IF
		CALL scribe("Secretary of War Stanton predicts the end of the Rebellion", 2)
		victory(1) = victory(1) + 10: GOTO dull2
	CASE ELSE
END SELECT

dull2:
	IF noise = 2 THEN PLAY "MNMFL16o2T120dd.dd.co1b.o2do3g.ab.bb.ag"
	DO WHILE INKEY$ = "": LOOP: EXIT SUB
dull1:
	IF noise = 2 THEN PLAY "MNMFT160o2L16geL8ccL16cdefL8ggge"
	DO WHILE INKEY$ = "": LOOP
END SUB

SUB flags (who, w, a)
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

SUB image2 (a$, s)
DIM g2(1 TO 8000)
menuText$(1) = a$
tlx = 32 - LEN(a$) \ 2
tly = 10: size = 1
CALL mxw(wide)
IF wide > 59 THEN wide = 59: a$ = LEFT$(a$, 59)
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
	LOCATE tly + 2, tlx + 2: PRINT a$
	CALL TICK(9)
	PUT (8 * tlx - 4, 16 * tly - 3), g2, PSET
END SUB

SUB integrity
CLS : COLOR 15
x = 0: y = 0
FOR i = 1 TO 40
FOR j = 1 TO 6: IF matrix(i, j) = 0 GOTO done
	index = matrix(i, j)
	FOR k = 1 TO 6
	IF matrix(index, k) = i GOTO ret
	IF matrix(index, k) = 0 THEN matrix(index, k) = i: PRINT "+ Adding return route from "; city$(index); " to "; city$(i): y = y + 1: GOTO ret
	NEXT k
	x = x + 1: PRINT "Error in CITIES.GRD entry for city #"; i; city$(index); ": no return route to "; city$(i): TICK 1
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
	FOR j = 1 TO LEN(city$(k))
	a = cityx(k) + 6 * (j - 4) - 3
	x = ASC(MID$(UCASE$(city$(k)), j, 1)) - 64
	IF a > 527 GOTO nextc
	PSET (a, cityy(k) + 12), 10
	
	IF matrix(k, 7) < 90 THEN
		IF bw = 0 THEN DRAW "S4C0" ELSE DRAW "S4C7"
	ELSE
		DRAW "C10"
	END IF
	IF x > 0 AND x < 27 THEN DRAW font$(x)
	NEXT j
nextc:
NEXT k
END SUB

SUB maxx
COLOR 14: LOCATE 28, 1: PRINT "press a key"; : DO WHILE INKEY$ = "": LOOP
SCREEN 0: COLOR 14, 5: CLS : COLOR 11, 0

LOCATE 2, 7: PRINT STRING$(57, "²")
LOCATE 9, 7: PRINT STRING$(57, "²")
FOR i = 1 TO 6: LOCATE 2 + i, 7: PRINT "²"; SPACE$(55); "²": NEXT i

		OPEN "I", 1, "hiscore.cws"
		FOR s = 1 TO 2
		COLOR 14, 4: LOCATE 3, 30 * (s - 1) + 10: PRINT force$(s); " HALL of FAME"
		COLOR 15, 0: FOR i = 1 TO 5
		INPUT #1, city$(5 * (s - 1) + i), matrix(s, i)
		LOCATE 3 + i, 30 * (s - 1) + 8: PRINT i, city$(5 * (s - 1) + i), matrix(s, i)
		NEXT i: NEXT s: CLOSE #1
		      
			FOR s = 1 TO 2: FOR i = 1 TO 5
			IF victory(s) < matrix(s, i) GOTO oldskor
				FOR j = 5 TO i + 1 STEP -1
				matrix(s, j) = matrix(s, j - 1)
				city$(5 * (s - 1) + j) = city$(5 * (s - 1) + j - 1)
				NEXT j

			COLOR 15, 1: IF s = 2 THEN COLOR 4, 7
			FOR k = 12 TO 14: LOCATE k, 1: PRINT SPACE$(80); : NEXT k
			LOCATE 12, 1: PRINT "Congratulations ! Score of"; victory(s)
			PRINT "New Entry into "; force$(s); " HALL of FAME in place "; i
			IF player = 1 AND s <> side THEN a$ = "COMPUTER": PRINT a$; " was "; force$(s); " commander": GOTO automate
who4:
			PRINT "What is name of "; force$(s); " commander"; : INPUT a$: IF a$ = "" GOTO who4
automate:
			city$(5 * (s - 1) + i) = a$
			matrix(s, i) = victory(s): GOTO foun
oldskor:
			NEXT i
foun:
			NEXT s
	       
		OPEN "O", 1, "hiscore.cws"
		FOR s = 1 TO 2
			FOR i = 1 TO 5
			WRITE #1, city$(5 * (s - 1) + i), matrix(s, i)
			NEXT i
		NEXT s: CLOSE #1: PRINT "Game Over": DO WHILE INKEY$ = "": LOOP: pcode = 1
END SUB

SUB occupy (x)
occupied(x) = 0
FOR i = 1 TO 40
IF armyloc(i) = x THEN occupied(x) = i: GOTO holdup
NEXT i
holdup:
END SUB

SUB relieve (who)
colour = 3: target = 0: hilite = 3
tlx = 67: tly = 2
CALL starfin(star, fin, who)
size = 0
FOR i = star TO fin
IF armysize(i) > 0 AND armyloc(i) > 0 AND armymove(i) = 0 THEN
	size = size + 1
	menuText$(size) = armyname$(i)
	IF LEN(menuText$(size)) > 11 THEN menuText$(size) = LEFT$(menuText$(size), 11)
	array(size) = i
END IF
NEXT i

IF size = 0 THEN EXIT SUB
CALL bubble(size)
menuText$(0) = "Relieve"
choose = 31: hilite = 11
CALL menu(6): CALL clrrite

IF choose < 1 THEN EXIT SUB
index = array(choose)
CALL icon(armyloc(index), 0, 9)

t$ = armyname$(index)
lname$(index) = t$

size = 0
FOR i = star TO fin
IF lname$(i) <> "" THEN
	size = size + 1
	menuText$(size) = lname$(i)
	IF LEN(menuText$(size)) > 11 THEN menuText$(size) = LEFT$(menuText$(size), 11)
	array(size) = i
END IF
NEXT i
CALL bubble(size)

have2:
menuText$(0) = "New Leader"
tlx = 67: tly = 2
CALL menu(0): CALL clrrite
IF choose < 1 GOTO have2
armymove(index) = -1
armylead(index) = rating(array(choose))
IF armylead(index) > 0 THEN armylead(index) = armylead(index) - 1
IF armyexper(index) > 0 THEN armyexper(index) = armyexper(index) - 1
COLOR 15: CALL clrbot: PRINT lname$(array(choose)); " has replaced "; t$; " in "; city$(armyloc(index)); : TICK 9
armyname$(index) = lname$(array(choose))
lname$(array(choose)) = ""
CALL icon(armyloc(index), 0, 8)
CALL clrbot
END SUB

SUB report (who)
DIM summ(40)
IF who = -1 GOTO frep
IF who > 100 GOTO batrep
menuText$(0) = "Information"
menuText$(1) = force$(side) + " Armies"
menuText$(2) = force$(3 - side) + " Armies"
menuText$(3) = "Cities"
menuText$(4) = "Force Summary"
menuText$(5) = "Intelligence"
menuText$(6) = "Battles": size = 6
IF LEN(DIR$("cws.his")) > 0 THEN menuText$(7) = "Recap": size = 7
CALL menu(0)
SELECT CASE choose
CASE IS < 0
	CLS
	CALL usa
	EXIT SUB
CASE 2: who = 3 - side
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
IF choose < 0 GOTO endrep
IF choose = 4 GOTO frep
CALL starfin(star, fin, who)
CLS : LOCATE 1, 1: c = 9: IF who = 2 THEN c = 15
COLOR c
PRINT " Report for "; force$(who); " Forces"; TAB(30); month$(month); ","; year; TAB(49); : COLOR 14: PRINT " Victory Points "; victory(who);
IF c = 15 THEN c = 7
x = victory(who) + victory(3 - who)
IF x = 0 THEN
	PRINT
ELSE
	y = (victory(who) / x) * 100
	PRINT "("; y; " %)";
END IF
CALL armyxy(215, 8, who)
COLOR c: PRINT control(who); "/ 40"; TAB(15); "CITIES CONTROLLED"; TAB(40); : PRINT "("; : x = INT(control(who) * 2.5 + .5): PRINT x; "%)";
PRINT TAB(50); : COLOR 12: PRINT "Capital: "; city$(capcity(who))
y = vptotal: IF capcity(1) > 0 THEN y = y + 100
IF capcity(2) > 0 THEN y = y + 100
PRINT income(who); "/"; y; TAB(15); "INCOME"; TAB(40); "("; : x = (income(who) / vptotal) * 100: PRINT x; "%)   "; : COLOR 14: PRINT "Cash:"; cash(who)
COLOR 11: PRINT " #      Name             Size  Location   Ldr Exp Suply Move To"
x = 0: FOR i = star TO fin
COLOR c
IF armyloc(i) < 1 GOTO deadeye
x = x + armysize(i)
PRINT i; TAB(5); armyname$(i); TAB(25); : y = CSRLIN
CALL strong(i): PRINT TAB(32); city$(armyloc(i));
IF who <> side THEN PRINT : GOTO deadeye
PRINT TAB(43); armylead(i); TAB(47); armyexper(i); TAB(52); supply(i);
PRINT TAB(57); : IF armymove(i) > -1 THEN PRINT city$(armymove(i)) ELSE PRINT "Resting"
IF fort(armyloc(i)) > 0 THEN LOCATE y, 68: PRINT "FORT +"; fort(armyloc(i))
deadeye:
NEXT i
PRINT " "; STRING$(70, "Ä")
PRINT " Total Forces "; TAB(25); LTRIM$(STR$(x)); "00"; TAB(40); "[ Enemy Forces "; LTRIM$(STR$(INT(aggress! * x))); "00 ]"
PRINT " "; STRING$(70, "Ä")
PRINT " "; force$(who); " NAVY has "; navysize(who); " ship(s) ";
x = 0
FOR k = 1 TO navysize(who)
	IF MID$(fleet$(who), k, 1) = "I" THEN x = x + 1
NEXT k
IF x > 0 THEN PRINT "("; x; "Ironclads) ";
IF navyloc(who) > 0 AND navyloc(who) < 99 THEN PRINT "in "; city$(navyloc(who)) ELSE PRINT
IF rr(who) > 0 THEN COLOR 14: PRINT " Army #"; rr(who); armyname$(rr(who)); " on train to "; city$(armymove(rr(who)));
LINE (0, 0)-(639, 449), 15, B
LINE (0, 62)-(639, 62), 15
GOTO endrep
'..........................................................................
'                               City Report
'..........................................................................
cityrep:
CLS : LOCATE 1, 1: COLOR 14
PRINT "City Report"; TAB(20); month$(month); ","; year: COLOR 15
PRINT " #    City       Control   Value"; TAB(41); " #    City       Control   Value"
LINE (1, 30)-(630, 30), 15
FOR i = 1 TO 20: COLOR 4: a$ = "neutral": IF cityp(i) = 1 THEN COLOR 9: a$ = "UNION"
IF cityp(i) = 2 THEN COLOR 7: a$ = "REBEL"
LOCATE 2 + i, 1: PRINT i; TAB(6); city$(i); TAB(18); a$; TAB(29); cityv(i)
NEXT i

FOR i = 21 TO 40: COLOR 4: a$ = "neutral": IF cityp(i) = 1 THEN COLOR 9: a$ = "UNION"
IF cityp(i) = 2 THEN COLOR 7: a$ = "REBEL"
LOCATE i - 18, 41: PRINT i; TAB(46); city$(i); TAB(58); a$; TAB(69); cityv(i)
NEXT i
LINE (1, 360)-(630, 360), 15
COLOR 9: LOCATE 24, 1: PRINT "Side    No. Cities   Income    Cash"
COLOR 9: PRINT force$(1); TAB(12); control(1); TAB(23); income(1); TAB(32); cash(1)
COLOR 7: PRINT force$(2); TAB(12); control(2); TAB(23); income(2); TAB(32); cash(2)
COLOR 4: PRINT force$(0); TAB(12); 40 - control(1) - control(2)
LINE (1, 382)-(630, 382), 15
GOTO endrep
'..........................................................................
'                               Intelligence
'..........................................................................
srep:
c = 9: IF side = 2 THEN c = 7
CALL usa
CALL starfin(star, fin, side)
FOR k = star TO fin
	IF armysize(k) > 0 THEN
	COLOR c
	x = cityx(armyloc(k))
	y = cityy(armyloc(k))
	z = 10: IF armysize(k) < 1000 THEN z = 9
	x = x / 8 - 2: y = y / 16
	IF y > 26 THEN y = 26
	FOR j = 0 TO 3
	LOCATE y + j, x: PRINT SPACE$(z);
	NEXT j
	LOCATE y, x: PRINT "Siz:"; : CALL strong(k)
	LOCATE y + 1, x: PRINT "Ldr:"; armylead(k)
	LOCATE y + 2, x: PRINT "Xpr:"; armyexper(k)
	LOCATE y + 3, x: PRINT "Sup:"; supply(k);
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
	IF occupied(k) > 0 THEN
		FOR j = 1 TO 40
		IF armyloc(j) = k THEN summ(k) = summ(k) + armysize(j)
		NEXT j
	END IF
NEXT k

CLS : CALL usa
FOR k = 1 TO 40
IF summ(k) > 0 THEN
	c = 9: IF cityp(k) = 2 THEN c = 7
	COLOR c
	LOCATE INT(cityy(k) / 16 + 1), cityx(k) / 8: PRINT summ(k)
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
LOCATE 14, 38: PRINT batwon(1)
LOCATE 14, 45: PRINT batwon(2)
LOCATE 17, 38: PRINT INT(.1 * casualty&(1))
LOCATE 17, 45: PRINT INT(.1 * casualty&(2))
IF history > 0 AND who > 2 THEN
	OPEN "O", #1, "battsumm"
	PRINT #1, " SIDE      BATTLES WON       LOSSES"
	FOR k = 1 TO 2
	a$ = " ": IF thrill = k THEN a$ = "*"
	PRINT #1, a$; force$(k), batwon(k), 100 * casualty&(k)
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
		who = 1: IF index > 20 THEN who = 2
		IF realism > 0 THEN
			CALL cutoff(who, armyloc(index), a)
			IF a < 1 THEN EXIT SUB
		END IF
		IF armysize(index) > 0 THEN x = cash(who) / armysize(index) * 10
		y = x + supply(index): IF y > 5 THEN x = 5 - supply(index)
		IF x < 1 THEN CALL clrbot: PRINT "Not enough funds in the Treasury to supply "; armyname$(index); : GOTO nocash
		supply(index) = supply(index) + x: cash(who) = cash(who) - .1 * x * armysize(index)
		CALL clrbot: PRINT armyname$(index); " has received supplies "; : IF noise > 0 THEN SOUND 4500, .5
nocash:
		CALL TICK(turbo!): IF cash(who) < 0 THEN cash(who) = 0
END SUB

SUB retreat (defend, x)
x = 0
IF player = 1 THEN
	IF (side = 1 AND defend > 20) OR (side = 2 AND defend < 21) THEN EXIT SUB
END IF

hilite = 13: colour = 3: tlx = 67: tly = 5: size = 0
y = armyloc(defend)
who = 1: IF defend > 20 THEN who = 2
FOR k = 1 TO 6
	IF matrix(y, k) > 0 AND cityp(matrix(y, k)) = who THEN size = size + 1: menuText$(size) = city$(matrix(y, k)): array(size) = matrix(y, k)
NEXT k
	IF size = 0 THEN EXIT SUB
	IF size = 1 THEN x = array(1): EXIT SUB
	menuText$(0) = "Retreat"
	CALL bubble(size)
	CALL menu(9)
	CALL clrrite
	IF choose < 0 OR choose > size THEN x = 0: EXIT SUB
	x = array(choose)
END SUB

SUB roman (target, a$)
a$ = "Union ": IF target > 20 THEN a$ = "Rebel "
IF target > 20 THEN target = target - 20
IF target > 10 THEN a$ = a$ + "X": target = target - 10
SELECT CASE target
	CASE IS < 4
	x = target: GOSUB add1s
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
IF x > 0 THEN FOR k = 1 TO x: a$ = a$ + "I": NEXT k
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

FOR i = 1 TO 6: LINE (x + 19 * i - 12, y + 7)-(x + 19 * i - 12 + 2, y + 40), 15, BF: NEXT i

IF noise < 2 GOTO relee
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
x = starx(i): y = stary(i)
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
IF history > 0 THEN
	OPEN "A", 2, "cws.his"
	a$ = LTRIM$(RTRIM$(a$))
	PRINT #2, a$
	CLOSE #2
END IF
END SUB

SUB shen
'                       Shenandoah
IF noise = 2 THEN
	IF INKEY$ <> "" THEN choose = 1: EXIT SUB
	PLAY "T90MFMNo1c4f8f8f4."
	IF INKEY$ <> "" THEN choose = 1: EXIT SUB
	PLAY "g8a8b-8o2d8c4."
	IF INKEY$ <> "" THEN choose = 1: EXIT SUB
	PLAY "MLf8e8MNd4.c8d8c8o1a8o2c4.c4d8d8d4."
	IF INKEY$ <> "" THEN choose = 1: EXIT SUB
	PLAY "o1a8o2c8o1a8g8f4.g4a4.f8"
	IF INKEY$ <> "" THEN choose = 1: EXIT SUB
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
IF navysize(s) = 0 OR navyloc(s) = 0 THEN navyloc(s) = 0: GOTO sink
IF navyloc(s) = 30 THEN x = 515: y = 268: GOTO float
IF navyloc(s) = 28 THEN x = 517: y = 172: GOTO float
IF navyloc(s) = 17 THEN x = 380: y = 425: GOTO float
IF navyloc(s) = 99 THEN x = 495: y = 310: GOTO float
x = cityx(navyloc(s)) + 25: y = cityy(navyloc(s)) + 25
IF navyloc(s) = 24 THEN y = y + 5: x = x - 5
float:
	PSET (x, y), 1
	a = 1: IF LEFT$(fleet$(s), 1) = "I" THEN a = 2
	CALL shipicon(s, a)
sink:
NEXT s
END SUB

SUB starfin (star, fin, who)
star = 1: fin = 20: IF who = 2 THEN star = 21: fin = 40
END SUB

SUB stax (who)
CALL starfin(star, fin, who)
FOR i = star TO fin
IF armysize(i) > 0 AND occupied(armyloc(i)) <> i THEN
	target = armyloc(i)
	x = cityx(target) - 12: y = cityy(target) - 12
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
IF who < 99 THEN CALL TICK(turbo!)
END SUB

SUB TICK (sec!)
start! = TIMER
DO WHILE TIMER - start! < sec! AND INKEY$ = "": LOOP
END SUB

SUB topbar
	LOCATE 1, 1: PRINT SPACE$(80);
	COLOR 11
	LOCATE 1, 10: PRINT "Input your decisions now for "; force$(side); " side "; : COLOR 14: PRINT month$(month); ","; year; "  "

	CALL flags((side), 0, 0)
	COLOR 4: IF bw > 0 THEN COLOR 7
	LOCATE 6, 68: PRINT "Difficulty "; LTRIM$(RTRIM$(STR$(difficult)))
	LOCATE 7, 68: PRINT "Funds:"; cash(side);

	FOR i = 1 TO 2: IF victory(i) < 0 THEN victory(i) = 0
	NEXT i
	x = victory(1) + victory(2): y = 0
	c = 9: IF side = 2 THEN c = 7
	LINE (580, 15)-(580, 35), 15
	LINE (530, 20)-(630, 30), 8 - c, BF
	IF x > 0 THEN y = 100 * (victory(side) / x)

	LINE (530, 20)-(530 + y, 30), c, BF
	COLOR c: LOCATE 4, 68: PRINT "VP :"; victory(side)

	LOCATE 5, 68: PRINT "("; y; "%)"

a$ = "  Snd": IF noise < 2 THEN a$ = "   Snd": IF noise = 0 THEN a$ = "      "
IF graf > 0 THEN a$ = a$ + " G" + LTRIM$(STR$(graf))
a$ = a$ + STR$(player)
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
IF realism = 0 THEN limit = train(who): EXIT SUB
x = 11: IF side = 2 THEN x = 23
limit = train(who) + 5 * (control(who) - x)
x = 2 * train(who)
IF limit > x THEN limit = x
IF limit < x \ 4 THEN limit = x \ 4
END SUB

SUB usa
SCREEN 12
LINE (1, 16)-(527, 440), 10, B
PAINT (200, 200), 2, 10
COLOR 10
'==========================  Mountains =================================
IF LEN(DIR$("mtn.vga")) > 0 THEN
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
IF navyloc(1) = 30 OR navyloc(2) = 30 THEN
	DRAW "C11U7R4D3L3BR6BU3D7BU4R3U3D7BR3U7BD4BR4BU4D7R4"
	LINE (485, 241)-(525, 270), 11, B
END IF

IF graf > 1 THEN CALL maptext
IF commerce > 0 THEN
LINE (447, 291)-(525, 317), 4, BF: LINE (447, 291)-(525, 317), 10, B
y = 312
a$ = "COMMERCE"
FOR j = 1 TO LEN(a$): x = ASC(MID$(UCASE$(a$), j, 1)) - 64
PSET (440 + 10 * j, y), 0: DRAW font$(x)
NEXT j
ELSE
LINE (447, 291)-(525, 335), 1, BF
END IF

FOR i = 1 TO 40
IF armyloc(i) > 0 THEN CALL placearmy(i)
NEXT i

FOR k = 1 TO 2
CALL stax(k)
NEXT k

IF player = 2 GOTO nosee
FOR i = 1 TO 40: IF armyloc(i) > 0 AND armymove(i) > 0 THEN CALL icon(armyloc(i), armymove(i), 1)
NEXT i
nosee:
CALL ships
CALL engine
COLOR 13: LOCATE 24, 51: PRINT " "; UCASE$(LEFT$(month$(month), 3)); ","; year
END SUB

SUB victor
	x = 0: FOR j = 1 TO 20: IF armyloc(j) > 0 THEN x = x + armysize(j)
	NEXT j
	y = 0: FOR j = 21 TO 40: IF armyloc(j) > 0 THEN y = y + armysize(j)
	NEXT j

	CALL clrbot: COLOR 14
	IF vicflag(2) > 0 AND year >= vicflag(2) AND month < vicflag(1) THEN
		a$ = "Time almost expired (" + month$(vicflag(1)) + "," + STR$(vicflag(2)) + ")"
		CALL image2(a$, 4)
	END IF
    FOR i = 1 TO 2
	IF (i = 1 AND y = 0) OR (i = 2 AND x = 0) THEN j = 7: victory(i) = victory(i) + 300: GOTO finis

	IF year >= vicflag(2) AND month >= vicflag(1) AND vicflag(2) > 0 THEN j = 2: GOTO finis
	IF control(i) >= vicflag(3) AND vicflag(3) > 0 THEN j = 3: GOTO finis
	IF income(i) / (income(1) + income(2)) >= .01 * vicflag(4) AND vicflag(4) > 0 THEN j = 4: GOTO finis
	IF vicflag(5) > 0 AND capcity(3 - i) = 0 AND capcity(i) > 0 THEN j = 5: GOTO finis

	IF vicflag(6) > 0 THEN
		IF i = 1 THEN
			IF y = 0 THEN j = 7: GOTO finis
			IF x / y > vicflag(6) THEN j = 6: GOTO finis
		END IF
		IF i = 2 THEN
			IF x = 0 THEN j = 7: GOTO finis
			IF y / x > vicflag(6) THEN j = 6: GOTO finis
		END IF
	END IF

	CALL clrbot: COLOR 14
	IF vicflag(3) > 0 AND control(i) >= .9 * vicflag(3) THEN
		a$ = force$(i) + " side almost controls" + STR$(vicflag(3)) + " cities"
		CALL image2(a$, 4)
	END IF

	IF vicflag(4) > 0 AND income(i) / (income(1) + income(2)) >= .009 * vicflag(4) THEN
		a$ = force$(i) + " side close to" + STR$(vicflag(4)) + " % of total income"
		CALL image2(a$, 4)
	END IF

	IF vicflag(6) > 0 AND x > 0 AND y > 0 THEN
		IF (i = 1 AND x / y > .9 * vicflag(6)) OR (i = 2 AND y / x > .9 * vicflag(6)) THEN
		a$ = force$(i) + "side close to" + STR$(vicflag(6)) + ":1 strength ratio"
		CALL image2(a$, 4)
		END IF
	END IF
	GOTO stale

finis:
	SELECT CASE j
		CASE IS < 3
		a$ = "TIME EXPIRED"
		CASE 3
		a$ = STR$(2.5 * vicflag(3)) + "% CITIES CONTROLLED"
		CASE 4
		a$ = STR$(vicflag(4)) + " % OF TOTAL INCOME"
		CASE 5
		a$ = "CAPITAL CAPTURED"
		CASE 6
		a$ = STR$(vicflag(6)) + ":1 ARMY STRENGTH RATIO"
		CASE 7
		a$ = "ENEMY ANNIHILATED"
END SELECT
	CLS
	c = 1: IF i = 2 THEN c = 7
	LINE (0, 0)-(639, 479), 4, BF
	LINE (0, 40)-(550, 460), 0, BF
	CALL usa
	LINE (70, 140)-(485, 265), 0, BF
	LINE (50, 120)-(465, 250), c, BF
	LINE (50, 120)-(465, 250), 4, B
	COLOR 14
	t$ = force$(i) + " SIDE IS WINNING"
	IF j = 2 THEN CALL center(10, "Confederates will win a technical victory") ELSE CALL center(10, t$)

	COLOR 15
	t$ = "END GAME VICTORY CONDITION" + STR$(j - 1) + " REACHED"
	CALL center(12, t$)
	CALL center(14, a$)

	menuText$(0) = "End Game"
	menuText$(1) = "Yes"
	menuText$(2) = "No-Override"
	size = 2: colour = 4
	tlx = 27: tly = 18
	hilite = 15
	IF j = 7 THEN size = 1
	CALL menu(0)

	IF choose <> 1 AND j < 7 THEN
play4ever:
			vicflag(j) = vicflag(j) + 1
			IF j = 5 THEN vicflag(j) = 0
			CLS
			CALL usa
			EXIT SUB
	END IF
	menuText$(0) = "Options"
	menuText$(1) = "Quit this Game"
	menuText$(2) = "Play More"
	IF player = 1 THEN menuText$(2) = "No - Press Onward to " + city$(capcity(3 - side))
	size = 2: colour = 8
	tlx = 27: tly = 18
	IF j <> 7 THEN
		CALL menu(0)
		IF choose <> 1 GOTO play4ever
	ELSE
		victory(i) = victory(i) + 100
	END IF

	thrill = i
	CALL usa: CALL report(100 + side)
	IF j = 2 THEN FOR k = 1 TO 2: victory(k) = .7 * victory(k): NEXT k: CALL rwin: GOTO death

	IF i = 1 THEN CALL capitol: COLOR 15: LOCATE 2, 27: t$ = "UNION VICTORY  VP's=" + STR$(victory(1)): PRINT t$: GOTO death
	IF i = 2 THEN CALL rwin: COLOR 15: LOCATE 2, 27: t$ = "REBEL VICTORY  VP's=" + STR$(victory(2)): PRINT t$
death:
	COLOR 14: LOCATE 4, 40 - .5 * LEN(a$)
	IF history > 0 THEN
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
  x = matrix(a, j): IF x = 0 GOTO tally5
  IF cityp(x) = side AND occupied(x) > 0 THEN y = y + armysize(occupied(x))
	FOR k = 1 TO 6: m = matrix(x, k): IF m = 0 OR m = a GOTO tally4
	IF cityp(m) = side AND occupied(m) > 0 THEN y = y + .1 * armysize(occupied(m))
tally4:
	NEXT k
NEXT j
tally5:
END SUB

