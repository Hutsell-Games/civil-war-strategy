# Plan: modernize the code of Civil War Strategy

Started 2026-11-11. This is the high-level plan. Each phase gets its details when it is next, in its own
section below.

## Goal

Make the code clean enough for future work, without changing how the game plays or looks. The same engine is
meant to carry other wars later (the Revolutionary War, the War of 1812, the Mexican-American War, the
Napoleonic Wars), so the clean code keeps the war's own content apart from the rest.

Where it starts: branch `qb64rust` at commit `8c3b185`. The game is 5,270 lines in `CWSTRAT.BAS`,
`CWSTRAT1.BM`, `CWSTRAT2.BM`, `CWSMENU.BM` and `CWS14.BI`. It has 361 lines with `GOTO` or `GOSUB`, about 60
shared arrays, no `TYPE` and no `CONST`. `CWSTRAT.BAS` (745 lines) has no SUB of its own.

## Decisions (user, 2026-11-11)

1. **End point: clean and ready for an engine split.** This plan cleans Civil War Strategy only. It gathers
   the war's own content (side names, the map drawing, the victory screens, the tunes, the event texts) in
   its own files. Splitting the engine from the game is a second plan.
2. **Language: QB64, built by both compilers.** The code may use `TYPE`, `CONST`, `FUNCTION`,
   `OPTION _EXPLICIT` and long names. It uses nothing that only QB64Rust accepts, so QB64pe stays a second
   check. The code no longer needs to build in DOS; that source stays on `canonical-source`.
3. **Every step keeps the recorded screens identical.** `python tests\play.py check` must pass with no
   script recorded again. That holds the order of the random numbers and every pixel. The known bugs
   (`TODO.md`, "The game", and the list at the end of `sub-names.md`) are kept. Each is fixed later as its
   own decision with its own new recording.
4. **Tests first.** Phase 0 measures which lines the scripts and unit tests reach and fills the gaps before
   those parts are changed.
5. **Start fresh from `qb64rust`.** Branch `extract-graphics` is read for what worked (its file split, its
   rename script), but nothing is merged from it. It mixed a bug fix with renames and moves.
6. **Data: rename first, records later.** The shared arrays and scalars are renamed first
   (`armysize` to `army_size`). A later phase groups them into records (`armies(i).size`,
   `cities(i).owner`, `sides(s).cash`). The saved-game file keeps its format.
7. **Rule SUBs do no input or output.** At the end a rule SUB draws nothing, prints nothing and reads no
   key, so `tests\rules_test.bas` can call every one. A SUB that mixes rules and screen (`battle`, `navy`,
   `tupdate`) becomes a rule part and a show part, called in the same order as today.
8. **`GOTO` and `GOSUB`: removed where they block a split.** Each `GOSUB` routine becomes a SUB or a
   FUNCTION. A `GOTO` is replaced when its SUB is broken up or when it jumps between menu cases. A short
   local `GOTO` in a clear SUB may stay.
9. **Order: names before structure.** See "Phases".
10. **Files: folders by layer.** See "File layout at the end".
11. **Variables.** Every shared variable and every SUB parameter gets a snake_case name. `OPTION _EXPLICIT`
    is turned on, so every local is declared with its type. A local is renamed only when its SUB is
    reworked. Loop counters `i`, `j`, `k` stay.
12. **SUB names: the "Settled names" table of `sub-names.md` is final.** One exception: a SUB that becomes a
    FUNCTION may get a name that reads as a value. Those names are listed for the user in phase 5.

13. **Coverage bar for phase 0.** Every line of the SUBs that phases 7 to 9 restructure is run by a test:
    the main module, `navy`, `tupdate`, `smarts`, `events`, `battle`, `railroad`, `filer`, `report` and
    `menu`. A line that no test can reach is listed with the reason. SUBs that are only renamed or moved
    need no more coverage.
14. **A test hook forces a special event.** Under a script only, an environment variable picks the event,
    as `CWS_SEED` picks the seed today. One script for each event records its screen. The hook must not use
    or skip a random number in a normal game.
