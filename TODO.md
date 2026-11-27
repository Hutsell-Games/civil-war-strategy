# To do

Open work on the QB64 port. Remove an item when it is done. The plan is
`docs\modernize-plan.md`.

## The tests

- **A game that reaches March 1865 with the computer active.** The generated games end sooner, because a
  player who only ends turns is beaten in 1 to 20 turns. `union-time` and `two-player` reach the time limit
  with a passive computer or none.
- **The count of lines that no test runs is out of date.** `docs\modernize-plan.md` ("Lines that no test
  runs") speaks of 10 lines and lists 13 in its table, and `tests\README.md` says 18. On 2026-11-24
  `python tests\play.py coverage --unit-tests` reported 225 lines not run of 7,961. The most are in
  `ui\army.bm` (26), `ai\navy.bm` (24), `io\tuning_knobs.bm` (20) and `ui\turn.bm` (14). Find out
  first whether tests were lost or the earlier count left lines out, then fix the numbers or add tests.

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how a
game plays changes the recorded screens.

- **The title screen, the burning capital and Lincoln's picture are not shown** (`docs\devnotes.md`, item 5).
  The pictures are in `docs\`. The game could load and show them, as World War 2's `TODO.md` also notes for
  its title.
- **`normal_random_number` draws high.** It sums 12 RNDs and subtracts 5.5, though the sum averages 6, so every draw centers
  on `mean + SQR(variance) / 2` (`TestNormalDrawsHigh` in `tests\rules_test.bas`), as in World War 2 and Civil War
  Battleset. A fix changes the battles, so every script would need `record` again.
- **The train and the cannon's wheel differ from DOS by a few pixels**, and the water beside Norfolk and
  Mobile is no longer filled by `touchup` (`docs\devnotes.md`, item 8). If QB64Rust ever draws `DRAW` and
  `CIRCLE` as QB 4.5 did, the four lines can go back to the original.
- **The computer playing both sides favors the Rebels.** In 100 two-player games of the computer
  against itself (`tests\autoplay.py`, standard map, seeds 1 to 100), the Rebels won 80 and the Union 20.
  43 of the Rebels' wins came at the time limit, March 1865, a technical victory: the Union's computer did
  not win before the clock ran out. Before the fixes G25 to G28 it was 69 to 31 (`docs\rule-changes.md`).
  Found 2026-11-15. Whether people find the same is the next check (user, 2026-11-16): games played by
  hand, as each side. Possible causes to measure with autoplay: the time limit itself, the Union's
  computer being too cautious to take Richmond, and the scenario's starting forces. On
  2026-11-21 the same games gave 76 to 24 with G34 (events in two-player games), and 78 to 22 with
  G35 to G47 as well; 43 games ended at the time limit. G35 to G47 changed the winner of 14 games,
  8 toward the Rebels and 6 toward the Union (sign test p = 0.79): no measurable change.
- **A riot that finds no city still takes the month's event.** `event_possible` (`rules\events.bm`)
  allows "city neutral" always. So when `event_riot_city` finds no city, or Realism is off, the riot is
  still the month's event. The player sees only the banner, and the events after it in the list are not
  tried. The original did the same (`GOSUB riot: EXIT SUB`). A riot with an `if = once` line would also be
  used up. A fix changes which numbers are drawn, so every script would need `record` again.
- **The first "is blockaded" message of a month takes the color before it.** `turn_date_and_supply`
  (`ui\turn.bm`) sets `COLOR COLOR_LIGHT_MAGENTA` after that message, so the first one shows in whatever
  color was set last, and later ones in magenta. The original did the same (`COLOR 13` after the `PRINT`)
  (found 2026-11-25, review of `ui\turn.bm`).
- **In a two-player game only a Rebel army's surrender plays the tune.** `turn_army_surrenders`
  (`ui\turn.bm`) plays it when the army's side is not `current_side`, and while the month is worked out
  `current_side` is the Union. Both players are people, so either both sides should hear it or neither.
  The original did the same (`x <> side`) (found 2026-11-25, review of `ui\turn.bm`).
- **No fort can be razed in a two-player game.** `turn_enter_city` (`ui\turn.bm`) offers "Raze ?" only when
  `opt_players = PLAYERS_ONE`, so neither player is ever asked. The original did the same (`player = 1`)
  (found 2026-11-25, review of `ui\turn.bm`).

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
- **One known folder for saves and settings.** `cws1.sav` to `cws9.sav`, `cws.cfg`, `hiscore.cws`, `cws.his`
  and `battsumm` are opened in the current folder (`io\files.bm`), so they land wherever the game was
  started from. The names of the settings, the Hall of Fame and the history are constants in `io\folders.bi`. A single folder, for example beside the program, would keep them together.
- **The numbers that are not tuning knobs yet.** `scenarios\TUNING.DAT` holds 135 knobs (user,
  2026-11-16; `tools\tuning\knobs.txt`). Left as numbers in the code, each for a reason:
  - **Thresholds that give a formula its shape**: the size ratios of `battle_strengths` (.2, .5, 1.5, 3,
    10), the odds bands' edges of `ai_attack_score`, and the strength ratios of `ai_stay_weight` (1.5, 2,
    3). A file could set them out of order; a knob for each needs a check of the order.
  - **The price of supply** (`army_buy_supply` and `army_supply_days`, `rules\army.bm`): one line
    multiplies by .1 and the other by 10, and one knob for both would not round as the two do now.
  - **The move order** (`turn_set_move_order`), the recruit menu's chances (`army_recruit_cities`),
    the fleets' chances in `ai\navy.bm`, the train's in `ai\railroad.bm`, the rest of Vary Start, and
    the computer's strength boost when it holds under 11 cities (`turn_update_victory_points`).
  - **`MAX_FORT`, `MAX_SUPPLY`, `MAX_EXPERIENCE`, `MAX_LEADER_RATING`, `MAX_CASH`, `MAX_FLEET_SHIPS`**:
    screens and files are laid out for them.

  A new knob is one line in `knobs.txt`, `make_knobs.py`, and the variable in the code. A fraction must
  be a DOUBLE (`name#`), which `make_knobs.py` sees to. Check a conversion as `number_knobs.py` was
  checked: the scripts, and the same autoplay games with the number and with the knob.

## The code

- **The Battles report's ALL GAMES casualties outgrow their box.** `report_battle_summary` (`ui\reports.bm`)
  prints each side's men lost, in thousands, at columns 38 and 45, inside boxes that end at x 345 and x 400.
  A 5-digit total (10 million men, about 30 wars at 300,000 each) prints as `" 12345 "`. The Rebel column
  then runs past the box to x 408, and the Union column's trailing space covers the divider at x 345. Print
  the numbers at a fixed width, right-aligned in their boxes (found 2026-11-25, review of `ui\reports.bm`).

- **The city report lists cities 1 to 20 and 21 to 40 in two columns** (`ui\reports.bm` lines 218 and 222).
  The numbers are the screen layout, so they stay. If another war has a different count of cities, the
  report needs laying out again.
- **Vary Start gives each fleet `10 * RND` ships** (`rules\setup.bm` lines 71 and 75). That is a random
  size, not the fleet limit, so it stays 10 rather than `MAX_FLEET_SHIPS`.
- **`fleet_city() = 0`, "the side has no fleet", has no constant.** Its tests read `fleet_exists(side)`
  since 2026-11-13 (`docs\archived\structure-review-completed.md`, item 2); 7 assignments of 0 are left.
  `docs\archived\constants.md` has no row for it; a `FLEET_NONE` would be a new name to agree.
- **An army without supply moves last**: `move_order_key(i) = 900 + i` (`rules\turn.bm` line 279). The 900
  is a sort key below `MOVE_KEY_NONE` (999), not a special value, so it stays.
- **Tests of `menu_choice` by sign keep their numbers** (`> 0`, `< 0`, `< 1`); see
  `docs\archived\constants.md`, section 2. Those of `army_order()` read `army_has_move` and `army_has_acted`
  since 2026-11-13.
- **The loops over the victory rules keep their numbers**: `FOR i = 1 TO 6` when the rules are read
  (`io\files.bm` line 58) and `FOR i = 2 TO 6` in `menu_victory_conditions` (`ui\reports.bm` line 20), which
  also maps a rule to a menu row (`i - 1`).
- **`total_income = union_income_bonus + 200`** (`load_cities`, `io\files.bm` line 120), where the cities are read. The 200
  may be the two capitals' income (`2 * capital_income`), but nothing says so, and the main loop works
  `total_income` out again from the sides' income. It stays a number.
- **The Emancipation Proclamation comes after 1862** (`year above 1862`, `[emancipation]` in
  `scenarios\EVENTS.DAT`). That is the date of an event, not `IRONCLAD_YEAR`; phase 11 moved the
  events' dates to data (2026-11-13).
- **`COLOR 16 - side_color` shows the other side's color** (`draw_battle_defender` and `draw_battle_losses`, `ui\battle.bm`): 16 - 9
  is 7 and 16 - 7 is 9. It stays as written. `side_color_of` (`game\colors.bm`) gives the color.
- **`CALL wait_seconds(99)`, "press a key", stays a number** (`ui\options.bm` line 94, Chk Links;
  `ui\turn.bm` line 218, "There are still defenders"; left alone by group 9). It goes with phase 7's
  `wait_key`, which replaces the 12 loops that announce a wait and read a key. Outside a script, a 99-second
  pause ends by itself; those loops do not, so `wait_key` must keep the difference or decide it.
- **`turn_resolve` clears two screen boxes by number** (`ui\turn.bm`): `LINE (5, 17)-(100, 63), 3, BF` with
  its border, the train's box after a train arrives, and `LINE (390, 350)-(520, 400), 1, BF`, under the
  month's label. They stay numbers for now. Name them in one pass over the panel's boxes, not one at a
  time (found 2026-11-25, review of `ui\turn.bm`).
- **`IF menu_color = 0 THEN menu_color = COLOR_GRAY`** (`ui\menu.bm` line 103): 0 there means "no color set",
  not black, so the test keeps its 0.
- **A loaded game's knobs skip the rules between knobs.** `tuning_apply_list` (`io\tuning_file.bm`)
  checks each knob's range but not `tuning_relations$`. A save keeps only the knobs off their defaults.
  So if `tools\tuning\knobs.txt` changes a default after a game was saved, the mix can break a rule:
  a save with `cost_ship=5000`, then a default `ironclad_cost_times` of 4, prices an ironclad at 20000,
  above `MAX_CASH`. A knob whose range has been narrowed since the save is passed over without a
  word: a save with `loss_own_share=5`, from before its most went from 10 to 1, loads it at its
  default, .8. To decide: refuse the save, warn, or fall back to the defaults (found 2026-11-24).
- **Files opened without a check.** `config_read` (`CWS.CFG`), `load_scenario_list` and `load_scenario`
  open their files without `_FILEEXISTS`. Started from another
  folder, the game stops with "File not found".
- **Special slots used as data.**
  - City 0's owner stands for "the port of a side with no fleet" (`navy_mark_side`). `ai_raise_forces`
    and `navy_can_invade` read it through `city_owner(fleet_city(side))`.
  - Army 0 is the scratch army of Join and is never cleared after it.
- **A literal side.** `army_get_commander(2, army_slot)` in `menu_army_detach` should be `SIDE_REBEL`.
- **A rule that changes its input.** `battle_strengths` sets an army's size to 1 when it is below 1, in a
  procedure that otherwise only works out strengths.
- **Forced choices.** Relieve loops until a row is picked, so Esc does not back out. The Capital command takes the money before the city is picked, and picking the same capital
  still pays (documented in `menu_move_capital`).
