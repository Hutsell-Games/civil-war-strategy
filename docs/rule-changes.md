# Rule changes from the canonical game

This records changes to gameplay rules and computer decisions from the DOS
`canonical-source` game to the current port. Updated 2026-11-14.

Include combat, movement, recruiting, economy, events, victory, AI decisions and changes
to random draws or saved state that affect those rules. Interface fixes, graphics,
platform compatibility, file layout and test infrastructure belong in
[developer notes](devnotes.md#port-and-interface-differences-from-canonical).
Player-facing release summaries belong in [CHANGELOG.md](../CHANGELOG.md).

The [side-specific rule inventory](modernize-plan.md#step-4-named-inventory) describes current
differences between the sides, including inherited rules; this document records changes
from canonical. Unchanged canonical quirks awaiting a decision remain in [TODO.md](../TODO.md).

## Keeping this record current

- Update this document in the same change as any gameplay-rule or AI change, including
  bug fixes, changed random draws, AI decisions and changes made while refactoring. A pure
  rename, move or extraction needs no entry when behavior stays the same.
- Give each change a stable ID and a concrete trigger. Record canonical behavior, current
  behavior, source procedure, the introducing commit when known, and relevant test or replay
  evidence. Keep existing IDs; append IDs without renumbering old entries. Moved U and P entries
  retain their IDs in developer notes.
- When a rule changes again, update its current behavior and retain its earlier behavior and
  commits as history. Record reversions and resolved regressions instead of deleting them.
- Label uncommitted changes explicitly, then replace that label with their commit ID after
  commit. Separate source inspection from tests actually run; date and identify the snapshot
  for each verification result. A proposed change is not current behavior.
- Use procedure names for current source references. Existing line numbers below identify
  the original review snapshot and can become stale. Canonical references stay tied to the
  fixed baseline below. Keep detailed test-run logs in developer notes or their archive; link relevant evidence here.

The record aims to cover every gameplay-rule and AI change from canonical. Its established coverage is the source
review below plus the dated updates that follow; passing branch tests does not establish
exhaustive equivalence to the DOS game.

## Baseline and review coverage

The baseline is local `origin/canonical-source`, commit
`45bdab482589d1a4d8d1b47c3e242bb19979f59c`. The original source review compared
`refactor_naming` at `d8b845d3283ab83f29a8cb92a5efe7919b222a64`, with supplemental
inspection through `b182514fcd1a8e0ff2dcb43b91a0caf6f2a7601d`, on 2026-11-14.
Line references below use that review snapshot; later entries identify their own changes.
Full review coverage and verification are in the
[developer archive](archived/devnotes-completed.md#canonical-comparison-review-2026-11-14).

The branch includes deliberate rule fixes and AI changes. Passing its recordings does
not establish equivalence to the DOS game.

## Explicit gameplay changes

These are real divergences even where the branch intentionally corrects a canonical bug. The original expressions were checked against the canonical sources, rather than treating historical notes as the specification.

| ID | Trigger / topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| G1 | Battle supply | `CWSTRAT.BAS:918` decrements supply of army slots 1 and 2, regardless of who fights. | Decrements the actual attacker and defender, when their supply is positive. [rules/battle.bm](../rules/battle.bm), `battle_fight:151`; `0e32e1c`. |
| G2 | Casualties with Union attacker 3–20 | `CWSTRAT.BAS:1000` uses `attack > 2` to identify Rebels, assigning those Union attackers' casualties to the wrong side. | Uses `army_side(attacker)`; defender casualties go to the opposite side. [rules/battle.bm](../rules/battle.bm), `battle_apply_losses:251`; `0e32e1c`. |
| G3 | Battle loss scaling above 80,000 troops | `CWSTRAT.BAS:942` and `:953` test `> 300` before `> 800`, so the latter case never runs; the multiplier is .9. | Tests the larger threshold first, applying .8 above 800. Each loss calculation tests the opposing army's size, as canonical does. [rules/battle.bm](../rules/battle.bm), `battle_losses:204` and `battle_size_rate!`; `0e32e1c`. |
| G4 | Defender has less than one fifth of attacker strength | `CWSTRAT.BAS:867` matches `< .5` before `< .2`, applying .8 to defensive strength. | Matches `< .2` first and applies .5, before the existing strength limits. [rules/battle.bm](../rules/battle.bm), `battle_strengths:10`; `c2801af`. |
| G5 | Armies above 80,000 / 100,000 troops move | `CWSTRAT.BAS:2384` matches all sizes above 400 in its first case, so the larger delays never apply. | Sizes above 800 can receive +200 to their move key; above 1000 can receive +300, subject to each case's original key limit. This changes order of combat and captures. [rules/turn.bm](../rules/turn.bm), `turn_set_move_order:280`; `0e32e1c`. |
| G6 | Defender surrenders or is crushed | Canonical's `crushed` block awards 25 points to `3 - s`, the defending side, even when that side just lost its army. | Awards the attacking winner 25 points. Introduced in `0e32e1c`; the attacker-loss path was corrected separately by the R1 fix (`db5deb2`). [rules/turn.bm](../rules/turn.bm), `turn_army_lost`. |
| G7 | Supplies from a surrendered/crushed army | Canonical clears the lost army's supply before transferring it, transferring zero. | Transfers the lost army's supplies to the winner before clearing its slot, up to `MAX_SUPPLY`. Introduced for a defeated defender in `0e32e1c`; the R1 fix (`db5deb2`) also passes the correct winner when the attacker is crushed. [rules/turn.bm](../rules/turn.bm), `turn_army_lost`; [ui/turn.bm](../ui/turn.bm), `turn_attack`. |
| G8 | Fleet destroyed in naval combat | Canonical `navy` gives the defeated fleet's side 10 victory points. | Gives the opposing, victorious side 10 points. Shore-battery destruction still awards the existing 5 points separately. [rules/navy.bm](../rules/navy.bm), `navy_fleet_defeated`; `0e32e1c`. |
| G9 | Rebels control at least 35 cities | `CWSTRAT.BAS:2625` replaces Rebel points with Union points plus 100. | Adds 100 to the Rebels' own accumulated points, after their 30-city bonus. [rules/turn.bm](../rules/turn.bm), `turn_update_victory_points:321`; `0e32e1c`. |
| G10 | Rebel monthly points fall below 1 | Canonical floors only Union points at zero. Rebel points may remain negative. | Floors both sides' monthly points at zero. [rules/turn.bm](../rules/turn.bm), `turn_update_victory_points:321`; `c2801af`. |
| G11 | Recruiting while Balance favors the computer | Canonical applies extra recruits to army 0 when adding men, or to a new slot just before its size is overwritten; visible armies gain no bonus. Its check uses the player's side rather than the recruited side. | Adds `5 * balance_help(side)` to the recruited army, after its base size is assigned, and only for the favored computer side. This applies to both new armies and additions. [rules/army.bm](../rules/army.bm), `army_raise:73`, `army_add_recruits:379`, `army_recruit_bonus:417`; `0e32e1c`. |
| G12 | Railroad capacity for the computer's side under Realism | `CWSTRAT2.BAS:1429` already uses `control(who)`, but chooses the baseline **11 or 23 by global player `side`**, not `who`. | Chooses the baseline by the side whose train is being evaluated. Before clamping, Rebel AI capacity is 60 units lower with a Union player; Union AI capacity is 60 units higher with a Rebel player. [rules/railroad.bm](../rules/railroad.bm), `railroad_capacity:54`; `0e32e1c`. |
| G13 | Vary Start | `CWSTRAT.BAS:583` loops `21 TO 6`, so it never removes a Rebel army. | Loops `21 TO 26`, allowing the first six Rebel armies to be removed as for the Union. The six extra random draws also shift later random fleet, capital and leader results. [rules/setup.bm](../rules/setup.bm), `vary_start_conditions:28`; `0e32e1c`. |
| G14 | AI considers moving two armies into each other's cities | Canonical `smarts` compares the other army's order with `x`, this army's troop count. | Compares it with this army's origin city and cancels the current army's crossing order. This does not explicitly cancel both orders. [ai/army.bm](../ai/army.bm), `ai_army_order:24`; `0e32e1c`. |
| G15 | AI considers reinforcing an empty threatened capital by train | Canonical checks the rail connectivity of a candidate left over from the preceding search. | Checks connectivity of the capital itself, changing whether it is chosen. [ai/railroad.bm](../ai/railroad.bm), `ai_railroad_city`; `0e32e1c`. |
| G16 | AI starts a fleet with no fleet currently located | Canonical's general build check depends on `cityp(0)`, which the most recent naval order sets. | A missing fleet can build regardless of city 0's owner, subject to money and shipyard availability. [ai/navy.bm](../ai/navy.bm), `ai_fleet_orders:5`, and [rules/navy.bm](../rules/navy.bm), `navy_can_build:63`; `0e32e1c`. |
| G17 | AI buys an ironclad | Canonical requires money for two ships but charges for one. | Charges two wooden ships' cost. This changes cash and subsequent purchase count. [ai/navy.bm](../ai/navy.bm), `ai_navy_build:143`; `0e32e1c`. |
| G18 | Player invasion when no army slot/commander is available | Canonical proceeds with slot 0 and consumes the invasion's resources. | Returns without landing an army or marking the invasion complete. [ui/navy.bm](../ui/navy.bm), `menu_navy_invade:173`; `0e32e1c`. |
| G19 | Computer invasion when no army slot/commander is available | Canonical repeatedly requests a commander and can loop forever. | Gives up the invasion. [ai/navy.bm](../ai/navy.bm), `ai_navy_invade:270`; `0e32e1c`. |
| G20 | Mercenary event | Canonical `CWSTRAT2.BAS`, `events`, adds men, experience and supplies to local `index = 0`, an invisible scratch army. | Reinforces the army in the favored side's capital; if empty, creates an army under the next available commander, with a busy order. Introduced in `0e32e1c`. The R3 fix (`db5deb2`) skips this event when the side has no capital, or its capital is empty and no army slot is free, continuing to the next eligible event. [rules/events.bm](../rules/events.bm), `event_possible`, `event_apply`, `event_new_army`. |
| G21 | Player attempts Attack off a friendly or neutral city | Canonical marks Ships done before testing ownership, even though it does not bombard. | Leaves Ships available when no valid attack takes place. [ui/navy.bm](../ui/navy.bm), `menu_navy_attack:95`; `0e32e1c`. |
| G22 | Player chooses naval Build / Attack | Canonical's `AND RND ...` conditions consume AI decision draws even on the player's path. | Removes these otherwise unused draws. Later random events, battles and AI choices can differ even when the immediate action looks identical. [ui/navy.bm](../ui/navy.bm), `menu_navy_build:38`, `menu_navy_attack:95`; `0e32e1c`. |
| G23 | Realism turned off after being on | `CWSTRAT.BAS:622–631` runs `unionplus` only when Realism goes on, so turning it off keeps the Union's income bonus at 70%. It stays there until Balance or the number of players changes. Starting a game recomputes it from the settings. | Recomputes the bonus on both paths, so it always matches the settings. The manual's list of Realism's effects (`docs/CWS.DOC`, section 6.13) does not mention the bonus. [rules/setup.bm](../rules/setup.bm), `option_toggle_realism`. `db5deb2`. `TestOptionToggleRealism`. |
| G24 | Computer's fleet off an enemy city with an army | `CWSTRAT.BAS:1527`: on `RND > .5` the order becomes Sail (`chx = 3`), but `GOTO anchor` returns to `SELECT CASE choose`, which still holds Attack. The test runs again and draws a second number, and the fleet bombards the city all the same. | On `RND > .5` the fleet sails instead (`ai_navy_sail`), and the city is not bombarded. The second draw is gone with `random_discard`. Ruled by the user on 2026-11-14, reversing the ruling of 2026-11-13 that kept it. `war-rebel-altmap` now lasts 14 months, not 9; it and `war-union-altmap` were recorded again. [ai/navy.bm](../ai/navy.bm), `ai_navy_attack`. **Uncommitted** (2026-11-14). `TestAiNavyAttackSailsFromAnArmy`. |

## Rule changes within the later shared-rule cleanup

These changes are in `9f49d30`, outside the large explicit bug-fix batch. Its commit message acknowledges the first three topics; unchanged recorded screens did not exercise the distinguishing cases.

| ID | Topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| C1 | AI winter movement in February | `CWSTRAT.BAS:2293` blocks hostile/neutral destinations only in January. The player's menu already blocks January and February. | `winter_stops_move` blocks both months for the computer too. Normal openings advance in two-month steps, but even-month scenarios/saves distinguish this. [rules/turn.bm](../rules/turn.bm), `winter_stops_move:56`; [ai/army.bm](../ai/army.bm), `ai_army_order`. |
| C2 | AI builds onto an existing fleet | Canonical AI does not enforce the player's sea-port check inside Build. | The shared build predicate requires an existing fleet to be off a sea port owned by its side. This can stop AI purchases at river ports, captured ports or neutral ports. Its order loop can now terminate before the old build attempt and random draw. [rules/navy.bm](../rules/navy.bm), `navy_can_build:63`; [ai/navy.bm](../ai/navy.bm), `ai_navy_build` and `ai_navy_adjust`. |
| C3 | Troops on trains in victory checks | `CWSTRAT2.BAS:1761` and `:1763` count only armies with a positive city location. Embarked armies have location 0 and are omitted. | `army_in_field` includes each side's embarked army. This changes annihilation and force-ratio victory decisions, and the associated warnings. [rules/victory.bm](../rules/victory.bm), `victory_forces:6`; [rules/army.bm](../rules/army.bm), `army_in_field:292`. |
| C4 | Troops on trains in AI recruiting decisions | Canonical `smarts` excludes those troops when comparing its own and opposing strength for recruiting. | `ai_count_armies` uses `side_strength`, which includes train passengers. The embarked army still does not count toward its count of city-based armies. [ai/forces.bm](../ai/forces.bm), `ai_count_armies`; [rules/army.bm](../rules/army.bm), `side_strength:298`. |
| C5 | Positive troop counts in inactive, non-embarked slots | Canonical `iterate` sums every army slot when calculating the AI's overall strength ratio, including location 0. | `turn_strength_ratio` uses `side_strength`, which excludes an army with neither a city nor a train. This distinguishes inconsistent/edited saves or otherwise stale slots; train passengers themselves were already included in canonical's overall ratio. [rules/turn.bm](../rules/turn.bm), `turn_strength_ratio:106`. |

## Command availability and game state after setup or loading

These retain their original U IDs. They affect available orders, opening resources or
victory/event state. Interface and file-format details are in
[developer notes](devnotes.md#interface-and-save-compatibility).

| ID | Topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| U4 | Month command availability after Load | Canonical main code tests the Load submenu's returned row; only choosing its first row reopens Troops, Moves and Ships. | Every successful load resets those three command gates, regardless of selected row/slot. [ui/files.bm](../ui/files.bm), `menu_load_game:52`; `0e32e1c`. |
| U5 | Month command availability after Save | Saving in slot 1 can reopen Troops, Moves and Ships through the same returned-row test. | Saving never resets those gates. [ui/files.bm](../ui/files.bm), `menu_save_game:105`; `0e32e1c`. |
| U9 | Initial random cash when selecting a different scenario | Canonical loads the externally selected map and gives its opening random cash before `RANDOMIZE TIMER`. | Selecting a different scenario runs setup again after `script_start` has seeded the generator. Both opening cash and subsequent random sequence can differ. Repeated scenario changes/restarts also differ in their setup call sequence. [cws.bas](../cws.bas); [rules/setup.bm](../rules/setup.bm), `game_apply_settings:229`; `f97722d`. |
| U14 | Victory rules and events in a saved game | Canonical saves neither `vicflag()` nor `emancipate`. A game loaded in a new session can have the Emancipation Proclamation again. One loaded in the same session keeps that session's flag and victory rules, including rules switched off and thresholds raised by playing on. | `save_game` writes the six victory rules, then the events that have happened, by their names in `EVENTS.DAT`. `load_game` clears every event and reads them back; a name `EVENTS.DAT` no longer has is passed over. A save without them, written before this change or by `make_save.py`, loads with the victory rules in memory and no event done. Canonical cannot read the new lines, as for [U10](devnotes.md#interface-and-save-compatibility). [io/files.bm](../io/files.bm), `save_game`, `load_game`. `db5deb2`. `TestSaveGameKeepsVictoryRulesAndEvents`, `TestSaveGameFindsEventsByName`, `TestSaveGameWithoutVictoryRulesLoads`; `files` and `scenario-save` recorded again. |

## Regression history and subsequent corrections

These entries retain problems found after the original changes. **Current status: corrected
in `db5deb2`**, inspected 2026-11-14. This update inspected
source and test definitions; it did not rerun the tests or recorded games.

| ID | Trigger | Earlier port behavior | Current behavior and evidence |
|----|---------|-----------------------|-------------------------------|
| R1 | Attacker is crushed after a battle | `turn_attack` passed the lost attacker as both loser and winner to `turn_army_surrenders`. The loss helper credited the wrong side and could not transfer supplies to the surviving defender. Canonical credited the defender 25 points in this case, although its supply transfer was zero (G7). | The caller passes the surviving defender when the attacker is lost, and the attacking winner when the defender is lost. The winner receives 25 points and the loser's supplies. This restores canonical's point recipient for attacker losses and extends G7's supply fix. [ui/turn.bm](../ui/turn.bm), `turn_attack`, `turn_army_surrenders`; [rules/turn.bm](../rules/turn.bm), `turn_army_lost`. The original failing probe is recorded in the developer archive; runtime verification of the caller is not recorded here. |
| R2 | Start another game or change scenario in the same process | `game_reset` left city counts intact, and `load_cities` added the next map's cities. Standard then alternate reported 21 Union cities instead of the alternate map's 10. Canonical's externally selected map starts with its own city count; [U8](devnotes.md#interface-and-save-compatibility) introduced repeated in-process scenario selection. | `game_reset` clears both sides' city counts before loading. Reports, initial realistic rail capacity and first-turn AI now use the selected map's counts. [rules/setup.bm](../rules/setup.bm), `game_reset`; [tests/rules_test.bas](../tests/rules_test.bas), `TestGameNewCountsOnlyItsScenariosCities` checks both sides across repeated switches. |
| R3 | Mercenary event without a capital or a free army slot | G20's new-army path could use city 0 after the capital was lost, consuming a commander for an army with no city. With no slot, it could announce a reinforcement that formed no army. Canonical placed the reinforcement in scratch army 0 regardless (G20). | `event_possible` requires a capital and either its existing army or a free slot. Otherwise selection continues to the next eligible event; `event_apply` also guards new-army creation against capital 0. [rules/events.bm](../rules/events.bm), `event_possible`, `event_apply`; [tests/rules_test.bas](../tests/rules_test.bas), `TestEventMercenariesNeedTheCapital`, `TestEventMercenariesNeedAnArmySlot`. |

## Review evidence

The [original canonical review](archived/devnotes-completed.md#canonical-comparison-review-2026-11-14)
records its source snapshots, test results, failed regression probes and limits. Those
results describe that review's snapshots, not verification of every later edit.
