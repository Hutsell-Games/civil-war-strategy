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

' ---------------------------------------------------------------- city_take
' A side takes a city: its value in victory points, more for a capital.

SUB TestCityTakeCountsTheCitysValue
city_value(7) = 15: city_fort(7) = 2: side_capital(2) = 25
CALL city_take(7, 1, 0)
AssertEqualInt 1, city_owner(7), "the Union holds it"
AssertEqualInt 15, side_victory_points(1), "its value"
AssertEqualInt 2, city_fort(7), "weaken_fort 0: the fort stands"
CALL city_take(7, 2, 1)
AssertEqualInt 1, city_fort(7), "weaken_fort 1: a level less"
AssertEqualInt 25, side_capital(2), "not a capital"
END SUB

SUB TestCityTakeOfTheCapital
city_value(25) = 20: side_capital(2) = 25: side_victory_points(2) = 300
CALL city_take(25, 1, 0)
AssertEqualInt 120, side_victory_points(1), "its value and 100"
AssertEqualInt 200, side_victory_points(2), "100 from the Rebels"
AssertEqualInt 0, side_capital(2), "the Rebels have no capital"
END SUB

' --------------------------------------------------- city_fix_return_routes
' City 1 has roads to 2 and 3. City 2 has a road back; city 3 has none but a
' free slot; city 4 has a road to 5, whose six slots are full.

SUB TestCityFixReturnRoutesListsEach
DIM added(240) AS INTEGER: DIM from_city(240) AS INTEGER: DIM to_city(240) AS INTEGER
city_road(1, 1) = 2: city_road(1, 2) = 3
city_road(2, 1) = 1: city_road(3, 1) = 6: city_road(6, 1) = 3
city_road(4, 1) = 5
FOR k = 1 TO 6: city_road(5, k) = 10 + k: city_road(10 + k, 1) = 5: NEXT k
CALL city_fix_return_routes(count, added(), from_city(), to_city())
AssertEqualInt 2, count, "two roads without a way back"
AssertEqualInt 1, added(1), "the first is added"
AssertEqualInt 3, from_city(1), "from city 3"
AssertEqualInt 1, to_city(1), "to city 1"
AssertEqualInt 1, city_road(3, 2), "in city 3's second slot"
AssertEqualInt 0, added(2), "the second has no free slot"
AssertEqualInt 5, from_city(2), "city 5"
AssertEqualInt 4, to_city(2), "has no road to city 4"
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

' ------------------------------------------------------------------- battle
' The rules of a land battle, which calculate_battle shows. The numbers are
' those of the scenario: attack loss 11, defend loss 9, strength cap 20.
' Sizes are in hundreds of men.

SUB TestBattleStrengthsStepByStep
DIM attack_steps(7) AS INTEGER: DIM defend_steps(8) AS INTEGER
rule_strength_cap = 20: current_side = 1: opt_difficulty = 3
army_size(1) = 120: army_leader_rating(1) = 5: army_experience(1) = 3: army_supply(1) = 2
army_size(21) = 80: army_leader_rating(21) = 6: army_experience(21) = 8: army_supply(21) = 0
army_city(21) = 5: city_fort(5) = 1
CALL battle_strengths(1, 21, attack_steps(), defend_steps())
AssertEqualInt 1, attack_steps(1), "attack base: 1.2 rounds to 1"
AssertEqualInt 3, attack_steps(2), "with leader and experience: 1 + 1.5 + .9"
AssertEqualInt 3, attack_steps(4), "outmanned: 120 against 80 changes nothing"
AssertEqualInt 3, attack_steps(7), "the attack"
AssertEqualInt 2, defend_steps(1), "defense: .013 * 80 + 1"
AssertEqualInt 6, defend_steps(2), "with leader and experience: 2 + 1.8 + 2.4"
AssertEqualInt 3, defend_steps(5), "no supply halves it"
AssertEqualInt 6, defend_steps(7), "a fort doubles it"
AssertEqualInt 6, defend_steps(8), "the defense"
END SUB

SUB TestBattleCountsAnEmptyArmyAsOne
DIM attack_steps(7) AS INTEGER: DIM defend_steps(8) AS INTEGER
rule_strength_cap = 20: opt_difficulty = 3: army_size(21) = 50
CALL battle_strengths(1, 21, attack_steps(), defend_steps())
AssertEqualInt 1, army_size(1), "an attacker of 0 men becomes 100"
AssertEqualInt 1, attack_steps(4), "outmanned 1 to 50: 1"
AssertEqualInt 20, defend_steps(4), "50 to 1: the cap"
END SUB

SUB TestBattleFightTakesSupplyFromOneAndTwo
RANDOMIZE 1
army_supply(1) = 2: army_supply(2) = 1: army_supply(21) = 3: army_supply(22) = 3
CALL battle_fight(3, 6, 21, 22, winner, loser, rounds)
AssertEqualInt 1, army_supply(1), "army 1 loses a day"
AssertEqualInt 0, army_supply(2), "and army 2"
AssertEqualInt 3, army_supply(21), "not the attacker"
AssertEqualInt 3, army_supply(22), "nor the defender"
AssertTrue winner = 21 OR winner = 22, "a winner of the two:" + STR$(winner)
AssertEqualInt 21 + 22 - winner, loser, "the other one loses"
AssertTrue rounds >= 1, "at least one round:" + STR$(rounds)
END SUB

SUB TestBattleFightWithSeedOne
RANDOMIZE 1
CALL battle_fight(3, 6, 1, 21, winner, loser, rounds)
AssertEqualInt 21, winner, "the winner with seed 1: the defender"
AssertEqualInt 1, loser, "the attacker loses"
AssertEqualInt 1, rounds, "one round with seed 1"
END SUB

SUB TestBattleLossesWithSeedOne
RANDOMIZE 1
rule_attack_loss = 11: rule_defend_loss = 9
army_size(1) = 120: army_size(21) = 80: army_city(21) = 5: city_fort(5) = 1
CALL battle_losses(1, 21, 1, killa, killd)
AssertEqualInt 8, killa, "the attacker's losses"
AssertEqualInt 9, killd, "the defender's losses"
AssertEqualInt 120, army_size(1), "not taken yet"
END SUB

SUB TestBattleCasualtiesByArmyNumber
army_size(3) = 120: army_size(21) = 80
CALL battle_apply_losses(3, 21, 3, 10, 20)
AssertEqualInt 110, army_size(3), "the attacker loses 10"
AssertEqualInt 60, army_size(21), "the defender loses 20"
AssertEqualInt 10, side_casualties&(2), "Union army 3's losses count for the Rebels (attacker > 2)"
AssertEqualInt 20, side_casualties&(1), "and the Rebels' for the Union"
AssertEqualInt 1, side_battles_won(1), "a battle won for the Union"
AssertEqualInt 1, side_victory_points(1), "and a victory point"
END SUB

SUB TestBattleLeavesTheDefenderOne
army_size(1) = 120: army_size(21) = 15
CALL battle_apply_losses(1, 21, 1, 5, 20)
AssertEqualInt 1, army_size(21), "not below 100 men"
AssertEqualInt 5, side_casualties&(1), "army 1's losses count for the Union"
END SUB

