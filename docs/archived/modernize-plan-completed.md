# Done: modernizing the code of Civil War Strategy

The finished parts of `../modernize-plan.md`, archived from 2026-11-11 onward. The active plan
keeps the remaining work and current rules. The original decisions, phase table, proposed layout,
split rules and phase 11 survey were moved here on 2026-11-14. Counts and line numbers describe
the tree on the date each part was written.

## The kept bugs fixed (2026-11-13)

The user ruled on `TODO.md`'s "The game" rows at once: 22 were fixed in one batch, and three are kept
(`normal_random_number` drawing high, the pictures not shown, the train's and the cannon's pixels).
The `SELECT CASE` branches that were never reached (`sub-names.md`, "Found while reading") were fixed
with them. Each fix below names what the original did.

The menus and files:

- **Load after the first save.** `saved_games_check` (`port\files.bm`) sets `saves_exist` both ways from
  the disk. It only ever set it to 0, so Load stayed "-" until a new game.
- **Resume Saved Game with nothing loaded** (no saved game, Esc, or a save that cannot load) goes back to
  the title menu (`cws.bas`). It went on to the main menu on a black screen.
- **F7 ends the turn only at the main menu.** A new menu kind, `MENU_MAIN_KEYS` (`cws.bi`), is the main
  menu's (`menu_main`); F3 and F4 still work at every plain menu. F7 gave 99 at every plain menu, which
  SOUNDS printed as `menu_text$(99)`, Load read as a row and Save took as slot 99.
- **Save and Load and the month's commands.** Every game loaded opens Troops, Moves and Ships again; a
  save opens nothing (`menu_load_game`, `menu_save_game`). Both did so only for the menu's first row.
- **Rndom Evt** prints the setting in force (`menu_option_events`), so Esc shows what is set. It kept
  the last choice's text in a `STATIC`.
- **Attack off a city that is not the enemy's** leaves Ships open (`menu_navy_attack`). The fleet was
  marked as having acted before the city was checked.
- **The player's Build and Attack draw no random number.** Their `random_discard` calls are gone. The
  computer's Attack keeps its own.

The navy and the events:

- **Invasion with no commander left** lands no army, for the player and the computer
  (`menu_navy_invade`, `ai_navy_invade`). The player's landed in slot 0; the computer asked again
  without end. `ai_navy_invade` lost its `action` parameter.
- **A computer side with no fleet builds its first ship** whatever city 0's owner is
  (`ai_fleet_orders`). Whether it built depended on whose fleet had the last order.
- **The mercenaries** join the army in the side's capital, or else form a new army there under the
  next commander (`event_apply`, and the new `event_new_army`, `rules\events.bm`). With no commander left
  they are lost. They joined army 0. The user ruled "a new army at Richmond"; a city holds one army, so
  an army already in the capital takes them.
- **The computer's ironclad** costs two ships, as the player's does (`ai_navy_build`).

The rules:

- **`railroad_capacity`** counts the cities of the side asked about, not the player's.
- **Vary Start** may remove some of the Rebels' first six armies (`FOR k = 21 TO 26`). The loop ran
  from 21 to 6 and never ran.
- **Casualties** count for the attacker's side by `army_side` (`battle_apply_losses`). `attacker > 2`
  counted Union armies 3 to 20 as Rebels.
- **A battle takes a day of supply** from the attacker and the defender (`battle_fight`), not from
  armies 1 and 2.
- **The Balance setting's extra recruits** go to the army recruited, in `army_raise` and
  `army_add_recruits`. They went to army 0, or to a new army just before its size was set.
  `army_recruit_bonus` now takes the side, and gives the men only to the computer's side when the
  setting favors it, as `battle_strengths` does with its strength. The original tested only the
  player's side, so it would have given them to whoever recruited. `army_place_new` is gone: it only
  set `army_city`, which `army_raise` sets.
- **The computer's train to its capital** checks the capital's track (`ai_railroad`), not the last
  city of the loop before.
- **Crossing moves**: two of the computer's armies that would trade cities stay put
  (`ai_army_order`). The test compared the other army's order with this army's size.
- **An army lost** gives its supplies to the winner and 25 victory points to the winner's side
  (`turn_army_lost`). The supplies were cleared first, and the points went to the loser's side.
- **A fleet sunk in combat** gives 10 points to the winner's side (`navy_fleet_defeated`), not the
  loser's.
- **The Rebels' bonus for 35 cities** adds 100 to their own points (`turn_update_victory_points`), not
  to the Union's.
- **`SELECT CASE` in order**: `battle_losses` tests `> 800` before `> 300`, and `turn_set_move_order`
  tests `> 1000`, `> 800` and `> 400` in that order.

The tests:

- The unit tests that pinned a bug now state the rule: `TestRailroadCapacityCountsBySide`,
  `TestBattleCasualtiesBySide`, `TestBattleFightTakesSupplyFromTheArmies`,
  `TestEventMercenariesFormAnArmy`, `TestTurnArmyLost`, `TestNavyFleetDefeated`, `TestSavedGamesCheck`
  and `TestVictoryPointsKeepEightTenths`. New: `TestEventMercenariesJoinTheCapitalsArmy`,
  `TestArmyRecruitBonus` and `TestArmyRaiseGetsTheRecruitBonus`. 157 unit tests.
- 32 of the 40 scripts were recorded again. `make_scripts.py` wrote the generated ones
  again; the games now last 1 to 14 turns (`pass`) and 9 to 24 (`war`).
- Scripts written by hand that changed their steps: `options` (Esc in Rndom Evt, with a state),
  `files` (Resume with no saved game returns to the title menu; Load is offered after the first save),
  `endings` (game 3 ended at the time limit until "Three more" below; the `war` games still end with
  an army annihilated),
  `union-manassas` (the computer's second turn by rules; the Files menu opens on Load once a game is
  saved) and `navy-losses` (seed 2 for 6, so that the shore battery still sinks the ship at the first
  shot).
- Every changed line runs under the tests (`play.py coverage`). One line that ran before does not:
  `ai_fortify`'s stop for a Union computer without a fleet (`modernize-plan.md`, "Lines that no test
  runs"). 12 lines are not run, 15 before. 40 scripts pass `check` and `compare` with both compilers.

### Three more (2026-11-13)

Found after the batch; the user ruled on them the same day.

- **An outnumbered defender is halved.** `battle_strengths` tests `CASE IS < .2` before
  `CASE IS < .5`, so a defender with less than a fifth of the attacker's men has half its strength.
  The `.2` case was never reached. New test: `TestBattleOutnumberedDefender`.
- **Both sides' victory points stop at 0** (`turn_update_victory_points`). Only the Union's did, so
  the Rebels' went below 0 when they lost their capital with fewer than 100 points.
  `TestOnlyUnionVictoryPointsStopAtZero` became `TestVictoryPointsStopAtZero`.
- **The Rebel fleet off Philadelphia** holds its place half the time (`ai_pick_port`). Looked into,
  this was not a bug: the original's row 30 read a 0, and city 0 does not sail; read as city 30, the
  fleet's own port, it does not sail either. The FUNCTION now returns 30 and says so. No game changes.

Four scripts were recorded again: `navy`, `war-rebel-altmap`, `war-union-1866` (`make_scripts.py`
wrote it again: 20 turns) and `endings`, whose game 3 again ends with the Union annihilated, as it
did before the batch; its keys are back to that. 162 unit tests; 40 scripts pass `check` and
`compare`; every changed line runs, and no line stopped running.

