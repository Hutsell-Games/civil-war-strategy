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
star = side_first_army(1): fin = side_last_army(1)
AssertEqualInt 1, star, "the Union's first"
AssertEqualInt 20, fin, "the Union's last"
star = side_first_army(2): fin = side_last_army(2)
AssertEqualInt 21, star, "the Rebels' first"
AssertEqualInt 40, fin, "the Rebels' last"
END SUB

' --------------------------------------------------------- bub2 and bubble
' bub2 sorts brray. bubble sorts the menu's texts and keeps array beside them.

SUB TestBub2SortsBrray
move_order_key(1) = 30: move_order_key(2) = 10: move_order_key(3) = 20: move_order_key(4) = 5
CALL sort_move_order(3)
AssertEqualInt 10, move_order_key(1), "first"
AssertEqualInt 20, move_order_key(2), "second"
AssertEqualInt 30, move_order_key(3), "third"
AssertEqualInt 5, move_order_key(4), "past the limit: left alone"
END SUB

SUB TestBubbleSortsTextsAndKeepsArrayBeside
menu_text$(1) = "Richmond": menu_value(1) = 25
menu_text$(2) = "Atlanta": menu_value(2) = 31
menu_text$(3) = "Memphis": menu_value(3) = 17
CALL menu_bubble_sort(3)
AssertEqualStr "Atlanta", menu_text$(1), "first"
AssertEqualInt 31, menu_value(1), "its city"
AssertEqualStr "Memphis", menu_text$(2), "second"
AssertEqualStr "Richmond", menu_text$(3), "third"
AssertEqualInt 25, menu_value(3), "its city"
END SUB

' -------------------------------------------------------------------- roman
' The name of a general the game makes up: the side and the army's number
' in Roman numerals. It changes target, which the caller gives as a copy.

SUB TestRomanNamesUnionArmies
t = 1: CALL army_generate_name(t, a$): AssertEqualStr "Union I", a$, "1"
t = 3: CALL army_generate_name(t, a$): AssertEqualStr "Union III", a$, "3"
t = 4: CALL army_generate_name(t, a$): AssertEqualStr "Union IV", a$, "4"
t = 5: CALL army_generate_name(t, a$): AssertEqualStr "Union V", a$, "5"
t = 8: CALL army_generate_name(t, a$): AssertEqualStr "Union VIII", a$, "8"
t = 9: CALL army_generate_name(t, a$): AssertEqualStr "Union IX", a$, "9"
t = 10: CALL army_generate_name(t, a$): AssertEqualStr "Union X", a$, "10"
t = 14: CALL army_generate_name(t, a$): AssertEqualStr "Union XIV", a$, "14"
t = 20: CALL army_generate_name(t, a$): AssertEqualStr "Union XX", a$, "20"
END SUB

SUB TestRomanNamesRebelArmiesFromOne
t = 21: CALL army_generate_name(t, a$): AssertEqualStr "Rebel I", a$, "21"
t = 36: CALL army_generate_name(t, a$): AssertEqualStr "Rebel XVI", a$, "36"
t = 40: CALL army_generate_name(t, a$): AssertEqualStr "Rebel XX", a$, "40"
END SUB

SUB TestRomanChangesItsTarget
t = 36: CALL army_generate_name(t, a$)
AssertEqualInt 6, t, "36 comes back as 6"
END SUB

' ------------------------------------------------------------------- occupy
' occupied(x) is the first army in city x, or 0.

SUB TestOccupyFindsTheFirstArmyInACity
army_city(3) = 7: army_city(5) = 7: army_city(22) = 9
CALL city_update_occupier(7): AssertEqualInt 3, city_army(7), "two armies: the first"
CALL city_update_occupier(9): AssertEqualInt 22, city_army(9), "a Rebel army"
city_army(8) = 4
CALL city_update_occupier(8): AssertEqualInt 0, city_army(8), "no army: set back to 0"
END SUB

' ------------------------------------------------------------------- cutoff
' a counts the cities linked to target that who holds; 0 means cut off.

SUB TestCutoffCountsFriendlyNeighbors
city_road(5, 1) = 2: city_road(5, 2) = 3: city_road(5, 3) = 4
city_owner(2) = 1: city_owner(3) = 2: city_owner(4) = 1
a = city_is_connected(1, 5): AssertEqualInt 2, a, "the Union holds two neighbors"
a = city_is_connected(2, 5): AssertEqualInt 1, a, "the Rebels hold one"
city_owner(3) = 0
a = city_is_connected(2, 5): AssertEqualInt 0, a, "cut off"
END SUB

' ------------------------------------------------------------ traincapacity
' Without realism the capacity is the side's own. With it, the capacity
' grows with the cities held, between half and twice the side's own. The
' cities are counted from 11 when the player is the Union and from 23 when
' the player is the Rebels, whichever side who is.

