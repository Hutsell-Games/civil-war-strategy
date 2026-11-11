# Developer notes: branch `qb64rust`

This branch starts from `canonical-source`, the BASIC PDS 7.1 source as W.R. Hutsell gave it. It changes that
source as little as possible so that the game builds with QB64Rust and with QB64pe, and so that its SUBs can be
tested. The plan is `docs\port-study.md` (QB64Rust's study 46 until 2026-11-06). It follows the ports of World War 2
(`Hutsell-Games/world-war-2`) and Civil War Battleset (`Hutsell-Games/civil-war-battleset`), both on a branch
`qb64rust`, and the principles in QB64Rust's `docs\PORTING-PDS.md`, section 0.

The branch `main` of this repo is an earlier port of 2024, made for QB64pe: one merged source file, with the DOS
programs and their features removed. This branch does not build on it. It takes four graphics lines from it
(item 8) and the text of the help program (item 6).

This file holds what was changed from `canonical-source` and why, and what each step of the port found.

## Build

```
qb64rust -x CWSTRAT.BAS -o cws.exe
```

`cws.exe` is the name of the DOS program, which is on `canonical-source` only ("Files removed", below). The
build runs from this folder: it reads `CWS.CFG`, `HISCORE.CWS`, `graphics\` and `scenarios\` beside it.
`tests\play.py` copies these into a folder of its own for each run.

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
   Proclamation (`events`). 64-bit Windows cannot run them. All three `SHELL` lines are removed: the first
   with the jump past it (item 13), the last a comment until then (2026-11-11). The game will not show the
   pictures (user, 2026-11-11). Run in
   DOSBox 0.74-3 on 2026-11-06, the programs drew [CWSTITLE.png](CWSTITLE.png), [CITYBURN.png](CITYBURN.png)
   and [ABELINCO.png](ABELINCO.png). Each waits for a key. The game's own title screen, with the two flags and
   the menu, still shows. `burn`, its `DECLARE` and its call in `capture` are removed (user, 2026-11-11): with
   the picture gone, the SUB only ran `SCREEN 12` and `CALL usa`. The 25 scripts reach that call and show the
   same screens without it.
6. **The help screens are a text file in `docs\`, and F1 is gone.** F1 at a menu ran `SHELL "cwsdoc.com"`: a
   text viewer made with TXT2COM that holds four topics of help. The port removes F1's branch from `menu`
   (`CWSMENU.BM`) and the "F1 = HELP" label from `topbar` (`CWSTRAT2.BM`), as the branch `main` did. F1 at a
   menu is now ignored, like any other key the menu does not use. The text is [CWSDOC.TXT](CWSDOC.TXT), as
   `main` keeps it, and the full manual is [CWS.DOC](CWS.DOC). A pager in the game was considered and not
   built: players who want the instructions can read the documents (user, 2026-11-06).
7. **Every `GOSUB` routine in a SUB ends by `RETURN`.** QB64 keeps one `GOSUB` stack for the whole program
   ("The searches", section 2). Two routines could leave their SUB:
   - `crsr` in `menu` (`CWSMENU.BM`): Esc, an entry chosen by its first letter, F7 at a main menu, and any key
     at a menu of switch 3 set `leave` to 1. The line after `GOSUB crsr` goes to `called` for 1, as the
     routine did. Ctrl+B set `leave` to 2, for the boss screen, which is gone (item 12).
   - `riot` in `events` (`turn.bm`): `IF control(who) = 1 THEN EXIT SUB` is now `... THEN RETURN`. Both
     lines that call it are `GOSUB riot: EXIT SUB`, so the SUB ends either way.
8. **Four graphics lines are changed as `main` changed them**, because QB64 draws three shapes differently from
   DOS and `PAINT` then floods the map ("What DOS did that QB64 does not", below):
   - the railroad's small train (`CWSTRAT.BAS`): `U8` is `U9` in its `DRAW` string;
   - the cannon's wheel (`cannon`, now in `drawings\cannon.bm`): the arc `CIRCLE (x + 5, y), 29, 1, 4, 1.5, 1.4` has the
     radius 27;
   - `touchup` (now in `drawings\map.bm`): `PAINT (502, 160), 1, 10` and `PAINT (108, 400), 1, 10` are comments.
9. **The data files are in folders**, named in `FOLDERS.BI`, which `CWS14.BI` includes: the pictures in
   `graphics\` and the map, the setup and the leaders in `scenarios\`, with the alternate map's three files and
   `ALTMAP.BAT`. Nine lines name a folder now. `CWS.CFG`, `HISCORE.CWS`, the saved games and the history files
   stay beside the program. `ALTMAP.BAT` is unchanged: run in `scenarios\`, it still switches the two maps.
10. **The test hooks**: `SCRIPT.BM`, included at the end of `CWSTRAT.BAS`, and calls to it in the sources. When
    the environment variable `CWS_SEED` is not set, the program behaves as before. Each changed line is listed
    in "The test hooks", below.
11. **The 17 SUBs that only draw are in eight files in `drawings\`** (branch `extract-graphics`,
    2026-11-11). They are 1,138 lines, and they were spread over the three `.BM` files. `CWSTRAT.BAS` and
    `tests\rules_test.bas` include the eight files after `cwsmenu.bm`.

    | File | SUBs | Moved from |
    |---|---|---|
    | `map.bm` | `maptext`, `showcity`, `touchup`, `usa` | `CWSTRAT2.BM`; `showcity` from `CWSTRAT1.BM` |
    | `schooner.bm` | `schooner` | `CWSMENU.BM` |
    | `ironclad.bm` | `ironclad` | `CWSMENU.BM` |
    | `cannon.bm` | `cannon` | `CWSTRAT2.BM` |
    | `capitol.bm` | `capitol`, the Union's victory | `CWSTRAT2.BM` |
    | `rwin.bm` | `rwin`, the Rebels' victory | `CWSTRAT2.BM` |
    | `surrender.bm` | `surrender`, an army's surrender | `CWSTRAT2.BM` |
    | `icons.bm` | `armyxy`, `chessie`, `engine`, `flags`, `flashcity`, `shipicon`, `tinytrain` | `CWSTRAT2.BM`; `flashcity` and `tinytrain` from `CWSTRAT1.BM` |

    They moved unchanged. Each SUB, with the blank line after its `END SUB`, has the same bytes as before, and
    so does everything left in the three `.BM` files. The 25 scripts show the same screens. Two SUBs that draw
    did not move: `icon` animates the map with sounds and `GET`/`PUT` of the shared `image` array, and `victor`
    holds rules of the game. This and item 14 are the two places where the branch rearranges the source for the
    reader, not for the build or the tests. `git blame -C` follows a moved SUB back to its old file.
12. **The boss screen is removed** (user, 2026-11-11: "it is no longer needed"). Ctrl+B at a menu showed boxes
    and circles moving over a black screen, to hide the game, until Ctrl+B again. `SUB scrnsavr` and three
    places in `menu` are gone: Ctrl+B's line in `crsr`, `IF leave = 2 GOTO boss`, and the lines `boss:` to
    `GOTO remenu`. Ctrl+B is now a key the menus ignore, or a key like any other at a menu of switch 3. The
    manual, `docs\CWS.DOC` section 1.8, still describes the screen saver: it is the original text, kept as given.
13. **Dead code is removed, and Vary Start's loop for the Rebels runs** (2026-11-11). Removed: the main
    module's `topbar:` routine, which nothing called (`CALL topbar` runs the SUB); a `GOTO menu0` after
    `GOTO loader`; `a$ = COMMAND$` and its jump past the `cwstitle.exe` comment, with the comment; a line of
    `smarts` that ran only when `best = 0`, after the line before had jumped away in that case; six
    `DECLARE SUB`s with no SUB (`banner`, `blastem`, `sndblst`, `sndfx`, `usamap`, `war`); the unused array
    `price`; and the labels `iron`, `band`, `notitle2`, `movopt`, `dock`, `move9`, `counter` and `remenu`, which
    no jump named. None of these changes a screen.
    Vary Start (Utility menu) had `FOR k = 21 TO 6`, which never ran. It is now `FOR k = 21 TO 26`, so it clears
    some of the Rebels' first six armies, as the loop before it does for the Union's. This changes the game:
    the script `options` was recorded again.
14. **19 more SUBs are in eight files by subject, beside `CWSTRAT.BAS`** (2026-11-11). They are 2,057 lines:
    1,332 from `CWSTRAT1.BM`, which keeps 491, and 725 from `CWSTRAT2.BM`, which keeps 335. `CWSTRAT.BAS` and
    `tests\rules_test.bas` include the eight files after `cwsmenu.bm`.

    | File | SUBs | Moved from |
    |---|---|---|
    | `battle.bm` | `battle`, `capture`, `retreat` | `battle` from `CWSTRAT1.BM`; the others from `CWSTRAT2.BM` |
    | `computer.bm` | `evaluate`, `smarts`: the computer player | `smarts` from `CWSTRAT1.BM`; `evaluate` from `CWSTRAT2.BM` |
    | `ending.bm` | `endit`, `maxx`, `victor`: the ending conditions, the Hall of Fame, the end of the game | `CWSTRAT2.BM` |
    | `files.bm` | `filer`: the settings and the saved games | `CWSTRAT1.BM` |
    | `navy.bm` | `barnacle`, `navy`, `ships`, `shiptype` | `CWSTRAT1.BM`; `ships` from `CWSTRAT2.BM` |
    | `railroad.bm` | `railroad`, `traincapacity` | `railroad` from `CWSTRAT1.BM`; `traincapacity` from `CWSTRAT2.BM` |
    | `report.bm` | `report` | `CWSTRAT2.BM` |
    | `turn.bm` | `events`, `iterate`, `tupdate`: the end of a turn | `CWSTRAT1.BM`; `events` from `CWSTRAT2.BM` |

    They moved unchanged, by the rule of item 11: each SUB with the blank line after its `END SUB` has the same
    bytes as before, and so does everything left in the two `.BM` files. The 25 scripts show the same screens
    with both compilers. Left in `CWSTRAT1.BM` and `CWSTRAT2.BM` are the armies' orders (`recruit`, `combine`,
    `fortify`, `relieve`, `cancel`) and the small SUBs that many others call. Two of those were looked at and
    stay: `void` is called from `navy` and `railroad` as well as the computer player, and `armystat` from
    `armies` and `menu`, not from `report`.

Not changed: the code is not reformatted, no variable is renamed, and no feature of the game is removed but F1's
help (item 6) and the boss screen (item 12). No rule of the game is changed but Vary Start's loop (item 13). The
text "Registered Edition" and the version stay. The DOS line-drawing characters in the sources (code page 437)
stay as they are, and both compilers draw them as DOS did.

## The searches before the port (2026-11-06)

The sources searched: `CWSTRAT.BAS`, `CWSTRAT2.BAS`, `CWSMENU.BAS` and `CWS14.BI`, as on `canonical-source`. Line
numbers in this section are those of the original files.

### 1. Names that BASIC PDS 7.1 has and QB64 does not

The names searched for are the list "Popular BASIC PDS 7.1 features" in QB64Rust's `docs\SOMEDAY.md`, the
PDS-only statements and functions that list leaves off, and the QB 4.5 forms that QB64 lacks or treats
differently, as for Civil War Battleset.

| Name | Where | What the port does |
|---|---|---|
| `DIR$` | 10 calls. `CWSTRAT.BAS` lines 31, 134, 670, 909, 1142, 1147, 1193; `CWSTRAT2.BAS` lines 777, 1444; `CWSMENU.BAS` line 215 | A `FUNCTION DIR$` with QB64's `_FILES$` (item 4). Every call passes an argument |
| `COMMON SHARED` | 12 lines, `CWS14.BI` lines 66 to 77. No named blocks | Kept: in one program it acts as `DIM SHARED` (measured for Civil War Battleset) |

None of the other names was found: no `CURDIR$`, `CHDRIVE`, `ON LOCAL ERROR` or `FRE`, no currency type, no
`BYVAL`, no `REDIM PRESERVE`, no `TYPE`, no `$DYNAMIC` or `$STATIC`. The only `ON ERROR` is `ON ERROR GOTO 0`
(`CWSTRAT.BAS` line 174).

### 2. `GOSUB` routines that can leave their SUB before `RETURN`

QB64pe and QB64Rust keep one `GOSUB` stack for the whole program. When a SUB ends while one of its own `GOSUB`
routines is still pending, the routine's entry stays on the stack. A later `RETURN` that finds this entry on top
stops the program with "RETURN without GOSUB". QB 4.5 and PDS 7.1 drop the entry when the SUB ends (QB64Rust's
`DIVERGENCES-QB45.md` Q-018).

A script built the control-flow graph of each SUB and looked for a way from each routine's label to `EXIT SUB`
or `END SUB` that passes no `RETURN`. Then each of the routines was read by hand.

There are 20 `GOSUB` routines in 9 SUBs: 6 in `navy`, 1 each in `railroad`, `smarts`, `tupdate`, `events`,
`roman`, `rwin` and `shipicon`, 2 in `recruit`, 3 in `menu` and 2 in `scrnsavr`. Two can leave their SUB:

| Routine | SUB | How it leaves | When |
|---|---|---|---|
| `crsr` | `menu` (`CWSMENU.BAS` line 254) | `GOTO called` for Esc (line 259), for an entry chosen by its first letter (line 263), for any key at a menu of switch 3 (line 258) and for F7 (line 290). `GOTO boss` for Ctrl+B (line 256), which draws the menu again and comes back to `GOSUB crsr` | At every menu. Enter and the arrow keys return normally |
| `riot` | `events` (`CWSTRAT2.BAS` line 483) | `IF control(who) = 1 THEN EXIT SUB` (line 485) | A special event that starts a riot while the side holds one city |

**Did the game stop?** Not in the 11 scripts played before the fix. A stale entry stops the program only when a
`RETURN` finds it on top, and here none does. No other `GOSUB` routine calls `menu` or `events`. The one
routine that does is `crsr` itself: F4 at a main menu shows a report, which has a menu of its own. The stale
entry is then one of the same `GOSUB crsr`, so the outer `RETURN` still goes to the right line. Each stale
entry only stays on the stack, which grows by one for each menu left by Esc or by a letter. The fix (item 7)
is made all the same, as in the other two ports: it changes no screen, and a later change to the game could
put a `RETURN` after a menu.

The two routines of the main module, `unionplus` and `blanken`, were read too. Each ends by `RETURN`. The main
module also had a label `topbar:` with a `RETURN`, which nothing called: `CALL topbar` runs the SUB of that
name in `CWSTRAT2.BAS`. It was removed on 2026-11-11.

### 3. Memory, `BLOAD`, `SHELL` and the clock

| Statement | Where | What it did in DOS | What the port does |
|---|---|---|---|
| `DEF SEG = VARSEG(a(1))`, `BLOAD "<name>.vga", VARPTR(a(1))` | `CWSTRAT.BAS` lines 32 to 34 (`mtn.vga`), 65 to 67 (`cwsicon.vga`), 910 to 912 (the forts); `CWSMENU.BAS` lines 216 to 218 (the faces) | Loaded a picture saved by `BSAVE` into an array, which `PUT` then drew | Kept. Both compilers draw the pictures, and the same |
| `SHELL "cwstitle.exe"`, `"cityburn.exe"`, `"abelinco.exe"` | `CWSTRAT.BAS` lines 62 and 1011; `CWSTRAT2.BAS` line 525 | Showed a picture and waited for a key | All three are removed. The pictures are in `docs\` (item 5) |
| `SHELL "cwsdoc.com"` | `CWSMENU.BAS` line 275 | Showed the help text | Removed with F1 and its label; the text is in `docs\` (item 6) |
| `SHELL "copy cws.his oldhist.ory"` | `CWSTRAT.BAS` line 134 | Kept the history file of the game before | Kept: `copy` works on Windows. Under a script it is done in BASIC ("The test hooks"). A `TODO.md` row for Linux |
| `RANDOMIZE TIMER` | `CWSTRAT.BAS` line 113; `CWSMENU.BAS` line 494 (`scrnsavr`) | Seeded the random numbers | The first takes the scripts' seed ("The test hooks"). The second is the boss screen's, which no script reaches |
| `DATE$` | `CWSTRAT.BAS` line 136 | The first line of the history file | A fixed date under a script |
| `COMMAND$` | `CWSTRAT.BAS` line 60 | Any option skipped the title program (`CWS /Q`) | Removed on 2026-11-11: it only skipped a line that is a comment |

There is no `PEEK`, `POKE`, `CALL ABSOLUTE`, `CALL INTERRUPT`, `RUN`, `CHAIN`, `KILL`, `NAME` or `FILES`.

## The first builds (2026-11-06)

QB64Rust 0.3.0 and QB64pe 4.7.0 both build the merged program with no error. `qb64rust --report unsupported`
names nothing. QB64Rust's warnings (`-w`) name five places, none of them a bug: the labels `iron` and `band`,
which no jump names; two lines after a `GOTO` that cannot run (`GOTO menu0` after `GOTO loader`, and the
`topbar:` routine); and the parameter `who` of `burn`, which is not used.

## What DOS did that QB64 does not

### Three shapes that `PAINT` fills

Played with either compiler's build, the first games showed three wrong screens, the same in both builds:

- **The railroad move** painted the whole map light blue (red for the Rebels). The main menu's Railroad entry
  draws a small train at the top right with `DRAW` at scale 6 and fills it with `PAINT (x, y), z, 15`.
- **A battle** painted the map magenta. `cannon` draws the cannon's wheel with two ellipses and an arc, and
  fills the space between them.
- **Each month's update** painted the map dark blue. `touchup` draws the Norfolk coast and the Mobile border
  again and fills the water beside them.

In each case the outline that should hold the paint is not closed in QB64.

The first two were measured against the old compilers on 2026-11-06, with QB64Rust's
`verification\qb45\q45_cws_paint_leaks.bas`. QB 4.5 and PDS 7.1, run in DOSBox, give the same pixels as each
other. QB64pe and QB64Rust give the same pixels as each other, and other ones:

| | QB 4.5 and PDS 7.1 | QB64pe and QB64Rust |
|---|---|---|
| The train: where the graphics cursor ends after the `DRAW` string | 555, 26 | 556, 28 |
| The train: the outline | closed; the paint stays inside | open at its top left: the outline's last line is on row 22, two rows below its first line on row 20; the paint covers the screen |
| The wheel: the second `PAINT`, at 618, 373 | inside the crescent between the outer ellipse and the arc | outside the arc; the paint covers the screen |

So QB64 draws a `DRAW` string at scale 6 with other lengths than DOS did, and `CIRCLE` with other pixels. The
branch `main` found the three leaks in 2024 and changed four lines (its `dev\minimal-changes.md`). This
branch takes the same four changes (item 8). With them the three screens show the map as it should be. The
train and the wheel then differ from DOS by a few pixels. `touchup`'s two fills are gone: the water beside the
two coast lines keeps the color the map gave it.

The third shape was not measured in DOS: it depends on the whole map being drawn first.

### The DOS programs

`CWSTITLE.EXE`, `CITYBURN.EXE` and `ABELINCO.EXE` were run in DOSBox on a desktop of its own, and each screen
was taken with DOSBox's own screenshot key. The title screen was the same after 4 and after 15 seconds, and
Lincoln's picture after 3 and after 13. The burning capital draws for a few seconds: its screen was the same
after 10 and after 20 seconds.

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
| `maxx`, `ending.bm` | `INPUT a$` | `CALL announce(4, ""): INPUT a$` |
| `crsr` in `menu`, `CWSMENU.BM` | `crsr:   a$ = INKEY$: IF a$ = "" GOTO crsr` | `crsr:   CALL announce(2, mtx$(0)): DO: a$ = INKEY$: LOOP WHILE a$ = ""` |

The menu's loop reads keys as before. Its label stays, so the wait is announced again after a key the menu
ignores.

Choices made here (`docs\port-study.md`, section 4):

- **`TICK` of 99 seconds or more waits for a key** under a script, as in Civil War Battleset. The game uses
  `TICK 99` twice as "read this, then press a key": after Chk Links, and at "There are still defenders".
  Shorter pauses return at once.
- **Under a script the game is silent**: `scriptstart` runs `PLAY "V0"`, QB64's volume 0. A script may turn the
  sound on in the Utility menu, and the `SOUND` and `PLAY` statements then run and take their time, unheard.
  A script must not start with `noise` 2 in its `CWS.CFG`: the title music plays before `scriptstart` runs.
- **Under a script the history file is copied in BASIC** (`scriptshell`), because a `SHELL` starts `cmd.exe`,
  whose console window shows on the user's desktop even when the program runs on a hidden one.

## The tests

`tests\play.py`, `tests\make_scripts.py` and `tests\test_play.py` are Civil War Battleset's, changed for this
game. `tests\README.md` is their manual. `tests\rules_test.bas` has 23 unit tests of 12 SUBs and FUNCTIONs that
draw nothing, and of `DIR$` and two hooks.

There are 25 scripts. Eleven are written by hand; ten of these are the scripts that QB64Rust's own test corpus
plays on its copy of `main`'s game (`tests\corpus\screen\g12_game.*.keys` there), with this port's places in
place of that copy's numbers. Fourteen are generated: whole games in which the player only ends each turn.
QB64pe 4.7.0 and QB64Rust gave the same screens in every recording, twice each.

### Found

- **The three paint leaks** (above).
- **`files`, one of the ten scripts taken from QB64Rust, was out of step.** `main` looks for saved games with
  `_FILEEXISTS("*.sav")`, which finds nothing, so that game never loads one, and the script said so. Here
  `DIR$` finds them. The script ran to its end all the same, with some keys going to other menus than it
  meant. It was written again, and now saves two games and loads both.
- **Load stays "-" after the first save of a game.** The Files menu sets `filel` to 0 when it finds no saved
  game, and only a new game sets it back. So a player who saves for the first time cannot load in the same
  game without going through New Game and Resume Saved Game. DOS did the same; a `TODO.md` row.
- **Resume Saved Game with no saved game shows the main menu on a black screen.** The map is not drawn until
  something redraws it. DOS did the same by the code; a `TODO.md` row.
- **A passive player loses in 1 to 11 turns.** The generated `pass` games end at the first victory condition
  the computer reaches. The `war` games, with only the time limit on, end after 10 to 21 turns, when the
  player's side has no army left. None reaches March 1865; the hand-written `union-time` and `two-player` do.

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
