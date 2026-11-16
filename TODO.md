# To do

Open work on the QB64 port. Remove an item when it is done. The plan is
`docs\modernize-plan.md`.

## The tests

- **A game that reaches March 1865 with the computer active.** The generated games end sooner, because a
  player who only ends turns is beaten in 1 to 20 turns. `union-time` and `two-player` reach the time limit
  with a passive computer or none.

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how a
game plays changes the recorded screens.

Ruled on 2026-11-13 (user): the other 22 bugs of this list, and the `SELECT CASE` branches that were never
reached (`docs\archived\sub-names.md`, "Found while reading"), were fixed in one batch. The pictures,
`normal_random_number` and the train's pixels below are kept. Of four rows found afterward, three were
settled on 2026-11-13 (user). The fourth, the computer's fleet that "thinks of sailing" and
attacks all the same, was kept then and fixed on 2026-11-14 (user; `docs\rule-changes.md`, G24). Three
inherited typos of the computer were fixed on 2026-11-15 (user; G25 to G27), with a fourth (G28). What each fix did
is in `docs\archived\modernize-plan-completed.md`, "The kept bugs fixed" and "Three more".

- **The title screen, the burning capital and Lincoln's picture are not shown** (`docs\devnotes.md`, item 5).
  The pictures are in `docs\`. The game could load and show them, as World War 2's `TODO.md` also notes for
  its title.
- **`normal_random_number` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers
  on `mean + SQR(variance) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2 and Civil War
  Battleset. A fix changes the battles, so every script would need `record` again.
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
- **The computer playing both sides favors the Rebels.** In 100 two-player games of the computer
  against itself (`tests\autoplay.py`, standard map, seeds 1 to 100), the Rebels won 80 and the Union 20.
  43 of the Rebels' wins came at the time limit, March 1865, a technical victory: the Union's computer did
  not win before the clock ran out. Before the fixes G25 to G28 it was 69 to 31 (`docs\rule-changes.md`).
  Found 2026-11-15. Whether people find the same is the next check (user, 2026-11-16): games played by
  hand, as each side. Possible causes to measure with autoplay: the time limit itself, the Union's
  computer being too cautious to take Richmond, and the scenario's starting forces.

Found on 2026-11-16 in a code review, by reading the code; not run. Each is in the DOS code too
(`CWSTRAT.BAS` and `CWSTRAT2.BAS` on `canonical-source`). A fix needs a row in `docs\rule-changes.md`.

- **Join can make the armies disappear** (`army_combine_add`, `rules\army.bm`). `best` is set only when an
  army's leader rating is above army 0's, which starts at 0. When every army that joins has a rating of 0,
  `best` stays 0. `army_combine_finish` then puts the troops in army 0 and leaves the city with no army.
  Relieve with a leader of rating 1 gives an army a rating of 0 (`army_take_leader`).
- **Relieve mixes up the leaders' names and ratings** (`menu_army_relieve`, `ui\army.bm`;
  `army_free_leader`). The old leader goes back to the list in the army's slot under his own name, but
  keeps that slot's rating. He then has the rating of the slot's first leader. A second Relieve of the
  same army writes over the name in that slot, and that leader is lost. Join (`army_combine_absorb`)
  frees leaders the same way.
- **Cancel can cancel another army's move** (`menu_army_cancel`, `ui\army.bm`). The menu keeps the city,
  and the army is found by `INSTR` of its name. With "Rebel II" and "Rebel III" in one city, both with
  moves, picking "Rebel II" cancels "Rebel III". Keeping the army's number in `menu_value()` would fix
  it, but `MENU_CITY_BOX` reads the city from there.
- **The computer's recruiting reads a leftover value** (`ai_recruit_pick`, `ai\forces.bm`).
  `army = 0 XOR army_size(army) < ai_reinforce_below` reads `army_size(0)` for a city with no army.
  Army 0 still holds the size of the last Join, so whether an empty city is picked depends on it. Army 0
  is not saved, so a game plays differently after a Load.
- **The time limit marks the wrong winner** (`end_game`, `ui\victory.bm`). `check_victory_conditions`
  tests the Union first, so a game that runs out of time always ends with the Union as the side.
  `victory_won` then sets `victory_reason` to the Union, and `save_battle_summary` puts the winner's `*`
  beside the Union in `battsumm`, for a Confederate technical victory. `script_autoplay_end` and
  `tests\autoplay.py` work around this rather than fix it.