SUB TestTraincapacityWithoutRealism
train_capacity(1) = 600: train_capacity(2) = 300: opt_realism = 0
limit = railroad_capacity(1): AssertEqualInt 600, limit, "the Union"
limit = railroad_capacity(2): AssertEqualInt 300, limit, "the Rebels"
END SUB

SUB TestTraincapacityWithRealism
train_capacity(1) = 600: opt_realism = 1: current_side = 1
side_city_count(1) = 14: limit = railroad_capacity(1): AssertEqualInt 615, limit, "14 cities"
side_city_count(1) = 11: limit = railroad_capacity(1): AssertEqualInt 600, limit, "11 cities"
side_city_count(1) = 5: limit = railroad_capacity(1): AssertEqualInt 570, limit, "5 cities"
train_capacity(1) = 20
side_city_count(1) = 0: limit = railroad_capacity(1): AssertEqualInt 10, limit, "never less than half"
side_city_count(1) = 40: limit = railroad_capacity(1): AssertEqualInt 40, limit, "never more than twice"
END SUB

SUB TestTraincapacityCountsByPlayersSide
train_capacity(1) = 600: opt_realism = 1: side_city_count(1) = 23
current_side = 2
limit = railroad_capacity(1): AssertEqualInt 600, limit, "the Union's trains when the player is the Rebels"
END SUB

' --------------------------------------------------------------------- void
' The strength the player's side has around city a: the armies in the
' cities linked to it, and a tenth of those one city further.

SUB TestVoidAddsNearbyArmies
current_side = 1
city_road(1, 1) = 2: city_owner(2) = 1: city_army(2) = 4: army_size(4) = 50
city_road(2, 1) = 3: city_owner(3) = 1: city_army(3) = 6: army_size(6) = 40
city_road(2, 2) = 1
y = city_nearby_enemy_strength(1)
AssertEqualInt 54, y, "50 beside and a tenth of 40 further"
END SUB

SUB TestVoidIsZeroWithNoArmyNear
current_side = 1
city_road(1, 1) = 2: city_owner(2) = 2: city_army(2) = 24: army_size(24) = 50
y = city_nearby_enemy_strength(1)
AssertEqualInt 0, y, "the enemy's army does not count"
END SUB

' ----------------------------------------------------------------- barnacle
' A fleet loses its last ship.

SUB TestBarnacleRemovesTheLastShip
fleet_size(1) = 3: fleet_ships$(1) = "WIW": fleet_city(1) = 30
CALL navy_remove_ship(1)
AssertEqualInt 2, fleet_size(1), "two ships left"
AssertEqualStr "WI", fleet_ships$(1), "the last one gone"
AssertEqualInt 30, fleet_city(1), "still there"
END SUB

SUB TestBarnacleEndsAFleetOfOne
fleet_size(2) = 1: fleet_ships$(2) = "I": fleet_city(2) = 27
CALL navy_remove_ship(2)
AssertEqualInt 0, fleet_size(2), "no ships"
AssertEqualStr "", fleet_ships$(2), "no fleet"
AssertEqualInt 0, fleet_city(2), "nowhere"
END SUB

' ------------------------------------------------------------------- normal
' A draw around xbar with the variance vary. It sums 12 RNDs and takes off
' 5.5, though the sum averages 6, so the draws center on xbar + SQR(vary) / 2.

SUB TestNormalDrawsHigh
RANDOMIZE 1
total& = 0
FOR i = 1 TO 2000
	CALL normal_random_number(100, 100, r)
	total& = total& + r
NEXT i
avg! = total& / 2000
AssertTrue avg! > 103 AND avg! < 107, "the average of 2000 draws is near 105, not 100:" + STR$(avg!)
END SUB

SUB TestNormalWithNoVarianceIsTheMean
CALL normal_random_number(70, 0, r)
AssertEqualInt 70, r, "variance 0"
END SUB

' ---------------------------------------------------------------- commander
' The next general of a side that has no army: one from the list of names,
' or a made-up one when the list is used up.

SUB TestCommanderTakesTheFirstFreeName
leader_name$(1) = "Grant": army_city(1) = 5
leader_name$(2) = "Pope"
leader_name$(3) = "Meade"
CALL army_get_commander(1, empty)
AssertEqualInt 2, empty, "Grant has an army; Pope is next"
END SUB

SUB TestCommanderMakesUpANameAfterTheList
RANDOMIZE 1
CALL army_get_commander(2, empty)
AssertEqualInt 21, empty, "the Rebels' first army"
AssertEqualStr "Rebel I", leader_name$(21), "its made-up name"
AssertTrue leader_rating(21) >= 1 AND leader_rating(21) <= 9, "a rating from 1 to 9:" + STR$(leader_rating(21))
END SUB

' ---------------------------------------------------------------------- mxw
' The width of a menu: its longest entry, or its title and one more.

