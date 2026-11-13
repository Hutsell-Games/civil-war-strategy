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
   `cities(i).owner`, `sides(s).cash`). The saved-game file keeps its format. Overtaken on
   2026-11-12: phase 10 closed with no records ("Phase 10: records").
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
| 10 | Records | Closed with none: the arrays stay arrays ("Phase 10: records"). |
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
`b67f89e`. Step 6, the computer's turn, is committed as `ae48902`, and the cleanup after it, from
the review of steps 1 to 6, as `5e27bf8`. Step 7, the special events, is committed as `c298f3a`,
and step 8, victory, as `f5ee0f0`. That ends phase 8.

Phase 9, the menus, has its plan below ("Phase 9: the menus"). Its step 1, the Utility menu, is
committed as `693c078`, step 2, the Commands menu, as `10056a5`, step 3, the Files menu, as
`f831801`, step 4, the main menu, as `653e218`, and step 5, the main module as a loop, as
`83c34c8`. Step 6, the navy's commands, is committed as `aa2f80b`. That commit does not build:
it also holds the three `git mv` renames of step 7, without step 7's `$INCLUDE` lines. Step 7,
the other commands, is committed as `77e3024` and puts that right. Step 8, `menu_select` and the
file renames, is done in the working tree (2026-11-12). That ends phase 9.

