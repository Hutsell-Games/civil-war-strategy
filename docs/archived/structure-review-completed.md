# Done: the review of the structure of the game's code

The finished parts and original findings of `../structure-review.md`, archived from 2026-11-13
onward. The active review keeps the remaining work and deliberately deferred items. Original
findings, decisions and the second review's shared-rule results were moved here on 2026-11-14.

## The first review: findings and recommendation

Written 2026-11-13, after phase 9 of `modernize-plan.md` and phase 11's step 2. It asks whether the code is
structured the best way, and which patterns would make it easier to read and change. It started from the
nested `IF`s of `ai\ai.bm`.

Original findings and recommendation, retained as the record of the first review. Items 1 to 5
were completed below; the city numbers remain in the active review. Counts describe the tree
on the date of the review.

### How it was measured

A scratch script (`tests\out\scratch\survey.py`, not committed) read every `.bm` file and `cws.bas`. It found
349 procedures: 313 SUBs and 36 FUNCTIONs. The counts below are from it, or from `grep`, on the working tree
of 2026-11-13. They are rough: the script reads text, not a parse tree.

### Summary

The layering is sound. Cleaning `ai\ai.bm` line by line treats symptoms. Most of its tangled conditions come
from four causes that run through the whole game. Fixing those removes more than a clean-up of one file.

### What is working

