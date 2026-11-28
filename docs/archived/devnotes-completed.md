# Done: the finished work of the port

This is the one archive of Civil War Strategy. Each section is a finished document, or the finished
part of one that still has open items. The sections were separate files in `docs\archived\` until
2026-11-27; the line under each heading names the file it was. New finished work is added as a new
section, not a new file.

- [Done: developer notes of the port](#done-developer-notes-of-the-port)
- [46. Porting Civil War Strategy to QB64Rust: what was done](#46-porting-civil-war-strategy-to-qb64rust-what-was-done)
- [Done: modernizing the code of Civil War Strategy](#done-modernizing-the-code-of-civil-war-strategy)
- [Constants](#constants)
- [Shared variable and parameter names](#shared-variable-and-parameter-names)
- [SUB and FUNCTION names](#sub-and-function-names)
- [Local variable, parameter and label names](#local-variable-parameter-and-label-names)
- [Done: local variable, parameter and label names](#done-local-variable-parameter-and-label-names)
- [Done: where each SUB goes (phase 6)](#done-where-each-sub-goes-phase-6)
- [Plan: scenarios in folders, picked in the game](#plan-scenarios-in-folders-picked-in-the-game)
- [Done: the review of the structure of the game's code](#done-the-review-of-the-structure-of-the-games-code)
- [Done: panel review of the code, 2026-11-14](#done-panel-review-of-the-code-2026-11-14)
- [Done: the code review of 2026-11-16](#done-the-code-review-of-2026-11-16)
- [Done: the plan to run Civil War Strategy in a browser with QBJS](#done-the-plan-to-run-civil-war-strategy-in-a-browser-with-qbjs)
- [Code smells review: completed items](#code-smells-review-completed-items)

## Done: developer notes of the port

The finished parts of `devnotes.md`, moved here on 2026-11-13, under the same headings: the searches,
builds and measurements of the port of 2026-11-06, and what its first tests found. The notes keep how to
build and format the game, what was changed from `canonical-source`, the test hooks and the files removed.

### The searches before the port (2026-11-06)

The sources searched: `CWSTRAT.BAS`, `CWSTRAT2.BAS`, `CWSMENU.BAS` and `CWS14.BI`, as on `canonical-source`. Line
numbers in this section are those of the original files.

#### 1. Names that BASIC PDS 7.1 has and QB64 does not

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

#### 2. `GOSUB` routines that can leave their SUB before `RETURN`

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
module also has a label `topbar:` with a `RETURN`, which nothing calls: `CALL topbar` runs the SUB of that
name in `CWSMENU.BAS`. Both compilers accept the label beside the SUB.

#### 3. Memory, `BLOAD`, `SHELL` and the clock

| Statement | Where | What it did in DOS | What the port does |
|---|---|---|---|
| `DEF SEG = VARSEG(a(1))`, `BLOAD "<name>.vga", VARPTR(a(1))` | `CWSTRAT.BAS` lines 32 to 34 (`mtn.vga`), 65 to 67 (`cwsicon.vga`), 910 to 912 (the forts); `CWSMENU.BAS` lines 216 to 218 (the faces) | Loaded a picture saved by `BSAVE` into an array, which `PUT` then drew | Kept. Both compilers draw the pictures, and the same |
| `SHELL "cwstitle.exe"`, `"cityburn.exe"`, `"abelinco.exe"` | `CWSTRAT.BAS` lines 62 and 1011; `CWSTRAT2.BAS` line 525 | Showed a picture and waited for a key | Comments; the pictures are in `docs\` (item 5) |
| `SHELL "cwsdoc.com"` | `CWSMENU.BAS` line 275 | Showed the help text | Removed with F1 and its label; the text is in `docs\` (item 6) |
| `SHELL "copy cws.his oldhist.ory"` | `CWSTRAT.BAS` line 134 | Kept the history file of the game before | Kept: `copy` works on Windows. Under a script it is done in BASIC ("The test hooks"). A `TODO.md` row for Linux |
| `RANDOMIZE TIMER` | `CWSTRAT.BAS` line 113; `CWSMENU.BAS` line 494 (`scrnsavr`) | Seeded the random numbers | The first takes the scripts' seed ("The test hooks"). The second is the boss screen's, which no script reaches |
| `DATE$` | `CWSTRAT.BAS` line 136 | The first line of the history file | A fixed date under a script |
| `COMMAND$` | `CWSTRAT.BAS` line 60 | Any option skipped the title program (`CWS /Q`) | Kept. It now only skips a line that is a comment |

There is no `PEEK`, `POKE`, `CALL ABSOLUTE`, `CALL INTERRUPT`, `RUN`, `CHAIN`, `KILL`, `NAME` or `FILES`.

### The first builds (2026-11-06)

QB64Rust 0.3.0 and QB64pe 4.7.0 both build the merged program with no error. `qb64rust --report unsupported`
names nothing. QB64Rust's warnings (`-w`) name five places, none of them a bug: the labels `iron` and `band`,
which no jump names; two lines after a `GOTO` that cannot run (`GOTO menu0` after `GOTO loader`, and the
`topbar:` routine); and the parameter `who` of `burn`, which is not used.

### What DOS did that QB64 does not

#### Three shapes that `PAINT` fills

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

#### The DOS programs

`CWSTITLE.EXE`, `CITYBURN.EXE` and `ABELINCO.EXE` were run in DOSBox on a desktop of its own, and each screen
was taken with DOSBox's own screenshot key. The title screen was the same after 4 and after 15 seconds, and
Lincoln's picture after 3 and after 13. The burning capital draws for a few seconds: its screen was the same
after 10 and after 20 seconds.

### The tests

#### Found

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



### Canonical comparison review (2026-11-14)

Moved from `rule-changes.md` on 2026-11-14. This is historical review evidence,
not a report of tests run during the documentation move. Regression IDs refer to
[the rule-change record](../rule-changes.md#regression-history-and-subsequent-corrections).

#### Baseline and review coverage

Reviewed 2026-11-14. This compares the complete branch trees, not just the most recent naming commits:

- Reviewed branch: `refactor_naming`, `d8b845d3283ab83f29a8cb92a5efe7919b222a64`.
- Canonical base: local remote-tracking ref `origin/canonical-source`, `45bdab482589d1a4d8d1b47c3e242bb19979f59c`.
- No fetch was performed. These commit IDs identify the comparison even if either branch moves.
- Supplemental source review covers the two commits added during this review, through `b182514fcd1a8e0ff2dcb43b91a0caf6f2a7601d` (`30d424e`, event-reader validation extraction; `b182514`, shared fortification command). No additional gameplay divergence was identified in those two commits. Line references below use the primary `d8b845d` snapshot.
- Current update: the staged fixes in `ui/turn.bm`, `rules/setup.bm` and `rules/events.bm` were inspected on 2026-11-14 and are recorded as R1–R3 in `../rule-changes.md`. They are not yet associated with a commit. The verification results at the end remain those of the original review, not a test run of these staged fixes.
- Scope: gameplay, AI, menus, presentation, persistence, startup and test-mode behavior. Renames, formatting, file moves and procedure extraction are excluded unless their behavior differs.

The branch is **not behaviorally equivalent** to canonical. It includes explicit bug fixes and feature changes. Existing recordings describe the branch's behavior; passing them does not establish equivalence to the DOS original.

#### Original review verification and limits (2026-11-14)

The review followed the commit history from canonical, inspected the original three BASIC sources and include, and checked the changed rule expressions and their current callers. Static findings are tied to the branch commit above. Unrelated working-tree edits appeared during the review; they were left untouched. An exported copy under ignored `tests/out/canonical-review/branch/` was used to separate branch verification from that ongoing work.

- Python tooling/layer checks: **41 passed** on the working tree.
- BASIC rule suite on the exact `d8b845d` snapshot: **188 passed, 0 failed, 0 errors**. A working-tree run that included the new event-reader tests also passed all 190 tests.
- Recorded game checks on the exact `d8b845d` snapshot: **40 passed, 0 failed** with QB64Rust. The separate working-tree run also passed all 40.
- Isolated review probes on the original snapshot: the crushed-attacker, scenario-count and absent-capital expectations **all failed**. R1/R2/R3 in `../rule-changes.md` record the later staged corrections; these failures do not describe the corrected working tree.
- An additional probe compared the extracted volunteer-event arithmetic against the canonical expression for initial army sizes 1 through 1250, at event weight 3: it passed. No arithmetic divergence is claimed from storing that event multiplier in the event table.
- The six map/setup/leader files match their canonical standard/alternate counterparts byte for byte. The two canonical leader files themselves are identical, so Git's apparent swapped rename pairing does not change the leaders. `CWS.CFG` and `HISCORE.CWS` have no branch diff.
- The original review changed no game source. Scratch exports, probes and logs are ignored under `tests/out/canonical-review/`. Later source changes and their status are recorded separately in `../rule-changes.md`.

The DOS/PDS executable was not replayed side by side, and QB64pe comparison was not rerun. Existing game recordings were rerecorded after intentional rule changes; neither their success nor line coverage proves that every possible play sequence matches canonical. This document records the divergences established by source review and the targeted probes, with inconsistent-state cases identified separately.

## 46. Porting Civil War Strategy to QB64Rust: what was done

Was `docs\archived\port-study-completed.md`.

The finished parts of `port-study.md`, moved here on 2026-11-13, under the same headings. The rest, D8's
answer of 2026-11-14, moved here on 2026-11-14 ("D8 settled", at the end), and `port-study.md` was removed.
`qb64rust` will eventually replace `main`, with its predecessor preserved as `old-main` (`../devnotes.md`).
The account below retains the status when written.

Written 2026-11-06. The user asked for the port the same day: "port Civil War Strategy from canonical-source on a
qb64rust branch, use the processes we have established for civil war battleset and world-war-2 and in QB64Rust"
(`DECISIONS.md` 2026-11-06). So this study is not a plan to approve first,
as `study\44` was. It says what was built, and section 4 lists the choices Claude made, each with the panel's
view, for the user to rule on. The user answered them the same day, taking every recommendation. Later that
day the user changed D3: F1 and its label are removed, and no pager is built. The port is committed. The study
stays open while D8's question, whether `qb64rust` replaces the game's `main`, has no answer (`CLAUDE.md`
working rule 7).

The game is W.R. Hutsell's *Civil War Strategy* 1.57 (`Hutsell-Games/civil-war-strategy`), cloned beside this
repo as `..\civil-war-strategy`. The port is on its new branch `qb64rust`, made from `origin/canonical-source`.
Nothing there is committed or staged by Claude, except the renames that `git mv` stages (`CLAUDE.md` rule 1).

### 1. The game, and how it differs from the two earlier ports

| | World War 2 | Civil War Battleset | Civil War Strategy |
|---|---|---|---|
| The original source | branch `main` | branch `main` | branch `canonical-source`; `main` holds a port of 2024 for QB64pe |
| Programs | the game and an editor | the game, an editor and `pbmfix` | the game only |
| Modules | 4 | 3, and 1 shared with the editor | 3: `CWSTRAT.BAS` (2,629 lines), `CWSTRAT2.BAS` (1,901), `CWSMENU.BAS` (551), and `CWS14.BI` |
| PDS-only names | `DIR$`, `CURDIR$`, named `COMMON`, `ON LOCAL ERROR`, the mouse interrupt | `DIR$`, `CURDIR$`, `CHDRIVE`, `ON LOCAL ERROR`, `FRE` | `DIR$` only (10 calls) |
| DOS programs with no source | title, city picture, sound players | title, yell, sound players | title (`CWSTITLE.EXE`), burning capital (`CITYBURN.EXE`), Lincoln (`ABELINCO.EXE`), help viewer (`CWSDOC.COM`) |
| Sound | sound files, DOS players | sound files, DOS players | `PLAY` and `SOUND` only, which QB64 has |
| Memory | mouse driver | `BLOAD` to text memory, BIOS keyboard buffer | `BLOAD` of pictures into arrays only |
| Scenarios | 7 | 77 | one map, and an alternate map switched in by `ALTMAP.BAT` |

Two more differences shaped the work:

- **QB64Rust already tests this game.** Its corpus holds a copy of `main`'s merged `CWSTRAT.BAS` with ten
  whole-game scripts (`tests\corpus\screen\g12_game.*`, the change `cws-whole-game`). The port reuses those ten
  scripts. Nine ran unchanged but for the names of the waits. The tenth, `files`, did not fit this game
  (section 3).
- **`main` already found what QB64 draws wrong.** Its `dev\minimal-changes.md` of 2024 names three paint leaks
  and the four lines that fix them. The port takes those four changes and measures two of the leaks against
  QB 4.5 and PDS 7.1 (section 3).

### 2. What was done

The steps are those of `study\44` section 6. All were done in one session, so the steps were not committed one
by one: the user stages and commits (section 5 proposes the commits).

| Step | Result |
|---|---|
| 1. The branch | `qb64rust` from `origin/canonical-source` |
| 2. The searches | PDS-only names: `DIR$` (10 calls) and unnamed `COMMON SHARED` (12 lines). `GOSUB` routines in SUBs: 20, of which 2 can leave their SUB (`crsr` in `menu`, `riot` in `events`). Memory and `SHELL`: 4 `BLOAD`s into arrays, 5 `SHELL`s (4 DOS programs and `copy`). The game's `docs\devnotes.md`, "The searches" |
| 3. The measurements | None was needed for the port: `COMMON SHARED`, `BLOAD` into an array and `DIR$` by `_FILES$` were measured for Civil War Battleset. The paint leaks were measured after they showed (section 3) |
| 4. One program, building | `CWSTRAT.BAS` includes `CWSTRAT1.BM` (its own 28 SUBs, moved unchanged), `CWSTRAT2.BM`, `CWSMENU.BM`, `QB64.BM` and `SCRIPT.BM`. Both compilers build it with no error. `qb64rust --report unsupported` names nothing |
| 5. What DOS did that QB64 does not | The four DOS programs' `SHELL` lines are comments; their three screens were captured in DOSBox into the game's `docs\`, and the help text is there as `CWSDOC.TXT`. The two `GOSUB` routines end by `RETURN`. Four graphics lines are changed as `main` changed them |
| 6. The test hooks | `SCRIPT.BM`: the seed from `CWS_SEED`, 15 announced waits (13 pauses, the menu, one `INPUT`), `TICK` returning at once below 99 seconds, a fixed date, `copy` done in BASIC, and `PLAY "V0"` |
| 7. The tests | 23 unit tests of 12 SUBs and 3 helpers. 25 scripts: 11 written by hand (10 of them from this repo's corpus) and 14 generated whole games. QB64pe 4.7.0 and QB64Rust gave the same screens in every recording, each script twice with each. The scripts and unit tests run 93.9% of the 3,851 lines that hold a statement (3,383 run, 234 partly run, 234 not run). `play.py check` takes 31 seconds with four jobs |
| 8. The files | The pictures are in `graphics\`, the map files and `ALTMAP.BAT` in `scenarios\`, the game's documents in `docs\`; `FOLDERS.BI` names the folders. After the move, `check` passed all 25 scripts: no screen changed. The user removed the 14 DOS-only files (D9) |
| 9. The build on GitHub Actions | `.github\workflows\build.yml`, from World War 2's. It has not run (D8) |
| 10. The documents | In the game's repo: `README.md`, `docs\devnotes.md`, `tests\README.md`, `TODO.md`. Here: this study, `PORTING-PDS.md`, `DIVERGENCES-QB45.md` Q-019 and Q-020, a `DECISIONS.md` row, `STATUS.md` "Next" |

No `SHELL` can run under the scripts: the four DOS programs' lines are comments, and `scriptshell` copies the
history file in BASIC. So the scripts ran on the host, on a hidden desktop, with four jobs (`CLAUDE.md` working
rule 6). The DOSBox captures ran on a hidden desktop too, with the sound written to a file.

### 3. What the port found

**QB64 draws three of the game's shapes differently from DOS, and `PAINT` then floods the map.** Both compilers
showed the same wrong screens: the railroad's train painted the map light blue, the battle's cannon painted
it magenta, and each month's `touchup` painted it dark blue. Two were measured with the new
`verification\qb45\q45_cws_paint_leaks.bas`. QB 4.5 and PDS 7.1 give the same pixels as each other; QB64pe and
QB64Rust give the same pixels as each other, and other ones:

- A `DRAW` string at scale 6 (`S6`) ends at 555, 26 in the old compilers and at 556, 28 in QB64. The train's
  outline is closed in the old compilers and open by one pixel row in QB64 (`DIVERGENCES-QB45.md` Q-019).
- `CIRCLE` with an aspect of 1.4, as two ellipses and an arc, encloses the point 618, 373 in the old compilers
  and not in QB64 (Q-020).

QB64Rust keeps QB64pe's pixels: its recorded screens are QB64pe's, and the corpus compares them byte for byte.
So these are two rows for the register, not bugs to fix. The lesson for a port is in `PORTING-PDS.md`, section
3: look at the screens, because a program that draws an outline and paints inside it can look wrong in QB64
with no error.

**A script can be out of step and still pass.** The corpus script `g12_game.files` was written for `main`'s
game, which looks for saved games with `_FILEEXISTS("*.sav")` and so never loads one. This port's `DIR$` finds
them. Converted, the script still ran to its end with both compilers and the same screens, but some of its
keys went to other menus than its comments said. It was found by reading the script's comments against the
code, then looking at each screen. It is written again and now saves two games and loads both. The corpus copy
is not affected: it is still `main`'s game.

**Stale `GOSUB` entries do not always stop a program.** `menu` leaves `GOSUB crsr` by `GOTO`, as in the other
two games. Here nothing returns over the stale entry, so no script stopped, in `main`'s copy either: the stack
only grows. The fix is made all the same (D6).

**Nothing new failed in QB64Rust.** The merged program built at the first try, and the two builds never
differed in 25 scripts. The game's `docs\devnotes.md` ("The first builds") lists QB64Rust's five warnings.
None is a bug of the game.

**The game's own oddities**, each a row of the game's `TODO.md` and none changed: Load stays "-" after a game's
first save; Resume Saved Game with no saved game shows the main menu on a black screen; `FOR k = 21 TO 6` in
Vary Start never runs; `traincapacity` reads `side` where it means `who`; `normal` draws high, as in the other
two games.

### 4. Choices made, for the user to rule on

**User (2026-11-06): every recommendation is taken**, D1 to D10, answered one by one. In particular: D3 is (a)
now and the help pager next; D8 leaves open whether `qb64rust` replaces the game's `main`; D9's `git rm` is
run by the user; D10 adds no `SOMEDAY.md` row.

The panel: the pragmatic engineer, the QB64 engineer, the compiler engineer, the Rust engineer, the test
engineer, and one more role, a QB64 user porting an old program, as in `study\43` and `study\44`. The Rust
engineer has no view on any of these: no Rust code changed.

**D1. Take `main`'s four graphics changes** (`U8` to `U9` in the train, radius 29 to 27 in the cannon's arc, two
`PAINT` lines of `touchup` turned off).
- (a) As built: take them. The three screens show the map as they should.
- (b) Leave the lines as they came, with a `TODO.md` row. The map is then wrong after every railroad move,
  battle and month.
- (c) Fix QB64Rust's `DRAW` and `CIRCLE` to draw as QB 4.5 did.

*Panel:* the QB64 user and the pragmatic engineer want (a): with (b) the game cannot be played, and the changes
are the user's own, from 2024. The compiler engineer rules out (c) for now: QB64Rust follows QB64pe, its
recordings would all change, and a QB64pe build of the game would still leak. The test engineer notes that
the scripts were recorded with (a), and that (b) would give 25 recordings full of flooded maps.
**Recommended: (a).**

**D2. The three DOS pictures are kept in `docs\` and not shown by the game**, as World War 2 and Civil War
Battleset did with theirs (`study\44` D6).
- (a) As built.
- (b) Show the captured pictures in the game with `_LOADIMAGE`, where it ran the DOS programs.

*Panel:* the pragmatic engineer wants (a) now: (b) is new code and three new data files, and the other two
ports wait for the same decision. The QB64 user would like (b) later for all three games at once. The test
engineer notes that `burn` and the Lincoln event are reached by scripts either way. **Recommended: (a), with
the `TODO.md` row that is there.**

**D3. F1 no longer shows the help.** The text is `docs\CWSDOC.TXT`, taken from `main`.
- (a) As built: the `SHELL` is a comment, and F1 only draws the screen again. "F1 = HELP" still shows.
- (b) Write a pager that shows `CWSDOC.TXT` in the game, four pages chosen by F1 to F4.
- (c) Take "F1 = HELP" off the screen, as `main` did.

*Panel:* the QB64 user wants (b): the help is part of the game, and a player sees "F1 = HELP" on every screen.
The pragmatic engineer accepts (b) as its own small change after the port is committed, since it adds a SUB
and changes screens. The test engineer wants a script for it then. Nobody wants (c): it removes a feature.
**Recommended: (a) now, (b) next, as a `TODO.md` row.**

**User, later on 2026-11-06: (c).** This came after Claude found that `CWSDOC.TXT` has four topics, not four pages. Its Getting
Started topic is 98 lines, about four screens, so a pager would also have to scroll. Built: F1's branch is
removed from `menu` (`CWSMENU.BM`), and the "F1 = HELP" label from `topbar` (`CWSTRAT2.BM`). F1 at a menu is
now ignored. The game's `README.md` points to `docs\CWSDOC.TXT` and the full manual `docs\CWS.DOC`. All 25
scripts were recorded again, because the label was on every map screen. QB64pe and QB64Rust gave the same
screens in every run. `check` passed 25 of 25, and the 23 unit tests passed. Line coverage is now 94.0%.

**D4. Under a script, `TICK` of 99 seconds or more waits for a key**, as in Civil War Battleset (`study\44`
D10, still open there). The game uses `TICK 99` twice. *Panel:* agreed, for the reason given there: a script
then sees those screens. **Recommended: as built.**

**D5. `ALTMAP.BAT` stays, moved into `scenarios\` unchanged.** The porting guide removes DOS launchers. This one
is the only way to play the alternate map, and it works in `cmd.exe`: it renames six files.
- (a) As built: keep it beside the files it renames.
- (b) Remove it, and say in `README.md` which six renames switch the maps.

*Panel:* the QB64 user and the pragmatic engineer want (a): it works and costs nothing. The QB64 engineer notes
that it does not work on Linux, where the renames would be done by hand. The test engineer notes that the four
scripts on the alternate map switch the files in `play.py`, so the batch file itself is not tested (a
`TODO.md` row). **Recommended: (a).**

*Since 2026-11-13:* replaced. Each map is a folder of `scenarios\`, the player picks it after Start NEW Game,
and `ALTMAP.BAT` is removed ([`scenario-plan.md`](#plan-scenarios-in-folders-picked-in-the-game)).

**D6. The `GOSUB` fix is made though no script stopped.** *Panel:* the compiler engineer and the test engineer
want it: the stack grows by one entry for each menu left by a letter, and a later `RETURN` placed after a menu
would stop the game. It changes no screen. **Recommended: as built.**

**D7. The generated scripts are whole games in which the player only ends each turn.** World War 2 and Civil War
Battleset generated one script per scenario and side. This game has one scenario, so the generator varies the
seed, the side, the settings and the map instead: 10 `pass` games and 4 `war` games (the game's
`tests\README.md`). They add 1.7 points of line coverage to the 92.2% of the hand-written scripts and the unit
tests, and a history file checked by its hash for each game.
- (a) As built.
- (b) Add a style in which the player also acts (recruits, moves, attacks), by rules.

*Panel:* the test engineer prefers (a) now: the hand-written scripts cover the player's commands, and the
generated ones add what they cannot, the computer playing long games. (b) needs rules that know the map. The
pragmatic engineer agrees. **Recommended: (a).**

**D9. The 14 DOS-only files are still on the branch.** The game's `docs\devnotes.md`, "Files to remove", lists
them with the `git rm` command: the DOS programs, the PDS object and build files, and three DOS launchers.
The hook and rule 1 leave a deletion to the user. *Panel:* all agree they go, as in World War 2.
**Recommended: the user runs the `git rm`.** Until then a build made in the repo's folder as `cws.exe` would
overwrite `CWS.EXE`; `play.py` and the workflow build elsewhere.

**D10. The corpus copy `g12_game` stays `main`'s game.** This port is another source of the same game. The
corpus copy has QB64pe's recorded screens and ten scripts held to line coverage.
- (a) Leave the corpus as it is.
- (b) Later, replace the copy with this port's source and its 25 scripts.

*Panel:* the test engineer wants (a) for now: the copy works, and (b) means new recordings and a new
`civil-war-strategy.unreached` list. The compiler engineer notes that (b) would add `DIR$` by `_FILES$` and
the `leave` flag to what the corpus runs, which other programs already cover. **Recommended: (a); no
`SOMEDAY.md` row unless the user wants (b).**


### D8 settled (from `port-study.md`, 2026-11-14)

**D8. The workflow's trigger, and what `main` becomes.** `build.yml` builds on each merge into `main`, as the
other two ports do. Here `main` is the 2024 port, not the original. So the workflow runs only once `qb64rust`
is merged into `main`, which would replace the 2024 port.

**Chosen: (a)** (user, 2026-11-14). Leave the trigger as built: builds on merges into `main`, with no
additional trigger for pushes to `qb64rust`.

#### Historical main

**Decided** (user, 2026-11-14): `qb64rust` will eventually merge into `main` and replace what was there.
Keep `old-main` as the historical branch: **main as it was before the latest rewrite**.
Its snapshot is commit `b02d2188115c7d9e5182696631d0f0372e947de3`
(`Merge pull request #23 from Hutsell-Games/minor-updates-for-release`).
The future merge is separate work; D8 has no remaining open question.

## Done: modernizing the code of Civil War Strategy

Was `docs\archived\modernize-plan-completed.md`.

The finished parts of `../modernize-plan.md`, archived from 2026-11-11 onward. The active plan
keeps the remaining work and current rules. The original decisions, phase table, proposed layout,
split rules and phase 11 survey were moved here on 2026-11-14. Counts and line numbers describe
the tree on the date each part was written.

### The kept bugs fixed (2026-11-13)

