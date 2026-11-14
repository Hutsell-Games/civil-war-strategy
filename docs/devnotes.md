# Developer notes: branch `qb64rust`

This branch starts from `canonical-source`, the BASIC PDS 7.1 source as W.R. Hutsell gave it. It changes that
source as little as possible so that the game builds with QB64Rust and with QB64pe, and so that its SUBs can be
tested. The plan is `docs\port-study.md` (QB64Rust's study 46 until 2026-11-06). It follows the ports of World War 2
(`Hutsell-Games/world-war-2`) and Civil War Battleset (`Hutsell-Games/civil-war-battleset`), both on a branch
`qb64rust`, and the principles in QB64Rust's `docs\PORTING-PDS.md`, section 0.

The branch `main` of this repo is an earlier port of 2024, made for QB64pe: one merged source file, with the DOS
programs and their features removed. This branch does not build on it. It takes four graphics lines from it
(item 8) and the text of the help program (item 6).

This file holds what was changed from `canonical-source` and why. What each step of the port found is in
`archived\devnotes-completed.md`.

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

Not changed: the code is not reformatted, no variable is renamed, and no feature of the game is removed. The
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
| `CWSTRAT.BAS`, Start NEW Game with history on | `SHELL "copy cws.his oldhist.ory"` | `CALL scriptshell("copy cws.his oldhist.ory")` |
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
- **Under a script the history file is copied in BASIC** (`scriptshell`), because a `SHELL` starts `cmd.exe`,
  whose console window shows on the user's desktop even when the program runs on a hidden one.
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
