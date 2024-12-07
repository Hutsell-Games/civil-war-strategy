'============================================================================
'                GENmenu 3.05 : Generic Menu Main Module Level  12/91
'                Updated to Use Graphic Screens 8, 9, 12
'============================================================================
'       globalTLX  = top left x  (if zero, automatically centered)
'       globalTLY = top left y   (if zero, automatically centered)
'       size = # rows (current maximum=20)
'       globalMTX$() = text for menu
'                globalMTX$(0) = heading (blank defaults to M E N U)
'                globalMTX$(1-size) are options
'       globalChoose = option selected (row #)
'            -1 indicates ESC key pressed
'            entering with globalChoose+21 causes globalChoose to be default entry
'       globalWType = window type (0 = no line; 1=single line;
'                            2=double line
'               if >10 then 10's digit=box color  1's digit= window type

SUB choices (b1, wide)
boxc = globalColour: IF globalWType > 10 THEN boxc = INT(globalWType / 10): globalWType = globalWType - 10 * boxc
COLOR boxc
VIEW (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + size + 2) + 8)
CLS 1
VIEW
LINE (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + size + 2) + 8), globalColour, B
LINE (8 * globalTLX - 2, 16 * (globalTLY + 1) + 3)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + 1) + 6), globalColour, B
IF ABS(globalWType) = 2 THEN
LINE (8 * globalTLX - 2, 16 * globalTLY - 8)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + size + 2) + 4), globalColour, B
END IF
COLOR globalColour

LOCATE globalTLY + 1, globalTLX + b1: PRINT globalMTX$(0)
FOR i = 1 TO size
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
	IF row > size THEN row = 1
	globalChoose = row
	row1 = row
       
	IF globalTLY = 0 THEN globalTLY = INT(11.5 - .5 * size)
	IF globalTLY + size > 26 THEN globalTLY = 26 - size
       
	brx = globalTLX + wide + 1
	bry = globalTLY + size + 3
       
	boxc = globalColour: IF globalWType > 10 THEN boxc = INT(globalWType / 10): globalWType = globalWType - 10 * boxc

	COLOR boxc

	VIEW (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + size + 2) + 8)
	CLS 1
	VIEW
	LINE (8 * globalTLX - 6, 16 * globalTLY - 11)-(8 * (globalTLX + wide + 1) + 7, 16 * (globalTLY + size + 2) + 8), globalColour, B
	LINE (8 * globalTLX - 2, 16 * (globalTLY + 1) + 3)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + 1) + 6), globalColour, B
	IF ABS(globalWType) = 2 THEN
		LINE (8 * globalTLX - 2, 16 * globalTLY - 8)-(8 * (globalTLX + wide + 1) + 3, 16 * (globalTLY + size + 2) + 4), globalColour, B
	END IF

	COLOR globalColour
	b1 = INT(.5 * (wide - LEN(globalMTX$(0))) + .5) + 1

	CALL choices(b1, wide)
sel1:
	SELECT CASE switch
		CASE 1: CALL icon(globalArray(row), 0, 7)
		CASE 2: CALL icon(globalArray(row), 0, 9)
			target = globalOccupied(globalArray(row))
			IF target > 0 THEN
			flag = 1
			t$ = globalArmyName$(target)
			IF LEN(t$) > wide THEN t$ = LEFT$(t$, wide)
			COLOR 12
			LOCATE globalTLY + 2 + row, globalTLX + 2: PRINT SPACE$(wide);
			LOCATE globalTLY + 2 + row, globalTLX + 2: PRINT t$;
			LOCATE globalTLY + 4 + size, globalTLX + 1: PRINT SPACE$(12);
			LOCATE globalTLY + 4 + size, globalTLX + 1: PRINT "Size"; globalArmySize(target);
			x = POS(0): y = CSRLIN: LOCATE y, x - 1: PRINT "00";
			ELSE
			flag = 0
			LOCATE globalTLY + 4 + size, globalTLX + 1: PRINT SPACE$(12);
			END IF
		CASE 4: CALL armystat(globalArray(row))
		CASE 5: COLOR 11: CALL clrbot: PRINT globalArmyName$(index); "  Exp="; globalArmyExper(index); " Cash="; globalCash(side);
		CASE 6: CALL icon(globalArmyLoc(globalArray(row)), 0, 9)
		CASE 8
			IF globalGraf > 2 AND row > 0 THEN
				LINE (548, 148)-(592, 216), 15, B
				a = row: IF side = 1 THEN a = 6 - row
				t$ = "face" + LTRIM$(STR$(a)) + ".vga"
				IF _FILEEXISTS(t$) THEN
					DEF SEG = VARSEG(graft(1))
					BLOAD t$, VARPTR(graft(1))
					DEF SEG
					PUT (550, 150), graft, PSET
					IF side = 2 THEN
						PAINT (560, 160), 8, 0
						PAINT (570, 155), 7, 0
					END IF
				END IF
			END IF
		CASE 9: CALL icon(globalArray(row), 0, 9)
	END SELECT
	IF flag = 0 THEN
		COLOR globalHilite
		LOCATE globalTLY + 2 + row, globalTLX + 2
		PRINT globalMTX$(row)
		IF globalBW > 0 THEN LINE (8 * (globalTLX + 1), 16 * (globalTLY + row + 1))-(8 * (globalTLX + LEN(globalMTX$(row)) + 1) - 1, 16 * (globalTLY + row + 2) - 1), globalHilite, B
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
crsr:   a$ = INKEY$: IF a$ = "" GOTO crsr
	IF ASC(a$) = 13 THEN RETURN
	IF ASC(a$) = 2 THEN GOTO boss
	IF LEN(a$) = 2 GOTO arrows
	IF switch = 3 THEN globalChoose = -ASC(UCASE$(a$)): GOTO called
	IF ASC(a$) = 27 THEN globalChoose = -1: GOTO called
		row1 = row
		FOR k = 1 TO size
		c1$ = UCASE$(LEFT$(LTRIM$(globalMTX$(k)), 1))
		IF c1$ = UCASE$(a$) THEN globalChoose = k: GOSUB limits: GOTO called
		NEXT k
	GOTO crsr