15. **One commit for each step that can be reviewed alone.** A phase is several steps: one SUB broken up,
    one group of renames. After each step Claude runs the scripts with both compilers and hands over a
    commit message. The user stages and commits.
16. **The rename and move scripts are kept in `tools\refactor\`**, with the tables they read. The rename
    script works on tokens, so it leaves strings and comments alone. Another port can reuse them: Wars of
    Napoleon has 55 SUBs with the same old names.

17. **Shared variables: the subject first, in snake_case**, as in the SUB names: `army_size()`,
    `army_city()`, `city_owner()`, `city_value()`, `side_cash()`, `fleet_city()`. Each name then maps onto
    a record field of phase 10 (`armies(i).size`).
18. **Constants: upper case with a group prefix**: `MAX_CITIES`, `ARMIES_PER_SIDE`, `SIDE_UNION`,
    `SIDE_REBEL`, `MARK_MOVE_LINE`, `MENU_MAIN`.
19. **Phase 11 moves three kinds of content out of code into data files**, where the screens stay
    identical: the texts and names (side names, month names, event texts, default army names); the limits
    and rule numbers (40 cities, 20 armies a side, the start year, prices, the dates when ironclads and
    events start); and the map's line work (`usa`, `chessie` and `touchup`, about 400 `LINE` and `DRAW`
    statements, read by a small drawer). The limits and numbers become constants in `game\` first.

20. **Phase 3 does all nine groups of `constants.md`**, each group as its own commit. The other side and an
    army's side become two FUNCTIONs, `other_side(side)` and `army_side(army)`. The 16 colors are named and
    used in `COLOR` statements and the menu's color variables; the pictures keep their numbers.
21. **Variable names settled so far** (`variable-names.md`): `armylead()` becomes `army_leader_rating()`,
    and `size` becomes `menu_item_count`. The shared `side` becomes `current_side`, so that the parameter
    `who` can become `side`. `matrix()` is split into `city_road()` and `city_is_port()`. `navymove()` is
    dropped in phase 7.

## Phases

Every phase ends with all scripts passing on unchanged recordings, with both compilers
(`play.py check` and `play.py compare`), and with the unit tests passing.

| # | Phase | What it does |
|---|-------|--------------|
| 0 | Coverage | Measure the lines the tests reach on `8c3b185`. Add scripts or unit tests for what they miss. |
| 1 | Delete dead code | `burn`, `scrnsavr` and the Ctrl+B key, the unreached label `topbar:`, the box that `menu` draws twice, unused `DECLARE` lines. |
| 2 | Rename SUBs | The settled table, by script. |
| 3 | Constants | `CONST` names for `icon`'s kinds, `menu`'s switches, the sides, 40 cities, 20 armies a side, colors. |
| 4 | Rename variables | Shared variables and parameters, by script from a reviewed table. Then `OPTION _EXPLICIT` and declared locals. |
| 5 | FUNCTIONs | A SUB that only returns a value through a parameter becomes a FUNCTION (`cutoff`, `void`, `starfin`, `mxw`, `traincapacity`, `commander`). |
| 6 | Move SUBs into files | The layout below. SUBs move whole; no line inside one changes. |
| 7 | Break up the big pieces | `filer`, `report`, the main module, `navy`, `tupdate`, `smarts`, `events`. `GOSUB` routines become SUBs. The list is "Worth breaking out" in `sub-names.md`. |
| 8 | Split rules from screen | Each mixed SUB becomes a rule part and a show part. `rules_test.bas` grows with each rule SUB. |
| 9 | Menus | One menu SUB for each command. It asks the player, then calls a rule SUB. The main module becomes a loop. |
| 10 | Records | `TYPE` records for armies, cities, sides and fleets. |
| 11 | The war's own content | Move what another war would replace into `game\`: flags, victory screens, tunes. Move texts, names, limits and the map's line work into data files (decision 19). |

After the plan, each as its own decision: the known bugs, and the engine split.

## Which model does which phase

Decided 2026-11-11: work starts with Sonnet. The scripts are the safety net (25 whole-game scripts on
unchanged recordings, two compilers), so a mistake shows as a failed script. But a script passes on what it
reaches, so the harder the phase, the more it matters that the model reads the code well.

| Phase | Model | Why |
|-------|-------|-----|
| 1 Delete dead code | Sonnet | Small, listed deletions. |
| 2 Rename SUBs | Sonnet | A script run from a settled table. |
| 4 Rename variables | Sonnet | A script from a table. If scope cases or `OPTION _EXPLICIT` errors stall it, Opus. |
| 6 Move SUBs into files | Sonnet | Whole SUBs move; no line changes. |
| 0 Coverage | Opus | Prepared saves and scripts that reach one rare branch each need the game's rules understood. |
| 3 Constants | Opus | Each number is read in place: is this `40` cities, armies or 4,000 men? |
| 5 FUNCTIONs | Opus | Call sites pass results by reference. |
| 10 Records | Opus | Wide but regular. |
| 7 Break up the big SUBs | Fable | Untangling the `GOTO` knots in `navy`, `tupdate` and the main module. |
| 8 Split rules from screen | Fable | Every `RND` draw and every pixel must stay in order. |
| 9 Menus | Fable | The main module's `GOTO menu0` web becomes a loop. |
| 11 Map lines into data | Fable | `DRAW` and `PAINT` depend on order; expect several tries. |

**Phase order is not model order.** Phase 0 (Opus) comes before phase 2 in the plan, but phase 0's first
step is phase 1's deletions, which Sonnet can do. Work in this order with Sonnet: phase 1, then phases 2
and 4's scripts, then 6. **When the next step is one marked Opus or Fable, stop and tell the user to switch
model** before starting it. Do not carry on with a weaker model because it is nearly the same size of step.

A step handed to Sonnet names its plan section and the table it works from, and the hand-over shows the
output of `play.py check` and `play.py compare` (decision 15).

## Where to resume

Updated 2026-11-11. Phases 0 to 7 are done and committed. Phase 8's steps 1 and 2 are committed
(`6eda547`, `013b8d0`). What each step did is in `modernize-completed.md`.

Step 3 is committed in two parts (`70692b3`, `77ee9a6`), step 4 as `9e038a4` and step 5 as
`b67f89e`. Step 6, the computer's turn, is done in the working tree.

**Next:** step 7, `special_events` and `event_riot`.

Tools for reading the code are in the ignored folder `tests\out\scratch\` (`show_gaps.py`,
`var_uses.py`, `count_numbers.py`). They are not committed.

## File layout at the end

```
cws.bas              the main loop only
cws.bi               types, constants, shared variables
rules\               army.bm city.bm battle.bm navy.bm railroad.bm setup.bm turn.bm victory.bm
ai\                  ai.bm
ui\                  menu.bm orders.bm reports.bm screen.bm messages.bm
draw\                map.bm icons.bm ships.bm pictures.bm
game\                the Civil War's map, flags, victory screens, tunes, event texts, side names
port\                qb64.bm script.bm
```

The folder states the rule its files keep: nothing in `rules\` or `ai\` draws, prints or reads a key, and
`game\` is what another war replaces. The file names inside each folder are settled in phase 6.

## Open questions

Asked as the plan goes down a level:

None at present.

## Lines that no test runs

Phase 0 measured the coverage and added the scripts (`modernize-completed.md`, "Phase 0: coverage").
Phase 7's rule for these lines still holds:

- Before the step, read `tests\out\coverage\report.txt` for the lines the step moves or rewrites.
- A line that no test runs is either reached first by a new script or unit test, or moved whole with no
  change inside it. The hand-over names the lines that moved without a test.
- A step that must rewrite lines no test runs (the `GOTO` knots of `navy_commands` and `turn_resolve`)
  waits for its tests.

The 20 lines that no test runs (21 before phase 7 step 6):

| File | Lines | Why |
|------|-------|-----|
| `rules\setup.bm` | 22-24 | Vary Start's second loop, `FOR k = 21 TO 6`, never runs (a bug of the original, kept) |
| `ai\ai.bm` | 39 | Follows `IF ... GOTO capital ELSE GOTO city2`; nothing reaches it |
| `ai\ai.bm` | 113-114 | The `ELSE` for a fleet at sea; a fleet at sea already left at line 98 |
| `ai\ai.bm` | 222 | An army of size 0 that still holds a city; no game makes one |
| `port\qb64.bm` | 15-16 | `DIR$("")` for the next match; the game never calls it that way |
| `rules\battle.bm` | 58 | `CASE IS < .2` comes after `CASE IS < .5`, which takes it |
| `rules\battle.bm` | 131, 142 | `CASE IS > 800` comes after `CASE IS > 300`, which takes it (a bug of the original, kept) |
| `rules\navy.bm` | 87 | The computer wants a first ship and holds no sea port. It can be reached: a save where the computer's side has cash, no fleet and no sea port. No script has that state |
| `rules\navy.bm` | 346, 398 | `GOTO firemore` after an `IF ... GOTO ... ELSE GOTO ...`, and `GOTO pirate` after a `SELECT` whose cases all jump |
| `rules\turn.bm` | 307, 309 | `CASE IS > 800` and `CASE IS > 1000` come after `CASE IS > 400` (a bug of the original, kept) |
| `ui\orders.bm` | 118 | The picker found no city of the player's among 39; the player always holds the city it started on |
| `ui\orders.bm` | 133 | `CASE ELSE` of the picker's menu; the menu returns only a key, 1, 2 or 3 |
| `ui\reports.bm` | 95 | The army report when both sides have 0 victory points; a side gets points for its cities at the start |

Of the 214 lines run in part, most are a one-line `IF` whose `THEN` part did not run, or a sound that plays
only with the sound on. In `special_events` eight are left: the exit when random events are off, the cap
`pct! > .9` (it needs the year 1868), England's ships when the Rebel fleet is in port, the cap of the
Rebel fleet at 10 ships, and the riot's two early returns (realism off; a side with one city).

A step of phases 7 to 9 that rewrites a line still looks that line up in `tests\out\coverage\report.txt`
first (`play.py coverage`).

## Phase 7: what it left for later phases

- **Six `GOSUB` routines** that only their own SUB uses: `crsr`, `limits` and `noadjust` in
  `menu_select` (the key loop, which phase 9 reworks), `add1s` in `army_generate_name`, `jack` in
  `draw\ships.bm` and `stars` in `game\victory_screens.bm`.
- **The main module's menus**, a web of `GOTO menu0`, `GOTO optmen` and `GOTO utile` (phase 9).
- **`calculate_battle`**, whose split parts a rule from its screen (phase 8).
- **`army_clear`** (step 4): it waits for phase 10.

The splits of `calculate_battle` (losses, strengths) are phase 8's: they part a rule from its screen.

## Phase 8: split rules from screen

Started 2026-11-11. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

### How a SUB is split

Claude's choice on 2026-11-11, made while carrying out step 1. Check it before step 2.

- **The rule part** goes in `rules\` or `ai\`. It has no `PRINT`, `LOCATE`, `COLOR`, `CLS`, drawing,
  `SOUND`, `PLAY` or key, and calls no SUB that has one. What the screen needs from it comes back through
  its parameters.
- **The show part keeps the old SUB's name**, its parameters and every screen statement in the same order.
  It calls the rule parts where the rules were. Its callers do not change.
- **The show part goes to `ui\`**, in a file named after the rules file it came from: `calculate_battle`
  is now in `ui\battle.bm`. The layout of decision 10 had no such files.
- **Commands are filed in `ui\` for now.** Many show parts carry out one order, calling rules and
  drawing: `navy_commands`, `army_combine`, `army_recruit`, `railroad_move`, `turn_resolve`. Both the
  player's menus and the computer give these orders. They are a layer of their own, between rules and
  screens, which phase 9 names when each command gets its SUB.
- **The computer's code stays in `ai\`** (user, 2026-11-12). It decides and draws nothing itself; its
  messages are SUBs of `ui\ai.bm`. It may call the commands above to carry out an order.
- **Random numbers.** Two pieces of drawing code draw random numbers: the explosion marker
  (`draw_map_marker` with `MARK_EXPLOSION`, one draw for each circle when the sound is on) and
  `draw_schooner` (four). Where a show part calls them, it must stay between the same draws of the rule
  parts. `menu_recruit_cities` (`ui\orders.bm`) is the other way round: a rule that draws random numbers
  and picks the recruiting cities. It moves to `rules\` in step 6.
- **The cursor and the color.** A `LOCATE` or `COLOR` in a rule SUB decides where and how the next `PRINT`
  shows. Examples are `LOCATE 14 + i, 69` in `ai_recruit_pick` and the `COLOR` at the top of
  `menu_recruit_cities`. It moves to the show part at the same point.
- **A pause inside a rule's loop** becomes a count that the rule returns. The fight played a sound for
  each roll; now `battle_fight` returns `rounds`, and `calculate_battle` plays the sound that many times.
- **The factors inside the formulas** (`.3 * army_leader_rating`, `IF RND > .9`) stay numbers, as phase 3
  left them (`constants.md`, the end of section 7). Each is used once, and its line says what it does.

### The list

Measured on 2026-11-11, before step 1, with `tests\out\scratch\p8_mixed.py` (not committed). 41 SUBs in
`rules\`, `ai\` and `game\events.bm` print, draw, play a sound, read a key, or call a SUB of `ui\` or
`draw\` that does. `file-layout.md` marked 11 of them. One more, `ai_navy_adjust`, only calls
`menu_navy_items`, which fills the menu's texts and draws nothing. That leaves 40 to split.

| File | SUBs |
|------|------|
| `rules\battle.bm` | `calculate_battle` (step 1, done) |
| `rules\railroad.bm` | `railroad_move`, `railroad_start`, `railroad_arrive` |
| `rules\city.bm` | `city_capture`, `check_map_links` (the Utility menu's Chk Links, a printed report) |
| `rules\army.bm` | `army_new`, `army_get_commander`, `army_resupply`, `army_recruit`, `army_combine` (asks for a city with `menu_select`) |
| `rules\navy.bm` | `navy_commands` (one `COLOR`), `navy_build_ship`, `navy_bombard`, `navy_sail_to_port`, `navy_raid_commerce`, `navy_finish_move`, `navy_commerce_raid`, `navy_combat`, `navy_show_hits` |
| `rules\turn.bm` | `turn_date_and_supply`, `turn_resolve`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats`, `turn_army_surrenders`, `turn_enter_city` |
| `ai\ai.bm` | `ai_turn`, `ai_fortify`, `ai_army_orders`, `ai_drill`, `ai_recruit`, `ai_recruit_pick` (one `LOCATE`) |
| `game\events.bm` | `special_events`, `event_riot` |
| `rules\victory.bm` | `check_victory_conditions`, `victory_warnings`, `end_game`, `hall_of_fame` (reads the commander's name) |

Not in phase 8: `load_game` and `save_game` (`port\files.bm`). The folder rule does not cover `port\`, and
their screen is the menu of saved games, which phase 9 reworks.

### Steps

The order takes the SUBs that others call first, so that a caller's split finds its callees split.

1. **Done: `calculate_battle`.** See `modernize-completed.md`.
2. **Done: the railroad.** See `modernize-completed.md`.
3. **Done: `rules\city.bm` and `rules\army.bm`.** See `modernize-completed.md`.
4. **Done: `rules\navy.bm`.** See `modernize-completed.md`.
5. **Done: `rules\turn.bm`.** See `modernize-completed.md`.
6. **Done: `ai\ai.bm`.** See `modernize-completed.md`.
7. `special_events` and `event_riot`. The texts stay in the show part, which phase 11 moves to data.
8. The four of `rules\victory.bm`.
