# Done: developer notes of the port

The finished parts of `devnotes.md`, moved here on 2026-11-13, under the same headings: the searches,
builds and measurements of the port of 2026-11-06, and what its first tests found. The notes keep how to
build and format the game, what was changed from `canonical-source`, the test hooks and the files removed.

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
module also has a label `topbar:` with a `RETURN`, which nothing calls: `CALL topbar` runs the SUB of that
name in `CWSMENU.BAS`. Both compilers accept the label beside the SUB.

### 3. Memory, `BLOAD`, `SHELL` and the clock

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

## The tests

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

