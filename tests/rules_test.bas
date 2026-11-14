' Unit tests of the game's rules that draw nothing.
' Run from the repo's folder:  qb64rust test tests/rules_test.bas
'
' Each test runs in a program of its own, so every shared array starts at
' zero. A test sets the few values the SUB reads, calls it and checks what
' the code gives today. These tests record behavior; they do not judge it.
' The Union's armies are 1 to 20, the Rebels' 21 to 40. Side 1 is the Union.

'$INCLUDE: '../cws.bi'

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

SUB TestRailroadCapacityCountsBySide
    train_capacity(1) = 600: opt_realism = 1: side_city_count(1) = 23
    current_side = 2
    limit = railroad_capacity(1): AssertEqualInt 660, limit, "the Union's 12 cities above 11, whoever plays"
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
' A draw around mean with the variance given. It sums 12 RNDs and takes off
' 5.5, though the sum averages 6, so the draws center on mean + SQR(variance) / 2.

SUB TestNormalDrawsHigh
    RANDOMIZE 1
    total& = 0
    FOR i = 1 TO 2000
        total& = total& + normal_random_number(100, 100)
    NEXT i
    avg! = total& / 2000
    AssertTrue avg! > 103 AND avg! < 107, "the average of 2000 draws is near 105, not 100:" + STR$(avg!)
END SUB

SUB TestNormalWithNoVarianceIsTheMean
    AssertEqualInt 70, normal_random_number(70, 0), "variance 0"
END SUB

' ------------------------------------------------------------- text_replace$

SUB TestTextReplaceEveryPlace
    t$ = "{city} and {city}"
    AssertEqualStr "Atlanta and Atlanta", text_replace$(t$, "{city}", "Atlanta"), "both places"
    AssertEqualStr "{city} and {city}", t$, "the text passed in is unchanged"
    AssertEqualStr "a{a}b", text_replace$("ab", "a", "a{a}"), "the new text is not searched again"
    AssertEqualStr "none here", text_replace$("none here", "{side}", "Union"), "nothing to replace"
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

SUB TestBattleFightTakesSupplyFromTheArmies
    RANDOMIZE 1
    army_supply(1) = 2: army_supply(2) = 1: army_supply(21) = 3: army_supply(22) = 0
    CALL battle_fight(3, 6, 21, 22, winner, loser, rounds)
    AssertEqualInt 2, army_supply(1), "not army 1"
    AssertEqualInt 1, army_supply(2), "nor army 2"
    AssertEqualInt 2, army_supply(21), "the attacker loses a day"
    AssertEqualInt 0, army_supply(22), "the defender has none to lose"
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

SUB TestBattleCasualtiesBySide
    army_size(3) = 120: army_size(21) = 80
    CALL battle_apply_losses(3, 21, 3, 10, 20)
    AssertEqualInt 110, army_size(3), "the attacker loses 10"
    AssertEqualInt 60, army_size(21), "the defender loses 20"
    AssertEqualInt 10, side_casualties&(1), "Union army 3's losses count for the Union"
    AssertEqualInt 20, side_casualties&(2), "and the Rebels' for the Rebels"
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
' The Balance setting's extra men go to the computer's side when the setting favors it.
SUB TestArmyRecruitBonus
    current_side = SIDE_UNION: opt_difficulty = 1: opt_realism = REALISM_OFF
    army_size(21) = 100: army_city(21) = 0: army_size(1) = 100: army_city(1) = 0
    CALL army_add_recruits(SIDE_REBEL, 21, isolated)
    AssertEqualInt 155, army_size(21), "the computer's Rebels: 4,500 and 1,000 more"
    CALL army_add_recruits(SIDE_UNION, 1, isolated)
    AssertEqualInt 145, army_size(1), "the player's Union: 4,500 only"
    current_side = SIDE_REBEL: opt_difficulty = 5: army_size(1) = 100
    CALL army_add_recruits(SIDE_UNION, 1, isolated)
    AssertEqualInt 155, army_size(1), "the computer's Union at Balance 5: 1,000 more"
    opt_difficulty = DIFFICULTY_EVEN: army_size(21) = 100
    CALL army_add_recruits(SIDE_REBEL, 21, isolated)
    AssertEqualInt 145, army_size(21), "an even Balance: none"
END SUB

SUB TestArmyRaiseGetsTheRecruitBonus
    RANDOMIZE 1
    current_side = SIDE_UNION: opt_difficulty = 2: opt_realism = REALISM_OFF
    leader_name$(22) = "Hood": city_owner(9) = SIDE_REBEL: city_road(9, 1) = 10: city_owner(10) = SIDE_REBEL
    CALL army_raise(SIDE_REBEL, 22, 9)
    AssertEqualInt 75, army_size(22), "7,000 and 500 more"
END SUB

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

SUB TestArmyAddRecruitsWithRealismCutOff
    opt_realism = REALISM_ON: opt_difficulty = 3: current_side = 1
    city_value(7) = 20: army_city(4) = 7: army_size(4) = 100: side_cash(1) = 300
    CALL army_add_recruits(1, 4, isolated)
    AssertEqualInt 120, army_size(4), "(2 * 20 + 20) \ 3 more: city 7 has no road to a Union city"
    AssertEqualInt 1, isolated, "isolated"
END SUB

' recruit_troops: the men a city gives under the Realism setting.
SUB TestRecruitTroopsByCityValue
    city_value(7) = 20: city_value(8) = 20: city_road(7, 1) = 8: city_owner(8) = 1
    AssertEqualInt 93, recruit_troops(1, 7, 0), "a new army: 3 * 20 + 33"
    AssertEqualInt 60, recruit_troops(1, 7, 1), "added men: 2 * 20 + 20"
    AssertEqualInt 31, recruit_troops(2, 7, 0), "a third, cut off from the Rebels' cities"
    AssertEqualInt 20, recruit_troops(2, 7, 1), "a third of 60"
    AssertEqualInt 70, recruits_cut_off(1, 7, 70), "not cut off: all of it"
    AssertEqualInt 23, recruits_cut_off(2, 7, 70), "cut off: 70 \ 3"
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
    CALL turn_update_victory_points(SIDE_UNION)
    CALL turn_update_victory_points(SIDE_REBEL)
    AssertEqualInt 154, side_victory_points(1), "80, 24 for income and cities, 50 for 30 cities"
    AssertEqualInt 170, side_victory_points(2), "8, 12 for income and cities, 50 for 30 cities and 100 for 35"
END SUB