' ---------------------------------------------------------------- commander
' The next general of a side that has no army: one from the list of names,
' or a made-up one when the list is used up.

SUB TestCommanderTakesTheFirstFreeName
leader_name$(1) = "Grant": army_city(1) = 5
leader_name$(2) = "Pope"
leader_name$(3) = "Meade"
CALL army_pick_commander(1, empty)
AssertEqualInt 2, empty, "Grant has an army; Pope is next"
END SUB

SUB TestCommanderMakesUpANameAfterTheList
RANDOMIZE 1
CALL army_pick_commander(2, empty)
AssertEqualInt 21, empty, "the Rebels' first army"
AssertEqualStr "Rebel I", leader_name$(21), "its made-up name"
AssertTrue leader_rating(21) >= 1 AND leader_rating(21) <= 9, "a rating from 1 to 9:" + STR$(leader_rating(21))
END SUB

SUB TestCommanderNoneLeft
FOR i = 1 TO 20: army_city(i) = 5: NEXT i
CALL army_pick_commander(1, empty)
AssertEqualInt 0, empty, "every Union army has a city"
END SUB

' -------------------------------------------------------- combining armies
' Army 0 gathers the armies of a city; the best leader's army takes them over.

SUB TestArmyCombineTakesTheBestLeader
army_city(1) = 5: army_size(1) = 100: army_leader_rating(1) = 4: army_experience(1) = 2: army_supply(1) = 3: army_name$(1) = "Grant"
army_city(2) = 5: army_size(2) = 50: army_leader_rating(2) = 7: army_experience(2) = 5: army_supply(2) = 9: army_name$(2) = "Sherman"
army_city(3) = 5: army_size(3) = 40: army_order(3) = 12
CALL army_combine_start(5)
best = 0
CALL army_combine_add(1, 5, best, status)
AssertEqualInt COMBINE_JOINED, status, "army 1 joins"
CALL army_combine_absorb(1)
AssertEqualStr "Grant", leader_name$(1), "Grant goes back to the list"
AssertEqualInt 0, army_city(1), "army 1's slot is empty"
CALL army_combine_add(2, 5, best, status)
AssertEqualInt COMBINE_JOINED, status, "army 2 joins"
AssertEqualInt 2, best, "Sherman is the better leader"
CALL army_combine_absorb(2)
CALL army_combine_add(3, 5, best, status)
AssertEqualInt COMBINE_SKIPPED, status, "army 3 has an order: it does not join"
CALL army_combine_finish(5, 2, 2)
AssertEqualInt 150, army_size(2), "the men of both"
AssertEqualInt 3, army_experience(2), "experience by share of men: 2/3 of 2 and 1/3 of 5"
AssertEqualInt 10, army_supply(2), "3 + 9, at most 10"
AssertEqualStr "Sherman", army_name$(2), "under Sherman"
AssertEqualInt ORDER_BUSY, army_order(2), "two joined: no order this turn"
AssertEqualInt 2, city_army(5), "it holds the city"
END SUB

SUB TestArmyCombineRefusesTooLarge
army_city(1) = 5: army_size(1) = 1200
army_city(2) = 5: army_size(2) = 100
CALL army_combine_start(5)
CALL army_combine_add(1, 5, best, status)
CALL army_combine_add(2, 5, best, status)
AssertEqualInt COMBINE_TOO_LARGE, status, "130,000 men: too large"
AssertEqualInt 1200, army_size(0), "army 0 has army 1's men only"
END SUB

' ------------------------------------------------- raising and supplying
SUB TestArmyRaiseSetsUpANewArmy
RANDOMIZE 1
leader_name$(3) = "Pope": leader_rating(3) = 5: side_cash(1) = 500
CALL army_raise(1, 3, 7)
AssertEqualStr "Pope", army_name$(3), "the leader on the list"
AssertEqualStr "", leader_name$(3), "is off the list"
AssertEqualInt 5, army_leader_rating(3), "with his rating"
AssertEqualInt 1, army_experience(3), "a Union army starts at 1"
AssertEqualInt 23, army_size(3), "7,000 men, a third of it in a city cut off"
AssertTrue army_supply(3) >= 5 AND army_supply(3) <= 10, "supplies from 5 to 10:" + STR$(army_supply(3))
AssertEqualInt 7, army_city(3), "in city 7"
AssertEqualInt 3, city_army(7), "which it holds"
AssertEqualInt 400, side_cash(1), "for 100"
AssertEqualInt ORDER_BUSY, army_order(3), "no order this turn"
END SUB

SUB TestArmyBuySupplyUpToTheLevel
army_city(1) = 5: army_size(1) = 100: army_supply(1) = 1: side_cash(1) = 1000
CALL army_buy_supply(1, result)
AssertEqualInt SUPPLY_BOUGHT, result, "bought"
AssertEqualInt 5, army_supply(1), "up to the resupply level"
AssertEqualInt 960, side_cash(1), "4 days for 10,000 men cost 40"
side_cash(1) = 2: army_supply(1) = 1
CALL army_buy_supply(1, result)
AssertEqualInt SUPPLY_NO_CASH, result, "not enough cash"
AssertEqualInt 1, army_supply(1), "nothing bought"
END SUB

SUB TestArmyBuySupplyCutOff
opt_realism = REALISM_ON
army_city(1) = 5: army_size(1) = 100: army_supply(1) = 1: side_cash(1) = 1000
CALL army_buy_supply(1, result)
AssertEqualInt SUPPLY_CUT_OFF, result, "city 5 has no road to a Union city"
AssertEqualInt 1000, side_cash(1), "nothing paid"
END SUB

SUB TestArmyAddRecruits
opt_difficulty = 3: current_side = 1
army_city(4) = 7: army_size(4) = 100: side_cash(1) = 300
CALL army_add_recruits(1, 4, isolated)
AssertEqualInt 145, army_size(4), "4,500 more men"
AssertEqualInt 200, side_cash(1), "for 100"
AssertEqualInt 0, isolated, "not isolated without the Realism setting"
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

' ---------------------------------------------- railroad_board and _unload
' An army takes the train from city 7 to city 12; army 5 stays in city 7.

SUB TestRailroadBoardPutsTheArmyOnTheTrain
army_city(3) = 7: army_city(5) = 7: city_army(7) = 3
CALL railroad_board(1, 3, 12)
AssertEqualInt 3, train_army(1), "the army aboard"
AssertEqualInt 7, train_city(1), "the train is in city 7"
AssertEqualInt 7, train_from_city(1), "and sets out from there"
AssertEqualInt 0, army_city(3), "the army is in no city"
AssertEqualInt 12, army_order(3), "it is bound for city 12"
AssertEqualInt 5, city_army(7), "army 5 now holds city 7"
END SUB

SUB TestRailroadUnloadPutsTheArmyInItsCity
army_city(5) = 7: city_army(7) = 3
train_army(1) = 3: train_city(1) = 7: train_from_city(1) = 7: army_order(3) = 12
CALL railroad_unload(1)
AssertEqualInt 0, train_army(1), "the train is empty"
AssertEqualInt 12, train_city(1), "in city 12"
AssertEqualInt 12, army_city(3), "the army is in city 12"
AssertEqualInt ORDER_BUSY, army_order(3), "and can take no order this turn"
AssertEqualInt 5, city_army(7), "army 5 holds city 7"
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

