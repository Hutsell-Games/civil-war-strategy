# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

## The tests

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

- **Load stays "-" after a game's first save.** The Files menu sets `filel` to 0 when it finds no saved game,
  and only a new game sets it back. A player who saves for the first time cannot load in the same game.
- **Resume Saved Game with no saved game shows the main menu on a black screen.** The map is not drawn until
  F3 or a menu draws it.
- **`gaussian_random_number` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so
  every draw centers on `xbar + SQR(vary) / 2` (`TestGaussianDrawsHigh` in `tests\rules_test.bas`), as in World
  War 2 and Civil War Battleset. A fix changes the battles, so every script would need `record` again.
- **`traincapacity` counts cities from the player's side, not from the side it is asked about**
  (`TestTraincapacityCountsByPlayersSide`): it uses `side` where the rest of the SUB uses `who`.
- **`ai_turn` never stops at an empty slot of `matrix`** when the computer weighs its capital's neighbors
  (`computer.bm`). Inside `FOR j = 1 TO 6`, `IF j = 0 GOTO nocap` can never be true. It was probably meant to
  be `k = 0`, where `k = matrix(target, j)`. A fix changes how the computer plays.
- **The computer judges a Rebel landing by the Union fleet's city** (`navy.bm` line 44). The Rebels' "Invasion"
  line calls `enemy_strength_near(navyloc(1))`, where the Union's line above it has `navyloc(1)` rightly. It
  was probably meant to be `navyloc(who)`. Only the computer reads the result, and only without realism. A
  fix changes how the computer plays.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.
