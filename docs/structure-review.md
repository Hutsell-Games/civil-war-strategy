# Review: the structure of the game's code

Written 2026-11-13, after phase 9 of `modernize-plan.md` and phase 11's step 2. It asks whether the code is
structured the best way, and which patterns would make it easier to read and change. It started from the
nested `IF`s of `ai\ai.bm`.

Nothing here is decided. The questions for the user are at the end. What was built from it is in
`archived\structure-review-completed.md`.

## How it was measured

A scratch script (`tests\out\scratch\survey.py`, not committed) read every `.bm` file and `cws.bas`. It found
349 procedures: 313 SUBs and 36 FUNCTIONs. The counts below are from it, or from `grep`, on the working tree
of 2026-11-13. They are rough: the script reads text, not a parse tree.

## Summary

The layering is sound. Cleaning `ai\ai.bm` line by line treats symptoms. Most of its tangled conditions come
from four causes that run through the whole game. Fixing those removes more than a clean-up of one file.

## What is working

- **The folders hold.** `rules\` makes 335 assignments to shared game state; `ui\` makes 4.
- **The safety net holds.** 40 whole-game scripts, 152 unit tests and two compilers. They caught nothing wrong
  in the first clean-up of `ai\ai.bm` (below).

## The four causes

### 1. One variable carries several meanings, and every caller decodes it

| Variable | Its values | Tests at call sites |
|----------|------------|--------------------:|
| `fleet_city()` | a city; 0 for "no fleet"; 99 (`FLEET_AT_SEA`) for "at sea" | 35 |
| `army_order()` | a city; 0, -1 or -2 (`ORDER_NONE`, `ORDER_BUSY`, `ORDER_DONE`) | 45 |
| `army_city()` | a city; `> 0` also means "this army exists" | 32 |

**Fix:** a few FUNCTIONs that name each test, such as `fleet_in_port(side)`, `army_exists(i)` and
`army_has_move(i)`. The arrays stay as they are.

### 2. The menu's globals are a return channel for code that is not a menu

- `rules\` and `ai\` use `menu_value()` and `menu_text$()` 28 times.
- `ai_evaluate_move` keeps its scores in `menu_value()`.
- `ai_recruit_pick` returns its pick in `menu_choice`.

**Fix:** a SUB that makes a list fills an array its caller passes. A SUB that picks one item becomes a
FUNCTION.

### 3. Results come back through parameters

97 SUBs assign to one of their parameters: `again`, `quit`, `ordered`, `refuge`, `sailed` and others. How many
of them return exactly one value was not counted.

**Fix:** where a SUB returns one value, make it a FUNCTION. `refuge = turn_retreat_city(city, side)` reads
better than a third parameter.

### 4. Code is written twice: once for each side, and once for the player and once for the computer

- `turn_update_victory_points` (`rules\turn.bm`) is the same four lines for each side, except for one kept
  bug (`TODO.md`, the Rebels' bonus built on the Union's points).
- `menu_navy_commands` (`ui\navy.bm`) and `ai_navy_orders` (`ai\navy.bm`) are the same loop. Their Build
  checks differ slightly. Three `random_discard` calls keep the random numbers in step between them.

**Fix:** one SUB that takes `side`. For a command: one shared rule such as `navy_can_build(side)`; then the
menu or the computer chooses; then the command in `commands\` runs.

## Two findings for the second-war goal

- **City numbers are in the code.** City 30 is in `ai\navy.bm` (lines 6, 7, 98 and 100) and `draw\map.bm`
  (line 519). City 27 is in `rules\setup.bm` (line 34), and city 24 in `draw\map.bm` (line 148). These fail
  phase 11's test that a second war replaces only `game\` and `scenarios\`.
- **The folder rules are kept only by convention.** Phase 8's script that found the mixed SUBs
  (`p8_mixed.py`) was never committed. A small test that fails when `rules\` or `ai\` calls into `ui\` or
  `draw\` would keep the rule.

## The panel

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

## Recommendation

In this order, each a commit that keeps the recorded screens identical:

1. The layer check, as a test.
2. The state predicates (cause 1).
3. SUBs that return one value become FUNCTIONs (cause 3).
4. The menu's globals out of `rules\` and `ai\` (cause 2).
5. The identical halves for each side become one SUB (cause 4, first part).
6. The city numbers move into the scenario's data.

The earlier plan for `ai\ai.bm` alone was four steps. Its step 1 is done (`archived\structure-review-completed.md`). Its steps 2 to 4
(`SELECT CASE` and `_ANDALSO` for nested `IF`s, named predicates, splitting `ai_evaluate_move`) are dropped
as separate work: the predicates and FUNCTIONs above cover most of them. The split of `ai_evaluate_move`
was done on 2026-11-14 (the third review, below).

## The second review: one idea written in several places

Written 2026-11-13, after the merges of the literal copies (`army_clear`, `load_scenario_armies`,
`battle_size_rate!`, `save_file_name$`, `side_color_of`). It looked for a rule or a fact that the code
states in several places in different words. Read in full: `ai\`, `rules\`, `commands\`, and in `ui\`
the orders, navy, army, turn, battle, menu, report and option menus. Skimmed: `draw\map.bm`,
`draw\ships.bm`, `draw\pictures.bm`, `game\`, and `ui\screen.bm`, `files.bm`, `victory.bm` and
`events.bm`.

The user took the pragmatic engineer's plan ("do as recommended", 2026-11-13). Items 4 and 9 and
the small items below were left out.

### Left out, and why

- **The two halves of `battle_strengths`** share three steps. It is one SUB read top to bottom, in the
  order of the right panel; helpers would make one battle harder to follow and risk its rounding.
- **The sea ports of a side** (`navy_list_shipyards`, `event_delivery_port`, `navy_retreat_port`): their
  tests differ in three ways, so one FUNCTION would need a parameter for each.
- **Small repeats**: the menus' lists in `ui\army.bm` and `ui\city.bm`, the three ways of shortening an army's name,
  the two-row menus, the road loops' three ways of stopping, the cannon's sound and the `"00"` texts.
  Each is done when its SUB is next changed for another reason.

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

## The third review: the size of files and procedures

Written 2026-11-14. It asked whether procedures should be broken up or filed elsewhere. Of 388
procedures, 276 are 25 lines or fewer and 11 are over 100. The user took its order ("do file
splits", then "continue", 2026-11-14). What is done is in `archived\structure-review-completed.md`.

Still to do, each a commit that keeps every screen:

1. **`menu_select`** (`ui\menu.bm`, 131 lines): the checks of the start row, and the loop that
   reads a key.
2. **`calculate_battle`** (`ui\battle.bm`, 179 lines): the panel of strengths, the result, the
   history line. Its `menu_text$(1)` to `(4)` are scratch strings that locals would replace.
3. **`menu_city_select`** (`ui\city.bm`, nesting 6 deep): three loops that step to the side's next
   city become one FUNCTION.
4. **`load_events`** (`port\events_file.bm`, 123 lines): the checks after the file is read.
5. **The fort command.** `ai_fortify` calls `draw_fort_built` (`ui\city.bm`), the one exception of
   `tests\test_layers.py`. A command `city_fortify` in `commands\city.bm` would remove it.
6. **The computer's enemy as a parameter.** `ai_evaluate_move`, `ai_railroad_city` and
   `city_nearby_enemy_strength` read the enemy from `current_side`; the other `ai_*` take `side`.

Left alone: `battle_strengths` (above), `menu_utility`, `report_armies` and `end_game`, which are
long but read top to bottom, and the four pictures drawn line by line (`draw_map`, `draw_schooner`,
`draw_ironclad`, `draw_surrender`).

## Questions for the user

1. **The order above:** go ahead with it, or keep to the `ai\ai.bm` steps?