' ------------------------------------------------------- the navy's rules

SUB TestNavyAddShipPutsIroncladsFirst
fleet_ships$(1) = "WW": fleet_size(1) = 2: side_cash(1) = 500
CALL navy_add_ship(1, "I", 100)
AssertEqualStr "IWW", fleet_ships$(1), "an ironclad goes first"
AssertEqualInt 3, fleet_size(1), "three ships"
AssertEqualInt 400, side_cash(1), "paid now"
CALL navy_add_ship(1, "W", 100)
AssertEqualStr "IWWW", fleet_ships$(1), "a wooden ship goes last"
side_cash(2) = 500
CALL navy_add_ship(2, "W", 100)
AssertEqualInt 500, side_cash(2), "a new fleet pays later"
END SUB

SUB TestNavyFoundAndCancelANewFleet
side_cash(2) = 500: fleet_ships$(2) = "W": fleet_size(2) = 1
CALL navy_found_fleet(2, 9, 100)
AssertEqualInt 9, fleet_city(2), "in port 9"
AssertEqualInt 400, side_cash(2), "paid"
CALL navy_cancel_new_fleet(1)
AssertEqualInt 0, fleet_size(1), "no ship"
AssertEqualStr "", fleet_ships$(1), "none"
END SUB

SUB TestNavyBombardArmy
RANDOMIZE 1
fleet_size(1) = 4: army_size(21) = 100: army_supply(21) = 5
CALL navy_bombard_army(1, 21, killd)
AssertTrue killd >= 2 AND killd <= 4, "2% to 4% of the men:" + STR$(killd)
AssertEqualInt 100 - killd, army_size(21), "taken from the army"
AssertEqualInt 2, army_supply(21), "3 days of supply lost"
END SUB

' The branches that hang on a random draw: each test tries seeds until the
' draw goes its way, then checks that branch exactly.

SUB TestNavyShoreBatteryDamagesFort
FOR s = 1 TO 100
	RANDOMIZE s
	fleet_ships$(1) = "W": fleet_size(1) = 1: fleet_city(1) = 5: city_fort(5) = 2
	CALL navy_shore_battery(1, 5, damaged)
	IF damaged = 1 THEN EXIT FOR
NEXT s
AssertEqualInt 1, damaged, "a seed where the fleet hits the fort"
AssertEqualInt 1, city_fort(5), "the fort loses a level"
AssertEqualInt 1, fleet_size(1), "the ship is safe"
AssertEqualInt 5, fleet_city(1), "the fleet stays"
END SUB

SUB TestNavyShoreBatterySinksShip
FOR s = 1 TO 100
	RANDOMIZE s
	fleet_ships$(1) = "WI": fleet_size(1) = 2: fleet_city(1) = 5: city_fort(5) = 2
	CALL navy_shore_battery(1, 5, damaged)
	IF damaged = 0 THEN EXIT FOR
NEXT s
AssertEqualInt 0, damaged, "a seed where the battery hits"
AssertEqualInt 2, city_fort(5), "the fort stands"
AssertEqualInt 1, fleet_size(1), "a ship is sunk"
AssertEqualStr "W", fleet_ships$(1), "the last of the list"
END SUB

SUB TestNavyShotIroncladBeatsWood
fleet_ships$(1) = "I": fleet_ships$(2) = "W"
RANDOMIZE 1
iron = 0: FOR k = 1 TO 200: iron = iron + navy_shot_hits(1): NEXT k
RANDOMIZE 1
wood = 0: FOR k = 1 TO 200: wood = wood + navy_shot_hits(2): NEXT k
AssertTrue iron > wood, "the same draws: the ironclad hits more often:" + STR$(iron) + STR$(wood)
fleet_ships$(2) = "I"
RANDOMIZE 1
even = 0: FOR k = 1 TO 200: even = even + navy_shot_hits(2): NEXT k
AssertTrue even > wood AND even < iron, "two ironclads: in between:" + STR$(even)
END SUB

SUB TestNavyRaidRoundLosesAShip
FOR s = 1 TO 100
	RANDOMIZE s
	raiding_side = 1: fleet_size(1) = 1: fleet_ships$(1) = "W": fleet_city(1) = FLEET_AT_SEA: raid_loss = 7
	CALL navy_raid_round(raider, sank)
	IF sank = 0 THEN EXIT FOR
NEXT s
AssertEqualInt 0, sank, "a seed where the raiders lose"
AssertEqualInt 1, raider, "the Union raided"
AssertEqualInt 0, raid_loss, "they sank nothing"
AssertEqualInt 0, fleet_size(1), "their last ship is gone"
AssertEqualInt 0, raiding_side, "nobody raids now"
END SUB

SUB TestNavyFleetLostToTheBattery
current_side = 1: fleet_pursuit = 1: fleet_city(1) = 5
CALL navy_fleet_lost(1)
AssertEqualInt 0, fleet_city(1), "no fleet"
AssertEqualInt 5, side_victory_points(2), "5 points for the Rebels"
AssertEqualInt 0, fleet_pursuit, "no pursuit"
END SUB

SUB TestNavyBlastCapitalAndNeutral
fleet_size(1) = 20: side_capital(2) = 25: fleet_city(1) = 25: city_owner(25) = 2
CALL navy_blast(1, 25, result)
AssertEqualInt BLAST_LOYAL, result, "the capital stays loyal"
AssertEqualInt 2, city_owner(25), "still the Rebels'"
fleet_city(1) = 7: city_owner(7) = 2: city_value(7) = 10
CALL navy_blast(1, 7, result)
AssertEqualInt BLAST_NEUTRAL, result, "20 ships: the city always gives in"
AssertEqualInt 0, city_owner(7), "neutral"
AssertEqualInt 10, side_victory_points(1), "its value for the Union"
END SUB

SUB TestNavyLandedArmy
side_cash(1) = 200: army_size(5) = 70
CALL navy_landed(1, 5)
AssertEqualInt 35, army_size(5), "3,500 men"
AssertEqualInt 300, side_cash(1), "the 100 given back"
END SUB

SUB TestNavyRaidingSide
fleet_city(2) = FLEET_AT_SEA: fleet_city(1) = 5: raiding_side = 1
CALL navy_note_raiding_side
AssertEqualInt 2, raiding_side, "the Rebels' fleet is at sea"
CALL navy_go_raiding(1)
AssertEqualInt FLEET_AT_SEA, fleet_city(1), "the Union's fleet goes to sea"
AssertEqualInt 1, raiding_side, "and raids"
END SUB

SUB TestNavyRaidRound
raiding_side = 1: fleet_size(1) = 0
CALL navy_raid_round(raider, sank)
AssertEqualInt 0, raider, "no ships: no raid"
AssertEqualInt 0, raiding_side, "nobody raids"
raiding_side = 1: fleet_size(1) = 10: side_income(2) = 100: current_side = 1
CALL navy_raid_round(raider, sank)
AssertEqualInt 1, sank, "10 ships always sink commerce"
AssertEqualInt 30, raid_loss, "at most 30% of the income"
AssertEqualInt 1, fleet_pursuit, "the other fleet will pursue"
END SUB

