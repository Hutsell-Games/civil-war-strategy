# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

## The tests

- **The real `SHELL "copy ..."`.** Under a script, `script_shell` (`port\script.bm`) copies in BASIC, because a
  `SHELL` opens a console window on the user's desktop. A test of the real one must run where a window does no
  harm: in QB64Rust's suites VM, or by hand.
- **A game that reaches March 1865 with the computer active.** The generated games end sooner, because a
  player who only ends turns is beaten in 1 to 20 turns. `union-time` and `two-player` reach the time limit
  with a passive computer or none.
- **Linux.** The game opens lower-case names of upper-case files (`"cities.grd"`, `"cws.cfg"`),
  and copies its history with `SHELL "copy ..."`, a Windows command. Then `play.py` would need its Linux
  branches checked, as for World War 2.

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how a
game plays changes the recorded screens.

Ruled on 2026-11-13 (user): the other 22 bugs of this list, and the `SELECT CASE` branches that were never
reached (`docs\sub-names.md`, "Found while reading"), were fixed in one batch. The pictures,
`normal_random_number` and the train's pixels below are kept. Of four rows found afterward, three were
settled on 2026-11-13 (user); the computer's fleet that "thinks of sailing" is kept. What each fix did
is in `docs\modernize-completed.md`, "The kept bugs fixed" and "Three more".

- **The title screen, the burning capital and Lincoln's picture are not shown** (`docs\devnotes.md`, item 5).
  The pictures are in `docs\`. The game could load and show them, as World War 2's `TODO.md` also notes for
  its title.
- **`normal_random_number` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers
  on `mean + SQR(variance) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2 and Civil War
  Battleset. A fix changes the battles, so every script would need `record` again.
- **The computer's fleet "thinks of sailing" and attacks all the same.** `ai_navy_attack`
  (`ai\ai.bm`) sets `action = NAVY_SAIL` off a city with an army, with a chance of 1 in 2, and then
  bombards the city anyway when it is the enemy's. The change of order does not stop this attack.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.

## Improvements

Ideas that the original game did not have. Each one changes how the game plays, looks or sounds, or where
it keeps its files, so each needs its own decision and its scripts recorded again.

- **Records for the armies.** Phase 10 closed with no records (`docs\modernize-plan.md`, "Phase 10:
  records"). Join copies some of an army's fields and four places clear a slot, each clearing different fields.
  If those clears and copies were made the same, an `armies(i)` record with one copy and one clear would be
  simpler code, not only a new spelling. Making them the same changes how the game plays.
- **Mouse menus.** The menus read only keys (`menu_select`, `ui\menu.bm`). `_MOUSEINPUT` could let a player
  click a row.
- **Music that stops as soon as a key is pressed.** The tunes in `game\tunes.bm` check `INKEY$` only between
  `PLAY` phrases, so a key stops the music at the end of a phrase. With `PLAY "MB"` the music plays in the
  background, as one victory tune already does (`game\victory_screens.bm`).
- **PNG pictures in place of the `.vga` files.** `load_picture` (`draw\pictures.bm`) loads the pictures with
  `DEF SEG` and `BLOAD`. They could be PNG files loaded with `_LOADIMAGE`, as the three pictures in `docs\`
  would be.
- **One known folder for saves and settings.** `cws1.sav` to `cws9.sav`, `cws.cfg`, `hiscore.cws`, `cws.his`
  and `battsumm` are opened in the current folder (`port\files.bm`), so they land wherever the game was
  started from. A single folder, for example beside the program, would keep them together.

## The code

Left alone by phase 3, group 1, of `docs\modernize-plan.md` (the sides and limits). None of these changes
how the game plays.

- **The city report lists cities 1 to 20 and 21 to 40 in two columns** (`ui\reports.bm` lines 142 and 147).
  The numbers are the screen layout, so they stay. If another war has a different count of cities, the
  report needs laying out again.
- **Vary Start gives each fleet `10 * RND` ships** (`rules\setup.bm` lines 28 and 29). That is a random
  size, not the fleet limit, so it stays 10 rather than `MAX_FLEET_SHIPS`.
- **`turn_collect_income` clears the armies' orders in its loop over the cities** (`rules\turn.bm`):
  `FOR i = 1 TO MAX_CITIES` sets `army_order(i)` too. It works only because `MAX_CITIES` and
  `MAX_ARMIES` are both 40. A war with other limits needs a loop of its own over `MAX_ARMIES`.

Left alone by group 2 (the special values):

- **`fleet_city() = 0`, "the side has no fleet", has no constant.** Its tests read `fleet_exists(side)`
  since 2026-11-13 (`docs\structure-review.md`, item 2); 7 assignments of 0 are left.
  `docs\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 195). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **`menu_select` treats a start above 42 as row 1**: `IF menu_choice > 21` (`ui\menu.bm` line 64) runs
  after `MENU_START` is taken off. The 21 there is the menu's 21 rows (`menu_text$(21)`), not
  `MENU_START`, so it stays.
