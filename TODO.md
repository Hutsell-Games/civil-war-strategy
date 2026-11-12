# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

## The tests

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
- **Vary Start has a loop that never runs**: `FOR k = 21 TO 6` (`vary_start_conditions`, `rules\setup.bm`). The loop before
  it clears some of the Union's first six armies; this one was probably meant for the Rebels' (21 to 26).
- **Casualties are counted for the wrong side when Union armies 3 to 20 attack.** `battle_apply_losses`
  (`rules\battle.bm`) has `s = 1: IF attacker > 2 THEN s = 2`, most likely meant as `attacker > 20`. Phase 3
  of `docs\modernize-plan.md` left this line as it is, without `army_side`: the FUNCTION would fix the bug,
  which changes the game (`TestBattleCasualtiesByArmyNumber` in `tests\rules_test.bas`).
- **A battle takes a day of supply from armies 1 and 2, not from the armies that fight.** `battle_fight`
  (`rules\battle.bm`) has `FOR i = 1 TO 2: IF army_supply(i) > 0 THEN army_supply(i) = army_supply(i) - 1`
  (`TestBattleFightTakesSupplyFromOneAndTwo`). It was most likely meant for the attacker and the defender.
- **The Balance setting's extra recruits are never added.** `army_recruit_bonus` (`rules\army.bm`) adds
  men to a new army just before `army_raise` sets its size, and to army 0 when men join an army
  (`army_add_recruits` passes 0, as `army_recruit` passed `empty`, which was 0 there). It was most likely
  meant for the army recruited.
- **The computer checks the wrong city's track before a train to its capital.** `ai_railroad` (`ai\ai.bm`)
  calls `railroad_route_count(side, target)` with `target` left from the loop before, not the capital.
- **The winner of a battle gets none of the loser's supplies.** `turn_army_surrenders` (`rules\turn.bm`)
  sets the loser's supplies to 0 and then adds them to the winner's.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.

## The code

Left alone by phase 3, group 1, of `docs\modernize-plan.md` (the sides and limits). None of these changes
how the game plays.

- **The 40 leaders have no constant.** `leader_name$()` and `leader_rating()` hold 40 leaders. Their loops
  (`port\files.bm` line 8, Vary Start in `rules\setup.bm` line 39) and their `DIM` keep the number 40.
  `docs\constants.md` has no row for them; a `MAX_LEADERS` would be a new name to agree.
- **`draw_surrender (side)` is passed an army, not a side** (`game\victory_screens.bm`, called from
  `turn_resolve`). Its test now reads `army_side(side)`. The parameter wants the name `army`.
- **The city report lists cities 1 to 20 and 21 to 40 in two columns** (`ui\reports.bm` lines 141 and 146).
  The numbers are the screen layout, so they stay. If another war has a different count of cities, the
  report needs laying out again.
- **Vary Start gives each fleet `10 * RND` ships** (`rules\setup.bm` lines 28 and 29). That is a random
  size, not the fleet limit, so it stays 10 rather than `MAX_FLEET_SHIPS`.

Left alone by group 2 (the special values):

- **`fleet_city() = 0`, "the side has no fleet", has no constant.** It appears in 18 tests and assignments.
  `docs\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 302). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **`menu_select` treats a start above 42 as row 1**: `IF menu_choice > 21` (`ui\menu.bm` line 64) runs
  after `MENU_START` is taken off. The 21 there is the menu's 21 rows (`menu_text$(21)`), not
  `MENU_START`, so it stays.
- **The Utility menu calls `menu_select(-1)`** (`CWSTRAT.BAS` line 331). No mode has that number, so it is a
  plain menu without the F3, F4 and F7 keys. `docs\constants.md` has no row for it, so it keeps the -1
  (left alone by group 4). A `MENU_NO_KEYS` would be a new name to agree.
- **`animate_army`'s parameter `background_saved` is misnamed** (`draw\icons.bm`). The `GET` it skips takes
  the army's flag picture from its city, not the background; `ANIMATE_PICTURE_TAKEN` says so (group 5).
  The parameter wants the name `picture_taken`.
- **Tests of `army_order()` and `menu_choice` by sign keep their numbers** (`> 0`, `< 0`, `< 1`); see
  `docs\constants.md`, section 2.

Left alone by group 6 (the settings and victory rules):

- **The Realism switch is `opt_realism = 1 - opt_realism`** (`CWSTRAT.BAS` line 492). It toggles between
  off and on, but from `REALISM_HIGH` (2) it gives -1. Written with names it would read
  `REALISM_ON - opt_realism`, which hides that, so the numbers stay.
- **The rule that ended the game has no constants**: `j = 2: GOTO finis` to `j = 6` in
  `check_victory_conditions` (`rules\victory.bm`), and 7 for the other ending. The numbers follow
  `VICTORY_YEAR` to `VICTORY_FORCE_RATIO`, but `j` is a code of its own; `docs\constants.md` has no row for it.
- **The loops over the victory rules keep their numbers**: `FOR i = 1 TO 6` when the rules are read
  (`port\files.bm` line 15) and `FOR i = 2 TO 6` in `menu_victory_conditions` (`ui\reports.bm` line 28), which
  also maps a rule to a menu row (`i - 1`).

Left alone by group 7 (the rule numbers):

- **`total_income = union_income_bonus + 200`** (`load_cities`, `port\files.bm` line 39), where the cities are read. The 200
  may be the two capitals' income (`2 * CAPITAL_INCOME`), but nothing says so, and the main loop works
  `total_income` out again from the sides' income. It stays a number.
- **The Emancipation Proclamation comes after 1862** (`turn_year > 1862`, `game\events.bm` line 93). That is
  the date of an event, not `IRONCLAD_YEAR`, so it stays; phase 11 moves the events' dates to data.
- **`ai_turn` compares `side_cash` with no index**: `side_cash < 222` (`ai_fortify`, `ai\ai.bm` line 59). Every other use
  is `side_cash(who)`. Check what the two compilers make of it before the line is touched.

Left alone by group 8 (the colors):

- **A side's color is set as a number in a variable**, as in `c = 9: IF city_owner(i) = SIDE_REBEL THEN c = 7`
  and then `COLOR c` or `LINE ..., c`. The table names colors in `COLOR` statements and the menu's variables
  only, so these stay. A `side_color(side)` FUNCTION would be the next step.
- **`COLOR 16 - c` shows the other side's color** (`rules\battle.bm` lines 39, 65 and 167): 16 - 9 is 7 and
  16 - 7 is 9. It stays as written; it would go with `side_color`.
- **`CALL wait_seconds(99)`, "press a key", stays a number** (`CWSTRAT.BAS` line 507, Chk Links;
  `rules\turn.bm` line 143, "There are still defenders"; left alone by group 9). It goes with phase 7's
  `wait_key`, which replaces the 12 loops that announce a wait and read a key. Outside a script, a 99-second
  pause ends by itself; those loops do not, so `wait_key` must keep the difference or decide it.
- **`IF menu_color = 0 THEN menu_color = COLOR_GRAY`** (`ui\menu.bm` line 56): 0 there means "no color set",
  not black, so the test keeps its 0.