The user ruled on `TODO.md`'s "The game" rows at once: 22 were fixed in one batch, and three are kept
(`normal_random_number` drawing high, the pictures not shown, the train's and the cannon's pixels).
The `SELECT CASE` branches that were never reached ([`sub-names.md`](#sub-and-function-names), "Found while reading") were fixed
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

#### Three more (2026-11-13)

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

### Scenarios in folders (2026-11-13)

`scenarios\ALTMAP.BAT` renamed six files to switch the map, on Windows only. The plan that replaced it
is [`scenario-plan.md`](#plan-scenarios-in-folders-picked-in-the-game); it was done in four commits.

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

### Phase 11 step 2 (2026-11-13)

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

### Phase 11 step 4, and the events' tunes

Moved from the active plan on 2026-11-28.

- **Step 4, done 2026-11-14: the rules that treat the sides differently are named.** The inventory
  covers `rules\`, `ai\`, their callers in `commands\` and `ui\`, `io\files.bm` and
  `scenarios\EVENTS.DAT`. It stays in `../modernize-plan.md`, "Rules that treat the sides
  differently", because it describes the code as it is now. It moves no rule; whether the rules
  move is a question for the engine split. Fixes since then removed two of its 26 rules: the
  Realism setting no longer raises an event balance of 1 (G55), and the Rebel computer's invasion
  check looks at its own fleet's city (G50).
- **The events' two tunes are in `game\`.** Commit `2d5bf02` (2026-11-23) moved them from
  `ui\events.bm` into `play_side_tune` (`game\tunes.bm`), which a city's capture plays too.

### Progress, phase by phase

Updated 2026-11-11. Phase 1 is committed (`1727bf9`). Phase 2 is done in the working tree, not committed:
`tools\refactor\rename_subs.py` (from the "Settled names" table; `report` lists uses, `apply` rewrites).
`play.py check` and `compare` pass 25 of 25 with no recording changed, and the 23 unit tests pass. The branch
is `refactor_naming`. The user stages and commits. Phase 2 is committed (`4097c02`). Phase 4 step A is done
in the working tree: `tools\refactor\rename_vars.py` renamed 83 shared variables from [`variable-names.md`](#shared-variable-and-parameter-names)
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
4. The user accepted the names of [`constants.md`](#constants) as proposed (2026-11-11).

Answered: the table of variable names in [`variable-names.md`](#shared-variable-and-parameter-names) (phase 4) was settled, and phase 4 is done.

#### Phases 8 to 10, commit by commit

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

### Which model did which phase

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

### Phase 0: coverage

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

#### How the gaps are reached (user, 2026-11-11)

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

#### The gaps, by group

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

#### Found while reading

One more bug of the original, kept like the others (decision 3): in `events`, the mercenaries join
`armyname$(index)`, but `index` is never set in that SUB. So they join army 0, which is no army.

A second one: the Victory Conditions menu (`endit`) shows the income condition as
`vicflag(3) * 2.5` percent. `vicflag(3)` is the city condition; the income condition is `vicflag(4)`, and
`victor` tests that one. So the menu can show a percent that is not the one in force.

#### Steps

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

#### Phase 0 after phase 7 began

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

### Phase 7: break up the big pieces

Started 2026-11-11. The pieces and their names are those of "Worth breaking out" in [`sub-names.md`](#sub-and-function-names). Each
step is one commit (decision 15), and each ends with `play.py check`, `play.py compare` and the unit tests
passing on unchanged recordings.

#### Phase 0 was not finished

Only step 1 of phase 0 (the deletions) was done. Steps 2 to 10 were skipped: there is no forced dice, no
prepared save and no new script. So decision 13's bar is not met. Measured on 2026-11-11 before step 1
(`play.py coverage`, 25 scripts): 3,354 of 3,786 lines run in full, 232 in part, 200 not run. By
statements not run: the main module 116, `rules\navy.bm` 104, `ui\orders.bm` 74, `game\events.bm` 59,
`rules\army.bm` 59, `rules\turn.bm` 39, `ai\ai.bm` 32, `rules\railroad.bm` 24.

The user decided on 2026-11-11 to finish phase 0 before step 5, and it is finished ("Phase 0 after phase
7 began"). Steps 1 to 4 were done under this rule, which still holds for the 21 lines left:

The rule for lines that no test runs is in `modernize-plan.md`, "Lines that no test runs".

#### Steps

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
     names of [`sub-names.md`](#sub-and-function-names). Lines moved without a test: none.
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

#### What it left for later phases

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

### Phase 8: split rules from screen, the steps done

Started 2026-11-11. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

#### How a SUB is split

Moved to `modernize-plan.md`, "How a SUB is split", on 2026-11-13, because it still holds for new code.

#### The list

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

#### Steps

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
  proposed in [`constants.md`](#constants), section 5, for the user to approve.
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
     one of 16 constants, `EVENT_NONE` to `EVENT_STANTON` (`CWS14.BI`, proposed in [`constants.md`](#constants)).
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

### Phase 9: the menus, the steps done

Started 2026-11-12. Each step is one commit (decision 15), and each ends with `play.py check`,
`play.py compare` and the unit tests passing on unchanged recordings. Phase 7's rule for lines that no
test runs still holds.

#### How a menu is split

Moved to `modernize-plan.md`, "How a menu is split", on 2026-11-13, because it still holds for new code.

#### Steps

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
     line, `port-study.md`, [`sub-names.md`](#sub-and-function-names), [`constants.md`](#constants)) and the tools of phases 4 to 6 in
     `tools\refactor\` keep the old names.
   - Unit tests: 123, none new. 38 scripts. Lines moved without a test: none. 185 lines of the
     game are run in part and 18 are not run. That ends phase 9.

### Phase 10: records, the steps done

Closed on 2026-11-12 with no records: every shared array stays an array (user, 2026-11-12). This
overtakes the second half of decision 6.

#### Why no records

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

#### What both compilers do with records

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

#### The script

`tools\refactor\make_records.py` is kept with the others (decision 16), for a later change or
another port. It reads the "Record field" column of [`variable-names.md`](#shared-variable-and-parameter-names), where every row now says
"(stays an array)", and turns `army_size(expr)` into `armies(expr).size`. It uses the tokens of
`rename_vars.py`, so strings and comments stay as they are, and it skips an array that a SUB
declares for itself. The declarations in `cws.bi` are written by hand. It rewrote 437 uses for
`sides`, 370 for `fleets` and `trains` and 578 for `cities` and `leaders`, each with all tests
passing, before they were taken back.

`army_clear` (phase 7, step 4) waited for this phase. It stayed undone, for the reason above: the
places that clear an army did not clear the same fields. It was built on 2026-11-13 (`1f3295b`)
for the six fields they share ("What it left for later phases", under phase 7).

#### Steps

1. **Done: the script, and `sides`.** The eight arrays of a side are one record:
   `sides(s).name`, `.capital`, `.cash`, `.income`, `.city_count`, `.victory_points`,
   `.battles_won` and `.casualties` (a LONG). `cws.bi` has the `TYPE side_type` block and
   `DIM SHARED sides(2) AS side_type`, and the eight arrays are gone from its `COMMON SHARED`
   and `DIM SHARED` lines.
   - **The script,** `tools\refactor\make_records.py`, rewrote 437 uses in 26 files. It reads the
     record and field names from [`variable-names.md`](#shared-variable-and-parameter-names). `report` shows what it would do; `apply`
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
   - [`variable-names.md`](#shared-variable-and-parameter-names): the "Record field" column names a record for the armies only.
   - Unit tests: 123. 38 scripts, unchanged recordings, both compilers.
4. **Closed with no records** (user, 2026-11-12). The army record was not built. No line copies
   or clears a whole army, so it too would only change the spelling of 842 uses ("Why no
   records" above). The seven army rows of [`variable-names.md`](#shared-variable-and-parameter-names) now say
   "(stays an array)" as well, and `make_records.py` stays for a later change or another port.
   `army_clear` (phase 7, step 4) stays undone. No code changed.

### After the plan: the labels

**Done (2026-11-12): the labels.** The game had 148 lines with `GOTO` or `GOSUB` in 19 files.
7 are left, all in `menu_city_select` ([`local-names.md`](#local-variable-parameter-and-label-names), Part 2), and no `GOSUB`. The work was
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

### Open questions

Answered: the commands get a folder of their own, `commands\` (user, 2026-11-12). A command carries
out one order for either side: it calls rules and shows what happened. Examples are
`navy_build_ship`, `army_combine`, `army_recruit` and `railroad_move`, which phase 8 filed in `ui\`.
Nothing in `commands\` opens a menu or reads a key. Phase 9 steps 6 and 7 move them.

### Phase 11: the war's own content

#### Open questions

1. **Texts: code in `game\`, or a data file?** **Data files** (user, 2026-11-13). The events
   are in `scenarios\EVENTS.DAT`, with their rules: the user asked that the code not know which war
   is fought. The other 24 war-naming strings follow the same rule in step 3.

### Original plan: baseline, decisions and phases

Retained on 2026-11-14 as historical context. The numbered decisions below keep their original
numbers; the active plan summarizes the rules that still apply.

Where it starts: branch `qb64rust` at commit `8c3b185`. The game is 5,270 lines in `CWSTRAT.BAS`,
`CWSTRAT1.BM`, `CWSTRAT2.BM`, `CWSMENU.BM` and `CWS14.BI`. It has 361 lines with `GOTO` or `GOSUB`, about 60
shared arrays, no `TYPE` and no `CONST`. `CWSTRAT.BAS` (745 lines) has no SUB of its own.

### Decisions (user, 2026-11-11)

1. **End point: clean and ready for an engine split.** This plan cleans Civil War Strategy only. It gathers
   the war's own content (side names, the map drawing, the victory screens, the tunes, the event texts) in
   its own files. Splitting the engine from the game is a second plan.
2. **Language: QB64, built by both compilers.** The code may use `TYPE`, `CONST`, `FUNCTION`,
   `OPTION _EXPLICIT` and long names. It uses nothing that only QB64Rust accepts, so QB64pe stays a second
   check. The code no longer needs to build in DOS; that source stays on `canonical-source`.
3. **Every step keeps the recorded screens identical.** `python tests\play.py check` must pass with no
   script recorded again. That holds the order of the random numbers and every pixel. The known bugs
   (`TODO.md`, "The game", and the list at the end of [`sub-names.md`](#sub-and-function-names)) are kept. Each is fixed later as its
   own decision with its own new recording. Narrowed on 2026-11-13 (user, [`scenario-plan.md`](#plan-scenarios-in-folders-picked-in-the-game) P1): a
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
   2026-11-12: phase 10 closed with no records ([`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy), "Phase 10"). One exception (user, 2026-11-13):
   the saved game gains the scenario's name as its first field ([`scenario-plan.md`](#plan-scenarios-in-folders-picked-in-the-game), step 3).
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
12. **SUB names: the "Settled names" table of [`sub-names.md`](#sub-and-function-names) is final.** One exception: a SUB that becomes a
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

20. **Phase 3 does all nine groups of [`constants.md`](#constants)**, each group as its own commit. The other side and an
    army's side become two FUNCTIONs, `other_side(side)` and `army_side(army)`. The 16 colors are named and
    used in `COLOR` statements and the menu's color variables; the pictures keep their numbers.
21. **Variable names settled so far** ([`variable-names.md`](#shared-variable-and-parameter-names)): `armylead()` becomes `army_leader_rating()`,
    and `size` becomes `menu_item_count`. The shared `side` becomes `current_side`, so that the parameter
    `who` can become `side`. `matrix()` is split into `city_road()` and `city_is_port()`. `navymove()` is
    dropped in phase 7.

### Phases

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
| 7 | Break up the big pieces | `filer`, `report`, the main module, `navy`, `tupdate`, `smarts`, `events`. `GOSUB` routines become SUBs. The list is "Worth breaking out" in [`sub-names.md`](#sub-and-function-names). |
| 8 | Split rules from screen | Each mixed SUB becomes a rule part and a show part. `rules_test.bas` grows with each rule SUB. |
| 9 | Menus | One menu SUB for each command. It asks the player, then calls a rule SUB. The main module becomes a loop. |
| 10 | Records | Closed with none: the arrays stay arrays ([`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy), "Phase 10"). |
| 11 | The war's own content | Move what another war would replace into `game\`: flags, victory screens, tunes. Move texts, names, limits and the map's line work into data files (decision 19). |

After the plan, each as its own decision: the known bugs, and the engine split.

### File layout at the end

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


### Original split rules from phases 8 and 9

These are the rules as written during those phases, including temporary exceptions that later
steps removed. Current guidance stays in the active plan under the same split headings.

#### How a SUB is split

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
  `SUPPLY_*`, `BLAST_*`; [`constants.md`](#constants), section 5). A yes-or-no flag (`damaged`, `sank`, `halted`,
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
  left them ([`constants.md`](#constants), the end of section 7). Each is used once, and its line says what it does.

#### How a menu is split

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


### Phase 11: the original survey

Moved from the active plan on 2026-11-14. This is the original survey, partly updated as the
event data work finished; its paths and counts are historical.

#### What knows that it is the Civil War, today

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

#### Coverage inventory history

The 11 lines that no test runs (20 before phase 9 step 6, 18 before the last labels went, 17 before
`DIR$` went on 2026-11-13, 15 before the kept bugs were fixed the same day, 12 before `battle_strengths`'
cases were put in order). The table names the SUB, not the line
numbers, because each step moves the lines; `report.txt` has the numbers of the day.

## Constants

Was `docs\archived\constants.md`.

The bare numbers of the game on the `qb64rust` branch (commit `8c3b185`) that stand for a limit, a side, a
kind of behavior or a rule, with a proposed constant for each. This is the table that phase 3 of
`modernize-plan.md` works from. It works like [`sub-names.md`](#sub-and-function-names): a name written in the "Your name" column
replaces Claude's.

"Uses" counts the places in `CWSTRAT.BAS`, `CWSTRAT1.BM`, `CWSTRAT2.BM` and `CWSMENU.BM` where the number
appears with that meaning. A count marked "about" comes from a search pattern and may miss a few.

Constants are written in upper case with a group prefix (decision 18). A constant replaces a number only
where the number has that meaning: `40` as the count of cities becomes `MAX_CITIES`, while `40` as a size
of 4,000 men stays `40`. So each replacement is read, not done by a blind search.

Names in the tables use the SUB names of today. Phase 2 has renamed the SUBs by the time phase 3 runs.

### 1. Sides and limits

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `0` | No side: a neutral city, no fleet raiding. | (read case by case) | `SIDE_NONE` | |
| `1`, `2` | The Union, the Rebels. | (read case by case) | `SIDE_UNION`, `SIDE_REBEL` | |
| `1 TO 2` | A loop over both sides. | 26 | `SIDE_UNION TO SIDE_REBEL` | |
| `3 - who` | The other side. | 60 | `other_side(side)`, a FUNCTION (answer 1) | |
| `40` | The number of cities. | 47 together with the next row; not yet split | `MAX_CITIES` | |
| `40` | The number of army slots. | | `MAX_ARMIES` | |
| `40` | The number of leaders in `cwslead.dat`: the `DIM` and two loops. Added after phase 3 (user, 2026-11-13). | 4 | `MAX_LEADERS` | |
| `20`, `21` | The Union's last army slot and the Rebels' first. | 11 in loops | `ARMIES_PER_SIDE`, and `side_army_range` for the loops | |
| `< 21`, `> 20` | "This army is Union" or "is Rebel". | 33 | `army_side(army)`, a FUNCTION (answer 1) | |
| `6` | The roads a city can have. | about 20 | `MAX_ROADS` | |
| `10` | The most ships in a fleet. | about 8 | `MAX_FLEET_SHIPS` | |
| `2` | The highest fort level. | about 5 | `MAX_FORT` | |
| `10` | The highest supply level and experience. | about 6 | `MAX_SUPPLY`, `MAX_EXPERIENCE` | |
| `9` | The highest leader rating. | 2 | `MAX_LEADER_RATING` | |
| `19999` | The most money a side can hold. | 1 | `MAX_CASH` | |

### 2. Special values

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `navyloc() = 99` | The fleet is at sea, raiding commerce. | about 12 | `FLEET_AT_SEA` | |
| `matrix(c, 7) = 99` | The city is a port. Also written `> 90` and `< 99`. | 5 and about 10 | `PORT_SEA = 99` and `PORT_RIVER = 90`: phase 4 made the column `city_port_type()`, not `city_is_port` ([`variable-names.md`](#shared-variable-and-parameter-names), note 1). | |
| `armymove() = 0` | The army has no order. | (read case by case) | `ORDER_NONE` | |
| `armymove() = -1` | The army cannot be given an order this turn: it drilled, fortified, combined, was just raised or came by train. | 8 | `ORDER_BUSY` | |
| `armymove() = -2` | The army has moved or lost its order in this turn's update. | 2 | `ORDER_DONE` | |
| `choose = -1` | The player left the menu with Esc. | about 10 | `MENU_ESCAPED` | |
| `choose = 99` | The player pressed F7 in a plain menu (end the turn). | 1 set, read in the main module | `MENU_END_TURN_KEY` | |
| `choose = 21 + n` going in | Start the menu on option `n`. Written `choose = 23`. | 55 | `MENU_START + 2`, with `MENU_START = 21` | |
| `choose` = 1 to 3, 1 to 9 after the title and main menus | The rows of the title menu (Resume, New, Quit) and of the main menu (Troops to Files). Also the main menu's start, `MENU_START + row`. Added after phase 3 (user, 2026-11-13). | 29 | `TITLE_RESUME`, `TITLE_NEW_GAME`, `TITLE_QUIT`; `MAIN_TROOPS` … `MAIN_FILES` | |
| `brray() = 999` | The army does not move this turn. | 3 | `MOVE_KEY_NONE` | |
| `icon(999, …)` | No city: draw nothing. | 1 | Deleted: the line above it already sends every city above 40 to `noshow`. | |

Tests by sign keep their numbers: `army_order() > 0` (the army has a city to move to) and `choose < 0` or
`< 1`. The `menu` mode that `newcity` uses returns a letter as a negative number, so `< 0` is not the same
test as `= MENU_ESCAPED`.

### 3. Map marks: the third argument of `icon`

| Number | What `icon` draws | Calls | Proposed | Your name |
|-------:|-------------------|------:|----------|-----------|
| 1 | The dotted white line of a move order, from a city to a city. | 5 | `MARK_MOVE_LINE` | |
| 2 | A yellow box around a city where men were recruited. | 1 | `MARK_RECRUIT` | |
| 3 | An explosion at a city, three times. | 2 | `MARK_EXPLOSION` | |
| 4 | Erase the army's box at a city and its move line. | 6 | `MARK_ERASE_ARMY` | |
| 5 | Erase a move line only. | 2 | `MARK_ERASE_LINE` | |
| 6 | Flash a white frame around a city. | 5 | `MARK_FLASH_FRAME` | |
| 7 | Save what is under the mark, then draw a white box. | 1 | `MARK_BOX` | |
| 8 | Put back what marks 7 and 9 saved. | 4 | `MARK_RESTORE` | |
| 9 | Save what is under the mark, then draw the red arrow pointer. | 5 | `MARK_POINTER` | |
| 11 | A dotted black line: a road between two cities. | 1 | `MARK_ROAD` | |

10 has no case and no caller.

### 4. Menu modes: the argument of `menu`

The mode says what `menu` shows beside the options while the player moves through them.

| Number | What `menu` does | Calls | Proposed | Your name |
|-------:|------------------|------:|----------|-----------|
| 0 | Nothing more. F3 redraws the map, F4 shows the force summary, F7 ends the turn. | 51 | `MENU_PLAIN` | |
| 1 | The options are cities: a white box marks the city. | 2 | `MENU_CITY_BOX` | |
| 2 | The options are cities: a pointer marks the city, and the army there is named with its size. | 2 | `MENU_CITY_ARMY` | |
| 3 | Returns the key itself: up, down, Enter, or a letter as a negative number. Used by `newcity`. | 1 | `MENU_RAW_KEYS` | |
| 4 | The options are armies: `armystat` shows the army's figures. | 1 | `MENU_ARMY_STATS` | |
| 5 | Prints an army's experience and the cash. No caller passes it. | 0 | Delete the case in phase 1. | |
| 6 | The options are armies: a pointer marks the army's city. | 2 | `MENU_ARMY_POINTER` | |
| 8 | The difficulty menu: shows a general's face for each level. | 1 | `MENU_FACES` | |
| 9 | The options are cities: a pointer marks the city. | 5 | `MENU_CITY_POINTER` | |

`wtype`, the kind of box: 0 no line, 1 a single line, 2 a double line. Every caller sets 2. Proposed:
`BOX_DOUBLE = 2`, and the cases for 0 and 1 stay until phase 9.

### 5. Other behavior codes

| Where | Numbers | Meaning | Proposed | Your name |
|-------|---------|---------|----------|-----------|
| `navy (who, chx)` | 0 | The player's Ships menu. | `NAVY_ASK`, until phase 9 gave the player's menu its own SUB. | |
| | 1 to 5 | The computer's action: build, attack a port, sail, raid commerce, invade. | `NAVY_BUILD`, `NAVY_ATTACK`, `NAVY_SAIL`, `NAVY_RAID`, `NAVY_INVADE` | |
| `scribe (a$, flag)` | 0, 1, 2 | Write to the history only; also show on the bottom line; also show in a box. | `SHOW_NOT`, `SHOW_LINE`, `SHOW_BOX` | `SHOW_HISTORY_ONLY` for 0 (user, 2026-11-12) |
| `filer (switch)` | 1, 2, 3 | New game, load, save. | None: phase 7 splits `filer` into three SUBs. | |
| `report (who)` | -1, 100 + side | Go straight to the force summary; to the battle summary. | None: phase 7 gives each report a SUB. | |
| `tinytrain`, `snapshot`, `animate` | 0, 1 | Erase or draw; save or restore; for `animate`, take the army's picture from its city first, or use the one taken already (not march or retreat: both pass 0). | `DRAW_ERASE = 0`, `DRAW_SHOW = 1`; `SNAP_SAVE = 0`, `SNAP_RESTORE = 1`; `ANIMATE_TAKE_PICTURE = 0`, `ANIMATE_PICTURE_TAKEN = 1` (user, 2026-11-11) | |
| `flags (who, w, a)` | `w` | An offset in pixels, or below 0 for a small flag at `-w`. | None in phase 3: the SUB is reworked in phase 8. | |
| `army_combine_add`'s `status` (phase 8) | 0, 1, 2 | The army does not join; it would make army 0 more than 125,000 men; it joins. | `COMBINE_SKIPPED`, `COMBINE_TOO_LARGE`, `COMBINE_JOINED` | |
| `army_buy_supply`'s `result` (phase 8) | -1, 0, 1 | The army is cut off under the Realism setting; the cash is not enough; supplies were bought. | `SUPPLY_CUT_OFF`, `SUPPLY_NO_CASH`, `SUPPLY_BOUGHT` | |
| `navy_blast`'s `result` (phase 8) | 0, 1, 2 | The city stands firm; it is the other side's capital and stays loyal; it turns neutral. | `BLAST_FIRM`, `BLAST_LOYAL`, `BLAST_NEUTRAL` | `BOMBARD_HOLDS`, `BOMBARD_CAPITAL_HOLDS`, `BOMBARD_TURNS_NEUTRAL` (user, 2026-11-12) |
| `menu_files`' `action` (phase 9) | 0, 1, 2 | Back to the main menu; a new game; the program ends. | `FILES_BACK`, `FILES_NEW_GAME`, `FILES_QUIT` | |
| `event_roll`'s `event` (phase 8) | 0 to 15 | No event; ironclads available; riots; English ships; mercenaries; a loan; cotton sales; the uprising; Union shipworks; volunteers; the Emancipation Proclamation; Lincoln reelected; donations; Rebel deserters; repeating rifles; Stanton's prediction. | `EVENT_NONE`, `EVENT_IRONCLADS`, `EVENT_RIOTS`, `EVENT_ENGLISH_SHIPS`, `EVENT_MERCENARIES`, `EVENT_LOAN`, `EVENT_COTTON`, `EVENT_UPRISING`, `EVENT_SHIPWORKS`, `EVENT_VOLUNTEERS`, `EVENT_EMANCIPATION`, `EVENT_REELECTION`, `EVENT_DONATIONS`, `EVENT_DESERTERS`, `EVENT_RIFLES`, `EVENT_STANTON` | Since 2026-11-13 only `EVENT_NONE` is left. The events, the ironclads' announcement among them, are rows of `scenarios\EVENTS.DAT`, found by name with `event_find`. |

### 6. Settings and victory rules

| Variable | Numbers | Meaning | Proposed | Your name |
|----------|---------|---------|----------|-----------|
| `graf` | 0, 1, 2, 3 | Off; basic; city names; full, with pictures. | `GRAPHICS_OFF`, `GRAPHICS_BASIC`, `GRAPHICS_NAMES`, `GRAPHICS_FULL` | |
| `noise` | 0, 1, 2 | Off; effects; effects and music. | `SOUND_OFF`, `SOUND_EFFECTS`, `SOUND_MUSIC` | |
| `realism` | 0, 1, 2 | Off; on; on, and the computer is more careful. | `REALISM_OFF`, `REALISM_ON`, `REALISM_HIGH` | |
| `player` | 1, 2 | One player against the computer; two players. | `PLAYERS_ONE`, `PLAYERS_TWO` | |
| `vicflag(1)` to `(6)` | 1 to 6 | Month and year of the time limit, cities, income, capital, force ratio. 43 uses. | `VICTORY_MONTH`, `VICTORY_YEAR`, `VICTORY_CITIES`, `VICTORY_INCOME`, `VICTORY_CAPITAL`, `VICTORY_FORCE_RATIO` | |
| `victory_rule_met`'s `rule` | 2 to 6, 7 | The rule that was met: the same numbers as `victory_rule()` (`victory_play_on` adds 1 to `victory_rule(rule)`). 7: the enemy has no men left. Added after phase 3 (user, 2026-11-13). | `VICTORY_YEAR` to `VICTORY_FORCE_RATIO`, and `VICTORY_WIPED_OUT` | |
| `opt_difficulty` | 3 | The middle level, where neither side gets help. The tests are `< 3` and `> 3`; the formulas beside them keep their numbers. Added after phase 3 (user, 2026-11-13). | `DIFFICULTY_EVEN` | |

`graf`, `noise` and `realism` are compared with a number in 79 places, often as `> 0` or `> 2`.
`graf > 2` becomes `graf >= GRAPHICS_FULL`: the same test, written with the level it means.

### 7. Rule numbers

These are the Civil War's own numbers. Phase 3 names them in `CWS14.BI`; phase 11 moves them to `game\`
(decision 19).

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `100` | The price of raising an army or adding men. | about 12 | `COST_RECRUIT` | |
| `100` | The price of a wooden ship; an ironclad costs twice that. | 1 | `COST_SHIP` | |
| `200` | The price of a fort level. | 5 | `COST_FORT` | |
| `500` | The price of moving the capital. | 2 | `COST_MOVE_CAPITAL` | |
| `100` | The income a side gets for holding its capital. | 2 | `CAPITAL_INCOME` | |
| `1861` | The first year. | 3 | `FIRST_YEAR` | |
| `1862`, month 3 | When ironclads can be built. | 3 | `IRONCLAD_YEAR`, `IRONCLAD_MONTH` | |
| `65` | The smallest army that can detach a part. | 1 | `MIN_DETACH_SIZE` | |
| `5` | The supply level that Resupply fills to. | 2 | `RESUPPLY_LEVEL` | |

Added after phase 3 (user, 2026-11-13):

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `1250` | The largest army that Combine makes: 125,000 men. | 1 | `MAX_ARMY_SIZE` | |
| `15` | Below 1,500 men an army fights at half strength, and the computer will not attack with it. | 3 | `SMALL_ARMY_SIZE` | |
| `2`, `12` | The months a turn takes, and the months of a year. | 3 | `MONTHS_PER_TURN`, `MONTHS_PER_YEAR` | |

The months in the season rules (`turn_month < 7 OR turn_month > 10`, "No campaigns in January") and the
events' dates keep their numbers.

Not named in phase 3: the factors inside the formulas of `battle`, `evaluate`, `smarts` and `events`
(`.3 * armylead(attack)`, `IF RND > .9`). Each is used once and its line says what it does. They are looked
at again in phase 8, when the rule SUBs are split out.

### 8. Colors

`COLOR n` appears 171 times with 15 values. The most used: 11 light cyan (57, messages), 14 yellow (32),
15 white (23), 7 gray (11), 12 light red (11). The drawing statements (`LINE`, `PSET`, `CIRCLE`, `PAINT`,
`DRAW`) carry about 1,000 more color numbers.

Settled (answer 2): constants for the 16 colors, `COLOR_BLACK` to `COLOR_WHITE`, used in the `COLOR`
statements and in the menu variables (`colour`, `hilite`). The pictures (`cannon`, `schooner`, `usa` and
the like) keep their numbers: there a number is a pixel's color in a drawing, and phase 11 turns the map's
lines into data anyway.

### 9. Keys and pauses

| Number or text | Meaning | Uses | Proposed | Your name |
|----------------|---------|-----:|----------|-----------|
| `ASC(a$) = 13`, `= 27` | Enter, Esc. | about 12 | `KEY_ENTER`, `KEY_ESC` | |
| `"H"`, `"P"`, `"I"`, `"Q"` after a 0 byte | Up, Down, Page Up, Page Down. | 6 | `KEY_UP$`, `KEY_DOWN$`, `KEY_PAGE_UP$`, `KEY_PAGE_DOWN$` | |
| `"="`, `">"`, `"A"` after a 0 byte | F3, F4, F7. | 3 | `KEY_F3$`, `KEY_F4$`, `KEY_F7$` | |
| `TICK 9` | A long pause that a key ends. | 13 | `PAUSE_LONG` | |
| `TICK 99` | Wait for a key. | 2 | Goes away in phase 7, with `wait_key` ([`sub-names.md`](#sub-and-function-names), "Waiting for a key"). Phase 3 left it: outside a script, `TICK 99` gives up after 99 seconds, which the key loops do not. | |
| `tlx = 67` | The column of the right panel, where most menus go. | 22 | `PANEL_COL` | |

### Answers (user, 2026-11-11)

1. **The other side, and an army's side: two FUNCTIONs.** `3 - who` (60 places) becomes
   `other_side(side)`, and `attack > 20` (33 places) becomes `army_side(attacker) = SIDE_REBEL`. A FUNCTION
   call draws no random number and no pixel, so the screens stay identical. Another war that does not
   split its armies 20 and 20 then changes one FUNCTION.
2. **Colors: the 16 are named and used in text only.** `COLOR_BLACK` to `COLOR_WHITE` go into the `COLOR`
   statements and the menu's color variables. The pictures keep their numbers.
3. **Phase 3 does all nine groups**, each group as its own commit.
4. **The proposed names are taken as they stand.** No name in the "Your name" column (user, 2026-11-11).

## Shared variable and parameter names

Was `docs\archived\variable-names.md`.

Every shared variable of the game on the `qb64rust` branch (commit `8c3b185`), with what it holds and a
proposed name. This is the table that phase 4 of `modernize-plan.md` renames from. It works like
[`sub-names.md`](#sub-and-function-names): the "Your name" column is empty, and a name written there replaces Claude's.

The shared variables are declared in `CWS14.BI`. "Uses" counts where the name appears in `CWSTRAT.BAS`,
`CWSTRAT1.BM`, `CWSTRAT2.BM` and `CWSMENU.BM`. "Record field" was the name the variable would get in phase 10.
Phase 10 closed with no records, so every array stays an array (user, 2026-11-12; "Why no records"
in `modernize-plan.md`).

Rules the proposals follow (decisions 17 and 18 of the plan):

- The subject comes first, in snake_case: `army_`, `city_`, `side_`, `fleet_`, `train_`, `menu_`, `opt_`,
  `turn_`, `pic_`.
- An array indexed by side (1 Union, 2 Rebel) starts with `side_`, unless it belongs to the fleet or the
  train, which each side has one of.
- A setting that `CWS.CFG` saves starts with `opt_`.
- A name says what the value is, not its type: `army_city`, not `army_loc`.

### Armies

Indexed by army, 1 to 40. Armies 1 to 20 are Union, 21 to 40 Rebel. Index 0 is a scratch army in `combine`.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `armyname$()` | The army's name, which is its leader's name. Empty when the slot is free. | 76 | `army_name$()` | (stays an array) | |
| `armysize()` | Its size in hundreds of men. 0 when the slot is free. | 139 | `army_size()` | (stays an array) | |
| `armylead()` | Its leader's rating, 1 to 9. | 35 | `army_leader_rating()` | (stays an array) | settled 2026-11-11 (first proposal `army_leadership()`, your note `armies(i).leader`) |
| `armyexper()` | Its experience, 0 to 10. | 49 | `army_experience()` | (stays an array) | |
| `supply()` | Its supply level, 0 to 10. | 72 | `army_supply()` | (stays an array) | |
| `armyloc()` | The city it is in. 0 when the slot is free. | 143 | `army_city()` | (stays an array) | |
| `armymove()` | Its order: the city it marches to, 0 for none, or below 0 when it cannot move this turn (it drilled, fortified, was just raised, or came by train). | 88 | `army_order()` | (stays an array) | |
| `lname$()` | The leaders not yet used, by army slot. A slot's entry is emptied when its leader takes an army. | 24 | `leader_name$()` | (stays an array) | |
| `rating()` | The rating of the leader in `lname$()`. | 13 | `leader_rating()` | (stays an array) | |
| `brray()` | The order of movement for this turn: one sort key for each army, sorted by `bub2`. | 24 | `move_order_key()` | (stays an array) | |

### Cities

Indexed by city, 1 to 40.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `city$()` | The city's name. `city$(0)` is "NONE". | 86 | `city_name$()` | (stays an array) | |
| `cityx()`, `cityy()` | Its place on the screen, in pixels. | 37, 46 | `city_x()`, `city_y()` | (stays an array) | |
| `cityv()` | Its value: income each turn and victory points. | 21 | `city_value()` | (stays an array) | |
| `cityp()` | Its owner now: 0 neutral, 1 Union, 2 Rebel. | 73 | `city_owner()` | (stays an array) | |
| `cityo()` | Its owner when the game began. | 3 | `city_first_owner()` | (stays an array) | |
| `fort()` | Its fort level, 0 to 2. | 44 | `city_fort()` | (stays an array) | |
| `occupied()` | The first army found in the city, or 0. Set by `occupy`. | 59 | `city_army()` | (stays an array) | |
| `matrix()` | `matrix(c, 1 TO 6)`: the cities joined to city `c` by road, 0 for none. `matrix(c, 7)`: 99 when the city is a port. | 43 | `city_road()` and `city_port_type()` (see note 1) | (stays an array) | |
| `capcity()` | By side: the side's capital city, 0 when it has fallen. | 37 | `side_capital()` | (stays an array) | |

### Sides

Indexed by side: 1 Union, 2 Rebel.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `force$()` | The side's name: "Union", "Rebel". | 45 | `side_name$()` | (stays an array) | |
| `cash()` | Its money. | 89 | `side_cash()` | (stays an array) | |
| `income()` | Its income this turn. | 28 | `side_income()` | (stays an array) | |
| `control()` | The number of cities it holds. | 31 | `side_city_count()` | (stays an array) | |
| `victory()` | Its victory points. | 72 | `side_victory_points()` | (stays an array) | |
| `batwon()` | Battles it has won. | 13 | `side_battles_won()` | (stays an array) | |
| `casualty&()` | Men it has lost. | 15 | `side_casualties&()` | (stays an array) | |
| `vptotal` | The two sides' incomes added, used for percentages in the reports. | 6 | `total_income` | (stays a scalar) | |
| `usadv` | The Union's income bonus, set from the difficulty. | 9 | `union_income_bonus` | `game\` (phase 11) | |
| `emancipate` | 1 once the Emancipation Proclamation event has happened. | 3 | `emancipation_done` | `game\` (phase 11) | Became `event_done()`, one flag for each event, on 2026-11-13. |

### Navy

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `fleet$()` | By side: one letter for each ship, "W" wooden or "I" ironclad. | 41 | `fleet_ships$()` | (stays an array) | |
| `navysize()` | By side: the number of ships. Kept equal to `LEN(fleet$())`. | 82 | `fleet_size()` | (stays an array) | |
| `navyloc()` | By side: the port city the fleet is in, 0 for no fleet, 99 for at sea raiding commerce. | 96 | `fleet_city()` | (stays an array) | |
| `navymove()` | By side: set to 0 and saved, never read. | 4 | `fleet_unused()` (see note 2) | none | |
| `commerce` | The side whose fleet is raiding commerce, or 0. | 27 | `raiding_side` | (stays a scalar) | |
| `raider` | The money the raiders sank this turn. | 9 | `raid_loss` | (stays a scalar) | |
| `grudge` | 1 when the last sea fight left a fleet that the computer should go after. | 8 | `fleet_pursuit` | (stays a scalar) | |

### Railroad

Indexed by side.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `rr()` | The army on the side's train, or 0. | 21 | `train_army()` | (stays an array) | |
| `rrfrom()` | The city the train left. | 4 | `train_from_city()` | (stays an array) | |
| `tracks()` | The city where the train icon is drawn. | 7 | `train_city()` | (stays an array) | |
| `train()` | The largest army the side's train can carry (from `CWS.CFG`). | 11 | `train_capacity()` | (stays an array) | |

### The turn and the game

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `month`, `year` | The date. | 30, 30 | `turn_month`, `turn_year` | | |
| `month$()` | The months' names. | 14 | `month_name$()` | | |
| `side` | The side that gives orders now: the human's side in a one-player game, each side in turn in a two-player game. | 163 | `current_side` (see note 3) | | |
| `player` | The number of human players, 1 or 2. | 32 | `opt_players` | | |
| `rflag` | Recruiting this turn: 0 not yet offered, above 0 the number of cities on offer, below 0 no more. | 11 | `turn_recruit_state` | | |
| `rcity()` | The cities on offer for recruiting this turn. | 2 | `turn_recruit_city()` | | |
| `mflag` | Above 0 when no army is left to give a move order to. | 5 | `turn_moves_done` | | |
| `nflag` | Above 0 when the navy has acted this turn. | 10 | `turn_navy_done` | | |
| `aggress!` | The computer's strength against the player's, as a ratio. It makes the computer bolder. | 14 | `ai_strength_ratio!` | | |
| `pcode` | 1 when the game is over and a new one must start. | 3 | `game_over` | | |
| `thrill` | The victory condition that ended the game, marked in the last report. | 2 | `victory_reason` | | |
| `vicflag()` | The victory conditions: (1) month and (2) year of the time limit, (3) a number of cities, (4) a percent of the total income, (5) capital captured, (6) force ratio. Above 0 means on. | 50 | `victory_rule()` | | |
| `filel` | 0 when no saved game was found, so Load shows as "-". | 4 | `saves_exist` | | |
| `scripted` | 1 when `tests\play.py` runs the program. | (in `SCRIPT.BM`) | `scripted` (kept) | | |

### Settings

Saved in `CWS.CFG`, except `bw`.

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `graf` | Graphics level, 0 to 3: 0 off, 2 city names, 3 full with pictures. | 23 | `opt_graphics` | |
| `noise` | Sound: 0 off, 1 effects, 2 effects and music. | 49 | `opt_sound` | |
| `difficult` | Difficulty, 1 to 5. | 30 | `opt_difficulty` | |
| `turbo!` | The length of a pause, in seconds. | 58 | `opt_pause!` | |
| `randbal` | Random events: 0 off, else how far they favor a side. | 23 | `opt_event_balance` | |
| `jancam` | 1 when campaigns in January and February are allowed. | 10 | `opt_winter_campaigns` | |
| `realism` | Realism, 0 to 2. | 27 | `opt_realism` | |
| `history` | 1 when messages are written to `cws.his`. | 12 | `opt_history` | |
| `bold` | The computer's aggression, 0 to 5. | 19 | `opt_ai_aggression` | |
| `bw` | 1 for the alternate colors of menus and city names. | 6 | `opt_alt_colors` | |
| `ATKFAC`, `DEFAC` | The attacker's and the defender's loss factors, read from `CWS.INI`. | 2, 2 | `rule_attack_loss`, `rule_defend_loss` | |
| `TCR` | The cap on an army's strength in a battle, read from `CWS.INI`. | 25 | `rule_strength_cap` | |

### Menus

`menu` takes its input and gives its answer through these shared variables.

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `mtx$()` | The menu's title (0) and its options (1 and up). Also used as scratch text. | 227 | `menu_text$()` | |
| `size` | The number of options. | 163 | `menu_item_count` | settled 2026-11-11 (first proposal `menu_count`, your note `menu_items`) |
| `choose` | Going in: 21 plus the option to start on. Coming out: the option picked, below 1 for none. | 176 | `menu_choice` | |
| `array()` | A value for each option, such as the city or army it stands for. | 68 | `menu_value()` | |
| `tlx`, `tly` | The column and row of the menu's top left corner. | 83, 83 | `menu_col`, `menu_row` | |
| `colour` | The color of the menu's box. | 36 | `menu_color` | |
| `hilite` | The color of the chosen option. | 18 | `menu_highlight` | |
| `wtype` | The kind of box: 2 with a title bar; above 10 it also carries the box color. | 13 | `menu_box_type` | |

### Pictures and drawing

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `graphic()` | A picture loaded with `BLOAD`: the icon sheet, then a general's face before a battle. | 6 | `pic_loaded()` | |
| `graft()` | A picture loaded by `menu`: a leader's face (case 8). | 3 | `pic_face()` | |
| `mtn()` | The mountain picture, drawn 8 times by `usa`. | 10 | `pic_mountain()` | |
| `Ncap()` | The capital's star, cut from the icon sheet. | 2 | `pic_capital()` | |
| `image()` | The piece of screen saved under a map marker or a moving army. | 8 | `saved_under_marker()` | |
| `anima()` | The piece of screen saved under an army's icon. | 4 | `saved_under_army()` | |
| `font$()` | The `DRAW` string of each letter, A to Z, of the map's own font. | 4 | `map_font$()` | |
| `starx()`, `stary()` | Where the 8 stars go on the Rebel flag of the victory screen (from `CWS.INI`). | 2 | `flag_star_x()`, `flag_star_y()` | |

### Unused

| Current | Finding | Proposed |
|---------|---------|----------|
| `price()` | Declared, never used. | Delete in phase 1. |
| `DECLARE SUB banner`, `blastem`, `sndblst`, `sndfx`, `usamap`, `war` | No such SUB exists. QB64 needs no `DECLARE` lines at all. | Delete every `DECLARE` in phase 1. |

### Parameters

A parameter gets the name of what is passed, the same in every SUB.

| Current | Where | What is passed | Proposed |
|---------|-------|----------------|----------|
| `who` | 17 SUBs | A side, 1 or 2. | `side` (see note 3) |
| `s` | `capture`, `image2` | In `capture` a side; in `image2` a number of seconds. | `side`; `seconds` |
| `index` | `animate`, `armystat`, `strong`, `resupply`, `evaluate`, `movefrom` | An army. | `army` |
| `index` | `newcity` | A city, in and out. | `city` |
| `which` | `placearmy` an army; `flashcity` a city | | `army`; `city` |
| `attack`, `defend` | `battle`, `retreat` | The attacking and the defending army. | `attacker`, `defender` |
| `win`, `lose` | `battle` | The armies that won and lost, out. | `winner`, `loser` |
| `target` | `cutoff`, `fortify`, `newarmy`, `movefrom`, `roman` | A city (in `roman` an army). | `city`; `army` in `roman` |
| `from`, `dest` | `icon` | Two cities. | `from_city`, `to_city` |
| `kind` | `icon` | Which mark to draw, 1 to 11. | `mark` (with the `MARK_` constants) |
| `switch` | `menu` | What to show beside the highlighted item, a bare number (3 changes how keys return). | `menu_item_show_beside` (with constants) |
| `switch` | `filer` | Which job: 1 scenario, 2 load, 3 save. | `job` (with constants) |
| `chx` | `navy` | The naval action the computer wants, 0 for the player's menu. | `action` |
| `empty` | `newarmy`, `commander` | A free army slot. | `slot` |
| `flag` | `animate`, `snapshot`, `tinytrain`, `scribe`, `shipicon`, `capture` | A different yes-or-no or choice in each. | Named in each SUB: `show` (draw_train), `ship_type` (draw_ship_icon), `background_saved` (animate_army), `weaken_fort` (city_capture), `display` (scribe_message), `put_back` (screen_snapshot). |
| `a`, `x`, `y`, `limit`, `result` | `cutoff`, `void`, `evaluate`, `retreat`, `traincapacity`, `normal` | The value the SUB gives back. | Goes away in phase 5, when the SUB becomes a FUNCTION. |
| `x`, `y`, `z` | `armyxy`, `snapshot` | A screen position; `z` a side. | `x`, `y` kept; `z` to `side` |
| `a$` | `center`, `image2`, `scribe`, `roman` | A text. | `text$`; `name$` in `roman` |
| `sec!` | `TICK` | Seconds. | `seconds!` |

### Notes

1. **`matrix()` holds two things.** Columns 1 to 6 are roads and column 7 is the port mark. The proposal
   splits it into `city_road(c, 1 TO 6)` and `city_port_type(c)`. Column 7 is not a yes-or-no: it is 0 for
   no port, 90 for a river port and 99 for a sea port (`cities.grd`), so it is `city_port_type`, not
   `city_is_port`. That is more than a rename: each `matrix(i, 7) = 99` becomes `city_port_type(i) = 99`. The split is its own step in phase 4, after the plain
   renames. `maxx` also uses `matrix()` as scratch space for the Hall of Fame's scores; it gets a local
   array of its own in the same step.
2. **`navymove()` is never read**, but `filer` writes it to the saved game, and the save format is frozen
   (decision 6). It could become a constant 0 in the `WRITE #` and a dummy in the `INPUT #`, and the array
   could go. That is proposed for phase 7, when `filer` is split. Done in phase 7 step 1.
3. **`side` and `who`.** Today the shared `side` is "the side that gives orders now", and 17 SUBs take a
   parameter `who` for "the side this call is about". Decision 11's example renames `who` to `side`. Both
   cannot be `side`, so the shared one becomes `current_side`. The rename script must do the shared one
   first. `cancel (side)` already has a parameter with the shared variable's name; it keeps `side`.
4. **`mtx$()` and `array()` as scratch.** Several SUBs use them for things that are not a menu (`endit`
   keeps texts in `mtx$(8)` and `mtx$(9)`; `bubble` sorts both). They are renamed as menu variables now.
   A SUB that misuses them gets locals when it is reworked.
5. **Locals with the same name as a shared variable.** The rename script works on tokens, so it must know
   scope: a parameter or a `DIM` inside a SUB hides the shared name. Known case: `cancel (side)`. Turning on `OPTION _EXPLICIT` at the end of phase 4 finds any that were missed.

## SUB and FUNCTION names

Was `docs\archived\sub-names.md`.

Every SUB and FUNCTION of the game on the `qb64rust` branch (commit `8c3b185`), with what it does. The test
program `tests\rules_test.bas` is left out. The new names are in "Settled names" below.

All are SUBs except the three marked FUNCTION. Armies 1 to 20 are Union and 21 to 40 are Rebel. Side 1 is the
Union and side 2 is the Rebels.

| Name | File | What it does |
|------|------|--------------|
| `choices` | CWSMENU.BM | Draws a menu's box and prints its title and its options. |
| `ironclad` | CWSMENU.BM | Draws the picture of an ironclad at sea on the lower half of the screen, shown when a fleet led by an ironclad sails. |
| `menu` | CWSMENU.BM | Shows the menu held in `mtx$()`, lets the player pick an option with the arrow keys or a letter, and returns the pick in `choose`. |
| `mxw` | CWSMENU.BM | Returns the width a menu needs: the length of its longest option or of its title. |
| `schooner` | CWSMENU.BM | Draws the picture of a wooden sailing ship on the lower half of the screen, shown when a fleet led by a wooden ship sails. |
| `animate` | CWSTRAT1.BM | Moves an army's icon in steps along the road from its city toward the city it is marching to. |
| `armies` | CWSTRAT1.BM | Takes the player's move order: the player picks an army and a neighboring city, and the move is recorded. |
| `armystat` | CWSTRAT1.BM | Prints an army's name, size, leader rating, experience and supply in the right panel. |
| `barnacle` | CWSTRAT1.BM | Removes one ship from a side's fleet, and clears the fleet when no ship is left. |
| `battle` | CWSTRAT1.BM | Fights a land battle: shows both armies' strengths and the odds, picks the winner, takes the losses from both armies and records the result. |
| `combine` | CWSTRAT1.BM | Merges a side's armies that stand in one city into a single army under the best leader. |
| `cutoff` | CWSTRAT1.BM | Counts the neighboring cities that a side holds; a count of 0 means the city is cut off. |
| `filer` | CWSTRAT1.BM | Reads the scenario and settings for a new game, loads a saved game, or saves the game, as its argument says. |
| `flashcity` | CWSTRAT1.BM | Flashes a city's dot through several colors, then draws it in its owner's color. |
| `fortify` | CWSTRAT1.BM | Lets the player pick a city that holds one of their armies and pay 200 to raise its fort level, up to 2. |
| `icon` | CWSTRAT1.BM | Draws or erases a marker on the map, chosen by `kind`: a move line, a recruiting box, an explosion, a highlight box, an arrow pointer or a road. |
| `iterate` | CWSTRAT1.BM | Ends the turn: moves the date on two months, pays for and uses up each army's supplies, and works out the ratio of the two sides' strengths. |
| `movefrom` | CWSTRAT1.BM | Lets the player pick a city and, when several armies stand there, which army to give an order to. |
| `navy` | CWSTRAT1.BM | Runs the naval commands for the player or the computer: build a ship, bombard a city, sail, raid commerce, invade, and fight the other fleet. |
| `newarmy` | CWSTRAT1.BM | Creates a new army in a city with its leader, size, experience and supply, and charges the side 100. |
| `newcity` | CWSTRAT1.BM | Lets the player step through their own cities with the arrow keys or a first letter and choose one, used for a train's destination. |
| `normal` | CWSTRAT1.BM | Returns a random number from a roughly normal distribution with the given mean and variance. |
| `placearmy` | CWSTRAT1.BM | Draws an army's flag icon at its city, with an "S" on it when the army is out of supplies. |
| `railroad` | CWSTRAT1.BM | Starts a train move for the player or the computer, or finishes the one under way when the army arrives. |
| `recruit` | CWSTRAT1.BM | Offers a few cities for recruiting and spends 100 for each pick, which raises a new army there or adds men to the army already there. |
| `shiptype` | CWSTRAT1.BM | Draws one ship of a fleet as a wooden ship or an ironclad, according to its letter in `fleet$`. |
| `showcity` | CWSTRAT1.BM | Draws all 40 cities in their owners' colors with their fort marks, the capitals, and the roads between cities. |
| `smarts` | CWSTRAT1.BM | Plays the computer's turn: special events, supplies, forts, recruiting, the navy, combining armies, a train move and a move order for each army. |
| `snapshot` | CWSTRAT1.BM | Saves the small square of screen around a point, or puts the saved square back. |
| `strong` | CWSTRAT1.BM | Prints an army's size in men: its size number followed by "00". |
| `tinytrain` | CWSTRAT1.BM | Draws or erases the small train icon at the city where a side's train is. |
| `tupdate` | CWSTRAT1.BM | Carries out the turn: armies move in order of speed, battles are fought, losers retreat or surrender, cities are captured, raiders sink commerce and victory points are updated. |
| `armyxy` | CWSTRAT2.BM | Draws a small Union or Rebel flag icon at a screen position. |
| `bub2` | CWSTRAT2.BM | Sorts the numbers in `brray()` into rising order with a bubble sort. |
| `bubble` | CWSTRAT2.BM | Sorts the menu texts in `mtx$()` alphabetically and keeps `array()` in step with them. |
| `cancel` | CWSTRAT2.BM | Lets the player pick one of their armies that has a move order and cancels the order. |
| `cannon` | CWSTRAT2.BM | Draws the picture of a cannon in the right panel before a battle. |
| `capitol` | CWSTRAT2.BM | Draws the Union victory screen: the Capitol, a quotation from Lincoln and a row of flags, with music. |
| `capture` | CWSTRAT2.BM | Gives a city to the side that took it, adds its victory points, and handles the fall of a capital. |
| `center` | CWSTRAT2.BM | Prints a text centered on a given row of the end-of-game box. |
| `chessie` | CWSTRAT2.BM | Draws the coastline of Chesapeake Bay on the map. |
| `clrbot` | CWSTRAT2.BM | Clears the message line at the bottom of the screen and leaves the cursor at its start. |
| `clrrite` | CWSTRAT2.BM | Clears the panel on the right of the screen. |
| `commander` | CWSTRAT2.BM | Finds a free army slot with an unused leader for a side, and makes up a leader such as "Union IV" when the list is used up. |
| `endit` | CWSTRAT2.BM | Shows the menu where the player turns each victory condition on or off. |
| `engine` | CWSTRAT2.BM | Draws the box at the top left that shows each side's train and where it is going. |
| `evaluate` | CWSTRAT2.BM | Scores each neighboring city as a move for one of the computer's armies and returns the best one, or 0 to stay. |
| `events` | CWSTRAT2.BM | Announces that ironclads are available in 1862, and otherwise may bring a random special event that changes a side's ships, men, cash or victory points. |
| `flags` | CWSTRAT2.BM | Draws a Union or Rebel flag in the right panel, with the side's name under it when it is the main flag. |
| `image2` | CWSTRAT2.BM | Shows a message in a box in the middle of the screen for a few seconds, then puts back what was under it. |
| `integrity` | CWSTRAT2.BM | Checks that every road on the map has a road back, adds the missing ones where there is room, and reports the rest. |
| `maptext` | CWSTRAT2.BM | Draws each city's name under it on the map with the game's own line font. |
| `maxx` | CWSTRAT2.BM | Shows the Hall of Fame, adds the game's scores to it when they qualify, saves it to `hiscore.cws` and marks the game as over. |
| `occupy` | CWSTRAT2.BM | Sets `occupied()` for a city to the first army found there, or to 0 when there is none. |
| `relieve` | CWSTRAT2.BM | Lets the player replace an army's leader with an unused one, at the cost of one point of leadership and one of experience. |
| `report` | CWSTRAT2.BM | Shows the Information menu and its reports: either side's armies, the cities, forces by city, army details on the map, the battle summary and the history of the game. |
| `resupply` | CWSTRAT2.BM | Buys supplies for an army from its side's cash, up to a supply level of 5. |
| `retreat` | CWSTRAT2.BM | Lets the human owner of a beaten army choose the neighboring friendly city it retreats to. |
| `roman` | CWSTRAT2.BM | Builds a made-up army name from an army's number, such as "Union IV" or "Rebel XII". |
| `rwin` | CWSTRAT2.BM | Draws the Rebel victory screen: the Confederate flag over a landscape with a mansion, with "Dixie". |
| `scribe` | CWSTRAT2.BM | Shows a message on the bottom line or in a box, and adds it to the history file `cws.his` when history is on. |
| `shen` | CWSTRAT2.BM | Plays "Shenandoah" when music is on, and stops between phrases if a key is pressed. |
| `shipicon` | CWSTRAT2.BM | Draws a wooden ship or an ironclad with its side's flag at the current drawing position. |
| `ships` | CWSTRAT2.BM | Draws each side's fleet icon on the map at the place where the fleet is. |
| `starfin` | CWSTRAT2.BM | Returns the first and last army numbers of a side: 1 and 20 for the Union, 21 and 40 for the Rebels. |
| `stax` | CWSTRAT2.BM | Draws a small yellow circle at each city where a side has more than one army. |
| `surrender` | CWSTRAT2.BM | Draws the surrender picture in the right panel, an officer giving up his saber, with the winner's flag. |
| `TICK` | CWSTRAT2.BM | Waits for a number of seconds or until a key is pressed. |
| `topbar` | CWSTRAT2.BM | Draws the top line and the right panel for the player's turn: the date, the flag, the difficulty, the funds, the victory points and the key hints. |
| `touchup` | CWSTRAT2.BM | Redraws stretches of coast and river on the map that an erased icon may have wiped out. |
| `traincapacity` | CWSTRAT2.BM | Returns the largest army that a side's railroad can carry. |
| `usa` | CWSTRAT2.BM | Draws the whole map: state borders, coast, rivers, mountains, cities, city names, armies, fleets and trains. |
| `victor` | CWSTRAT2.BM | Checks the victory conditions, warns when a side is close to one, and runs the end of the game when one is met. |
| `void` | CWSTRAT2.BM | Adds up the strength of the player's armies near a city: in full for neighboring cities and a tenth for cities two roads away. |
| `DIR$` (FUNCTION) | QB64.BM | Stands in for the `DIR$` of BASIC PDS 7.1: returns the first file that matches a pattern, or the next match when the pattern is empty. |
| `announce` | SCRIPT.BM | In a scripted run, writes to memory that the program is about to wait for a key and which kind of wait it is. |
| `scriptdate$` (FUNCTION) | SCRIPT.BM | Returns the date that starts the history file: today's, or 01-01-2000 in a scripted run. |
| `scriptshell` | SCRIPT.BM | Runs a `SHELL` command, except that a scripted run does a `copy` command in BASIC so that no console window opens. |
| `scriptstart` | SCRIPT.BM | Seeds the random numbers from the environment variable `CWS_SEED`, which makes the run scripted, or from the clock. |
| `scripttick%` (FUNCTION) | SCRIPT.BM | In a scripted run, takes the place of `TICK`'s pause: it returns at once for a short pause and waits for a key for one of 99 seconds or more. |

### Worth breaking out

Listed from the safest and most useful down. None changes what the game does. The scripts of `tests\play.py`
compare the screens, so each step can be checked by running them.

One thing to watch in every case: a variable inside a SUB is local unless `CWS14.BI` shares it. Code moved
out of a SUB loses that SUB's locals, so each one it uses must be passed as an argument.

#### Small and safe

- **`filer` into three SUBs.** Its argument only picks one of three unrelated jobs, and it has three callers.
  `load_scenario` (case 1), `load_game` (case 2), `save_game` (case 3). The line that reads or writes
  `cws.cfg` appears four times (twice read and once written in `filer`, once written at `CWSTRAT.BAS` line
  689): make it `config_read` and `config_write`.
- **`report` into one SUB for each report.** It holds six reports joined by `GOTO`: armies, cities, force
  summary, intelligence, battle summary and recap. Two callers pass a made-up number to reach one report
  directly: `report(-1)` for the force summary and `report(100 + side)` for the battle summary. With a SUB
  for each report they call it by name, and `menu_report` keeps only the menu.
- **Waiting for a key.** `CALL announce(1, "X"): DO WHILE INKEY$ = "": LOOP` appears 12 times. Make it
  `wait_key (letter$)`.
- **The fleet-sailing screen in `navy`.** The Sail and Raid cases hold the same 16 lines: the row of ships,
  the picture of the lead ship and the pause. Make it `draw_fleet_sailing (who)`.
- **Clearing an army.** The same line that sets an army's size, place, leader, experience, move and supply
  to zero is in `tupdate` (the army that surrenders), `combine`, the "Vary Start" menu case (twice) and the
  start of a new game. Make it `army_clear (index)`.
- **A city's dot.** `flashcity` and `showcity` both draw the dot with the same three lines. Erasing a fort's
  square and calling `showcity` appears in `navy`, `capture` and `tupdate`. Make them `draw_city_dot` and
  `city_redraw_fort`.
- **The train picture.** The same `DRAW` string is in `engine`, `tinytrain` and the Railroad case of the
  main menu.
- **The menu's box.** `menu` draws the box and then calls `choices`, which draws the same box again. The
  copy in `menu` can go.
- **Dead code in `CWSTRAT.BAS`.** The label `topbar:` near the end (lines 706 to 710) is never reached; the
  SUB `topbar` replaced it.
- **Numbers that pick a behavior.** `icon`'s `kind` (1 to 11) and `menu`'s `switch` (0 to 9) are bare
  numbers at about 50 call sites. Named constants (`CONST MARK_MOVE_LINE = 1`) explain each call without
  changing a SUB.

#### The main module, `CWSTRAT.BAS`

It is 745 lines with no SUB of its own; the menus hold the game's rules inline. These pieces stand alone:

- **Detach** (lines 358 to 373): `army_detach`.
- **Drill** (lines 377 to 387): `army_drill`. The computer's drill at the end of `smarts` applies the same
  rule.
- **Supply menu** (lines 311 to 337): `menu_supply`.
- **Move capital** (lines 341 to 354): `menu_move_capital`.
- **Vary Start** (lines 571 to 606): `vary_start_conditions`.
- **The title screen and its music** (lines 63 to 95): `draw_title` and `play_title_music`.
- **Reading `cities.grd`** (lines 99 to 110): `load_cities`.
- **The month's income** (lines 150 to 168): `turn_collect_income`.
- **The `GOSUB` routines** `blanken` (the "player's turn" screen) and `unionplus` (the Union's income
  bonus): `draw_player_turn` and `set_union_advantage`.

The Utility menu and the Commands menu could each become a SUB later. Their cases leave by `GOTO menu0`, so
that takes more care.

#### `navy` (435 lines)

- **Ship against ship** (the label `pirate:` to the end of its `SELECT`, with `showhit`, `clr1`, `boxes` and
  `xout`): `navy_combat (who, chx)`. It is about 100 lines and is entered from two places.
- **The computer's choice of port** (the `GOSUB` routine `nest`): `ai_pick_port`.
- **One SUB for each action** (build, bombard, sail, raid, invade) is the end state, with `navy_commands`
  keeping the menu. The cases jump into each other with `GOTO ahoy`, `GOTO anchor` and `GOTO ships`, so do
  this last.
- **The menu, apart from the computer's choices** (agreed): `menu_navy (who)` for the human's Ships menu,
  `ai_navy (who, chx)` for the computer's choice of action, and `navy_action (who, action)` for what is left.
  The computer's path runs through the code that builds the menu (the label `ahoy:`), because three of its
  decisions are made there: it invades when "Invasion" is added to the menu, a "Sail" order becomes "Build"
  when it has no fleet, and its loop of building ships ends there. Those move to `ai_navy` first.

#### Other SUBs that serve both the human and the computer

`navy` is not the only one. Two more mix the human's menu with the computer's choice:

- **`recruit`:** `IF who <> side THEN GOSUB randsel` swaps the menu for the computer's pick (the `GOSUB`
  routine `randsel`). Split it into `menu_army_recruit` (the human's menu), `ai_recruit` (the pick) and
  `army_recruit (who, city)` (pay 100, then raise a new army or add men to the one there).
- **`railroad`:** four parts in one SUB. The computer's choice of army and city (case 0 up to the label
  `human:`), the human's choice (`human:` to `haul:`), starting the train (`haul:`) and the train's arrival
  (case `IS > 0`). They become `ai_railroad`, `menu_railroad`, `railroad_start` and `railroad_arrive`. The
  `GOSUB` routine `route`, which counts the friendly track out of a city, becomes `railroad_route_count`.

#### Rules apart from the screen

- **Losses in `battle`** (lines 199 to 228): the same eight lines appear twice, once for each army, with the
  attacker and the defender swapped. They print nothing. Make them `battle_losses`; `tests\rules_test.bas`
  can then test the losses directly.
- **Strengths in `battle`** (lines 85 to 151): the attack and defense values are worked out step by step,
  and each step is printed in the right panel. Splitting out the arithmetic means returning each step's value
  for the panel. Worth doing only together with tests of the combat rules.
- **An army's side**: `who = 1: IF index > 20 THEN who = 2` and its variants appear 10 times. Make it
  `FUNCTION army_side (index)`. Leave out the line in `battle` that tests `attack > 2` (see the bugs below):
  using the FUNCTION there would fix the bug, which changes the game.
- **`maxx` borrows `city$()` and `matrix()`** to hold the Hall of Fame's names and scores while it shows
  them. That works only because the game is over and a new game reads the cities again. Give the Hall of
  Fame its own arrays, with `hall_of_fame_load` and `hall_of_fame_save`.
- **`victor`**: the warnings that a side is close to winning are one block; make it `victory_warnings (i)`.
  The end of the game, from the label `finis:`, becomes `end_game`.

#### Screen helpers

- **Loading a picture**: `DEF SEG`, `BLOAD` and `DEF SEG` again load a `.vga` file four times (`menu`,
  `battle` and twice in `CWSTRAT.BAS`). Make it `load_picture (file$, picture())`.
- **What `menu` shows beside the highlighted row**: two `SELECT CASE switch` blocks in `menu` draw an arrow
  at an army's city, the army's name and size, the army's details, or a leader's face. This is why `menu`
  needs to know about armies and cities. Moving them to `menu_highlight (switch, row)` and
  `menu_unhighlight (switch, row)` leaves `menu` a plain menu.

#### Not worth doing now

- Every menu is set up by assigning shared variables (`tlx`, `tly`, `size`, `colour`, `hilite`, `mtx$()`)
  before `CALL menu`. Passing them as arguments would touch every menu in the game, which goes beyond
  breaking code out.
- `CALL clrbot: PRINT ...: CALL TICK(turbo!)` (a message, then a pause) is everywhere, but most of the
  messages are built from several pieces and calls to `strong`. A helper would cover few of them.

#### `tupdate` (270 lines)

- **The order of movement** (lines 1637 to 1658, with `bub2`): `turn_set_move_order`.
- **Commerce raiding** (the label `allthru:`, lines 1841 to 1871): `navy_commerce_raid`.
- **Victory points** (lines 1878 to 1885): `turn_update_victory_points`.
- **The `GOSUB` routine `upbox`**: `draw_update_box`.
- The attack, retreat and surrender part in the middle is one knot of `GOTO`s. Leave it until the rest is
  done.

#### `smarts` and `events`

- `smarts` already has headed sections: supply, fortify, recruit, navy, army moves, drill. Each can become
  an `ai_` SUB. The `GOSUB` routine `enufarmies` becomes `ai_count_armies`.
- `events`: the `GOSUB` routine `riot` becomes `event_riot`.

#### Found while reading, not to fix as part of a rename

These look like bugs in the original. Fixing them changes how the game plays, so each is its own decision.

- `CWSTRAT.BAS` line 582: `FOR k = 21 TO 6` never runs, so "Vary Start" never removes a Rebel army.
- `battle`: `s = 1: IF attack > 2 THEN s = 2` most likely meant `attack > 20`. As written, casualties are
  counted for the wrong side when Union armies 3 to 20 attack.
- `battle` and `tupdate`: `SELECT CASE` tests `IS > 300` before `IS > 800` (and `IS > 400` before `IS > 800`
  and `IS > 1000`), so the later cases are never reached.
- `tupdate`: `victory(2) = victory(1) + 100` in the Rebel line most likely meant `victory(2) + 100`.

### Settled names

One row for each SUB and FUNCTION, in alphabetical order of its current name.

`draw_` is for a SUB that puts a fixed piece of the screen in place, whether lines or text. `print_` is only
for a SUB that writes at the cursor, as a `PRINT` statement does.

| Current name | Settled name |
|--------------|--------------|
| `animate` | `animate_army` |
| `announce` | `script_mark_key_wait` |
| `armies` | `menu_army_move` |
| `armystat` | `draw_army_stats` |
| `armyxy` | `draw_flag_icon` |
| `barnacle` | `navy_remove_ship` |
| `battle` | `calculate_battle` |
| `bub2` | `sort_move_order` |
| `bubble` | `menu_bubble_sort` |
| `burn` | (deleted) |
| `cancel` | `menu_army_cancel` |
| `cannon` | `draw_cannon` |
| `capitol` | `draw_union_victory` |
| `capture` | `city_capture` |
| `center` | `print_centered` |
| `chessie` | `draw_chesapeake` |
| `choices` | `draw_menu` |
| `clrbot` | `clear_bottom_line` |
| `clrrite` | `clear_right_panel` |
| `combine` | `army_combine` |
| `commander` | `army_get_commander` |
| `cutoff` | `city_is_connected` |
| `DIR$` | `DIR$` (kept) |
| `endit` | `menu_victory_conditions` |
| `engine` | `draw_train_box` |
| `evaluate` | `ai_evaluate_move` |
| `events` | `special_events` |
| `filer` | `file_management` |
| `flags` | `draw_large_flag` |
| `flashcity` | `animate_city` |
| `fortify` | `menu_city_fortify` |
| `icon` | `draw_map_marker` |
| `image2` | `show_message_box` |
| `integrity` | `check_map_links` |
| `ironclad` | `draw_ironclad` |
| `iterate` | `turn_date_and_supply` |
| `maptext` | `draw_city_names` |
| `maxx` | `hall_of_fame` |
| `menu` | `menu_select` |
| `movefrom` | `menu_army_select` |
| `mxw` | `menu_measure_width` |
| `navy` | `navy_commands` |
| `newarmy` | `army_new` |
| `newcity` | `menu_city_select` |
| `normal` | `normal_random_number` |
| `occupy` | `city_update_occupier` |
| `placearmy` | `draw_army_flag` |
| `railroad` | `railroad_move` |
| `recruit` | `menu_army_recruit` |
| `relieve` | `menu_army_relieve` |
| `report` | `menu_report` |
| `resupply` | `army_resupply` |
| `retreat` | `menu_army_retreat` |
| `roman` | `army_generate_name` |
| `rwin` | `draw_rebel_victory` |
| `schooner` | `draw_schooner` |
| `scribe` | `scribe_message` |
| `scriptdate$` | `script_date$` |
| `scriptshell` | `script_shell` |
| `scriptstart` | `script_start` |
| `scripttick%` | `script_tick%` |
| `scrnsavr` | (deleted) |
| `shen` | `play_shenandoah` |
| `shipicon` | `draw_ship_icon` |
| `ships` | `draw_fleets` |
| `shiptype` | `draw_fleet_ship` |
| `showcity` | `draw_cities` |
| `smarts` | `ai_turn` |
| `snapshot` | `screen_snapshot` |
| `starfin` | `side_army_range`; in phase 5 the FUNCTIONs `side_first_army` and `side_last_army` (user, 2026-11-11) |
| `stax` | `draw_stack_markers` |
| `strong` | `print_army_size` |
| `surrender` | `draw_surrender` |
| `TICK` | `wait_seconds` |
| `tinytrain` | `draw_train` |
| `topbar` | `draw_top_bar` |
| `touchup` | `draw_map_touchup` |
| `traincapacity` | `railroad_capacity` |
| `tupdate` | `turn_resolve` |
| `usa` | `draw_map` |
| `victor` | `check_victory_conditions` |
| `void` | `city_nearby_enemy_strength` |

## Local variable, parameter and label names

Was `docs\archived\local-names.md`.

The renames of phases 4 and 5 covered the shared variables ([`variable-names.md`](#shared-variable-and-parameter-names)) and the SUBs ([`sub-names.md`](#sub-and-function-names)).
They left the names inside each SUB: its parameters, its `DIM` locals and its `GOTO` labels. Many of these are
still the original's: `chosit`, `star` and `fin`, `xbar`, `slush`, `killd`, labels such as `deadman` and `puter`.

This document listed them, on branch `refactor_naming` at commit `d70ccbb`. Parts 1 and 2, the renames of the
locals and the labels removed, are done, and so is part 3, the constants; they are in
[`local-names-completed.md`](#done-local-variable-parameter-and-label-names). Part 4, the possible bugs, is done too: each is fixed or has a row in
`TODO.md`. This document moved to `docs\archived\` on 2026-11-13.

### Rules the proposals follow

These are the rules of [`variable-names.md`](#shared-variable-and-parameter-names), used for locals:

- snake_case, and a name says what the value is, not its type.
- The same thing gets the same name in every SUB: an army is `army`, a side is `side`, a city is `city`.
- When a SUB already has that name, the second one says how it differs: `to_city`, `spare_army`.
- QB64 keywords cannot be names. So a color is `side_color` or `dot_color`, never `color`. A width is
  `menu_width`, never `width`. `command$`, `key$` and `line$` are out for the same reason.

Two kinds of name are kept:

- **`i`, `j`, `k` and `n` as loop counters.** Where one holds something else, part 1 lists it.
- **`x` and `y` as a screen position**, in pixels or in text columns and rows. Where one holds a count, a city
  or a strength, part 1 lists it.

A rename inside a SUB touches nothing outside it. The rename can be checked the same way as before:
`tests\rules_test.bas` and the scripts of `tests\play.py` must give the same results. One risk is a local that
gets the name of a shared variable, a CONST, a SUB or a FUNCTION. That would make it hide the shared one, or
not compile. Every proposal below was checked against the 90 shared names in `cws.bi` and against the CONSTs,
SUBs and FUNCTIONs. The shared side is `current_side`, so `side` is free.

### Part 4: found while reading

None of these is fixed by a rename. Items 1 to 3 and 7 were names that said the wrong thing; part 1b renamed
them, and they are in [`local-names-completed.md`](#done-local-variable-parameter-and-label-names). Items 4 to 6, 8 and 9 look like bugs of the original, kept
like the others (decision 3). Fixing one changes how the game plays, so each would be its own decision and a
`TODO.md` row.

Where they stand on 2026-11-13: 6 and 8 were fixed in the batch of kept bugs ([`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy),
"The kept bugs fixed"). 4, 5 and 9 have rows in `TODO.md`. The line numbers below are those of commit
`d70ccbb`; 148 is now 243, 206 is now 399 and 35 is now 46.

4. **`ai_army_order`, the capital check** (`ai\ai.bm` line 148): `neighbor = city_road(city, j): IF j = 0 GOTO
   nocap`. `j` runs from 1, so the test is never true. It most likely meant `neighbor = 0`. As written,
   `city_nearby_enemy_strength(0)` is called for an empty road. City 0 has no roads, so that returns 0 and
   a fix changes no play.
5. **`ai_evaluate_move`, the fort factor** (line 206): `IF city_fort(to_city) = 3 THEN fort_factor = 3`. Forts go up to 2
   (`MAX_FORT`), so the factor is never 3. Worse, the original is one `IF` line
   (`x1 = 1: IF fort(a) = 1 THEN x1 = 2: IF fort(a) = 3 THEN x1 = 3`), so a fort of 2 gives 1, as no fort does.
6. **`ai_army_order`, "eliminate crossing moves"** (line 158): `IF army_order(other_army) = army_troops`, where
   `army_troops` is the army's size, not a city. It most likely meant the army's city (`city`). As written it matches only by chance,
   so crossing moves are mostly not removed. Fixed.
8. **`event_roll`, the mercenaries**: `index` is never set, so they join army 0. Fixed: they join the army in
   the capital, or form a new one there.
9. **`ai_fortify`, the Union's cash** (`ai\ai.bm` line 35): `IF side = SIDE_UNION AND fleet_size(SIDE_UNION) < 1
   AND RND > .5 AND side_cash < 222 THEN EXIT SUB`. `side_cash` here is the local scalar, always 0, so the test
   is always true. It most likely meant `side_cash(side) < 222`. The original has the same with `cash`.

## Done: local variable, parameter and label names

Was `docs\archived\local-names-completed.md`.

The finished parts of [`local-names.md`](#local-variable-parameter-and-label-names), moved here on 2026-11-12. That document keeps the rules and the
possible bugs; it is in `docs\archived\` too since 2026-11-13. A section not found there is here.

### Part 1: local variables and parameters

#### 1a. Names with one meaning in many SUBs

Each row is one rename, done in every SUB it lists. Part 1b lists the SUBs where the same name means something
else.

**Done on 2026-11-12**, by `tools\refactor\rename_locals.py` (101 SUBs). Two rows were left out at the user's
word: `kind` stays `kind`, and the sorts' `limit` stays `limit`. The unit tests (123) and the scripts (38, both
compilers) gave the same results as before.

| Current | What it holds | SUBs | Proposed | Your name |
|---------|---------------|------|----------|-----------|
| `star`, `fin` | A side's first and last army, from `side_first_army` and `side_last_army`. `star` reads as a star. | `ai_resupply`, `ai_fortify_pick`, `ai_count_armies`, `ai_army_orders`, `ai_drill`, `army_combine_gather`, `load_game`, `army_pick_commander`, `army_list_combine_cities`, `menu_main_inform`, `menu_army_select`, `menu_army_cancel`, `menu_army_relieve`, `menu_supply`, `report_armies`, `report_intelligence` | `first_army`, `last_army` | |
| `who` | A side, 1 or 2. [`variable-names.md`](#shared-variable-and-parameter-names) planned this rename ("Parameters"); some SUBs were done, these were not. | Parameter: `ai_resupply`, `ai_fortify`, `ai_fortify_pick`, `ai_raise_forces`, `ai_count_armies`, `ai_fleet_orders`, `ai_army_orders`, `ai_army_order`, `ai_drill`, `event_riot_city`, `event_riot`. Local: `draw_army_flag`, `load_game`, `army_buy_supply`, `menu_city_fortify`, `menu_army_select`, `menu_army_retreat` | `side` | |
| `index` | An army. | Local: `navy_bombard`, `railroad_arrive`, `railroad_unload`, `menu_army_move`, `menu_army_cancel`, `menu_army_relieve`, `menu_army_detach`, `menu_army_drill`, `event_roll`. Parameter: `turn_army_surrenders` | `army` | |
| `active` | The army whose move is being carried out. | Parameter: `city_capture`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats`, `turn_army_surrenders`, `turn_enter_city`. Local: `turn_resolve` | `moving_army` | |
| `defend` | The army in the city that is attacked. | `turn_attack` (local), `turn_attacker_withdraws`, `turn_defender_retreats` (parameters) | `defender` | |
| `defend` | The enemy's strength near a city, from `city_nearby_enemy_strength`. It is not an army. | `ai_fortify_pick`, `ai_army_order`, `ai_evaluate_move`, `ai_railroad` | `enemy_strength` | |
| `from` | The city an army or a train sets out from. | `ai_evaluate_move`, `army_recruit`, `railroad_start`, `railroad_board`, `animate_army` | `from_city` | |
| `s` | A side. | `draw_fleets`, `hall_of_fame_load`, `hall_of_fame_save`, `hall_of_fame` (`ui\victory.bm`), `battle_apply_losses`, `turn_army_supply`, `turn_army_lost`, `turn_move_army`, `turn_enter_city`. Parameter: `hall_of_fame_place`, `hall_of_fame_insert` | `side` | |
| `a` | The number of a side's cities next to a city, from `city_is_connected`. 0 means cut off. | `ai_recruit_pick`, `army_raise`, `army_buy_supply`, `army_add_recruits`, `turn_army_supply`, `menu_supply`, and the count itself in `city_is_connected` | `friendly_neighbors` | |
| `a` | A ship's kind for `draw_ship_icon`: 1 wooden, 2 ironclad. | `navy_ship_joins`, `navy_fleet_founded`, `navy_commerce_raid`, `draw_fleets`, `draw_fleet_ship` | `ship_type` | |
| `c` | A side's color: 9 (or 1) for the Union, 7 (or 15) for the Rebels. | `draw_train`, `draw_train_box`, `draw_top_bar`, `draw_player_turn`, `draw_surrender`, `calculate_battle`, `report_armies`, `report_intelligence`, `report_force_summary`, `ai_turn`, `end_game` | `side_color` | |
| `c` | A city dot's color: its owner's, or a flash color. | `animate_city`, `draw_cities`, and the parameter of `draw_city_dot` | `dot_color` | |
| `c` | The color of the computer's messages. | Parameter: `ai_army_orders`, `draw_ai_plan` | `text_color` | |
| `wide` | A menu's width, in columns. | `draw_menu`, `menu_select`, `menu_arrow_key`, `menu_mark_row`, `menu_measure_width`, `show_message_box` | `menu_width` | |
| `b1` | The column where a menu's title starts, from the left of the box. | `draw_menu`, `menu_select`, `menu_arrow_key` | `title_col` | |
| `kind` | The menu's mode: what it shows beside the highlighted row (`MENU_PLAIN`, `MENU_CITY_BOX` and the others). | Parameter: `menu_arrow_key`, `menu_mark_row`, `menu_unmark_row` | `mode` | `kind` (kept) |
| `boxc` | The color of a menu's box. | `draw_menu`, `menu_select` | `box_color` | |
| `hit()` | The hits each fleet still has to give in a sea fight, by side. | `navy_combat_begin`, `navy_combat_volley`, `navy_combat_auto`, `navy_show_hits`, `menu_navy_combat` | `hits()` | |
| `over` | 1 when the sea fight is over. | `navy_combat_volley`, `navy_combat_auto`, `menu_navy_combat` | `combat_over` | |
| `limit` | The largest army the train can carry, from `railroad_capacity`. | `ai_railroad`, `menu_main_railroad`, `menu_railroad`, and the result being worked out in `railroad_capacity` | `capacity` | |
| `limit` | The number of entries to sort. | Parameter: `sort_move_order`, `menu_bubble_sort` | `count` | `limit` (kept) |
| `FALSE` | A local that is always 0, used as false. | `sort_move_order`, `menu_bubble_sort` | Delete; write `0`, or add `CONST FALSE = 0` to `cws.bi` | Deleted; `CONST FALSE = 0` in `cws.bi` |
| `pct!` | A chance, compared with a random number. | `army_recruit_cities` (`event_roll` is in part 1b) | `chance!` | |
| `x`, `y` | The Union's and the Rebels' men in the field, in hundreds (`victory_forces`). | Parameter: `victory_forces`, `victory_rule_met`, `victory_near_force`, `victory_warnings`. Local: `check_victory_conditions` | `union_men`, `rebel_men` | `union_troops`, `rebel_troops` |
| `i` | A side. | Parameter: `victory_rule_met`, `victory_near_cities`, `victory_near_income`, `victory_near_force`, `victory_won`, `victory_warnings`, `end_game`. Local: `check_victory_conditions` | `side` | |
| `j` | A victory rule, 2 to 7. | Parameter: `victory_rule_met`, `victory_play_on`, `victory_won`, `end_game`. Local: `check_victory_conditions` | `rule` | |
| `a$`, `t$` | A message built and then printed or passed to `scribe_message`. About 230 uses. | Most SUBs that print | Kept, or `message$`. Part 1b lists the ones that hold something else. | `a$` renamed in every SUB (2026-11-13): `message$` for a message, a name of its own elsewhere (`setting$`, `check_mark$`, `owner$`, `reason$`, `history_line$`, …). `t$` renamed too: `file$`, `favor$`, `income_text$`, `message$`. |

#### 1b. Names that mean something of their own in one SUB

By file, in the order of the SUBs. A name in 1a is listed here only where it means something else.

**Done on 2026-11-12**, by `tools\refactor\rename_locals_1b.py` (106 SUBs and the main module). A row with an
empty "Your name" got the proposed name. Three things were done beyond the rows:

- An army slot is `army_slot` in every SUB that had `slot` for it: `army_new`, `army_get_commander`,
  `navy_land_army`, `army_raise`, `army_pick_commander`, `army_detach`, `army_place_new`, `army_recruit_bonus`,
  `ai_navy_invade` and `menu_navy_invade`. `load_game` and `save_game` keep `slot` for a saved game's number.
- Men are `troops` in every name: 1a's `union_men` and `rebel_men` became `union_troops` and `rebel_troops`.
- `army_pick_commander` passes `(i)`, by value, because `army_generate_name` changes its first argument.
  That is what the copy in `x` was for.

Three names the user asked about were not taken, each for a reason:

- `leader_name$` and `army_name$` are shared arrays, so the locals are `generated_name$` and `short_name$`.
- `draw_train`'s `from` is `city`, not `city_from`: `train_city` is where the train is, also after it arrives.
- `hall_of_fame`'s `a$` stays `commander$`, not `player_name$`: it is "COMPUTER" when the computer's side
  enters the Hall of Fame.

##### `cws.bas` (the main program)

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| main | `chosit` | The option the main menu starts on next time, as `MENU_START` + its row. It is kept from one game to the next. | `main_menu_start` | |
| main | `a$` | The "EVENTS FOR" line written to the history. | `message$` | |
| `DECLARE` lines | `who%`, `flag%`, `xbar%`, `vary%`, `z%`, `w%`, `a%`, `active%` | The parameter names of the 10 `DECLARE` lines that have parameters (of 14). They are the old names and do not match the SUBs. | Delete the `DECLARE` lines (QB64 needs none), or give them the SUBs' names | Deleted |

##### `ai\ai.bm`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `ai_fortify` | `side_cash` | A local scalar with the same name as the shared array `side_cash()`. It is always 0. It is read once, in `side_cash < 222` (part 4, item 9); every `side_cash(side)` is the array. | Kept until item 9 is decided | |
| `ai_fortify` | `target` | The city to fortify. | `city` | |
| `ai_fortify` | `x` | The army in that city. | `army` | |
| `ai_fortify_pick` | `target` (parameter) | The city picked to fortify, out. | `fort_city` | `city` |
| `ai_fortify_pick` | `x` | The city of the army being looked at. | `city` | `candidate_city` |
| `ai_raise_forces` | `slush` | The cost of a ship, held back from the cash while the computer recruits, then given back. | `ship_reserve` | |
| `ai_raise_forces` | `x` | The number of armies, from `ai_count_armies`. | `army_count` | |
| `ai_count_armies` | `x` | The number of the side's armies, less 2 when outnumbered. The FUNCTION's result. | `army_count` | |
| `ai_count_armies` | `y`, `z` | The other side's and this side's strength, in tenths of the men. | `enemy_strength`, `own_strength` | |
| `ai_army_order` | `target` | The city the army is in. | `city` | |
| `ai_army_order` | `x` | The army's size. | `army_men` (see part 4, item 6) | `army_troops` |
| `ai_army_order` | `k` | A city next to the capital. | `neighbor` | |
| `ai_army_order` | `flag` | The enemy's strength near that city. It is not a flag. | `neighbor_strength` | |
| `ai_army_order` | `best` | The road picked, from `ai_evaluate_move`. | `best_road` | |
| `ai_army_order` | `y` | The army already in the city the order goes to. | `other_army` | |
| `ai_evaluate_move` | `x` (parameter) | Two things. First, how much the computer wants to stay in a fortified city. At the end, the road picked, out. | `best_road` for the parameter, and a new local `stay_weight` for the first use | `best_road`, `stay_weight`, and `best_score` in the last loop |
| `ai_evaluate_move` | `best` | Two things: the army's size, then the number of the best road so far. | `own_strength`, then `best_road` | |
| `ai_evaluate_move` | `max` | The number of roads out of the city. | `road_count` | |
| `ai_evaluate_move` | `a` | The city at the end of the road being scored. | `to_city` | |
| `ai_evaluate_move` | `c` | The army in that city. | `occupant` | |
| `ai_evaluate_move` | `m` | A city two roads away. | `far_city` | |
| `ai_evaluate_move` | `y` | The road's score. | `score` | |
| `ai_evaluate_move` | `x1` | How much that city's fort multiplies its defender: 1, 2 or 3. | `fort_factor` | |
| `city_nearby_enemy_strength` | `a` (parameter) | The city. | `city` | |
| `city_nearby_enemy_strength` | `x`, `m` | A city next to it, and a city two roads away. | `neighbor`, `far_city` | |
| `city_nearby_enemy_strength` | `y` | The strength added up. The FUNCTION's result. | `strength` | |
| `ai_recruit_pick` | `x` | Two things: the army in a city, then the best score so far. | `army`, then `best_score` | |
| `ai_recruit_pick` | `target` | A city on the recruiting list. | `city` | |
| `ai_recruit_pick` | `y` | That city's score. | `score` | |
| `ai_railroad` | `max` | The lowest enemy strength found near an army so far. | `least_threat` | |
| `ai_railroad` | `index` | The army picked to send: the one farthest from the enemy. | `spare_army` | |
| `ai_railroad` | `x` | Two things: how many enemy cities are next to an army, then a count of track from `railroad_route_count`. | `enemy_neighbors`, then `routes` | |
| `ai_railroad` | `from` | Two things: a city next to an army's city, then the city the train leaves. | `neighbor`, then `from_city` | |
| `ai_railroad` | `target` | A city looked at as the start or the end of the train ride. | `candidate` | `candidate_city` |
| `ai_railroad` | `x1` | The city the train goes to. | `to_city` | |
| `ai_pick_port` | `x` | How many enemy ports are on the list. | `enemy_ports` | |
| `ai_pick_port` | `target` | A port on the list. | `port` | |

##### `commands\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `army_recruit` | `empty` | A free army slot. | `slot` | `army_slot` |
| `city_capture` | `c` (parameter) | The city. | `city` | |
| `city_capture` | `capital` | 1 when the city was the enemy's capital. | `was_capital` | `was_enemy_capital` |
| `navy_bombard` | `target` | The city the fleet lies off. | `city` | |
| `navy_bombard` | `killd` | The men the army lost, in hundreds. | `casualties` | |
| `navy_land_army` | `c` | The city the fleet is in. | `city` | |
| `navy_combat_retreat` | `target` | The port the beaten fleet goes to. | `port` | |

##### `draw\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `animate_army` | `background_saved` (parameter) | 1 when the caller has already saved the screen under the icon (`TODO.md` notes the name is wrong). | `picture_taken` | |
| `animate_army` | `to2` | The city the army marches to. | `to_city` | |
| `animate_army` | `x1`, `y1` | The icon's place on the way, between the two cities. | `step_x`, `step_y` | |
| `draw_train` | `from` | The city where the train is drawn. | `city` | |
| `draw_flag` | `w` (parameter) | How far right of x = 585 the flag goes. 0 is the main flag, which also gets the side's name. | `x_offset` | |
| `draw_flag` | `a` (parameter) | The flag's top row, in pixels. 0 for the default. | `top_y` | |
| `draw_city_names`, `draw_map` | `x` | A letter's number in `map_font$()`, 1 for A. | `letter` | |
| `draw_city_names` | `a` | The x position of that letter. | `letter_x` | |
| `draw_stack_markers` | `target` | The city of the army. | `city` | |
| `draw_fleet_ship` | `i` (parameter) | The ship's place in the fleet. | `ship` | |
| `draw_fleet_sailing` | `a` | The letter code of the lead ship. | `lead_ship` | |

##### `game\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `event_roll` | `who` (parameter) | The side the event was rolled for, out. A roll for the Union gives an event good for the South. | `event_side` | |
| `event_roll` | `pct!` | Two things: the chance of an event (line 23), then the share of each army's men kept after the uprising (lines 70 to 76). | `chance!`, then `share_kept!` | |
| `event_roll` | `plus` | The difficulty, turned round for the Union. It makes events likelier and bigger. | `event_weight` | |
| `event_roll` | `empty` | The Rebel port that the English ships sail to. | `port` | |
| `event_roll` | `x` | Two things: the ships to add to a fleet, then a counter of armies. | `new_ships`, then `count` | |
| `event_riot_city` | `x` | A city picked at random. | `city_tried` | `candidate_city` |
| `draw_union_victory` | `x` | Which part of the Capitol's front is being drawn, 0 to 2. | `wing` | `capitol_wing` |
| `draw_surrender` | `side` (parameter) | An army, not a side. The caller passes `index`, an army (`ui\turn.bm` line 196). | `army` | |
| `draw_surrender` | `s` | The army's side. | `side` | |
| `draw_surrender` | `w` | The left edge of the right panel, 514 pixels. | `panel_x` | `panel_left` |

##### `port\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `load_scenario` | `a` | The number of armies the scenario has for a side. | `army_count` | |
| `load_cities` | `a` | The city's number in `cities.grd`, read and not used. | `unused` | |
| `load_cities` | `x` | The city's owner. | `owner` | |
| `load_game` | `a` | The side whose turn it is, read from the saved game. | `saved_side` | |
| `load_game` | `myside` | The side in `CWS.CFG`. It is read and then not used. | `config_side` | |
| `save_game` | `myside` | The side written to `CWS.CFG`. | `config_side` | |
| `DIR$` | `f$` | The file name found. | `found$` | `found_file$` |
| `script_shell` | `sp` | Where the first space is. | `space_at` | |
| `script_shell` | `c$` | The command, trimmed. `command$` is a keyword. | `trimmed$` | |
| `script_shell` | `d$` | The file's contents. | `contents$` | |
| `script_shell` | `f` | A file number. | `file_num` | |

##### `rules\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `army_combine_add` | `pct!` | The army's share of the men in the combined army. | `share!` | |
| `army_raise` | `x` | The new army's size. | `men` | `troops` |
| `army_add_recruits` | `x` | The men added. | `men` | `troops` |
| `army_pick_commander` | `x` | The army slot passed to `army_generate_name`. | Delete; pass `i` | Deleted; passes `(i)` |
| `army_pick_commander` | `a$` | The made-up leader's name. | `name$` | `generated_name$` |
| `army_buy_supply` | `x` | The supply the cash can buy, then the supply bought. | `supply_added` (`SUPPLY_BOUGHT` is a CONST) | |
| `army_buy_supply` | `y` | The army's new supply level. | `new_supply` | |
| `army_generate_name` | `x` | How many `I` to add to the Roman numeral, 0 to 3. | `number` | `ones` |
| `army_recruit_cities` | `max` | How many cities are offered. | `offer_count` | |
| `army_recruit_cities` | `x` | A city on the list. | `city` | |
| `battle_strengths` | `x`, `x1` | The attacker's and the defender's strength, built step by step. | `attack_strength`, `defend_strength` | |
| `battle_strengths` | `R!` | The defender's size over the attacker's. | `size_ratio!` | |
| `battle_fight` | `attack`, `defend` (parameters) | The two strengths. | `attack_strength`, `defend_strength` | |
| `battle_fight` | `scale` | The size of the die: the larger strength, plus 1. | `die_size` | `scale` (kept) |
| `battle_fight` | `star`, `fin` | Here two dice rolls, not two armies. | `attack_roll`, `defend_roll` | |
| `battle_fight` | `hit`, `hit1` | 1 when the attacker's roll hits, and when the defender's does. | `attacker_hit`, `defender_hit` | |
| `battle_losses` | `pct!` | The share of an army lost. | `loss_rate!` | |
| `battle_losses`, `normal_random_number` | `xbar`, `vary` | The mean and the variance of the losses. `xbar` is the statistics name for a mean (x̄). | `mean`, `variance` | |
| `normal_random_number` | `pct!` | The sum of 11 random numbers, less 5.5. | `sum!` | |
| `city_is_connected` | `y` | A city next to the city. | `neighbor` | |
| `city_fix_return_routes` | `index` | A city next to city `i`. | `neighbor` | |
| `city_update_occupier` | `x` (parameter) | The city. | `city` | |
| `navy_bombard_army` | `pct!` | The share of the army lost. | `loss_rate!` | |
| `navy_bombard_army` | `x` | The supply the army loses. | `supply_loss` | |
| `navy_shot_hits` | `pct!` | The ironclad's bonus or penalty to the chance of a hit. | `ironclad_bonus!` | |
| `navy_shot_hits` | `a$` | The letter of the last ship in the fleet. | `ship$` | |
| `railroad_route_count` | `x` | The count of track. The FUNCTION's result. | `routes` | |
| `railroad_route_count` | `y`, `z` | A city next to the city, and a city two roads away. | `neighbor`, `far_city` | |
| `railroad_capacity` | `x` | Two things: a number of cities, then the most the train can carry. | `base_cities`, then `most` | `base_cities`, then `max_capacity` |
| `game_apply_settings` | `a$` | A row of ship letters. | `ships$` | |
| `turn_strength_ratio` | `x`, `y` | The Rebels' and the Union's strength. The letters are the other way round from `victory_forces`. | `rebel_strength`, `union_strength` | |
| `turn_retreat_city` | `flee` | The road to the best city found so far. | `best_city` | `best_road` |
| `turn_retreat_city` | `x` | A city next to the city. | `neighbor` | |
| `turn_collect_income` | `x` | A city's owner. | `owner` | |
| `turn_set_move_order` | `x` | Set to 1 to 4 by army size, and never read. | Delete | |
| `hall_of_fame_insert` | `i` (parameter) | The place in the Hall of Fame. | `place` | |

##### `ui\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `draw_ai_fort` | `target` (parameter) | The city. | `city` | |
| `draw_ai_plan`, `draw_ai_drill` | `i` (parameter) | The army. | `army` | |
| `calculate_battle` | `attack`, `defend` | The two strengths. | `attack_strength`, `defend_strength` | |
| `calculate_battle` | `a` | Two things: the odds in percent, then the winner's side. | `odds_pct`, then `winner_side` | |
| `calculate_battle` | `k` | The defender's fort level, for the picture. | `fort_level` | `fort_level`; `k` stays the loop counter |
| `calculate_battle` | `t$` | Two things: the fort picture's file name, then a message. | `file$`, then `message$` | |
| `calculate_battle` | `y` | The column of the right panel, 68. | `col` | |
| `special_events` | `who` | The side the event was rolled for (`event_roll`). | `event_side` | |
| `event_riot` | `x` | The city that riots. | `city` | |
| `menu_main_railroad` | `z` | The side's color. | `side_color` | |
| `menu_select` | `row1` | The row that was highlighted before the key. | `previous_row` | |
| `menu_select` | `brx`, `bry` | The box's right and bottom edge. Set and never read. | Delete | |
| `menu_select`, `menu_arrow_key` | `leave` | 1 when the menu is to close. | `done` | |
| `menu_select` | `a$` | The key pressed. | `pressed$` | |
| `menu_arrow_key` | `k$` (parameter) | The key's second byte. | `pressed$` | |
| `menu_select` | `c1$` | An option's first letter. | `initial$` | `menu_initial_letter$` |
| `menu_select`, `menu_mark_row` | `flag` | 1 when `menu_mark_row` has printed the row itself. | `row_shown` | |
| `menu_mark_row` | `target` | The army in the row's city. | `army` | |
| `menu_mark_row` | `t$` | Two things: the army's name, then the face picture's file name. | `name$`, then `file$` | `short_name$`, then `file$` |
| `menu_mark_row` | `a` | The face picture's number. | `face` | `face_pic` |
| `menu_measure_width` | `x` | An option's length. | `length` | `menu_option_length` |
| `show_message_box` | `seconds` (parameter) | The box's fill color, not a time. Every caller passes 4 (red). The box waits `PAUSE_LONG`. | `box_color` | |
| `show_message_box` | `x`, `y` | Set and never read. | Delete | |
| `show_message_box` | `g2()` | The screen under the box, put back at the end. | `saved_screen()` | |
| `menu_army_move` | `target` | The army's city, from `menu_army_select`. | `city` | |
| `menu_city_fortify` | `x` | The army in the city. | `army` | |
| `menu_city_select` | `a$` | The letter the player typed. | `letter$` | |
| `menu_city_select` | `x` | How many cities have been tried. | `tries` | |
| `menu_city_select` | `y` | The city it started from. | `start_city` | |
| `menu_army_cancel` | `target` | The city picked. | `city` | |
| `menu_army_cancel` | `x` | Where a space or the picked name is found in an army's name. | `found_at` | |
| `menu_army_cancel` | `turbo` | Always 0. The original's integer `turbo`, not the setting `turbo!` (now `opt_pause!`), so `wait_seconds(turbo + 1)` waits 1 second. | Delete; write `wait_seconds(1)` | |
| `menu_army_relieve` | `target` | Set to 0 and never read. | Delete | |
| `menu_army_relieve` | `t$`, `a$` | The old leader's name and the new one's. | `old_name$`, `new_name$` | |
| `menu_army_retreat` | `x` (parameter) | The city the army retreats to, out. | `retreat_city` | |
| `menu_army_retreat` | `y` | The city the army is in. | `city` | |
| `menu_supply` | `max` | The width of the longest army name. | `name_width` | |
| `menu_railroad` | `index` | The army picked. The SUB already has `army` for its result. | `chosen_army` | |
| `menu_railroad` | `a` | The city from `menu_army_select`. Only tested for 0. | `chosen_city` | |
| `menu_railroad` | `x` | Two things: the army's side (never read), then a count of track. | `routes` | |
| `menu_railroad` | `target`, `from`, `x1` | The city whose track is counted, the city the train leaves, the city it goes to. | `route_city`, `from_city`, `to_city` | |
| `menu_army_detach`, `menu_army_drill` | `target` | The army's city. | `city` | |
| `menu_army_detach` | `empty` | A free army slot. | `slot` | `army_slot` |
| `menu_victory_conditions` | `chosit` | The option the menu starts on next time, as 21 + its row. | `start_option` | |
| `report_armies` | `x`, `y` | Several numbers in turn: the two sides' victory points added up, three percents, the income of both sides with the capitals' bonus. | `total_points`, `percent`, `all_income` (`total_income` is shared) | `total_points`, `percent`, `all_income`, `total_troops`, `ironclads`, `row` |
| `report_intelligence` | `z` | The width of an army's box, in columns. | `box_width` | |
| `report_force_summary` | `summ()` | The men in each city. | `city_men()` | `city_troops()` |
| `report_recap` | `x` | The lines printed. | `line_count` | |
| `check_map_links` | `x`, `y` | The roads that could not be fixed, and the roads fixed. | `unresolved`, `fixed` | |
| `print_centered` | `y` (parameter), `x` | The row, and the column it starts at. | `row`, `col` | |
| `draw_top_bar` | `x`, `y` | The two sides' victory points added up, and the side's percent of them. | `total_points`, `percent` | |
| `turn_move_army` | `target` | The city the army marches to. | `to_city` | |
| `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats` | `target` (parameter) | The city that is attacked. | `city` | |
| `turn_attack` | `win`, `lose` | The armies that won and lost. | `winner`, `loser` | |
| `turn_defender_retreats` | `s` | The attacker's side, passed to `turn_retreat_city`. | `attacker_side` | |
| `turn_defender_retreats` | `flee` | The city the player picked to retreat to. | `chosen_city` | |
| `turn_defender_retreats` | `move2` | The city the army retreats to. | `retreat_city` | |
| `turn_army_surrenders` | `x` | The army's side. | `side` | |
| `turn_enter_city` | `c` | The city entered. | `city` | `city`; its parameter `target` is `to_city` |
| `ai_turn` | `who` | The computer's side. | `ai_side` | |
| `hall_of_fame` | `a$` | The commander's name, typed in. | `commander$` | |
| `hall_of_fame`, `end_game` | `j`, `k` | Declared and never used. | Delete | |

### Part 2: `GOTO` and `GOSUB` labels

There were about 90 labels. Most did nothing but skip to the next pass of a loop (`GOTO puter` landed on
`puter: NEXT i`), leave a loop, or go to the end of a SUB. On 2026-11-12 those were replaced by `_CONTINUE`,
`EXIT FOR`, `EXIT SUB`, an `IF` block or a `DO` loop, and their labels are gone
([`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy), "After the plan: the labels"). No `GOSUB` is left.

### Part 3: constants that read unclearly

Renamed on 2026-11-12 with the proposed names (user). Only the names changed, not the values.

| Was | Now | What it means |
|-----|-----|---------------|
| `SHOW_NOT` | `SHOW_HISTORY_ONLY` | `scribe_message` writes to the history only. |
| `BLAST_FIRM`, `BLAST_LOYAL`, `BLAST_NEUTRAL` | `BOMBARD_HOLDS`, `BOMBARD_CAPITAL_HOLDS`, `BOMBARD_TURNS_NEUTRAL` | The result of `navy_blast`: the city stands firm, it is the capital and stays loyal, or it turns neutral. |

### Part 4: found while reading

Items 1 to 3 and 7 were names that said the wrong thing; part 1b renamed them.

1. **`show_message_box (text$, seconds)`**: `seconds` is the box's color. Every caller passes 4.
2. **`draw_surrender (side)`** is passed an army and calls `army_side(side)` on it.
3. **`ai_evaluate_move (army, x)`**: `x` is a weight going in and the chosen road coming out.
7. **`turn_strength_ratio`** uses `y` for the Union and `x` for the Rebels. `victory_forces` and its callers
   use them the other way round. Not a bug, but easy to get wrong. The proposed names remove it.

**Dead locals, deleted on 2026-11-12.** A scan listed every local and parameter that is never read in its SUB.
These eight locals were deleted, with the lines that only set them: `brx` and `bry` (`menu_select`), `x` and
`y` (`show_message_box`), `x` (`turn_set_move_order`, which also lost its empty `CASE ELSE`), `target`
(`menu_army_relieve`), `j` (`hall_of_fame`) and `k` (`end_game`).

Found by the same scan and kept:

- `unused!` in `random_discard`: it is set and never read on purpose, to use up one random number.
- Two parameters that are never used: `side` of `army_combine_done` and `city` of `navy_blast`. Taking them out
  changes their callers too.
- Parameters that are only set: these are the SUBs' results (`ordered`, `again`, `result` and the others).

## Done: where each SUB goes (phase 6)

Was `docs\archived\file-layout-completed.md`.

The finished parts of `file-layout.md`, moved here on 2026-11-13, under the same headings: the questions
asked before phase 6 moved the SUBs. Phase 6 is done. Questions 2 and 3, whether the war's pictures go to
`game\`, are now phase 11's step 1 (`modernize-plan.md`).

### Questions for the user

1. `file_management` is saved-game work, not a port of QB64. `port\files.bm` is my pick. Phase 7 splits it
   into the file work and the screen work; the file part could then go to `rules\save.bm`.
2. `draw_cannon` and `draw_chesapeake` are Civil War pictures. They could go to `game\` with the victory
   screens. I put them in `draw\pictures.bm` because the plan names that file; say if you prefer `game\`.
3. `draw_ironclad` and `draw_schooner` are the same: ship pictures of this war, kept in `draw\ships.bm`.
4. 80 SUBs and FUNCTIONs, 11 of them marked mixed. The count per file runs from 1 to 8.

### The tables of procedures, to 2026-11-14

`file-layout.md` listed every procedure of every file from phase 6 until 2026-11-14, with where each
came from. The list had fallen behind the code (23 procedures missing, five gone), so it was cut to one
line per file. The tables follow as they were last written. `port\` is `io\` since then, and
`tools\refactor\arrange_files.py` moved five procedures and put `rules\army.bm` in a new order.

#### rules\

| File | SUBs |
|------|------|
| `army.bm` | `army_list_combine_cities`, `army_set_order`, `army_free_leader`, `army_take_leader` (new in phase 9), `army_appoint` (new 2026-11-13: a slot takes a free leader, once written in five places), `army_can_drill`, `side_can_detach`, `army_in_field`, `side_strength` (new 2026-11-13: rules the player and the computer checked each in their own code), `army_combine_start`, `army_combine_add`, `army_combine_absorb`, `army_combine_finish`, `army_raise`, `army_pick_commander`, `army_buy_supply`, `army_add_recruits`, `army_recruit_cities`, `army_detach`, `army_drill`, `army_recruit_bonus`, `army_generate_name`, `side_first_army`, `side_last_army`, `sort_move_order`, `army_side`, `other_side`, `recruit_troops`, `recruits_cut_off` (new after the plan), `army_exists`, `army_has_move`, `army_has_acted` (new 2026-11-13, [`structure-review-completed.md`](#done-the-review-of-the-structure-of-the-games-code) item 2), `army_clear` (new 2026-11-13: the six fields that five SUBs cleared) (`army_combine`, `army_new`, `army_get_commander`, `army_resupply` and `army_recruit` until phase 8 moved them to `ui\army.bm`) |
| `city.bm` | `city_build_fort`, `capital_move_pay`, `capital_move_to` (new in phase 9), `fort_affordable`, `capital_can_move` (new 2026-11-13), `city_take`, `city_is_connected`, `city_fix_return_routes`, `city_update_occupier`, `city_list_sort` (new 2026-11-13, [`structure-review-completed.md`](#done-the-review-of-the-structure-of-the-games-code) item 4), `side_city_step`, `side_city_by_letter` (new 2026-11-14: the city picker's steps) (`city_capture` and `check_map_links` until phase 8 moved them to `ui\city.bm`) |
| `battle.bm` | `battle_strengths`, `battle_fight`, `battle_size_rate!` (new 2026-11-13), `battle_losses`, `battle_apply_losses`, `normal_random_number` (`calculate_battle` until phase 8 split it) |
| `navy.bm` | `fleet_exists`, `fleet_is_at_sea` (new 2026-11-13, [`structure-review-completed.md`](#done-the-review-of-the-structure-of-the-games-code) item 2), `navy_mark_side`, `navy_count_ships`, `navy_has_ironclads`, `navy_list_shipyards`, `navy_list_ports`, `navy_can_invade` (new 2026-11-13, item 4), `random_discard` (new in phase 9), `navy_clear_fleet` (new 2026-11-13: the fleet is gone, once written in four places), `ship_cost`, `navy_can_build`, `navy_can_attack`, `navy_can_raid` (new 2026-11-13), `navy_remove_ship`, `navy_add_ship`, `navy_found_fleet`, `navy_cancel_new_fleet`, `navy_bombard_army`, `navy_shore_battery`, `navy_fleet_lost`, `navy_blast`, `navy_move_fleet`, `navy_go_raiding`, `navy_landed`, `navy_note_raiding_side`, `navy_raid_round`, `navy_ship_hits`, `navy_shot_hits`, `navy_fleet_defeated`, `navy_retreat_port` (the rest until phase 8 moved them to `ui\navy.bm`) |
| `railroad.bm` | `railroad_board`, `railroad_unload`, `railroad_route_count`, `railroad_capacity` (`railroad_move`, `railroad_start` and `railroad_arrive` until phase 8 moved them to `ui\railroad.bm`) |
| `turn.bm` | `turn_set_moves_done`, `turn_set_navy_done`, `turn_reset_commands`, `turn_check_commands`, `turn_close_recruiting`, `turn_next_player` (new in phase 9), `winter_stops_move` (new 2026-11-13), `turn_advance_month`, `turn_army_supply`, `turn_strength_ratio`, `turn_army_marches`, `turn_battle_experience`, `turn_withdraw`, `turn_defender_halts`, `turn_retreat_city`, `turn_retreat_to`, `turn_army_lost`, `turn_occupy`, `turn_raze_fort`, `turn_army_forages`, `turn_collect_income`, `turn_set_move_order`, `turn_update_victory_points` (the eight others until phase 8 moved them to `ui\turn.bm`) |
| `setup.bm` | `set_union_advantage`, `vary_start_conditions` (new in phase 7), `balance_help` (new 2026-11-13: the Balance setting's help for the computer, once worked out four times); the Utility menu's settings (new in phase 9): `option_swap_side`, `option_toggle_players`, `option_next_graphics`, `option_set_sound`, `option_set_display_speed`, `option_toggle_alt_colors`, `option_set_balance`, `option_set_event_balance`, `option_toggle_winter_campaigns`, `option_toggle_realism`, `option_toggle_history`, `option_next_aggression`, `option_events_favor_computer` (new after the plan); the start of a game (new in phase 9, out of the main module): `game_new`, `game_reset`, `game_apply_settings` |
| `victory.bm` | `victory_toggle_rule` (new in phase 9), `victory_forces`, `victory_time_near`, `victory_rule_met`, `victory_near_cities`, `victory_near_income`, `victory_near_force`, `victory_play_on`, `victory_won`, `victory_technical_points`, `hall_of_fame_place`, `hall_of_fame_insert` (`check_victory_conditions`, `victory_warnings`, `end_game` and `hall_of_fame` until phase 8 moved them to `ui\victory.bm`) |
| `events.bm` | `event_roll`, `event_pick`, `event_target`, `event_chance!`, `event_conditions_hold`, `event_possible`, `event_delivery_port`, `event_apply`, `event_riot_city`, `event_find` (in `game\` until phase 11 made the events data: `scenarios\EVENTS.DAT`) |

#### ai\

| File | SUBs |
|------|------|
| `army.bm` | `ai_army_orders`, `ai_army_order`, `ai_drill`, `ai_evaluate_move`, `ai_stay_weight`, `ai_move_strength`, `ai_city_targeted`, `ai_attack_score`, `ai_beyond_score` (new 2026-11-14: the parts of `ai_evaluate_move`), `city_nearby_enemy_strength`, `ai_combine`, `ai_razes_fort` (`ai_turn` until phase 8 moved it to `ui\turn.bm`) |
| `forces.bm` | `ai_resupply`, `ai_fortify`, `ai_fortify_pick`, `ai_raise_forces`, `ai_count_armies`, `ai_recruit`, `ai_recruit_pick` |
| `navy.bm` | `ai_fleet_orders`, `ai_pick_port`, `ai_navy_orders`, `ai_navy_build`, `ai_navy_attack`, `ai_navy_sail`, `ai_navy_raid`, `ai_navy_invade` (new in phase 9: the computer's half of the navy's commands), `ai_navy`, `ai_navy_adjust` |
| `railroad.bm` | `ai_railroad_orders`, `ai_railroad`, `ai_railroad_army`, `ai_railroad_city` (new 2026-11-14: the two halves of `ai_railroad`) |

The four files were one, `ai.bm`, until 2026-11-14 (`tools\refactor\split_files.py`).

#### commands\

The orders that the player's menus and the computer both give (new in phase 9). A command calls rules
and shows what happened. Nothing here opens a menu or reads a key.

| File | SUBs |
|------|------|
| `army.bm` | `army_combine_gather`, `army_combine_done`, `army_combine_redraw`, `army_new`, `army_get_commander`, `army_resupply`, `army_recruit` (from `ui\army.bm`; `army_combine` until phase 9 split it) |
| `city.bm` | `city_capture` (from `ui\city.bm`), `city_fortify` (new 2026-11-14: the fort and its message, for the player and the computer) |
| `railroad.bm` | `railroad_finish`, `railroad_start`, `railroad_arrive` (from `ui\railroad.bm`; `railroad_move` until phase 9 split it) |
| `navy.bm` | `navy_ship_joins`, `navy_fleet_founded`, `navy_bombard`, `navy_say_no_ships`, `navy_sail_to`, `navy_start_raid`, `navy_land_army`, `navy_finish_move`, `navy_redraw_map`, `navy_commerce_raid`, `navy_combat_begin`, `navy_combat_draw`, `navy_combat_volley`, `navy_combat_retreat`, `navy_combat_auto`, `navy_show_hits` (from `ui\navy.bm`) |

#### ui\

| File | SUBs |
|------|------|
| `menu.bm` | `menu_select`, `menu_place`, `menu_start_row`, `menu_wait_key$`, `menu_letter_row`, `menu_show_selected`, `menu_show_plain` (new 2026-11-14: the parts of `menu_select`), `menu_arrow_key` (new in phase 9), `menu_redraw` (new 2026-11-13), `menu_mark_row`, `menu_unmark_row`, `menu_measure_width`, `menu_bubble_sort`, `menu_set_cities` (new 2026-11-13), `menu_add_row`, `menu_short_name$`, `menu_set_two` (new 2026-11-14: rows that 15 places wrote out), `draw_menu` |
| `main_menu.bm` | `menu_main`, `menu_main_railroad`, `menu_main_end_turn`, `menu_main_inform`, `show_title`, `menu_title`, `show_new_game` (new in phase 9: the main menu and the title, out of the main module) |
| `orders.bm` | `menu_commands` (new in phase 9: the Commands menu, out of the main module). The menus of its entries moved to `army.bm`, `city.bm`, `railroad.bm` and `navy.bm` on 2026-11-14 |
| `city.bm` | `menu_city_fortify`, `menu_city_select`, `menu_move_capital` (from `orders.bm`, 2026-11-14). `draw_fort_built` became part of `city_fortify` (`commands\city.bm`) on 2026-11-14 |
| `railroad.bm` | `menu_railroad` (from `orders.bm`, 2026-11-14) |
| `options.bm` | `menu_utility`, `menu_option_side`, `menu_option_players`, `menu_option_graphics`, `menu_option_sound`, `menu_option_display`, `menu_option_balance`, `menu_option_events`, `menu_option_january`, `menu_option_realism`, `menu_option_history`, `menu_option_aggression` (new in phase 9: the Utility menu, out of the main module) |
| `files.bm` | `menu_files`, `menu_load_game`, `menu_save_game`, `menu_quit` (new in phase 9: the Files menu, out of the main module and `port\files.bm`) |
| `reports.bm` | `menu_report`, `menu_victory_conditions`, `draw_army_stats`, `print_army_size`, `troops_text$` (new 2026-11-14: a number of troops, once written in 11 places), `check_map_links` (from `ui\city.bm` in phase 9) |
| `screen.bm` | `clear_bottom_line`, `clear_right_panel`, `screen_snapshot`, `wait_seconds`, `print_centered`, `draw_top_bar`, `draw_train_box`, `draw_player_turn`, `draw_update_box` |
| `messages.bm` | `show_message_box`, `scribe_message` |
| `battle.bm` | `calculate_battle` (new in phase 8: the battle's screen), `draw_battle_attacker`, `draw_battle_defender`, `battle_odds_text$`, `draw_battle_odds`, `draw_battle_fort`, `battle_cannon_sound`, `cannon_shot` (new 2026-11-14: also the ships' guns in `commands\navy.bm`), `draw_battle_winner`, `draw_battle_losses`, `battle_history_line$` (new 2026-11-14: the parts of `calculate_battle`) |
| `army.bm` | `menu_army_combine`, `menu_raze_fort` (new in phase 9: the player's Join and Raze menus; the file of phase 8 moved to `commands\army.bm`); `menu_army_move`, `menu_army_select`, `menu_army_recruit`, `draw_recruit_funds`, `menu_recruit_cities`, `menu_army_cancel`, `menu_army_relieve`, `menu_army_retreat`, `menu_supply`, `menu_army_detach`, `menu_army_drill` (from `orders.bm`, 2026-11-14) |
| `navy.bm` | `menu_navy_commands`, `menu_navy_build`, `menu_navy_attack`, `menu_navy_sail`, `menu_navy_raid`, `menu_navy_invade`, `menu_navy_combat` (new in phase 9: the player's half of the navy's commands; the file of phase 8 moved to `commands\navy.bm`); `menu_navy`, `menu_navy_items` (from `orders.bm`, 2026-11-14) |
| `turn.bm` | `turn_date_and_supply`, `turn_resolve`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats`, `turn_army_surrenders`, `turn_enter_city`, `ai_turn` (new in phase 8: the month's moves) |
| `ai.bm` | `draw_ai_plan`, `draw_ai_drill`, `draw_ai_funds`, `draw_ai_navy_color` (new in phase 8: the computer's messages), `draw_ai_recruit_color` (new 2026-11-13) |
| `events.bm` | `special_events`, `event_show_city` (`event_riot` until phase 11), `event_message$`, `text_replace` (new in phase 8: the special events' messages and tunes) |
| `victory.bm` | `check_victory_conditions`, `victory_warnings`, `end_game`, `hall_of_fame` (new in phase 8: the warnings, the victory screens and the Hall of Fame) |

#### draw\

| File | SUBs |
|------|------|
| `map.bm` | `draw_map`, `draw_map_touchup`, `draw_cities`, `draw_city_names`, `draw_map_marker`, `draw_stack_markers`, `draw_fleets` |
| `icons.bm` | `draw_flag_icon`, `draw_large_flag`, `draw_army_flag`, `draw_train`, `animate_army`, `animate_city`; `flag_x`, `flag_y`, `draw_erase_flag`, `flag_picture_save`, `flag_picture_restore` (new 2026-11-13: the flag's place beside a city, once worked out in six places, two of them in `commands\`) |
| `ships.bm` | `draw_fleet_ship`, `draw_ship_icon`, `ship_icon` (new 2026-11-13), `draw_ironclad`, `draw_schooner`, `draw_fleet_sailing`, `draw_navy_box`, `draw_ship_sunk` |
| `pictures.bm` | `draw_cannon`, `draw_chesapeake`, `draw_title` |

#### game\ (what another war replaces)

| File | SUBs |
|------|------|
| `victory_screens.bm` | `draw_union_victory`, `draw_rebel_victory`, `draw_surrender` |
| `tunes.bm` | `play_shenandoah`, `play_title_music` |
| `colors.bm` | `side_color_of`, `city_dot_color` (new after the plan: the sides' colors, once written out in 11 places), `side_bright_color`, `side_panel_color` (new 2026-11-13: the two other pairs, once written out in 7 places) |

#### port\

| File | SUBs |
|------|------|
| `files.bm` | `hall_of_fame_load`, `hall_of_fame_save`, `load_scenario`, `load_scenario_armies` (new 2026-11-13: one side's armies, once written twice), `load_cities`, `load_game`, `save_game`, `saved_games_check`, `any_saved_game`, `save_file_name$` (new 2026-11-13), `history_start`, `config_read`, `config_write`, `save_battle_summary` (`file_management` until phase 7 split it; the menus of `load_game` and `save_game` until phase 9 moved them to `ui\files.bm`) |
| `events_file.bm` | `load_events`, `event_clear_row`, `event_read_line`, `event_read_side`, `event_read_conditions`, `event_read_effect`, `event_read_chance`, `text_is_number`, `text_last_space` (from `files.bm`, 2026-11-14), `event_row_problem$`, `event_general_problem$` (new 2026-11-14: the checks at the end of `load_events`) |
| `script.bm` | `script_start`, `script_date$`, `script_tick%`, `script_shell`, `script_mark_key_wait` (from `SCRIPT.BM`) |

## Plan: scenarios in folders, picked in the game

Was `docs\archived\scenario-plan.md`.

Drafted 2026-11-13. Done: steps 1 to 3 are committed (`2ba37f5`, `f97722d`, `fe4d78d`), and step 4
is the commit that adds this line. What each step did is in [`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy).

### Goal

The player picks the map inside the game. `scenarios\ALTMAP.BAT` goes away. A saved game knows which
scenario it belongs to. A new scenario is added by adding a folder and one line to a list.

This also serves phase 11 of `modernize-plan.md`, whose test is that a second war is made by replacing
`game\` and `scenarios\`.

### What is wrong today

- **The switch is outside the game.** `ALTMAP.BAT` renames six files in `scenarios\`. It runs only on
  Windows. Nothing in the game says which map is active.
- **A saved game does not know its map.** `save_game` (`port\files.bm`) writes armies and city owners by
  city number, with no map name. Read from the code, not tried: a game saved on one map and loaded after
  the switch loads without complaint onto the other map.
- **The file names are fixed.** `load_scenario` opens `cws.ini` and `cwslead.dat`, and `load_cities` opens
  `cities.grd`. `game_new` calls both before the title menu (`cws.bas` line 12).
- **The tests go around the batch file.** `play.py` has its own `swap_altmap`, and `TODO.md` lists
  `ALTMAP.BAT` itself as untested.

### Decided (user, 2026-11-13)

1. **It is built in this repo**, not in `pretzel-wargames`.
2. **One folder for each scenario**, not a suffix in the file names.

### Decided as proposed (user, 2026-11-13)

Claude proposed P1 to P6. The user accepted all six ("implement per your recommendations").

- **P1. Change decisions 3 and 6 of `modernize-plan.md`.** Decision 3 says every step keeps the recorded
  screens identical. Decision 6 says the saved-game file keeps its format. Steps 2 and 3 below break both.
  Proposed wording for decision 3: "A refactor step keeps the recorded screens identical. A change to
  behavior or the screen that is meant is its own commit. It records again only the scripts whose
  checkpoints differ, and its commit message lists them." Decision 6 gets the same exception for the
  scenario name. The user asked on 2026-11-13 whether the rule must be held rigidly; this is the answer
  proposed.
- **P2. A list file names the scenarios**: `scenarios\SCENARIOS.LST`, one line for each scenario with its
  folder and its title. The menu shows the titles in the file's order. The first line is the scenario that
  loads before the title menu. A list avoids `DIR$` on folders, which is untested on Linux.
- **P3. The titles**: "Standard Map" and "Alternate Map". `docs\CWS.DOC` may have better names.
- **P4. A saved game without a scenario name loads as the first scenario**, which is what happens today.
  The other choice is to refuse it.
- **P5. The scenario menu is not shown when the list has one line.**
- **P6. The leaders stay a file of each scenario.** `CWSLEAD.DAT` and `ALTLEAD.DAT` are the same bytes
  today. Wars of Napoleon has leaders for each scenario, so the file stays in the folder.

### The layout

```
scenarios\
    EVENTS.DAT                 the war's events, for every scenario (as today)
    SCENARIOS.LST              the list: folder and title
    standard\
        CITIES.GRD  CWS.INI  CWSLEAD.DAT
    alternate\
        CITIES.GRD  CWS.INI  CWSLEAD.DAT       (today ALTMAP.GRD, ALTMAP.INI, ALTLEAD.DAT)
```

The six files move with `git mv`. Their contents do not change.

### Steps

Each step is one commit. After each, `python tests\play.py check` and the unit tests run with both
compilers, as in the modernize plan.

#### Step 1: the folders (a refactor step: no screen changes)

- `git mv` the six files into `standard\` and `alternate\`. Add `SCENARIOS.LST`.
- A shared `scenario_folder$` (`cws.bi`) holds the scenario's folder. A FUNCTION `scenario_file$(name$)`
  gives `SCNDIR + scenario_folder$ + "/" + name$`. `load_scenario` and `load_cities` use it.
- `game_new` reads the list and sets `scenario_folder$` to its first line.
- `play.py`: `#! altmap` copies the three files of `alternate\` over those of `standard\` in the run's
  folder. This keeps the four alternate-map scripts running until step 2 replaces the directive.
- `make_save.py` reads the opening from `scenarios\standard\`. `tests\data\bad-map\scenarios\CITIES.GRD`
  moves to `bad-map\scenarios\standard\`.
- The user runs `git rm scenarios/ALTMAP.BAT`. The batch file cannot work after the move.
- **Check:** all 39 scripts pass with nothing recorded again.

#### Step 2: the menu (changes the screen)

- After "Start NEW Game", `menu_scenario` (`ui\main_menu.bm`) lists the titles. Esc goes back to the
  title menu.
- When the choice is not the scenario already loaded, `game_new` runs again with that folder. Found:
  `game_apply_settings` draws two random numbers (each side's extra cash, `50 * RND`). The first load
  draws them before `script_start` seeds the numbers; the second draws them after. So a game on the
  standard map plays as before, and a game on the alternate map starts with other cash and goes
  differently (one checked: the Union's April 1861 funds are 364, not 350).
- Every script that chooses Start NEW Game gets one more line to answer the menu. `make_scripts.py` writes
  it for the 14 generated games. The scripts that resume a prepared save do not pass the menu.
- `#! altmap` goes. The four alternate-map scripts pick the second row. `swap_altmap` and its test in
  `test_play.py` are deleted.
- To check first: which wait letter the new menu announces, and that no `rule` line of a script already
  answers that letter.
- **Check:** the digests at the title menu and the main menus should not change, because the menu is gone
  before the map is drawn. Any script whose digest does change is recorded again and named in the commit
  message.

#### Step 3: the saved game (changes the file)

- `save_game` writes the scenario's folder name as the first field. `load_game` reads it. When it names
  another scenario than the one loaded, the leaders and the cities of that scenario are read first.
- To check: `load_cities` adds to each side's city count, points and cash. `load_game` must still end
  with the saved values. Found: it does, because the save holds all three and is read after the
  reload. The save must be closed during the reload, because `load_scenario` and `load_cities` read
  their files as #1 too. With the file left open, QB64Rust ended with exit code 1 and QB64pe went on.
- A save that names a folder that is missing gives a message and goes back to the menu.
- A save without the field follows P4.
- `make_save.py` writes the field. The round-trip test in `tests\rules_test.bas` (near line 1855) gets
  the scenario.
- One new script: start on the alternate map, save, New Game, Resume Saved Game. Its digest shows the
  alternate map.
- **Check:** `files` checks `cws1.sav` and `cws2.sav` by their hashes, so it is recorded again. No other
  script names a `.sav` file in `#! files`.

#### Step 4: the documents

- `README.md`: how to pick the map. `docs\devnotes.md` item 9, `docs\file-layout.md` and `tests\README.md`
  (`#! altmap`, the script table).
- `TODO.md`: the row "`ALTMAP.BAT` itself" goes.
- Comments: `port\folders.bi` (the `SCNDIR` line) and `port\files.bm` ("ALTMAP does not swap this file").
- `modernize-plan.md`: decisions 3 and 6 as P1 is answered. [`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy): what each step did.

### Not in this plan

- **Splitting `CWS.INI`.** Its side names, month names and flag star positions are the war's, and they
  are the same in both scenarios. Wars of Napoleon keeps such lines in `gamedata.ini`. This is a step for
  phase 11 or the engine split.
- **Settings and the Hall of Fame for each scenario.** `CWS.CFG` and `HISCORE.CWS` stay shared.
- **Linux file names.** The game opens lower-case names of upper-case files. That row stays in `TODO.md`.
- **The copy in `pretzel-wargames`.** It is a copy of 2026-11-10 and is not updated by this plan.

## Done: the review of the structure of the game's code

Was `docs\archived\structure-review-completed.md`.

The finished parts and original findings of `../structure-review.md`, archived from 2026-11-13
onward. Original findings, decisions and the second review's shared-rule results were moved here
on 2026-11-14. The review closed on 2026-11-14: its last open item, the map's city numbers, went
to step 1 of phase 11 in `../modernize-plan.md`, and its deferred items are at the end of this file.

### The first review: findings and recommendation

Written 2026-11-13, after phase 9 of `modernize-plan.md` and phase 11's step 2. It asks whether the code is
structured the best way, and which patterns would make it easier to read and change. It started from the
nested `IF`s of `ai\ai.bm`.

Original findings and recommendation, retained as the record of the first review. Items 1 to 5
were completed below; the map's city numbers are in phase 11 step 1. Counts describe the tree
on the date of the review.

#### How it was measured

A scratch script (`tests\out\scratch\survey.py`, not committed) read every `.bm` file and `cws.bas`. It found
349 procedures: 313 SUBs and 36 FUNCTIONs. The counts below are from it, or from `grep`, on the working tree
of 2026-11-13. They are rough: the script reads text, not a parse tree.

#### Summary

The layering is sound. Cleaning `ai\ai.bm` line by line treats symptoms. Most of its tangled conditions come
from four causes that run through the whole game. Fixing those removes more than a clean-up of one file.

#### What is working

- **The folders hold.** `rules\` makes 335 assignments to shared game state; `ui\` makes 4.
- **The safety net holds.** 40 whole-game scripts, 152 unit tests and two compilers. They caught nothing wrong
  in the first clean-up of `ai\ai.bm` (below).

#### The four causes

##### 1. One variable carries several meanings, and every caller decodes it

| Variable | Its values | Tests at call sites |
|----------|------------|--------------------:|
| `fleet_city()` | a city; 0 for "no fleet"; 99 (`FLEET_AT_SEA`) for "at sea" | 35 |
| `army_order()` | a city; 0, -1 or -2 (`ORDER_NONE`, `ORDER_BUSY`, `ORDER_DONE`) | 45 |
| `army_city()` | a city; `> 0` also means "this army exists" | 32 |

**Fix:** a few FUNCTIONs that name each test, such as `fleet_in_port(side)`, `army_exists(i)` and
`army_has_move(i)`. The arrays stay as they are.

##### 2. The menu's globals are a return channel for code that is not a menu

- `rules\` and `ai\` use `menu_value()` and `menu_text$()` 28 times.
- `ai_evaluate_move` keeps its scores in `menu_value()`.
- `ai_recruit_pick` returns its pick in `menu_choice`.

**Fix:** a SUB that makes a list fills an array its caller passes. A SUB that picks one item becomes a
FUNCTION.

##### 3. Results come back through parameters

97 SUBs assign to one of their parameters: `again`, `quit`, `ordered`, `refuge`, `sailed` and others. How many
of them return exactly one value was not counted.

**Fix:** where a SUB returns one value, make it a FUNCTION. `refuge = turn_retreat_city(city, side)` reads
better than a third parameter.

##### 4. Code is written twice: once for each side, and once for the player and once for the computer

- `turn_update_victory_points` (`rules\turn.bm`) is the same four lines for each side, except for one kept
  bug (`TODO.md`, the Rebels' bonus built on the Union's points).
- `menu_navy_commands` (`ui\navy.bm`) and `ai_navy_orders` (`ai\navy.bm`) are the same loop. Their Build
  checks differ slightly. Three `random_discard` calls keep the random numbers in step between them.

**Fix:** one SUB that takes `side`. For a command: one shared rule such as `navy_can_build(side)`; then the
menu or the computer chooses; then the command in `commands\` runs.

#### Two findings for the second-war goal

- **City numbers are in the code.** City 30 is in `ai\navy.bm` (lines 6, 7, 98 and 100) and `draw\map.bm`
  (line 519). City 27 is in `rules\setup.bm` (line 34), and city 24 in `draw\map.bm` (line 148). These fail
  phase 11's test that a second war replaces only `game\` and `scenarios\`.
- **The folder rules are kept only by convention.** Phase 8's script that found the mixed SUBs
  (`p8_mixed.py`) was never committed. A small test that fails when `rules\` or `ai\` calls into `ui\` or
  `draw\` would keep the rule.

#### The panel

- **Pragmatic engineer:** Do causes 1 and 3 first. They are mechanical, keep the screens identical, and
  shorten conditions in every file.
- **QB64 engineer:** Cause 2 is safe as long as the arrays are passed in the same order and no `RND` moves.
  Both compilers pass arrays by reference.
- **Compiler/languages engineer:** This is evidence for phase 11's step 5, the list of what QB64 made
  awkward. Three things stand out: a FUNCTION returns one value, there is no `ENUM` (`cws.bi` has 179 `CONST`
  lines, in groups), and there are no modules (126 shared names, all global).
- **Rust engineer:** Do not reopen records. The ruling of 2026-11-12 ([`modernize-plan-completed.md`](#done-modernizing-the-code-of-civil-war-strategy), "Phase 10:
  records") still fits: the predicates of cause 1 give most of the readability without them.
- **Test engineer:** Commit the layer check first. Add a unit test for each new predicate.
- **Game-AI engineer** (added because the computer's move scoring is a utility AI): The merge of the
  player's and the computer's commands in cause 4 changes the random draws, so it cannot keep the screens
  identical. It belongs after the kept bugs are ruled on.

#### Recommendation

In this order, each a commit that keeps the recorded screens identical:

1. The layer check, as a test.
2. The state predicates (cause 1).
3. SUBs that return one value become FUNCTIONs (cause 3).
4. The menu's globals out of `rules\` and `ai\` (cause 2).
5. The identical halves for each side become one SUB (cause 4, first part).
6. The city numbers move into the scenario's data.

### Already done

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

**Item 5, one SUB for both sides**, in the working tree on 2026-11-13, not committed.
`turn_update_victory_points (side)` (`rules\turn.bm`) does one side's month; `turn_resolve` (`ui\turn.bm`)
and the unit test call it for the Union, then the Rebels. The two halves differed in one line: only the
Union's points stop at 0. That line is kept behind `side = SIDE_UNION`, and `TODO.md` has a row for it.
A new unit test, `TestOnlyUnionVictoryPointsStopAtZero`, pins it and the strength ratio. The 40 scripts
passed `check` and `compare` on unchanged recordings, and the 158 unit tests passed.

**Item 3, SUBs that return one value**, in the working tree on 2026-11-13, not committed. 76 SUBs assign
to a parameter, and 55 to exactly one. Four became FUNCTIONs: `ai_fortify_pick (side)`,
`normal_random_number (mean, variance)`, `turn_retreat_city (city, attacker_side)` and
`text_replace$ (text$, find$, with$)`. Each only picks, draws a number or builds a text.
The others stay SUBs, for these reasons:

- Most change the game as their main work (buy supply, bombard, move a fleet, set an order) and return
  only a flag such as `again`, `raised` or `sailed`. A FUNCTION would hide that work.
- The menus draw and read keys.
- `ai_navy` leaves `action` as it was when no rule applies, so it is an input too.
- `victory_rule_met` also gives 300 victory points, and `army_pick_commander` also writes a made-up name.
- `ai_evaluate_move` keeps its scores in `menu_value()`, so it waits for item 4.

`TestTextReplaceEveryPlace` is new. The 40 scripts passed `check` and `compare` on unchanged
recordings, and the 159 unit tests passed.

**Item 4, the menu's globals out of `rules\` and `ai\`**, in the working tree on 2026-11-13, not
committed. Neither folder names a menu variable any more, and `tests\test_layers.py` checks it
(`test_rules_and_ai_leave_the_menu_alone`). Four rows of its `ALLOWED` are gone; `ai_fortify`'s call
of `draw_fort_built` is the one left.

- **Lists.** `army_list_combine_cities`, `army_recruit_cities`, `navy_list_shipyards` and
  `navy_list_ports` fill an array the caller passes, with a count. `city_list_sort` (`rules\city.bm`)
  sorts by name as `menu_bubble_sort` did, so the lists keep their order. The player's menus copy a
  list into the menu with `menu_set_cities` (`ui\menu.bm`), and set the menu's place and colors
  that the rules set before.
- **Picks.** `ai_recruit_pick` and `ai_pick_port` are FUNCTIONs that give a city. `ai_navy_orders`
  chooses by its `action`, not `menu_choice`. `ai_army_order` lost a line that never ran.
- **Scores.** `ai_evaluate_move` keeps its scores in a local `road_score()`.
- **Invasion.** `navy_can_invade` (`rules\navy.bm`) is the test that the Ships menu and
  `ai_navy_adjust` share. The computer filled the Ships menu to read its row count.
- **The computer's screen.** `draw_ai_funds` takes the list's count. `draw_ai_recruit_color`
  (`ui\ai.bm`) sets the color the player's list set for the computer before.

What the computer left in the menu's variables could change no screen. The menus that open in its
turn, Retreat and End Game, set their own place and colors. The values it left in `menu_choice` give
row 1, as the player's End Turn does. One read was a bug: `ai_pick_port` set the row to 30, and
`menu_value(30)` was always 0, so the fleet stayed in port. It returns 0 now (`TODO.md`). The 40
scripts passed `check` and `compare` on unchanged recordings, the 161 unit tests passed, and every
changed line runs under the tests.

### The second review: one idea written in several places

Written 2026-11-13, after the merges of the literal copies (`army_clear`, `load_scenario_armies`,
`battle_size_rate!`, `save_file_name$`, `side_color_of`). It looked for a rule or a fact that the code
states in several places in different words. Read in full: `ai\`, `rules\`, `commands\`, and in `ui\`
the orders, navy, army, turn, battle, menu, report and option menus. Skimmed: `draw\map.bm`,
`draw\ships.bm`, `draw\pictures.bm`, `game\`, and `ui\screen.bm`, `files.bm`, `victory.bm` and
`events.bm`.

The user took the pragmatic engineer's plan ("do as recommended", 2026-11-13). Items 4 and 9 and
the small repeats were left out. Items 4 and 9 stay as they are ("Left as they are, from the
second review", below). The small repeats were done on 2026-11-14 ("The small repeats", below).

#### The rules that the player's menus and the computer each checked

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

#### Done, keeping every screen

In the working tree on 2026-11-13, not committed. Each part passed the unit tests and the 40 scripts'
`check` on unchanged recordings.

1. **The Balance setting's help for the computer.** `balance_help (side)` (`rules\setup.bm`) is how
   many steps the setting helps the computer's side. The extra recruits are 5 times it, the attack and
   the defense in battle 2 times it, and the starting cash 100 times 3 more than it. The four places
   wrote the same test and formula each in its own way. `TestBalanceHelpGoesToTheComputer` pins it.
2. **A slot takes a free leader.** `army_appoint (army, leader)` (`rules\army.bm`) replaces the same
   three lines in `army_raise`, `army_detach`, `event_new_army` and `load_scenario_armies`, and in
   `army_take_leader`. `army_combine_absorb` calls `army_free_leader`. `TestArmyAppointAndFreeLeader`.
3. **The other two side palettes.** `side_bright_color` (light blue and white: the trains, the army
   report's heading, the computer's turn) and `side_panel_color` (blue and gray: the player's turn,
   victory, surrender), in `game\colors.bm`. They replace 7 places that wrote the numbers.
4. **The ship letters.** `SHIP_WOODEN$` and `SHIP_IRONCLAD$` (`cws.bi`), `ship_cost` (`rules\navy.bm`)
   and `ship_icon` (`draw\ships.bm`). The tests keep the letters as data. `TestShipKinds`.
5. **The fleet is gone.** `navy_clear_fleet` (`rules\navy.bm`) clears the ships, their count and the
   port, for `navy_remove_ship`, `navy_fleet_lost`, `navy_fleet_defeated` and `ai_fleet_orders`. No
   place left the count and the list disagreeing. `navy_cancel_new_fleet` keeps `fleet_city()` on
   purpose: `ai_fleet_orders` sets city 30 for the computer's first Union ship before it is built, and
   `ai_raise_forces` reads it after. `TestNavyClearFleet`.
6. **The flag's place beside a city.** `flag_x`, `flag_y`, `draw_erase_flag`, `flag_picture_save` and
   `flag_picture_restore` (`draw\icons.bm`) replace six places that worked it out. Two were in
   `commands\` (`army_recruit`, `railroad_arrive`), which no longer draw pixels themselves.

### The third review: the size of files and procedures

Written 2026-11-14. It asked whether procedures should be broken up or filed elsewhere. Of 388
procedures, 276 are 25 lines or fewer and 11 are over 100. The user took its order ("do file
splits", then "continue", 2026-11-14). Every step is done or dropped.

#### Done, keeping every screen

1. **Three files split by topic** (`tools\refactor\split_files.py`, commit `1f3e52a`). `ai\ai.bm`
   became `ai\army.bm`, `ai\forces.bm`, `ai\navy.bm` and `ai\railroad.bm`. `ui\orders.bm` keeps
   only `menu_commands`; its other menus went to `ui\army.bm`, `ui\navy.bm` and the new
   `ui\city.bm` and `ui\railroad.bm`. The events file's reader left `port\files.bm` for
   `port\events_file.bm`. All 388 procedures moved byte for byte.
2. **`ai_evaluate_move` in parts** (`ai\army.bm`, 209 lines to 92). `ai_stay_weight`,
   `ai_move_strength`, `ai_city_targeted`, `ai_attack_score` and `ai_beyond_score` are called
   where their lines were, so the four `RND` draws keep their order. The unused `score = 1` in the
   loop that summed the strength went. Found on the way: the bonus for the enemy's capital
   compares an owner with a city (`TODO.md`, "The game").
3. **`ai_railroad` in two** (`ai\railroad.bm`): `ai_railroad_army` picks the army and
   `ai_railroad_city` the city.

Six unit tests are new: `TestAiStayWeight`, `TestAiMoveStrength`, `TestAiCityTargeted`,
`TestAiAttackScore`, `TestAiBeyondScore` and `TestAiRailroadArmyAndCity`.

4. **`menu_select` in parts** (`ui\menu.bm`, 145 lines to 93). `menu_place` puts the box,
   `menu_start_row` works out the first row, `menu_wait_key$` waits for a key,
   `menu_letter_row` finds the row of a letter, and `menu_show_selected` and `menu_show_plain`
   draw a row highlighted and plain. A test `IF menu_width = 0` that was always true went.
   `TestMenuStartRow`, `TestMenuLetterRow` and `TestMenuPlace` are new.
5. **`calculate_battle` in parts** (`ui\battle.bm`, 179 lines to 33). `draw_battle_attacker`
   and `draw_battle_defender` draw the two halves of the panel, `draw_battle_odds` the odds,
   `draw_battle_fort` the fort, `draw_battle_winner` the winner and `draw_battle_losses` the
   losses; `battle_cannon_sound` plays the rounds. `battle_history_line$` builds the history's
   line in locals, so `menu_text$(1)` to `(4)` are no longer its scratch strings.
   `TestBattleOddsText` and `TestBattleHistoryLine` are new.
6. **`menu_city_select`'s three loops in one FUNCTION** (`ui\city.bm`, nesting 6 deep to 2).
   `side_city_step` (`rules\city.bm`) steps to the side's next city either way, within a number
   of steps. `side_city_by_letter` uses it for a letter, with the original's limit of 38 steps,
   so the city just before the first with that letter is still never reached (`TODO.md`, "The
   game"). Up and down used to loop forever if the side held no city; they now give city 0,
   shown with no name. `TestSideCityStepWrapsBothWays` and `TestSideCityByLetter` are new.
7. **`load_events`' checks at the end** (`port\events_file.bm`, 123 lines to 101).
   `event_row_problem$` checks one event and looks up its "instead" and "then" names;
   `event_general_problem$` checks that `[events]` has its banner and chance lines. Each gives
   the last check that fails, as before. `TestEventRowProblemGivesTheLast` and
   `TestEventGeneralProblem` are new. The reading loop stays as it is: its branches share the
   state of the section being read.
8. **The fort command** (`commands\city.bm`). `city_fortify` builds the fort and shows it,
   for the player's Fortify and for `ai_fortify`; `draw_fort_built` is gone into it. `ai\`
   now calls nothing in `ui\` but `ui\ai.bm`, so `tests\test_layers.py` has no exception left.
   `ai_fortify` sets the army busy before the fort is built rather than after; building a fort
   does not read the army's order.
Dropped (user, 2026-11-14): **the computer's enemy as a parameter.** `ai_evaluate_move`,
`ai_railroad_city`, `city_nearby_enemy_strength`, `ai_raise_forces` and `ai_fleet_orders` read
the enemy from `current_side`. The computer's side is always `other_side(current_side)`
(`ai_turn`, `ui\turn.bm`), so taking it from `side` would change nothing in play. The change
was built and reverted: it put a new parameter on all 10 calls of
`city_nearby_enemy_strength` for no need the game has today.

Left alone: `battle_strengths` (see the second review's deferred items), `menu_utility`,
`report_armies` and `end_game`, which are long but read top to bottom, and the four pictures
drawn line by line (`draw_map`, `draw_schooner`, `draw_ironclad`, `draw_surrender`).

### Left as they are, from the second review

The user accepted the pragmatic engineer's plan on 2026-11-13. It left these two out:

- **The two halves of `battle_strengths`** share three steps. It is one SUB read top to bottom, in the
  order of the right panel; helpers would make one battle harder to follow and risk its rounding.
- **The sea ports of a side** (`navy_list_shipyards`, `event_delivery_port`, `navy_retreat_port`): their
  tests differ in three ways, so one FUNCTION would need a parameter for each.

### The small repeats

Done 2026-11-14, when the review closed (user: "yes" to doing them rather than waiting for each
SUB's next change). The 198 unit tests passed. The 41 scripts passed `check` and `compare` on
unchanged recordings, and `coverage` shows every new procedure run.

- **The menus' lists.** `menu_add_row (text$, value)` (`ui\menu.bm`) adds a row and its value. It
  replaces the same three lines in 8 places in `ui\army.bm` and 1 in `ui\city.bm`.
- **Shortening a name.** `menu_short_name$` (`ui\menu.bm`) cuts a name to 11 characters, for the
  Relieve menu's armies and leaders and the Supply menu. Each had a length test that `LEFT$` makes
  needless, as did `menu_mark_row`'s. `menu_army_cancel` keeps its own way: it drops the first
  name of a long one, and its search for the army picked depends on that text.
- **The two-row menus.** `menu_set_two (heading$, first$, second$)` (`ui\menu.bm`) replaces four
  lines in Raze, Quit, End Turn, the ship's Type, the fleets' Options, and the two menus at the end
  of a game. `navy_combat_auto` (`commands\navy.bm`) still sets the Options texts, though the
  computer's fight shows no menu.
- **The `"00"` texts.** `troops_text$ (hundreds)` (`ui\reports.bm`) gives a number of troops from the
  hundreds the game keeps. It replaces 11 texts in 7 lines, among them `menu_mark_row`'s "Size",
  which printed the number and then stepped back over its trailing space.
- **The cannon's sound.** `cannon_shot (gap!)` (`ui\battle.bm`) plays the two notes for a battle's
  round, a fleet's volley and a shore battery's shot, and waits `gap!` seconds after.
- **The road loops' three ways of stopping** were not changed. A loop over `city_road()` ends at
  the first 0 (`EXIT FOR`), skips a 0 (`_CONTINUE`), or tests each road for more than 0. They agree
  only while a city's roads have no 0 before the last road. The shipped `CITIES.GRD` files have
  none, and `city_fix_return_routes` fills the first 0. One form would change how a hand-made
  scenario with a gap plays, so it is a row in `TODO.md`, "The code".

### Questions for the user

2. **The kept bugs:** rule on `TODO.md`'s "The game" rows in one batch now, or leave them until after
   this work? The merge of the player's and the computer's commands waits on that. Answered 2026-11-13
   (user): now. All but three are fixed (`TODO.md`, "The game").

## Done: panel review of the code, 2026-11-14

Was `docs\archived\panel-review-completed.md`.

The findings of [../panel-review.md](../panel-review.md) that are done, under the same headings.

### Biggest opportunities

2. **Merge it and make CI real.** The branch is 95 commits ahead of `qb64rust`, and `main` is
   still the 2024 port.
   - [build.yml](../../.github/workflows/build.yml) has never run and will fail: it copies
     `docs\README.1ST` and `docs\WRHGAMES.DOC`, and neither is on this branch.
   - No CI job runs the 198 unit tests, the Python tests or the 40 scripts.

   Done in part: the port reached `main` on 2026-11-14, and `55e608e` fixed the copied
   documents and added the three test steps.

   Then the scripts failed in CI. On `main` at `55e608e` (2026-11-14), the build, the Python
   tests and the unit tests passed, but all 41 scripts stopped before the title menu: the
   game never reached a prompt on the Windows runner. The most likely cause was the first
   sound statement on a runner with no sound device. `039e402` moved the scripts to a Linux
   job, under Xvfb with ALSA's null sound device, as QB64Rust's CI runs its window programs.

   Done 2026-11-15: the merge of pull request 27 (`69e0cec`) ran both jobs, and all 41
   scripts passed on Linux.
3. **Make the BASIC copy the only path for the history file.** `script_shell`
   (`port\script.bm`) already copies in BASIC under every script. Dropping
   the real `SHELL "copy ..."` removes an untested path, the console window a player sees, and
   the Windows-only half of `TODO.md`'s Linux item. What is left for Linux is file-name case.

   Done 2026-11-14, in the staged set (not committed when this was written): `history_start`
   (`io\files.bm`) renames `cws.his` to `oldhist.ory` with `NAME` in all play, and the source
   has no `SHELL` left. The file-name case was fixed with it ([devnotes.md](../devnotes.md),
   "Linux file access and history backups").
4. **One batch ruling on the computer's inherited typos.** `TODO.md` has three: the fort of 2
   counted as none, `ai_fortify`'s local `side_cash`, and `ai_beyond_score`'s owner compared with a
   city. A fourth, `ai_army_order`'s test of `j = 0`, changed no play and was fixed on
   2026-11-15. A fifth is in `ai_attack_score`: the army's leader rating is added and
   subtracted, so it cancels. The original has the same line (`CWSTRAT2.BAS` line 364). One
   batch means one re-record.

   Done 2026-11-15: the user ruled to fix all four, and they were fixed in one batch
   ([rule-changes.md](../rule-changes.md), G25 to G28).

### Records that are wrong now

- **[rule-changes.md](../rule-changes.md) and [devnotes.md](../devnotes.md)** mark G23 and U12 to U14 "Uncommitted" and R1 to R3
  "staged". The changes are committed: the working tree holds only three document edits.
- **[README.md](../../README.md) and [devnotes.md](../devnotes.md)** still say the source changes "as
  little as possible" and that no variable is renamed.

  Done 2026-11-15: G23, U12 to U14 and R1 to R3 name `db5deb2`, which holds them. G24 and the
  Linux file-name note stay "uncommitted", because they are in the staged set. The README's
  sentence went with the staged set; `devnotes.md` now says the code was modernized, and that
  the port is on `main`.

- **[file-layout.md](../file-layout.md)** misses 23 procedures (`wait_key`, `menu_scenario` and
  the `report_` SUBs among them) and lists five that are gone (`army_combine`,
  `draw_fort_built`, `event_riot`, `file_management`, `railroad_move`). Generate its tables, or
  cut it to the folder rules.

  Done 2026-11-14: cut to the folder rules and one line per file. The old tables are in
  [file-layout-completed.md](#done-where-each-sub-goes-phase-6).

### Decisions for the user

3. Fix the four computer typos left in one batch?

   Answered 2026-11-15 (user): yes. Fixed as G25 to G28.

### The panel

- **QB64 engineer:** drop the `SHELL` and settle file-name case, which is cheap. Done
  2026-11-14 (item 3 above).
- **Test engineer:** CI is the gap, not coverage. Done 2026-11-15 (item 2 above).

## Done: the code review of 2026-11-16

Was `docs\archived\code-review-completed.md`.

The findings of the code review of 2026-11-16 that are fixed, and its list of what to fix first.
The open findings, its groups 3 and 4, moved to `TODO.md` on 2026-11-16: the inherited bugs to
"The game", the code smells to "The code".

The review read the whole codebase as it stood in the working tree on 2026-11-16, with the tuning
knobs staged. The game's BASIC source was read in full except the drawing files (`draw\`,
`game\`), which were only skimmed. Also read: `tests\autoplay.py`, `tests\test_autoplay.py`,
`tests\test_tuning.py` and `tools\tuning\make_knobs.py`. Neither the game nor the tests were run.
An "inherited" finding was checked against `CWSTRAT.BAS` and `CWSTRAT2.BAS` on the branch
`canonical-source`. Its four groups were bugs in the tuning knobs, state that goes stale after
Load or New Game, bugs inherited from DOS that `TODO.md` did not list, and code smells.

### 1. The tuning knobs: ranges that crash the game or break its arithmetic

| Knob | Value in range | What happens | Where |
|------|----------------|--------------|-------|
| `recruit_cities_offered` | 5 | With Balance below Even, `offer_count` is 6. `army_recruit_cities` then writes `turn_recruit_city(6)`, but the array is `turn_recruit_city(5)`: subscript out of range. Cap the range at 4, or size the array from the knob. | [rules/army.bm](../../rules/army.bm) `army_recruit_cities`; [cws.bi](../../cws.bi) line 242 |
| `defender_wins_loss`, `attacker_wins_loss`, `large_army_loss`, `huge_army_loss` | e.g. 10 | `battle_losses` takes `SQR(variance)` with `variance = mean * (1 - loss_rate!)`. A loss rate above 1 makes it negative, and `SQR` stops the program. With the shipped losses (attack 11, defend 9), `defender_wins_loss` = 10 gives the attacker a rate of 1.1. | [rules/battle.bm](../../rules/battle.bm) `battle_losses`, `normal_random_number` |
| `fort_defender_loss` | above .045 | The defender's loss rate goes below 0 behind a fort of 2. The mean and the variance are then negative: the same `SQR` error. | same |
| `invade_ships_least` | 1 | `navy_land_army` removes the ship first. With one ship that clears the fleet, so `fleet_city` is 0, and the new army is raised in city 0. Make the least 2, or read the city before the ship is removed. | [commands/navy.bm](../../commands/navy.bm) `navy_land_army` |
| `union_bonus_per_balance`, `union_bonus_realism_share` | 2000, 10 | 2000 × Balance 5 × 10 = 100,000 overflows `union_income_bonus`. | [rules/setup.bm](../../rules/setup.bm) `set_union_advantage` |
| `capital_income`, `union_bonus_per_balance` | 5000, 2000 | A treasury of 19,999 plus an income of about 15,000 wraps in `turn_collect_income`. Next month the negative cash is set to 0. | [rules/turn.bm](../../rules/turn.bm) `turn_collect_income` |
| `points_kept` | 1 | Victory points never decay, so they grow every month until they overflow. | [rules/turn.bm](../../rules/turn.bm) `turn_update_victory_points` |
| `points_per_income` | 10 | At the default `points_kept` of .8 the points settle near 30,000 or above, at the edge of an INTEGER. | same |

- **`max_army_size` is described wrongly.** Its text says "the most troops an army can hold". It
  only limits Join (`army_combine_add`). Recruiting and the events add troops without a cap.

The `check` lines of `knobs.txt` could cover some of these, for example
`fort_defender_loss * MAX_FORT < .01 * rule_defend_loss`. The loss rates depend on the scenario's
`CWS.INI`, though, so the surest fix is to clamp `loss_rate!` to between 0 and 1 in
`battle_losses`.

### 2. Port regressions: state that Load and New Game leave behind

These two turned out to be in DOS too, not port regressions. DOS's Files, New Game stays in the
same process (`GOTO newgame`, `CWSTRAT.BAS` line 693) and resets only `rflag`. Its Load resets
`rflag`, `mflag` and `nflag` (line 686), but not `commerce` or `raider`. The fixes are rule
changes G30 and G31 in `docs\rule-changes.md`.

- **The raiding state.** `raiding_side`, `raid_loss` and `fleet_pursuit` are not in the save
  file, and `game_reset` does not clear them.
  - A load in the same session keeps the old game's raider.
  - After New Game, in the first month, `turn_collect_income` still takes the old `raid_loss`
    off a side. `navy_raid_round` raids with the new scenario's fleet, which is in port.
- **The month's command flags after Files, New Game.** `game_reset` does not call
  `turn_reset_commands`. A player who used Ships, or ran out of armies to move, and then starts a
  new game finds Ships or Moves shown as "-" in its first month. `cws.bas` lets Ships open only
  when `turn_navy_done` is 0.

### 3. Inherited bugs that `TODO.md` does not list

- **A fleet saved at sea does not raid after a Load** (`load_game`). The raid is not saved, and
  `navy_note_raiding_side` runs only after a fleet moves (`navy_finish_move`). DOS's `filer` does
  not set `commerce` either. So a fleet at sea (`fleet_city` = 99) raids again only once some
  fleet has moved. Fixed with item 3 below (G31).

### What to fix first

These come from the new work or from the port, and none changes how a game plays at the
defaults:

1. Tighten the knob ranges: `recruit_cities_offered`, `invade_ships_least`, the loss knobs, and
   the income and points knobs.
2. Clamp `loss_rate!` to between 0 and 1 in `battle_losses`.
3. Call `navy_note_raiding_side` at the end of `load_game`.
4. Clear `raiding_side`, `raid_loss` and `fleet_pursuit` in `game_reset`, and call
   `turn_reset_commands` there.
5. Correct the description of `max_army_size` in `knobs.txt`.

#### What was built (2026-11-16, uncommitted)

1. In `tools\tuning\knobs.txt`: `recruit_cities_offered` goes to 4 at most, `invade_ships_least`
   to 2 at least, `union_bonus_per_balance` to 1000 at most, `union_bonus_realism_share` to 1 at
   most, and `points_kept` to .95 at most. A new `check` line keeps a side's settled victory
   points at 15,000 or below. Both sides' points are added in one INTEGER in `draw_top_bar`. At
   the defaults the bound works out to 2,760. With the new ranges, a treasury of 19,999 plus the
   largest income (5,000 + 5 × 1,000 + 590 of cities) stays below 32,767, so the cash needs no
   check. The loss knobs keep their ranges: item 2 makes every value safe.
2. `battle_rate_bounded!` in `rules\battle.bm` keeps both loss rates of `battle_losses` between
   0 and 1. Tests: `TestBattleRateBounded`, `TestBattleLossesWithARateAboveOne`.
3. As written, and `load_game` also clears `raiding_side`, `raid_loss` and `fleet_pursuit`
   before it calls `navy_note_raiding_side`. DOS's load (`filer` in `CWSTRAT.BAS`) does not set
   `commerce`, so this is rule change G31, ruled by the user on 2026-11-16. A fleet saved at
   sea now raids from the first month after the load. `events-union` was recorded again: the
   Union fleet saved at sea shows the raider's banner from its first checkpoint. Test:
   `TestLoadGameClearsTheRaid`.
4. As written; rule change G30, ruled by the user on 2026-11-16. Tests: `TestGameReset`,
   `TestNewGameTakesNoRaidFromIncome`.
5. The text now says that the knob limits Join only.

Checked: `tests\rules_test.bas` 221 passed; the Python tests 49 passed;
`python tests\play.py check` 41 of 41 scripts passed, with `events-union` recorded again.

### The second round (2026-11-16)

#### The knob `max_army_size`

| Knob | Value in range | What happens | Where |
|------|----------------|--------------|-------|
| `max_army_size` | 16000 | Three armies of 16,000 overflow the INTEGER sums of `victory_forces` and `side_troops`. | [rules/victory.bm](../../rules/victory.bm), [rules/army.bm](../../rules/army.bm) |

**What was built (uncommitted).** The knob's most is now 1600, not 16000, in
`tools\tuning\knobs.txt`, and `make_knobs.py` wrote `io\tuning_knobs.bm` and
`scenarios\TUNING.DAT` again. A side has 20 armies, and 20 × 1600 = 32,000. Army sizes are summed
or multiplied as INTEGERs in more places than the two named above:
- `side_troops` and `victory_forces`;
- `report_armies` (`total_troops`) and `report_force_summary` (`city_troops`);
- `city_nearby_enemy_strength`: 6 roads × 1600 plus 36 cities × 160, at most 15,360;
- `3 * army_size(spare_army)` in `ai/railroad.bm`.

Making all of them LONG would have changed signatures across the computer's code. Sizes are in
hundreds, so the most is 160,000 troops; the default stays 1250. Recruiting and the events can
still take an army past it (`TODO.md`, "The game").

#### Load and New Game

Both are in DOS too. DOS sets the ratio (`aggress!`) only at the month's end and in the victory
points, and its load (`filer` case 2) does not read `cwslead.dat` again.

- **`ai_strength_ratio!`.** It carried into the first computer turn of a new or loaded game. It
  is worked out again only in `turn_date_and_supply`, after the computer has moved.
  **Built:** `game_reset` and `load_game` set it to 0, as a game from the title has. Rule change
  G32. Test: `TestNewGameAndLoadClearTheStrengthRatio`.
- **The free leaders, on loading a save of the same scenario.** `load_game` reloaded the
  scenario's leaders only when the save was of another scenario. A leader that the current game
  used up stayed gone.
  **Built:** `load_scenario_leaders`, taken out of `load_scenario`, reads `CWSLEAD.DAT`.
  `load_game` calls it for every save, before it reads the armies. Rule change G33. Test:
  `TestLoadGameFreesTheScenariosLeaders`. The load tests run in an empty folder, so
  `WriteTestLeaders` in `tests\rules_test.bas` writes the leaders file there.

Checked: `tests\rules_test.bas` 223 passed; the Python tests 49 passed;
`python tests\play.py check` 41 of 41 scripts passed, none recorded again.

## Done: the plan to run Civil War Strategy in a browser with QBJS

Was `docs\archived\qbjs-plan-completed.md`.

The completed parts of [../qbjs-plan.md](../qbjs-plan.md), moved here on 2026-11-17: steps 0 to 3a,
the autoplay check of step 4, the progress record to 2026-11-17, the effort estimate, and the
answered questions with the panel. Step 12 was moved here on 2026-11-18 and 19, as the last progress
entries. The plan keeps what is still open. "The steps file" below is
`qbjs-steps.md`, the numbered work list. Its open steps (12 to 14) were merged into the plan on
2026-11-17, and its done steps are the progress entries here.

### Step 0, done: what QBJS makes of the game today

On 2026-11-16 the game (branch `tuning-knobs` at `87c054d`) was compiled with the fork's `main` at
`1589a46`:

    node ..\qbjs\qbc.js cws.bas program.js

QBJS reads all 49 include files and writes a `program.js` of 11,998 lines. It prints 130 warnings and
errors. The output is not valid JavaScript: `node --check program.js` stops at line 1357,
`if ( ship ==  ) {`, where a constant was not found.

#### What QBJS reports

| Gap | Lines in the game | QBJS's message | Where in QBJS |
|---|---|---|---|
| `TAB(` in `PRINT` | 34 | `Missing function or array [TAB]` | `ConvertPrint`, `tools\qb2js.bas` |
| Graphics `PUT (x, y), array(), PSET` | 19 | `Invalid variable 'PSET'` | `ConvertPut` (line 1328) knows only the file form |
| Graphics `GET (x1, y1)-(x2, y2), array()` | 7 | `Syntax error` | the same `ConvertPut` |
| `OPEN "I", 1, file$` (the old form) | 15, of 18 `OPEN`s | `Syntax Error in Open statement` | `ConvertOpen` (line 1393) wants `FOR … AS` |
| A string constant named with `$`: `CONST KEY_UP$ = …` | 29 uses of 10 constants | `Variable 'KEY_UP' (STRING) not defined` | not found yet |
| `VIEW (x1, y1)-(x2, y2)` and `VIEW` | 9 | `Missing or unsupported method: 'VIEW'` | no such statement |
| `DEF SEG`, `POKE`, `PEEK` | 7, in `script_mark_key_wait` (`io\script.bm`) | `Variable 'DEF' (SINGLE) not defined` | no DOS memory |
| `DEF SEG`, `VARSEG`, `BLOAD` | 3, in `load_picture` (`draw\pictures.bm`) | the same, and `'BLOAD'` | no DOS memory |
| `DEFINT A-Z` | 2 (`cws.bas` line 2, `cws.bi` line 1) | `'DEFINT' - ignoring line` | `DataTypeFromName` (line 4171) |
| `$RESIZE:STRETCH`, `_WINDOWSIZELIMIT` | 3 | `ignoring line` | harmless: the page scales the canvas |

The full list is `warnings.txt`. It is not kept in a repo; the command above writes it again.

#### What QBJS does not report

These compile without a message and run differently. They are the dangerous part.

- **Parameters are passed by value.** 75 of the game's 441 procedures assign to a scalar parameter. Examples:
  `battle_fight` (loser, rounds, winner), `turn_attack` (fought, took), `menu_railroad` (army, city).
  The caller never sees the result. In QBJS a call's arguments are plain JavaScript values
  (`ConvertMethodParams`, line 2718).
- **`DEFINT A-Z` is ignored, so most names become `SINGLE`.** A name with no suffix and no `AS` is a
  `SINGLE` in QBJS. In the game that is 550 of 617 parameters, 78 of 99 functions and 234 of 1,004
  `DIM` names. A value assigned to them is no longer rounded to a whole number.
- **Rounding.** QBJS rounds an assignment to an integer with `Math.round` (lines 959 and 2901), which
  takes 2.5 to 3. QB and QB64 round halves to the even number, which gives 2. The game divides
  integers in most of its rules.
- **`ENVIRON$` always returns `""`** (`qb.js` line 2009). The game's test hooks (`CWS_SEED`,
  `CWS_AUTOPLAY`, `io\script.bm`) are never switched on.

#### What is not a problem

- The game has no `GOTO`, `GOSUB`, `ON ERROR`, `FIELD`, `STRING * n`, `PCOPY`, `PALETTE` or `SHELL`.
  QBJS's largest gaps do not touch it.
- Every other keyword the game uses is known to QBJS's compiler. That shows the word is accepted. It
  does not show that it behaves as in QB64: `PAINT`, `DRAW`, `PLAY`, `CIRCLE` and the `LINE` style
  patterns (`&HF0F0`) are only checked by running the game (step 4).
- `RND` in QBJS uses QB's formula (`qb.js` line 3674). With the same seed it gives the same numbers
  as the native build. Step 1 rests on this.

### Step 1: a way to check the result

Without this, mistakes are found only by playing. It comes first.

- **The check: an autoplayed game ends the same way.** With `CWS_SEED` and `CWS_AUTOPLAY=1` the
  computer plays both sides and `script_autoplay_end` writes one line to `autoplay.txt`: the winner,
  the rule that ended the game, the month and year, and each side's points and cities
  (`tests\autoplay.py`). The native build gives the expected line for each seed. A game of several
  hundred turns that ends on the same line shows that parameters, integer types and rounding all
  work. Screens cannot be compared: the recorded screens are digests of pixels, and QBJS draws text
  and circles its own way.
- **A harness.** A script starts a local server for the built folder, opens it in a headless browser
  (Chrome and Edge are installed), sets the three variables, waits for the end and reads
  `autoplay.txt` from QBJS's file system. It supplies `ENVIRON$` by replacing `QB.func_Environ` in
  the page, so QBJS itself needs no change for it. It needs one package from npm to drive the browser
  (`puppeteer-core` or Playwright), which the user allowed on 2026-11-16.
- **Small programs for each change**, in QBJS's own tests (`..\qbjs\test\qb-lang.bas` and its
  neighbors, which use `lib\test\unit-test.bas`). These go upstream with each change.

The harness is a tool of this port. It lives in this repo's `tests\`.

### Step 2: the language, in QBJS

Each item is its own branch of the fork, so that each can be one pull request.

1. **`DEFINT` and the other `DEF` statements** (`DEFLNG`, `DEFSNG`, `DEFDBL`, `DEFSTR`). A table from
   first letter to type, read by `DataTypeFromName`. It changes only programs that use the statements.
2. **Round halves to even** in assignment to an integer, on entry to a procedure, in `CINT` and in the
   operands of `\` and `MOD`. It is a setting, with QBJS's rounding of today as the default (user, 2026-11-16).
3. **Parameters by reference, as an option that is off by default** (user, 2026-11-16: "more likely to
   be accepted upstream"). Two ways to switch it on: an option of the compiler (`node qbc.js -byref`),
   and a metacommand inside `$IF WEB THEN`, which QB64pe and QB64Rust skip. Not a keyword on each
   parameter: QB64pe would refuse it. An argument in its own parentheses, `CALL f((x))`, stays a copy.
   It works by copy in, copy out (below).
4. **A string constant named with `$`.** Find why `CONST KEY_UP$ = …` is not found. This is a bug in
   QBJS, with no option.
5. **The old form of `OPEN`**: `OPEN "I", 1, file$`, with the modes `I`, `O`, `A`, `R` and `B`.

### Step 3: the screen, in QBJS

1. **`TAB(n)` in `PRINT`**, to the screen and to a file (`PRINT #2, TAB(20); …`, `io\files.bm` line 394).
2. **Graphics `GET` and `PUT`.** The game saves what is under a menu or a marker and puts it back
   with `PSET`. Telling the graphics form from the file form is by the opening parenthesis.
3. **`VIEW`**: the graphics viewport, with clipping and coordinates relative to its corner, and
   `VIEW` alone to end it. The game uses only these two forms.
4. **`DEF SEG`, `PEEK` and `POKE`** on a small memory of bytes. The game needs 3 bytes (`&H4F0` to
   `&H4F2`). With them the harness can see when the game waits for a key, as the native test runner
   does, and the 82 key scripts of `tests\scripts` become usable.

### Step 3a: the pictures, in the game

Turn the ten `.vga` files into PNG files with the same pixels, and make `load_picture` load them
with `_LOADIMAGE(file$, 256)`. The `PUT`s of pictures become `_PUTIMAGE`. `draw_title` takes the
capital's star out of the icon with `GET`, which stays. Both QB64pe and QB64Rust must build it, and
`play.py check` must pass with no screen recorded again. If a screen differs, the change stops there
and the question comes back to the user. `DEF SEG`, `VARSEG` and `BLOAD` then leave the game.

**Done 2026-11-16**, on the branch `qbjs-web`. `tools\vga_to_png.py` wrote the ten `.PNG` files and
read each back against its `.VGA` file. All 41 scripts pass with no screen recorded again, on the
QB64Rust build (`play.py check`) and on the QB64pe build (`play.py compare`). The 223 unit tests pass.
The `.VGA` files and the converter stay for now; the files can go when the user says so.
`DEF SEG` is still in `io\script.bm`, for the test hook.

### Step 4: the autoplay check

- Run the autoplay check on seeds 1 to 100. Find and fix each difference.

### Progress

**2026-11-16.** The game repo's branch is `qbjs-web`; the fork's is `fix/const-string-suffix`
(the name is narrower than its content now; rename it before a pull request). Nothing is staged or
committed by Claude.

Done:
- **Step 3a**, the PNG pictures (above).
- **The harness of step 1, without the autoplay part.** `tests\web\run_qbjs.js` builds a program with
  QBJS, assembles the page from `export\dependencies.txt`, serves it, runs it in headless Chrome
  (`puppeteer-core`, installed in `tests\web\`, not committed) and reports the build's warnings, the
  page's errors, a screenshot and any JavaScript value asked for. `--env NAME=VALUE` replaces
  `ENVIRON$`. It needs the autoplay run and the game's data files in QBJS's file system (step 4).
- **In the fork, four fixes and a feature**, each with a test in `test\qb-lang.bas` or
  `test\qb-file.bas`. QBJS's compiler is built from `tools\qb2js.bas` into `qb2js.js` by
  `node qbc.js tools/qb2js.bas qb2js.js`; a rebuild without changes gives the committed file, byte for
  byte, so the rebuilt `qb2js.js` belongs in each change.
  1. `CONST NAME$ = …` (a constant with a type suffix) was never found again. 29 uses in the game.
  2. `CIRCLE (x, y), r, c, , , aspect` wrote invalid JavaScript for the skipped arguments, so the
     game's program did not even parse. Found by `node --check`, not by QBJS's own messages.
  3. `OPEN "I", 1, file$` in the original form, and `OPEN file$ FOR … AS #n`, where the file name was
     copied as text and a string variable was undefined (QBJS names `f$` `f`).
  4. `Line Input #` moved by `length + 1`, so after the first line of a file with CRLF endings, which
     is what QBJS's own `Print #` writes, every second line read as empty.
  5. `TAB(n)` and `SPC(n)` in `PRINT`, on the screen and to a file.

The game's build now has 34 fewer errors. What is left (`node qbc.js cws.bas`): `VIEW` 9, graphics
`GET`/`PUT` 15, `DEF SEG` and `POKE` 4, `DEFINT` 2, and the harmless `$RESIZE` lines. Its JavaScript
parses except for the `DEF SEG` line.

**2026-11-16, step 1 done** (fork branch `feature/def-seg-peek-poke`, uncommitted). `DEF SEG [= n]`,
`PEEK` and `POKE` work on a small byte memory in `qb.js` (empty at the start, values `AND 255`, no DOS
memory map). `DEF SEG = n` needed an exception in the assignment check, as `_Clipboard$ =` has. A test
is in `test\qb-lang.bas`. The game's build has no `DEF`/`SEG`/`POKE` message and `node --check` passes.

**2026-11-16, first run of the game.** The page loads and runs into `game_new`. Two findings:
- **Fixed** (fork branch `fix/string-array-suffix`, uncommitted): `DIM a$(10)` made a `SINGLE` array,
  because the type was read from the whole `a$(10)`. Every string array of the game was numeric, so
  `INPUT #` of `SCENARIOS.LST` gave a number for the folder name and `scenarios/NaN/CWSLEAD.DAT` was
  not found. Test in `test\qb-lang.bas`.
- **Open** (step 2 of the steps file): `INPUT #` reads a whole line, not fields, so `load_scenario`
  stops at `CWS.INI` with "Input past end of file".

**2026-11-16, `INPUT #` and `NOT`.** Both fixed on fork branch `fix/input-file-fields`, uncommitted.
- `sub_InputFromFile` (`qb.js`) now reads one field per variable from a file position, as QB does.
  This also settles step 8's first item. Tests in `test\qb-file.bas`.
- `NOT (a > b)` compiled to `~(a > b)`; `~` of a JavaScript boolean is -2 or -1, both true, so every
  `IF NOT (comparison)` took its branch (it stopped the game at its own tuning check). A group after
  `NOT` now compiles to `QB.not(...)`, which gives -1 or 0 for a boolean. Test in `test\qb-lang.bas`.
  **Not fixed:** `NOT x` without parentheses, where `x` holds a comparison's result, still uses `~`
  (and `NOT a > b` without parentheses applies `~` to `a` only).
- The main menu now shows.

**2026-11-16, past the main menu.** `run_qbjs.js` has `--keys "10:Enter,3:Enter"` (seconds to wait, then
a key) and prints the URL of each 404. The first Enter must come after about 8 seconds, or it is lost
before the menu waits for it. With four Enters a game starts and its main menu and army menus work, with
no page error. The nine 404s are the game looking for `cws1.sav` to `cws9.sav` and a scenario's own
`TUNING.DAT`; they are harmless. The map is not seen: the menus' `CLS 1` wipes the screen because
`VIEW` is not supported (steps 3 and 4 of the steps file). `_LOADIMAGE(file$, 256)` is not reached yet
(the title screen and `MTN.PNG` come after those steps).

Found, not yet fixed (for step 4, each with a small program to show it):
- `INPUT #` does not take the line ending after its last item, so the next `LINE INPUT #` reads an
  empty line. QB takes it.
- `INPUT #1, n` of `3.5` into an integer gave 3. QB gives 4 (halves go to even).
- `OPEN expression FOR …` with spaces in the expression, as `OPEN dir$ + "a" FOR INPUT AS #1`, is
  still "Syntax Error in Open statement".
- `ENVIRON$` always returns `""` (the harness works around it).

**2026-11-16, step 4 (`VIEW`) done** (fork branch `feature/view`, uncommitted, made from
`fix/input-file-fields` at `d7f6667`). `VIEW [SCREEN] (x1, y1)-(x2, y2) [, fill [, border]]` sets a
graphics view port and `VIEW` alone ends it. `CLS 1` and a bare `CLS` clear only the view port while
one is set; `CLS 0` and `CLS 2` clear the whole screen. The fill and the border (drawn just outside the
box, as QB does) are done. Drawing statements are not moved to the port's corner or clipped to it: the
first `LINE`, `CIRCLE`, `PAINT`, `PSET` or `PRESET` while a port is set logs one `console.warn`. The
game never draws inside a port. Tests are in `test\qb-graphics.bas` (run here with a copy that has its
own assert sub, since the harness cannot build QBJS's `Import` tests); the game's build has no
`VIEW`/`CLS` message and `node --check` passes. `qb2js.js` was rebuilt twice with identical results and
its diff is only the new code. The cursor is not homed by `CLS 1` inside a port (unchecked against QB).

**2026-11-16, step 3 (graphics `GET` and `PUT`) done** (fork branch `feature/graphics-get-put`, uncommitted,
made from `feature/view` at `27ef032`). `ConvertPut` hands a first argument that starts with `(`,
`STEP(` or `STEP (` to `ConvertGraphicsGetPut`; the file forms are unchanged. `GET` keeps the rectangle's
`ImageData` on the array object (`a._image`), so a program cannot read the array's elements. `PUT` with
`PSET` draws it back; `PRESET`, `AND`, `OR` and `XOR` (the default, as in QB) combine red, green and blue
pixel by pixel, which matches QB only where the palette numbers' bits line up. Tests are in
`test\qb-graphics.bas` (run with the same stand-in assert sub as step 4). The game's build now has only
the `DEFINT`, `$RESIZE`, `STRETCH` and `_WINDOWSIZELIMIT` messages, and `node --check` passes. A run to
the army menu shows the flags and markers with no page error. One oddity in that run, not yet looked at:
a red number `73755788803` at the left edge of the map under "JEFF. CITY" (likely step 5, `DEFINT`).

**2026-11-16, step 5 (`DEFINT` and the other `DEF` statements) done** (fork branch `feature/deftype`,
uncommitted, made from `feature/graphics-get-put` at `8a7906b`). `DEFINT`, `DEFLNG`, `DEFSNG`, `DEFDBL`,
`DEFSTR` and `_DEFINE A-Z AS type` (ranges such as `A-Z`, `I-K, M`) are recorded by `FindMethods` in four
parallel arrays (`defLine`, `defFirst`, `defLast`, `defType`). `DataTypeFromName` asks `DefaultDataType`,
which finds the last entry that covers the name's first letter and starts at or before `defCurLine`.
`defCurLine` is set per line in `FindMethods` and `ConvertLines`, and per method in `ConvertMethods`, so a
`DEF` applies to the lines and procedures after it, as in QB. It is 0 while the built-in methods are
registered, so `DEFINT` never changes a built-in's type. The statement itself makes no JavaScript, and
the "Missing or unsupported method" warning is gone. Tests are in `test\qb-lang.bas` (a section at the
end, with a `DEFSNG A-Z` before the last function). In the game, the stray red number is gone and Funds
shows `525` instead of `525.27`, as `INTEGER` does. The game's build now has only the `$RESIZE`,
`STRETCH` and `_WINDOWSIZELIMIT` messages. Notes for the pull request:
- A name keeps the type it got at first use, as in QB, so a later `DEF` does not retype a variable that
  already exists.
- An exported function from a library gets its return type from its name alone, so a `DEF` in the
  library is not carried through `EXPORT` (not tested).
- Rounding stays `Math.round` (2.5 gives 3, QB gives 2); that is step 6.
- `qb2js.js` was rebuilt twice with identical results. Its diff also renames some generated loop
  variables (`___v…`) in code that did not change: they come from a seeded counter that the new `For`
  loops shift.

**2026-11-16, step 6 (rounding to even, as a setting) done** (fork branch `feature/round-half-even`,
uncommitted, made from `feature/deftype` at `d6b0bd6`). Off by default; QBJS's `Math.round` stays.
- **The switch, for step 7 to reuse:** a metacommand `$ROUNDING EVEN` (or `$ROUNDING UP` to turn it off
  again), which the compiler turns into `QB.setRoundHalfEven(true)`; and a compiler option,
  `qbc.setRoundHalfEven()` in `qb2js.js` (`optionRoundHalfEven`), which `qbc.js` takes as
  `--round-half-even` after the file names and which puts the same call after `QB.start()`. The
  metacommand has no colon because the line splitter would cut `$ROUNDING:EVEN` into two statements.
  A program that also builds in QB64pe puts it inside `$IF WEB THEN … $END IF`. The name is for the
  upstream issue to settle.
- **The one function:** `QB.roundInt` in `qb.js`. The compiler now writes it where it wrote
  `Math.round(` for an assignment to an integer variable (also a function's result and an array
  element) and for an integer parameter on entry. With the setting on, a half goes to the even number
  (2.5 to 2, 3.5 to 4, -2.5 to -2, -3.5 to -4). `QB.toInteger`, which `INPUT` and `INPUT #` use, cut
  off the fraction (`3.5` gave 3); with the setting on it rounds like QB (4). With it off it is as before.
- **Already QB's, no change:** `CINT`, `CLNG`, `_ROUND` and the operands of `\` (they go through
  `func_Cint`, which already rounds a half to even).
- **Not done:** `MOD`. The compiler writes JavaScript `%` with no rounding of the operands, so
  `7.5 MOD 2` is 1.5 where QB gives 0. The game uses no `MOD`. `READ` into an integer also stores the
  DATA value unrounded.
- **Game:** no source change. Build it with `node ..\qbjs\qbc.js cws.bas <out>\program.js --round-half-even`
  (the harness `run_qbjs.js` does not pass the flag yet), or put `$ROUNDING EVEN` inside `$IF WEB THEN`
  in `cws.bas`, which needs QB64Rust and QB64pe to be checked for `$IF WEB`.
- Tests: `test\qb-lang.bas` (assignment, parameters, function results, negative numbers, on and off) and
  `test\qb-file.bas` (`INPUT #`). The language test passes in a copy with a stand-in assert sub; the
  `INPUT #` case was checked by a scratch program (3 2 6 off, 4 2 6 on), not through the QBJS suite.
- `qb2js.js` has 472 changed hunks, almost all `Math.round(` to `QB.roundInt(` in the compiler's own
  integer assignments. `qb-console.js` (the minimal runtime that runs the compiler) got a plain
  `roundInt`. Two builds in a row are identical.

**2026-11-16, step 7 (parameters by reference, copy in, copy out) done** (fork branch
`feature/byref-option`, uncommitted, made from `feature/round-half-even` at `a1205bd`). Off by default.
- **The switch:** the metacommand `$BYREF ON` (for the module it is in; `FindMethods` reads it before any
  line is converted, so its position does not matter) and the compiler option `qbc.setByRef()`, which
  `qbc.js` takes as `--byref`. The harness now has `--qbc "<flags>"` (for example
  `--qbc "--byref --round-half-even"`).
- **Caller** (`ConvertMethodParamsRef`): for a call to one of the module's own procedures, an argument
  that is a variable, an array element or a `TYPE` member, and whose parameter is a plain value, goes in
  a `QB.Ref` and is copied back after the call, in a `try … finally`. The object holding the element
  (`QB.arrayValue(arr, [i])`, or the `TYPE` variable) is taken once before the call, so `BumpIdx i, arr(i)`
  writes to the element that was chosen, as QB does. A statement call becomes a block; a `FUNCTION` call
  in an expression becomes `(await (async () => { … })())`. An expression, a constant, an argument in its
  own parentheses, a whole array (`a()`) and a function call are passed as before. Calls to library
  methods and built-ins are not changed.
- **Callee** (`ConvertMethods`): every plain-value parameter takes its value from a `QB.Ref` if it got
  one (`instanceof QB.Ref`) and is used as it was if not, so callbacks that the runtime calls with plain
  values still work. A `try { … } finally { … }` around the body copies each parameter back at every way
  out: the end, `EXIT SUB`, `EXIT FUNCTION`, and an error. Integer parameters are still rounded on entry,
  after the value is taken out. Array parameters, `TYPE` parameters (already objects, so already shared)
  and procedure parameters are left alone.
- **Tests:** `test\qb-byref.bas` (new; added to `test\qb-all-tests.bas`): a variable, an array element, a
  `TYPE` member, a string, `CALL`, parentheses, an expression and a constant, a `FUNCTION` in an
  expression, the element chosen before the call, `EXIT SUB`, `EXIT FUNCTION`, a variable first used as
  an argument. One check with the option off is in `test\qb-lang.bas`. Both pass in copies with a
  stand-in assert sub, not through the QBJS suite.
- **Game:** `node ..\qbjs\qbc.js cws.bas <out>\program.js --byref --round-half-even` builds with the
  same four messages as before (`$RESIZE`, `STRETCH` and two `_WINDOWSIZELIMIT`), `node --check` passes,
  and it has 1,301 uses of `QB.Ref` (none without the flag). The page runs to the Recruit menu with no
  page error. Whether the 75 procedures that write a parameter return the right results is for the
  autoplay check (step 9).
- **Found on the way, not fixed:** `NOT (a Or b)` and `NOT (a And b)` still compile to `QB.not(a | b)`,
  and `|` of two comparisons is the number 1, so `QB.not` gives -2, which is true. The earlier `NOT`
  fix (`QB.not`) handles a group that is one comparison, not a group that combines several. The
  compiler's own source worked around it (an `If` with a flag).
- **Also:** `qb-console.js` got `not`, because the compiler's own code uses `Not (…)` and the minimal
  runtime that runs it lacked it.
- **Limits:** a procedure called through `@name` or another module is not given Refs (the callee still
  works with plain values). `READ`, `GET #` and `SWAP` into an argument are not special.

**2026-11-16, step 8 (the small bugs) done** (fork branch `fix/open-expression`, uncommitted, made from
`feature/byref-option` at `6dbf5bb`). Of its three items, the `INPUT #` line ending was done in step 2 and
`INPUT` into an integer in step 6. The third is fixed here: `ConvertOpen` took the file name as one word
and `FOR` as the second, so `OPEN dir$ + "a" FOR INPUT AS #1` gave "Syntax Error in Open statement". It
now finds the `FOR` and the `AS` after it and converts everything before `FOR` as the file name
expression. The original form (`OPEN "I", 1, file$`) is the case with no `FOR`. A file number that is a
variable (`AS #n`) and a name in parentheses work. Test in `test\qb-file.bas` (passes in a copy with a
stand-in assert sub). The game's build is unchanged (the same four messages). `qb2js.js` was rebuilt
twice with identical results.
- **Found, not fixed:** a file number held in a variable with a type suffix, as in `Print #n%, "x"` or
  `Close #n%`, copies `n%` into the JavaScript unchanged (`QB.sub_PrintToFile(n%, …)`), which is a
  syntax error. `#n` (no suffix) works. The game's files use constants or unsuffixed names under
  `DEFINT`.

**2026-11-16, step 9 (the autoplay check) done.** `tests\web\autoplay.js` builds `cws.bas` with
`--byref --round-half-even`, and for each seed (`--seeds 1-3`) opens the page with `CWS_SEED` and
`CWS_AUTOPLAY=1` and the two-player `CWS.CFG` of `tests\autoplay.py`. It catches the game's `POKE`s of
`&H4F0` to `&H4F2` (`io\script.bm`) and answers each announced wait with the key of
`tests\autoplay.py`'s keys file. `SYSTEM` is `QB.halt(); return`, so the page just stops: the script
polls QBJS's file system for `autoplay.txt`. `--native` also runs `tests\autoplay.py` for the same
seeds and prints both lines. `run_qbjs.js` now exports its helpers.
- **Fixed on the way** (fork branch `fix/write-expression`, uncommitted, from `fix/open-expression`):
  `WRITE #n, a(i), 5, s$ + "x"` wrote the JavaScript text of each argument that is not a plain variable
  or a string literal (`QB.arrayValue(…)`). `ConvertWrite` now writes the value, and `_getWriteString`
  quotes a string value. Test in `test\qb-file.bas`.
- **Result for seed 1:** QBJS `1,2,3,1865,450,544,11,23` (time limit, March 1865, 148 s); native
  `1,cities,9,1863,848,407,32,5` (the Union wins by cities, September 1863). The games differ, so
  step 10 has its first case. The harness's own keys are a possible cause to rule out first.
- **Time:** about 150 s a seed in QBJS, so 100 seeds one after another take about four hours. Pages can
  run side by side if that is too slow.

**2026-11-16, step 10 (seeds 1 to 100) done: all 100 lines match** (fork branch `fix/integer-conversion`,
made from `fix/write-expression`, uncommitted). Two bugs showed, one after the other, in seed 1.
- **A comparison stored in an integer was 1, not -1.** `army_exists = army_city(army) > 0` gave 1, so
  `NOT army_exists(army)` was `~1`, which is -2 and true. Every computer army returned at once from
  `ai_army_order`: no army moved, so there was not one battle in the game (the history file of QBJS had
  none; the native one had 44). `QB.roundInt` now gives -1 and 0 for a boolean. Test in
  `test\qb-lang.bas`. This also makes `NOT` of such a value right, the case the "found, not fixed" note of
  step 2 named for `NOT x`.
- **QB64 rounds a value for a 16-bit integer as a single.** With the armies fixed, the games differed
  by one victory point: `0.8 * 808 + 0.3 * 507` is 798.5000000000001 as a double, and QB64 stores 798,
  not 799. QB64pe's `qb64pe.bas` converts to `float` for an integer of 16 bits or less
  (`qbr_float_to_long`) and rounds the double for a wider one; native `qb64rust` does the same (a small
  program: 798.50001 is 798 in an INTEGER, 799 in a LONG and with `CINT`). `QB.roundInt` (INTEGER, `_BYTE`,
  `_BIT`) now rounds through `Math.fround` when `$ROUNDING EVEN` or `--round-half-even` is on, and
  the compiler emits a new `QB.roundLong` for the wider types (`RoundFunction` in `qb2js.bas`). Test in
  `test\qb-lang.bas`. `qb2js.js` was rebuilt: a third build equals the second, and the diff holds only
  `roundLong` lines and the helper. Step 6 said "QB rounds half to even"; this is the rest of the rule.
- **The result.** `node tests\web\autoplay.js --seeds 1-13 …` in eight processes at once, and
  `python tests\autoplay.py --jobs 4 run … --seeds 1-100 --mode two` natively: the winner, the rule, the
  month and year, both sides' points and cities are the same in all 100 games (43 time limits, 31 by cities,
  14 by capital, 8 by force ratio, 4 by income, from the native summary). A game takes 150 to 400 s in
  QBJS with eight at once; the 100 took about 70 minutes. `node --check` of the build passes.
- **Not run:** the one-player games (`--mode one`) and the alternate map; only the two-player standard map.
  The History file of seed 1 matches line for line (`--history`).

**2026-11-17, step 11 (files across a reload) done** (fork branch `feature/persist-files`, made from
`fix/integer-conversion`, uncommitted). QBJS has no way to keep a program's files: `vfs.js` is in memory,
`localStorage` holds only the IDE's settings, and `lib/web/storage.bas` stores strings, not files. A file
that is missing is fetched from the server by `OPEN`, so after a reload the game would get the shipped
`CWS.CFG` back, not its own.
- **`QB.persistFiles(name)`** (`qb.js`) is new. A page calls it, and waits for it, before `__qbjs_run()`.
  It opens an IndexedDB database, puts the stored files and folders in the file system, and from then on
  `CLOSE` of a file that was not only read, `KILL`, `NAME`, `MKDIR` and `RMDIR` update the database. It
  returns false, and the program runs as before, when IndexedDB is not there.
- **Not changed:** the game, the compiler and the export pages. How a program asks for it is open:
  the page calling it (the game's `index.html`), or a metacommand such as `$PERSIST` in the compiler. I
  would ask upstream before choosing.
- **Check:** `node tests\web\persist.js` loads a small program three times in one browser. Load 1 prints
  NEW; loads 2 and 3 print FOUND:saved; a file the program deleted does not come back; a file in a folder
  does. A test in QBJS's own suite cannot do this, since it needs a reload.
- **Not checked:** the game itself with it on (its saves, `CWS.CFG`, the Hall of Fame). A file still open
  when the page closes is not saved.

**2026-11-17, step 12 started: the native scripts play in QBJS.** Playing by hand is mostly replaced by
`tests\web\play_qbjs.js`, which plays the keys files of `tests\scripts` in the QBJS build.
- **How:** `tests\web\play_setup.py prepare` fills the run's folder with `play.py`'s own functions, so
  the files, `CWS.CFG`, saves and seed are those of a native run. The page answers the waits the game
  announces at `&H4F0` to `&H4F2` with the steps of QB64Rust's screen-state check: `prompt`, `rule`,
  `play until`, `repeat`. A key goes in only after the program has taken the one before and reads
  again. In `INPUT`, which does not read QBJS's `INKEY$` buffer, keys come 40 ms apart. Capitals are
  typed with Shift down, because QBJS's `INKEY$` takes the character from the key's code and Shift.
- **What it checks:** every step meets the wait it expects, the program ends by `SYSTEM`, no page
  error, and each `#! files` file has the hash recorded natively. The `digest` lines cannot be
  compared, so each becomes a screenshot. `--native` runs the script in the QB64Rust build with full
  states and writes `report.html`, the two screens side by side with the share of pixels that differ.
- **Result so far:** `navy` (14 checkpoints, 13 s), `endings` (10) and `files` (26 checkpoints; the
  hashes of `cws1.sav`, `cws2.sav`, `cws.his`, `oldhist.ory` and `CWS.CFG` match) pass. In `navy` the
  numbers on screen match the native ones, but from May 1861 the map is white: the `DRAW` and `POINT`
  bugs listed in step 12 of the steps file.

**2026-11-17, the scripts in the suites VM, and two fixes.** QB64Rust's `tools\winvm\game.ps1` runs a
command of this repo in QB64Rust's suites VM (OpenSpec change `vm-game-runs` there). The first run of all
41 scripts with `--native`: 23 passed, 18 failed, for two QBJS bugs, both now fixed in the fork:
- **Array parameters** (`fix/array-param-suffix`, committed `8291f5b`): `SUB s (names$())` typed the
  array from `names$()`, so it was an INTEGER array under `DEFINT`. The Hall of Fame names were `NaN`.
- **Comparisons as -1 and 0** (`feature/qb-booleans`, uncommitted). A switch, off by default (user,
  2026-11-17): the compiler option `--qb-booleans` and the metacommand `$BOOLEANS QB`. `ConvertExpression`
  marks each stretch between logical operators or commas that holds a comparison, and the marks become
  `QB.toBoolean(...)` after `ConvertIntDiv`; a comparison that a `CASE IS` clause starts with is not
  marked. Tests in `test\qb-booleans.bas` (new) and one with the switch off in `test\qb-lang.bas`; QBJS's
  suite passes 12 of 12; a third build of `qb2js.js` equals the second. The game's 1,088 comparisons are
  wrapped, and the harness (`autoplay.js`, `play_qbjs.js`, `serve.js`) now builds with the switch.
- `play.py` puts Mesa's OpenGL DLLs beside the program when `QB64RUST_OPENGL_DIR` is set, so the native
  runs work in the VM. `autoplay.js` has `--jobs` and `--expect <native results>`.
- **With both fixes, in the VM:** all 41 scripts pass (`play_qbjs.js --native --jobs 4`), and autoplay
  seeds 1 to 100 all match `tests\out\web\native-1-100.json` (six at once, 25 to 95 s a seed). The first
  autoplay run stopped after seed 36, all matching, when a page took over puppeteer's 30 s to load; the
  harness now waits two minutes and counts such an error against its seed only, and seeds 37 to 100 ran
  again.

**2026-11-17, the open findings: `MOD`, `READ`, file numbers, `INPUT` and `VIEW`.** Three fork branches,
each made from `feature/qb-booleans` at `e2062fc` in its own worktree (`..\qbjs-wt\mod-read`,
`file-number`, `view`), all uncommitted. In each, QBJS's suite passes 12 of 12. QBJS's results were
checked against a small program built with `qb64pe.exe` (in QB64Rust's `target\scratch\2026-11-17\`,
not kept); `qb64rust` gives the same output, line for line.
- **`fix/mod-read-rounding`.** `MOD` compiles to `QB.mod(a, b)`. `ConvertMod` finds each operand by
  QB's precedence, so `10 MOD 3 * 2` is 4 (it was 2) and `2 + 7 MOD 4` is 5. With `$ROUNDING EVEN`,
  `QB.mod` rounds both operands first: `7.5 MOD 2` is 0 and `6.5 MOD 4` is 2, as in QB64pe. Without the
  setting, `7.5 MOD 2` stays 1.5. `READ` into an integer now rounds the value (`QB.roundLong`). QB64pe
  rounds the double it reads, so `798.5000000000001` read into an INTEGER or a LONG is 799, where an
  assignment to an INTEGER gives 798. A variable first used in `READ` gets its type before the conversion.
- **`fix/file-number-input`.** `ConvertFileNumber` takes off only the `#` in front of a file number and
  converts the rest. So `#n%` and `#d#` work in `OPEN`, `CLOSE`, `PRINT #`, `WRITE #`, `INPUT #`,
  `LINE INPUT #`, `GET #` and `PUT #`. `CLOSE #1, #2` now closes both files; it used to close only the
  first. `INPUT` and `INPUT #` into a variable never declared read a number, not text.
- **`feature/view-offset-clip`.** In a `VIEW` port, coordinates are relative to the port's corner and
  drawing is clipped to it. This covers `PSET`, `LINE`, `CIRCLE`, `PAINT`, `DRAW`, `POINT` and graphics
  `GET` and `PUT`. `POINT` outside the port is -1. `VIEW SCREEN` keeps the screen's coordinates and
  clips. `CLS 1` in a port sends the text cursor home and the graphics cursor to the port's center, as
  QB64pe does. The `console.warn` of step 4 is gone. Tests are in `test\qb-graphics.bas`.
- **The game.** Built with either changed compiler, the game's JavaScript is identical to before. The
  game uses no `MOD`, and its file numbers have no suffix. The `VIEW` branch changes only the runtime.
  The game's one `CLS 1` (`ui\menu.bm` line 70) now homes the cursor, as the native build does. Not
  run yet: the 41 scripts and the autoplay seeds with the `VIEW` branch.
- **`NOT`.** With `--qb-booleans`, `NOT (a < b OR b > c)` and `NOT x > y` give QB64pe's results. Without
  the switch both are wrong.
- **`ENVIRON$`** left the list: a browser has no environment, so `""` is right, and the harness
  supplies the variables. **The `.VGA` files** go (user, 2026-11-17), with `tools\vga_to_png.py`.

**2026-11-18, step 12: the reports read, and the drawing bugs fixed.** Moved here from the plan's
step 12 on 2026-11-18. Bug 3 of the list is still open and stays in the plan.
- On 2026-11-18 the reports of that morning's run were read: 35 scripts, all with
  `fix/line-pixels` and `fix/screen-same-mode`. Most screens differ by about 1 %, because QBJS draws
  text and `CIRCLE` its own way. The rest came from the bugs 6 to 9 below. Six scripts have no report
  from that run: `endings`, `sound-rebel`, `sound-union`, `two-player` and `union-time`, and
  `pass-union-1861`, played again on the host (at most 0.9 % with 6 to 9).
- Fixed in QBJS what the screens show. Known from `navy` (shown by small programs in
  `tests\out\web\probe\`, which is not kept; `--hook` traces a run):
  1. and 2. Done on 2026-11-17, branch `fix/draw-pixels`, not yet run with the game's scripts. With
     the switch `--qb-lines` (or `$LINES QB`), `DRAW` sets whole pixels as QB64pe does, so `PAINT`
     after the train's `DRAW` finds its border; `POINT(0)` and `POINT(1)` give the pen rounded. The
     switch is off by default because QBJS strokes smooth lines on purpose, and the Graphics 2D
     library's `LineWidth` relies on them (user, 2026-11-17). The game's runners pass it.
  - `LINE` strokes the canvas too, two pixels wide: `LINE (20,20)-(30,20)` covers rows 19 and 20
    and leaves out x=30, and a `B` box is two pixels wide. The map's `PAINT`s work because a line
    two pixels wide is hard to leak through. Done on 2026-11-18, branch `fix/line-pixels`: with
    `--qb-lines`, `LINE` sets whole pixels with the same helper.
  4. The mountains (`_PUTIMAGE` of `MTN.PNG`) looked different. On 2026-11-18 they show no
     difference in `navy` or `commands`. Which fix did it was not looked into.
  5. `SCREEN 12` while already in `SCREEN 12` clears the screen in QBJS. In QB64pe it changes
     nothing: pixels, graphics cursor and text cursor stay (checked 2026-11-17). The end-game screen
     (`ui/victory.bm` line 149) fills the screen red, then `draw_map` runs `SCREEN 12`, so QBJS shows
     white around the map where native shows red with a black shadow (`navy`, 20.7 % of pixels).
     Worse, `draw_surrender` (`game/victory_screens.bm` line 183) runs `SCREEN 12` during a turn and
     draws only the right panel, so in QBJS the map is gone until the next redraw
     (`pass-union-1861`, March and April 1862, 65 % of pixels). Done on 2026-11-18, branch
     `fix/screen-same-mode`: `SCREEN` with the mode in use returns at once, as QB64pe's
     `qbg_screen` does. With it and `fix/line-pixels` on `game/cws`, no screen of `pass-union-1861` or
     `navy` differs by more than 0.9 %.
  6. The bar under "VP" at the top right: native draws blue, then white to x=630; QBJS draws no
     white (`pass-union-1861`, every turn; the blue matches since `fix/line-pixels`). The white is
     `LINE ..., 8 - side_color, BF` (`ui/screen.bm` line 123), color -1 for the Union. QBJS draws
     every negative color black. QB64 masks it to the screen's palette: -1 is 15 in `SCREEN 12`, and
     `&HFFFFFFFF` (white) in a 32-bit image. Done on 2026-11-18, branch `fix/negative-color`.
  7. The army report draws its two rules with `STRING$(70, "─")`, where the `─` is byte 196 in the
     source (`ui/reports.bm` lines 173 and 175). `qbc.js` read the source as UTF-8, so each such byte
     became U+FFFD, drawn as a wide `?` box: the rule wrapped onto three lines (`union-manassas` and
     `commands`, 7.4 to 7.9 %). Fifteen lines in six files have such bytes: box lines, `▓` bars and
     `√` marks. Done on 2026-11-18, branch `fix/cp437-source`: `qbc.js` reads a source file, and each
     `$INCLUDE` file, that is not valid UTF-8 as code page 437, with the same characters `CHR$` gives.
     QBJS's suite does not use `qbc.js`, so no suite test covers it; a small program with box
     characters in its main file and its `$INCLUDE` file showed it.
  8. PRINT did not move an item that does not fit on the rest of the line to the next line, as QB64's
     `makefit` does. The report's ` 11 ` at column 78 went to the end of row 1 instead of the start of
     row 2. Done on 2026-11-18, branch `fix/print-makefit`, for every program (not under a switch).
     Six cases match QB64pe's `CSRLIN` and `POS(0)`, among them `TAB` and an item longer than a line.
  9. `PAINT` stopped at pixels of the fill color as well as at the border. `draw_map` starts with
     `PAINT (200, 200), 2, 10` over a map that is already green, so in QBJS it painted nothing, and a
     menu left on the map stayed under the Intelligence report (`commands`, 3.5 %). QB64pe fills every
     pixel not of the border color. Done on 2026-11-18, branch `fix/paint-fill-color`, with
     `--qb-lines` only, so that QBJS's default `PAINT` does not change.

  The four branches of 6 to 9 start from `fix/screen-same-mode`, each with a test in QBJS's suite
  but 7. They are committed (`cdd021a`, `57d93c1`, `31b157f`, `6d222cc`) and not merged into
  `game/cws`. With all four applied to `game/cws`, no screen of `commands`,
  `union-manassas`, `navy` or `pass-union-1861` differs by more than 1.3 %.

**2026-11-18 and 19, step 12: three more drawing bugs, and the two-player autoplay.** Moved here
from the plan's step 12 on 2026-11-19.
- With `fix/line-pixels` and `fix/screen-same-mode`, 37 of the 41 scripts passed in the VM; the
  other four (`pass-union-1861`, `sound-rebel`, `sound-union`, `two-player`) passed alone.
- The branches of 6 to 9 (`fix/negative-color`, `fix/cp437-source`, `fix/print-makefit`,
  `fix/paint-fill-color`) were merged into `game/cws` on 2026-11-18 (the fork's pull requests 1 to
  4; `game/cws` is at `64a9c02`, and QBJS's suite passes 12 of 12 there). With them, all 41 scripts
  passed in the VM on the first try, and every script but `bad-events` (no screens) has a report.
  No screen differs by more than 1.4 %. A scan of the 578 pairs for blocks of 8 by 16 pixels that
  differ, not thin text edges, found three bugs, 10 to 12 below.
- Bug 3 of the list, not fixed:
  3. `POINT(x, y)` in `SCREEN 12` gives a 32-bit color (4278233088), where QB gives the palette
     number (2). The game never calls `POINT(x, y)` (checked 2026-11-18). QBJS keeps every screen as
     32-bit pixels, and its own tests compare `POINT` with `_RGB32` in `SCREEN 12`, so a fix changes
     existing programs and goes behind a switch that is off by default, as the other QB settings do.
     Not needed now (user, 2026-11-18): a row in the fork's `SOMEDAY.md`.
- Three more bugs, fixed:
  10. A tab character in `PRINT` was drawn as a glyph. In QB64 it moves to the next tab stop, 8
      columns apart, blanking what it passes; with no stop left on the line it starts the next line.
      The game's prompts `"<4 tabs>ESC when done"` (`ui/reports.bm` line 18) and
      `"<3 tabs>press a key"` (`ui/options.bm` line 300) came out at the wrong column
      (`union-time`, the `war-*` scripts, `options`). Branch `fix/print-tab`, from
      `fix/print-makefit`.
  11. `LOCATE` cut a row or column that is not a whole number; QB64 rounds it, a half to the even
      number. The forces report (`ui/reports.bm` line 321) puts each number at `city_x(k) / 8`, so
      some were one column left (`union-time`, `commands`). Branch `fix/locate-round`, from
      `fix/screen-same-mode`.
  12. A new line on the last two rows scrolled the whole screen. In QB64 the last row does not
      scroll: the rows above it move up and the cursor stays on the row before the last. The
      History recap (`report_recap`, `ui/reports.bm`) prints each line on row 29, so in QBJS the
      lines scrolled off and "press a key" covered the last one (`files`). The new row is filled
      with the background color, as in QB64. Branch `fix/print-last-row`, from `fix/print-makefit`.

  Each was measured first with a small program built with `qb64pe.exe`: 38 cases of `PRINT` and
  `LOCATE` in `SCREEN 12`, and 18 cases of the last rows in six screen modes (in QB64Rust's
  `target\scratch\2026-11-18\print-probe\`, not kept). Each branch has a test in
  `test\qb-graphics.bas`, and QBJS's suite passes 12 of 12 on each, and on the three together over
  `game/cws`. With the three together, `files`, `union-time`, `commands` and `options` pass on the
  host and have no such block left. The three were merged into `game/cws` on 2026-11-19 (the fork's
  pull requests 5 to 7; `game/cws` is at `4188f2e`, and QBJS's suite passes 12 of 12 there).
- The autoplay check, two-player game on the standard map, with seeds 1 to 100 on
  2026-11-18. With `game/cws` at `64a9c02`, all 100 seeds match the native results. In the VM, with six
  pages at once, seeds 23, 25, 26 and 41 ran past the 600-second limit; on the host they finished in
  90 to 189 s and match. The `PAINT` of bug 9 makes a seed about 10 % slower (the fork's
  `SOMEDAY.md`). The alternate map was stopped after 78 seeds had played in QBJS, before the
  comparison with the native build. I stopped it when the user objected to the size of these runs.

**2026-11-19, step 12 done.** With `game/cws` at `4188f2e` (bugs 6 to 12 fixed), in QB64Rust's
suites VM:
- All 41 scripts pass, with no retry. No screen differs from the native one by more than 1.3 %,
  the difference of QBJS's text and `CIRCLE`. A scan of all 578 screen pairs finds no block of 8 by
  16 pixels that differs.
- Autoplay, two-player game on the alternate map, seeds 1 to 20: all 20 match the native results.
- Autoplay, one-player game on the standard map, seeds 1 to 20, played once as each side: all 40
  match the native results.
- How to run the scripts in the VM and read their reports is at the top of
  `tests\web\play_qbjs.js`.

**2026-11-19, step 13: what the user heard and saw, fixed.** The user played the game in Chrome
with `serve.js` and found two problems. Each is fixed in the fork, measured against QB64pe's source
or `qb64pe.exe`, and merged into `game/cws` (now `266df99`, the fork's pull requests 8 to 11).
- **A long beep after "new game".** The beep is the menu's `SOUND 700, .5` (`ui/menu.bm` line 175),
  28 ms. QBJS ended `SOUND`, `BEEP` and `PLAY` notes with a JavaScript timer, so a busy page made a
  tone ring until the timer ran: in a test that kept the page busy, the 28 ms tone lasted 0.69 s.
  `SOUND` also gave `oscillator.stop()` milliseconds where it takes seconds. Branch
  `fix/sound-timing`, for every program: each tone now ends on the audio clock. Whether this was the
  beep the user heard is not confirmed: the user has not listened since.
- **The schooner's picture mostly black.** `draw_schooner` (`draw/ships.bm`) runs `PAINT (140, 340)`
  with no color. QB64pe fills with the foreground color; QBJS filled with black and flooded the
  screen (96.5 % of pixels differed, 2.2 % with the fix). Branch `fix/paint-default-color`, for
  every program, with a suite test.
- **Found on the way:** `CIRCLE` drawn as a smoothed arc, so a `PAINT` inside a small circle could
  leak. Branch `fix/circle-pixels`, under `--qb-lines`: `CIRCLE` sets QB64's pixels; 20 cases match
  `qb64pe.exe` pixel for pixel. With it, the scripts' screens differ by about 0.6 % where they
  differed by up to 1.3 %.
- **The sound review.** QBJS's `PLAY`, `SOUND` and `BEEP`, read against QB64pe's `audio.cpp`. What
  the game meets is fixed under a new switch, `--qb-sound` / `$SOUND QB` (branch
  `fix/play-dots-volume`): every dot after a note counts (the victory tune's `f4..`), 18.2 clock
  ticks to a second, `SOUND` and `BEEP` as loud as `PLAY`, one queue for `PLAY` and `SOUND` with
  QB64's wait, `MB` in the background (the end-game tune), and the audio resumed on the first key.
  The switch is off by default, because these change how existing QBJS programs sound (user,
  2026-11-19). What the game does not meet is in the fork's `SOMEDAY.md`. The game's build
  scripts pass `--qb-sound`.
- **Checks:** all 41 scripts pass in the VM with `f8cb94e` (four only when played again alone,
  for load). `sound-rebel` and `sound-union` pass on the host with `266df99` and the switch on.
  QBJS's suite passes 12 of 12 on each merge.

### Effort

Counted in Claude's sessions: step 1 one, step 2 two to three, step 3 two, step 4 one to three,
depending on what playing shows. About 6 to 9 in all. The user's time:
playing the game in step 4, and posting upstream.

### Questions for the user

Answered on 2026-11-16 (user):

- **The pictures become PNG files in the game, if they come out the same.** All ten `.vga` files of
  `graphics\` (the icon, the mountains, five faces, three forts). The files hold 16 colors and PNG
  loses nothing, so the pixels can be the same. The proof is that the recorded screens of
  `tests\scripts` do not change (`play.py check`). In QB64pe a 32-bit picture cannot be put on
  `SCREEN 12` (`_PUTIMAGE` gives error 5), so the pictures are loaded with `_LOADIMAGE(file$, 256)`,
  which maps each color to the nearest of QB64's palette. Its first 16 colors are `SCREEN 12`'s.
  This is step 3a.
- **Rounding is a setting**, and the game uses the one that fits it: halves to even.
- **The harness may download a browser driver from npm.**

- **By reference is copy in, copy out** (user, 2026-11-16), once a scan showed that it gives the
  same results as QB in this game. The caller puts each argument in a small object, as QBJS already
  does for the file `GET` (`tools\qb2js.bas` line 1358), and writes it back after the call. It
  differs from QB in two cases, and the game has neither:
  - **One variable passed in two arguments:** 4 calls, all `army_appoint(x, x)` (`io\files.bm` line
    97, `rules\army.bm` lines 203 and 440, `rules\events.bm` line 322). `army_appoint` never writes
    either parameter, so nothing is copied back that differs.
  - **A `SHARED` variable passed to a procedure that also uses it by name:** 8 calls. `current_side`
    goes to `menu_railroad`, `menu_army_cancel`, `menu_army_combine` and `menu_army_relieve`, and
    `army_city(…)` goes to `city_update_occupier` and `draw_army_flag`. None of the procedures they
    reach writes the variable, and none writes the parameter that receives it.

  The scan is `alias_scan.py`, in QB64Rust's `target\scratch\2026-11-16\qbjs-cws\`, which is not
  kept. It looks at the 1,606 calls of the 441 procedures, and through every procedure each one calls
  in turn. Run it again after a change to the game, before relying on the build.

#### The panel

Role-played by Claude, 2026-11-16.

- **Pragmatic engineer:** the measurement changed the picture. The game avoids QBJS's worst gaps
  (`GOTO`, `ON ERROR`), and what is left is a list of ten known items. Do the small ones first; they
  are also the ones upstream will take.
- **QB64 engineer:** `DEFINT` and rounding matter as much as by-reference here. 550 of 617
  parameters get their type from `DEFINT`. Without both, the rules drift and nothing says so.
- **Compiler engineer:** copy in, copy out fits how QBJS already writes calls. The scan found no
  call in the game where it differs from QB.
- **Test engineer:** step 1 before any change. The autoplay line is a strong check because `RND`
  already matches. Without it the plan rests on playing by hand.
- **Rust engineer:** nothing here touches QB64Rust's crates. Keep the QBJS target a separate change.
- **Web platform engineer** (added because the result runs in a browser): saved games that survive a
  reload, and the function keys, decide whether the game is usable. Look at both early in step 4.
- **Recommendation:** start with step 1 and the four certain items of step 2 (`DEFINT`, the `CONST`
  bug, the old `OPEN`, and `TAB` from step 3). Nothing in them waits for an answer.

## Code smells review: completed items

Was `docs\archived\code-smells-review-completed.md`.

The items of the code smells review of 2026-11-26 that are fixed. The open items are in
[../code-smells-review.md](../code-smells-review.md), under the same headings.

### Worth fixing

#### 2. Drawing code changes game state (priority: high)

`draw_fleets` set `fleet_city(side) = 0` for a fleet with no ships (`draw\map.bm`). The repair
happened only when the map was drawn again. `tests\test_layers.py` checks `rules\`, not `draw\`, so
it did not catch this.

Fixed on 2026-11-26 (G61 in `rule-changes.md`). `navy_drop_empty_fleet` (`rules\navy.bm`) clears
the port of a fleet with no ships. It is called after the computer's first Union build
(`ai_fleet_orders`) and when a scenario or a save is read (`load_scenario`, `load_game`).
`draw_fleets` draws no such fleet and changes nothing.

#### 4. Realism is tested five ways (priority: high)

The counts were: `>= REALISM_ON` 11 times, `= REALISM_OFF` 4, `= REALISM_ON` 2, `<> REALISM_OFF` 1
and `>= REALISM_HIGH` 1. At `rules\battle.bm`, line 69, `= REALISM_ON` meant that Realism 2 lost the
realism defense that the other tests gave it.

`opt_history` had no constants, and was tested both as `= 1` and as `> 0`.

Fixed on 2026-11-26:
- Every rule asks `opt_realism = REALISM_ON` or `= REALISM_OFF`, as History's rules ask
  `HISTORY_ON`. Realism 2 and `REALISM_HIGH` are gone, with the .8 that `ai_attack_score`
  gave the computer's odds at 2: nothing in the original set 2 (user, 2026-11-26).
  `config_read` makes a Realism below 0 off and one above 1 on (G60 in `rule-changes.md`).
- `HISTORY_OFF` and `HISTORY_ON` are in `cws.bi`, every place asks for `HISTORY_ON`, and
  `config_read` makes any History but 0 on (U36 in `devnotes.md`).

#### 5. The 17 fields of `CWS.CFG` are kept in step by hand (priority: medium)

`config_read` and `config_write` each listed the 17 fields in order. `config_write_totals`
hard-coded the count 17 and the fields 12 to 15 (`io\files.bm`). An error of one field would have
mixed up the battle totals with no message. `config_read` also repeated the values the menus set
in `rules\setup.bm`: the display speeds 1, 2, 3 and 8, the event balances 0, 3, 5 and 7, Balance
1 to 5 and Aggression 0 to 5. `TestConfigReadMakesSettingsValid` checked them against fixed numbers.

Fixed on 2026-11-26. Nothing the game does changed, and no recorded screen changed.
- `cws.bi` names the values: `SPEED_FAST` to `SPEED_VERY_SLOW`, `EVENTS_OFF` to
  `EVENTS_FAVOR_REBELS`, `DIFFICULTY_LOWEST` and `DIFFICULTY_HIGHEST`, `AGGRESSION_LOWEST` and
  `AGGRESSION_HIGHEST`. Every place that compared the display speed or the event balance with
  one of its values uses the constant now, and so do `config_read`, the menu SUBs and the
  Display and Rndom Evt menus' row counts (`DISPLAY_SPEED_ROWS`, `EVENT_BALANCE_ROWS`). The
  computer's tests of Aggression in `ai\army.bm`, such as `opt_ai_aggression = 0`, are still
  bare numbers: item 10.
- Each menu's values are listed once: `display_speed_of_row!` and `event_balance_of_row` in
  `rules\setup.bm`. The menus set them, the start row is found from them
  (`display_row_of_speed`, `event_row_of_balance`), and `config_read` accepts only a value that
  one of the menu's rows gives.
- `balance_seen_by_player` gives the Balance with 1 and 5 traded for the Union. `event_roll` and
  the Utility menu had each worked it out as `6 - opt_difficulty`.
- `CONFIG_FIELDS` and `CONFIG_TOTALS_FIELD` give the file's layout to `config_write_totals`.
- Two branches that could no longer run were removed. `option_set_display_speed` took a row the
  menu does not have as a number of seconds; it now changes nothing, as the events' menu does.
  `menu_option_events` printed an event balance that no row gives as its number; `config_read`
  has not let one through since G62.
- `TestConfigReadKeepsWhatTheMenusSet` sets each menu's every value, writes and reads `CWS.CFG`,
  and checks that the value and its menu row come back. `TestConfigLayoutMatchesConfigWrite`
  checks that `config_write` writes `CONFIG_FIELDS` fields with the totals at `CONFIG_TOTALS_FIELD`.

The two field lists of `config_read` and `config_write` are still written out twice: BASIC's
`INPUT #` and `WRITE #` take no list in common. The layout test fails when a field is added to
`config_write` without changing `CONFIG_FIELDS`, or before the totals without moving
`CONFIG_TOTALS_FIELD`. A field added to `config_read` alone makes it read past the file's end,
which stops the other `TestConfig` tests.

#### 7. File handling comes in two styles (priority: low)

The first of its two points is fixed. The second, returning an error's text, moved to
[../SOMEDAY.md](../SOMEDAY.md) on 2026-11-27, with item 6.

- `io\files.bm`, `ui\messages.bm` and `ui\reports.bm` opened fixed handles: #1 for the scenario's
  files, the saves, `CWS.CFG`, `battsumm` and the Hall of Fame, and #2 for the history file. A
  comment in `load_game` explained why it closed #1 early: `load_scenario` and `load_cities` used
  #1 too.

Fixed on 2026-11-26. Every `OPEN` in the game takes its number from `FREEFILE`, in a local
`file_num`. `load_scenario_armies` is given the number of the open `CWS.INI`. Nothing the game
does changed, and no recorded screen changed.

#### 8. The menu's shared variables carry many meanings (priority: high)

- `menu_choice` was both an input (`MENU_START + n`, the row to start on) and the result: a row,
  `MENU_ESCAPED`, minus a key's code, or 1, 2 and 3 for Up, Enter and Down (`menu_select` and
  `menu_start_row`, `ui\menu.bm`).
- `show_message_box` wrote over `menu_text$(1)`, `menu_col`, `menu_row` and `menu_item_count` to
  measure its text (`ui\messages.bm`). A menu being filled when a message showed lost its first row.
- `navy_combat_auto` set the menu's texts and `menu_choice` "though no menu shows"
  (`commands\navy.bm`).

The last two points were fixed on 2026-11-26 (U35 in `devnotes.md`). The box keeps its place and
width in locals, and measures the message alone; before, its width also counted the heading left in
`menu_text$(0)`. The computer's sea fight sets no menu rows.

The first point was fixed on 2026-11-26. `menu_choice` is now the result only: a row,
`MENU_ESCAPED`, or `MENU_END_TURN_KEY` at the main menu.

- `menu_select (kind, start_row)` takes the row to start on as its second argument. All 36 calls
  pass it, and `MENU_START` is gone. A number that is no row of the menu starts it on row 1
  (`menu_start_row`).
- The city picker's menu (`MENU_RAW_KEYS`) leaves its key in the new shared `menu_key$`: a letter
  in upper case, Esc, Enter, or `CHR$(0)` and `KEY_UP$` or `KEY_DOWN$`. `menu_city_select`
  (`ui\city.bm`) reads that. Its `CASE ELSE` that no key could reach is gone.
- `menu_navy_items` gives the Ships menu's start row through a parameter.
- `play_shenandoah` (`game\tunes.bm`) no longer sets `menu_choice` to 1 when a key stops the tune.
  Nothing read it.

No recorded screen changed. One case differs that no menu of the game reaches: a menu called with
no start row began on row 21 when the menu before it had ended on row 21 and it had 21 rows itself.
It now begins on row 1.

#### 9. `battle_strengths` changes the armies (priority: low)

The procedure worked out the strengths, and also set `army_size` to 1 when it was below 1
(`rules\battle.bm`). Its attack and defense halves are near copies with small differences: the
small-army step is capped for the attacker only. `army_size(attacker) / army_size(defender)` is
worked out five times.

Fixed on 2026-11-27 (user: "yes" to the pragmatic engineer's plan). The clamp is now
`battle_armies_ready (attacker, defender)` in `rules\battle.bm`, and `calculate_battle`
(`ui\battle.bm`) calls it before `battle_strengths`. It could not simply go: `battle_losses` caps
an army's losses at `army_size - 1`, so an army of 0 would take -1 losses and gain 100 troops.
`TestBattleCountsAnEmptyArmyAsOne` calls the new SUB. The 281 unit tests and the 43 scripts passed
on unchanged recordings.

Left as they are:

- **The two halves.** The user accepted this on 2026-11-13
  ([`structure-review-completed.md`](#done-the-review-of-the-structure-of-the-games-code), "Left as they are, from the second review"). Nothing has
  changed since. The uncapped step 3 of the defender changes nothing at the shipped
  `small_army_strength` of .5. Above 1 it changes only the step-3 number on the right panel, since
  the defender is capped at step 4.
- **The ratio worked out five times.** Keeping it in a `SINGLE` could flip a comparison at an
  exact ratio such as 1 to 5. Showing that it does not would take a recording at each boundary,
  to save four repeated expressions.

#### 15. The same map lines are drawn in two places (priority: medium)

`draw_map_touchup` (`draw\map.bm`) was the original's `touchup` (`CWSTRAT2.BAS`, line 1367).
`turn_resolve` called it after the month's moves. `MARK_ERASE_ARMY` called it after it painted a
green box over an army's flag at New Orleans (27) or Norfolk (28). Most of its 40 lines copied
lines of `draw_map` point for point, so a point moved in one copy would have left two lines on
the map. The commerce box, `(447, 291)-(525, 335)`, was written out in `draw_map` and twice in
`navy_commerce_raid`. `draw_map` also had two lines of no length, and `draw_map_touchup` two
`PAINT` lines that were comments.

A check of the screens showed more: touchup drew its lines over city dots and names, such as
the letters of "MOBILE", and repaired only its own pieces.

Fixed on 2026-11-27 at the user's request (U42 in `devnotes.md`):
- `turn_resolve` draws the map again over its area (`draw_map_area`). `draw_map` is
  `SCREEN 12` and `draw_map_area`.
- `MARK_ERASE_ARMY` puts back the bare map under the flag, from a copy that `draw_map_area`
  keeps (`draw_map_restore`), at every city. When no army is left in the city, it then draws
  the city's mark again (`draw_city`, taken out of `draw_cities`).
- Not changed: an army marching out (`animate_army`) and an erased train (`draw_train`) still
  paint a green box with `draw_erase_flag` (`TODO.md`).
- `draw_map_touchup` and the two lines of no length are gone. `draw_commerce_box` draws the
  commerce box for `draw_map_area` and `navy_commerce_raid`.

235 of the 592 screens of the 43 scripts changed, in 32 scripts, which were recorded again.
Every change looked at matches what a fresh `draw_map` draws.

### Smaller items

#### 10. Bare numbers beside named ones (priority: low)

- In `battle_strengths`, the ratios `.2`, `.5`, `3`, `10` and `1.5` are bare numbers beside tuning
  knobs.
- `ai\army.bm`, line 264: `opt_ai_aggression < 3` and `army_size(army) < 40`. Lines 222 and
  275 test `opt_ai_aggression > 0` and `= 0`, where `cws.bi` has `AGGRESSION_LOWEST`.
- `rules\army.bm`, lines 320 to 325: `i > 20` and `i > 30` on city numbers, and the chances `.3`,
  `.4` and `.6`.
- `report_cities` loops `1 TO 20` and `21 TO 40` (`ui\reports.bm`, lines 219 to 225) where it
  means `MAX_CITIES`.

Fixed on 2026-11-27. The game plays as before: all 43 scripts give their recorded screens.

- Eight new knobs in `tools\tuning\knobs.txt`. The battle ratios are `badly_outnumbered_ratio`
  (.2), `outnumbered_ratio` (.5), `attack_outnumbering_ratio` (3), `defend_outnumbering_ratio`
  (1.5) and `overwhelming_ratio` (10). Three rules between knobs keep their order. The
  computer's cautious attack is `ai_cautious_aggression` (3), `ai_cautious_army_size` (40) and
  `ai_cautious_odds` (.8, also bare on line 264).
- The ratios are DOUBLE knobs, like the other fractions. At exact ratios such as 20 against 100
  and 50 against 100, a DOUBLE compares as the literal did, with QB64Rust and QB64pe alike.
- `ai\army.bm` compares with `AGGRESSION_LOWEST`.
- `army_recruit_cities` names its chances as constants of its own, with the roll `.8` that
  offers one city fewer: `FEWER_CITIES_ROLL`, `CHANCE_SPREAD`, `CHANCE_CATCH_UP` and
  `CHANCE_WITH_ARMY`. Its city positions are `MAX_CITIES \ 2` and `3 * MAX_CITIES \ 4`.
- `report_cities` shows two columns of `MAX_CITIES \ 2` cities.
- New unit tests: `TestBattleAttackRatiosAtTheirKnobs`, `TestBattleDefendRatiosAtTheirKnobs` and
  `TestAiAttackScoreOfACautiousComputer`.

#### 11. Loose ends in `cws.bi` (priority: low)

- `FALSE` was a constant, but `TRUE` was not.
- The `COMMON SHARED` lines were left from the DOS game's `CHAIN`, in a program of one module.
- `saved_under_army(300)`, `saved_under_marker(300)`, `menu_value(40)` and `pic_capital(60)` had
  bare sizes.
- The comment on the events table was above the scenarios' `DIM`, not the events'.
- The header runs code: `CALL tuning_defaults`.

`TRUE` was fixed on 2026-11-26 with item 12: `cws.bi` has `CONST TRUE = -1`. The rest was fixed
on 2026-11-27. Nothing the game does changed.

- The `COMMON SHARED` lines are gone. The arrays already had `DIM SHARED`. The 37 variables that
  only `COMMON` declared have `DIM SHARED` lines now, in groups: the menu, the turn and the game,
  the options, the rules and income, and commerce raiding. The game has no `REDIM` or `ERASE`, so
  the arrays becoming static instead of dynamic changes nothing.
- `menu_value()` is sized `MENU_MAX_ROWS`, like `menu_text$()`. Only `menu_add_row` writes it,
  and that stops at `MENU_MAX_ROWS` rows.
- The `GET` buffers are sized by `FLAG_BUFFER_SIZE`, `MARKER_BUFFER_SIZE` and
  `CAPITAL_BUFFER_SIZE`, with a comment naming the area each holds. They keep the DOS game's
  sizes, since what `GET` needs has not been measured in QB64pe, QB64Rust and QBJS.
- The events table's comment is above `DIM SHARED event_count`.
- `CALL tuning_defaults` stays in the header, as its comment says: `cws.bas` and
  `tests\rules_test.bas` both include `cws.bi`, and both need the defaults.

Checked with the 282 unit tests, all 43 scripts with the QB64Rust build, and `play.py compare` of
`title` and `union-manassas` with both builds.

#### 12. Two styles for true, and for calls (priority: low)

- A comparison gave -1, while flags and the FUNCTIONs described as "1 when ..." gave 1.
- 17 calls left out `CALL`, such as `wait_seconds .1 * opt_pause!`. 78 used it.

Fixed on 2026-11-26. Nothing the game does changed.

- Every yes-or-no is `TRUE` (-1) or `FALSE` (0), as a comparison gives. That covers about 50
  flags and FUNCTIONs, such as `again`, `quit`, `starved`, `event_done()`, `navy_has_ironclads`
  and `victory_near_cities`. They are set to `TRUE` or `FALSE` and tested as `IF flag` or
  `IF NOT flag`, never against 1 or 0. `NOT 1` is -2, which is also true: once
  `event_general_problem$` tested `IF NOT has_banner`, `TestEventGeneralProblem` failed until it
  passed `TRUE` instead of 1.
- Calls that pass a yes-or-no pass `TRUE` or `FALSE`: `recruit_troops`, `city_capture`,
  `city_take`, `event_pick`, `turn_set_moves_done` and `turn_set_navy_done`. So does
  `tuning_check$` in the generated `io\tuning_knobs.bm` (`tools\tuning\make_knobs.py`).
- Two places counted with a flag: `save_game` added `event_done()` into `done_count`, and
  `event_conditions_hold` worked out `1 - event_done(row)`. They test the flag now.
- The settings of `CWS.CFG` (`opt_winter_campaigns`, `opt_history` and the others) keep their
  values 0 and 1. They are a file's fields with numbered values, not flags, and the file stays
  as it was.
- The 19 calls that left out `CALL` use it now, with the arguments in parentheses. 17 of them
  were `wait_seconds` and 2 `clear_bottom_line`.

#### 13. The two data readers repeat the same loop (priority: low)

`io\events_file.bm` and `io\tuning_file.bm` share the same lines: open the file, the read loop, the
BOM strip, and the split of `key = value`. One shared reader would serve both.

Decided on 2026-11-27: no shared reader. Claude recommended this as the pragmatic engineer, and the
user had it carried out. The helpers moved instead.

- The shared part is about 15 lines in each reader. The formats differ around it. Tuning cuts a
  line at its first `;`, while events takes `;` as a comment only at a line's start, so that a
  `text` or `banner` value may hold one. Events also reads `[section]` lines, strips quotes, and
  refuses a key given twice. A missing events file is an error; a missing tuning file is passed over.
- BASIC cannot pass a procedure as an argument, so a shared reader could only hand back one line at
  a time. Each caller would keep its loop and its `SELECT CASE`, and save about 10 lines.
- No third `key = value` reader exists. `load_game` reads with `INPUT #`, and `ui\reports.bm` reads
  plain lines of history.
- `text_take_item$`, `text_without_bom$`, `text_trim$`, `text_is_number` and `text_last_space`
  moved byte for byte from `io\events_file.bm` to a new `io\text.bm`. `io\tuning_file.bm` and
  `io\script.bm` use them too, and before they built only because the events reader was included
  beside them. `cws.bas` and `tests\rules_test.bas` include `io\text.bm` before the readers.

#### 14. `draw_map` does start-up work on every draw (priority: low)

It calls `_FILEEXISTS(GFXDIR + "MTN.PNG")` each time, where it could test `pic_mountain`, and it sets
`SCREEN 12` each time.

Fixed on 2026-11-27, the first half only.

- `draw_map` tests `pic_mountain < -1`, whether `show_title` loaded the picture, instead of
  whether the file is on disk now. The old test was a latent bug: if the file existed but failed
  to load, `pic_mountain` was -1, and each `_PUTIMAGE` would have stopped the game with an error.
- `SCREEN 12` stays. It is how `draw_map` starts from a clean screen, and about 30 calls reach it,
  many straight after a full-screen picture or report (`draw\ships.bm`,
  `game\victory_screens.bm`). Taking it out would mean checking each of those paths.

#### 18. Bare numbers left in the armies' code (priority: low)

Item 10 named three lines of `ai\army.bm`. The rest of the file still had about 20 bare numbers
beside tuning knobs: chances, strength ratios, the odds steps .3 to 1.5, and the score -9999. Two
comments gave a knob's value: "plus 20" (`ai_move_strength`) and "50 for the enemy's capital"
(`ai_beyond_score`). `ai_razes_fort` tests `city_y(city) > 150`, a pixel of this map. In
`rules\army.bm`, the price of a day of supplies was written twice, as `* 10#` in
`army_supply_days` and `.1 *` in `army_buy_supply`. A new army's experience is a bare 1 in
`army_raise`.

Fixed on 2026-11-27, as the pragmatic engineer recommended (user: "do the pragmatic engineer's
recommendations").

- The two comments name the knobs, `ai_aggression_strength` and `ai_capital_road_bonus`.
- `cws.bi` names the price once, as `SUPPLY_PRICE` (.1#). `army_supply_days` divides the cash
  by it and `army_buy_supply` multiplies by it. A probe compared both with the old formulas
  for every cash value from 0 to 19999, army sizes 1 to 3000 and 1 to 10 days, in the QB64pe
  and QB64Rust builds: no result differs. All 43 scripts show the recorded screens.

Left as they are:

- **The other numbers of `ai\army.bm`.** They are no knobs worth tuning one by one. The odds
  steps are one table and read best together.
- **`ai_razes_fort`'s 150.** It belongs with item 3, phase 11 of `modernize-plan.md`.
- **The new army's experience of 1.** The Union's side of `rebel_new_army_experience` would be a
  knob of its own; nothing asks to tune it.

#### 19. Ship kinds and sides as bare numbers in the drawing code (priority: low)

- `ship_icon` gave 1 for a wooden ship and 2 for an ironclad, and `draw_ship_icon` tested
  `CASE 1` and `CASE 2`.
- `draw_ship_jack` tested the side as `CASE 1` and `CASE 2`.
- `draw_fleet_sailing` tested the lead ship as `CASE 73` and `CASE 87`, `ASC("I")` and `ASC("W")`.
- `draw_cities` wrote the first fort level as a bare 1, and tested `CASE MAX_FORT` for capitals
  but `CASE IS >= MAX_FORT` for other cities.
- `draw_city_names` tested `opt_alt_colors = 0`, and stopped at x 527, the map's right edge,
  which `draw_map` also wrote as a bare number.

Fixed on 2026-11-27. No recorded screen changed.

- `ship_icon` is gone. `draw_ship_icon (side, ship$)` takes the ship's letter: an ironclad for
  `SHIP_IRONCLAD$`, a wooden ship for any other letter or none, as `ship_icon` gave.
  `TestShipKinds` no longer checks `ship_icon`.
- `draw_ship_jack` tests `SIDE_UNION` and `SIDE_REBEL`, and `draw_fleet_sailing` tests
  `SHIP_IRONCLAD$` and `SHIP_WOODEN$`.
- A capital's fort mark is the full one at `MAX_FORT` or more, as for other cities. They differ
  only for a fort above `MAX_FORT`, which only a `CITIES.GRD` written by hand gives:
  `load_cities` does not limit it.
- `draw_city_names` tests `opt_alt_colors > 0`, as the other three places do.
- `MAP_RIGHT` (527) in `cws.bi` is the names' limit and the map's border in `draw_map`. The
  other 527 of `draw_map` is a line of the map, which stays with its points.

Left as it is: the fort level 1. Fort levels are the numbers 0 to `MAX_FORT`, and a name for 1
would say nothing more.

#### 20. The 40 cities, again (priority: low)

Item 10 made `report_cities` use `MAX_CITIES`. `report_armies` still printed `"/ 40"` and worked
out the share as `* 2.5` (`ui\reports.bm`). `menu_victory_conditions` and `ui\victory.bm` turned
the cities rule into a percentage with `2.5`, which is 100 over 40.

Fixed on 2026-11-27: each is `100 / MAX_CITIES` now, and `report_armies` prints `MAX_CITIES`.
The results are the same exact numbers, so no recorded screen changed.

#### 21. Flags that item 12 did not reach (priority: low)

Eight FUNCTIONs still set 0 and -1: `army_may_get_supply`, `side_needs_supply`,
`side_can_supply`, `navy_can_build`, `navy_can_invade`, `navy_has_retreat_port`,
`any_saved_game` and `menu_has_value`.

Fixed on 2026-11-27: they set `FALSE` and `TRUE`. `any_saved_game` had no first value and gave
the 0 a FUNCTION starts with; it sets `FALSE` first now. `scenario_find`'s -1 stays: it is "no
row", not a flag.

#### 22. Hidden inputs and scratch storage (priority: low)

- `draw_ship_icon` takes its place from the graphics cursor, so each caller sets it with `PSET`
  first. `navy_combat_draw` did so with no color.
- Army slot 0 is the scratch army of a Join (`army_combine_start`).
- `army_generate_name` changed its argument; its one caller passed `(i)` so that its loop survived.
- The computer's army code finds its enemy from `current_side`, though `ai_army_order` is given
  `side`.
- `draw_stack_markers` tested `army_size(i) > 0`, not `army_exists(i)`, so it drew a circle for
  the army on the train at city 0's position, off the screen.
- `menu_main` changes its argument `start`, `main_menu_start` of `cws.bas`.

Fixed on 2026-11-27, in part. No recorded screen changed.

- `army_generate_name` works on a local copy, and `army_pick_commander` passes `i`.
  `TestRomanChangesItsTarget` is now `TestRomanLeavesItsTarget`, and `qb64-friction.md` section 5
  says so.
- `draw_stack_markers` asks `army_exists(i)` as well.
- `navy_combat_draw`'s `PSET` names `COLOR_BLUE`, the color it had. Its `COLOR COLOR_BLUE`
  stays: the wooden ship's first `DRAW` strokes take the current color.
- `menu_main`'s comment says that the caller's row moves too. Railroad, a closed Troops and Esc
  leave `main_menu_start` as `menu_main` set it.

Left as they are:

- **The graphics cursor.** `DRAW` works from it, and so does every picture of the game.
- **Army slot 0.** Join was fixed recently (G35, G36); moving its scratch army would risk it for
  nothing a player sees.
- **`current_side` in the computer's code.** `ui\turn.bm` explains it, and autoplay swaps
  `current_side` to play both sides (`tests\README.md`), which a parameter would have to carry.

#### 23. Menus that keep text in spare rows (priority: low)

`menu_victory_conditions` kept the time rule's text in `menu_text$(8)` and the force ratio's in
`menu_text$(9)`, past its six rows. Rows 1 to 5 stand for rules 2 to 6. `menu_report` handles row
1 in its `CASE ELSE`.

Fixed on 2026-11-27: the two texts are locals, `time_text$` and `ratio_text$`, and the SUB's
comment says that a row is its rule less 1. `menu_report`'s `CASE ELSE` stays.

#### 24. The picture-drawing code (priority: low)

- `draw_surrender` tested `IF army < 99`, always true for an army slot of 1 to 40.
- It used `side_color` for the uniform and then for the face, and wrote one line as
  `LINE (547, 263)` among positions written as `panel_left + ...`.
- `draw_rebel_victory` played its tune with `PLAY` after its own `opt_sound` test, while
  `draw_union_victory` used `play_music`.
- `draw_rebel_victory` did not clear the screen, as `draw_union_victory` does. Below its picture,
  which ends at y 440, the battle summary's "press a key" and the map's red still showed (seen by
  the user, 2026-11-27). The original's `rwin` (`CWSTRAT2.BAS`, line 1038) did the same.
- `draw_ironclad` and `draw_schooner` begin with the same three lines.

Fixed on 2026-11-27. No recorded screen changed.

- `draw_surrender` always waits; the test is gone.
- The face's color is `face_color`, and the line is `LINE (panel_left + 33, 263)-(panel_left + 44, 263)`.
- `draw_rebel_victory` plays each part through `play_music`. It played at Sound 2 or more, and
  `play_music` plays at Sound 2; Sound is never above 2 (`config_read`, `option_set_sound`).
- `draw_rebel_victory` starts with `SCREEN 12` and `CLS` (U41 in `devnotes.md`, at the user's
  request). No script takes a checkpoint at a Rebel victory, so the 43 scripts passed unchanged.

Left as it is: the three lines that the ironclad and the schooner share.

#### 26. The victory banner is written out three times (priority: low)

`end_game` (`ui\victory.bm`) had three branches for the banner: the Rebels' technical victory,
the Union's victory and the Rebels' victory. They differed only in the picture and the text; each
repeated `COLOR COLOR_WHITE`, `LOCATE 2, 27` and `PRINT message$`.

Fixed on 2026-11-28: each branch draws its picture and sets `message$`, and the banner is printed
once after them. The last branch is a plain `ELSE`, since `side` is always the Union or the Rebels
(`check_victory_conditions` loops from `SIDE_UNION` to `SIDE_REBEL`).

#### 27. The battle panel's two halves repeat five rows (priority: low)

`draw_battle_attacker` and `draw_battle_defender` (`ui\battle.bm`) each printed Ldr/Exp, Small,
Outman, Supply and Difclt from `steps(2)` to `steps(6)`, with Supply in magenta when the army has
none. Only the rows differed: 5 to 9 and 18 to 22. A change to the supply test could have reached
one side and not the other.

Fixed on 2026-11-27: both call `draw_battle_steps (army, steps(), top_row, col, side_color)`. No
recorded screen changed.

#### 28. The bottom line's message color is set by hand (priority: low)

`COLOR COLOR_LIGHT_CYAN` stood beside `CALL clear_bottom_line` 38 times, in either order, in
`commands\` and `ui\`. `clear_bottom_line` prints spaces, which show only the background, so the
order drew the same pixels.

Fixed on 2026-11-27: the 38 pairs are `CALL start_bottom_message` (`ui\screen.bm`), which sets
the color and clears the line. No recorded screen changed. Left as they are: the messages
themselves. Most are `PRINT` lists with numbers, and building them as strings would change the
spaces around the numbers.

#### 29. The right panel's text column is a bare 68 (priority: low)

24 places in `ui\` placed the right panel's text at column 68, beside `PANEL_COL = 67` in
`cws.bi`: `LOCATE row, 68`, `col = 68` in `ui\battle.bm`, and `menu_col = 68` in
`menu_city_select`.

Fixed on 2026-11-27: they read `PANEL_TEXT_COL`, a new constant of 68 in `cws.bi`. No recorded
screen changed. Left as it is: `LOCATE row, 68` in the army report (`ui\reports.bm`), a column of
the report and not of the panel.
