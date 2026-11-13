# Review: the structure of the game's code

Written 2026-11-13, after phase 9 of `modernize-plan.md` and phase 11's step 2. It asks whether the code is
structured the best way, and which patterns would make it easier to read and change. It started from the
nested `IF`s of `ai\ai.bm`.

Nothing here is decided. The questions for the user are at the end.

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
- `menu_navy_commands` (`ui\navy.bm`) and `ai_navy_orders` (`ai\ai.bm`) are the same loop. Their Build
  checks differ slightly. Three `random_discard` calls keep the random numbers in step between them.

**Fix:** one SUB that takes `side`. For a command: one shared rule such as `navy_can_build(side)`; then the
menu or the computer chooses; then the command in `commands\` runs.

## Two findings for the second-war goal

- **City numbers are in the code.** City 30 is in `ai\ai.bm` (lines 127, 128 and 546) and `draw\map.bm`
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
- **Rust engineer:** Do not reopen records. The ruling of 2026-11-12 (`modernize-plan.md`, "Phase 10:
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

The earlier plan for `ai\ai.bm` alone was four steps. Its step 1 (below) is done. Its steps 2 to 4
(`SELECT CASE` and `_ANDALSO` for nested `IF`s, named predicates, splitting `ai_evaluate_move`) are dropped
as separate work: the predicates and FUNCTIONs above cover most of them. The split of `ai_evaluate_move`
can follow item 4, once its scores no longer live in `menu_value()`.

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

## Questions for the user

1. **The order above:** go ahead with it, or keep to the `ai\ai.bm` steps?
2. **The kept bugs:** rule on `TODO.md`'s "The game" rows in one batch now, or leave them until after
   this work? The merge of the player's and the computer's commands waits on that.