## Scenarios in folders (2026-11-13)

`scenarios\ALTMAP.BAT` renamed six files to switch the map, on Windows only. The plan that replaced it
is `scenario-plan.md`; it was done in four commits.

- **The folders** (`2ba37f5`). Each map is a folder of `scenarios\`, `standard\` and `alternate\`, with
  `CITIES.GRD`, `CWS.INI` and `CWSLEAD.DAT`; the files moved with `git mv`, unchanged.
  `scenarios\SCENARIOS.LST` names each folder and its title. `load_scenario_list` (`port\files.bm`)
  reads it, and `scenario_file$` gives a file of the scenario in use (`scenario_now`). No screen
  changed.
- **The menu** (`f97722d`). After Start NEW Game, `menu_scenario` (`ui\main_menu.bm`) lists the
  titles; Esc goes back to the title menu, and a list of one line shows no menu. Picking another
  map runs `game_new` again. Every script that starts a new game answers the menu, and `#! altmap`
  is gone from `play.py`. The alternate map now loads after the random numbers are seeded, so its
  starting cash differs: `pass-union-altmap`, `pass-rebel-altmap`, `war-union-altmap` and
  `war-rebel-altmap` were recorded again. The user removed `ALTMAP.BAT`.
- **The saved game** (`fe4d78d`). `save_game` writes the scenario's folder as the first line, and
  `load_game` reads that scenario's leaders and map first when it differs. A save without the line
  loads as the first scenario; one whose scenario is not in the list is refused with a message on
  the Load menu's bottom line. The new script `scenario-save` saves on the alternate map and loads
  it from the standard map. `files` was recorded again for the new hashes of its saves.
- **The documents.** `TODO.md` loses the untested `ALTMAP.BAT`; `port-study.md` D5 and
  `devnotes.md` item 9 say what replaced it. Decisions 3 and 6 of `modernize-plan.md` were narrowed
  in the first commit: a change that is meant is its own commit and records again only the scripts
  that differ.

## Phase 11 step 2 (2026-11-13)

Question 1 answered: war texts go to data files. The user then asked for more than the texts: the
whole of each special event is data, so that the code does not know which war is fought.

- **`scenarios\EVENTS.DAT` holds the 18 events**, each under its name in brackets with labeled lines:
  the side it favors, its conditions (`if`), its effect, its texts, and `when`, `for`, `instead`,
  `then`, `redraw` and `listed`. Its `[events]` section holds the banner and the month's chance.
  The head of the file says what each line means.
- **`load_events` (`port\files.bm`) reads it** into the events table (`event_*` and `condition_*` in
  `cws.bi`); `game_new` calls it after the scenario. A line it cannot read ends the game at its
  start with the file, the line and the reason (`event_file_error$`). It refuses a line twice, an
  event name twice, a bracket left open, a word where a number goes, an effect with the wrong
  count of numbers, and a `listed` or `when` it does not know.
- **`event_roll` moved to `rules\events.bm`** (from `game\events.bm`) and no longer names an event.
  It goes down the favored side's rows and takes the first whose conditions hold and whose effect
  can be carried out. `event_apply` carries out one of ten effects (`EFFECT_*`). The 16 `EVENT_*`
  constants but `EVENT_NONE`, and `emancipation_done`, are gone; `event_done()` holds what has
  happened.
- **The ironclads' announcement is an event too** (`when = before`): it is tried before the roll,
  also with random events off. Its date stays the rule `IRONCLAD_YEAR` and `IRONCLAD_MONTH` of
  `cws.bi`, which the navy uses; the file repeats it, and `TestEventIroncladsMatchTheRule` checks
  that the two agree.