SUB TestMxwIsTheLongestEntry
menu_text$(0) = "Main": menu_text$(1) = "Troops": menu_text$(2) = "Railroad": menu_text$(3) = "END TURN": menu_item_count = 3
wide = menu_measure_width
AssertEqualInt 8, wide, "Railroad"
menu_text$(0) = "VGA CIVILWAR STRATEGY"
wide = menu_measure_width
AssertEqualInt 22, wide, "the title and one more"
END SUB

' ------------------------------------------- army_detach and army_drill

SUB TestDetachTakesThreeTenths
army_size(21) = 100: army_supply(21) = 10: army_experience(21) = 4: army_city(21) = 25
leader_name$(22) = "Jackson": leader_rating(22) = 9: army_order(22) = 7
CALL army_detach(21, 25, 22)
AssertEqualInt 30, army_size(22), "the new army's men"
AssertEqualInt 70, army_size(21), "the old army's men"
AssertEqualInt 3, army_supply(22), "the new army's supplies"
AssertEqualInt 7, army_supply(21), "the old army's supplies"
AssertEqualInt 25, army_city(22), "in the same city"
AssertEqualInt 4, army_experience(22), "the old army's experience"
AssertEqualInt 9, army_leader_rating(22), "the slot's leader"
AssertEqualStr "Jackson", army_name$(22), "named for the leader"
AssertEqualStr "", leader_name$(22), "the name is taken from the list"
AssertEqualInt 0, army_order(22), "no order"
END SUB

SUB TestDrillAddsALevelAndBusiesTheArmy
army_experience(3) = 2
CALL army_drill(3)
AssertEqualInt 3, army_experience(3), "one more level"
AssertEqualInt ORDER_BUSY, army_order(3), "busy for the month"
END SUB

' ------------------------------- set_union_advantage and turn_collect_income

SUB TestUnionAdvantageFollowsTheBalance
opt_difficulty = 3
CALL set_union_advantage
AssertEqualInt 360, union_income_bonus, "one player"
opt_realism = REALISM_ON
CALL set_union_advantage
AssertEqualInt 252, union_income_bonus, "seven tenths with realism on"
opt_realism = 0: opt_players = PLAYERS_TWO
CALL set_union_advantage
AssertEqualInt 150, union_income_bonus, "two players"
END SUB

SUB TestIncomeIsCitiesCapitalAndRaids
city_owner(1) = 1: city_value(1) = 10
city_owner(2) = 2: city_value(2) = 20
side_capital(1) = 5
side_cash(2) = MAX_CASH + 1
raiding_side = 1: raid_loss = 5
army_order(3) = 7
CALL turn_collect_income
AssertEqualInt 110, side_income(1), "a city and the capital"
AssertEqualInt 110, side_cash(1), "the Union's cash"
AssertEqualInt 20, side_income(2), "a city and no capital"
AssertEqualInt MAX_CASH + 20 - 5, side_cash(2), "capped, then income less the raid"
AssertEqualInt 1, side_city_count(1), "the Union's cities"
AssertEqualInt 1, side_city_count(2), "the Rebels' cities"
AssertEqualInt 130, total_income, "both incomes"
AssertEqualInt 0, army_order(3), "orders cleared"
END SUB

' ------------------------- turn_set_move_order and turn_update_victory_points

SUB TestMoveOrderPutsNoSuppliesLast
army_city(5) = 3: army_order(5) = 4: army_size(5) = 100
army_order(7) = ORDER_BUSY
CALL turn_set_move_order
AssertEqualInt 905, move_order_key(1), "army 5, out of supplies, is the only one that moves"
AssertEqualInt MOVE_KEY_NONE, move_order_key(2), "the others do not move"
AssertEqualInt ORDER_NONE, army_order(7), "a busy army is free again"
END SUB

SUB TestVictoryPointsKeepEightTenths
side_victory_points(1) = 100: side_income(1) = 50: side_city_count(1) = 30
side_victory_points(2) = 10: side_income(2) = 0: side_city_count(2) = 40
CALL turn_update_victory_points
AssertEqualInt 154, side_victory_points(1), "80, 24 for income and cities, 50 for 30 cities"
AssertEqualInt 254, side_victory_points(2), "over 34 cities the Rebels get the Union's points and 100"
END SUB

' ---------------------------------------------------------- ai_count_armies

SUB TestAiCountsItsArmies
army_city(1) = 5: army_size(1) = 100
army_city(21) = 25: army_size(21) = 100
army_city(22) = 26: army_size(22) = 100
AssertEqualInt 2, ai_count_armies(2), "two armies, and more men than the Union"
army_size(1) = 300
AssertEqualInt 0, ai_count_armies(2), "the Union has more men: two fewer"
army_size(1) = 500
AssertEqualInt 0, ai_count_armies(2), "the Union has more than twice the men: none"
army_size(22) = 250
AssertEqualInt 0, ai_count_armies(2), "500 against 350: two fewer"
END SUB