SUB TestNavyShipHits
fleet_ships$(1) = "WI": fleet_ships$(2) = "IW"
AssertEqualInt 20, navy_ship_hits(1), "the last ship is an ironclad"
AssertEqualInt 10, navy_ship_hits(2), "the last ship is wooden"
END SUB

SUB TestNavyFleetDefeated
current_side = 1: fleet_city(2) = 5: fleet_ships$(2) = "W"
CALL navy_fleet_defeated(2)
AssertEqualInt 0, fleet_city(2), "the Rebels' fleet is gone"
AssertEqualInt 10, side_victory_points(2), "10 points for the loser (as in the original)"
AssertEqualInt 1, fleet_pursuit, "the Union, whose turn it is, won: pursuit"
CALL navy_fleet_defeated(1)
AssertEqualInt 0, fleet_pursuit, "the Union lost: no pursuit"
END SUB

SUB TestNavyRetreatPort
city_owner(3) = 1: city_port_type(3) = PORT_SEA: fleet_city(1) = 3
city_owner(8) = 1: city_port_type(8) = PORT_SEA
CALL navy_retreat_port(1, target)
AssertEqualInt 8, target, "the one other sea port"
AssertEqualInt 8, fleet_city(1), "the fleet is there"
city_owner(8) = 2: fleet_city(1) = 3
CALL navy_retreat_port(1, target)
AssertEqualInt 0, target, "none left"
END SUB

' ------------------------------------------------------ the computer's choices
' The player is the Union (current_side 1), the computer the Rebels.

SUB TestAiFortifyPickOutnumbered
current_side = 1: opt_ai_aggression = 0: ai_strength_ratio! = 0
army_city(21) = 5: army_size(21) = 50: city_army(5) = 21
city_road(5, 1) = 6: city_owner(6) = 1: city_army(6) = 1: army_size(1) = 100
CALL ai_fortify_pick(2, target)
AssertEqualInt 5, target, "10,000 of the player's men next to 5,000"
opt_ai_aggression = 3
CALL ai_fortify_pick(2, target)
AssertEqualInt 0, target, "an aggressive computer does not fortify"
END SUB

SUB TestAiArmyOrderAndWinter
RANDOMIZE 1
current_side = 1: turn_month = 3
army_city(21) = 5: army_size(21) = 100: army_supply(21) = 5: city_army(5) = 21
city_road(5, 1) = 6: city_value(6) = 10
CALL ai_army_order(2, 21, ordered)
AssertEqualInt 1, ordered, "an order"
AssertEqualInt 6, army_order(21), "to the neutral city next to it"
army_order(21) = ORDER_NONE: turn_month = 1
CALL ai_army_order(2, 21, ordered)
AssertEqualInt 0, ordered, "no winter campaigns: none in January"
AssertEqualInt ORDER_NONE, army_order(21), "left where it is"
army_city(22) = 0
CALL ai_army_order(2, 22, ordered)
AssertEqualInt 0, ordered, "an army without a city has none"
END SUB

SUB TestArmyRecruitCitiesKeptForTheMonth
current_side = 1: turn_recruit_state = 2
turn_recruit_city(1) = 7: turn_recruit_city(2) = 3
city_name$(7) = "Boston": city_name$(3) = "Albany"
CALL army_recruit_cities(1)
AssertEqualInt 2, menu_item_count, "the month's two cities"
AssertEqualStr "Albany", menu_text$(1), "sorted"
AssertEqualInt 3, menu_value(1), "city 3"
END SUB

SUB TestAiRecruitPickSmallArmy
menu_item_count = 2: menu_value(1) = 7: menu_value(2) = 3
city_army(3) = 4: army_size(4) = 100: side_cash(2) = 500
CALL ai_recruit_pick(2)
AssertEqualInt 2, menu_choice, "the city with an army under 15,500 men"
END SUB

' ------------------------------------------------------ the special events
' script_dice$ gives event_roll its draws, as CWS_DICE does under a script.
' The Balance setting 5, difficulty 3 and 1863 give a chance of .135; a draw
' of 0 passes it.

SUB TestEventIroncladsComeFirst
opt_realism = REALISM_ON: turn_year = IRONCLAD_YEAR: turn_month = 1
CALL event_roll(event, variant, who)
AssertEqualInt EVENT_IRONCLADS, event, "January 1862 with the Realism setting"
END SUB

SUB TestEventNoneWithoutBalance
opt_event_balance = 0: turn_year = 1863
CALL event_roll(event, variant, who)
AssertEqualInt EVENT_NONE, event, "the Balance setting 0: no events"
END SUB

SUB TestEventLoanForTheSouth
opt_event_balance = 5: opt_difficulty = 3: current_side = 2: turn_year = 1863
side_city_count(2) = 15
script_dice$ = "0,0,0,.5,.5,0"
CALL event_roll(event, variant, who)
AssertEqualInt EVENT_LOAN, event, "no riot, no ships, no mercenaries: a loan"
AssertEqualInt SIDE_UNION, who, "an event rolled for the Union is good for the South"
AssertEqualInt 300, side_cash(2), "100 for each point of plus"
END SUB

SUB TestEventMercenariesJoinArmyZero
opt_event_balance = 5: opt_difficulty = 3: current_side = 2: turn_year = 1863
side_city_count(2) = 30
script_dice$ = "0,0,0,.5,0,.9"
CALL event_roll(event, variant, who)
AssertEqualInt EVENT_MERCENARIES, event, "30 cities: mercenaries"
AssertEqualInt 1, variant, "British"
AssertEqualInt 300, army_size(0), "they join army 0, as in the original (TODO.md)"
AssertEqualInt MAX_EXPERIENCE, army_experience(0), "with the best experience"
END SUB

SUB TestEventEmancipation
opt_event_balance = 5: opt_difficulty = 3: current_side = 2: turn_year = 1863
side_victory_points(1) = 200: side_victory_points(2) = 200
script_dice$ = "0,.9,.5,0"
CALL event_roll(event, variant, who)
AssertEqualInt EVENT_EMANCIPATION, event, "the Proclamation, once, after 1862"
AssertEqualInt 300, side_victory_points(1), "100 points for the Union"
AssertEqualInt 100, side_victory_points(2), "100 from the Rebels"
AssertEqualInt 1, emancipation_done, "not again"
END SUB

SUB TestEventRiotCity
opt_realism = REALISM_ON: side_city_count(1) = 5
city_first_owner(7) = 2: city_owner(7) = 1
script_dice_now$ = ".15"
CALL event_riot_city(1, city)
AssertEqualInt 7, city, "the draw .15 picks city 7, which the Union took"
AssertEqualInt SIDE_NONE, city_owner(7), "it turns neutral"
END SUB

' ------------------------------------------------------------------ victory

SUB TestVictoryForcesCountArmiesInTheField
army_city(1) = 5: army_size(1) = 100: army_size(2) = 70
army_city(21) = 9: army_size(21) = 60
CALL victory_forces(x, y)
AssertEqualInt 100, x, "the Union's army in a city; not army 2, which has none"
AssertEqualInt 60, y, "the Rebels'"
END SUB

SUB TestVictoryRuleMetByCities
victory_rule(VICTORY_CITIES) = 24: side_city_count(1) = 24
CALL victory_rule_met(1, 100, 60, j)
AssertEqualInt 3, j, "24 cities: the cities rule"
CALL victory_rule_met(2, 100, 60, j)
AssertEqualInt 0, j, "the Rebels have met none"
END SUB

