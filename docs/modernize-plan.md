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
   (`TODO.md`, "The game", and the list at the end of `archived\sub-names.md`) are kept. Each is fixed later as its
   own decision with its own new recording. Narrowed on 2026-11-13 (user, `archived\scenario-plan.md` P1): a
   refactor step keeps the recorded screens identical. A change to behavior or the screen that is meant
   is its own commit. It records again only the scripts whose checkpoints differ, and its commit message
   lists them.
4. **Tests first.** Phase 0 measures which lines the scripts and unit tests reach and fills the gaps before
   those parts are changed.
5. **Start fresh from `qb64rust`.** Branch `extract-graphics` is read for what worked (its file split, its
   rename script), but nothing is merged from it. It mixed a bug fix with renames and moves.
6. **Data: rename first, records later.** The shared arrays and scalars are renamed first
   (`armysize` to `army_size`). A later phase groups them into records (`armies(i).size`,
   `cities(i).owner`, `sides(s).cash`). The saved-game file keeps its format. Overtaken on
   2026-11-12: phase 10 closed with no records (`archived\modernize-plan-completed.md`, "Phase 10"). One exception (user, 2026-11-13):
   the saved game gains the scenario's name as its first field (`archived\scenario-plan.md`, step 3).
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
12. **SUB names: the "Settled names" table of `archived\sub-names.md` is final.** One exception: a SUB that becomes a
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

20. **Phase 3 does all nine groups of `archived\constants.md`**, each group as its own commit. The other side and an
    army's side become two FUNCTIONs, `other_side(side)` and `army_side(army)`. The 16 colors are named and
    used in `COLOR` statements and the menu's color variables; the pictures keep their numbers.
21. **Variable names settled so far** (`archived\variable-names.md`): `armylead()` becomes `army_leader_rating()`,
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
| 7 | Break up the big pieces | `filer`, `report`, the main module, `navy`, `tupdate`, `smarts`, `events`. `GOSUB` routines become SUBs. The list is "Worth breaking out" in `archived\sub-names.md`. |
| 8 | Split rules from screen | Each mixed SUB becomes a rule part and a show part. `rules_test.bas` grows with each rule SUB. |
| 9 | Menus | One menu SUB for each command. It asks the player, then calls a rule SUB. The main module becomes a loop. |
| 10 | Records | Closed with none: the arrays stay arrays (`archived\modernize-plan-completed.md`, "Phase 10"). |
| 11 | The war's own content | Move what another war would replace into `game\`: flags, victory screens, tunes. Move texts, names, limits and the map's line work into data files (decision 19). |

After the plan, each as its own decision: the known bugs, and the engine split.

## Which model does which phase

Phase 11, the one phase left, is marked for Fable: `DRAW` and `PAINT` depend on order; expect several
tries. **When the next step is one marked Opus or Fable, stop and tell the user to switch model** before
starting it. The table for every phase is in `archived\modernize-plan-completed.md`, "Which model did which phase".

## Where to resume

Updated 2026-11-13. Phases 0 to 10 are done and committed. What each step did, and its commits, are in
`archived\modernize-plan-completed.md`.

**Next:** phase 11, the war's own content. Question 1 is answered (data files); the special events,
their rules and their texts, are in `scenarios\EVENTS.DAT`. Questions 2 and 3 are still open before
steps 1 and 3–4.

Tools for reading the code are in the ignored folder `tests\out\scratch\` (`show_gaps.py`,
`var_uses.py`, `count_numbers.py`). They are not committed.

## File layout at the end

```
cws.bas              the main loop only
cws.bi               types, constants, shared variables
rules\               army.bm city.bm battle.bm navy.bm railroad.bm setup.bm turn.bm victory.bm
ai\                  army.bm forces.bm navy.bm railroad.bm
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

## Lines that no test runs

Phase 0 measured the coverage and added the scripts (`archived\modernize-plan-completed.md`, "Phase 0: coverage").
Phase 7's rule for these lines still holds:

- Before the step, read `tests\out\coverage\report.txt` for the lines the step moves or rewrites.
- A line that no test runs is either reached first by a new script or unit test, or moved whole with no
  change inside it. The hand-over names the lines that moved without a test.
- A step that must rewrite lines no test runs (the `GOTO` knots of `navy_commands` and `turn_resolve`)
  waits for its tests.

The 11 lines that no test runs (20 before phase 9 step 6, 18 before the last labels went, 17 before
`DIR$` went on 2026-11-13, 15 before the kept bugs were fixed the same day, 12 before `battle_strengths`'
cases were put in order). The table names the SUB, not the line
numbers, because each step moves the lines; `report.txt` has the numbers of the day.

| File | SUB | Lines | Why |
|------|-----|-------|-----|
| `rules\setup.bm` | `vary_start_conditions` | 2 | The Rebels' army removed by Vary Start; no script's draw removes one. The loop never ran until 2026-11-13 (`FOR k = 21 TO 6`) |
| `ai\navy.bm` | `ai_fleet_orders` | 2 | The `ELSE` for a fleet at sea; a fleet at sea already left a few lines before |
| `ai\navy.bm` | `ai_fleet_orders` | 1 | The Union computer's first fleet, started at city 30 against a Rebel player. `ai_raise_forces` builds the first ship before it. It was the `THEN` part of a one-line `IF` until 2026-11-12 |
| `ai\army.bm` | `ai_evaluate_move` | 1 | `odds! = 5`: an army of size 0 that still holds a city; no game makes one |
| `rules\battle.bm` | `battle_losses` | 1 | The losses of a defender of more than 80,000 men; no script has one. The case came after `CASE IS > 300` until 2026-11-13 |
| `ai\forces.bm` | `ai_fortify` | 1 | The Union computer stops fortifying when it has no fleet. Since 2026-11-13 a computer without a fleet builds one in the same turn (`ai_fleet_orders`), so no script's computer fortifies without one. A game can still reach it: the Union's fleet sunk in the player's turn, before the computer fortifies |
| `ai\navy.bm` | `ai_navy_raid` | 1 | The computer's fleet goes raiding and meets no enemy at sea. It raids only in answer to the player's raiders, which are at sea |
| `ui\city.bm` | `menu_city_select` | 1 | `CASE ELSE` of the picker's menu; the menu returns only a key, 1, 2 or 3 |
| `ui\reports.bm` | `report_armies` | 1 | The army report when both sides have 0 victory points; a side gets points for its cities at the start |