Phase 9 step 8 is committed as `4fa959d`. Phase 10, records, has its plan below ("Phase 10:
records"). Its step 1, the script and `sides`, was committed as `3043c01`, and step 2, `fleets` and
`trains`, as `ae6da81`. Both were taken back in `a04672d`, and phase 10 is closed with no records
(2026-11-12; "Why no records", below).

**Next:** phase 11, the war's own content. Its plan is drafted below ("Phase 11: the war's own
content"); the user answers its three open questions before any code changes.

Tools for reading the code are in the ignored folder `tests\out\scratch\` (`show_gaps.py`,
`var_uses.py`, `count_numbers.py`). They are not committed.

## File layout at the end

```
cws.bas              the main loop only
cws.bi               types, constants, shared variables
rules\               army.bm city.bm battle.bm navy.bm railroad.bm setup.bm turn.bm victory.bm
ai\                  ai.bm
ui\                  menu.bm orders.bm reports.bm screen.bm messages.bm
commands\            the orders that the player's menus and the computer both give
draw\                map.bm icons.bm ships.bm pictures.bm
game\                the Civil War's map, flags, victory screens, tunes, event texts, side names
port\                qb64.bm script.bm
```

The folder states the rule its files keep: nothing in `rules\` or `ai\` draws, prints or reads a key,
nothing in `commands\` opens a menu or reads a key, and `game\` is what another war replaces. The file names inside each folder are settled in phase 6.

## Open questions

Asked as the plan goes down a level:

None at present.

Answered: the commands get a folder of their own, `commands\` (user, 2026-11-12). A command carries
out one order for either side: it calls rules and shows what happened. Examples are
`navy_build_ship`, `army_combine`, `army_recruit` and `railroad_move`, which phase 8 filed in `ui\`.
Nothing in `commands\` opens a menu or reads a key. Phase 9 steps 6 and 7 move them.

## Lines that no test runs

Phase 0 measured the coverage and added the scripts (`modernize-completed.md`, "Phase 0: coverage").
Phase 7's rule for these lines still holds:

- Before the step, read `tests\out\coverage\report.txt` for the lines the step moves or rewrites.
- A line that no test runs is either reached first by a new script or unit test, or moved whole with no
  change inside it. The hand-over names the lines that moved without a test.
- A step that must rewrite lines no test runs (the `GOTO` knots of `navy_commands` and `turn_resolve`)
  waits for its tests.

The 18 lines that no test runs (20 before phase 9 step 6). The table names the SUB, not the line
numbers, because each step moves the lines; `report.txt` has the numbers of the day.

| File | SUB | Lines | Why |
|------|-----|-------|-----|
| `rules\setup.bm` | `vary_start_conditions` | 3 | Vary Start's second loop, `FOR k = 21 TO 6`, never runs (a bug of the original, kept) |
| `ai\ai.bm` | `ai_fleet_orders` | 2 | The `ELSE` for a fleet at sea; a fleet at sea already left a few lines before |
| `ai\ai.bm` | `ai_fleet_orders` | 1 | The Union computer's first fleet, started at city 30 against a Rebel player. `ai_raise_forces` builds the first ship before it. It was the `THEN` part of a one-line `IF` until 2026-11-12 |
| `ai\ai.bm` | `ai_evaluate_move` | 1 | `odds! = 5`: an army of size 0 that still holds a city; no game makes one |
| `port\qb64.bm` | `DIR$` | 2 | `DIR$("")` for the next match; the game never calls it that way |
| `rules\battle.bm` | `battle_strengths` | 1 | `CASE IS < .2` comes after `CASE IS < .5`, which takes it |
| `rules\battle.bm` | `battle_losses` | 2 | `CASE IS > 800` comes after `CASE IS > 300`, which takes it (a bug of the original, kept) |
| `ai\ai.bm` | `ai_navy_raid` | 1 | The computer's fleet goes raiding and meets no enemy at sea. It raids only in answer to the player's raiders, which are at sea |
| `rules\turn.bm` | `turn_set_move_order` | 2 | `CASE IS > 800` and `CASE IS > 1000` come after `CASE IS > 400` (a bug of the original, kept) |
| `ui\orders.bm` | `menu_city_select` | 1 | The picker found no city of the player's among 39; the player always holds the city it started on |
| `ui\orders.bm` | `menu_city_select` | 1 | `CASE ELSE` of the picker's menu; the menu returns only a key, 1, 2 or 3 |
| `ui\reports.bm` | `report_armies` | 1 | The army report when both sides have 0 victory points; a side gets points for its cities at the start |

Of the 178 lines run in part, most are a one-line `IF` whose `THEN` part did not run, or a sound that plays
only with the sound on. In `game\events.bm` five are left: the cap `chance! > .9` (it needs the year 1868),
the cap of the Rebel fleet at 10 ships, the `EXIT SUB` after the volunteers' loop, which leaves at its
sixth army, and the riot's two early returns (realism off; a side with one city).

A step of phases 7 to 9 that rewrites a line still looks that line up in `tests\out\coverage\report.txt`
first (`play.py coverage`).

## Phase 7: what it left for later phases

- **Six `GOSUB` routines** that only their own SUB uses: `crsr`, `limits` and `noadjust` in
  `menu_select` (the key loop, which phase 9 reworks), `add1s` in `army_generate_name`, `jack` in
  `draw\ships.bm` and `stars` in `game\victory_screens.bm`. Phase 9 step 8 removed the three of
  `menu_select`. The other three went with the labels on 2026-11-12 (`modernize-completed.md`,
  "After the plan: the labels").
- **The main module's menus**, a web of `GOTO menu0`, `GOTO optmen` and `GOTO utile` (phase 9).
- **`calculate_battle`**, whose split parts a rule from its screen (phase 8).
- **`army_clear`** (step 4): it waited for phase 10 and stays undone ("Phase 10: records").

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
- **A screen part changes no game state** (user, 2026-11-12, the review's finding 2). Every
  assignment to a shared variable is in `rules\` or `ai\`, however short, except two kinds:
  - the menu's own variables (`menu_*`), and the lines tangled with the menus that phase 9 rewrites:
    `turn_navy_done = 1` (four times in `ui\navy.bm`), `fleet_size(side) = LEN(fleet_ships$(side))` in
    Sail and Raid, and `city_owner(0) = side` in `navy_commands`;
  - the army's city and order that `turn_attacker_withdraws` and `turn_defender_retreats` set just
    before `animate_army`, which reads them to draw the march.
- **A code that a rule returns gets constants** when its caller tests it by number (`COMBINE_*`,
  `SUPPLY_*`, `BLAST_*`; `constants.md`, section 5). A yes-or-no flag (`damaged`, `sank`, `halted`,
  `added`) stays 0 or 1, and the battle's step indexes stay numbers with a comment.
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
7. **Done: `special_events` and `event_riot`.** See `modernize-completed.md`.
8. **Done: `rules\victory.bm`.** See `modernize-completed.md`. That ends phase 8.

## Phase 9: the menus

Started 2026-11-12. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

### How a menu is split

Claude's choice on 2026-11-12, made while carrying out step 1. Check it before step 2.

- **One menu SUB for each menu and each entry.** A menu SUB fills the menu's texts, calls
  `menu_select` and shows the result. Its name starts with `menu_`. It is in `ui\`.
- **A menu SUB changes no game state.** What the player chose goes to a rule SUB, however short
  (`option_toggle_history` is one line). This is phase 8's rule for a screen part, now without the
  exception for "the lines tangled with the menus".
- **A menu that shows again is a loop.** `GOTO utile` became a `DO` loop in `menu_utility`. An entry
  that ends the menu is an `EXIT SUB`.
- **The row a menu starts on is set where the menu is filled.** A menu that shows again starts on
  the row just chosen (`menu_choice = MENU_START + row`).
- **The statements stay in their order** inside each entry, except that a setting is changed first
  and shown after. No message reads a setting before it is changed.
- **A variable of the main module that a menu used between calls** becomes `STATIC` in the menu's
  SUB. The only one so far is `t$` in `menu_option_events`.
- **Known oddities are kept**, each with a unit test where a rule SUB holds it, or a row in
  `TODO.md`.

### Steps

The menus come first, from the simplest. The main module's loop follows, when no menu is left in
it. The commands that both the player and the computer give come last. They are the hardest:
their random numbers must stay in order.

1. **Done: the Utility menu.** See `modernize-completed.md`.
2. **Done: the Commands menu.** See `modernize-completed.md`.
3. **Done: the Files menu.** See `modernize-completed.md`.
4. **Done: the main menu and its own entries.** See `modernize-completed.md`.
5. **Done: the main module is a loop.** See `modernize-completed.md`.
6. **Done: the navy's commands.** See `modernize-completed.md`.
7. **Done: the other commands.** See `modernize-completed.md`.
8. **Done: `menu_select` and the file renames.** See `modernize-completed.md`. That ends phase 9.

## Phase 10: records

Closed on 2026-11-12 with no records: every shared array stays an array (user, 2026-11-12). This
overtakes the second half of decision 6.

### Why no records

The first plan made six records: armies, leaders, cities, sides, fleets and trains. `sides`
(`3043c01`) and `fleets` and `trains` (`ae6da81`) were built and committed, and `cities` and
`leaders` were built. The user then asked whether the code was better for it. It was not, so all
of them were taken back (`a04672d`), and the army record was not built:

- **A record pays where the code handles a whole thing at once.** Nothing copies or clears a
  whole city, side, fleet or train. For them a record only changed the spelling, and made lines
  longer: `side_cash(city_owner(i))` became `sides(cities(i).owner).cash`.
- **`leaders(i)` misled.** It is the pool of leaders not yet used, by army slot, not "the leader
  of army i".
- **Armies are not handled whole either.** No line copies a whole army: Join
  (`rules\army.bm`, lines 48 to 51) copies the size, leader rating, experience, supply and name,
  and leaves the city and the order. Four places clear a slot, each with other fields; the
  fullest (`rules\setup.bm`, line 137) leaves the experience and the supply. No `SWAP` of armies
  exists. A whole-record copy or clear would change fields the original leaves alone, so the
  screens-identical rule (decision 3) allows it in one or two lines at most, out of 842 uses.

Records become worth it when the clears and copies are made the same. That changes behavior, so
it belongs with the known bugs after the plan, each with its own new recording.

### What both compilers do with records

Measured on 2026-11-12 with two small programs, built by QB64Rust and by QB64pe (the reference
clone). Both printed the same for every line:

- a variable-length `STRING` field starts empty, and `LEN` and `= ""` work on it;
- a field, and an element of a field array, is passed by reference: a SUB that changes its
  parameter changes the field;
- `SWAP` of two fields and of two whole records, and a whole record copied with `=`;
- `WRITE #` and `INPUT #` into fields, with a name that holds a comma;
- an INTEGER field that overflows wraps with no error, as an INTEGER array does;
- a field array with a `CONST` bound (`road(0 TO MAX_ROADS)`), and a `TYPE` in an included `.bi`.

So a record needs no more than the new name on each line, should records be taken up again.

### The script

`tools\refactor\make_records.py` is kept with the others (decision 16), for a later change or
another port. It reads the "Record field" column of `variable-names.md`, where every row now says
"(stays an array)", and turns `army_size(expr)` into `armies(expr).size`. It uses the tokens of
`rename_vars.py`, so strings and comments stay as they are, and it skips an array that a SUB
declares for itself. The declarations in `cws.bi` are written by hand. It rewrote 437 uses for
`sides`, 370 for `fleets` and `trains` and 578 for `cities` and `leaders`, each with all tests
passing, before they were taken back.

`army_clear` (phase 7, step 4 of `modernize-completed.md`) waited for this phase. It stays
undone, for the reason above: the places that clear an army do not clear the same fields.

## Phase 11: the war's own content

Drafted 2026-11-12. Not started: its questions are open (below).

### The test of this phase

Phase 10 showed that a change can pass every test and still not make the code better. So this
phase has one test of its own: **a second war is made by replacing `game\` and `scenarios\`, and
nothing else.** A step is worth doing when it moves something that fails that test. A step that
only moves text around is not.

### What knows that it is the Civil War, today

Surveyed on 2026-11-12 at `a04672d`.

| What | Where it is | Lines or count |
|------|-------------|---------------:|
| Side names, month names, start date, victory rules, starting armies and cash | `scenarios\CWS.INI` (data already) | |
| Leaders; cities and roads | `scenarios\CWSLEAD.DAT`, `CITIES.GRD` (data already) | |
| The events' rules, the tunes, the victory screens | `game\events.bm`, `tunes.bm`, `victory_screens.bm` (in `game\` already) | 431 |
| The events' texts ("Lincoln has been reelected") and their two tunes | `ui\events.bm` | 15 texts |
| Other texts that name the war ("Union", "Rebel", "ironclad") | `ui\options.bm` 6, `ui\reports.bm` 5, `ui\victory.bm` 3, `ui\battle.bm` 2, `ui\orders.bm` 2, `commands\navy.bm` 2, `rules\army.bm` 2, `ui\navy.bm` 1, `draw\pictures.bm` 1 | 24 texts |
| The map's line work | `draw\map.bm` (`draw_map`, `draw_map_touchup`), `draw\pictures.bm` (`draw_chesapeake`) | about 410 |
| The flags | `draw\icons.bm` (`draw_flag`, `draw_flag_icon`) | about 55 |
| The title, the cannon, the ironclad and the schooner | `draw\pictures.bm`, `draw\ships.bm` | about 370 |
| The rule numbers (prices, the ironclads' date, the first year) | `cws.bi`, the block "The Civil War's own rule numbers" | 10 constants |
| Rules that treat the two sides differently (the Union's two extra supply in `rules\army.bm` line 61, `union_income_bonus`) | `rules\`, `ai\` | not yet counted |

### Steps, as proposed

1. **Move what is the war's and is already a SUB**: the flags, the map's line work, the title,
   the cannon and the two ship pictures go to `game\`, whole (as phase 6 moved SUBs). The ten
   rule constants go to a `game\rules.bi`.
2. **The events' texts** leave `ui\events.bm` for `game\`.
3. **The other 24 texts**, each looked at: a text that only uses `side_name$()` already passes
   the test; one that spells "Union" does not.
4. **List the rules that treat the sides differently**, with a name for each. Whether they move
   is a question for the engine split, not for this phase.
5. **A list of what QB64 made awkward**, kept from step 1 on. It is the evidence for whether
   QB64Rust should gain modules or another feature (user, 2026-11-12).

### Open questions

1. **Texts: code in `game\`, or a data file?** Decision 19 says data files.
2. **The map's line work: code in `game\`, or a data file read by a small drawer?** Decision 19
   says a data file.
3. **Are steps 1 to 4 the right size**, given the test above, or should the phase stop after
   step 2?
