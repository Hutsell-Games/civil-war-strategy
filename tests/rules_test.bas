' Unit tests of the game's rules that draw nothing.
' Run from the repo's folder:  qb64rust test tests
'
' Each test runs in a program of its own, so every shared array starts at
' zero. A test sets the few values the SUB reads, calls it and checks what
' the code gives today. These tests record behavior; they do not judge it.
' The Union's armies are 1 to 20, the Rebels' 21 to 40. Side 1 is the Union.

'$INCLUDE: '../cws14.bi'

' ------------------------------------------------------------------ starfin
' The first and last army of a side.

SUB TestStarfinGivesEachSidesArmies
CALL starfin(star, fin, 1)
AssertEqualInt 1, star, "the Union's first"
AssertEqualInt 20, fin, "the Union's last"
CALL starfin(star, fin, 2)
AssertEqualInt 21, star, "the Rebels' first"
AssertEqualInt 40, fin, "the Rebels' last"
END SUB

' --------------------------------------------------------- bub2 and bubble
' bub2 sorts brray. bubble sorts the menu's texts and keeps array beside them.

SUB TestBub2SortsBrray
brray(1) = 30: brray(2) = 10: brray(3) = 20: brray(4) = 5
CALL bub2(3)
AssertEqualInt 10, brray(1), "first"
AssertEqualInt 20, brray(2), "second"
AssertEqualInt 30, brray(3), "third"
AssertEqualInt 5, brray(4), "past the limit: left alone"
END SUB

SUB TestBubbleSortsTextsAndKeepsArrayBeside
mtx$(1) = "Richmond": array(1) = 25
mtx$(2) = "Atlanta": array(2) = 31
mtx$(3) = "Memphis": array(3) = 17
CALL bubble(3)
AssertEqualStr "Atlanta", mtx$(1), "first"
AssertEqualInt 31, array(1), "its city"
AssertEqualStr "Memphis", mtx$(2), "second"
AssertEqualStr "Richmond", mtx$(3), "third"
AssertEqualInt 25, array(3), "its city"
END SUB

' -------------------------------------------------------------------- roman
' The name of a general the game makes up: the side and the army's number
' in Roman numerals. It changes target, which the caller gives as a copy.

SUB TestRomanNamesUnionArmies
t = 1: CALL roman(t, a$): AssertEqualStr "Union I", a$, "1"
t = 3: CALL roman(t, a$): AssertEqualStr "Union III", a$, "3"
t = 4: CALL roman(t, a$): AssertEqualStr "Union IV", a$, "4"
t = 5: CALL roman(t, a$): AssertEqualStr "Union V", a$, "5"
t = 8: CALL roman(t, a$): AssertEqualStr "Union VIII", a$, "8"
t = 9: CALL roman(t, a$): AssertEqualStr "Union IX", a$, "9"
t = 10: CALL roman(t, a$): AssertEqualStr "Union X", a$, "10"
t = 14: CALL roman(t, a$): AssertEqualStr "Union XIV", a$, "14"
t = 20: CALL roman(t, a$): AssertEqualStr "Union XX", a$, "20"
END SUB

SUB TestRomanNamesRebelArmiesFromOne
t = 21: CALL roman(t, a$): AssertEqualStr "Rebel I", a$, "21"
t = 36: CALL roman(t, a$): AssertEqualStr "Rebel XVI", a$, "36"
t = 40: CALL roman(t, a$): AssertEqualStr "Rebel XX", a$, "40"
END SUB

SUB TestRomanChangesItsTarget
t = 36: CALL roman(t, a$)
AssertEqualInt 6, t, "36 comes back as 6"
END SUB

' ------------------------------------------------------------------- occupy
' occupied(x) is the first army in city x, or 0.

SUB TestOccupyFindsTheFirstArmyInACity
armyloc(3) = 7: armyloc(5) = 7: armyloc(22) = 9
CALL occupy(7): AssertEqualInt 3, occupied(7), "two armies: the first"
CALL occupy(9): AssertEqualInt 22, occupied(9), "a Rebel army"
occupied(8) = 4
CALL occupy(8): AssertEqualInt 0, occupied(8), "no army: set back to 0"
END SUB

' ------------------------------------------------------------------- cutoff
' a counts the cities linked to target that who holds; 0 means cut off.