SUB TestVictoryEnemyWipedOut
side_victory_points(1) = 50
CALL victory_rule_met(1, 100, 0, j)
AssertEqualInt 7, j, "the Rebels have no men in the field"
AssertEqualInt 350, side_victory_points(1), "300 more points"
END SUB

SUB TestVictoryTimeNear
victory_rule(VICTORY_YEAR) = 1865: victory_rule(VICTORY_MONTH) = 3
turn_year = 1865: turn_month = 1
AssertEqualInt 1, victory_time_near, "January 1865, the limit March 1865"
turn_month = 3
AssertEqualInt 0, victory_time_near, "March: the time is up, not near"
END SUB

SUB TestVictoryNearRules
victory_rule(VICTORY_CITIES) = 20: side_city_count(1) = 18
AssertEqualInt 1, victory_near_cities(1), "18 of 20 cities: nine tenths"
side_city_count(1) = 17
AssertEqualInt 0, victory_near_cities(1), "17: not yet"
victory_rule(VICTORY_FORCE_RATIO) = 3
AssertEqualInt 1, victory_near_force(1, 280, 100), "2.8 to 1 against 3"
AssertEqualInt 0, victory_near_force(2, 280, 100), "the Rebels are outnumbered"
AssertEqualInt 0, victory_near_force(1, 280, 0), "no Rebel men: no ratio"
END SUB

SUB TestVictoryPlayOn
victory_rule(VICTORY_CITIES) = 24: victory_rule(VICTORY_CAPITAL) = 1
CALL victory_play_on(VICTORY_CITIES)
AssertEqualInt 25, victory_rule(VICTORY_CITIES), "one city more"
CALL victory_play_on(VICTORY_CAPITAL)
AssertEqualInt 0, victory_rule(VICTORY_CAPITAL), "the capital rule is off"
END SUB

SUB TestVictoryWonAndTechnical
side_victory_points(2) = 100
CALL victory_won(2, 7)
AssertEqualInt 200, side_victory_points(2), "100 more for wiping out the enemy"
AssertEqualInt 2, victory_reason, "marked for the battle summary"
AssertEqualInt 1, game_over, "the game is over"
side_victory_points(1) = 100
CALL victory_technical_points
AssertEqualInt 70, side_victory_points(1), "seven tenths"
AssertEqualInt 140, side_victory_points(2), "for both sides"
END SUB

SUB TestHallOfFamePlaceAndInsert
DIM hall_name$(2, 5): DIM hall_score(2, 5)
FOR i = 1 TO 5: hall_name$(1, i) = "N" + LTRIM$(STR$(i)): hall_score(1, i) = 600 - 100 * i: NEXT i
side_victory_points(1) = 350
AssertEqualInt 3, hall_of_fame_place(1, hall_score()), "350 reaches the third, 300"
CALL hall_of_fame_insert(1, 3, "Grant", hall_name$(), hall_score())
AssertEqualStr "Grant", hall_name$(1, 3), "in third place"
AssertEqualInt 350, hall_score(1, 3), "with the score"
AssertEqualStr "N3", hall_name$(1, 4), "the old third moves down"
AssertEqualStr "N4", hall_name$(1, 5), "and the old fourth; the fifth drops out"
side_victory_points(1) = 50
AssertEqualInt 0, hall_of_fame_place(1, hall_score()), "50 reaches none"
END SUB

' ------------------------------------------------------- the month's moves

SUB TestTurnAdvanceMonth
turn_month = 11: turn_year = 1861
CALL turn_advance_month
AssertEqualInt 1, turn_month, "November to January"
AssertEqualInt 1862, turn_year, "of the next year"
CALL turn_advance_month
AssertEqualInt 3, turn_month, "then March"
END SUB

SUB TestTurnArmySupplyInWinter
turn_month = 1: army_city(1) = 5: army_size(1) = 100: army_supply(1) = 2: side_cash(1) = 100
CALL turn_army_supply(1, blockaded, starved)
AssertEqualInt 80, side_cash(1), "a day of supply for 10,000 men costs 20"
AssertEqualInt 2, army_supply(1), "bought one, used one away from a sea port in winter"
AssertEqualInt 0, blockaded, "not blockaded"
AssertEqualInt 0, starved, "not starved"
END SUB

SUB TestTurnArmySupplyBlockaded
turn_month = 8: army_city(21) = 9: city_port_type(9) = PORT_SEA: fleet_city(1) = 9
army_size(21) = 40: army_supply(21) = 1
CALL turn_army_supply(21, blockaded, starved)
AssertEqualInt 1, blockaded, "the Union's fleet is in port 9"
AssertEqualInt 1, starved, "the day it had is gone"
AssertEqualInt 0, army_supply(21), "no supplies"
AssertEqualInt 40, army_size(21), "an army of 50 or fewer keeps its men"
END SUB

SUB TestTurnStrengthRatio
current_side = 1: army_size(1) = 100: army_size(21) = 50
CALL turn_strength_ratio
AssertTrue ai_strength_ratio! = .5, "the computer's 5,000 against the player's 10,000:" + STR$(ai_strength_ratio!)
END SUB

SUB TestTurnArmyMarches
army_supply(1) = 2
CALL turn_army_marches(1, starved)
AssertEqualInt 1, army_supply(1), "a day used"
AssertEqualInt 0, starved, "it had one"
army_supply(1) = 0
CALL turn_army_marches(1, starved)
AssertEqualInt 0, army_supply(1), "not below 0"
AssertEqualInt 1, starved, "it had none"
END SUB

SUB TestTurnBattleExperience
army_experience(3) = 4: army_experience(4) = MAX_EXPERIENCE
CALL turn_battle_experience(3)
AssertEqualInt 5, army_experience(3), "a level more"
CALL turn_battle_experience(4)
AssertEqualInt MAX_EXPERIENCE, army_experience(4), "not past the top"
END SUB

SUB TestTurnWithdrawAndHalt
army_order(2) = 5
CALL turn_withdraw(2)
AssertEqualInt 5, army_city(2), "back in the city it came from"
AssertEqualInt 2, city_army(5), "which it holds"
AssertEqualInt ORDER_DONE, army_order(2), "done for the month"
army_leader_rating(21) = 11: army_order(21) = 7
CALL turn_defender_halts(21, halted, old_order)
AssertEqualInt 0, halted, "a leader rated 11 always keeps his order"
AssertEqualInt 7, army_order(21), "kept"
RANDOMIZE 1
army_leader_rating(22) = 0: army_order(22) = 8
CALL turn_defender_halts(22, halted, old_order)
AssertEqualInt 1, halted, "a leader rated 0 loses it"
AssertEqualInt 8, old_order, "the order it had"
AssertEqualInt ORDER_DONE, army_order(22), "lost"
END SUB