- **The Utility menu calls `menu_select(-1)`** (`menu_utility`, `ui\options.bm` line 31). No mode has that number, so it is a
  plain menu without the F3, F4 and F7 keys. `docs\constants.md` has no row for it, so it keeps the -1
  (left alone by group 4). A `MENU_NO_KEYS` would be a new name to agree.
- **`animate_army`'s parameter `background_saved` is misnamed** (`draw\icons.bm`). The `GET` it skips takes
  the army's flag picture from its city, not the background; `ANIMATE_PICTURE_TAKEN` says so (group 5).
  The parameter wants the name `picture_taken`.
- **Tests of `menu_choice` by sign keep their numbers** (`> 0`, `< 0`, `< 1`); see
  `docs\constants.md`, section 2. Those of `army_order()` read `army_has_move` and `army_has_acted`
  since 2026-11-13.

Left alone by group 6 (the settings and victory rules):

- **The Realism switch is `opt_realism = 1 - opt_realism`** (`option_toggle_realism`, `rules\setup.bm`). It toggles between
  off and on, but from `REALISM_HIGH` (2) it gives -1. Written with names it would read
  `REALISM_ON - opt_realism`, which hides that, so the numbers stay.
- **The loops over the victory rules keep their numbers**: `FOR i = 1 TO 6` when the rules are read
  (`port\files.bm` line 17) and `FOR i = 2 TO 6` in `menu_victory_conditions` (`ui\reports.bm` line 28), which
  also maps a rule to a menu row (`i - 1`).

Left alone by group 7 (the rule numbers):

- **`total_income = union_income_bonus + 200`** (`load_cities`, `port\files.bm` line 49), where the cities are read. The 200
  may be the two capitals' income (`2 * CAPITAL_INCOME`), but nothing says so, and the main loop works
  `total_income` out again from the sides' income. It stays a number.
- **The Emancipation Proclamation comes after 1862** (`year above 1862`, `[emancipation]` in
  `scenarios\EVENTS.DAT`). That is the date of an event, not `IRONCLAD_YEAR`; phase 11 moved the
  events' dates to data (2026-11-13).
- **`ai_fortify` compares `side_cash` with no index**: `side_cash < 222` (`ai\ai.bm` line 30). Every other use
  is `side_cash(who)`. Here `side_cash` is a local scalar, declared so that `OPTION _EXPLICIT` accepts it,
  and it is always 0, as the original's undeclared `cash` was. So the test is always true.

Left alone by group 8 (the colors):

- **A side's color is set as a number in a variable**, as in `c = 9: IF city_owner(i) = SIDE_REBEL THEN c = 7`
  and then `COLOR c` or `LINE ..., c`. The table names colors in `COLOR` statements and the menu's variables
  only, so these stay. A `side_color(side)` FUNCTION would be the next step.
- **`COLOR 16 - c` shows the other side's color** (`ui\battle.bm` lines 27, 35 and 81): 16 - 9 is 7 and
  16 - 7 is 9. It stays as written; it would go with `side_color`.
- **`CALL wait_seconds(99)`, "press a key", stays a number** (`ui\options.bm` line 56, Chk Links;
  `ui\turn.bm` line 134, "There are still defenders"; left alone by group 9). It goes with phase 7's
  `wait_key`, which replaces the 12 loops that announce a wait and read a key. Outside a script, a 99-second
  pause ends by itself; those loops do not, so `wait_key` must keep the difference or decide it.
- **`IF menu_color = 0 THEN menu_color = COLOR_GRAY`** (`ui\menu.bm` line 56): 0 there means "no color set",
  not black, so the test keeps its 0.