- **Vary Start** (`vary_start_conditions`, `rules\setup.bm`).
  - When the Rebels' random fleet size is 0, their fleet keeps the scenario's port (city 24) with no
    ships. `fleet_exists` is then true for a fleet of none.
  - It is offered at any time in the Utility menu. It reloads the scenario, which resets the date, the
    victory rules and the cash, and brings back every leader, including those who command an army.
  - The ironclad chance is `RND > .45 * current_side`, the player's side, for both fleets.
  - Under Realism it can give ironclads in 1861: `game_apply_settings` turned them into wooden ships
    before Vary Start runs.
- **A fleet that retreats to no port** (`navy_retreat_port`, `rules\navy.bm`). With no other sea port,
  `fleet_city` becomes 0 while the fleet keeps its ships. The message says "retreating to NONE". Build
  then adds ships to a fleet that is in no port and is never drawn.
- **Smaller ones:**
  - The force-ratio warning lacks a space: "UNIONside close to" (`victory_warnings`, `ui\victory.bm`).
  - `ai_army_order` tests `victory_rule(VICTORY_CAPITAL) <> 0`, but a rule that is off is negative. The
    computer still holds its capital when the capital rule is off. `ai_evaluate_move` tests `> 0`.
  - Recruiting has no size cap. Repeated recruiting in one city can take an army past 32767, where it
    wraps to a negative size.
  - "No - Press Onward to" names the enemy's capital, which is "NONE" when the capital was taken
    (`end_game`).
  - The railroad picker allows the army's own city as a destination after one refused city
    (`menu_railroad`).

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
  and `battsumm` are opened in the current folder (`io\files.bm`), so they land wherever the game was
  started from. A single folder, for example beside the program, would keep them together.
- **The numbers that are not tuning knobs yet.** `scenarios\TUNING.DAT` holds 135 knobs (user,
  2026-11-16; `tools\tuning\knobs.txt`). Left as numbers in the code, each for a reason:
  - **Thresholds that give a formula its shape**: the size ratios of `battle_strengths` (.2, .5, 1.5, 3,
    10), the odds bands' edges of `ai_attack_score`, and the strength ratios of `ai_stay_weight` (1.5, 2,
    3). A file could set them out of order; a knob for each needs a check of the order.
  - **The price of supply** (`army_buy_supply` and `army_supply_days`, `rules\army.bm`): one line
    multiplies by .1 and the other by 10, and one knob for both would not round as the two do now.
  - **The move order** (`turn_set_move_order`), the recruit menu's chances (`army_recruit_cities`),
    the fleets' chances in `ai\navy.bm`, the train's in `ai\railroad.bm`, the rest of Vary Start, and
    the computer's strength boost when its enemy holds under 11 cities (`turn_update_victory_points`).
  - **`MAX_FORT`, `MAX_SUPPLY`, `MAX_EXPERIENCE`, `MAX_LEADER_RATING`, `MAX_CASH`, `MAX_FLEET_SHIPS`**:
    screens and files are laid out for them.

  A new knob is one line in `knobs.txt`, `make_knobs.py`, and the variable in the code. A fraction must
  be a DOUBLE (`name#`), which `make_knobs.py` sees to. Check a conversion as `number_knobs.py` was
  checked: the scripts, and the same autoplay games with the number and with the knob.

## The code

Left alone by phase 3, group 1, of `docs\archived\modernize-plan-completed.md` (the sides and limits). None of these changes
how the game plays.

- **The city report lists cities 1 to 20 and 21 to 40 in two columns** (`ui\reports.bm` lines 228 and 232).
  The numbers are the screen layout, so they stay. If another war has a different count of cities, the
  report needs laying out again.
- **Vary Start gives each fleet `10 * RND` ships** (`rules\setup.bm` lines 54 and 58). That is a random
  size, not the fleet limit, so it stays 10 rather than `MAX_FLEET_SHIPS`.

Left alone by group 2 (the special values):