SUB TestTurnRetreatCity
city_road(1, 1) = 2: city_road(1, 2) = 3: city_road(1, 3) = 4
city_owner(2) = 2: city_value(2) = 5
city_owner(3) = 2: city_value(3) = 9: city_army(3) = 30
city_owner(4) = 1: city_value(4) = 20
CALL turn_retreat_city(1, 1, move2)
AssertEqualInt 2, move2, "the richer city 3 has an army"
city_army(3) = 0
CALL turn_retreat_city(1, 1, move2)
AssertEqualInt 3, move2, "now city 3, the richest of the Rebels'"
CALL turn_retreat_city(1, 2, move2)
AssertEqualInt 4, move2, "a Union defender goes to the Union's city"
city_owner(4) = 2
CALL turn_retreat_city(1, 2, move2)
AssertEqualInt 0, move2, "no Union city next to it"
CALL turn_retreat_to(25, 3)
AssertEqualInt 3, army_city(25), "in city 3"
AssertEqualInt 25, city_army(3), "which it holds"
AssertEqualInt ORDER_DONE, army_order(25), "done for the month"
END SUB

SUB TestTurnArmyLost
army_city(21) = 5: army_size(21) = 80: army_name$(21) = "Lee": army_supply(21) = 6: army_supply(1) = 4
CALL turn_army_lost(21, 1)
AssertEqualInt 0, army_city(21), "the slot is cleared"
AssertEqualStr "", army_name$(21), "and its name"
AssertEqualInt 25, side_victory_points(2), "25 points for the other side of the army that won"
AssertEqualInt 4, army_supply(1), "the winner gains none of its supplies (as in the original)"
END SUB

SUB TestTurnOccupyAndForage
CALL turn_occupy(2, 7)
AssertEqualInt 7, army_city(2), "in city 7"
AssertEqualInt 2, city_army(7), "which it holds"
AssertEqualInt ORDER_DONE, army_order(2), "done for the month"
city_fort(7) = 2
CALL turn_raze_fort(7)
AssertEqualInt 0, city_fort(7), "razed"
RANDOMIZE 1
army_supply(2) = 1
CALL turn_army_forages(2)
AssertTrue army_supply(2) >= 2, "at least a day more:" + STR$(army_supply(2))
army_supply(2) = MAX_SUPPLY
CALL turn_army_forages(2)
AssertEqualInt MAX_SUPPLY, army_supply(2), "not past the top"
END SUB

' ------------------------------------------ the Utility menu's settings
' The option_ SUBs of rules/setup.bm, and victory_toggle_rule.

SUB TestOptionSwapSide
current_side = SIDE_UNION
CALL option_swap_side
AssertEqualInt SIDE_REBEL, current_side, "the Rebels"
AssertEqualInt 3, opt_event_balance, "events favor the Union"
CALL option_swap_side
AssertEqualInt SIDE_UNION, current_side, "the Union again"
AssertEqualInt 7, opt_event_balance, "events favor the Rebels"
END SUB

SUB TestOptionSwitches
opt_players = PLAYERS_ONE
CALL option_toggle_players: AssertEqualInt PLAYERS_TWO, opt_players, "two players"
CALL option_toggle_players: AssertEqualInt PLAYERS_ONE, opt_players, "one again"
CALL option_toggle_alt_colors: AssertEqualInt 1, opt_alt_colors, "the other colors"
CALL option_toggle_alt_colors: AssertEqualInt 0, opt_alt_colors, "the usual colors"
CALL option_toggle_winter_campaigns: AssertEqualInt 1, opt_winter_campaigns, "January campaigns on"
CALL option_toggle_winter_campaigns: AssertEqualInt 0, opt_winter_campaigns, "and off"
CALL option_toggle_history: AssertEqualInt 1, opt_history, "history on"
CALL option_toggle_history: AssertEqualInt 0, opt_history, "and off"
CALL option_set_sound(SOUND_MUSIC): AssertEqualInt SOUND_MUSIC, opt_sound, "music"
CALL option_set_sound(SOUND_OFF): AssertEqualInt SOUND_OFF, opt_sound, "quiet"
END SUB

SUB TestOptionCyclesStartAgain
opt_graphics = GRAPHICS_NAMES
CALL option_next_graphics: AssertEqualInt GRAPHICS_FULL, opt_graphics, "the next level"
CALL option_next_graphics: AssertEqualInt GRAPHICS_OFF, opt_graphics, "after the last, the first"
opt_ai_aggression = 4
CALL option_next_aggression: AssertEqualInt 5, opt_ai_aggression, "the next level"
CALL option_next_aggression: AssertEqualInt 0, opt_ai_aggression, "after 5, 0"
END SUB

SUB TestOptionDisplaySpeed
CALL option_set_display_speed(2)
AssertTrue opt_pause! = 2, "Normal is 2 seconds:" + STR$(opt_pause!)
CALL option_set_display_speed(4)
AssertTrue opt_pause! = 8, "Very Slow is 8 seconds:" + STR$(opt_pause!)
END SUB

SUB TestOptionSetBalance
opt_players = PLAYERS_ONE
CALL option_set_balance(4)
AssertEqualInt 4, opt_difficulty, "the level"
AssertEqualInt 480, union_income_bonus, "the Union's extra income follows it"
END SUB

SUB TestOptionSetEventBalance
CALL option_set_event_balance(2): AssertEqualInt 3, opt_event_balance, "favor the Union"
CALL option_set_event_balance(3): AssertEqualInt 5, opt_event_balance, "neutral"
CALL option_set_event_balance(4): AssertEqualInt 7, opt_event_balance, "favor the Rebels"
CALL option_set_event_balance(MENU_ESCAPED): AssertEqualInt 7, opt_event_balance, "Esc changes nothing"
CALL option_set_event_balance(1): AssertEqualInt 0, opt_event_balance, "off"
END SUB

' Realism on works the Union's extra income out again; realism off does not. From high
' realism (2) the switch gives -1, which counts as on (as in the original).
SUB TestOptionToggleRealism
opt_players = PLAYERS_ONE: opt_difficulty = 3
CALL option_toggle_realism
AssertEqualInt REALISM_ON, opt_realism, "on"
AssertEqualInt 252, union_income_bonus, "seven tenths of 360"
CALL option_toggle_realism
AssertEqualInt REALISM_OFF, opt_realism, "off"
AssertEqualInt 252, union_income_bonus, "not worked out again (as in the original)"
opt_realism = REALISM_HIGH: union_income_bonus = 0
CALL option_toggle_realism
AssertEqualInt -1, opt_realism, "from high realism: -1 (as in the original)"
AssertEqualInt 360, union_income_bonus, "worked out, without the seven tenths"
END SUB

' With realism going on, a Rebel player's event balance of 1 becomes 3. No menu sets 1.
SUB TestOptionToggleRealismEventBalance
current_side = SIDE_REBEL: opt_event_balance = 1
CALL option_toggle_realism
AssertEqualInt 3, opt_event_balance, "1 becomes 3"
opt_realism = REALISM_OFF: opt_event_balance = 5
CALL option_toggle_realism
AssertEqualInt 5, opt_event_balance, "any other value stays"
END SUB

SUB TestVictoryToggleRule
victory_rule(VICTORY_CITIES) = 16
CALL victory_toggle_rule(VICTORY_CITIES)
AssertEqualInt -16, victory_rule(VICTORY_CITIES), "off: the number as a negative"
CALL victory_toggle_rule(VICTORY_CITIES)
AssertEqualInt 16, victory_rule(VICTORY_CITIES), "on again"
END SUB