SUB TestOnlyUnionVictoryPointsStopAtZero
    side_victory_points(1) = -50: side_victory_points(2) = -50
    side_city_count(1) = 5: side_city_count(2) = 20
    current_side = SIDE_REBEL
    CALL turn_update_victory_points(SIDE_UNION)
    CALL turn_update_victory_points(SIDE_REBEL)
    AssertEqualInt 0, side_victory_points(1), "the Union's -38 stops at 0"
    AssertEqualInt -34, side_victory_points(2), "the Rebels' -40 and 6 for their cities stays below 0"
    AssertTrue ai_strength_ratio! = .7, "the Union holds 5 cities: the Rebel computer gains .7"
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
    CALL navy_blast(1, result)
    AssertEqualInt BOMBARD_CAPITAL_HOLDS, result, "the capital stays loyal"
    AssertEqualInt 2, city_owner(25), "still the Rebels'"
    fleet_city(1) = 7: city_owner(7) = 2: city_value(7) = 10
    CALL navy_blast(1, result)
    AssertEqualInt BOMBARD_TURNS_NEUTRAL, result, "20 ships: the city always gives in"
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
    AssertEqualInt 10, side_victory_points(1), "10 points for the winner"
    AssertEqualInt 0, side_victory_points(2), "none for the loser"
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
    AssertEqualInt 5, ai_fortify_pick(2), "10,000 of the player's men next to 5,000"
    opt_ai_aggression = 3
    AssertEqualInt 0, ai_fortify_pick(2), "an aggressive computer does not fortify"
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
' The events are rows of the table read from scenarios\EVENTS.DAT. event_find gives the row
' of a name. script_dice$ gives event_roll its draws, as CWS_DICE does under a script: the
' chance of an event, the side, then the draws of the side's events in the file's order.
' The Balance setting 5, difficulty 3 and 1863 give a chance of .135; a draw of 0 passes it.
' A second draw of 0 gives the South's events, one of .9 the Union's.

' Reads the game's events table, and sets what most tests of event_roll start from.
' A test's program moves to its own folder when it starts; _STARTDIR$ is this file's folder.
SUB events_for_test
    side_name$(1) = "Union": side_name$(2) = "Rebel"
    CALL load_events(_STARTDIR$ + "/../scenarios/events.dat")
    opt_event_balance = 5: opt_difficulty = 3: current_side = 2: turn_year = 1863
END SUB

SUB TestLoadEventsReadsTheTable
    CALL events_for_test
    AssertEqualStr "", event_file_error$, "the whole file was read"
    AssertEqualInt 18, event_count, "an announcement, nine events for the South and eight for the Union"
    AssertEqualStr "SPECIAL EVENT...", event_banner$, "the banner"
    AssertEqualInt 4, chance_count, "the chance has four factors"
    AssertEqualInt CHANCE_YEAR, chance_kind(2), "the second: the years"
    AssertEqualInt 1860, chance_value#(2), "since 1860"
    AssertEqualInt 1, chance_has_most, "the chance has a cap"
    row = event_find("ironclads")
    AssertEqualInt 1, event_before(row), "an announcement"
    AssertEqualInt SIDE_NONE, event_favors(row), "that favors no side"
    row = event_find("riots")
    AssertEqualInt SIDE_REBEL, event_favors(row), "the side by its name"
    AssertEqualInt 0, event_before(row), "an event of the roll"
    AssertEqualInt EFFECT_CITY_NEUTRAL, event_effect(row), "an effect without a number"
    AssertEqualStr " Riots have broken out in {city}", event_text$(row, 0), "quotes keep the space at the start"
    AssertEqualStr "{city} is now NEUTRAL !", event_outcome$(row), "the outcome"
    row = event_find("mercenaries")
    AssertEqualInt 2, event_text_count(row), "two texts"
    AssertEqualInt 2, event_if_count(row), "two conditions"
    AssertEqualInt SUBJECT_CITIES, condition_subject(event_if_first(row) + 1), "the second: the cities"
    AssertEqualInt RELATION_AT_LEAST, condition_relation(event_if_first(row) + 1), "at least"
    AssertEqualInt 30, condition_value!(event_if_first(row) + 1), "30"
    row = event_find("uprising")
    AssertEqualInt event_find("furloughs"), event_instead(row), "instead names an event further down"
    AssertEqualInt 2, event_instead_count(row), "with two conditions"
    AssertEqualInt 0, event_listed(event_find("furloughs")), "which is not in the list"
    row = event_find("emancipation")
    AssertEqualInt 100, event_amount!(row, 0), "the effect's first number"
    AssertEqualInt -100, event_amount!(row, 1), "and its second"
    AssertEqualInt REDRAW_MAP, event_redraw(row), "the map is drawn again"
    AssertEqualInt event_find("stanton"), event_then(event_find("rifles")), "then names an event"
END SUB

' The ironclads' announcement repeats the rule's date (IRONCLAD_YEAR, IRONCLAD_MONTH of
' cws.bi), which the navy uses. The two must agree.
SUB TestEventIroncladsMatchTheRule
    CALL events_for_test
    row = event_find("ironclads")
    first = event_if_first(row)
    AssertEqualInt 3, event_if_count(row), "the Realism setting, the year and the month"
    AssertEqualInt SUBJECT_YEAR, condition_subject(first + 1), "the year"
    AssertEqualInt IRONCLAD_YEAR, condition_value!(first + 1), "is IRONCLAD_YEAR"
    AssertEqualInt SUBJECT_MONTH, condition_subject(first + 2), "the month"
    AssertEqualInt RELATION_BELOW, condition_relation(first + 2), "below"
    AssertEqualInt IRONCLAD_MONTH, condition_value!(first + 2), "IRONCLAD_MONTH"
END SUB

' The chance line gives the same number as the line it replaced, bit for bit, for every year
' of the war and every weight.
SUB TestEventChanceAsBefore
    CALL events_for_test
    FOR turn_year = 1861 TO 1870
        FOR w = 1 TO 5
            old! = .005 * (turn_year - 1860) * w * w: IF old! > .9 THEN old! = .9
            AssertEqualSingle old!, event_chance!(w), "the year" + STR$(turn_year) + ", weight" + STR$(w)
        NEXT w
    NEXT turn_year
END SUB