- **The month's chance is a line of the file**: `.005 x (year - 1860) x weight x weight, at most
  .9`. It is worked out in double precision and rounded once, as the old line was; with single
  precision at each step, 24 of the 50 values of 1861 to 1870 differed in their last bit.
  `TestEventChanceAsBefore` checks all 50.
- **The random numbers are drawn in the order of before**, so every recorded screen is unchanged.
  Three things in the file keep that order: a silent event (the Rebels' points in January 1864 and
  1865), `instead` (the furloughs for the uprising from June 1864, the riot for the shipworks), and
  `then` (Stanton's prediction after the rifles).
- **Kept as they were:** the mercenaries join army 0 (`TODO.md`); the volunteers reach five armies;
  a riot that finds no city still shows the banner.
- **Tests:** the 38 scripts pass with both compilers, and a new one, `bad-events`, starts the game
  with a file it cannot read. The unit tests reach every event by its name (`event_find`), every
  line of the reader, and files of another war: Wars of Napoleon's chance, an announcement like
  its Trafalgar, and an event whose effect is for the other side (`for`), as its Hapsburgs give
  France cash. Of the new code only one older line is run in part (`modernize-plan.md`, "Lines
  that no test runs").
- **Checked against Wars of Napoleon** (`WON2.BM`, `SUB events`). The order of the events, the
  fall-through when one cannot happen, the roll conditions and the delivery port fit as they
  are. The chance, the announcement before the roll, `for` and `{side}` were added for it. What
  it still needs is code: Trafalgar sets the fleet to 10 ships; "windfall tax revenues" add a
  random amount; a traitor gives his army to a new commander; its revolt picks the city by
  another rule; its rally grows up to 10 armies that grew; and the conditions "fleet at sea"
  and "fleet size". Those wait for that port's own phase 11.

The events' two tunes are still `PLAY` strings in `ui\events.bm`. The other 24 war-naming strings
wait on step 3; questions 2 and 3 are still open.

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

### Phases 8 to 10, commit by commit

Moved from the plan's "Where to resume" on 2026-11-13.

Phases 0 to 7 are done and committed. Phase 8's steps 1 and 2 are committed (`6eda547`, `013b8d0`).
Step 3 is committed in two parts (`70692b3`, `77ee9a6`), step 4 as `9e038a4` and step 5 as
`b67f89e`. Step 6, the computer's turn, is committed as `ae48902`, and the cleanup after it, from
the review of steps 1 to 6, as `5e27bf8`. Step 7, the special events, is committed as `c298f3a`,
and step 8, victory, as `f5ee0f0`. That ends phase 8.

Phase 9's step 1, the Utility menu, is committed as `693c078`, step 2, the Commands menu, as
`10056a5`, step 3, the Files menu, as `f831801`, step 4, the main menu, as `653e218`, and step 5,
the main module as a loop, as `83c34c8`. Step 6, the navy's commands, is committed as `aa2f80b`.
That commit does not build: it also holds the three `git mv` renames of step 7, without step 7's
`$INCLUDE` lines. Step 7, the other commands, is committed as `77e3024` and puts that right. Step
8, `menu_select` and the file renames, is committed as `4fa959d`. That ends phase 9.

Phase 10's step 1, the script and `sides`, was committed as `3043c01`, and step 2, `fleets` and
`trains`, as `ae6da81`. Both were taken back in `a04672d`, and phase 10 is closed with no records
(2026-11-12; "Why no records", under phase 10).

## Which model did which phase

Moved from the plan on 2026-11-13; only phase 11 is left of it.

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

### What it left for later phases

- **Six `GOSUB` routines** that only their own SUB uses: `crsr`, `limits` and `noadjust` in
  `menu_select` (the key loop, which phase 9 reworks), `add1s` in `army_generate_name`, `jack` in
  `draw\ships.bm` and `stars` in `game\victory_screens.bm`. Phase 9 step 8 removed the three of
  `menu_select`. The other three went with the labels on 2026-11-12 ("After the plan: the labels").
- **The main module's menus**, a web of `GOTO menu0`, `GOTO optmen` and `GOTO utile` (phase 9).
- **`calculate_battle`**, whose split parts a rule from its screen (phase 8).
- **`army_clear`** (step 4): it waited for phase 10 and stayed undone ("Phase 10" below). It was
  built on 2026-11-13 (`1f3295b`): `army_clear (army)` sets the six fields that five SUBs cleared,
  and `game_reset` keeps its own loop.

The splits of `calculate_battle` (losses, strengths) are phase 8's: they part a rule from its screen.

## Phase 8: split rules from screen, the steps done

Started 2026-11-11. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

### How a SUB is split

Moved to `modernize-plan.md`, "How a SUB is split", on 2026-11-13, because it still holds for new code.

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
4. **Done: `rules\navy.bm`.** Every SUB of the file but `navy_remove_ship` moved to `ui\navy.bm`:
   `navy_commands`, `navy_action`, the five actions, `navy_finish_move`, `navy_commerce_raid`,
   `navy_combat` and `navy_show_hits`. `navy_action` and `navy_land_army` draw nothing themselves,
   but they call screen parts. The rules are 16 SUBs and FUNCTIONs in `rules\navy.bm`:
   - Build: `navy_add_ship (side, ship$, cost)`, `navy_found_fleet (side, city, cost)` and
     `navy_cancel_new_fleet (side)`. A fleet that had ships pays in `navy_add_ship`, as before at the
     label `add2ship`.
   - Attack: `navy_bombard_army (side, index, killd)`, `navy_shore_battery (side, target, damaged)`,
     `navy_fleet_lost (side)` and `navy_blast (side, target, result)`. `navy_bombard` calls them after
     the explosion marker, which draws random numbers when the sound is on, as before.
   - Sail, Raid and Invasion: `navy_move_fleet (side, city)`, `navy_go_raiding (side)` and
     `navy_landed (side, empty)`. `navy_landed` gives back the 100 and sets the 3,500 men after
     `city_capture`, not before it; the capture reads neither.
   - `navy_note_raiding_side`: the first part of `navy_finish_move`.
   - `navy_raid_round (raider, sank)`: one round of the commerce raid. `navy_commerce_raid` keeps the
     raiding side in `raider` for its messages, since the rule may set `raiding_side` to 0 first.
   - Naval combat: `navy_ship_hits (side)` and `navy_shot_hits (side)` (FUNCTIONs),
     `navy_fleet_defeated (loser)` and `navy_retreat_port (side, target)`. The two blocks for a
     defeated fleet were the same with the sides swapped. One SUB does both, with the pursuit written
     as "the winner is the side whose turn it is", which gives the same value in each.
   - Left in the screen part for phase 9 and step 6: the flag `turn_navy_done`, the line
     `fleet_size(side) = LEN(fleet_ships$(side))` in Sail and Raid, the menus' values, and the
     computer's choices by random number (Build line 51, its port at line 83, and Attack's change to
     Sail at line 117 of the old file).
   - A new bug, kept: a fleet sunk in naval combat gives its own side 10 victory points (`TODO.md`).
   - Unit tests: 12 new ones, so 64 in all. Lines moved without a test: none. Two rewritten lines were
     not run in full by a script: the capital that stays loyal, and one of the pursuit branches. The
     tests `TestNavyBlastCapitalAndNeutral` and `TestNavyFleetDefeated` run them. The three lines not
     run are the same three as before, now `ui\navy.bm` 76, 309 and 350. 209 lines of the game are run
     in part (212 before) and 20 are not run.
5. **Done: `rules\turn.bm`.** The eight mixed SUBs moved to `ui\turn.bm`: `turn_date_and_supply`,
   `turn_resolve`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`,
   `turn_defender_retreats`, `turn_army_surrenders` and `turn_enter_city`. `turn_resolve` holds no rule
   of its own; it moved whole. The rules are 13 new SUBs in `rules\turn.bm`, beside
   `turn_collect_income`, `turn_set_move_order` and `turn_update_victory_points`:
   - Supply: `turn_advance_month`, `turn_army_supply (i, blockaded, starved)` for one army, and
     `turn_strength_ratio`. `turn_date_and_supply` keeps the loop over the armies, so that each army's
     messages and the `COLOR` between them come where they did. The old side variable `s` started as
     the Union and turned to the Rebels at their first army, so it was always `army_side(i)`, which the
     rule now uses.
   - Moving and fighting: `turn_army_marches (active, starved)`, `turn_battle_experience (win)`,
     `turn_withdraw (active)`, `turn_defender_halts (defend, halted, old_order)`,
     `turn_retreat_city (target, s, move2)`, `turn_retreat_to (defend, move2)`,
     `turn_army_lost (index, active)`, `turn_occupy (active, target)`, `turn_raze_fort (c)` and
     `turn_army_forages (active)`.
   - `turn_defender_halts` returns the defender's old order, so that the screen can erase its line after
     the rule has cleared it. The marker reads only the cities and `city_army`.
   - Left in the screen part: the attacker's and the defender's city and order set just before
     `animate_army`, which reads them to draw the march, and the computer's choice to raze a fort
     (`opt_realism` and `city_y(c) > 150`, for step 6 or phase 9).
   - A new bug, kept: an army that surrenders or is crushed gives 25 victory points to its own side
     (`TODO.md`).
   - Unit tests: 10 new ones, so 74 in all. Lines moved without a test: none. The defender's lost order
     after the attacker withdrew was not run in full by a script; `TestTurnWithdrawAndHalt` runs it.
     The two lines not run are the dead `CASE` arms of `turn_set_move_order`, now `rules\turn.bm` 163
     and 165. 208 lines of the game are run in part and 20 are not run.