' ----------------------------------------------------- railroad_route_count

SUB TestRouteCountsTwoStepsOfTrack
city_road(1, 1) = 2: city_road(1, 2) = 3
city_road(2, 1) = 1: city_road(2, 2) = 4
city_owner(2) = 1: city_owner(3) = 2: city_owner(4) = 1
AssertEqualInt 2, railroad_route_count(1, 1), "city 2, and city 4 beyond it; not the way back"
AssertEqualInt 0, railroad_route_count(2, 4), "a city with no road"
city_owner(4) = 2
AssertEqualInt 1, railroad_route_count(1, 1), "city 2 only: the track is blocked"
END SUB

' ------------------------------------------- ai_navy and menu_navy_items

SUB TestAiNavyChangesItsOrder
action = NAVY_ATTACK
CALL ai_navy(1, action)
AssertEqualInt NAVY_BUILD, action, "no fleet: build"
fleet_city(1) = 5: action = NAVY_ATTACK
CALL ai_navy(1, action)
AssertEqualInt NAVY_ATTACK, action, "a fleet in port: the order stands"
raiding_side = 2: raid_loss = 3
CALL ai_navy(1, action)
AssertEqualInt NAVY_RAID, action, "the Rebels' raiders sank commerce: raid back"
fleet_pursuit = 1
CALL ai_navy(1, action)
AssertEqualInt NAVY_SAIL, action, "the enemy's fleet is to be pursued: sail"
END SUB

SUB TestNavyMenuOffersWhatTheFleetCanDo
CALL menu_navy_items(1)
AssertEqualStr "-", menu_text$(1), "no money: no Build"
AssertEqualStr "-", menu_text$(3), "no fleet: no Sail"
AssertEqualStr "-", menu_text$(4), "no fleet: no Raid"
AssertEqualInt 4, menu_item_count, "four entries"
fleet_city(1) = 5: fleet_size(1) = 2
CALL menu_navy_items(1)
AssertEqualStr "Sail", menu_text$(3), "a fleet may sail"
AssertEqualStr "Raid", menu_text$(4), "and raid"
AssertEqualStr "-", menu_text$(2), "off a neutral city: no Attack"
AssertEqualInt 5, menu_item_count, "off a neutral city with two ships: five entries"
AssertEqualStr "Invasion", menu_text$(5), "the fifth"
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
AssertEqualStr DATE$, script_date$, "not scripted: today"
scripted = 1
AssertEqualStr "01-01-2000", script_date$, "scripted"
END SUB

' Under a script, scriptshell copies in BASIC instead of SHELL, whose
' cmd.exe would show a console window. The test sets scripted first, so it
' never runs a SHELL.
SUB TestScriptshellCopiesAFile
scripted = 1
d$ = TestTempDir$ + "/"
f = FREEFILE: OPEN d$ + "cws.his" FOR OUTPUT AS #f: PRINT #f, "history": CLOSE #f
f = FREEFILE: OPEN d$ + "oldhist.ory" FOR OUTPUT AS #f: PRINT #f, "an older and longer one": CLOSE #f
CALL script_shell("copy " + d$ + "cws.his " + d$ + "oldhist.ory")
f = FREEFILE: OPEN d$ + "oldhist.ory" FOR INPUT AS #f: LINE INPUT #f, a$: CLOSE #f
AssertEqualStr "history", a$, "the copy replaces the old file"
END SUB

'$INCLUDE: '../rules/army.bm'
'$INCLUDE: '../rules/city.bm'
'$INCLUDE: '../rules/battle.bm'
'$INCLUDE: '../rules/navy.bm'
'$INCLUDE: '../rules/railroad.bm'
'$INCLUDE: '../rules/setup.bm'
'$INCLUDE: '../rules/turn.bm'
'$INCLUDE: '../rules/victory.bm'
'$INCLUDE: '../ai/ai.bm'
'$INCLUDE: '../ui/menu.bm'
'$INCLUDE: '../ui/orders.bm'
'$INCLUDE: '../ui/reports.bm'
'$INCLUDE: '../ui/screen.bm'
'$INCLUDE: '../ui/messages.bm'
'$INCLUDE: '../draw/map.bm'
'$INCLUDE: '../draw/icons.bm'
'$INCLUDE: '../draw/ships.bm'
'$INCLUDE: '../draw/pictures.bm'
'$INCLUDE: '../game/victory_screens.bm'
'$INCLUDE: '../game/tunes.bm'
'$INCLUDE: '../game/events.bm'
'$INCLUDE: '../port/files.bm'
'$INCLUDE: '../port/qb64.bm'
'$INCLUDE: '../port/script.bm'