' Writes an events file of the test's own and reads it. The lines are parted by "|".
SUB events_from_text (lines$)
    rest$ = lines$
    f = FREEFILE: OPEN TestTempDir$ + "events.dat" FOR OUTPUT AS #f
    DO WHILE rest$ <> ""
        cut = INSTR(rest$, "|")
        IF cut = 0 THEN PRINT #f, rest$: rest$ = "" ELSE PRINT #f, LEFT$(rest$, cut - 1): rest$ = MID$(rest$, cut + 1)
    LOOP
    CLOSE #f
    side_name$(1) = "Union": side_name$(2) = "Rebel"
    CALL load_events(TestTempDir$ + "events.dat")
END SUB

' The reason of event_file_error$, without the file and the line.
FUNCTION events_why$
    events_why$ = MID$(event_file_error$, INSTR(event_file_error$, ": ") + 2)
END FUNCTION

SUB TestLoadEventsNamesTheLineItCannotRead
    CALL events_from_text("; a comment|[rain]|favors = 2|effect = rain 3|text = never read")
    AssertEqualStr TestTempDir$ + "events.dat, line 4: unknown effect: rain", event_file_error$, "an effect that is not known"
    AssertEqualInt SIDE_REBEL, event_favors(1), "favors takes a number too"
    AssertEqualInt 0, event_text_count(1), "the reading stops at the line"
    CALL events_from_text("[rain]|favors = France")
    AssertEqualStr "favors needs a side's name, 1 or 2", events_why$, "a side that is not known"
    CALL events_from_text("[rain]|favors = 1x")
    AssertEqualStr "favors needs a side's name, 1 or 2", events_why$, "a number with more after it"
    CALL events_from_text("[rain]|favors = 1|for = Spain")
    AssertEqualStr "for needs a side's name, 1 or 2", events_why$, "for"
    CALL events_from_text("[rain]|when = later")
    AssertEqualStr "when needs before or roll", events_why$, "when"
    CALL events_from_text("[rain]|listed = false")
    AssertEqualStr "listed needs yes or no", events_why$, "listed"
    CALL events_from_text("[rain]|favors = Union|if = year 1864")
    AssertEqualStr "cannot read the condition: year 1864", events_why$, "a condition without its comparison"
    CALL events_from_text("[rain]|favors = Union|if = day is 4")
    AssertEqualStr "cannot read the condition: day is 4", events_why$, "a subject that is not known"
    CALL events_from_text("[rain]|favors = Union|if = year near 1864")
    AssertEqualStr "cannot read the condition: year near 1864", events_why$, "a comparison that is not known"
    CALL events_from_text("[rain]|favors = Union|if = roll above x")
    AssertEqualStr "cannot read the condition: roll above x", events_why$, "a number that is not a number"
    CALL events_from_text("[rain]|favors = Union|if = roll above .5.5")
    AssertEqualStr "cannot read the condition: roll above .5.5", events_why$, "two points"
    CALL events_from_text("[rain]|favors = Union|instead = snow")
    AssertEqualStr "instead needs an event, the word if and a condition", events_why$, "instead without a condition"
    CALL events_from_text("[rain]|favors = Union|redraw = sky")
    AssertEqualStr "redraw needs fleets or map", events_why$, "redraw"
    CALL events_from_text("[rain]|favors = Union|weather = wet")
    AssertEqualStr "unknown line: weather", events_why$, "a line that is not known"
    CALL events_from_text("[rain]|favors = Union|text = a|text = b|text = c|text = d|text = e")
    AssertEqualStr "too many texts", events_why$, "five texts"
    CALL events_from_text("[rain]|a line")
    AssertEqualStr "the line has no =", events_why$, "no ="
    CALL events_from_text("favors = Union")
    AssertEqualStr "the line belongs to no event: favors", events_why$, "a line before the first event"
    CALL events_from_text("[rain")
    AssertEqualStr "a name in brackets needs its ]", events_why$, "a bracket left open"
    CALL events_from_text("[rain]|favors = 1|[rain]")
    AssertEqualStr "a second event named rain", events_why$, "a name twice"
    CALL events_from_text("[rain]|favors = 1|favors = 2")
    AssertEqualStr "a second favors line", events_why$, "a line twice"
    CALL events_from_text("[rain]|if = once|effect = cash 1|if = roll above .5")
    AssertEqualStr "a second if line", events_why$, "if twice"
    CALL events_from_text("[events]|banner = a|[events]")
    AssertEqualStr "a second [events]", events_why$, "[events] twice"
    CALL events_from_text("[events]|banner = a|banner = b")
    AssertEqualStr "a second banner line", events_why$, "banner twice"
    CALL events_from_text("[events]|motto = none")
    AssertEqualStr "unknown line in [events]: motto", events_why$, "a line of [events] that is not known"
END SUB

' Each effect takes the numbers it needs, no more and no fewer.
SUB TestLoadEventsCountsTheEffectsNumbers
    CALL events_from_text("[rain]|effect = cash")
    AssertEqualStr "cash needs 1 number", events_why$, "cash without its amount"
    CALL events_from_text("[rain]|effect = cash 1.2.3")
    AssertEqualStr "unknown effect: cash 1.2.3", events_why$, "an amount that is not a number"
    CALL events_from_text("[rain]|effect = points")
    AssertEqualStr "points needs 1 or 2 numbers", events_why$, "points"
    CALL events_from_text("[rain]|effect = armies grow 1.1")
    AssertEqualStr "armies grow needs 2 numbers", events_why$, "armies grow"
    CALL events_from_text("[rain]|effect = city neutral 3")
    AssertEqualStr "city neutral needs no number", events_why$, "city neutral"
    CALL events_from_text("[rain]|effect = points 1 2 3")
    AssertEqualStr "too many numbers in the effect", events_why$, "three numbers"
END SUB

SUB TestLoadEventsReadsTheChance
    CALL events_from_text("[events]|banner = b|chance = .05 x (difficulty - 3), plus .1")
    AssertEqualStr "", event_file_error$, "read"
    opt_difficulty = 5
    AssertEqualSingle .05 * (5 - 3) + .1, event_chance!(1), "as Wars of Napoleon works it out"
    CALL events_from_text("[events]|banner = b|chance = year x difficulty x 2")
    turn_year = 3: opt_difficulty = 4
    AssertEqualSingle 24, event_chance!(1), "the year and the difficulty alone"
    CALL events_from_text("[events]|banner = b|chance = .05 x luck")
    AssertEqualStr "cannot read the chance: luck", events_why$, "a factor that is not known"
    CALL events_from_text("[events]|banner = b|chance = (year - x)")
    AssertEqualStr "cannot read the chance: (year - x)", events_why$, "a year less a word"
    CALL events_from_text("[events]|banner = b|chance = (weight - 1)")
    AssertEqualStr "cannot read the chance: (weight - 1)", events_why$, "only the year and the difficulty take a number off"
    CALL events_from_text("[events]|banner = b|chance = .1, minus 2")
    AssertEqualStr "cannot read the chance: minus 2", events_why$, "a part after the factors that is not known"
    CALL events_from_text("[events]|banner = b|chance = .1, at most y")
    AssertEqualStr "cannot read the chance: at most y", events_why$, "a cap that is not a number"
    CALL events_from_text("[events]|banner = b|chance = 1 x 1 x 1 x 1 x 1 x 1 x 1")
    AssertEqualStr "too many factors in the chance", events_why$, "seven factors"
