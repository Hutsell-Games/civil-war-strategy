# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

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
- **Casualties are counted for the wrong side when Union armies 3 to 20 attack.** `calculate_battle`
  (`rules\battle.bm`) has `s = 1: IF attacker > 2 THEN s = 2`, most likely meant as `attacker > 20`. Phase 3
  of `docs\modernize-plan.md` left this line as it is, without `army_side`: the FUNCTION would fix the bug,
  which changes the game.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.

## The code

Left alone by phase 3, group 1, of `docs\modernize-plan.md` (the sides and limits). None of these changes
how the game plays.

- **The 40 leaders have no constant.** `leader_name$()` and `leader_rating()` hold 40 leaders. Their loops
  (`port\files.bm` line 8, Vary Start in `CWSTRAT.BAS` line 602) and their `DIM` keep the number 40.
  `docs\constants.md` has no row for them; a `MAX_LEADERS` would be a new name to agree.
- **`draw_surrender (side)` is passed an army, not a side** (`game\victory_screens.bm`, called from
  `turn_resolve`). Its test now reads `army_side(side)`. The parameter wants the name `army`.
- **The city report lists cities 1 to 20 and 21 to 40 in two columns** (`ui\reports.bm` lines 141 and 146).
  The numbers are the screen layout, so they stay. If another war has a different count of cities, the
  report needs laying out again.
- **Vary Start gives each fleet `10 * RND` ships** (`CWSTRAT.BAS` lines 591 and 592). That is a random
  size, not the fleet limit, so it stays 10 rather than `MAX_FLEET_SHIPS`.

Left alone by group 2 (the special values):

- **`fleet_city() = 0`, "the side has no fleet", has no constant.** It appears in 18 tests and assignments.
  `docs\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 66). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **`menu_select` treats a start above 42 as row 1**: `IF menu_choice > 21` (`ui\menu.bm` line 64) runs
  after `MENU_START` is taken off. The 21 there is the menu's 21 rows (`menu_text$(21)`), not
  `MENU_START`, so it stays.
- **The Utility menu calls `menu_select(-1)`** (`CWSTRAT.BAS` line 431). No mode has that number, so it is a
  plain menu without the F3, F4 and F7 keys. `docs\constants.md` has no row for it, so it keeps the -1
  (left alone by group 4). A `MENU_NO_KEYS` would be a new name to agree.
- **Tests of `army_order()` and `menu_choice` by sign keep their numbers** (`> 0`, `< 0`, `< 1`); see
  `docs\constants.md`, section 2.