Of the 178 lines run in part, most are a one-line `IF` whose `THEN` part did not run, or a sound that plays
only with the sound on. In `rules\events.bm` one is left: the riot's early return for a side with one city.

A step of phases 7 to 9 that rewrites a line still looks that line up in `tests\out\coverage\report.txt`
first (`play.py coverage`).

## Phases 7 to 10

Done. What each did is in `archived\modernize-plan-completed.md`. Two of the rules they set still hold
for new code, and are kept here: "How a SUB is split" (phase 8) and "How a menu is split" (phase 9).

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
  `SUPPLY_*`, `BLAST_*`; `archived\constants.md`, section 5). A yes-or-no flag (`damaged`, `sank`, `halted`,
  `added`) stays 0 or 1, and the battle's step indexes stay numbers with a comment.
- **Random numbers.** Two pieces of drawing code draw random numbers: the explosion marker
  (`draw_map_marker` with `MARK_EXPLOSION`, one draw for each circle when the sound is on) and
  `draw_schooner` (four). Where a show part calls them, it must stay between the same draws of the rule
  parts. `menu_recruit_cities` (`ui\army.bm`) is the other way round: a rule that draws random numbers
  and picks the recruiting cities. It moves to `rules\` in step 6.
- **The cursor and the color.** A `LOCATE` or `COLOR` in a rule SUB decides where and how the next `PRINT`
  shows. Examples are `LOCATE 14 + i, 69` in `ai_recruit_pick` and the `COLOR` at the top of
  `menu_recruit_cities`. It moves to the show part at the same point.
- **A pause inside a rule's loop** becomes a count that the rule returns. The fight played a sound for
  each roll; now `battle_fight` returns `rounds`, and `calculate_battle` plays the sound that many times.
- **The factors inside the formulas** (`.3 * army_leader_rating`, `IF RND > .9`) stay numbers, as phase 3
  left them (`archived\constants.md`, the end of section 7). Each is used once, and its line says what it does.

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

## Phase 11: the war's own content

Drafted 2026-11-12. Question 1 answered 2026-11-13: data files
(`archived\modernize-plan-completed.md`). Questions 2 and 3 are still open.

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
| The tunes, the victory screens | `game\tunes.bm`, `victory_screens.bm` (in `game\` already) | 275 |
| The events: when each happens, what it does and its texts ("Lincoln has been reelected") | `scenarios\EVENTS.DAT` (data since 2026-11-13; read by `load_events`, rolled by `rules\events.bm`, shown by `ui\events.bm`) | 18 events |
| The events' two tunes | `ui\events.bm` (`PLAY` strings) | 2 |
| Other texts that name the war ("Union", "Rebel", "ironclad") | `ui\options.bm` 6, `ui\reports.bm` 5, `ui\victory.bm` 3, `ui\battle.bm` 2, `ui\orders.bm` 2, `commands\navy.bm` 2, `rules\army.bm` 2, `ui\navy.bm` 1, `draw\pictures.bm` 1 | 24 texts |
| The map's line work | `draw\map.bm` (`draw_map`, `draw_map_touchup`), `draw\pictures.bm` (`draw_chesapeake`) | about 410 |
| The flags | `draw\icons.bm` (`draw_large_flag`, `draw_flag_icon`) | about 55 |
| The title, the cannon, the ironclad and the schooner | `draw\pictures.bm`, `draw\ships.bm` | about 370 |
| The rule numbers (prices, the ironclads' date, the first year) | `cws.bi`, the block "The Civil War's own rule numbers" | 10 constants |
| Rules that treat the two sides differently (the Union's two extra supply in `rules\army.bm` line 61, `union_income_bonus`) | `rules\`, `ai\` | not yet counted |

### Steps, as proposed

1. **Move what is the war's and is already a SUB**: the flags, the map's line work, the title,
   the cannon and the two ship pictures go to `game\`, whole (as phase 6 moved SUBs). The ten
   rule constants go to a `game\rules.bi`.
2. **Done: the events** are in `scenarios\EVENTS.DAT` (`archived\modernize-plan-completed.md`, "Phase 11 step
   2"). Still in `ui\events.bm`: the two `PLAY` tunes, the alarm of an announcement, and the
   bottom line cleared only for an event of the Union's roll.
3. **The other 24 texts**, each looked at: a text that only uses `side_name$()` already passes
   the test; one that spells "Union" does not. Those that fail go to a data file too (question 1).
4. **List the rules that treat the sides differently**, with a name for each. Whether they move
   is a question for the engine split, not for this phase.
5. **A list of what QB64 made awkward**, kept from step 1 on. It is the evidence for whether
   QB64Rust should gain modules or another feature (user, 2026-11-12).

### Open questions

2. **The map's line work: code in `game\`, or a data file read by a small drawer?** Decision 19
   says a data file.
3. **Are steps 1 to 4 the right size**, given the test above, or should the phase stop after
   step 2?