END SUB

SUB TestLoadEventsChecksNamesAtTheEnd
    CALL events_from_text("[rain]|text = wet")
    AssertEqualStr TestTempDir$ + "events.dat, [rain]: has no favors line", event_file_error$, "favors is needed"
    CALL events_from_text("[rain]|when = before|effect = cash 1")
    AssertEqualStr "has an effect but no side: it needs a favors or a for line", events_why$, "an announcement with an effect"
    CALL events_from_text("[rain]|favors = Union|then = snow")
    AssertEqualStr "names an event that is not there: snow", events_why$, "then"
    CALL events_from_text("[rain]|favors = Union|instead = hail if roll above .5")
    AssertEqualStr "names an event that is not there: hail", events_why$, "instead"
    CALL events_from_text("[events]|chance = .1|[rain]|favors = 1")
    AssertEqualStr TestTempDir$ + "events.dat: [events] needs a banner line", event_file_error$, "the banner"
    CALL events_from_text("[events]|banner = a")
    AssertEqualStr "[events] needs a chance line", events_why$, "the chance"
END SUB

SUB TestLoadEventsStopsAtTheLimits
    many$ = ""
    FOR i = 1 TO MAX_EVENTS + 1: many$ = many$ + "[e" + LTRIM$(STR$(i)) + "]|": NEXT i
    CALL events_from_text(many$)
    AssertEqualStr "too many events", events_why$, "41 events"
    many$ = "[rain]|favors = Union|"
    FOR i = 1 TO 13: many$ = many$ + "[r" + LTRIM$(STR$(i)) + "]|favors = 1|if = once, once, once, once, once, once, once, once, once, once|": NEXT i
    CALL events_from_text(many$)
    AssertEqualStr "too many conditions", events_why$, "130 conditions"
END SUB

' A file of the test's own: the code knows no event by name. The chance is that of Wars of
' Napoleon. A third text is picked by a draw above two thirds, every comparison is used, and
' {side} names the side.
SUB TestEventsOfAnotherWar
    CALL events_from_text("[events]|banner = b|chance = .05 x (difficulty - 3), plus .1|[tribute]|favors = 1|when = roll|listed = yes|if = month below 3, cities at most 4, year at least 1805|effect = cash 10|text = a|text = b|text = {side} is paid|[calm]|favors = 1|effect = points 1|text = calm")
    AssertEqualStr "", event_file_error$, "read"
    opt_event_balance = 5: opt_difficulty = 3: current_side = 2: turn_year = 1863: turn_month = 2
    side_city_count(1) = 4
    script_dice$ = "0.1,.9,.7"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("tribute"), event, "a draw of .1 passes the chance of .1, and side 1's first event holds"
    AssertEqualInt 2, variant, "a draw above two thirds: the third text"
    AssertEqualInt 30, side_cash(1), "its cash"
    AssertEqualStr "Union is paid", event_message$(event_text$(event, variant)), "{side}"
    turn_month = 3: script_dice$ = "0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("calm"), event, "March: the next event"
    script_dice$ = ".11"
    CALL event_roll(event, variant, who)
    AssertEqualInt EVENT_NONE, event, "a draw of .11 fails the chance"
END SUB

' An event favors one side and its effect is for the other, as Wars of Napoleon's Hapsburgs
' give France cash. {side} names the side the effect is for.
SUB TestEventForAnotherSide
    CALL events_from_text("[events]|banner = b|chance = 1|[gold]|favors = 2|for = 1|effect = cash 100|text = gold for {side}")
    AssertEqualStr "", event_file_error$, "read"
    opt_event_balance = 5: opt_difficulty = 3: current_side = 2
    script_dice$ = "0,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("gold"), event, "the event of side 2"
    AssertEqualInt 300, side_cash(1), "the cash goes to side 1"
    AssertEqualInt 0, side_cash(2), "not to side 2"
    AssertEqualStr "gold for Union", event_message$(event_text$(event, variant)), "{side}"
END SUB

' An announcement comes before the roll, also with random events off. One that favors a side
' can carry out an effect, as Wars of Napoleon's Trafalgar does. A silent one lets the next
' come.
SUB TestEventAnnouncements
    CALL events_from_text("[events]|banner = b|chance = 1|[quiet]|when = before|favors = 2|effect = points 5|[trafalgar]|when = before|favors = 2|if = year is 1805, month is 11, roll above .2|effect = points 40|text = Nelson|[later]|favors = 1|effect = cash 1|text = later")
    AssertEqualStr "", event_file_error$, "read"
    opt_event_balance = 0: turn_year = 1805: turn_month = 11
    script_dice$ = ".5"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("trafalgar"), event, "the announcement, with random events off"
    AssertEqualInt 0, who, "rolled for no side"
    AssertEqualInt 45, side_victory_points(2), "the silent one first, then Trafalgar"
    script_dice$ = ".1"
    CALL event_roll(event, variant, who)
    AssertEqualInt EVENT_NONE, event, "the roll of .1 fails, and random events are off"
    AssertEqualInt 50, side_victory_points(2), "the silent one again"
END SUB

' "instead" takes the other event only when its effect can be carried out: ships need a fleet.
SUB TestEventInsteadNeedsItsEffect
    CALL events_from_text("[events]|banner = b|chance = 1|[calm]|favors = 1|effect = points 1|text = calm|instead = ships if roll above .5|[ships]|favors = 1|listed = no|effect = ships 2|text = ships")
    AssertEqualStr "", event_file_error$, "read"
    opt_event_balance = 5: opt_difficulty = 3: current_side = 2
    script_dice$ = "0,.9,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("calm"), event, "no fleet: no ships, so the event stays"
    fleet_city(1) = 4: fleet_size(1) = 1: fleet_ships$(1) = "W"
    script_dice$ = "0,.9,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("ships"), event, "with a fleet: the ships instead"
    AssertEqualInt 7, fleet_size(1), "two for each point of plus"
END SUB

