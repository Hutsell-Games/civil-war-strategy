# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\modernize-plan.md`.

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
reached (`docs\archived\sub-names.md`, "Found while reading"), were fixed in one batch. The pictures,
`normal_random_number` and the train's pixels below are kept. Of four rows found afterward, three were
settled on 2026-11-13 (user); the computer's fleet that "thinks of sailing" is kept. What each fix did
is in `docs\archived\modernize-plan-completed.md`, "The kept bugs fixed" and "Three more".

- **The title screen, the burning capital and Lincoln's picture are not shown** (`docs\devnotes.md`, item 5).
  The pictures are in `docs\`. The game could load and show them, as World War 2's `TODO.md` also notes for
  its title.
- **`normal_random_number` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers
  on `mean + SQR(variance) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2 and Civil War
  Battleset. A fix changes the battles, so every script would need `record` again.
- **The computer's fleet "thinks of sailing" and attacks all the same.** `ai_navy_attack`
  (`ai\navy.bm`) sets `action = NAVY_SAIL` off a city with an army, with a chance of 1 in 2, and then
  bombards the city anyway when it is the enemy's. The change of order does not stop this attack.
- **The computer counts a fort of 2 as no fort** when it weighs an attack (`ai_attack_score`, `ai\army.bm`
  lines 262 to 267). The original's `x1 = 1: IF fort(a) = 1 THEN x1 = 2: IF fort(a) = 3 THEN x1 = 3` is
  one `IF` line, so the second test runs only when the fort is 1. A fort of 0 gives 1, of 1 gives 2, and of
  2 gives 1 again; a fort is never 3 (`MAX_FORT` is 2). It most likely meant the fort plus 1.
- **The Union's computer skips fortifying half the time when it has no fleet** (`ai_fortify`, `ai\forces.bm`
  line 44): `... AND RND > .5 AND side_cash < 222 THEN EXIT SUB`. `side_cash` there is a local scalar,
  declared so that `OPTION _EXPLICIT` accepts it, and it is always 0, as the original's undeclared `cash`
  was. So the cash test is always true. It most likely meant `side_cash(side) < 222`.
- **The computer's bonus for a road toward the enemy's capital compares an owner with a city**
  (`ai_beyond_score`, `ai\army.bm`): `IF city_owner(far_city) = side_capital(enemy_side)`. An
  owner is 0 to 2, and no capital is city 1 or 2, so the 50 goes to no city while the enemy
  holds its capital. Once the capital falls, `side_capital` is 0, and every neutral city one
  road beyond gets the 50. It most likely meant `far_city = side_capital(enemy_side)`. The
  original did the same (`CWSTRAT2.BM` line 381, `IF cityp(m) = capcity(side) THEN y = y + 50`).
  Found 2026-11-14. `TestAiBeyondScore`
  holds it.
- **A letter in the city picker never reaches one city** (`side_city_by_letter`, `rules\city.bm`).
  When the side does not hold the first city with that letter, the search goes on through the next
  38 cities, as the original's 39 tries did. The 40th, the city just before the first, is never
  looked at. When it is the only city the side holds, the picker stays where it was. It most likely meant
  `MAX_CITIES - 1` steps. Found 2026-11-14. `TestSideCityByLetter` holds it.
- **The army report counts the capitals' income twice** (`report_armies`, `ui\reports.bm`). Its line
  "income / all income" adds 100 for each capital to `total_income`, which `turn_collect_income` has
  already counted them in. The original did the same (`CWSTRAT2.BAS` line 811, with `vptotal` from
  `CWSTRAT.BAS` line 169). Found 2026-11-13. A fix changes the report's screen in the scripts that
  show it.
- **Realism on gives a Rebel player's event balance of 1 two more, and Realism off does not take them back**
  (`option_toggle_realism`, `rules\setup.bm`). The original did the same (`CWSTRAT.BAS` line 628). No menu
  sets 1 (the Random Events menu sets 0, 3, 5 or 7), so only a `CWS.CFG` written by hand reaches it. Taking
  2 off when Realism goes off would also change a 3 set in the menu, so a fix needs to remember the
  change. Found 2026-11-14.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.

## Improvements

Ideas that the original game did not have. Each one changes how the game plays, looks or sounds, or where
it keeps its files, so each needs its own decision and its scripts recorded again.