' ------------------------------------------- the Commands menu's rules

SUB TestArmySetOrder
CALL army_set_order(3, 17)
AssertEqualInt 17, army_order(3), "a city to march to"
CALL army_set_order(3, ORDER_NONE)
AssertEqualInt ORDER_NONE, army_order(3), "cancelled"
CALL turn_set_moves_done(1): AssertEqualInt 1, turn_moves_done, "no army left to move"
CALL turn_set_moves_done(0): AssertEqualInt 0, turn_moves_done, "open again"
END SUB

SUB TestCityBuildFort
side_cash(SIDE_REBEL) = 450: city_fort(25) = 1
CALL city_build_fort(SIDE_REBEL, 25)
AssertEqualInt 2, city_fort(25), "a level more"
AssertEqualInt 450 - COST_FORT, side_cash(SIDE_REBEL), "paid for"
END SUB

SUB TestCapitalMove
side_cash(SIDE_REBEL) = 700: side_capital(SIDE_REBEL) = 33: side_victory_points(SIDE_UNION) = 10
CALL capital_move_pay(SIDE_REBEL)
AssertEqualInt 700 - COST_MOVE_CAPITAL, side_cash(SIDE_REBEL), "paid"
AssertEqualInt 60, side_victory_points(SIDE_UNION), "50 points to the other side"
AssertEqualInt 33, side_capital(SIDE_REBEL), "the capital has not moved yet"
CALL capital_move_to(SIDE_REBEL, 25)
AssertEqualInt 25, side_capital(SIDE_REBEL), "moved"
END SUB

' Relieve: the old leader goes back to his army's slot among the free leaders. The army
' takes the new leader with a point less than his rating and loses a level of experience.
SUB TestArmyRelieveLeader
army_name$(3) = "Fremont": army_leader_rating(3) = 2: army_experience(3) = 4
leader_name$(7) = "Grant": leader_rating(7) = 9
CALL army_free_leader(3)
AssertEqualStr "Fremont", leader_name$(3), "free again, in the army's slot"
CALL army_take_leader(3, 7)
AssertEqualStr "Grant", army_name$(3), "the new leader"
AssertEqualStr "", leader_name$(7), "no longer free"
AssertEqualInt 8, army_leader_rating(3), "a point less than his rating"
AssertEqualInt 3, army_experience(3), "a level of experience lost"
AssertEqualInt ORDER_BUSY, army_order(3), "busy for the month"
END SUB

' The rating comes from the new leader's slot, and neither number goes below 0.
SUB TestArmyTakeLeaderAtZero
army_name$(3) = "Fremont": leader_name$(7) = "Banks"
CALL army_take_leader(3, 7)
AssertEqualInt 0, army_leader_rating(3), "a rating of 0 stays 0"
AssertEqualInt 0, army_experience(3), "no experience stays none"
END SUB

' ------------------------------------------------- saved games (port/files.bm)

SUB TestTurnResetCommands
turn_recruit_state = -1: turn_moves_done = 1: turn_navy_done = 1
CALL turn_reset_commands
AssertEqualInt 0, turn_recruit_state, "Troops open"
AssertEqualInt 0, turn_moves_done, "Moves open"
AssertEqualInt 0, turn_navy_done, "Ships open"
END SUB

' Before each main menu: Ships is closed when the side has no fleet and under 100 in cash.
' In a two-player game with no side set, the Union plays.
SUB TestTurnCheckCommands
current_side = SIDE_UNION: opt_players = PLAYERS_ONE
side_cash(SIDE_UNION) = COST_SHIP - 1: fleet_city(SIDE_UNION) = 30
CALL turn_check_commands
AssertEqualInt 0, turn_navy_done, "a fleet: Ships stays open"
fleet_city(SIDE_UNION) = 0: side_cash(SIDE_UNION) = COST_SHIP
CALL turn_check_commands
AssertEqualInt 0, turn_navy_done, "no fleet, the price of a ship: open"
side_cash(SIDE_UNION) = COST_SHIP - 1
CALL turn_check_commands
AssertEqualInt 1, turn_navy_done, "no fleet and too little cash: closed"
current_side = SIDE_NONE: opt_players = PLAYERS_TWO
CALL turn_check_commands
AssertEqualInt SIDE_UNION, current_side, "two players and no side: the Union"
CALL turn_close_recruiting
AssertEqualInt -1, turn_recruit_state, "Troops closed"
END SUB

' After a turn ends: with one player the month is played. With two, the Rebels' turn follows
' the Union's, and the month is played after the Rebels'.
SUB TestTurnNextPlayer
opt_players = PLAYERS_ONE: current_side = SIDE_REBEL
CALL turn_next_player(over)
AssertEqualInt 1, over, "one player: the month is played"
AssertEqualInt SIDE_REBEL, current_side, "and the player keeps the side"
opt_players = PLAYERS_TWO: current_side = SIDE_UNION
CALL turn_next_player(over)
AssertEqualInt 0, over, "two players, after the Union: no month yet"
AssertEqualInt SIDE_REBEL, current_side, "the Rebels' turn"
CALL turn_next_player(over)
AssertEqualInt 1, over, "after the Rebels: the month is played"
AssertEqualInt SIDE_UNION, current_side, "then the Union again"
END SUB

SUB TestGameReset
game_over = 1: turn_recruit_state = -1: saves_exist = 0: emancipation_done = 1: union_income_bonus = 252
army_size(7) = 90: army_city(7) = 12: army_order(7) = 5: army_leader_rating(7) = 4: army_name$(7) = "Banks"
fleet_size(SIDE_REBEL) = 3: fleet_city(SIDE_REBEL) = 27: train_army(SIDE_UNION) = 7: train_city(SIDE_UNION) = 30
side_victory_points(SIDE_UNION) = 400: victory_rule(VICTORY_MONTH) = 3
CALL game_reset
AssertEqualInt 0, game_over, "the game is on"
AssertEqualInt 0, turn_recruit_state, "Troops open"
AssertEqualInt 1, saves_exist, "Load open"
AssertEqualInt 0, emancipation_done, "no Emancipation Proclamation yet"
AssertEqualInt 0, union_income_bonus, "no extra income yet"
AssertEqualInt 0, army_size(7) + army_city(7) + army_order(7) + army_leader_rating(7), "no army"
AssertEqualStr "", army_name$(7), "nor its name"
AssertEqualInt 0, fleet_size(SIDE_REBEL) + fleet_city(SIDE_REBEL), "no fleet"
AssertEqualInt 0, train_army(SIDE_UNION) + train_city(SIDE_UNION), "no train"
AssertEqualInt 0, side_victory_points(SIDE_UNION), "no points"
AssertEqualInt 1, victory_rule(VICTORY_MONTH), "the time limit's month is January until the scenario sets it"
END SUB