SUB TestEventIroncladsComeFirst
    CALL events_for_test
    opt_realism = REALISM_ON: turn_year = IRONCLAD_YEAR: turn_month = 1: opt_event_balance = 0
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("ironclads"), event, "January 1862 with the Realism setting, even with random events off"
    turn_month = IRONCLAD_MONTH
    CALL event_roll(event, variant, who)
    AssertEqualInt EVENT_NONE, event, "not from March"
END SUB

SUB TestEventNoneWithoutBalance
    CALL events_for_test
    opt_event_balance = 0
    CALL event_roll(event, variant, who)
    AssertEqualInt EVENT_NONE, event, "the Balance setting 0: no events"
END SUB

SUB TestEventLoanForTheSouth
    CALL events_for_test
    side_city_count(2) = 15
    script_dice$ = "0,0,0,.5,.5,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("loan"), event, "no riot, no ships, no mercenaries: a loan"
    AssertEqualInt SIDE_UNION, who, "an event rolled for the Union is good for the South"
    AssertEqualInt 300, side_cash(2), "100 for each point of plus"
END SUB

SUB TestEventCottonForTheSouth
    CALL events_for_test
    side_city_count(2) = 15
    script_dice$ = "0,0,0,.5,.5,.4,.4"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("cotton"), event, "the loan's draw fails and the cotton's passes"
    AssertEqualInt 300, side_cash(2), "100 for each point of plus"
END SUB

SUB TestEventEnglishShipsJoinFleetInPort
    CALL events_for_test
    fleet_size(2) = 3: fleet_ships$(2) = "WWW": fleet_city(2) = 12
    script_dice$ = "0,0,0,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("english ships"), event, "no riot, and the draw for ships passes"
    AssertEqualInt 9, fleet_size(2), "two ships for each point of plus"
    AssertEqualStr "WWWWWWWWW", fleet_ships$(2), "all wooden"
    AssertEqualInt 12, fleet_city(2), "the fleet stays in its port"
END SUB

' Without a fleet in port the ships go to the Rebels' first sea port that the Union's fleet
' is not in. Without such a port the event does not happen and the list goes on.
SUB TestEventEnglishShipsNeedAPort
    CALL events_for_test
    city_owner(8) = 2: city_port_type(8) = PORT_SEA: city_owner(9) = 2: city_port_type(9) = PORT_SEA
    fleet_city(1) = 8
    script_dice$ = "0,0,0,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("english ships"), event, "a new fleet"
    AssertEqualInt 9, fleet_city(2), "in port 9: the Union's fleet is in port 8"
    AssertEqualInt 6, fleet_size(2), "of six ships"
    city_owner(8) = 1: city_owner(9) = 1: fleet_size(2) = 0: fleet_ships$(2) = "": fleet_city(2) = 0
    script_dice$ = "0,0,0,0,.5,.9,.9,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("uprising"), event, "no port: no ships, and the last event of the list comes"
    AssertEqualInt 0, fleet_size(2), "no ships"
END SUB

' The mercenaries form a new army in the capital under the next commander.
SUB TestEventMercenariesFormAnArmy
    CALL events_for_test
    CALL mercenaries_for_test
    side_city_count(2) = 30
    script_dice$ = "0,0,0,.5,0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("mercenaries"), event, "30 cities: mercenaries"
    AssertEqualInt 1, variant, "British"
    AssertEqualInt 22, event_army, "the next commander's slot"
    AssertEqualInt 25, army_city(22), "in the capital"
    AssertEqualInt 22, city_army(25), "the capital holds it"
    AssertEqualInt 300, army_size(22), "of the mercenaries"
    AssertEqualInt MAX_EXPERIENCE, army_experience(22), "with the best experience"
    AssertEqualInt ORDER_BUSY, army_order(22), "it has acted this month"
    AssertEqualStr "Longstreet", army_name$(22), "the commander's name"
    AssertEqualStr "", leader_name$(22), "who leaves the free leaders"
    AssertEqualStr "British mercenaries join Longstreet's army", event_message$(event_text$(event, variant)), "the text names it"
    army_size(22) = 0: army_city(22) = 0: city_army(25) = 0
END SUB

' With an army in the capital, the mercenaries join it.
SUB TestEventMercenariesJoinTheCapitalsArmy
    CALL events_for_test
    CALL mercenaries_for_test
    army_size(23) = 100: army_city(23) = 25: city_army(25) = 23: army_name$(23) = "Hood"
    side_city_count(2) = 30
    script_dice$ = "0,0,0,.5,0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt 23, event_army, "the army in the capital"
    AssertEqualInt 400, army_size(23), "gains them"
    AssertEqualStr "Longstreet", leader_name$(22), "no commander is used"
    army_size(23) = 0: army_city(23) = 0: city_army(25) = 0
END SUB

' The Rebels with no army, the capital 25 empty, and Longstreet the first free leader.
SUB mercenaries_for_test
    DIM i AS INTEGER
    FOR i = 21 TO 40: army_city(i) = 0: army_size(i) = 0: leader_name$(i) = "": NEXT i
    leader_name$(22) = "Longstreet": leader_rating(22) = 7
    side_capital(2) = 25: city_army(25) = 0
END SUB

' The South's last event. From June 1864 the furloughs take its place.
SUB TestEventUprisingAndFurloughs
    CALL events_for_test
    army_size(1) = 100: army_size(21) = 100
    script_dice$ = "0,0,0,.5,.5,.9,.9,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("uprising"), event, "every draw fails: the uprising"
    AssertEqualInt 1, variant, "its second text"
    AssertEqualInt 90, army_size(1), "the Union's armies lose a tenth"
    AssertEqualInt 100, army_size(21), "the Rebels' none"
    turn_year = 1864: turn_month = 6: army_size(1) = 100
    script_dice$ = "0,0,0,.5,.5,.9,.9,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("furloughs"), event, "June 1864: the furloughs instead"
    AssertEqualInt 0, variant, "its only text"
    AssertEqualInt 80, army_size(1), "a fifth"
END SUB

' Two events without a text: the Rebels' points in January 1864 and 1865. The list goes on.
SUB TestEventBonusInJanuary
    CALL events_for_test
    turn_year = 1864: turn_month = 1: side_city_count(2) = 15
    script_dice$ = "0,0,0,.5,.5,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt 50, side_victory_points(2), "50 points in January 1864"
    AssertEqualInt event_find("loan"), event, "and an event after it"
    turn_year = 1865
    script_dice$ = "0,0,0,.5,.5,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt 150, side_victory_points(2), "100 more in January 1865"
