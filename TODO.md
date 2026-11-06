# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is QB64Rust's
`study\46-civil-war-strategy-port.md`.

## The tests

- **The boss screen** (`scrnsavr`, 89 statements) starts and ends only with Ctrl+B, which a keys file cannot
  give. It also runs `RANDOMIZE TIMER`, so a script that reached it would not play the same game twice.
- **The title music.** It plays only when the game starts with `noise` 2, before the hooks make the game
  silent. So the tune in `CWSTRAT.BAS` and `shen` (the Rebels' tune) are not run by any test.
- **The real `SHELL "copy ..."`.** Under a script, `scriptshell` (`SCRIPT.BM`) copies in BASIC, because a
  `SHELL` opens a console window on the user's desktop. A test of the real one must run where a window does no
  harm: in QB64Rust's suites VM, or by hand.
- **`ALTMAP.BAT` itself.** The scripts on the alternate map switch the files in `play.py`, not with the batch
  file.
- **A game that reaches March 1865 with the computer active.** The generated games end sooner, because a
  player who only ends turns is beaten in 1 to 21 turns. `union-time` and `two-player` reach the time limit
  with a passive computer or none.
- **Linux.** The game opens lower-case names of upper-case files (`'cws14.bi'`, `"cities.grd"`, `"cws.cfg"`),
  and copies its history with `SHELL "copy ..."`, a Windows command. Then `play.py` would need its Linux
  branches checked, as for World War 2.

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how a
game plays changes the recorded screens.

- **The F1 help pager, next** (decided 2026-11-06, QB64Rust's `study\46` D3). "F1 = HELP" still shows at the
  top right, though F1 no longer shows the help (`docs\devnotes.md`, item 6). Write a pager that shows
  `docs\CWSDOC.TXT` in the game, its four pages chosen by F1 to F4, as `CWSDOC.COM` did, with a script for it.
- **The title screen, the burning capital and Lincoln's picture are not shown** (`docs\devnotes.md`, item 5).
  The pictures are in `docs\`. The game could load and show them, as World War 2's `TODO.md` also notes for
  its title.
- **Load stays "-" after a game's first save.** The Files menu sets `filel` to 0 when it finds no saved game,
  and only a new game sets it back. A player who saves for the first time cannot load in the same game.
- **Resume Saved Game with no saved game shows the main menu on a black screen.** The map is not drawn until
  F3 or a menu draws it.
- **`normal` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers
  on `xbar + SQR(vary) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2 and Civil War
  Battleset. A fix changes the battles, so every script would need `record` again.
- **`traincapacity` counts cities from the player's side, not from the side it is asked about**
  (`TestTraincapacityCountsByPlayersSide`): it uses `side` where the rest of the SUB uses `who`.
- **Vary Start has a loop that never runs**: `FOR k = 21 TO 6` (`CWSTRAT.BAS`, Utility menu). The loop before
  it clears some of the Union's first six armies; this one was probably meant for the Rebels' (21 to 26).
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.