SUB TestCutoffCountsFriendlyNeighbors
matrix(5, 1) = 2: matrix(5, 2) = 3: matrix(5, 3) = 4
cityp(2) = 1: cityp(3) = 2: cityp(4) = 1
CALL cutoff(1, 5, a): AssertEqualInt 2, a, "the Union holds two neighbors"
CALL cutoff(2, 5, a): AssertEqualInt 1, a, "the Rebels hold one"
cityp(3) = 0
CALL cutoff(2, 5, a): AssertEqualInt 0, a, "cut off"
END SUB

' ------------------------------------------------------------ traincapacity
' Without realism the capacity is the side's own. With it, the capacity
' grows with the cities held, between half and twice the side's own. The
' cities are counted from 11 when the player is the Union and from 23 when
' the player is the Rebels, whichever side who is.

SUB TestTraincapacityWithoutRealism
train(1) = 600: train(2) = 300: realism = 0
CALL traincapacity(1, limit): AssertEqualInt 600, limit, "the Union"
CALL traincapacity(2, limit): AssertEqualInt 300, limit, "the Rebels"
END SUB

SUB TestTraincapacityWithRealism
train(1) = 600: realism = 1: side = 1
control(1) = 14: CALL traincapacity(1, limit): AssertEqualInt 615, limit, "14 cities"
control(1) = 11: CALL traincapacity(1, limit): AssertEqualInt 600, limit, "11 cities"
control(1) = 5: CALL traincapacity(1, limit): AssertEqualInt 570, limit, "5 cities"
train(1) = 20
control(1) = 0: CALL traincapacity(1, limit): AssertEqualInt 10, limit, "never less than half"
control(1) = 40: CALL traincapacity(1, limit): AssertEqualInt 40, limit, "never more than twice"
END SUB

SUB TestTraincapacityCountsByPlayersSide
train(1) = 600: realism = 1: control(1) = 23
side = 2
CALL traincapacity(1, limit): AssertEqualInt 600, limit, "the Union's trains when the player is the Rebels"
END SUB

' --------------------------------------------------------------------- void
' The strength the player's side has around city a: the armies in the
' cities linked to it, and a tenth of those one city further.

SUB TestVoidAddsNearbyArmies
side = 1
matrix(1, 1) = 2: cityp(2) = 1: occupied(2) = 4: armysize(4) = 50
matrix(2, 1) = 3: cityp(3) = 1: occupied(3) = 6: armysize(6) = 40
matrix(2, 2) = 1
CALL void(1, y)
AssertEqualInt 54, y, "50 beside and a tenth of 40 further"
END SUB

SUB TestVoidIsZeroWithNoArmyNear
side = 1
matrix(1, 1) = 2: cityp(2) = 2: occupied(2) = 24: armysize(24) = 50
CALL void(1, y)
AssertEqualInt 0, y, "the enemy's army does not count"
END SUB

' ----------------------------------------------------------------- barnacle
' A fleet loses its last ship.

SUB TestBarnacleRemovesTheLastShip
navysize(1) = 3: fleet$(1) = "WIW": navyloc(1) = 30
CALL barnacle(1)
AssertEqualInt 2, navysize(1), "two ships left"
AssertEqualStr "WI", fleet$(1), "the last one gone"
AssertEqualInt 30, navyloc(1), "still there"
END SUB

SUB TestBarnacleEndsAFleetOfOne
navysize(2) = 1: fleet$(2) = "I": navyloc(2) = 27
CALL barnacle(2)
AssertEqualInt 0, navysize(2), "no ships"
AssertEqualStr "", fleet$(2), "no fleet"
AssertEqualInt 0, navyloc(2), "nowhere"
END SUB

' ------------------------------------------------------------------- normal
' A draw around xbar with the variance vary. It sums 12 RNDs and takes off
' 5.5, though the sum averages 6, so the draws center on xbar + SQR(vary) / 2.

SUB TestNormalDrawsHigh
RANDOMIZE 1
total& = 0
FOR i = 1 TO 2000
	CALL normal(100, 100, r)
	total& = total& + r
NEXT i
avg! = total& / 2000
AssertTrue avg! > 103 AND avg! < 107, "the average of 2000 draws is near 105, not 100:" + STR$(avg!)
END SUB

SUB TestNormalWithNoVarianceIsTheMean
CALL normal(70, 0, r)
AssertEqualInt 70, r, "variance 0"
END SUB

