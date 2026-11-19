# Done: the plan to run Civil War Strategy in a browser with QBJS

The completed parts of [../qbjs-plan.md](../qbjs-plan.md), moved here on 2026-11-17: steps 0 to 3a,
the autoplay check of step 4, the progress record to 2026-11-17, the effort estimate, and the
answered questions with the panel. Step 12 was moved here on 2026-11-18 and 19, as the last progress
entries. The plan keeps what is still open. "The steps file" below is
`qbjs-steps.md`, the numbered work list. Its open steps (12 to 14) were merged into the plan on
2026-11-17, and its done steps are the progress entries here.

## Step 0, done: what QBJS makes of the game today

On 2026-11-16 the game (branch `tuning-knobs` at `87c054d`) was compiled with the fork's `main` at
`1589a46`:

    node ..\qbjs\qbc.js cws.bas program.js

QBJS reads all 49 include files and writes a `program.js` of 11,998 lines. It prints 130 warnings and
errors. The output is not valid JavaScript: `node --check program.js` stops at line 1357,
`if ( ship ==  ) {`, where a constant was not found.

### What QBJS reports

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

### What QBJS does not report

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

### What is not a problem

- The game has no `GOTO`, `GOSUB`, `ON ERROR`, `FIELD`, `STRING * n`, `PCOPY`, `PALETTE` or `SHELL`.
  QBJS's largest gaps do not touch it.
- Every other keyword the game uses is known to QBJS's compiler. That shows the word is accepted. It
  does not show that it behaves as in QB64: `PAINT`, `DRAW`, `PLAY`, `CIRCLE` and the `LINE` style
  patterns (`&HF0F0`) are only checked by running the game (step 4).
- `RND` in QBJS uses QB's formula (`qb.js` line 3674). With the same seed it gives the same numbers
  as the native build. Step 1 rests on this.

## Step 1: a way to check the result

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

## Step 2: the language, in QBJS

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

## Step 3: the screen, in QBJS

1. **`TAB(n)` in `PRINT`**, to the screen and to a file (`PRINT #2, TAB(20); …`, `io\files.bm` line 394).
2. **Graphics `GET` and `PUT`.** The game saves what is under a menu or a marker and puts it back
   with `PSET`. Telling the graphics form from the file form is by the opening parenthesis.
3. **`VIEW`**: the graphics viewport, with clipping and coordinates relative to its corner, and
   `VIEW` alone to end it. The game uses only these two forms.
4. **`DEF SEG`, `PEEK` and `POKE`** on a small memory of bytes. The game needs 3 bytes (`&H4F0` to
   `&H4F2`). With them the harness can see when the game waits for a key, as the native test runner
   does, and the 82 key scripts of `tests\scripts` become usable.

## Step 3a: the pictures, in the game

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

## Step 4: the autoplay check

- Run the autoplay check on seeds 1 to 100. Find and fix each difference.

## Progress

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

## Effort

Counted in Claude's sessions: step 1 one, step 2 two to three, step 3 two, step 4 one to three,
depending on what playing shows. About 6 to 9 in all. The user's time:
playing the game in step 4, and posting upstream.

## Questions for the user

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

### The panel

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
