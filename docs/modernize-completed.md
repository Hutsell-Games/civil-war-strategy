# Done: modernizing the code of Civil War Strategy

The finished parts of `modernize-plan.md`, moved here on 2026-11-11. The plan keeps the decisions, the
phases still to do and the rules that still hold. Line numbers are those of the day each part was written.

## Progress, phase by phase

Updated 2026-11-11. Phase 1 is committed (`1727bf9`). Phase 2 is done in the working tree, not committed:
`tools\refactor\rename_subs.py` (from the "Settled names" table; `report` lists uses, `apply` rewrites).
`play.py check` and `compare` pass 25 of 25 with no recording changed, and the 23 unit tests pass. The branch
is `refactor_naming`. The user stages and commits. Phase 2 is committed (`4097c02`). Phase 4 step A is done
in the working tree: `tools\refactor\rename_vars.py` renamed 83 shared variables from `variable-names.md`
(not `side`, `matrix`, `navymove`); checks pass as for phase 2. Step B is committed (`e89f206`): `side` to
`current_side` and the parameters. The `matrix()` split is done in the working tree
(`tools\refactor\split_matrix.py`: `city_road()`, `city_port_type()`, and a local `hall_score` in
`hall_of_fame`); checks pass as before. `OPTION _EXPLICIT` is on in `CWSTRAT.BAS`; `tools\refactor\declare_locals.py` added the
`DIM` lines (about 94, at the top of each SUB). That ends phase 4. Phase 6 is done in the working tree:
`tools\refactor\move_subs.py` moved the 74 SUBs by the table of `file-layout.md` and `git mv`ed `SCRIPT.BM`,
`QB64.BM` and `FOLDERS.BI` into `port\`; `play.py` hashes the six folders. `CWSTRAT.BAS` and `CWS14.BI` keep
their names (renaming them to `cws.bas` and `cws.bi` touches CI and the scripts, so it is a step of its own).
Phase 6 is committed (`19ac90a`). Phase 3 group 1 (sides and limits) is committed (`8db43da`): the
CONSTs in `CWS14.BI`, and `army_side` and `other_side` in `rules\army.bm`. Each number was read in place
(not by a script from a table), so no script goes into `tools\refactor\`.
Groups 2 to 9 are committed (`cfc9030`, `dd8c456`, `b608f8d`, `8953dfc`, `e0d1b2f`, `b57be0b`,
`c19189e`, `f05fdd8`), which ends phase 3. What the groups left alone is in `TODO.md`, "The code".
Phase 5 step 1 is committed (`b870824`): `city_is_connected`, `city_nearby_enemy_strength`,
`railroad_capacity` and `menu_measure_width` are FUNCTIONs and keep their settled names. Each call
`CALL f(args, v)` became `v = f(args)`, with the same variable and in the same place. Step 2 is done in
the working tree: `side_army_range` became `side_first_army` and `side_last_army` (user, 2026-11-11).
`army_get_commander` stays a SUB, because it also makes up a leader, draws a random number and prints
(user, 2026-11-11). That ends phase 5.
Phase 7 step 1 is done in the working tree (2026-11-11): `file_management` is split, see "Phase 7" below.
Steps 2 and 3 are done in the working tree too: `menu_report` is split, and `wait_key` is in.
Step 4, the small shared pieces, is done in the working tree.
Phase 0 went first (user, 2026-11-11) and is done: see "Phase 0 after phase 7 began" below. 33 scripts,
21 lines not run, each with its reason.
Phase 7 step 5 is done in the working tree: eleven pieces of the main module are SUBs.
Step 6 is done in the working tree: `turn_resolve`'s outer parts are SUBs, and 20 lines are not run.
Step 7 is done in the working tree: `event_riot`, and `ai_turn` is six `ai_` SUBs and a FUNCTION.
Step 8 is done in the working tree: recruiting and the railroad are split into menu, computer and rule.
Step 9 is done in the working tree: `victory_warnings`, `end_game`, and the Hall of Fame's own arrays.
Step 10's first part is done in the working tree: `navy_combat`, `ai_pick_port`, `draw_fleet_sailing`.
Its second part is done too: `navy_commands` is a loop over `menu_navy` or `ai_navy_adjust` and `navy_action`.
Its third part is done too: one SUB for each action. That ends step 10.
Step 11 is done in the working tree: the knot of `turn_resolve` is six SUBs.
Step 12 is done in the working tree: `menu_mark_row` and `menu_unmark_row`. That ends phase 7.
Phase 8 step 1 is done in the working tree: `calculate_battle` is four rule SUBs and its screen, see
"Phase 8" below. Step 2 is done in the working tree: the railroad.

Notes from the start of the work:

1. **Done: phase 1, the deletions.** `burn` and its call in `capture`; `scrnsavr`, its Ctrl+B test in
   `menu` and the labels `boss:` and `boss1:`; the label `topbar:` in `CWSTRAT.BAS` (lines 706 to 710) and
   the dead `GOTO menu0` after `GOTO loader` (line 128); `menu` mode 5; `price()`; every `DECLARE SUB` in
   `CWS14.BI`. Then `play.py check` and `play.py compare` must pass with no recording changed. The cause to
   watch: `scrnsavr` runs `RANDOMIZE TIMER`, but only after Ctrl+B, which no script sends.
2. Then the scripts of phases 2 and 4 into `tools\refactor\` (decision 16), tested on a copy first.
3. **Stop and tell the user** at phase 0 (Opus), phase 3 (Opus) and phase 5 (Opus). They come before
   phase 6 in the plan's order, so the user decides whether to switch model there or run phase 6 first.
4. The user accepted the names of `constants.md` as proposed (2026-11-11).

Answered: the table of variable names in `variable-names.md` (phase 4) was settled, and phase 4 is done.

## Phase 0: coverage

Measured on `8c3b185` (2026-11-11, `python tests\play.py coverage`): the 25 scripts and the unit tests run
3,381 of 3,844 lines with a statement in full and 234 in part; 229 are not run (94.0%). By statements, the
SUBs with the most not run:

| SUB | Statements | Not run |
|-----|-----------:|--------:|
| the main module | 941 | 126 |
| `navy` | 575 | 104 |
| `scrnsavr` (deleted in phase 1) | 89 | 89 |
| `events` | 181 | 59 |
| `tupdate` | 328 | 39 |
| `menu` | 218 | 30 |
| `battle` | 310 | 27 |
| `smarts` | 190 | 26 |
| `railroad` | 171 | 23 |
| `shen` | 21 | 21 |
| `report` | 295 | 15 |
| `filer` | 161 | 7 |

The drawing SUBs are at or near 100%. The full list is `tests\out\coverage\subs.txt` after a run.

### How the gaps are reached (user, 2026-11-11)

- **Forced dice in `events`.** Each `RND` in `events` becomes `script_rnd!` (`SCRIPT.BM`). In a normal game it
  returns `RND`. Under a script, an environment variable holds the next draws (for example
  `0.05,0.95,0.1`); when they are used up it returns `RND`. `play.py` sets the variable from a new header
  line of the keys file. The event's own conditions (`year`, `control(2) < 30`) still run.
- **Prepared saved games.** A new header `#! data <folder>` copies the files of `tests\data\<folder>\` into
  the run. The folder holds a `cws1.sav` written for the test, and the script loads it with Resume Saved
  Game. The same header gives a broken `CITIES.GRD` or leaves out `MTN.VGA`. A save is a text file of 85
  `WRITE #` lines (`filer`, case 3), so it can be written by hand or by a small script.
