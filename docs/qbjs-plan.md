# Plan: run Civil War Strategy in a browser with QBJS

Written 2026-11-16. What is done (steps 0 to 11, the start of step 12, and the progress record to
2026-11-17) is in [archived/qbjs-plan-completed.md](archived/qbjs-plan-completed.md). The work list
that was `qbjs-steps.md` was merged into this file on 2026-11-17.

## Goal

The game runs in a web browser, built by QBJS, from the same source that QB64pe and QB64Rust build.
The game's rules play the same as in the native build.

The way there is to extend QBJS, not to rewrite the game for it (user, 2026-11-16; QB64Rust's
`docs\DECISIONS.md`). The work is done in our fork, `..\qbjs` (`davidshq-contribute/qbjs`), on branches,
and offered to upstream (`boxgaming/qbjs`). Pushing and opening pull requests wait for the user.

## How the work is done

Where the work happens:

- The fork is `..\qbjs`. Each step goes on a branch of its own (named in the step), so that each can
  be its own pull request upstream.
- A branch started while another is not committed yet goes in a git worktree, `..\qbjs-wt\<name>`, made
  from the last committed branch. `test\headless\run.js` runs there with `NODE_PATH` set to the
  `node_modules` of `..\qbjs\test\headless`.
- The game is on its branch `qbjs-web`.
- Claude stages and commits nothing (QB64Rust's `CLAUDE.md`, human rule 1). Before a new fork
  branch starts, the user commits the work before it.

How every step is checked:

- **A small program** for the feature, run with `node tests\web\run_qbjs.js <program.bas> --shot <png>`
  from the game's folder. Look at the screenshot; read the page's errors.
- **A test in QBJS's own suite** (`test\qb-lang.bas`, `test\qb-file.bas` or `test\qb-graphics.bas`),
  sent upstream with the change. Run the whole suite with `node run.js` in the fork's
  `test\headless\` (`npm install` there first); it prints `PASS: 12 of 12 test modules completed`
  when every module passes.
- **The game's build**: `node ..\qbjs\qbc.js cws.bas <out>\program.js`, then
  `node --check <out>\program.js`. QBJS's own messages miss some broken output (the `CIRCLE` bug of
  2026-11-16 was found only by `node --check`).
- **After a change to `tools\qb2js.bas`**, rebuild the compiler twice:
  `node qbc.js tools/qb2js.bas qb2js.js`, two times. The second build must be byte-identical to the
  first, and `git diff qb2js.js` must show only the code that changed. A hunk of spacing alone is a
  bug in the change: fix it in `tools\qb2js.bas`, never in `qb2js.js` (user, 2026-11-16).
- `qb.js`, `vfs.js` and `qb-console.js` are hand-written sources. Keep QBJS's style: its indentation,
  its naming (`this.sub_X`, `this.func_X`, `_private`), no reformatting of lines not changed.

Which model: Sonnet is enough where a wrong result shows: a page error, a wrong screenshot, a failing
test. Opus is for the steps where a mistake runs without any error and changes the game's numbers.
Those are marked **Opus**. A silent mistake shows in the autoplay check (`tests\web\autoplay.js`) as a
different last line, but finding its cause is still Opus work.

Each fix is in QBJS when QBJS differs from QB64. A fix goes in the game only when the game depends
on something no browser can give.

## Step 12: the screens of the native scripts — Opus

`node tests\web\play_qbjs.js` plays the 41 scripts of `tests\scripts` in the QBJS build, as `play.py`
plays them natively (what it checks is at the top of the file). All 41 pass in QB64Rust's suites VM,
and autoplay seeds 1 to 100 match the native results (the archive's progress record, 2026-11-17).
On 2026-11-18, with `fix/line-pixels` and `fix/screen-same-mode`, 37 passed in the VM; the other four
pass alone. Under load in the VM a page can stop answering, so with `--jobs` above 1 the runner now
plays a failed script once more, alone, at the end. The summary names the scripts that passed only
then.
Still to do:

- Look at the `report.html` of each script (`--native --jobs 4` in the suites VM, with QB64Rust's
  `tools\winvm\game.ps1`; the command is at the top of `play_qbjs.js`). A screen that differs is a
  drawing bug.
- Fix in QBJS what the screens show. Known from `navy` (shown by small programs in
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
  3. `POINT(x, y)` in `SCREEN 12` gives a 32-bit color (4278233088), where QB gives the palette
     number (2). The game does not use this form; QBJS's tests should cover it.
  4. The mountains (`_PUTIMAGE` of `MTN.PNG`) look different. Not looked at yet.
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
  6. The bar under "VP" at the top right: native draws blue, then white to x=630; QBJS draws the blue
     shorter and no white (`pass-union-1861`, July 1862). Not looked at yet.
- Not run yet: the autoplay check of the one-player games (`--mode one`) and of the alternate map.

## Step 13: listen, and press keys in a real browser — the user

What the scripts cannot show. With `node tests\web\serve.js`: the music and sounds (`PLAY`, `SOUND`,
with noise 2 in Options), and F3, F4, F7, PgUp and PgDn in a real Chrome window, where the browser
may take F3 (find) and F7 (caret browsing) first. Also the speed of a computer's turn, and whether
saves, `CWS.CFG` and `HISCORE.CWS` are still there after the page is loaded again (`QB.persistFiles`,
below). Each problem becomes a step here.

## Step 14: upstream — Sonnet drafts, the user posts

- An issue first: the by-reference option, `DEFINT`, the rounding setting, the booleans setting
  (`--qb-booleans`) and the lines setting (`--qb-lines`), each with a small program that shows the
  difference today. One switch for all of QB's numeric semantics may suit upstream better than three;
  the issue can ask.
- Then the pull requests, the certain ones first: the five fixes already made (branch
  `fix/const-string-suffix`, to split into one branch each), step 1, steps 3 and 4, step 8, and the
  integer fixes of 10, and the drawing fixes of 12. Also the three branches of 2026-11-17:
  `fix/file-number-input`, `feature/view-offset-clip`, and the precedence and `READ` parts of
  `fix/mod-read-rounding`. Then 5, 6, 7 and 11 (`QB.persistFiles`) once the issue has an answer, with
  the rounding of `MOD`'s operands, which follows the rounding setting of 6, and `fix/boolean-store`:
  a comparison stored in an integer gives -1 only with the booleans setting, 1 as before without it.
- Behavior that changes for existing QBJS programs, to name in each pull request (checked against
  upstream's compiler, 2026-11-17): `DEFINT` was ignored with a warning (`DEFINT A-Z: x = 7 / 2` gave
  3.5); `10 MOD 3 * 2` was 2; `INPUT #` read a whole line per statement; `CLS` and `VIEW` now reset
  `DRAW`'s angle and scale; `SCREEN` with the mode in use no longer clears the screen or resets
  anything.
- Each pull request: what was wrong, the small program, the test added, and the rebuilt `qb2js.js`.
- QBJS has one maintainer and no contribution guide, so the answer may take time. The game does not
  wait for it: it builds from the fork.

## Progress

When a step is done, record what it did here, then move the record and the step to the archive.

Found while building, not fixed:

- Without `--qb-booleans`, `NOT` of a comparison is wrong. `NOT (a < b OR b > c)` gives -2, which is
  true, and `NOT x > y` applies `~` to `x` alone. With the switch both match QB64pe (checked
  2026-11-17). This is for the upstream issue, as a reason for the booleans setting. QBJS's compiler
  is built without the switch, so its own source avoids `Not` of joined comparisons.
- `WINDOW` inside a `VIEW` port still maps to the whole screen; QB maps it to the port. A graphics
  `PUT` that reaches outside the port is drawn there; QB64 gives an error.
- `PRESET` draws nothing: it only moves the graphics cursor (`sub_PReset` in `qb.js`).
- QBJS splits a number such as `1E+1` into `1E + 1`, which is invalid JavaScript. A statement call
  whose argument holds `=` (`UT.AssertTrue 9 MOD 3 = 0`) is compiled as an assignment.
- By reference: a procedure called through `@name` or from another module gets no Refs. `READ`,
  `GET #` and `SWAP` into an argument are not special.
- `QB.persistFiles`: `tests\web\serve.js` already calls it before the program starts (`--no-persist`
  turns it off). Not checked yet: the game's saves, `CWS.CFG` and Hall of Fame after a reload (step
  13). How a program asks for it (the page, or a metacommand such as `$PERSIST`) is for upstream. A
  file still open when the page closes is not saved.

**By reference rests on a scan.** Copy in, copy out differs from QB when one variable is passed in
two arguments, or when a `SHARED` variable is passed to a procedure that also uses it by name. On
2026-11-16 `alias_scan.py` found no such call that matters in the game (the archive, "Questions
for the user"). Run it again after a change to the game, before relying on the build.

## Not in this plan

- **Phones.** A bar of keys on the page and menus that take a tap (`TODO.md`, "Mouse menus"). First
  the game must run in a desktop browser.
- **A QBJS target in QB64Rust** (`qb64rust` builds the folder and warns about what QBJS cannot run).
  That is QB64Rust's work (its `docs\SOMEDAY.md`, the QBJS web build row).
- **The WebAssembly target** of QB64Rust's `study\51`. It runs the game with no change and no fork,
  and is a different piece of work. This plan does not replace it.