- **The folders hold.** `rules\` makes 335 assignments to shared game state; `ui\` makes 4.
- **The safety net holds.** 40 whole-game scripts, 152 unit tests and two compilers. They caught nothing wrong
  in the first clean-up of `ai\ai.bm` (below).

### The four causes

#### 1. One variable carries several meanings, and every caller decodes it

| Variable | Its values | Tests at call sites |
|----------|------------|--------------------:|
| `fleet_city()` | a city; 0 for "no fleet"; 99 (`FLEET_AT_SEA`) for "at sea" | 35 |
| `army_order()` | a city; 0, -1 or -2 (`ORDER_NONE`, `ORDER_BUSY`, `ORDER_DONE`) | 45 |
| `army_city()` | a city; `> 0` also means "this army exists" | 32 |

**Fix:** a few FUNCTIONs that name each test, such as `fleet_in_port(side)`, `army_exists(i)` and
`army_has_move(i)`. The arrays stay as they are.

#### 2. The menu's globals are a return channel for code that is not a menu

- `rules\` and `ai\` use `menu_value()` and `menu_text$()` 28 times.
- `ai_evaluate_move` keeps its scores in `menu_value()`.
- `ai_recruit_pick` returns its pick in `menu_choice`.

**Fix:** a SUB that makes a list fills an array its caller passes. A SUB that picks one item becomes a
FUNCTION.

#### 3. Results come back through parameters

97 SUBs assign to one of their parameters: `again`, `quit`, `ordered`, `refuge`, `sailed` and others. How many
of them return exactly one value was not counted.

**Fix:** where a SUB returns one value, make it a FUNCTION. `refuge = turn_retreat_city(city, side)` reads
better than a third parameter.

#### 4. Code is written twice: once for each side, and once for the player and once for the computer

- `turn_update_victory_points` (`rules\turn.bm`) is the same four lines for each side, except for one kept
  bug (`TODO.md`, the Rebels' bonus built on the Union's points).
- `menu_navy_commands` (`ui\navy.bm`) and `ai_navy_orders` (`ai\navy.bm`) are the same loop. Their Build
  checks differ slightly. Three `random_discard` calls keep the random numbers in step between them.

**Fix:** one SUB that takes `side`. For a command: one shared rule such as `navy_can_build(side)`; then the
menu or the computer chooses; then the command in `commands\` runs.

### Two findings for the second-war goal

- **City numbers are in the code.** City 30 is in `ai\navy.bm` (lines 6, 7, 98 and 100) and `draw\map.bm`
  (line 519). City 27 is in `rules\setup.bm` (line 34), and city 24 in `draw\map.bm` (line 148). These fail
  phase 11's test that a second war replaces only `game\` and `scenarios\`.
- **The folder rules are kept only by convention.** Phase 8's script that found the mixed SUBs
  (`p8_mixed.py`) was never committed. A small test that fails when `rules\` or `ai\` calls into `ui\` or
  `draw\` would keep the rule.

### The panel

- **Pragmatic engineer:** Do causes 1 and 3 first. They are mechanical, keep the screens identical, and
  shorten conditions in every file.
- **QB64 engineer:** Cause 2 is safe as long as the arrays are passed in the same order and no `RND` moves.
  Both compilers pass arrays by reference.
- **Compiler/languages engineer:** This is evidence for phase 11's step 5, the list of what QB64 made
  awkward. Three things stand out: a FUNCTION returns one value, there is no `ENUM` (`cws.bi` has 179 `CONST`
  lines, in groups), and there are no modules (126 shared names, all global).
- **Rust engineer:** Do not reopen records. The ruling of 2026-11-12 (`archived\modernize-plan-completed.md`, "Phase 10:
  records") still fits: the predicates of cause 1 give most of the readability without them.
- **Test engineer:** Commit the layer check first. Add a unit test for each new predicate.
- **Game-AI engineer** (added because the computer's move scoring is a utility AI): The merge of the
  player's and the computer's commands in cause 4 changes the random draws, so it cannot keep the screens
  identical. It belongs after the kept bugs are ruled on.

### Recommendation

In this order, each a commit that keeps the recorded screens identical:

1. The layer check, as a test.
2. The state predicates (cause 1).
3. SUBs that return one value become FUNCTIONs (cause 3).
4. The menu's globals out of `rules\` and `ai\` (cause 2).
5. The identical halves for each side become one SUB (cause 4, first part).
6. The city numbers move into the scenario's data.

## Already done

**Step 1 of the `ai\ai.bm` plan**, in the working tree on 2026-11-13, not committed. Six procedures read
names in place of repeated lookups. In `ai_evaluate_move`, `city_nearby_enemy_strength` and `ai_railroad`,
`current_side` is the player, so the local `enemy_side` says so. `own_side` replaces
`other_side(current_side)`. `ai_pick_port` gets `enemy_side` for `other_side(side)`. The 40 scripts
passed `play.py check` and `play.py compare` on unchanged recordings, and the 152 unit tests passed.

Two of step 1's names were taken back after item 2 (user, 2026-11-13). `army_troops` in
`ai_evaluate_move` only renamed `army_size(army)`, made the odds lines lopsided beside
`army_size(occupant)`, and shared its name with `ai_army_order`'s local of another use. `port` and
`port_owner` in `ai_fleet_orders` and `ai_navy_attack` hid two tests of `fleet_city()` from item 2's
rewrite; those now read `fleet_is_at_sea(side)` and `NOT fleet_exists(side)`. With `own_side` in place,
`ai_evaluate_move`'s `enemy_bound` read wrong: its loop walks the computer's own armies, so it is
`ally_bound` now. Step 1 also brought out a kept bug, the test for crossing moves (`TODO.md`).

**Item 1 of the recommendation, the layer check**, in the working tree on 2026-11-13, not committed.
`tests\test_layers.py` reads the source and fails when `rules\` or `ai\` uses the screen, the speaker or
the keyboard, when `rules\` calls into `ui\`, `draw\`, `game\` or `commands\`, when `ai\` calls into them
other than `ui\ai.bm` and `commands\`, or when `commands\` opens a menu or reads a key. It runs with the
other Python tests. Five calls break a rule today and are listed in its `ALLOWED`, each with its reason:

- `army_list_combine_cities` and `army_recruit_cities` (`rules\army.bm`) call `menu_bubble_sort`
  (`ui\menu.bm`), which sorts the menu's arrays and draws nothing (cause 2).
- `ai_navy_adjust` calls `menu_navy_items` (`ui\orders.bm`), which fills the Ships menu's texts (cause 2).
- `ai_recruit` calls `menu_recruit_cities` (`ui\orders.bm`), which sets the `COLOR` that `draw_ai_funds`
  prints in.
- `ai_fortify` calls `draw_fort_built` (`ui\orders.bm`), the fort's message shared with the player's
  Fortify.

A row whose call is gone fails the test too, so the list cannot go stale.

**Item 2, the state predicates**, in the working tree on 2026-11-13, not committed. Five FUNCTIONs name
what the arrays hold. Each gives -1 or 0, as the comparison it replaces, so `AND` and `OR` work as before:

| FUNCTION | File | Replaces |
|----------|------|----------|
| `army_exists(army)` | `rules\army.bm` | `army_city() > 0`; with `NOT`, `= 0` and `< 1` |
| `army_has_move(army)` | `rules\army.bm` | `army_order() > 0`; with `NOT`, `< 1` |
| `army_has_acted(army)` | `rules\army.bm` | `army_order() < 0`; with `NOT`, `> -1` |
| `fleet_exists(side)` | `rules\navy.bm` | `fleet_city() > 0`; with `NOT`, `= 0`, `< 1` and `<= 0` |
| `fleet_is_at_sea(side)` | `rules\navy.bm` | `= FLEET_AT_SEA`; with `NOT`, `<> FLEET_AT_SEA`, `< 41` and `<= MAX_CITIES` |

A script rewrote 70 comparisons on 64 lines in 14 files, and one more by hand in `ui\reports.bm`. It left
assignments alone, such as `fleet_city(side) = 0`. It also left the tests of city numbers (30, 27, 24),
which are item 6. The rewrite is the same only while neither array is negative. Nothing sets a negative
value: the train sets `army_city()` from an order that is a city. Both compilers read `NOT f(x) AND y` as
`(NOT f(x)) AND y` (checked with a small program). Every changed line runs under the tests
(`play.py coverage`). `TestArmyStateByName` and `TestFleetStateByName` in `tests\rules_test.bas` pin the
values. The 40 scripts passed `check` and `compare` on unchanged recordings, and the 154 unit tests
passed.

For phase 11's list of what QB64 made awkward: the FUNCTION was first named `fleet_at_sea`, and neither
compiler accepted it. Names ignore case, so it is the same name as the constant `FLEET_AT_SEA`.

**Item 5, one SUB for both sides**, in the working tree on 2026-11-13, not committed.
`turn_update_victory_points (side)` (`rules\turn.bm`) does one side's month; `turn_resolve` (`ui\turn.bm`)
and the unit test call it for the Union, then the Rebels. The two halves differed in one line: only the
Union's points stop at 0. That line is kept behind `side = SIDE_UNION`, and `TODO.md` has a row for it.
A new unit test, `TestOnlyUnionVictoryPointsStopAtZero`, pins it and the strength ratio. The 40 scripts
passed `check` and `compare` on unchanged recordings, and the 158 unit tests passed.

**Item 3, SUBs that return one value**, in the working tree on 2026-11-13, not committed. 76 SUBs assign
to a parameter, and 55 to exactly one. Four became FUNCTIONs: `ai_fortify_pick (side)`,
`normal_random_number (mean, variance)`, `turn_retreat_city (city, attacker_side)` and
`text_replace$ (text$, find$, with$)`. Each only picks, draws a number or builds a text.
The others stay SUBs, for these reasons:

- Most change the game as their main work (buy supply, bombard, move a fleet, set an order) and return
  only a flag such as `again`, `raised` or `sailed`. A FUNCTION would hide that work.
- The menus draw and read keys.
- `ai_navy` leaves `action` as it was when no rule applies, so it is an input too.
- `victory_rule_met` also gives 300 victory points, and `army_pick_commander` also writes a made-up name.
- `ai_evaluate_move` keeps its scores in `menu_value()`, so it waits for item 4.

`TestTextReplaceEveryPlace` is new. The 40 scripts passed `check` and `compare` on unchanged
recordings, and the 159 unit tests passed.

**Item 4, the menu's globals out of `rules\` and `ai\`**, in the working tree on 2026-11-13, not
committed. Neither folder names a menu variable any more, and `tests\test_layers.py` checks it
(`test_rules_and_ai_leave_the_menu_alone`). Four rows of its `ALLOWED` are gone; `ai_fortify`'s call
of `draw_fort_built` is the one left.

- **Lists.** `army_list_combine_cities`, `army_recruit_cities`, `navy_list_shipyards` and
  `navy_list_ports` fill an array the caller passes, with a count. `city_list_sort` (`rules\city.bm`)
  sorts by name as `menu_bubble_sort` did, so the lists keep their order. The player's menus copy a
  list into the menu with `menu_set_cities` (`ui\menu.bm`), and set the menu's place and colors
  that the rules set before.
- **Picks.** `ai_recruit_pick` and `ai_pick_port` are FUNCTIONs that give a city. `ai_navy_orders`
  chooses by its `action`, not `menu_choice`. `ai_army_order` lost a line that never ran.
- **Scores.** `ai_evaluate_move` keeps its scores in a local `road_score()`.
- **Invasion.** `navy_can_invade` (`rules\navy.bm`) is the test that the Ships menu and
  `ai_navy_adjust` share. The computer filled the Ships menu to read its row count.
- **The computer's screen.** `draw_ai_funds` takes the list's count. `draw_ai_recruit_color`
  (`ui\ai.bm`) sets the color the player's list set for the computer before.

What the computer left in the menu's variables could change no screen. The menus that open in its
turn, Retreat and End Game, set their own place and colors. The values it left in `menu_choice` give
row 1, as the player's End Turn does. One read was a bug: `ai_pick_port` set the row to 30, and
`menu_value(30)` was always 0, so the fleet stayed in port. It returns 0 now (`TODO.md`). The 40
scripts passed `check` and `compare` on unchanged recordings, the 161 unit tests passed, and every
changed line runs under the tests.

## The second review: one idea written in several places

Written 2026-11-13, after the merges of the literal copies (`army_clear`, `load_scenario_armies`,
`battle_size_rate!`, `save_file_name$`, `side_color_of`). It looked for a rule or a fact that the code
states in several places in different words. Read in full: `ai\`, `rules\`, `commands\`, and in `ui\`
the orders, navy, army, turn, battle, menu, report and option menus. Skimmed: `draw\map.bm`,
`draw\ships.bm`, `draw\pictures.bm`, `game\`, and `ui\screen.bm`, `files.bm`, `victory.bm` and
`events.bm`.

The user took the pragmatic engineer's plan ("do as recommended", 2026-11-13). Items 4 and 9 and
the small repeats were left out; their reasons remain in the active review under
"Deliberately deferred from the second review".

### The rules that the player's menus and the computer each checked

This is cause 4's second part. Each rule is now one FUNCTION in `rules\`, called by the menu's "-"
row, by the menu's action and by `ai\`: `army_can_drill`, `capital_can_move`, `fort_affordable`,
`side_can_detach`, `winter_stops_move`, `navy_can_build`, `navy_can_attack`, `navy_can_raid`, and
`side_strength` with `army_in_field`. `ai_fortify` builds through `city_build_fort`.

Where the copies differed, the user ruled (2026-11-13):

1. **Build: one rule for both**, the player's. The computer now needs a sea port of its own too.
2. **Attack: keep the difference.** Only the test is shared. The computer's Attack still turns to Sail
   off a neutral city: that is its choice, not a rule.
3. **Winter: January and February for both** (`turn_month < 3`), as the option's text says.
4. **Strength: the army on a train counts** everywhere. The rounding of each sum is kept.
   `ai_count_armies` still counts only the armies that hold a city as its armies.

`turn_check_commands` keeps its own test: it closes Ships for a side with no fleet and not the price
of a ship, which is not the Build rule. The 40 scripts passed `check` and `compare` on unchanged
recordings: none reached a case where the copies differed. 175 unit tests passed, 5 of them new
for these rules. `TestTurnStrengthRatio` now gives its two armies a city, as every army in a game has.

| Rule | Checked in, before | How the copies differed |
|------|------------|-----------------------|
| Can drill | `ai_drill`, `menu_army_drill` | not at all |
| The capital can move | `menu_commands`, `menu_move_capital` | not at all |
| A fort is affordable | `menu_commands` (twice), `menu_city_fortify`; `ai_fortify` adds the fort without `city_build_fort` | not at all |
| Detach is the Rebels' only | `menu_commands`, `menu_army_detach` | not at all |
| Winter stops a move into a city not the side's | `ai_army_order` (`turn_month = 1`), `menu_army_move` (`turn_month < 3`) | only in a scenario that starts in an even month |
| A ship can be built | the Ships menu's row, `menu_navy_build`, `ai_navy_build`, `ai_navy_adjust`, `ai_fleet_orders`, `turn_check_commands` | only the player's Build asks for a sea port, and the computer's does not test the port's owner |
| Attack and Raid | the Ships menu's rows, the player's and the computer's action | the computer's Attack also sails off a neutral city |
| A side's strength | `turn_strength_ratio`, `ai_count_armies`, `victory_forces` | only the first counts the army on a train; two of them add tenths, rounded at each step |

### Done, keeping every screen

In the working tree on 2026-11-13, not committed. Each part passed the unit tests and the 40 scripts'
`check` on unchanged recordings.

1. **The Balance setting's help for the computer.** `balance_help (side)` (`rules\setup.bm`) is how
   many steps the setting helps the computer's side. The extra recruits are 5 times it, the attack and
   the defense in battle 2 times it, and the starting cash 100 times 3 more than it. The four places
   wrote the same test and formula each in its own way. `TestBalanceHelpGoesToTheComputer` pins it.
2. **A slot takes a free leader.** `army_appoint (army, leader)` (`rules\army.bm`) replaces the same
   three lines in `army_raise`, `army_detach`, `event_new_army` and `load_scenario_armies`, and in
   `army_take_leader`. `army_combine_absorb` calls `army_free_leader`. `TestArmyAppointAndFreeLeader`.
3. **The other two side palettes.** `side_bright_color` (light blue and white: the trains, the army
   report's heading, the computer's turn) and `side_panel_color` (blue and gray: the player's turn,
   victory, surrender), in `game\colors.bm`. They replace 7 places that wrote the numbers.
4. **The ship letters.** `SHIP_WOODEN$` and `SHIP_IRONCLAD$` (`cws.bi`), `ship_cost` (`rules\navy.bm`)
   and `ship_icon` (`draw\ships.bm`). The tests keep the letters as data. `TestShipKinds`.
5. **The fleet is gone.** `navy_clear_fleet` (`rules\navy.bm`) clears the ships, their count and the
   port, for `navy_remove_ship`, `navy_fleet_lost`, `navy_fleet_defeated` and `ai_fleet_orders`. No
   place left the count and the list disagreeing. `navy_cancel_new_fleet` keeps `fleet_city()` on
   purpose: `ai_fleet_orders` sets city 30 for the computer's first Union ship before it is built, and
   `ai_raise_forces` reads it after. `TestNavyClearFleet`.
6. **The flag's place beside a city.** `flag_x`, `flag_y`, `draw_erase_flag`, `flag_picture_save` and
   `flag_picture_restore` (`draw\icons.bm`) replace six places that worked it out. Two were in
   `commands\` (`army_recruit`, `railroad_arrive`), which no longer draw pixels themselves.

## The third review: the size of files and procedures

### Done, keeping every screen

1. **Three files split by topic** (`tools\refactor\split_files.py`, commit `1f3e52a`). `ai\ai.bm`
   became `ai\army.bm`, `ai\forces.bm`, `ai\navy.bm` and `ai\railroad.bm`. `ui\orders.bm` keeps
   only `menu_commands`; its other menus went to `ui\army.bm`, `ui\navy.bm` and the new
   `ui\city.bm` and `ui\railroad.bm`. The events file's reader left `port\files.bm` for
   `port\events_file.bm`. All 388 procedures moved byte for byte.
2. **`ai_evaluate_move` in parts** (`ai\army.bm`, 209 lines to 92). `ai_stay_weight`,
   `ai_move_strength`, `ai_city_targeted`, `ai_attack_score` and `ai_beyond_score` are called
   where their lines were, so the four `RND` draws keep their order. The unused `score = 1` in the
   loop that summed the strength went. Found on the way: the bonus for the enemy's capital
   compares an owner with a city (`TODO.md`, "The game").
3. **`ai_railroad` in two** (`ai\railroad.bm`): `ai_railroad_army` picks the army and
   `ai_railroad_city` the city.

Six unit tests are new: `TestAiStayWeight`, `TestAiMoveStrength`, `TestAiCityTargeted`,
`TestAiAttackScore`, `TestAiBeyondScore` and `TestAiRailroadArmyAndCity`.

4. **`menu_select` in parts** (`ui\menu.bm`, 145 lines to 93). `menu_place` puts the box,
   `menu_start_row` works out the first row, `menu_wait_key$` waits for a key,
   `menu_letter_row` finds the row of a letter, and `menu_show_selected` and `menu_show_plain`
   draw a row highlighted and plain. A test `IF menu_width = 0` that was always true went.
   `TestMenuStartRow`, `TestMenuLetterRow` and `TestMenuPlace` are new.
5. **`calculate_battle` in parts** (`ui\battle.bm`, 179 lines to 33). `draw_battle_attacker`
   and `draw_battle_defender` draw the two halves of the panel, `draw_battle_odds` the odds,
   `draw_battle_fort` the fort, `draw_battle_winner` the winner and `draw_battle_losses` the
   losses; `battle_cannon_sound` plays the rounds. `battle_history_line$` builds the history's
   line in locals, so `menu_text$(1)` to `(4)` are no longer its scratch strings.
   `TestBattleOddsText` and `TestBattleHistoryLine` are new.

## Questions for the user

2. **The kept bugs:** rule on `TODO.md`'s "The game" rows in one batch now, or leave them until after
   this work? The merge of the player's and the computer's commands waits on that. Answered 2026-11-13
   (user): now. All but three are fixed (`TODO.md`, "The game").