arrows:
	a$ = RIGHT$(a$, 1)
	row1 = row
	 IF a$ = "H" THEN row = row - 1: GOSUB limits: RETURN
	 IF a$ = "I" THEN row = 1: GOSUB limits: RETURN
	 IF a$ = "P" THEN row = row + 1: GOSUB limits: RETURN
	 IF a$ = "Q" THEN row = size: GOSUB limits: RETURN
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
	IF row > size THEN row = 1
	IF row < 1 THEN row = size
	RETURN
noadjust:
	IF globalTLX = 0 THEN globalTLX = INT(40.5 - .5 * wide)
	RETURN
boss:
	CALL scrnsavr
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
	FOR i = 1 TO size
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

SUB scrnsavr
SCREEN 12
most = 5
CLS
sec! = 0
DO WHILE TIMER - sec! < .5: LOOP
DIM x(2), y(2)
RANDOMIZE TIMER
boxes = 1: IF RND > .5 THEN boxes = 0: aspect! = 1: IF RND > .5 THEN aspect! = .5: IF RND > .5 THEN aspect! = 2

dx = 20: dy = 5: c = 1
GOSUB newbox

animate:
IF boxes = 0 THEN
	CIRCLE (x(1), y(1)), .5 * ABS(x(1) - x(2)), c, , , aspect!
ELSE
	LINE (x(1), y(1))-(x(2), y(2)), c, B
END IF
PAINT (x(1) + 1, y(1) + 1), 16 * RND, c

sec! = TIMER
DO: a$ = INKEY$: LOOP WHILE a$ = "" AND TIMER - sec! < .1
IF a$ <> "" THEN IF ASC(a$) = 2 THEN EXIT SUB

x(1) = x(1) + dx
x(2) = x(2) + dx

IF x(1) < 1 THEN dx = 20: x(1) = 1: GOSUB newbox1
IF x(2) > 675 THEN dx = -20: GOSUB newbox1

y(1) = y(1) + dy
y(2) = y(2) + dy
IF y(1) < 1 THEN dy = 5: y(1) = 1: GOSUB newbox1
IF y(2) > 480 THEN dy = -5: GOSUB newbox1

GOTO animate
	    
newbox:
x(1) = 1 + 650 * RND
IF x(1) < 1 THEN x(1) = 1
x(2) = x(1) + 30 + 50 * RND: IF x(2) > 639 THEN x(2) = 639
IF x(2) < 1 THEN x(2) = x(1)

y(1) = 10 + 100 * RND
y(2) = y(1) + 50 + 120 * RND
RETURN

newbox1:
reps = reps + 1
IF reps >= most THEN CLS : reps = 0: most = 3 + 10 * RND: IF RND > .9 THEN boxes = 1 - boxes
y(2) = y(1) + 20 + 100 * RND
IF y(2) > 475 THEN y(2) = 475
x(2) = x(1) + 50 + 50 * RND
IF x(2) > 675 THEN x(2) = 675
c = c + 1
IF c > 15 THEN c = 1
IF RND > .5 THEN RETURN
IF dy = 5 THEN dy = 5 + 10 * RND
IF dy = -5 THEN dy = -5 - 10 * RND
IF boxes = 0 THEN aspect! = 1: IF RND > .5 THEN aspect! = .5: IF RND > .5 THEN aspect! = 2
RETURN

END SUB