- **Battle odds that match the roll.** The battle screen's "Odds" is `a / (a + d)` (`battle_odds_text$`,
  `ui\battle.bm`), as in DOS. `battle_fight` (`rules\battle.bm`) rolls differently: each side hits on an
  INTEGER draw of `scale * RND` up to its strength, and a round where both or neither hit is rolled again. The
  true chance is `p(1 - q) / (p(1 - q) + q(1 - p))`, with `p = (a + .5) / scale` and `q = (d + .5) / scale`.
  The shown odds always name the right favorite but understate it, by far: 3 against 2 shows 60%, and the
  attacker wins 81%; 2 against 1 shows 66%, true 83%; 4 against 7 shows 36%, true 8% (by the formula and by
  a simulation of the roll, 2026-11-14). The manual (`docs\CWS.DOC`, section 7.3) calls the odds "A GUIDE
  ONLY", calculated "separately" from the combat, so this is as designed. Showing the true chance changes the
  screen of every battle, not the battles, and the manual's sentence would need rewording.
- **Records for the armies.** Phase 10 closed with no records (`docs\archived\modernize-plan-completed.md`, "Phase 10:
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

Left alone by phase 3, group 1, of `docs\archived\modernize-plan-completed.md` (the sides and limits). None of these changes
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
  since 2026-11-13 (`docs\archived\structure-review-completed.md`, item 2); 7 assignments of 0 are left.
  `docs\archived\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 195). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **`menu_select` treats a start above 42 as row 1**: `IF row > 21` (`menu_start_row`, `ui\menu.bm` line 184) runs
  after `MENU_START` is taken off. The 21 there is the menu's 21 rows (`menu_text$(21)`), not
  `MENU_START`, so it stays.
- **The Utility menu calls `menu_select(-1)`** (`menu_utility`, `ui\options.bm` line 31). No mode has that number, so it is a
  plain menu without the F3, F4 and F7 keys. `docs\archived\constants.md` has no row for it, so it keeps the -1
  (left alone by group 4). A `MENU_NO_KEYS` would be a new name to agree.
- **Tests of `menu_choice` by sign keep their numbers** (`> 0`, `< 0`, `< 1`); see
  `docs\archived\constants.md`, section 2. Those of `army_order()` read `army_has_move` and `army_has_acted`
  since 2026-11-13.

Left alone by group 6 (the settings and victory rules):

- **The Realism switch is `opt_realism = 1 - opt_realism`** (`option_toggle_realism`, `rules\setup.bm`). It toggles between
  off and on, but from `REALISM_HIGH` (2) it gives -1. Written with names it would read
  `REALISM_ON - opt_realism`, which hides that, so the numbers stay.
- **The loops over the victory rules keep their numbers**: `FOR i = 1 TO 6` when the rules are read
  (`port\files.bm` line 52) and `FOR i = 2 TO 6` in `menu_victory_conditions` (`ui\reports.bm` line 28), which
  also maps a rule to a menu row (`i - 1`).

Left alone by group 7 (the rule numbers):

- **`total_income = union_income_bonus + 200`** (`load_cities`, `port\files.bm` line 99), where the cities are read. The 200
  may be the two capitals' income (`2 * CAPITAL_INCOME`), but nothing says so, and the main loop works
  `total_income` out again from the sides' income. It stays a number.
- **The Emancipation Proclamation comes after 1862** (`year above 1862`, `[emancipation]` in
  `scenarios\EVENTS.DAT`). That is the date of an event, not `IRONCLAD_YEAR`; phase 11 moved the
  events' dates to data (2026-11-13).

Left alone by group 8 (the colors):

- **`COLOR 16 - side_color` shows the other side's color** (`draw_battle_defender` and `draw_battle_losses`, `ui\battle.bm`): 16 - 9
  is 7 and 16 - 7 is 9. It stays as written. `side_color_of` (`game\colors.bm`) gives the color.
- **`CALL wait_seconds(99)`, "press a key", stays a number** (`ui\options.bm` line 56, Chk Links;
  `ui\turn.bm` line 134, "There are still defenders"; left alone by group 9). It goes with phase 7's
  `wait_key`, which replaces the 12 loops that announce a wait and read a key. Outside a script, a 99-second
  pause ends by itself; those loops do not, so `wait_key` must keep the difference or decide it.
- **`IF menu_color = 0 THEN menu_color = COLOR_GRAY`** (`ui\menu.bm` line 56): 0 there means "no color set",
  not black, so the test keeps its 0.

Found while renaming the locals (`docs\archived\local-names.md`, part 4):

- **`ai_army_order`'s capital check tests the loop counter** (`ai\army.bm` lines 49 to 52):
  `IF j = 0 THEN EXIT FOR`, after `neighbor = city_road(city, j)`. `j` runs from 1, so the test is never
  true; it most likely meant `neighbor = 0`. A fix changes no play: past the last road the loop asks
  `city_nearby_enemy_strength(0)`, and city 0 has no roads, so the answer is 0.