END SUB

' The South's riot is in a city the Union took. Without the Realism setting no city riots,
' and the event is still the month's.
SUB TestEventRiotsForTheSouth
    CALL events_for_test
    opt_realism = REALISM_HIGH: turn_month = 5: side_city_count(1) = 5
    city_first_owner(7) = 2: city_owner(7) = 1: city_name$(7) = "Atlanta"
    script_dice$ = "0,0,.95,.15"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("riots"), event, "a draw above .9"
    AssertEqualInt 7, event_city, "the draw .15 picks city 7"
    AssertEqualInt SIDE_NONE, city_owner(7), "it turns neutral"
    AssertEqualStr " Riots have broken out in Atlanta", event_message$(event_text$(event, 0)), "the text names the city"
    AssertEqualStr "Atlanta is now NEUTRAL !", event_message$(event_outcome$(event)), "and so does the outcome"
    opt_realism = REALISM_OFF
    script_dice$ = "0,0,.95"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("riots"), event, "the riot"
    AssertEqualInt 0, event_city, "in no city"
END SUB

SUB TestEventShipworks
    CALL events_for_test
    fleet_size(1) = 2: fleet_ships$(1) = "WI": fleet_city(1) = 5
    script_dice$ = "0,.9,0,.5"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("shipworks"), event, "the Union has a fleet, and the draw passes"
    AssertEqualInt SIDE_REBEL, who, "an event rolled for the Rebels is good for the Union"
    AssertEqualInt 5, fleet_size(1), "a ship for each point of plus"
    AssertEqualStr "WIWWW", fleet_ships$(1), "wooden"
    AssertEqualInt 5, fleet_city(1), "the fleet stays where it is"
END SUB

' A draw above .95 after the shipworks' own: a riot in a Rebel city takes their place.
SUB TestEventRiotsInsteadOfShipworks
    CALL events_for_test
    fleet_size(1) = 2: fleet_ships$(1) = "WW": fleet_city(1) = 5
    script_dice$ = "0,.9,0,.99"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("riots"), event, "the riot instead"
    AssertEqualInt 2, fleet_size(1), "no ships"
    fleet_city(1) = 0
    script_dice$ = "0,.9,0,.99"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("volunteers"), event, "without a fleet: no shipworks and no riot, and .99 is the volunteers' draw"
END SUB

' Each of the Union's first five armies that has men grows on a draw above .5.
SUB TestEventVolunteers
    CALL events_for_test
    army_size(1) = 100: army_size(2) = 100: army_size(6) = 100
    script_dice$ = "0,.9,.5,.7,.6,.4,.6,.6,.6"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("volunteers"), event, "a draw of .7 or more"
    AssertEqualInt 113, army_size(1), "a tenth more, and one for each point of plus"
    AssertEqualInt 100, army_size(2), "its draw failed"
    AssertEqualInt 0, army_size(3), "an army without men stays so"
    AssertEqualInt 100, army_size(6), "the sixth army is not looked at"
END SUB

SUB TestEventEmancipation
    CALL events_for_test
    side_victory_points(1) = 200: side_victory_points(2) = 200
    script_dice$ = "0,.9,.5,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("emancipation"), event, "the Proclamation, once, after 1862"
    AssertEqualInt 300, side_victory_points(1), "100 points for the Union"
    AssertEqualInt 100, side_victory_points(2), "100 from the Rebels"
    AssertEqualInt 1, event_done(event), "not again"
    script_dice$ = "0,.9,.5,0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("donations"), event, "the next time another event comes"
    AssertEqualInt 300, side_cash(1), "100 for each point of plus"
END SUB

SUB TestEventReelection
    CALL events_for_test
    turn_year = 1864: turn_month = 11: event_done(event_find("emancipation")) = 1
    side_victory_points(2) = 200
    script_dice$ = "0,.9,.5,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("reelection"), event, "November 1864"
    AssertEqualInt 100, side_victory_points(2), "the Rebels lose half their points"
END SUB

SUB TestEventDeserters
    CALL events_for_test
    event_done(event_find("emancipation")) = 1
    army_size(1) = 100: army_size(21) = 100
    script_dice$ = "0,.9,.5,0,0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("deserters"), event, "no donations, and the next draw passes"
    AssertEqualInt 92, army_size(21), "the Rebels' armies lose 8 in 100"
    AssertEqualInt 100, army_size(1), "the Union's none"
END SUB

' The rifles are followed by Stanton's prediction: its points and its text.
SUB TestEventRiflesThenStanton
    CALL events_for_test
    event_done(event_find("emancipation")) = 1
    army_experience(1) = 5: army_experience(2) = 9: army_experience(21) = 5
    script_dice$ = "0,.9,.5,0,0,0,.9"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("rifles"), event, "the last draw passes"
    AssertEqualInt 7, army_experience(1), "two more"
    AssertEqualInt 9, army_experience(2), "not past the best experience"
    AssertEqualInt 5, army_experience(21), "the Rebels' stay"
    AssertEqualInt 10, side_victory_points(1), "Stanton's ten points"
    script_dice$ = "0,.9,.5,0,0,0,0"
    CALL event_roll(event, variant, who)
    AssertEqualInt event_find("stanton"), event, "every draw fails: Stanton alone"
    AssertEqualInt 20, side_victory_points(1), "ten more"
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
    AssertEqualInt 2, turn_retreat_city(1, 1), "the richer city 3 has an army"
    city_army(3) = 0
    AssertEqualInt 3, turn_retreat_city(1, 1), "now city 3, the richest of the Rebels'"
    AssertEqualInt 4, turn_retreat_city(1, 2), "a Union defender goes to the Union's city"
    city_owner(4) = 2
    AssertEqualInt 0, turn_retreat_city(1, 2), "no Union city next to it"
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
    AssertEqualInt 25, side_victory_points(1), "25 points for the side of the army that won"
    AssertEqualInt 0, side_victory_points(2), "none for the loser's"
    AssertEqualInt 10, army_supply(1), "the winner takes its supplies"
    AssertEqualInt 0, army_supply(21), "which it has no more"
    army_supply(1) = 9: army_city(22) = 6: army_supply(22) = 4
    CALL turn_army_lost(22, 1)
    AssertEqualInt MAX_SUPPLY, army_supply(1), "up to the most an army holds"
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

