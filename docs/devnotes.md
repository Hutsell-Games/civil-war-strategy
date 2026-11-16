# Developer notes: the QB64 port

The port starts from `canonical-source`, the BASIC PDS 7.1 source as W.R. Hutsell gave it. It first changed that
source as little as possible so that the game builds with QB64Rust and with QB64pe, and so that its SUBs can be
tested. Since 2026-11-11 the code has been modernized: formatted, renamed and split by topic
([modernize-plan.md](modernize-plan.md)). The plan of the port was `docs\port-study.md` (QB64Rust's study 46 until 2026-11-06), now
`docs\archived\port-study-completed.md`. It follows the ports of World War 2
(`Hutsell-Games/world-war-2`) and Civil War Battleset (`Hutsell-Games/civil-war-battleset`), both on a branch
`qb64rust`, and the principles in QB64Rust's `docs\PORTING-PDS.md`, section 0.

Before this port, `main` held an earlier port of 2024, made for QB64pe: one merged source file, with the DOS
programs and their features removed. This port does not build on it. It takes four graphics lines from it
(item 8) and the text of the help program (item 6).

This port replaced the 2024 port on `main` on 2026-11-14 (user, 2026-11-14). The branch `old-main`
keeps `main` as it was before: commit `b02d2188115c7d9e5182696631d0f0372e947de3`. The build workflow
(`.github\workflows\build.yml`) runs on merges into `main` only (D8).

The permanent record of gameplay-rule and AI changes from `canonical-source` is
[rule-changes.md](rule-changes.md). This file holds the port's technical changes and their reasons.
What each step of the port found is in
`archived\devnotes-completed.md`.
The ongoing evidence for possible QB64Rust language and tooling improvements is in
[qb64-friction.md](qb64-friction.md), phase 11 step 5 of the modernization plan.

## Build

```
qb64rust -x cws.bas -o cws.exe
```

`cws.exe` is the name of the DOS program, which is on `canonical-source` only ("Files removed", below). The
build runs from this folder: it reads `CWS.CFG`, `HISCORE.CWS`, `graphics\` and `scenarios\` beside it.
`tests\play.py` copies these into a folder of its own for each run.

## Format

The source is laid out by QB64Rust's formatter, with the settings in `qb64rust.toml`: upper-case keywords,
four spaces a level, every IF a block IF, and one statement a line. Format an include file inside its
program, so that its names take the program's spelling and the rewrites apply:

```
qb64rust -y commands/army.bm --program cws.bas -o commands/army.bm
qb64rust -y cws.bas -o cws.bas
```

Format Document in VS Code does the same. `tests\rules_test.bas` is left packed: checked as a program it has
errors, because `qb64rust test` supplies its `Assert` SUBs, so the formatter does not rewrite it. A SUB's name
followed by a colon (`clear_right_panel: EXIT SUB`) also stays on one line, as the formatter cannot tell it
from a label.

## What was changed from `canonical-source`, and why

1. **One program, instead of three linked modules.** QB64 builds one source file. `CWSTRAT2.BAS` and
   `CWSMENU.BAS` were renamed to `.BM` (with `git mv`) and are included at the end of `CWSTRAT.BAS`. Their headers
   were removed: `DEFINT A-Z`, their `DECLARE` lines and the include of `cws14.bi`. The main module already has
   `DEFINT A-Z` and the include, and QB64 does not need a `DECLARE` for a SUB the program defines.
2. **The 28 SUBs of `CWSTRAT.BAS` moved to `CWSTRAT1.BM`.** A test file can then include `CWS14.BI` and the `.BM`
   files and get every SUB without the main module's code. They moved unchanged: when they were moved,
   `CWSTRAT.BAS` and `CWSTRAT1.BM` put back together gave the original `CWSTRAT.BAS` byte for byte.
3. **Three `DIM SHARED` arrays moved to `CWS14.BI`**: `graphic` and `Ncap` from `CWSTRAT.BAS`, and `graft` from
   `CWSMENU.BAS`. They are the pictures' arrays. A test file needs them too, and QB64 wants a `DIM SHARED`
   before the SUBs that use it.
4. **`DIR$` is written in `QB64.BM`** with QB64's `_FILES$`. It is World War 2's. No call changed: all 10 calls
   pass an argument. Without it, both compilers read `DIR$("*.sav")` as an array.
5. **The title screen, the burning capital and the picture of Lincoln are pictures in `docs\`.** The DOS game
   ran three DOS programs that have no source: `SHELL "cwstitle.exe"` at its start, `SHELL "cityburn.exe"` when
   a capital falls (`burn`, only with full graphics), and `SHELL "abelinco.exe"` at the Emancipation
   Proclamation (`events`). 64-bit Windows cannot run them. The three `SHELL` lines are comments now. Run in
   DOSBox 0.74-3 on 2026-11-06, the programs drew [CWSTITLE.png](CWSTITLE.png), [CITYBURN.png](CITYBURN.png)
   and [ABELINCO.png](ABELINCO.png). Each waits for a key. The game's own title screen, with the two flags and
   the menu, still shows. `burn` still draws the map again, as it did after the picture.
6. **The help screens are a text file in `docs\`, and F1 is gone.** F1 at a menu ran `SHELL "cwsdoc.com"`: a
   text viewer made with TXT2COM that holds four topics of help. The port removes F1's branch from `menu`
   (`CWSMENU.BM`) and the "F1 = HELP" label from `topbar` (`CWSTRAT2.BM`), as the branch `main` did. F1 at a
   menu is now ignored, like any other key the menu does not use. The text is [CWSDOC.TXT](CWSDOC.TXT), as
   `main` keeps it, and the full manual is [CWS.DOC](CWS.DOC). A pager in the game was considered and not
   built: players who want the instructions can read the documents (user, 2026-11-06).
7. **Every `GOSUB` routine in a SUB ends by `RETURN`.** QB64 keeps one `GOSUB` stack for the whole program
   (`archived\devnotes-completed.md`, "The searches", section 2). Two routines could leave their SUB:
   - `crsr` in `menu` (`CWSMENU.BM`): Esc, an entry chosen by its first letter, F7 at a main menu, and any key
     at a menu of switch 3 set `leave` to 1; Ctrl+B sets it to 2. The lines after `GOSUB crsr` go to `called`
     for 1 and to `boss` for 2, as the routine did.
   - `riot` in `events` (`CWSTRAT2.BM`): `IF control(who) = 1 THEN EXIT SUB` is now `... THEN RETURN`. Both
     lines that call it are `GOSUB riot: EXIT SUB`, so the SUB ends either way.
8. **Four graphics lines are changed as `main` changed them**, because QB64 draws three shapes differently from
   DOS and `PAINT` then floods the map (`archived\devnotes-completed.md`, "What DOS did that QB64 does not"):
   - the railroad's small train (`CWSTRAT.BAS`): `U8` is `U9` in its `DRAW` string;
   - the cannon's wheel (`cannon`, `CWSTRAT2.BM`): the arc `CIRCLE (x + 5, y), 29, 1, 4, 1.5, 1.4` has the
     radius 27;
   - `touchup` (`CWSTRAT2.BM`): `PAINT (502, 160), 1, 10` and `PAINT (108, 400), 1, 10` are comments.
9. **The data files are in folders**, named in `FOLDERS.BI`, which `CWS14.BI` includes: the pictures in
   `graphics\` and the map, the setup and the leaders in `scenarios\`, with the alternate map's three files and
   `ALTMAP.BAT`. Nine lines name a folder now. `CWS.CFG`, `HISCORE.CWS`, the saved games and the history files
   stay beside the program. Since 2026-11-13 each map has a folder of `scenarios\`, `standard\` and `alternate\`,
   and `ALTMAP.BAT` is removed: the player picks the map after Start NEW Game, and a saved game names its
   map in its first line (`docs\archived\scenario-plan.md`).
10. **The test hooks**: `SCRIPT.BM`, included at the end of `CWSTRAT.BAS`, and calls to it in the sources. When
    the environment variable `CWS_SEED` is not set, the program behaves as before. Each changed line is listed
    in "The test hooks", below.

Not changed by these steps: the code was not reformatted, no variable was renamed, and no feature of the game
was removed. The modernization since then has formatted the code and renamed its variables. The
text "Registered Edition" and the version stay. The DOS line-drawing characters in the sources (code page 437)
stay as they are, and both compilers draw them as DOS did.

## The test hooks

`SCRIPT.BM` holds the hooks, as in the other two ports. `tests\README.md` ("How the game takes part") says what
each does for a script. The hooks act only when `CWS_SEED` is set. One shared variable, `scripted`, is added
at the end of `CWS14.BI`.

The lines changed for them:

| Where | Before | Now |
|---|---|---|
| `CWSTRAT.BAS`, before the title menu | `RANDOMIZE TIMER` | `CALL scriptstart` |
| `history_start`, `io/files.bm` | `SHELL "copy cws.his oldhist.ory"` | `NAME "cws.his" AS "oldhist.ory"`, after an old `oldhist.ory` is deleted, in normal play and scripts |
| `CWSTRAT.BAS`, the same place | `DATE$` | `scriptdate$` |
| `TICK`, `CWSTRAT2.BM` | | first line `IF scripttick(sec!) THEN EXIT SUB` |
| 12 loops `DO WHILE INKEY$ = "": LOOP` | | `CALL announce(1, "<letter>")` before each |
| `maxx`, `CWSTRAT2.BM` | `INPUT a$` | `CALL announce(4, ""): INPUT a$` |
| `crsr` in `menu`, `CWSMENU.BM` | `crsr:   a$ = INKEY$: IF a$ = "" GOTO crsr` | `crsr:   CALL announce(2, mtx$(0)): DO: a$ = INKEY$: LOOP WHILE a$ = ""` |

The menu's loop reads keys as before. Its label stays, so the wait is announced again after a key the menu
ignores.

Choices made here (`docs\archived\port-study-completed.md`, section 4):

- **`TICK` of 99 seconds or more waits for a key** under a script, as in Civil War Battleset. The game uses
  `TICK 99` twice as "read this, then press a key": after Chk Links, and at "There are still defenders".
  Shorter pauses return at once.
- **Under a script the game is silent**: `scriptstart` runs `PLAY "V0"`, QB64's volume 0. A script may turn the
  sound on in the Utility menu, and the `SOUND` and `PLAY` statements then run and take their time, unheard.
  A script must not start with `noise` 2 in its `CWS.CFG`: the title music plays before `scriptstart` runs.
- **The history file is renamed in BASIC in all play** (`history_start`, `io/files.bm`). The original
  copied `cws.his` to `oldhist.ory` and then emptied it, so `NAME` does the same. It no longer needs
  Windows' `copy` command or opens a console window, and it works on Linux too.
- **The boss screen (Ctrl+B) announces no wait.** A keys file cannot give Ctrl+B, so no script reaches it.

## The tests

`tests\play.py`, `tests\make_scripts.py` and `tests\test_play.py` are Civil War Battleset's, changed for this
game. `tests\README.md` is their manual. `tests\rules_test.bas` has 23 unit tests of 12 SUBs and FUNCTIONs that
draw nothing, and of `DIR$` and two hooks.

There are 25 scripts. Eleven are written by hand; ten of these are the scripts that QB64Rust's own test corpus
plays on its copy of `main`'s game (`tests\corpus\screen\g12_game.*.keys` there), with this port's places in
place of that copy's numbers. Fourteen are generated: whole games in which the player only ends each turn.
QB64pe 4.7.0 and QB64Rust gave the same screens in every recording, twice each.

## Files removed

The port does not use these 14 files, so they are not on this branch. They stay on `canonical-source`. The
game was checked to run without each of them: no run of `tests\play.py` copied them.

| File | What it is |
|---|---|
| `CWS.EXE` | The DOS build of the game. The QB64 build takes its name |
| `CWSTITLE.EXE`, `CITYBURN.EXE`, `ABELINCO.EXE` | DOS programs with no source (item 5) |
| `CWSDOC.COM` | The DOS help viewer (item 6) |
| `CWSTRAT.OBJ`, `CWSTRAT2.OBJ`, `CWSMENU.OBJ` | PDS object files |
| `CWSTRAT.MAK`, `CWS.LNK`, `CWSMAK.BTM` | PDS build files |
| `GO.BAT`, `INSTALL.BAT`, `PRINTDOC.BAT` | DOS launchers |

`HISCORE.CWS` and `CWS.CFG` stay: the game opens both without checking that they exist. `tests\data\` holds a
copy of the empty `HISCORE.CWS` that came with the game, which every test run starts from.


## Port and interface differences from canonical

Moved from `rule-changes.md` on 2026-11-14. These describe interface, compatibility and
implementation differences, rather than game rules. Original U and P IDs are retained
so earlier references remain identifiable. Gameplay effects of loading, setup and
persisted victory/event state remain in [rule-changes.md](rule-changes.md).
These entries retain their original review dates and verification claims; moving them
is not a new source review or test run.

### Interface and save compatibility

| ID | Topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| U1 | Load after creating the first save | The Files menu can set `filel` to 0 but does not restore it when a save appears, keeping Load disabled until a new-game initialization. | Rechecks the disk in both directions, enabling Load after a successful first save. [io/files.bm](../io/files.bm), `saved_games_check:230`; `0e32e1c`. |
| U2 | Resume without successfully loading a game | No save, cancellation, or failure can lead into the main menu without the normal map display. | Returns to the title menu until a game is actually loaded. [cws.bas](../cws.bas), title loop; `0e32e1c`. |
| U3 | F7 in a submenu | Any canonical plain menu accepts F7 and returns 99, which some callers treat as an array index or save slot. | F7 ends a turn only at the main menu. F3 and F4 remain available in plain menus. [ui/menu.bm](../ui/menu.bm), `menu_arrow_key:258`; `0e32e1c`. |
| U6 | Esc in Random Events options | The status line can show stale text from an earlier selection, held in main-module `t$`. | Reconstructs the displayed description from the setting currently in force. [ui/options.bm](../ui/options.bm), `menu_option_events:258`; `0e32e1c`. |
| U7 | Saved-game discovery | Canonical uses `*.sav` to determine whether any save exists, although its slot list only enumerates `cws1.sav` through `cws9.sav`. An unrelated `.sav` can enable Load without a valid listed slot. | Only those nine actual slot names count as saved games. [io/files.bm](../io/files.bm), `any_saved_game:238`. |
| U8 | Choosing and retaining a map | Canonical `ALTMAP.BAT` swaps the active files on disk, affecting subsequent launches too. | A Scenario menu follows Start NEW Game when multiple scenarios are listed. Esc returns to the title; one listed scenario skips the menu. The selected scenario remains active for later games in that process, but a fresh process starts with the list's first scenario. No file-swapping batch file is provided. [ui/main_menu.bm](../ui/main_menu.bm), `menu_scenario:175`; [rules/setup.bm](../rules/setup.bm), `game_new:184`; `2ba37f5`, `f97722d`. |
| U10 | Save format and map restoration | Canonical saves begin with numeric month/year/bonus/side data and contain no map identity. They load against whichever map files are installed. | Saves prepend the quoted scenario folder. Loading switches to that scenario's map/leaders when necessary. Unnamed old saves are assigned to the first scenario; an unknown named scenario is refused with a message. **New saves cannot be read directly by canonical**, which expects a numeric first field. [io/files.bm](../io/files.bm), `load_game:126`, `save_game:203`; `fe4d78d`. |
| U11 | No owned city during city-picker arrow navigation | Canonical `newcity` loops indefinitely searching for an owned city on Up/Down. | The search is bounded by `MAX_CITIES` and returns city 0 when none exists. [rules/city.bm](../rules/city.bm), `side_city_step:50`; `d8b845d`. |
| U12 | Enemy Forces in the army report | `CWSTRAT2.BAS:829` prints `INT(aggress! * x)`: the computer's strength ratio times the side's men. The ratio is 0 before the first month's end, so the first turn shows "000". It is computed once a month, and `CWSTRAT.BAS:2621` and `:2626` add .7 when the computer holds fewer than 11 cities. In the Enemy report it multiplies the enemy's men instead. The manual (section 3.9) calls it "the total strength of the enemy forces". | Prints the other side's men in the armies that hold a city, counted as Total Forces counts its own, from the first turn on. The Force summary (F4) already showed every army's strength. [rules/army.bm](../rules/army.bm), `side_troops`; [ui/reports.bm](../ui/reports.bm), `report_armies`. `db5deb2`. `TestSideTroops`; `commands` and `union-manassas` recorded again. |
| U13 | Income target in the Victory Conditions menu | `CWSTRAT2.BAS:272` builds "% Total Income" from `vicflag(3)`, the cities rule. The standard map has 80 for both, so it shows the right value by chance. The alternate map shows 70% while the game ends at 60%. | Shows the income rule, `victory_rule(VICTORY_INCOME)`. [ui/reports.bm](../ui/reports.bm), `menu_victory_conditions`. `db5deb2`. `war-rebel-altmap` and `war-union-altmap` recorded again. |

### DOS presentation, runtime and external files

| ID | Topic | Divergence |
|---|---|---|
| P1 | External title picture | Canonical runs `CWSTITLE.EXE` on its first launch without command-line text. The port omits that picture and its key wait. The internal flags/title/menu remain; a reference image is in `docs/CWSTITLE.png`. [ui/main_menu.bm](../ui/main_menu.bm), `show_title`; `1cff8db`. |
| P2 | Capital-burning picture | Canonical runs `CITYBURN.EXE` on a full-graphics capital capture, then returns to the game map. The port omits the picture and key wait. The later removal of `burn` also removes its extra map redraw. [commands/city.bm](../commands/city.bm), `city_capture`; `1cff8db`, `1727bf9`. |
| P3 | Lincoln picture | Canonical runs `ABELINCO.EXE` during Emancipation. The port keeps the event but omits the external picture and its wait, with the reference image kept in `docs/ABELINCO.png`. [ui/events.bm](../ui/events.bm); `1cff8db`. |
| P4 | F1 help | Canonical menus launch `CWSDOC.COM`, then redraw the map/menu, and the top bar advertises F1. The branch ignores F1 and removes that label; help is read externally from `docs/CWSDOC.TXT` / `docs/CWS.DOC`. [ui/menu.bm](../ui/menu.bm), [ui/screen.bm](../ui/screen.bm); `77136ba`. |
| P5 | Ctrl+B boss screen / screensaver | Canonical Ctrl+B enters `scrnsavr`; Ctrl+B exits it and restores the menu. It also reseeds/consumes the game's random generator. The branch removes this reachable feature and treats Ctrl+B as an unrecognized menu key. `1727bf9` called this dead-code removal, but a user can reach it from canonical menus. Canonical `CWSMENU.BAS:256`, `:487`; [ui/menu.bm](../ui/menu.bm). |
| P6 | Train, cannon and water pixels | The Railroad menu's train uses `U9` in place of `U8`; the cannon wheel arc radius is 27 instead of 29; the two map touchup fills at `(502,160)` and `(108,400)` are omitted. These accommodate QB64 drawing differences but are still visual divergences. [ui/main_menu.bm](../ui/main_menu.bm), [draw/pictures.bm](../draw/pictures.bm), [draw/map.bm](../draw/map.bm); `1cff8db`. |
| P7 | Window sizing | `$RESIZE:STRETCH` permits resizing and scales the 640×480 display; Alt+Enter permits fullscreen. The window opens at 1280×960 when the desktop is at least 1280×1024 (`window_open`). Canonical is a DOS display without this window behavior. [cws.bas](../cws.bas), line 5; `bc7c787`. |
| P8 | Data locations | Canonical opens map/setup/leader/graphics files beside the executable. The branch requires `graphics/`, `scenarios/SCENARIOS.LST`, and per-scenario folders. Old flat installations do not work unchanged. Config, scores, saves and history remain relative to the current working directory. [io/folders.bi](../io/folders.bi), [io/files.bm](../io/files.bm). |
| P9 | Events as editable data / startup failures | Canonical events are embedded in `events`. The branch reads `scenarios/EVENTS.DAT` on each new game, allowing conditions, effects, messages, ordering and chance to be changed without rebuilding. A missing/unreadable file or invalid definition can now stop startup; recognized parse errors report file/line/reason. The supplied definitions otherwise preserve the old event order and chance, apart from the mercenary fix [G20](rule-changes.md#explicit-gameplay-changes). [io/events_file.bm](../io/events_file.bm), [rules/events.bm](../rules/events.bm), [scenarios/EVENTS.DAT](../scenarios/EVENTS.DAT); `6c41775`. |
| P10 | Distributed executable/tooling | A modern single executable replaces the three linked BASIC modules and DOS build/launcher/install/print-help tools. Removed DOS binaries remain on canonical. Building and deploying the new program requires its new folder layout. This is an execution/deployment change, not an additional gameplay-rule change. [README.md](../README.md), [developer notes](#what-was-changed-from-canonical-source-and-why). |

### Linux file access and history backups

Added 2026-11-14, uncommitted: references to shipped graphics, scenario files, `CWS.CFG` and
`HISCORE.CWS` now match their exact uppercase filenames on case-sensitive filesystems. New saves
and history files retain their existing lowercase names. `history_start`
([io/files.bm](../io/files.bm)) renames `cws.his` to `oldhist.ory` with `NAME` in both normal and
scripted play, replacing the Windows-only `SHELL "copy ..."` and the script-only command parser. An
older `oldhist.ory` is deleted first, and no console window opens. Gameplay rules and
save contents are unchanged.

Verification on Ubuntu under WSL2, using a copy on its case-sensitive filesystem:
41 Python tests and all 198 BASIC unit tests passed, including normal-play history rotation
over an existing backup. With the corrected headless audio setup below, all 41 whole-game
scripts passed on Linux with normal timeouts and unchanged recordings. All 41 also passed
on Windows.

The two initial Linux sound-script timeouts came from the headless test environment retaining
WSLg's audio connection. A captured native stack showed `navy_combat_volley` calling
`cannon_shot`, then `SOUND` waiting in `sub__delay` for queued audio. Delay samples six seconds
apart showed that backlog persisting; the same sound script also timed out with QB64pe.
Both sound scripts match their recordings with both compilers when the audio connection is
isolated and ALSA's null playback device is used. `tests/play.py` now supplies that device
and a private `XDG_RUNTIME_DIR`, clearing `PULSE_SERVER` and `WAYLAND_DISPLAY`, following
QB64Rust's established Linux runner. Sound commands still execute; this changes only the
automated test environment. No diagnostic logging was added to the game's source.

### Added behavior when test mode is enabled

Canonical has no equivalent of `CWS_SEED`. With it unset, the hooks use normal time, date, sound and random draws; the gameplay differences in [rule-changes.md](rule-changes.md) still apply. With it set, [io/script.bm](../io/script.bm) adds these divergences:

- A fixed seed replaces `RANDOMIZE TIMER`.
- `CWS_DICE` can supply special-event draws. Consumed forced values replace real random draws, affecting the subsequent generator state too.
- Short timed pauses return immediately. Pauses of at least 99 seconds wait for a key instead of expiring on the timer.
- Audio volume is muted before the title music; later sound statements can still take time.
- New-game history uses the fixed date `01-01-2000`.
- Keyboard waits write prompt markers to emulated memory for the screen-test driver.

These hooks are intentional test features, not ordinary-play regressions.

### Edge state changed during extraction

Canonical `tupdate` keeps its local battle winner/loser across successive armies' moves. The extracted `turn_attack` initializes them anew for each call. If an inconsistent save gives an occupied city a zero-strength defender, the battle is skipped and the subsequent code can therefore act on different stale/zero army slots. This is a source-level difference on an invalid/inconsistent state, not an established normal-play regression. See [ui/turn.bm](../ui/turn.bm), `turn_attack`, and extraction commit `d7c9378`.