6. **Done: `ai\ai.bm`.** The computer's decisions stay in `ai\ai.bm`. Only their own screen lines moved
   out, each block into a SUB of `ui\ai.bm` called at the same point: `draw_ai_fort (target)` from
   `ai_fortify`, `draw_ai_plan (i, c)` from `ai_army_orders`, `draw_ai_drill (i)` from `ai_drill` and
   `draw_ai_funds (side)` from `ai_recruit`.
   - The rule for `ai\` (user, 2026-11-12): it decides and draws nothing itself. It carries out an order
     through the same SUBs as the player's commands: `navy_commands`, `army_combine`, `army_recruit`,
     `army_resupply`, `railroad_move`, and `menu_recruit_cities` for the list of cities. Those SUBs are in
     `ui\` until phase 9 gives the commands a layer of their own. The computer cannot decide its whole
     turn first and show it after: some drawing draws random numbers, so its choices must come at the
     same moments as before.
   - `ai_turn` moved to `ui\turn.bm`, beside `turn_resolve`, which calls it. It decides nothing itself:
     it is the computer's half of the month, special events, the header line, each decision area in
     turn, and a redraw of the fleets.
   - Two choices became pure SUBs in `ai\ai.bm`, so that unit tests can run them (the review's finding
     1, 2026-11-12). `ai_fortify_pick (who, target)` is the city to fortify, the loop after the label
     `city2:`. It sets `target` to 0 before its first random draw, so that its early exit fortifies
     nothing, as the old `EXIT SUB` did; its `GOTO capital` is now `GOTO picked`, a label at its end.
     `ai_army_order (who, i, ordered)` is one army's move order, the old loop's body, with its lines
     unchanged. Each `GOTO deadman` goes to a label at its end, where `ordered` is still 0.
   - `ai_recruit_pick` lost its `LOCATE 14 + i, 69`. The loop left the cursor at row 14 plus the length
     of the list, so `draw_ai_funds` does that one `LOCATE`, just before the pick.
   - One rule: `army_recruit_cities (side)` in `rules\army.bm`, the list of recruiting cities, which
     draws random numbers. That list was `menu_recruit_cities` (`ui\orders.bm`), which keeps its name and
     now sets the menu's color and calls the rule. The rule calls `menu_bubble_sort`, which draws
     nothing.
   - A first version moved all eight SUBs to `ui\ai.bm`, because they call SUBs that draw. The user
     asked whether that was really screen code; it was not, and this version replaced it before commit.
   - Unit tests: 4 new ones, so 78 in all. Lines moved without a test: none. The lines not run are the
     same as before, now `ai\ai.bm` 23 (a dead `GOTO capital`), 105 and 106 (a fleet at sea in
     `ai_fleet_orders`) and 212 (in `ai_evaluate_move`). 206 lines of the game are run in part and 20
     are not run.

**Done: the cleanup after step 6.** A review of steps 1 to 6 (2026-11-12) found no change of behavior,
but four things to make even. The user took the pragmatic engineer's plan: one commit, before step 7.
- **Game state in the screen parts.** The rule is now in "How a SUB is split" (`modernize-plan.md`): a
  screen part changes no game state, except the menu's variables, the lines tangled with phase 9's
  menus, and the inputs of `animate_army`. A scan of the eight `ui\` files that phase 8 made
  (`tests\out\scratch\p8_state_in_ui.py`) found only those, so no code moved.
- **Three result codes got constants** in `CWS14.BI`: `COMBINE_SKIPPED`, `COMBINE_TOO_LARGE` and
  `COMBINE_JOINED` for `army_combine_add`, `SUPPLY_CUT_OFF`, `SUPPLY_NO_CASH` and `SUPPLY_BOUGHT` for
  `army_buy_supply`, and `BLAST_FIRM`, `BLAST_LOYAL` and `BLAST_NEUTRAL` for `navy_blast`. They are
  proposed in `constants.md`, section 5, for the user to approve.
- **Parameters got names of their own** (decision 11), in place of the old locals' names they kept so
  that lines could move unchanged: for example `killa` and `killd` became `attacker_losses` and
  `defender_losses`, `turn_army_lost (index, active)` became `(army, winner)`, and `ai_army_order`'s
  `i` became `army`. 25 SUBs, renamed by `tests\out\scratch\rename_in_sub.py`, which works on whole
  names outside strings and comments and refuses a name that is already used or shared.
- **Tests that pin a branch.** The test of the shore battery that accepted either result became two,
  one for each branch. A new test runs the losing round of a commerce raid, and one compares an
  ironclad's shots with a wooden ship's. Each test of a branch tries seeds until the draw goes its way,
  then checks that branch exactly.
- Unit tests: 81. 205 lines of the game are run in part and 20 are not run.

7. **Done: `special_events` and `event_riot`.** Both moved to the new `ui\events.bm` under their names;
   their rules stay in `game\events.bm`, the war's own file:
   - `event_roll (event, variant, who)` rolls the month's event and carries out what it does. Its lines
     are those of `special_events` without the messages: each `CALL scribe_message(...)` became
     `event = EVENT_...`, and `GOTO dull1` and `GOTO dull2` now go to two labels at its end. `event` is
     one of 16 constants, `EVENT_NONE` to `EVENT_STANTON` (`CWS14.BI`, proposed in `constants.md`).
     `variant` picks the text of the mercenaries (French or British) and of the uprising (three).
   - `special_events` calls it, then shows the event: the "SPECIAL EVENT..." line, the message from a
     `SELECT CASE` on `event`, and the tune of the side. Phase 11 can put the texts in a data file
     keyed by `event`.
   - `event_riot_city (who, city)` picks the city that riots and makes it neutral. `event_riot` prints
     the riot and the box after it.
   - Nothing that the events draw reads what they change before the message, and no drawing draws a
     random number, so all the draws now come before the messages, in the same order.
   - The riot's constant is `EVENT_RIOTS`, not `EVENT_RIOT`: BASIC ignores case, and `event_riot` is
     the SUB's name.
   - Rifles were always followed by Stanton's prediction, which falls through after them. That is now
     `EVENT_RIFLES`, which shows both messages.
   - A new bug, kept: the mercenaries join army 0 (`TODO.md`).
   - Unit tests: 6 new ones, so 87 in all. They give `event_roll` its draws through `script_dice$`, as
     `CWS_DICE` does under a script. Lines moved without a test: none. All 58 lines of `ui\events.bm`
     run. 204 lines of the game are run in part and 20 are not run.
8. **Done: `rules\victory.bm`.** `check_victory_conditions`, `victory_warnings`, `end_game` and
   `hall_of_fame` moved to the new `ui\victory.bm`. Their rules are 11 SUBs and FUNCTIONs in
   `rules\victory.bm`:
   - `victory_forces (x, y)`, the men in the field, `victory_time_near`, and
     `victory_rule_met (i, x, y, j)`, the rule a side has met. `victory_rule_met` keeps its lines
     unchanged; `GOTO finis` goes to a label at its end, and `j` is 0 there when no rule was met.
     `check_victory_conditions` keeps the loop over the two sides and the messages.
   - `victory_near_cities (i)`, `victory_near_income (i)` and `victory_near_force (i, x, y)`: the three
     warnings of `victory_warnings`.
   - `victory_play_on (j)`, `victory_won (i, j)` and `victory_technical_points`: the state that `end_game`
     changed between its menus and screens. `victory_won` also sets `game_over`, which `hall_of_fame` set
     after its last key. Only the main module reads `game_over`, after `check_victory_conditions` returns.
   - `hall_of_fame_place (s, hall_score())` and `hall_of_fame_insert (s, i, name$, hall_name$(),
     hall_score())`: the place a score earns, and the entry put in it. The entries now move down after
     the commander's name is read, not before; nothing shows them in between.
   - One new line run in part: `IF i = 0 GOTO foun` in `hall_of_fame`, for a side that earns no place.
     The scripts start from an empty Hall of Fame, where every score earns one.
     `TestHallOfFamePlaceAndInsert` tests the rule.
   - Unit tests: 8 new ones, so 95 in all. Lines moved without a test: none. 204 lines of the game are
     run in part and 20 are not run.

**Phase 8 is done.** Nothing in `rules\`, `ai\` or `game\events.bm` draws, prints, plays or reads a key
itself (`tests\out\scratch\p8_mixed.py`). What it left for phase 9: the commands that sit in `ui\`, the
lines tangled with the menus ("How a SUB is split", `modernize-plan.md`), `load_game` and `save_game`
in `port\`, and the computer's one-line choices in the screens. The scripts pass on the recordings of
phase 7, with both compilers, and the unit tests went from 33 to 95.

## Phase 9: the menus, the steps done

Started 2026-11-12. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

### How a menu is split

Moved to `modernize-plan.md`, "How a menu is split", on 2026-11-13, because it still holds for new code.

### Steps

The menus come first, from the simplest. The main module's loop follows, when no menu is left in
it. The commands that both the player and the computer give come last. They are the hardest:
their random numbers must stay in order.

1. **Done: the Utility menu.** The 229 lines from `utile:` to its `END SELECT` left the main module
   for the new `ui\options.bm`. The main module's `CASE 8` is now `chosit = 29` and
   `CALL menu_utility`.
   - `menu_utility` fills and shows the menu in a `DO` loop. `GOTO utile` is the loop's next turn, on
     the row just chosen. `GOTO menu0` is `EXIT SUB`: after Side, after Chk Links, on Esc, and on Esc
     in the SOUNDS or the Balance menu.
   - Eleven entries have a menu SUB each: `menu_option_side`, `menu_option_players`,
     `menu_option_graphics`, `menu_option_sound`, `menu_option_display`, `menu_option_balance`,
     `menu_option_events`, `menu_option_january`, `menu_option_realism`, `menu_option_history` and
     `menu_option_aggression`. End Cond, Vary Start and Chk Links call the SUBs they called before.
   - Twelve rule SUBs in `rules\setup.bm` change the settings (`option_swap_side` to
     `option_next_aggression`; the list is in `file-layout.md`). `victory_toggle_rule`
     (`rules\victory.bm`) turns a victory rule on or off for `menu_victory_conditions`.
   - Each setting is now changed before its message, not in the middle of it. No message reads a
     setting that changes after it.
   - `t$`, the text of the last Random Events choice, was a variable of the main module. It is
     `STATIC` in `menu_option_events`, so an Esc there still shows the choice before (`TODO.md`).
   - The line `IF opt_players = PLAYERS_TWO THEN menu_text$(2) = ""` is kept, though the next line
     sets `menu_text$(2)` again.
   - Found while reading, not tried: F7 in the SOUNDS menu prints `menu_text$(99)` (`TODO.md`).
   - Unit tests: 9 new ones, so 104 in all. Lines moved without a test: none. All 161 lines of
     `ui\options.bm` run, 6 of them in part. 204 lines of the game are run in part and 20 are not
     run, as before.
2. **Done: the Commands menu.** The 102 lines from `optmen:` to its last `GOTO optmen` left the main
   module for `ui\orders.bm`. The main module's `CASE 7` is now `chosit = 28` and
   `CALL menu_commands`.
   - **A script first.** `refusals-rebel` plays the refusals that no test ran, from a prepared save
     with the Rebels short of cash: "Not enough money for fort", "Cannot move capital", "Too small
     to detach", an army that "has reached maximum improvement through drilling", and "No armies
     remain eligible for drills". It was recorded on `693c078`, before the menu changed.
   - `menu_commands` is a `DO` loop. `GOTO optmen` is its next turn and `GOTO menu0` is `EXIT SUB`.
     Detach and Army Drill are `menu_army_detach (again)` and `menu_army_drill (again, drilled)`.
   - **The row the menu comes back on** was set three ways, and each is kept. Most commands set
     their own row. Capital came back on row 2, Fortify: the row was what `menu_city_select` left
     in `menu_choice`, and its Enter is row 2. An army that cannot drill further came back on row
     1, and so did Cancel, whose row was added to `MENU_START` twice.
   - The menus of `ui\orders.bm` change no state now. Seven rule SUBs do it:
     `army_set_order`, `army_free_leader` and `army_take_leader` (`rules\army.bm`),
     `city_build_fort`, `capital_move_pay` and `capital_move_to` (`rules\city.bm`), and
     `turn_set_moves_done` (`rules\turn.bm`).
   - `menu_army_relieve` printed the new leader's name between the changes. It now reads the name
     first, calls `army_take_leader`, and prints.
   - `ai_fortify` (`ai\ai.bm`) still builds its fort in its own lines. It marks the army busy
     between the fort and the payment, so it does not call `city_build_fort`.
   - The main module no longer declares `index`, `empty` and `target`.
   - Unit tests: 5 new ones, so 109 in all. 34 scripts. One line moved without a test: Detach when
     no commander is left (`IF empty = 0 THEN EXIT SUB` in `menu_army_detach`, `GOTO menu0`
     before). 198 lines of the game are run in part (204 before) and 20 are not run.
3. **Done: the Files menu.** The Files menu (`filex:`, `loader:`) and the Quit menu (`rusure:`) left
   the main module for the new `ui\files.bm`. The main module's `CASE 9` is now `chosit = 30`,
   `CALL menu_files(action)` and two tests of `action`.
   - `menu_files (action)` shows the menu and tells the main module what follows: `FILES_BACK`,
     `FILES_NEW_GAME` (`GOTO newgame`) or `FILES_QUIT` (`END`). It shows again only for Load with
     no saved game, as `GOTO filex` did. `menu_quit (action)` is the Yes or No menu.
   - `load_game` and `save_game` (`port\files.bm`) are split. `menu_load_game` and
     `menu_save_game` (`ui\files.bm`) hold the menus of saved games, "Loading" and "Saving", and
     the map drawn after. `load_game (slot)` and `save_game (slot)` read and write the files and
     show nothing, so the unit tests call them.
   - The title menu's Resume Saved Game calls `menu_load_game`, where it jumped to `loader:`.
   - The 40 dots after "Loading" and "Saving" were printed one for each city read or written. They
     are printed together after the file work. The screen is cleared right after in both cases.
   - `saved_games_check` (`port\files.bm`) sets `saves_exist` to 0 when no saved game is found, and
     `turn_reset_commands` (`rules\turn.bm`) opens Troops, Moves and Ships again.
   - A bug found and kept: the main module tested `menu_choice = 1` after the menu of saved games
     had changed it, so the month's commands open again after a save in slot 1, and after a load
     only of the Load menu's first game (`TODO.md`).
   - Unit tests: 3 new ones, so 112 in all. One saves a game and loads it again in a folder of
     its own. Lines moved without a test: none. 196 lines of the game are run in part and 20 are
     not run.
4. **Done: the main menu and its own entries.** They left the main module for the new
   `ui\main_menu.bm`. What stays under `menu0:` is `CALL menu_main(chosit)` and a `SELECT CASE`
   with one to four lines for each entry.
   - `menu_main (start)` draws the top bar, fills the menu and shows it. `start` is the main
     module's `chosit`, passed by reference: an entry shown as "-" still moves it, as before.
   - `menu_main_railroad` is the Railroad entry: the train's picture, the capacity line and
     `railroad_move`, or "Railroad is already carrying". `menu_main_end_turn (ended)` is the Yes or
     NOT YET menu. `menu_main_inform` is the reports and the armies' move lines drawn again.
   - Troops, Moves and Ships keep their lines in the main module. Each calls a menu SUB that
     was there already (`menu_army_recruit`, `menu_army_move`, `navy_commands`).
   - Two rule SUBs in `rules\turn.bm` hold the state the main menu changed:
     `turn_check_commands` (the Union plays when a two-player game has no side; Ships closes
     without a fleet or the price of a ship) and `turn_close_recruiting`. `endrnd:` calls
     `turn_reset_commands`, which step 3 added.
   - The main module no longer declares `fin`, `x`, `y`, `z`, `limit` and `star`. It is 268 lines,
     of which 113 have a statement.
   - Unit tests: 1 new one, so 113 in all. Lines moved without a test: none. 195 lines of the
     game are run in part and 20 are not run.
5. **Done: the main module is a loop.** `CWSTRAT.BAS` has no label, `GOTO` or `GOSUB` left. It is
   128 lines: the declarations, two nested `DO` loops, the `DATA` of the map's letters and the
   `$INCLUDE` lines. It was 745 lines when the plan began.
   - **The outer loop is a game**: `game_new`, `show_title`, `script_start`, `menu_title`, then a
     saved game or `show_new_game`. **The inner loop is one main menu and its command.** A flag
     `ended` says the turn ended (End Turn's Yes, or F7), and `new_game` leaves the inner loop
     (New Game in the Files menu, or the game is over).
   - **After a turn ends**: `turn_reset_commands`, then `turn_next_player (month_over)`
     (`rules\turn.bm`). In a two-player game the Rebels' turn follows the Union's and no month is
     played. Otherwise the month is played: the history line, `turn_resolve`,
     `turn_collect_income` and `check_victory_conditions`, in the lines they had.
   - `game_new` (`rules\setup.bm`) is the start of a game: `game_reset`, `load_scenario`,
     `game_apply_settings`, `set_union_advantage` and `load_cities`. The two random draws for the
     sides' cash are still the first of a game and still come before `script_start`.
   - `show_title`, `menu_title` and `show_new_game` are in `ui\main_menu.bm`, and
     `history_start` in `port\files.bm`. `show_title` reads the map's letters from the main
     module's `DATA` with `RESTORE` and `READ`; both compilers accept that in a SUB.
   - **Three calls changed places.** `set_union_advantage` and `load_cities` now come before the
     title screen, and `clear_bottom_line` after `script_start`. The mountain picture and the
     map's letters are loaded after the settings are applied. None of these draws a random
     number or reads what the other changes.
   - **Dropped, each without effect:** `a$ = COMMAND$: IF a$ <> "" OR replay > 0 GOTO notitle2`
     (both ways led to the next line); `menu_choice = 0` and the test of it in the title tune's
     line; `ON ERROR GOTO 0` (nothing sets a handler); and the loop that cleared `army_city()`
     when a game is over, just before `game_reset` clears it.
   - **Kept:** `chosit`, the row the main menu starts on, is not reset for a new game. After New
     Game in the Files menu, the new game's first main menu starts on Files.
   - Troops keeps a one-line `IF ... ELSE`: its refusal, Troops chosen while it shows "-", is
     run by no script, and as a line of its own it would be a 21st line not run.
   - Unit tests: 4 new ones, so 117 in all. Lines moved without a test: none. 194 lines of the
     game are run in part and 20 are not run.
6. **Done: the navy's commands.** `navy_commands` and its five actions served the player and the
   computer through one parameter, `action`. Each is now three parts, in three folders.
   - **The player** (`ui\navy.bm`, new): `menu_navy_commands` shows the Ships menu and calls
     `menu_navy_build`, `menu_navy_attack`, `menu_navy_sail`, `menu_navy_raid` or
     `menu_navy_invade`. `menu_navy_combat` is the sea fight that asks before each volley.
   - **The computer** (`ai\ai.bm`): `ai_navy_orders` takes an order and calls `ai_navy_build`,
     `ai_navy_attack`, `ai_navy_sail`, `ai_navy_raid` or `ai_navy_invade`.
   - **The commands** (`commands\navy.bm`, the first file of the new folder, moved there from
     `ui\navy.bm` with `git mv`): `navy_ship_joins`, `navy_fleet_founded`, `navy_bombard`,
     `navy_sail_to`, `navy_start_raid`, `navy_land_army` and `navy_combat_auto`, the fight that
     does not ask. Nothing in the folder opens a menu or reads a key. The sea fight is four
     parts that both fights use: `navy_combat_begin`, `navy_combat_draw`, `navy_combat_volley`
     and `navy_combat_retreat`.
   - **How each action was split.** The old SUB was read twice, once with `action` as the
     player's 0 and once as the computer's order. The computer's side is never `current_side`
     (`ai_turn` takes the other side), so each test of `side = current_side` went to one half.
   - **Two random numbers that the player uses up.** `IF action = NAVY_BUILD AND RND < ...` in
     Build and `IF action = NAVY_ATTACK AND ... AND RND > .5` in Attack drew a number for the
     player too: BASIC works out both sides of an `AND`. `menu_navy_build` and
     `menu_navy_attack` call `random_discard` (`rules\navy.bm`) there, so a game's numbers stay
     in order. The computer's Attack draws a second number when it thinks of sailing instead.
   - **Of the three lines phase 8 left, one could go.** `turn_navy_done = 1` is now
     `turn_set_navy_done`, called by the player's menus only. `city_owner(0) = side` stays, as
     `navy_mark_side`: `ai_fleet_orders` reads city 0's owner in a later month, as the last
     order left it. `fleet_size(side) = LEN(fleet_ships$(side))` stays, as `navy_count_ships`:
     it was not shown that the count and the list always agree (Vary Start draws the count and
     then builds the list; `navy_fleet_lost` clears the list only).
   - Other rules: `navy_has_ironclads`, and `navy_list_shipyards` and `navy_list_ports`, which
     fill the Port and To menus for the player and the computer.
   - **Names.** `navy_sail` and `navy_raid` cannot be SUBs: BASIC ignores case, and `NAVY_SAIL`
     and `NAVY_RAID` are constants. `NAVY_ASK` is gone.
   - **Two scripts first**, recorded on `83c34c8` in a copy of that commit. The split showed
     what the coverage had hidden: lines that only one of the two had run. `navy-build` is the
     player's Ships menu without a fleet, a new fleet through the Port menu, a sea fight that
     the player attacks in, and the refusals of a fleet at sea. `navy-raid-back` is the
     computer's fleet pursuing the player's raiders, then raiding in answer.
   - Kept, and now in `TODO.md`: the computer's ironclad at a wooden ship's price, Attack on a
     city that is not the enemy's closing Ships for the month, and Invasion with no commander
     left.
   - `play.py` hashes the folder `commands` with the other sources.
   - Unit tests: 4 new ones, so 121 in all. 36 scripts. Lines moved without a test: none. 193
     lines of the game are run in part and 18 are not run: the two unreachable `GOTO`s of
     `navy_combat` are gone, the computer's "no port for a first ship" is part of a line now,
     and `ai_navy_raid` has one new line that nothing can reach.
7. **Done: the other commands.** Three more SUBs chose between the player and the computer with
   `side = current_side`. Each is split, and the commands moved to `commands\`.
   - **Join.** `army_combine` is `menu_army_combine` (the new `ui\army.bm`) for the player and
     `ai_combine` (`ai\ai.bm`) for the computer, which picks a city at random.
     `army_list_combine_cities` (`rules\army.bm`) fills the list for both. The command is three
     parts in `commands\army.bm`: `army_combine_gather`, `army_combine_done` and
     `army_combine_redraw`. The player's menu pauses between the last two, and says so when no
     army joined; the computer does neither.
   - **The train.** `railroad_move` is gone. The player's half is in `menu_main_railroad`
     (`menu_railroad`, `railroad_start`, the pause). The computer's is `ai_railroad_orders`.
     The train's arrival at the start of the month's moves calls `railroad_arrive` in
     `turn_resolve`, with the pause for the player's side. `railroad_finish` clears the panel
     and the bottom line for all three.
   - **Raze.** The Raze menu is `menu_raze_fort` (`ui\army.bm`), and the computer's choice is
     the FUNCTION `ai_razes_fort`. `turn_enter_city` no longer jumps from the player's Yes into
     the computer's block.
   - **Moved with `git mv`:** `ui\army.bm`, `ui\city.bm` and `ui\railroad.bm` to `commands\`.
     `check_map_links`, a printed report, went from `ui\city.bm` to `ui\reports.bm`.
   - **Left in `ui\`:** the month's moves (`ui\turn.bm`) and the battle (`ui\battle.bm`). They
     are not orders: they play the month and ask the player on the way (the Retreat menu, "hit
     any key"). `menu_army_retreat` keeps its test of whose army retreats, since a menu for the
     computer's army makes no sense; the computer's choice is the rule `turn_retreat_city`.
     Recruiting was split in phase 7 (`menu_army_recruit`, `ai_recruit`, `army_recruit`).
   - **A script first**, recorded on the code before this step: `join`. No script had the
     player combine armies with success, and none had a train of the computer's arrive in the
     computer's turn; a prepared save gives both.
   - **Commit `aa2f80b` (step 6) does not build.** It took this step's three `git mv` renames
     from the index, without the `$INCLUDE` lines that follow them. This step's commit builds.
   - **A check that varies under load.** With four jobs, `play.py compare` three times found
     the two builds apart at the Hall of Fame's name prompt (`options`, once `rebel`): the
     cursor's "on" or "off" in the QB64pe build's state. Alone, with two jobs, and in a fourth
     run with four jobs the scripts passed. The game's code at that prompt did not change.
   - Unit tests: 2 new ones, so 123 in all. 37 scripts. Lines moved without a test: none. 188
     lines of the game are run in part and 18 are not run.
8. **Done: `menu_select` and the file renames.** The last `GOSUB` routines of the menus are gone,
   and the main program has the name of the layout.
   - **The key loop.** `menu_select` was a web of `GOTO sel1`, `GOTO called` and `GOSUB crsr`.
     It is now a `DO` loop for each highlighted row, with a `DO` loop inside that waits for a
     key that does something. `crsr` is that inner loop. `noadjust` is one line in its place.
     `limits` is two lines at the end of `menu_arrow_key`, a new SUB that moves the row for
     Up, Down, PgUp and PgDn and handles F3, F4 and F7 at a main menu. The unused label
     `remenu:` is gone.
   - **One `GOSUB limits` dropped:** the one after a letter that chooses a row. It did not
     change the row, which is always inside the menu there.
   - **A script first**, recorded on the code before this step: `menu-keys`. No script pressed
     PgUp or PgDn, or Down on a menu's last row. At the main menu it presses PgDn, Down, PgDn
     and PgUp.
   - **The renames,** with `git mv`: `CWSTRAT.BAS` to `cws.bas` and `CWS14.BI` to `cws.bi`. The
     build (`.github\workflows\build.yml`), the README, the build line of `devnotes.md`,
     `play.py`, the include of `rules_test.bas`, and the comments in `port\` that name them
     follow. The documents that describe the code as it was (`devnotes.md` past its build
     line, `port-study.md`, `sub-names.md`, `constants.md`) and the tools of phases 4 to 6 in
     `tools\refactor\` keep the old names.
   - Unit tests: 123, none new. 38 scripts. Lines moved without a test: none. 185 lines of the
     game are run in part and 18 are not run. That ends phase 9.

## Phase 10: records, the steps done

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

`army_clear` (phase 7, step 4) waited for this phase. It stayed undone, for the reason above: the
places that clear an army did not clear the same fields. It was built on 2026-11-13 (`1f3295b`)
for the six fields they share ("What it left for later phases", under phase 7).

### Steps

1. **Done: the script, and `sides`.** The eight arrays of a side are one record:
   `sides(s).name`, `.capital`, `.cash`, `.income`, `.city_count`, `.victory_points`,
   `.battles_won` and `.casualties` (a LONG). `cws.bi` has the `TYPE side_type` block and
   `DIM SHARED sides(2) AS side_type`, and the eight arrays are gone from its `COMMON SHARED`
   and `DIM SHARED` lines.
   - **The script,** `tools\refactor\make_records.py`, rewrote 437 uses in 26 files. It reads the
     record and field names from `variable-names.md`. `report` shows what it would do; `apply`
     refuses when a use is shadowed, has no index, or a record name is taken.
   - **`ai_fortify`'s local `side_cash`.** The SUB declares a scalar `side_cash`, always 0, and
     reads it once (`side_cash < 222`), beside the shared `side_cash(who)`. In BASIC they are two
     variables. The script rewrites the indexed uses and leaves the scalar as it is.
   - **Lines that no test runs:** none of the 18 has a field of a side, so none changed.
   - **A first unit test run timed out 15 tests,** right after the change, when each test's
     program was new. The next two runs passed all 123 in about 23 seconds.
   - Unit tests: 123, none new. 38 scripts, unchanged recordings, both compilers.
2. **Done: `fleets` and `trains`.** A side's fleet is `fleets(s).ships` (a STRING), `.size` and
   `.city`. Its train is `trains(s).army`, `.from_city`, `.city` and `.capacity`. `cws.bi` has
   `TYPE fleet_type` and `TYPE train_type`, declared on the line of `sides(2)`. The seven arrays
   are gone from its `COMMON SHARED` and `DIM SHARED` lines.
   - **The script** rewrote 370 uses in 20 files, with no shadowed or bare use.
   - **Lines that no test runs:** none of the 18 is in the diff, so none changed.
   - Unit tests: 123, none new, all passed on the first run. 38 scripts, unchanged recordings,
     both compilers.
3. **Taken back: `sides`, `fleets` and `trains`** (user, 2026-11-12). `cities` and `leaders` were
   also built (578 uses, all tests passing) and never committed. The records did not make the
   code better: nothing copies or clears a whole city, side, fleet or train, so a record only
   changed the spelling and made lines longer. Only armies become a record ("Only armies" in
   `modernize-plan.md`).
   - The source files are again what they were at `4fa959d`, the commit before step 1.
   - Kept: `tools\refactor\make_records.py`, for the armies.
   - `variable-names.md`: the "Record field" column names a record for the armies only.
   - Unit tests: 123. 38 scripts, unchanged recordings, both compilers.
4. **Closed with no records** (user, 2026-11-12). The army record was not built. No line copies
   or clears a whole army, so it too would only change the spelling of 842 uses ("Why no
   records" above). The seven army rows of `variable-names.md` now say
   "(stays an array)" as well, and `make_records.py` stays for a later change or another port.
   `army_clear` (phase 7, step 4) stays undone. No code changed.

## After the plan: the labels

**Done (2026-11-12): the labels.** The game had 148 lines with `GOTO` or `GOSUB` in 19 files.
7 are left, all in `menu_city_select` (`local-names.md`, Part 2), and no `GOSUB`. The work was
two steps: the labels that only skip, then nine SUBs whose jumps made a loop or a branch.

The first step:

- **A jump to the end of a SUB is `EXIT SUB`:** `victory_rule_met` (9), `ai_army_order` (7),
  `event_roll`, `menu_city_fortify`, `menu_army_select`, `menu_army_move`, `draw_map_marker`,
  `draw_train_box`, `city_update_occupier`, `ai_fortify_pick`.
- **A jump to a loop's `NEXT` is `_CONTINUE`,** the first use of it in the game: `ai_railroad`
  (6), `ai_evaluate_move`, `ai_fortify_pick`, `city_nearby_enemy_strength`, `ai_pick_port`,
  `army_recruit_cities`, `menu_supply`, `report_armies`, `hall_of_fame`, `draw_cities`,
  `draw_fleets`, `draw_train_box`, `turn_date_and_supply`. A jump to the line after `NEXT` is
  `EXIT FOR`.
- **A jump over a few lines is an `IF` block:** `ai_fleet_orders`, `ai_army_order`,
  `army_recruit`, `menu_army_move`, `turn_defender_retreats`, `turn_enter_city`,
  `special_events`, `animate_army`, `draw_map`, and `end_game`'s three victory screens.
  `draw_fleets` picks the fleet's place with `SELECT CASE`.
- **A jump back is a loop:** `turn_army_forages`, `menu_army_relieve`, `menu_railroad`,
  `menu_victory_conditions`, the commander's name in `hall_of_fame`, and the Capitol's three
  wings in `draw_union_victory` (a `FOR`).
- **`event_roll` has no label left.** Each event is an `IF` block that ends in `EXIT SUB`. The
  loan and the cotton each add the cash in their own block. The tests are the old ones turned
  round (`> .2 OR` became `<= .2 AND`), so the draws come in the same order.
- **A jump out of an inner loop to the outer loop's `NEXT` sets a flag:** `enemy_bound` in
  `ai_evaluate_move`, `linked` in `city_fix_return_routes`. `ai_evaluate_move` sets
  `road_count = 6` before its loop, not after it.
- **The three `GOSUB` routines:** `add1s` is `STRING$(ones, "I")` after the `SELECT CASE` of
  `army_generate_name`. `jack` is a new SUB, `draw_ship_jack (side)` (`draw\ships.bm`). `stars`
  is in line in `draw_rebel_victory`, where its one `GOSUB` was.
- **Three labels that nothing jumped to are deleted:** `move9`, `movopt`, `counter`.

The second step, the nine SUBs:

- **`ai_fortify`** picks the capital or calls `ai_fortify_pick`, then fortifies in a `DO` loop
  that picks again at its end. The test that ended it is turned round (`3 * RND <= ... OR`), so
  it draws its number as before. The line that nothing reached, `IF city > 0 GOTO capital`, is
  deleted.
- **`ai_raise_forces`:** two jumps are `EXIT SUB`; `ship_reserve` is still 0 there, so the line
  they skipped to added nothing. The third jump only skipped `ai_recruit` when the cash was
  under `COST_RECRUIT`. It is dropped: `ai_recruit` makes that test in its first line.
- **`ai_evaluate_move`:** the score for a city of the player's is two `IF`s, one for an empty
  city and a block for a city with an army.
- **`army_recruit_cities`:** the month's saved list sorts the menu and leaves (`EXIT SUB`). The
  lines it jumped to did no more than that for a saved list.
- **`navy_bombard`:** the shore battery fires in `DO UNTIL city_fort(city) = 0`.
- **`navy_commerce_raid`:** a `DO` loop that runs again (`again = 1`) when the raiders lost a
  ship and have one left.
- **`navy_combat_volley`:** the shots are a `DO` loop that ends when a ship has no hits left.
  `struck` is the side of that ship.
- **`turn_attack`:** a `DO` loop over the defenders, with an `ELSE` for the loser that is not
  crushed.
- **`end_game`:** the jump back into an `IF` block is gone. Its lines are a new SUB,
  `end_game_play_on (rule)` (`ui\victory.bm`), called from both menus.

Both steps:

- **Lines that no test runs:** 18, as before, but not the same ones. `ai_fortify`'s dead line
  is deleted. `ai_fleet_orders`' start of the Union's first fleet was the `THEN` part of a
  one-line `IF` and is a line of its own now; its statements did not change. `event_roll`'s
  England's ships for a Rebel fleet in port was rewritten without a test, so it got one:
  `TestEventEnglishShipsJoinFleetInPort`. 178 lines are run in part. One of them holds a
  changed statement that no test runs: the `EXIT SUB` on the first line of `ai_raise_forces`,
  after the Union computer's first ship. The `GOTO isok` it replaced was not run either.
- Unit tests: 124, one new. 38 scripts, unchanged recordings, both compilers.

**Done (2026-11-12): the last labels.** `menu_city_select` (`ui\orders.bm`) was the last SUB with
`GOTO`: 7 jumps to five labels. The game now has no `GOTO`, `GOSUB` or label. The only
`ON ERROR GOTO` left is `ON ERROR GOTO 0`.

- The picker's menu is a `DO` loop. Esc, Enter and `CASE ELSE` leave with `EXIT SUB`; every other
  key shows the menu again.
- A letter takes the first city that starts with it, then steps forward in a `DO WHILE` loop to a
  city of the player's. After 39 steps it goes back to the city it started from (`EXIT DO`), as
  before. `EXIT FOR` ends the search, where the jump back to the menu ended it before.
- The arrows step back or forward in a `DO ... LOOP UNTIL` the city is the player's.
- Lines that no test runs: 17. The give-up after 39 cities was a line of its own and is now the end
  of the line that counts the steps. It still never runs. 126 unit tests and 38 scripts pass, with
  unchanged recordings and both compilers.

## Open questions

Answered: the commands get a folder of their own, `commands\` (user, 2026-11-12). A command carries
out one order for either side: it calls rules and shows what happened. Examples are
`navy_build_ship`, `army_combine`, `army_recruit` and `railroad_move`, which phase 8 filed in `ui\`.
Nothing in `commands\` opens a menu or reads a key. Phase 9 steps 6 and 7 move them.

## Phase 11: the war's own content

### Open questions

1. **Texts: code in `game\`, or a data file?** **Data files** (user, 2026-11-13). The events
   are in `scenarios\EVENTS.DAT`, with their rules: the user asked that the code not know which war
   is fought. The other 24 war-naming strings follow the same rule in step 3.

## Original plan: baseline, decisions and phases

Retained on 2026-11-14 as historical context. The numbered decisions below keep their original
numbers; the active plan summarizes the rules that still apply.

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


## Original split rules from phases 8 and 9

These are the rules as written during those phases, including temporary exceptions that later
steps removed. Current guidance stays in the active plan under the same split headings.

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


## Phase 11: the original survey

Moved from the active plan on 2026-11-14. This is the original survey, partly updated as the
event data work finished; its paths and counts are historical.

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

### Coverage inventory history

The 11 lines that no test runs (20 before phase 9 step 6, 18 before the last labels went, 17 before
`DIR$` went on 2026-11-13, 15 before the kept bugs were fixed the same day, 12 before `battle_strengths`'
cases were put in order). The table names the SUB, not the line
numbers, because each step moves the lines; `report.txt` has the numbers of the day.