' The cities where armies can combine: a city of the side with an army that holds it and
' another army that has no order.
SUB TestArmyListCombineCities
    city_name$(7) = "Paducah": city_owner(7) = SIDE_UNION: city_army(7) = 1
    army_city(1) = 7: army_city(2) = 7
    city_name$(3) = "Cairo": city_owner(3) = SIDE_UNION: city_army(3) = 4
    army_city(4) = 3: army_city(5) = 3: army_order(5) = 9
    city_name$(9) = "Boston": city_owner(9) = SIDE_UNION: city_army(9) = 6: army_city(6) = 9
    CALL army_list_combine_cities(SIDE_UNION)
    AssertEqualInt 1, menu_item_count, "one city: not the one whose second army has an order, nor the one with one army"
    AssertEqualInt 7, menu_value(1), "Paducah"
    CALL army_list_combine_cities(SIDE_REBEL)
    AssertEqualInt 0, menu_item_count, "none for the other side"
END SUB

' The computer razes a fort it takes without a battle under realism, in the map's lower part.
SUB TestAiRazesFort
    city_y(5) = 151: city_y(6) = 150
    opt_realism = REALISM_OFF
    AssertEqualInt 0, ai_razes_fort(5), "not without realism"
    opt_realism = REALISM_ON
    AssertEqualInt 1, ai_razes_fort(5), "with realism, below line 150"
    AssertEqualInt 0, ai_razes_fort(6), "not at line 150 or above"
END SUB

' ------------------------------------------ the army and fleet state, by name
' Each gives -1 or 0, as the comparison it stands for, so AND and OR work on it as before.

SUB TestArmyStateByName
    army_city(1) = 0: army_order(1) = ORDER_NONE
    AssertEqualInt 0, army_exists(1), "an empty slot"
    army_city(1) = 7
    AssertEqualInt -1, army_exists(1), "an army in city 7"
    AssertEqualInt 0, army_has_move(1), "ORDER_NONE is no move"
    AssertEqualInt 0, army_has_acted(1), "ORDER_NONE has not acted"
    army_order(1) = 12
    AssertEqualInt -1, army_has_move(1), "an order to city 12"
    AssertEqualInt 0, army_has_acted(1), "a move to make has not acted"
    army_order(1) = ORDER_BUSY
    AssertEqualInt 0, army_has_move(1), "ORDER_BUSY is no move"
    AssertEqualInt -1, army_has_acted(1), "ORDER_BUSY has acted"
    army_order(1) = ORDER_DONE
    AssertEqualInt -1, army_has_acted(1), "ORDER_DONE has acted"
END SUB

SUB TestFleetStateByName
    fleet_city(SIDE_UNION) = 0
    AssertEqualInt 0, fleet_exists(SIDE_UNION), "no fleet"
    AssertEqualInt 0, fleet_is_at_sea(SIDE_UNION), "no fleet is not at sea"
    fleet_city(SIDE_UNION) = 30
    AssertEqualInt -1, fleet_exists(SIDE_UNION), "a fleet off city 30"
    AssertEqualInt 0, fleet_is_at_sea(SIDE_UNION), "off a city is not at sea"
    fleet_city(SIDE_UNION) = FLEET_AT_SEA
    AssertEqualInt -1, fleet_exists(SIDE_UNION), "a fleet at sea exists"
    AssertEqualInt -1, fleet_is_at_sea(SIDE_UNION), "raiding"
    AssertEqualInt 0, fleet_exists(SIDE_REBEL), "the other side's is apart"
END SUB

' --------------------------------------- the fleets' small rules (phase 9)

SUB TestNavyMarkSideAndCountShips
    CALL navy_mark_side(SIDE_REBEL)
    AssertEqualInt SIDE_REBEL, city_owner(0), "city 0, no port, is the side's"
    fleet_ships$(SIDE_UNION) = "IWW": fleet_size(SIDE_UNION) = 7
    CALL navy_count_ships(SIDE_UNION)
    AssertEqualInt 3, fleet_size(SIDE_UNION), "counted from the list of ships"
    CALL turn_set_navy_done(1)
    AssertEqualInt 1, turn_navy_done, "the fleet has acted"
END SUB

SUB TestNavyHasIronclads
    opt_realism = REALISM_OFF: turn_year = 1861: turn_month = 5
    AssertEqualInt 1, navy_has_ironclads, "without realism: always"
    opt_realism = REALISM_ON
    AssertEqualInt 0, navy_has_ironclads, "with realism: not in 1861"
    turn_year = IRONCLAD_YEAR: turn_month = 1
    AssertEqualInt 0, navy_has_ironclads, "nor in January 1862"
    turn_month = IRONCLAD_MONTH
    AssertEqualInt 1, navy_has_ironclads, "from March 1862"
    turn_year = 1863: turn_month = 1
    AssertEqualInt 1, navy_has_ironclads, "and in every later year"
END SUB

' The ports for a new fleet are the side's sea ports without the one the enemy's fleet lies
' off. The ports to sail to are all sea ports but the fleet's own.
SUB TestNavyListsOfPorts
    city_name$(5) = "Boston": city_port_type(5) = PORT_SEA: city_owner(5) = SIDE_UNION
    city_name$(8) = "Norfolk": city_port_type(8) = PORT_SEA: city_owner(8) = SIDE_UNION
    city_name$(9) = "Mobile": city_port_type(9) = PORT_SEA: city_owner(9) = SIDE_REBEL
    city_name$(11) = "Memphis": city_port_type(11) = PORT_RIVER: city_owner(11) = SIDE_UNION
    fleet_city(SIDE_REBEL) = 8
    CALL navy_list_shipyards(SIDE_UNION)
    AssertEqualInt 1, menu_item_count, "one shipyard: not the enemy's port, the blockaded port or the river port"
    AssertEqualInt 5, menu_value(1), "Boston"
    AssertEqualStr "Port", menu_text$(0), "the menu's title"
    fleet_city(SIDE_UNION) = 5
    CALL navy_list_ports(SIDE_UNION)
    AssertEqualInt 2, menu_item_count, "two ports to sail to: every sea port but the fleet's own"
    AssertEqualInt 8, menu_value(1), "Norfolk"
    AssertEqualInt 9, menu_value(2), "Mobile, the enemy's"
END SUB