- **`fleet_city() = 0`, "the side has no fleet", has no constant.** Its tests read `fleet_exists(side)`
  since 2026-11-13 (`docs\archived\structure-review-completed.md`, item 2); 7 assignments of 0 are left.
  `docs\archived\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 293). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **`menu_select` treats a start above 42 as row 1**: `IF row > 21` (`menu_start_row`, `ui\menu.bm` line 209) runs
  after `MENU_START` is taken off. The 21 there is the menu's 21 rows (`menu_text$(21)`), not
  `MENU_START`, so it stays.
- **The Utility menu calls `menu_select(-1)`** (`menu_utility`, `ui\options.bm` line 65). No mode has that number, so it is a
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
  (`io\files.bm` line 57) and `FOR i = 2 TO 6` in `menu_victory_conditions` (`ui\reports.bm` line 20), which
  also maps a rule to a menu row (`i - 1`).

Left alone by group 7 (the rule numbers):

- **`total_income = union_income_bonus + 200`** (`load_cities`, `io\files.bm` line 104), where the cities are read. The 200
  may be the two capitals' income (`2 * capital_income`), but nothing says so, and the main loop works
  `total_income` out again from the sides' income. It stays a number.
- **The Emancipation Proclamation comes after 1862** (`year above 1862`, `[emancipation]` in
  `scenarios\EVENTS.DAT`). That is the date of an event, not `IRONCLAD_YEAR`; phase 11 moved the
  events' dates to data (2026-11-13).

Left alone by group 8 (the colors):

- **`COLOR 16 - side_color` shows the other side's color** (`draw_battle_defender` and `draw_battle_losses`, `ui\battle.bm`): 16 - 9
  is 7 and 16 - 7 is 9. It stays as written. `side_color_of` (`game\colors.bm`) gives the color.
- **`CALL wait_seconds(99)`, "press a key", stays a number** (`ui\options.bm` line 102, Chk Links;
  `ui\turn.bm` line 224, "There are still defenders"; left alone by group 9). It goes with phase 7's
  `wait_key`, which replaces the 12 loops that announce a wait and read a key. Outside a script, a 99-second
  pause ends by itself; those loops do not, so `wait_key` must keep the difference or decide it.
- **`IF menu_color = 0 THEN menu_color = COLOR_GRAY`** (`ui\menu.bm` line 98): 0 there means "no color set",
  not black, so the test keeps its 0.

Found on 2026-11-16 in a code review, by reading the code; not run. The Realism tests and the forced
choices change how the game plays or is played; the others do not.

- **Waits that use a whole processor core.** `wait_key`, `wait_seconds` (`ui\screen.bm`), `menu_wait_key$`
  (`ui\menu.bm`) and `script_tick` (`io\script.bm`) loop on `INKEY$` with no `_LIMIT`. While the game
  waits for a key, it runs one core at 100%.
- **`wait_seconds` at midnight.** `TIMER` goes back to 0 at midnight, so `TIMER - start!` turns negative
  and the pause lasts until a key is pressed.
- **Files opened without a check.** `config_read` (`CWS.CFG`), `hall_of_fame_load` (`HISCORE.CWS`),
  `load_scenario_list` and `load_scenario` open their files without `_FILEEXISTS`. Started from another
  folder, the game stops with "File not found".
- **Special slots used as data.**
  - City 0's owner stands for "the port of a side with no fleet" (`navy_mark_side`). `ai_raise_forces`
    and `navy_can_invade` read it through `city_owner(fleet_city(side))`.
  - Army 0 is the scratch army of Join and is never cleared after it.
- **A latent precedence error** (`calculate_battle`, `ui\battle.bm`).
  `IF opt_players = PLAYERS_ONE AND (…) OR (…)` reads as `(A AND B) OR C`. It does no harm today,
  because `current_side` is the Union during a two-player month. The original has the same line.
- **Dead code.**
  - `IF army < 0` in `menu_city_fortify` (`ui\city.bm`): `city_army()` is never negative.
  - The first assignment of `menu_text$(2)` in `menu_utility` (`ui\options.bm`).
  - The unreachable `rule = VICTORY_WIPED_OUT` tests inside the force-ratio part of `victory_rule_met`.
  - The value of `odds! = 5 - 4 * RND` in `ai_beyond_score`, which is overwritten at once. The draw may
    be kept so that the random numbers stay in step; if so, a comment should say so.
- **A literal side.** `army_get_commander(2, army_slot)` in `menu_army_detach` should be `SIDE_REBEL`.
- **A rule that changes its input.** `battle_strengths` sets an army's size to 1 when it is below 1, in a
  procedure that otherwise only works out strengths.
- **Realism tests disagree.** Some places test `opt_realism = REALISM_ON`, others `>= REALISM_ON`, so
  Realism 2 (`REALISM_HIGH`, reachable through `CWS.CFG`) is on for some rules and off for others. This
  follows the original.
- **Forced choices.** Relieve and the port menu of a new fleet loop until a row is picked, so Esc does not
  back out. The Capital command takes the money before the city is picked, and picking the same capital
  still pays (documented in `menu_move_capital`).