- **Sound on, unheard.** Scripts with `cfg noise=2` run the tunes and beeps. `PLAY "V0"` moves out of
  `scriptstart` to before the title screen; the `RANDOMIZE` stays where it is, so no random number changes.
  The notes are not checked. Step 1 checks first that `SOUND` is silent under `PLAY "V0"` with both
  compilers.

### The gaps, by group

Line numbers are those of `8c3b185`.

| Group | Where | How it is reached |
|-------|-------|-------------------|
| Code that phase 1 deletes | `scrnsavr`; `menu` lines 296 to 300; `CWSTRAT.BAS` lines 706 to 710 | No test. Phase 1 may run before the rest of phase 0. |
| Special events | `events`: England's ships (429 to 442), mercenaries (445 to 449), riots (477 to 485), Lincoln reelected (518 to 520), and 12 half-run lines | Forced dice. A prepared save for the states: the Rebels hold 30 cities; November 1864 after the Emancipation. |
| Commands no script chooses | The Supply menu and its cut-off check (`CWSTRAT.BAS` 311 to 337); the ship type menu (`navy` 731 to 738); the Raze menu (`tupdate` 1803 to 1811); the Join menu (`combine` 292 to 294); the Which menu (`movefrom` 661 to 665); a fleet retreats (`navy` 1039 to 1051) | New scripts, from a new game or a prepared save. |
| Refusals | "Not enough money for fort", "Cannot move capital", "Too small to detach", "No armies remain eligible for drills", "Railroad is already carrying", "Too many troops for railroad capacity", "Track … is blocked", "No campaigns in January", "NO SHIPYARDS AVAILABLE", "No ships remain", "No more … commanders available", "No valid armies to combine" | A prepared save with low cash, a small army or a full list of commanders, then one key. |
| Rare states | A fleet eliminated (`navy` 811 to 816); the computer's fleet moves (`smarts` 1488 to 1505); the order of movement for slow armies (`tupdate` 1646 to 1648); a beaten army's flight (`tupdate` 1739 to 1747) | A prepared save. Where the branch draws nothing, a unit test. |
| Rule branches | `battle`: the caps on the two strengths (about 20 half-run lines), `x1 = .5 * x1`, `pct! = .8 * pct!`; `evaluate`; `resupply`; `victor` | Unit tests in `rules_test.bas`, which already calls these SUBs. |
| Sound | The title tune (`CWSTRAT.BAS` 79 to 93); `shen`; about 20 `IF noise > 0 THEN SOUND …` halves; the two victory tunes | One or two scripts with `cfg noise=2`. |
| Bad or odd files | `MTN.VGA` missing (`CWSTRAT.BAS` 35); `integrity`'s error lines (617, 623, 624); a `CWS.CFG` with `player` 0 or `turbo!` 0 (lines 48 to 52) | `#! data` with the file broken or left out; `#! cfg`. |
| Menu details | `menu`: a menu taller than the screen, an empty title, a `wtype` over 10 (`choices` line 19) | Read at step 3: reach it or list it. |