' The settings as a new game takes them. The Union player on Rebel ++ (1) gives the Rebels
' 500; cash becomes income, and up to 50 comes on top.
SUB TestGameApplySettingsUnion
RANDOMIZE 1
opt_realism = REALISM_ON: turn_year = 1861: fleet_ships$(SIDE_UNION) = "WIIW"
opt_players = 0: current_side = SIDE_NONE: opt_pause! = 0: opt_difficulty = 1
side_cash(SIDE_UNION) = 300: side_cash(SIDE_REBEL) = 50
CALL game_apply_settings
AssertEqualStr "WWWW", fleet_ships$(SIDE_UNION), "no ironclads before 1862 under realism"
AssertEqualInt PLAYERS_ONE, opt_players, "one player when the setting is not 1 or 2"
AssertEqualInt SIDE_UNION, current_side, "the Union when no side is set"
AssertEqualInt 7, opt_event_balance, "events favor the Rebels"
AssertTrue opt_pause! = 2, "the display speed is Normal when not set"
AssertEqualInt 300, side_income(SIDE_UNION), "the Union's income is its cash"
AssertEqualInt 550, side_income(SIDE_REBEL), "the Rebels' cash and income with 500 for Rebel ++"
AssertTrue side_cash(SIDE_UNION) >= 300 AND side_cash(SIDE_UNION) <= 350, "up to 50 more:" + STR$(side_cash(SIDE_UNION))
END SUB

' The Rebel player on Union ++ (5) gives the Union 500. Ironclads stay without realism.
SUB TestGameApplySettingsRebel
RANDOMIZE 1
opt_realism = REALISM_OFF: turn_year = 1861: fleet_ships$(SIDE_UNION) = "WI"
opt_players = PLAYERS_ONE: current_side = SIDE_REBEL: opt_pause! = 8: opt_difficulty = 5
side_cash(SIDE_UNION) = 300: side_cash(SIDE_REBEL) = 50
CALL game_apply_settings
AssertEqualStr "WI", fleet_ships$(SIDE_UNION), "ironclads stay"
AssertEqualInt 3, opt_event_balance, "events favor the Union"
AssertTrue opt_pause! = 8, "a display speed that is set stays"
AssertEqualInt 800, side_income(SIDE_UNION), "the Union's cash and income with 500 for Union ++"
AssertEqualInt 50, side_income(SIDE_REBEL), "the Rebels' income"
opt_players = PLAYERS_TWO
CALL game_apply_settings
AssertEqualInt SIDE_UNION, current_side, "two players: the Union starts"
END SUB

' A game saved in a slot and loaded again, in a folder of the test's own. save_game also
' writes the settings (cws.cfg), and load_game reads them.
SUB TestSaveGameAndLoadItAgain
CHDIR TestTempDir$
turn_month = 7: turn_year = 1863: union_income_bonus = 252: current_side = SIDE_REBEL
army_name$(22) = "Jackson": army_size(22) = 180: army_leader_rating(22) = 9: army_city(22) = 12
army_experience(22) = 3: army_supply(22) = 4: army_order(22) = 11
leader_name$(22) = "Jackson": leader_name$(23) = "Pemberton"
city_army(12) = 22: city_owner(12) = SIDE_REBEL: city_fort(12) = 1
side_cash(SIDE_REBEL) = 345: side_capital(SIDE_REBEL) = 33: side_victory_points(SIDE_UNION) = 77
fleet_ships$(SIDE_UNION) = "WWI": fleet_city(SIDE_UNION) = 30
train_army(SIDE_REBEL) = 22: train_city(SIDE_REBEL) = 25
opt_difficulty = 4: opt_history = 1
CALL save_game(3)
AssertEqualStr "CWS3.SAV", DIR$("cws3.sav"), "the slot's file"

turn_month = 0: turn_year = 0: union_income_bonus = 0: current_side = SIDE_UNION
army_name$(22) = "": army_size(22) = 0: army_leader_rating(22) = 0: army_city(22) = 0
army_experience(22) = 0: army_supply(22) = 0: army_order(22) = 0
city_army(12) = 0: city_owner(12) = 0: city_fort(12) = 0
side_cash(SIDE_REBEL) = 0: side_capital(SIDE_REBEL) = 0: side_victory_points(SIDE_UNION) = 0
fleet_ships$(SIDE_UNION) = "": fleet_city(SIDE_UNION) = 0: fleet_size(SIDE_UNION) = 0
train_army(SIDE_REBEL) = 0: train_city(SIDE_REBEL) = 0
opt_difficulty = 0: opt_history = 0
CALL load_game(3)
AssertEqualInt 7, turn_month, "the month"
AssertEqualInt 1863, turn_year, "the year"
AssertEqualInt 252, union_income_bonus, "the Union's extra income"
AssertEqualInt SIDE_REBEL, current_side, "the side that plays"
AssertEqualStr "Jackson", army_name$(22), "an army's name"
AssertEqualInt 180, army_size(22), "its size"
AssertEqualInt 9, army_leader_rating(22), "its leader's rating"
AssertEqualInt 12, army_city(22), "its city"
AssertEqualInt 3, army_experience(22), "its experience"
AssertEqualInt 4, army_supply(22), "its supplies"
AssertEqualInt 11, army_order(22), "its order"
AssertEqualStr "", leader_name$(22), "its leader is no longer free"
AssertEqualStr "Pemberton", leader_name$(23), "a leader without an army stays free"
AssertEqualInt 22, city_army(12), "a city's army"
AssertEqualInt SIDE_REBEL, city_owner(12), "its owner"
AssertEqualInt 1, city_fort(12), "its fort"
AssertEqualInt 345, side_cash(SIDE_REBEL), "a side's cash"
AssertEqualInt 33, side_capital(SIDE_REBEL), "its capital"
AssertEqualInt 77, side_victory_points(SIDE_UNION), "victory points"
AssertEqualStr "WWI", fleet_ships$(SIDE_UNION), "a fleet's ships"
AssertEqualInt 3, fleet_size(SIDE_UNION), "their count, from the ships"
AssertEqualInt 30, fleet_city(SIDE_UNION), "its port"
AssertEqualInt 22, train_army(SIDE_REBEL), "the army on the train"
AssertEqualInt 25, train_city(SIDE_REBEL), "where it goes"
AssertEqualInt 4, opt_difficulty, "a setting, from cws.cfg"
AssertEqualInt 1, opt_history, "another"
END SUB

' saves_exist goes to 0 when no saved game is on the disk, and nothing here sets it back.
SUB TestSavedGamesCheck
CHDIR TestTempDir$
saves_exist = 1
CALL saved_games_check
AssertEqualInt 0, saves_exist, "no saved game"
CALL save_game(1)
CALL saved_games_check
AssertEqualInt 0, saves_exist, "still 0 after a save (as in the original)"
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
'$INCLUDE: '../ui/main_menu.bm'
'$INCLUDE: '../ui/orders.bm'
'$INCLUDE: '../ui/files.bm'
'$INCLUDE: '../ui/options.bm'
'$INCLUDE: '../ui/reports.bm'
'$INCLUDE: '../ui/screen.bm'
'$INCLUDE: '../ui/messages.bm'
'$INCLUDE: '../ui/battle.bm'
'$INCLUDE: '../ui/railroad.bm'
'$INCLUDE: '../ui/city.bm'
'$INCLUDE: '../ui/army.bm'
'$INCLUDE: '../ui/navy.bm'
'$INCLUDE: '../ui/turn.bm'
'$INCLUDE: '../ui/ai.bm'
'$INCLUDE: '../ui/events.bm'
'$INCLUDE: '../ui/victory.bm'
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
