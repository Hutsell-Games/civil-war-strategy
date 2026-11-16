# Done: the code review of 2026-11-16

The findings of the code review of 2026-11-16 that are fixed, and its list of what to fix first.
The open findings, its groups 3 and 4, moved to `TODO.md` on 2026-11-16: the inherited bugs to
"The game", the code smells to "The code".

The review read the whole codebase as it stood in the working tree on 2026-11-16, with the tuning
knobs staged. The game's BASIC source was read in full except the drawing files (`draw\`,
`game\`), which were only skimmed. Also read: `tests\autoplay.py`, `tests\test_autoplay.py`,
`tests\test_tuning.py` and `tools\tuning\make_knobs.py`. Neither the game nor the tests were run.
An "inherited" finding was checked against `CWSTRAT.BAS` and `CWSTRAT2.BAS` on the branch
`canonical-source`. Its four groups were bugs in the tuning knobs, state that goes stale after
Load or New Game, bugs inherited from DOS that `TODO.md` did not list, and code smells.

## 1. The tuning knobs: ranges that crash the game or break its arithmetic

| Knob | Value in range | What happens | Where |
|------|----------------|--------------|-------|
| `recruit_cities_offered` | 5 | With Balance below Even, `offer_count` is 6. `army_recruit_cities` then writes `turn_recruit_city(6)`, but the array is `turn_recruit_city(5)`: subscript out of range. Cap the range at 4, or size the array from the knob. | [rules/army.bm](../../rules/army.bm) `army_recruit_cities`; [cws.bi](../../cws.bi) line 242 |
| `defender_wins_loss`, `attacker_wins_loss`, `large_army_loss`, `huge_army_loss` | e.g. 10 | `battle_losses` takes `SQR(variance)` with `variance = mean * (1 - loss_rate!)`. A loss rate above 1 makes it negative, and `SQR` stops the program. With the shipped losses (attack 11, defend 9), `defender_wins_loss` = 10 gives the attacker a rate of 1.1. | [rules/battle.bm](../../rules/battle.bm) `battle_losses`, `normal_random_number` |
| `fort_defender_loss` | above .045 | The defender's loss rate goes below 0 behind a fort of 2. The mean and the variance are then negative: the same `SQR` error. | same |
| `invade_ships_least` | 1 | `navy_land_army` removes the ship first. With one ship that clears the fleet, so `fleet_city` is 0, and the new army is raised in city 0. Make the least 2, or read the city before the ship is removed. | [commands/navy.bm](../../commands/navy.bm) `navy_land_army` |
| `union_bonus_per_balance`, `union_bonus_realism_share` | 2000, 10 | 2000 × Balance 5 × 10 = 100,000 overflows `union_income_bonus`. | [rules/setup.bm](../../rules/setup.bm) `set_union_advantage` |
| `capital_income`, `union_bonus_per_balance` | 5000, 2000 | A treasury of 19,999 plus an income of about 15,000 wraps in `turn_collect_income`. Next month the negative cash is set to 0. | [rules/turn.bm](../../rules/turn.bm) `turn_collect_income` |
| `points_kept` | 1 | Victory points never decay, so they grow every month until they overflow. | [rules/turn.bm](../../rules/turn.bm) `turn_update_victory_points` |
| `points_per_income` | 10 | At the default `points_kept` of .8 the points settle near 30,000 or above, at the edge of an INTEGER. | same |

- **`max_army_size` is described wrongly.** Its text says "the most troops an army can hold". It
  only limits Join (`army_combine_add`). Recruiting and the events add troops without a cap.

The `check` lines of `knobs.txt` could cover some of these, for example
`fort_defender_loss * MAX_FORT < .01 * rule_defend_loss`. The loss rates depend on the scenario's
`CWS.INI`, though, so the surest fix is to clamp `loss_rate!` to between 0 and 1 in
`battle_losses`.

## 2. Port regressions: state that Load and New Game leave behind

These two turned out to be in DOS too, not port regressions. DOS's Files, New Game stays in the
same process (`GOTO newgame`, `CWSTRAT.BAS` line 693) and resets only `rflag`. Its Load resets
`rflag`, `mflag` and `nflag` (line 686), but not `commerce` or `raider`. The fixes are rule
changes G30 and G31 in `docs\rule-changes.md`.

- **The raiding state.** `raiding_side`, `raid_loss` and `fleet_pursuit` are not in the save
  file, and `game_reset` does not clear them.
  - A load in the same session keeps the old game's raider.
  - After New Game, in the first month, `turn_collect_income` still takes the old `raid_loss`
    off a side. `navy_raid_round` raids with the new scenario's fleet, which is in port.
- **The month's command flags after Files, New Game.** `game_reset` does not call
  `turn_reset_commands`. A player who used Ships, or ran out of armies to move, and then starts a
  new game finds Ships or Moves shown as "-" in its first month. `cws.bas` lets Ships open only
  when `turn_navy_done` is 0.

## 3. Inherited bugs that `TODO.md` does not list

- **A fleet saved at sea does not raid after a Load** (`load_game`). The raid is not saved, and
  `navy_note_raiding_side` runs only after a fleet moves (`navy_finish_move`). DOS's `filer` does
  not set `commerce` either. So a fleet at sea (`fleet_city` = 99) raids again only once some
  fleet has moved. Fixed with item 3 below (G31).

## What to fix first

These come from the new work or from the port, and none changes how a game plays at the
defaults:

1. Tighten the knob ranges: `recruit_cities_offered`, `invade_ships_least`, the loss knobs, and
   the income and points knobs.
2. Clamp `loss_rate!` to between 0 and 1 in `battle_losses`.
3. Call `navy_note_raiding_side` at the end of `load_game`.
4. Clear `raiding_side`, `raid_loss` and `fleet_pursuit` in `game_reset`, and call
   `turn_reset_commands` there.
5. Correct the description of `max_army_size` in `knobs.txt`.

### What was built (2026-11-16, uncommitted)

1. In `tools\tuning\knobs.txt`: `recruit_cities_offered` goes to 4 at most, `invade_ships_least`
   to 2 at least, `union_bonus_per_balance` to 1000 at most, `union_bonus_realism_share` to 1 at
   most, and `points_kept` to .95 at most. A new `check` line keeps a side's settled victory
   points at 15,000 or below. Both sides' points are added in one INTEGER in `draw_top_bar`. At
   the defaults the bound works out to 2,760. With the new ranges, a treasury of 19,999 plus the
   largest income (5,000 + 5 × 1,000 + 590 of cities) stays below 32,767, so the cash needs no
   check. The loss knobs keep their ranges: item 2 makes every value safe.
2. `battle_rate_bounded!` in `rules\battle.bm` keeps both loss rates of `battle_losses` between
   0 and 1. Tests: `TestBattleRateBounded`, `TestBattleLossesWithARateAboveOne`.
3. As written, and `load_game` also clears `raiding_side`, `raid_loss` and `fleet_pursuit`
   before it calls `navy_note_raiding_side`. DOS's load (`filer` in `CWSTRAT.BAS`) does not set
   `commerce`, so this is rule change G31, ruled by the user on 2026-11-16. A fleet saved at
   sea now raids from the first month after the load. `events-union` was recorded again: the
   Union fleet saved at sea shows the raider's banner from its first checkpoint. Test:
   `TestLoadGameClearsTheRaid`.
4. As written; rule change G30, ruled by the user on 2026-11-16. Tests: `TestGameReset`,
   `TestNewGameTakesNoRaidFromIncome`.
5. The text now says that the knob limits Join only.

Checked: `tests\rules_test.bas` 221 passed; the Python tests 49 passed;
`python tests\play.py check` 41 of 41 scripts passed, with `events-union` recorded again.

## The second round (2026-11-16)

### The knob `max_army_size`

| Knob | Value in range | What happens | Where |
|------|----------------|--------------|-------|
| `max_army_size` | 16000 | Three armies of 16,000 overflow the INTEGER sums of `victory_forces` and `side_troops`. | [rules/victory.bm](../../rules/victory.bm), [rules/army.bm](../../rules/army.bm) |

**What was built (uncommitted).** The knob's most is now 1600, not 16000, in
`tools\tuning\knobs.txt`, and `make_knobs.py` wrote `io\tuning_knobs.bm` and
`scenarios\TUNING.DAT` again. A side has 20 armies, and 20 × 1600 = 32,000. Army sizes are summed
or multiplied as INTEGERs in more places than the two named above:
- `side_troops` and `victory_forces`;
- `report_armies` (`total_troops`) and `report_force_summary` (`city_troops`);
- `city_nearby_enemy_strength`: 6 roads × 1600 plus 36 cities × 160, at most 15,360;
- `3 * army_size(spare_army)` in `ai/railroad.bm`.

Making all of them LONG would have changed signatures across the computer's code. Sizes are in
hundreds, so the most is 160,000 troops; the default stays 1250. Recruiting and the events can
still take an army past it (`TODO.md`, "The game").

### Load and New Game

Both are in DOS too. DOS sets the ratio (`aggress!`) only at the month's end and in the victory
points, and its load (`filer` case 2) does not read `cwslead.dat` again.

- **`ai_strength_ratio!`.** It carried into the first computer turn of a new or loaded game. It
  is worked out again only in `turn_date_and_supply`, after the computer has moved.
  **Built:** `game_reset` and `load_game` set it to 0, as a game from the title has. Rule change
  G32. Test: `TestNewGameAndLoadClearTheStrengthRatio`.
- **The free leaders, on loading a save of the same scenario.** `load_game` reloaded the
  scenario's leaders only when the save was of another scenario. A leader that the current game
  used up stayed gone.
  **Built:** `load_scenario_leaders`, taken out of `load_scenario`, reads `CWSLEAD.DAT`.
  `load_game` calls it for every save, before it reads the armies. Rule change G33. Test:
  `TestLoadGameFreesTheScenariosLeaders`. The load tests run in an empty folder, so
  `WriteTestLeaders` in `tests\rules_test.bas` writes the leaders file there.

Checked: `tests\rules_test.bas` 223 passed; the Python tests 49 passed;
`python tests\play.py check` 41 of 41 scripts passed, none recorded again.