' ---------------------------------------------------------------- commander
' The next general of a side that has no army: one from the list of names,
' or a made-up one when the list is used up.

SUB TestCommanderTakesTheFirstFreeName
lname$(1) = "Grant": armyloc(1) = 5
lname$(2) = "Pope"
lname$(3) = "Meade"
CALL commander(1, empty)
AssertEqualInt 2, empty, "Grant has an army; Pope is next"
END SUB

SUB TestCommanderMakesUpANameAfterTheList
RANDOMIZE 1
CALL commander(2, empty)
AssertEqualInt 21, empty, "the Rebels' first army"
AssertEqualStr "Rebel I", lname$(21), "its made-up name"
AssertTrue rating(21) >= 1 AND rating(21) <= 9, "a rating from 1 to 9:" + STR$(rating(21))
END SUB

' ---------------------------------------------------------------------- mxw
' The width of a menu: its longest entry, or its title and one more.

SUB TestMxwIsTheLongestEntry
mtx$(0) = "Main": mtx$(1) = "Troops": mtx$(2) = "Railroad": mtx$(3) = "END TURN": size = 3
CALL mxw(wide)
AssertEqualInt 8, wide, "Railroad"
mtx$(0) = "VGA CIVILWAR STRATEGY"
CALL mxw(wide)
AssertEqualInt 22, wide, "the title and one more"
END SUB

' ------------------------------------------------------- QB64.BM, SCRIPT.BM

SUB TestDirFindsAFileByPattern
d$ = TestTempDir$ + "/"
AssertEqualStr "", DIR$(d$ + "*.sav"), "no saved game"
f = FREEFILE: OPEN d$ + "cws3.sav" FOR OUTPUT AS #f: PRINT #f, "x": CLOSE #f
AssertEqualStr "CWS3.SAV", DIR$(d$ + "*.sav"), "found, in upper case"
AssertEqualStr "CWS3.SAV", DIR$(d$ + "cws3.sav"), "found by its name"
AssertEqualStr "", DIR$(d$ + "cws4.sav"), "another name"
END SUB

SUB TestScriptdateIsFixedUnderAScript
AssertEqualStr DATE$, scriptdate$, "not scripted: today"
scripted = 1
AssertEqualStr "01-01-2000", scriptdate$, "scripted"
END SUB

' Under a script, scriptshell copies in BASIC instead of SHELL, whose
' cmd.exe would show a console window. The test sets scripted first, so it
' never runs a SHELL.
SUB TestScriptshellCopiesAFile
scripted = 1
d$ = TestTempDir$ + "/"
f = FREEFILE: OPEN d$ + "cws.his" FOR OUTPUT AS #f: PRINT #f, "history": CLOSE #f
f = FREEFILE: OPEN d$ + "oldhist.ory" FOR OUTPUT AS #f: PRINT #f, "an older and longer one": CLOSE #f
CALL scriptshell("copy " + d$ + "cws.his " + d$ + "oldhist.ory")
f = FREEFILE: OPEN d$ + "oldhist.ory" FOR INPUT AS #f: LINE INPUT #f, a$: CLOSE #f
AssertEqualStr "history", a$, "the copy replaces the old file"
END SUB

'$INCLUDE: '../cwstrat1.bm'
'$INCLUDE: '../cwstrat2.bm'
'$INCLUDE: '../cwsmenu.bm'
'$INCLUDE: '../battle.bm'
'$INCLUDE: '../computer.bm'
'$INCLUDE: '../ending.bm'
'$INCLUDE: '../files.bm'
'$INCLUDE: '../navy.bm'
'$INCLUDE: '../railroad.bm'
'$INCLUDE: '../report.bm'
'$INCLUDE: '../turn.bm'
'$INCLUDE: '../drawings/map.bm'
'$INCLUDE: '../drawings/schooner.bm'
'$INCLUDE: '../drawings/ironclad.bm'
'$INCLUDE: '../drawings/cannon.bm'
'$INCLUDE: '../drawings/capitol.bm'
'$INCLUDE: '../drawings/rwin.bm'
'$INCLUDE: '../drawings/surrender.bm'
'$INCLUDE: '../drawings/icons.bm'
'$INCLUDE: '../qb64.bm'
'$INCLUDE: '../script.bm'