Lines that no test can reach, so far:

- `CWSTRAT.BAS` line 128, `GOTO menu0`: it follows `GOTO loader`. Dead code; phase 1 removes it.
- `TICK` lines 1319 and 1320, the real pause: under a script `script_tick%` takes its place.
- `QB64.BM`, the `DIR$("")` form that returns the next match: the game never calls it that way.

### Found while reading

One more bug of the original, kept like the others (decision 3): in `events`, the mercenaries join
`armyname$(index)`, but `index` is never set in that SUB. So they join army 0, which is no army.

A second one: the Victory Conditions menu (`endit`) shows the income condition as
`vicflag(3) * 2.5` percent. `vicflag(3)` is the city condition; the income condition is `vicflag(4)`, and
`victor` tests that one. So the menu can show a percent that is not the one in force.

### Steps

Each step is one commit (decision 15). The 25 scripts that exist keep their recordings throughout.

1. Phase 1's deletions, done first, so that no test is written for code that goes.
2. `play.py`: the header `#! data <folder>` and the header for forced dice, with their tests in
   `test_play.py`.
3. The game: `script_rnd!` in `events`, and `PLAY "V0"` before the title. All 25 scripts must still pass.
4. A script that writes a save from a short description (which armies, which cities, the cash), so that a
   prepared save is readable. It goes in `tests\`.
5. The event scripts: one for each event of the table.
6. The command and refusal scripts.
7. The rare-state scripts and the unit tests of the rule branches.
8. The sound script.
9. Run `play.py coverage`. For each SUB of decision 13, each line still not run is reached or listed above
   with its reason.
10. Record the new scripts with both compilers (`play.py record`), then `play.py compare`.

### Phase 0 after phase 7 began

Steps 2 to 10 were taken up on 2026-11-11, after phase 7's step 4. Line numbers below are those of that day.

- **Steps 2 and 4, done.** `play.py` reads `#! data <folder>`, `#! without <file>` and `#! dice <groups>`.
  `tests\make_save.py` writes a saved game from a description: a `<name>.save` in a data folder becomes
  `<name>.sav` in the run. It is written at each run, so no made save is kept in the repo.
- **Step 3, done.** `special_events` draws its 17 random numbers through `script_rnd!`. The dice are
  groups, one for each call of `special_events`, so a script can force an event in each of several
  months. `script_mute` runs `PLAY "V0"` at the program's start.
- **Step 5, done.** Two scripts, `events-south` and `events-union`, each force several events from one
  prepared save. Not one script for each event: a group of dice for each month made that unnecessary.
- **Two faults of `play.py coverage` fixed.** Since phase 6 it left the unit tests' counts out, because
  their files are now in folders, and its table per SUB put every SUB of a folder under "(outside
  procedures)".
- **Measured after step 5** (27 scripts and the unit tests): 3,421 of 3,787 lines run in full, 223 in
  part, 143 not run. Before: 200 not run.

- **Steps 6 to 8, done.** Six more scripts, four of them from prepared saves: `refusals`, `navy-fights`,
  `navy-losses`, `bad-files`, `sound-union` and `sound-rebel` (`tests\README.md` says what each plays).
  Two need a seed found by trial, because the game draws a real random number there: the shore
  battery that sinks a ship (`navy-losses`, seed 6) and the Recruit menu that offers Indianapolis
  (`refusals`, seed 6). `tests\out\scratch\try_seeds.py` did the search; it is not kept in the repo.
