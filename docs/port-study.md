# 46. Porting Civil War Strategy to QB64Rust: what was done, and what waits for the user

> **Moved from QB64Rust on 2026-11-06.** This study was `study\46-civil-war-strategy-port.md` in QB64Rust
> (`davidshq/QB64Rust`), whose history holds its earlier versions. Paths such as `DECISIONS.md`,
> `PORTING-PDS.md`, `SOMEDAY.md`, `DIVERGENCES-QB45.md`, `CLAUDE.md`, `verification\...` and
> `tools\qb45\...` are QB64Rust's.
> The decisions it led to were rows of QB64Rust's `DECISIONS.md`. They are copied in the
> section "Decisions recorded in QB64Rust".

> A bare `study\44`, `study\45` or `study\46` names one of the three moved studies:
>
> - `study\44` is Civil War Battleset's `docs\port-study.md` (`Hutsell-Games/civil-war-battleset`, branch
>   `qb64rust`);
> - `study\45` is Wars of Napoleon's `docs\won-source-study.md` (`Hutsell-Games/wars-of-napoleon`, branch
>   `won-source`);
> - `study\46` is Civil War Strategy's `docs\port-study.md` (`Hutsell-Games/civil-war-strategy`, branch
>   `qb64rust`).

Written 2026-11-06. The user asked for the port the same day: "port Civil War Strategy from canonical-source on a
qb64rust branch, use the processes we have established for civil war battleset and world-war-2 and in QB64Rust"
(`DECISIONS.md` 2026-11-06). The user was away while it was done. So this study is not a plan to approve first,
as `study\44` was. It says what was built, and section 4 lists the choices Claude made, each with the panel's
view, for the user to rule on. The user answered them the same day, taking every recommendation. Later that
day the user changed D3: F1 and its label are removed, and no pager is built. The port is committed. The study
stays open while D8's question, whether `qb64rust` replaces the game's `main`, has no answer (`CLAUDE.md`
working rule 7).

The game is W.R. Hutsell's *Civil War Strategy* 1.57 (`Hutsell-Games/civil-war-strategy`), cloned beside this
repo as `..\civil-war-strategy`. The port is on its new branch `qb64rust`, made from `origin/canonical-source`.
Nothing there is committed or staged by Claude, except the renames that `git mv` stages (`CLAUDE.md` rule 1).

## 1. The game, and how it differs from the two earlier ports

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

## 2. What was done

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

## 3. What the port found

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

**The game's own oddities**, each a row of the game's `TODO.md` and none changed but the third: Load stays "-"
after a game's first save; Resume Saved Game with no saved game shows the main menu on a black screen;
`FOR k = 21 TO 6` in Vary Start never runs (made `21 TO 26` on 2026-11-11, `devnotes.md` item 13);
`traincapacity` reads `side` where it means `who`; `normal` draws high, as in the other two games.

## 4. Choices made, for the user to rule on

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

**User, later on 2026-11-06: (c).** "I don't think it's needed, folks can look at the doc if they want
instructions." This came after Claude found that `CWSDOC.TXT` has four topics, not four pages. Its Getting
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

**D8. The workflow's trigger, and what `main` becomes.** `build.yml` builds on each merge into `main`, as the
other two ports do. Here `main` is the 2024 port, not the original. So the workflow runs only once `qb64rust`
is merged into `main`, which would replace the 2024 port.
- (a) As built: leave the trigger. The user decides later whether `qb64rust` replaces `main`.
- (b) Also build on each push to `qb64rust`.

*Panel:* the pragmatic engineer wants (a): which branch is the game's future is the user's call, and (b) spends
CI time on every push. The QB64 user would like one answer for all three games. **Recommended: (a).** The
question behind it, whether `qb64rust` replaces `main` here, is put to the user and not answered by this
study.

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

## 5. What is left

1. **Done:** the port is committed in `..\civil-war-strategy` (`1cff8db`) and recorded here (`540aacb0`).
2. **Done, not yet committed:** F1 and its label are removed (D3, changed to (c)), and the 25 scripts are
   recorded again.
3. **Open:** D8's question, whether `qb64rust` replaces the game's `main`.

Not done, and not planned: any refactoring, reformatting, or fix to how the game plays.

## Decisions recorded in QB64Rust

Copied from QB64Rust's `docs\DECISIONS.md` when the study moved here (2026-11-06). The rows are no longer
kept there.

| Date | Decision | Where the details are |
|---|---|---|
| 2026-11-06 | **Civil War Strategy is ported to QB64Rust from its branch `canonical-source`, on a new branch `qb64rust`, by the process of the two earlier ports** (user: "port Civil War Strategy from canonical-source on a qb64rust branch, use the processes we have established for civil war battleset and world-war-2 and in QB64Rust"). The game's `main`, a port of 2024 for QB64pe, is not built on; four graphics lines and the help text are taken from it. The port was done in one session while the user was away, so its ten choices (D1 to D10) were made by Claude; the user took every recommendation the same day (F1's help pager comes next, as its own change; whether `qb64rust` replaces the game's `main` stays open): the graphics lines, the DOS pictures and the help kept in `docs\`, `ALTMAP.BAT` kept, the generated games, the workflow's trigger, the 14 DOS-only files left for the user to remove. What it measured about QB 4.5 and PDS 7.1 is `DIVERGENCES-QB45.md` Q-019 and Q-020 | `study\46`; the game's `docs\devnotes.md` and `tests\README.md`; `PORTING-PDS.md` sections 3 to 5 |
| 2026-11-06 | **Civil War Strategy drops F1 help instead of getting a pager** (user: "Lets remove it from the game, I don't think its needed, folks can look at the doc if they want instructions"). This changes `study\46` D3 from (b) to (c). F1's branch in `menu` and the "F1 = HELP" label in `topbar` are removed, as the game's `main` did. F1 at a menu is now ignored. Players read `docs\CWSDOC.TXT` or the manual `docs\CWS.DOC`. All 25 scripts were recorded again, and QB64pe and QB64Rust gave the same screens | `study\46` D3; the game's `docs\devnotes.md` item 6 |