' random_discard uses up one random number.
SUB TestRandomDiscard
    RANDOMIZE USING 7
    a! = RND: b! = RND
    RANDOMIZE USING 7
    CALL random_discard
    AssertTrue RND = b!, "the next number is the second"
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
    game_over = 1: turn_recruit_state = -1: saves_exist = 0: event_done(3) = 1: union_income_bonus = 252
    army_size(7) = 90: army_city(7) = 12: army_order(7) = 5: army_leader_rating(7) = 4: army_name$(7) = "Banks"
    fleet_size(SIDE_REBEL) = 3: fleet_city(SIDE_REBEL) = 27: train_army(SIDE_UNION) = 7: train_city(SIDE_UNION) = 30
    side_victory_points(SIDE_UNION) = 400: victory_rule(VICTORY_MONTH) = 3
    CALL game_reset
    AssertEqualInt 0, game_over, "the game is on"
    AssertEqualInt 0, turn_recruit_state, "Troops open"
    AssertEqualInt 1, saves_exist, "Load open"
    AssertEqualInt 0, event_done(3), "no event has happened yet"
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
    AssertEqualInt -1, _FILEEXISTS("cws3.sav"), "the slot's file"

    turn_month = 0: turn_year = 0: union_income_bonus = 0: current_side = SIDE_UNION
    army_name$(22) = "": army_size(22) = 0: army_leader_rating(22) = 0: army_city(22) = 0
    army_experience(22) = 0: army_supply(22) = 0: army_order(22) = 0
    city_army(12) = 0: city_owner(12) = 0: city_fort(12) = 0
    side_cash(SIDE_REBEL) = 0: side_capital(SIDE_REBEL) = 0: side_victory_points(SIDE_UNION) = 0
    fleet_ships$(SIDE_UNION) = "": fleet_city(SIDE_UNION) = 0: fleet_size(SIDE_UNION) = 0
    train_army(SIDE_REBEL) = 0: train_city(SIDE_REBEL) = 0
    opt_difficulty = 0: opt_history = 0
    CALL load_game(3, problem$)
    AssertEqualStr "", problem$, "loaded"
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

' A saved game's first line is its scenario's folder. Loaded on that scenario, it reads the
' scenario's files no second time.
SUB TestSaveGameNamesItsScenario
    CHDIR TestTempDir$
    scenario_count = 2: scenario_folder$(1) = "standard": scenario_folder$(2) = "alternate": scenario_now = 2
    turn_month = 9
    CALL save_game(3)
    f = FREEFILE: OPEN "cws3.sav" FOR INPUT AS #f: LINE INPUT #f, text$: CLOSE #f
    AssertEqualStr CHR$(34) + "alternate" + CHR$(34), text$, "the first line"
    turn_month = 0
    CALL load_game(3, problem$)
    AssertEqualStr "", problem$, "loaded"
    AssertEqualInt 9, turn_month, "the month, after the scenario's line"
    AssertEqualInt 2, scenario_now, "still the same scenario"
END SUB

' A game saved before saves named their scenario has no such line. It loads as the first
' scenario of the list.
SUB TestSaveGameWithoutAScenarioLoads
    CHDIR TestTempDir$
    scenario_count = 1: scenario_folder$(1) = "standard": scenario_now = 1
    turn_month = 9: turn_year = 1864
    CALL save_game(3)
    ' The same file without its first line, as the game wrote it before.
    f = FREEFILE: OPEN "cws3.sav" FOR INPUT AS #f: LINE INPUT #f, text$
    g = FREEFILE: OPEN "cws4.sav" FOR OUTPUT AS #g
    DO WHILE NOT EOF(f): LINE INPUT #f, text$: PRINT #g, text$: LOOP
    CLOSE #f, #g
    turn_month = 0: turn_year = 0
    CALL load_game(4, problem$)
    AssertEqualStr "", problem$, "loaded"
    AssertEqualInt 9, turn_month, "the month"
    AssertEqualInt 1864, turn_year, "the year"
    AssertEqualInt 1, scenario_now, "the first scenario"
END SUB

' A saved game of a scenario that is not in the list is not loaded, and the game is unchanged.
SUB TestSaveGameOfAnUnknownScenario
    CHDIR TestTempDir$
    scenario_count = 1: scenario_folder$(1) = "standard": scenario_now = 1
    f = FREEFILE: OPEN "cws5.sav" FOR OUTPUT AS #f
    PRINT #f, CHR$(34) + "nowhere" + CHR$(34): PRINT #f, "3,1861,252,1"
    CLOSE #f
    turn_month = 7
    CALL load_game(5, problem$)
    AssertEqualStr "cws5.sav is a game of the scenario " + CHR$(34) + "nowhere" + CHR$(34) + ", which is not in SCENARIOS.LST", problem$, "why"
    AssertEqualInt 7, turn_month, "nothing read"
    AssertEqualInt 1, scenario_now, "the scenario stays"
END SUB

' saves_exist is 0 when no saved game is on the disk, and 1 again once a game is saved.
SUB TestSavedGamesCheck
    CHDIR TestTempDir$
    saves_exist = 1
    CALL saved_games_check
    AssertEqualInt 0, saves_exist, "no saved game"
    CALL save_game(1)
    CALL saved_games_check
    AssertEqualInt 1, saves_exist, "1 after a save"
END SUB

' any_saved_game looks at the nine slots only: another .sav file is not a saved game.
SUB TestAnySavedGameLooksAtTheSlots
    CHDIR TestTempDir$
    AssertEqualInt 0, any_saved_game, "no saved game"
    f = FREEFILE: OPEN "other.sav" FOR OUTPUT AS #f: PRINT #f, "x": CLOSE #f
    AssertEqualInt 0, any_saved_game, "a .sav file that is not a slot"
    f = FREEFILE: OPEN "cws9.sav" FOR OUTPUT AS #f: PRINT #f, "x": CLOSE #f
    AssertEqualInt -1, any_saved_game, "the last slot"
END SUB

' ------------------------------------------------------- SCRIPT.BM

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
'$INCLUDE: '../rules/events.bm'
'$INCLUDE: '../rules/turn.bm'
'$INCLUDE: '../rules/victory.bm'
'$INCLUDE: '../ai/ai.bm'
'$INCLUDE: '../commands/army.bm'
'$INCLUDE: '../commands/city.bm'
'$INCLUDE: '../commands/navy.bm'
'$INCLUDE: '../commands/railroad.bm'
'$INCLUDE: '../ui/menu.bm'
'$INCLUDE: '../ui/main_menu.bm'
'$INCLUDE: '../ui/orders.bm'
'$INCLUDE: '../ui/files.bm'
'$INCLUDE: '../ui/options.bm'
'$INCLUDE: '../ui/reports.bm'
'$INCLUDE: '../ui/screen.bm'
'$INCLUDE: '../ui/messages.bm'
'$INCLUDE: '../ui/battle.bm'
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
'$INCLUDE: '../port/files.bm'
'$INCLUDE: '../port/script.bm'