- **Step 7's unit tests of the rule branches were not written.** The three lines they were for
  (`rules\battle.bm` 58, 131 and 142) cannot be reached: see the table.
- **Steps 9 and 10, done.** Measured on 2026-11-11 with 33 scripts and the unit tests: 3,552 of 3,787
  lines run in full, 214 in part, 21 not run (99.4%). All 33 scripts pass with both compilers.


The lines that no test runs are listed in `modernize-plan.md`, "Lines that no test runs".

## Phase 7: break up the big pieces

Started 2026-11-11. The pieces and their names are those of "Worth breaking out" in `sub-names.md`. Each
step is one commit (decision 15), and each ends with `play.py check`, `play.py compare` and the unit tests
passing on unchanged recordings.

### Phase 0 was not finished

Only step 1 of phase 0 (the deletions) was done. Steps 2 to 10 were skipped: there is no forced dice, no
prepared save and no new script. So decision 13's bar is not met. Measured on 2026-11-11 before step 1
(`play.py coverage`, 25 scripts): 3,354 of 3,786 lines run in full, 232 in part, 200 not run. By
statements not run: the main module 116, `rules\navy.bm` 104, `ui\orders.bm` 74, `game\events.bm` 59,
`rules\army.bm` 59, `rules\turn.bm` 39, `ai\ai.bm` 32, `rules\railroad.bm` 24.

The user decided on 2026-11-11 to finish phase 0 before step 5, and it is finished ("Phase 0 after phase
7 began"). Steps 1 to 4 were done under this rule, which still holds for the 21 lines left:

The rule for lines that no test runs is in `modernize-plan.md`, "Lines that no test runs".

### Steps

1. **Done: `file_management` into three SUBs.** `load_scenario`, `load_game` and `save_game`, still in
   `port\files.bm`. The line that reads or writes `cws.cfg` was there three times, and a fourth time in
   the Files menu's New Game. It is now `config_read (side)` and `config_write (side)`. `navymove()` is
   gone (decision 21): `save_game` writes a 0 in its place and `load_game` reads the field into a local,
   so the save format is the same. The Files menu calls `load_game` or `save_game` by `menu_choice`, and
   then still tests the `menu_choice` those SUBs' own menus left, as before. Lines moved without a test:
   none; the four half-run lines are `EXIT FOR`, `EXIT SUB` and one `THEN`, moved whole.
2. **Done: `menu_report` into one SUB for each report**: `report_armies (side)`, `report_cities`,
   `report_force_summary`, `report_intelligence`, `report_battle_summary` and `report_recap`, in
   `ui\reports.bm`. Each ends with `report_wait_key` ("press a key"). `menu_report` keeps the menu and
   draws the map again after a report. The F4 key calls `report_force_summary` in place of
   `menu_report(-1)`. The end of the game calls `report_battle_summary` in place of
   `menu_report(100 + side)`. The file `battsumm`, which only the end of the game wrote, is now written
   by `save_battle_summary` (`port\files.bm`), called just before the report is drawn and not just after.
   Two tests after the menu that could never be true are gone (`menu_choice < 0`, `menu_choice = 4`).
   Lines moved without a test: the `PRINT` for a side with no victory points, in `report_armies`.
3. **Done: `wait_key (letter$)`** (`ui\screen.bm`) for the 12 loops `CALL script_mark_key_wait(1, "X"):
   DO WHILE INKEY$ = "": LOOP`, each replaced by `CALL wait_key("X")` (2 in `CWSTRAT.BAS`, 3 in
   `game\events.bm`, 2 each in `rules\battle.bm`, `rules\turn.bm` and `rules\victory.bm`, 1 in
   `ui\reports.bm`). The menu's wait, the commander's name and the wait inside `script_tick%` are other
   kinds and stay. The two `wait_seconds(99)` stay as they are until the user decides whether they may
   wait forever (`TODO.md`, "The code").
4. **Done: small shared pieces.**
   - `draw_city_dot (city, c)` in `draw\map.bm`: the dot's three lines, used by `draw_cities` and twice
     by `animate_city`.
   - `city_redraw_fort (city)` in `draw\map.bm`: erases the fort's square and calls `draw_cities`. Used by
     `city_capture`, `navy_commands` (a fort damaged) and `turn_resolve` (a fort razed). The locals `x`
     and `y` those three set for it were read nowhere after.
   - `load_picture (file$, picture())` in `draw\pictures.bm`: `DEF SEG`, `BLOAD`, `DEF SEG`, four times.
   - `TRAIN_OUTLINE$` in `CWS14.BI`: the 55 characters that the three train pictures share. Each keeps
     its own color, scale and last strokes, which differ.
   - **Not done: `army_clear`.** The five places do not clear the same fields. A new game clears the
     name but not the experience or supply. Vary Start clears those but not the name. `army_combine`
     and the surrender in `turn_resolve` clear all of them; the first gives the name back to
     `leader_name$()` and the second clears it there too. Only Vary Start's two blocks are the same. One SUB for all would change what is left in a dead army's slot, which no screen shows at
     once. It waits for phase 10, where an army becomes a record.
5. **Done: the main module's pieces that stand alone.** `CWSTRAT.BAS` went from 753 lines to 614 and
   has no `GOSUB` left. The menus' `GOTO menu0` web stays for phase 9.
   - `draw_title` (`draw\pictures.bm`) and `play_title_music` (`game\tunes.bm`). The test that decides
     whether the tune plays stays in the main module.
   - `load_cities` (`port\files.bm`), `turn_collect_income` (`rules\turn.bm`) and `draw_player_turn`
     (`ui\screen.bm`, the `GOSUB` routine `blanken`).
   - `set_union_advantage` (the `GOSUB` routine `unionplus`) and `vary_start_conditions`, in a new file
     `rules\setup.bm`.
   - `menu_supply (picked)` and `menu_move_capital (city)` (`ui\orders.bm`). Each gives back 0 where
     the old code went to the main menu, and the main module then does `GOTO menu0`.
   - `army_detach (army, city, slot)` and `army_drill (army)` (`rules\army.bm`) are the rule only. The
     menu, the refusals and the messages stay in the main module until phase 9. `ai_turn` calls
     `army_drill` too. Both drills now mark the army busy before the message and not after it; nothing
     reads the order in between.
   - Four unit tests: detach, drill, the Union's advantage and the month's income.
   - Lines moved without a test: Vary Start's loop that never runs (now `rules\setup.bm` 22 to 24).
     Moved half-run: the six `EXIT SUB` of the Union's title tune (a key during the tune), the two
     caps on cash in `turn_collect_income`, and the supply below zero in `army_detach`.
6. **Done: `turn_resolve`'s outer parts.** `turn_resolve` went from 270 lines to 204 and has no
   `GOSUB` left.
   - `turn_set_move_order` and `turn_update_victory_points` (`rules\turn.bm`) draw nothing. Each has a
     unit test. The second test records that a Rebel side with more than 34 cities gets the Union's
     points and 100 (a bug of the original, kept).
   - `navy_commerce_raid` (`rules\navy.bm`, mixed): the raiding fleet's month, with its messages.
   - `draw_update_box` (`ui\screen.bm`): the `GOSUB` routine `upbox`.
   - The `GOTO allthru` after the loop over the armies is gone. It only jumped over `upbox`, and no
     test ran it, because the loop always leaves early. That makes 20 lines not run, not 21.
   - Lines moved without a test: the two shadowed `CASE` lines, now `rules\turn.bm` 283 and 285.
7. **Done: `special_events` and `ai_turn`.**
   - `event_riot (who)` (`game\events.bm`): the `GOSUB` routine `riot`.
   - `ai_turn` is now 17 lines that call one SUB for each of its headed sections, all in `ai\ai.bm`:
     `ai_resupply`, `ai_fortify`, `ai_raise_forces` (the Union's first ship and the recruiting),
     `ai_fleet_orders`, `ai_army_orders (who, c)` and `ai_drill`. Each takes the computer's side.
     Combining armies, the train and `draw_fleets` are single calls and stay in `ai_turn`.
   - `ai_count_armies (who)` is a FUNCTION (the `GOSUB` routine `enufarmies`), with a unit test.
   - The names `ai_raise_forces`, `ai_fleet_orders` and `ai_army_orders` are new. `ai_recruit` and
     `ai_navy` are kept for the computer's parts of `menu_army_recruit` (step 8) and `navy_commands`
     (step 10).
   - `ai_fortify` keeps the original's `side_cash < 222` with a local `side_cash` that is always 0
     (`TODO.md`, "The code").
   - A jump to the next section's label became `EXIT SUB`. Lines moved without a test: the four of
     `ai\ai.bm` in the table above, now 39, 113, 114 and 222.
8. **Done: `menu_army_recruit` and `railroad_move`**, each split into the human's menu, the computer's
   choice and the rule. Neither file has a `GOSUB` left for them.
   - Recruiting: `menu_army_recruit (side)` is the player's loop and `ai_recruit (side)` the
     computer's (`ai_raise_forces` calls it). Both call `menu_recruit_cities (side)`, which fills the
     menu with the month's cities, and `army_recruit (side, city, raised)`, which raises a new army
     or adds men. `ai_recruit_pick (side)` is the `GOSUB` routine `randsel`.
   - `army_recruit_bonus (slot)` is the `GOSUB` routine `playb`, the Balance setting's extra men. It
     never has an effect on an army, and the split keeps that: `army_new` sets a new army's size
     after it, and when men join an army it is called with slot 0, so it changes `army_size(0)`
     (which `ai_recruit_pick` reads for a city with no army). A fix would change the game.
   - The railroad: `railroad_move (side)` now only picks among `menu_railroad (side, army, city)`,
     `ai_railroad (side, army, city)`, `railroad_start (side, army, city)` and
     `railroad_arrive (side)`, and ends with the pause and the two clears as before.
     `railroad_route_count (side, city)` is a FUNCTION (the `GOSUB` routine `route`), with a unit
     test.
   - `ai_railroad` keeps one oddity: when it checks the track to the capital, it counts the track
     of the last city it looked at, not the capital's (`target` is not set again).
   - New names: `menu_recruit_cities`, `ai_recruit_pick`, `army_recruit_bonus`. The others are the
     names of `sub-names.md`. Lines moved without a test: none.
9. **Done: `check_victory_conditions`.** It keeps the tests of the rules, 40 lines.
   - `victory_warnings (i, x, y)` and `end_game (i, j)` (`rules\victory.bm`, both mixed). `x` and
     `y` are the Union's and the Rebels' men; `j` is the rule that was met.
   - `hall_of_fame` keeps its names in a local `hall_name$(2, 5)`. It used `city_name$(1)` to
     `city_name$(10)`, which stayed overwritten until the next game read `cities.grd` again; no
     screen showed them in between.
   - `hall_of_fame_load` and `hall_of_fame_save` (`port\files.bm`) read and write `hiscore.cws`. The
     file is now read whole before the table is printed, not line by line with it.
   - No unit tests: every piece draws or reads a key. Lines moved without a test: none.
10. **`navy_commands`**, in three parts. `navy_combat`, `ai_pick_port` and `draw_fleet_sailing` first. Then
    `ai_navy`, `menu_navy` and `navy_action`, and last one SUB for each action.
    - **Done: the first part.** `navy_commands` went from 436 lines to 265 and has no `GOSUB` left
      (lines 10 to 274 of `rules\navy.bm`).
      - `navy_combat (side, action)` (`rules\navy.bm`, mixed): ship against ship, the label `pirate:` to
        the end of its `SELECT`. `navy_commands` calls it from that label and goes on to `sail3:`.
        `navy_show_hits (hit())` is the `GOSUB` routine `showhit`. The routines `clr1` and `boxes`
        were one and two lines; they are written out where they were called.
      - `ai_pick_port (side)` (`ai\ai.bm`): the `GOSUB` routine `nest`.
      - `draw_fleet_sailing (side)` (`draw\ships.bm`): the 16 lines that Sail and Raid both held.
        `draw_navy_box` and `draw_ship_sunk (x, y)` there are the routines `box2` and `xout`.
      - New names: `navy_show_hits`, `draw_navy_box`, `draw_ship_sunk`. Lines moved without a test:
        the two dead `GOTO` lines of `navy_combat`, now `rules\navy.bm` 362 and 414.
    - **Done: the second part.** `navy_commands` is 12 lines: a loop that asks for the action
      (`menu_navy` for the player, `ai_navy_adjust` for the computer) and calls `navy_action`.
      - `navy_action (side, action, again)` (`rules\navy.bm`) is the old `SELECT` and the label
        `sail3:`. Each `GOTO ahoy` became `again = 1: EXIT SUB`, and the loop then asks again. The
        jumps `GOTO anchor` and `GOTO ships` stay inside it for the third part.
      - `ai_navy (side, action)` (`ai\ai.bm`) is the computer's first change of its order, done once.
        `ai_navy_adjust (side, action, quit)` holds the three decisions that were made while the
        menu was built: stop building, build when the fleet is gone, and invade when the menu
        offers Invasion.
      - `menu_navy (side, quit)` and `menu_navy_items (side)` (`ui\orders.bm`): the player's menu, and
        the menu's entries, which the computer's path fills too, as before.
      - The player's path no longer calls `city_nearby_enemy_strength` when Invasion is offered. It
        did, and threw the result away; the FUNCTION changes nothing.
      - `navy_action`'s locals now start at 0 on each pass. None is read before it is set.
      - Unit tests: `ai_navy` and `menu_navy_items`. New names: `ai_navy_adjust`, `menu_navy_items`.
      - The two dead `GOTO` lines of `navy_combat` are now `rules\navy.bm` 343 and 395.
    - **Done: the third part.** `navy_action` is a `SELECT` of five calls: `navy_build_ship`,
      `navy_bombard`, `navy_sail_to_port`, `navy_raid_commerce` (each `(side, action, again)`) and
      `navy_land_army (side, action)`, all in `rules\navy.bm`.
      - The names are not `navy_build`, `navy_attack`, `navy_sail`, `navy_raid` and `navy_invade`:
        BASIC ignores case, and those are the constants `NAVY_BUILD` to `NAVY_INVADE`.
      - `navy_finish_move` is the label `sail3:`: it notes which side raids commerce and draws the
        map again. A jump to `pirate:` became a call of `navy_combat` and then `navy_finish_move`.
      - `GOTO anchor` ran the same action again with a changed order, because `menu_choice` had not
        changed. In `navy_bombard` and `navy_land_army` it now jumps to the top of the SUB.
      - One dead line is deleted: Sail's `IF fleet_size(side) < 1 GOTO ships`, a jump into the
        middle of Build. Sail has already left by then if the fleet has no ship, and no test ran
        the jump.
      - The unrun lines of `rules\navy.bm` are now 87, 346 and 398. Moved half-run: Raid's fight
        when the other fleet is at sea too, and the computer's invasion with no commander left.
11. **Done: the attack, retreat and surrender knot in the middle of `turn_resolve`.** `turn_resolve` is
    40 lines and has no label. Its loop calls `turn_move_army (active)` for each army that moves. All
    six SUBs are in `rules\turn.bm` and all draw.
    - `turn_move_army (active)`: the army sets out, then enters an empty city, joins a friend or
      attacks.
    - `turn_attack (active, target, fought, took)`: the battles against one defender after another.
      `took` is 1 when the city is left without a defender. `fought` is the old `flag`: a battle was
      fought, so no fort is razed.
    - `turn_attacker_withdraws`, `turn_defender_retreats (active, target, defend, gone)` and
      `turn_army_surrenders (index, active)`: the three ways a battle ends.
    - `turn_enter_city (active, target, fought)`: the move into the city, the Raze menu and the
      capture.
    - One difference that no game reaches: the winner and loser of the last battle were locals of
      `turn_resolve`, kept from one army's move to the next. They were read without a battle only
      when the defender had 0 men, and no army with 0 men holds a city (the table above, `ai\ai.bm`
      222). They now start at 0 for each attack.
    - `turn_army_surrenders` keeps the original's order: it clears the loser's supplies and then
      adds them to the winner's, so the winner gains nothing.
    - No unit tests: every piece draws. Lines moved without a test: none.
12. **Done: `menu_select`'s highlight.** `menu_mark_row (kind, row, wide, flag)` and
    `menu_unmark_row (kind, row)` (`ui\menu.bm`) hold what a menu shows beside its highlighted row
    and what takes it off again. `menu_select` no longer names an army or a city.
    - The names are not `menu_highlight` and `menu_unhighlight`: `menu_highlight` is the shared
      variable for the highlight's color.
    - `menu_unmark_row` replaces two blocks. One of them skipped a row whose text is "EXIT". No
      menu of the game has such a row, so the test is gone.

## Phase 8: split rules from screen, the steps done

1. **Done: `calculate_battle`.** `rules\battle.bm` holds four rule SUBs, called in this order:
   - `battle_strengths (attacker, defender, attack_steps(), defend_steps())`: each value the right panel
     prints, 7 for the attack and 8 for the defense. It also counts an army of 0 men as 100, as before.
   - `battle_fight (attack, defend, attacker, defender, winner, loser, rounds)`: the rolls until one side
     hits and the other does not, and the day of supply taken from armies 1 and 2.
   - `battle_losses (attacker, defender, winner, killa, killd)`: both armies' losses.
   - `battle_apply_losses (attacker, defender, winner, killa, killd)`: takes them, and counts the
     casualties, the battle won and the victory point.

   `calculate_battle` (`ui\battle.bm`) is the screen. More details:
   - The fight's `GOTO grapple` is a `DO` loop that ends when exactly one side hits. The sound of each roll
     plays after the fight. No sound draws a random number, so the draws are the same.
   - Two pieces read nowhere are deleted: `spin = 0`, and a second working-out of the odds' text just
     before the losses are printed, whose `a$` was set again before use.
   - Bugs kept: the supply taken from armies 1 and 2 (new in `TODO.md`), `attacker > 2` in
     `battle_apply_losses`, and the `CASE IS > 800` arms that `CASE IS > 300` hides.
   - Unit tests: 7 new ones, so 40 in all. Lines moved without a test: the three dead `CASE` arms, now
     `rules\battle.bm` lines 54, 102 and 113, moved whole. All 81 lines of `ui\battle.bm` run, one of them
     in part (line 46, the odds' floor of 1%). 20 lines of the game are not run, as before.
2. **Done: the railroad.** `railroad_move`, `railroad_start` and `railroad_arrive` moved to
   `ui\railroad.bm`. Their state changes are two rule SUBs in `rules\railroad.bm`:
   - `railroad_board (side, army, city)`: the train takes the army, which leaves its city, and the next
     army there holds the city. `railroad_start` prints its message first, as before, and draws after.
   - `railroad_unload (side)`: the city the train left passes to the next army there, and the army gets
     off in the city it was sent to. `railroad_arrive` erases the train before it and draws after.
   - In each, the state changes keep their order. Only drawing moved past them: `draw_train` reads only
     `train_city`, and the old city's flag reads only that army's city and supply.
   - `railroad_move` holds no rule; it moved whole.
   - Unit tests: 2 new ones, so 42 in all. Lines moved without a test: none. Three lines of
     `ui\railroad.bm` are run in part, as they were in `rules\railroad.bm`: 38 (no army left in the old
     city), 45 (no capture on arrival) and 47 (the stack markers). 20 lines of the game are not run.
3. **Done, first part: `rules\city.bm`.** `city_capture` and `check_map_links` moved to `ui\city.bm`.
   Their rules are two SUBs in `rules\city.bm`:
   - `city_take (c, side, weaken_fort)`: the new owner, the city's victory points, the capital's 100
     points and its loss, and the fort's lost level. They keep their order.
   - `city_capture` now works out first whether the city is the other side's capital and whether its fort
     loses a level, then calls `city_take`, then shows the capture as before. Only drawing moved past
     the rule: `animate_city` reads only `city_owner`, and the message box and the history file read
     nothing the rule changes. The box named the capital by `side_capital`, which `city_take` sets to
     0; it names the city `c` now, which is the same city.
   - `city_fix_return_routes (count, added(), from_city(), to_city())`: Chk Links' repair of the roads.
     It adds the road back where a city has a free slot, and lists every road without a way back.
     `check_map_links` prints that list, a line for each road and the totals, as before. The wait of a
     second after each error now comes after the repair, not during it; the screen is the same.
   - Unit tests: 3 new ones, so 45 in all. Lines moved without a test: none. One line of `ui\city.bm`
     is run in part, as it was in `rules\city.bm`: line 11, the Rebels' tune. 20 lines of the game are
     not run.

   **Done, second part: `rules\army.bm`.** `army_combine`, `army_new`, `army_get_commander`,
   `army_resupply` and `army_recruit` moved to `ui\army.bm`. Their rules are nine SUBs in
   `rules\army.bm`:
   - Combining: `army_combine_start (target)` clears army 0, which gathers the armies.
     `army_combine_add (j, target, best, status)` adds one army's leader, men and experience, or says
     why it does not join. `army_combine_absorb (j)` takes its supplies and empties its slot.
     `army_combine_finish (target, best, joined)` puts the result in the best leader's slot.
   - `army_combine` keeps the menu and the loop over the side's armies, and prints each army's line
     between `army_combine_add` and `army_combine_absorb`, while the army still has its name and men.
     The old local `x`, the best rating so far, was always equal to `army_leader_rating(0)`, which
     `army_combine_add` now reads. `spin` is now `joined`. The computer's random pick of a city stays in
     `army_combine` until phase 9 reworks the menus.
   - The merged army takes its city in `army_combine_finish`, before the map is drawn, and no longer
     after it. `draw_cities`, the army's flag and the flashing frame do not read `city_army`;
     `draw_stack_markers`, which does, still comes after.
   - `army_raise (side, slot, city)`: a new army's supplies, experience, leader, size, city and price.
     `army_new` prints and draws after it.
   - `army_pick_commander (side, slot)`: the next commander. `army_get_commander` prints "No more ...
     commanders available" when it finds none.
   - `army_buy_supply (army, result)`: the supplies bought, with `result` 1, 0 for too little cash, or
     -1 for an army cut off. `army_resupply` prints by `result`.
   - `army_place_new (slot, city)` and `army_add_recruits (side, army, isolated)`: the two kinds of
     recruiting. `army_add_recruits` passes 0 to `army_recruit_bonus`, as `army_recruit` passed `empty`
     when it was 0 (`TODO.md`).
   - Callers in `ai\ai.bm` and `rules\navy.bm` now call screen parts. Steps 4 and 6 split them.
   - Unit tests: 7 new ones, so 52 in all. The two tests of the commander now call
     `army_pick_commander`. Lines moved without a test: none. 212 lines of the game are run in part and
     20 are not run, as before. Each line run in part in `ui\army.bm` and `rules\army.bm` is a branch
     that the old code did not reach either: a menu left with Esc, an army cut off, too little cash, an
     isolated city, the sound off.
