# Rule changes from the canonical game

This is the permanent record of changes to the game's rules and behavior from the DOS
`canonical-source` game to the current port. Keep it current as the game changes; it is not
an archived refactoring report. Updated 2026-11-14.

Gameplay rules include combat, movement, recruiting, economy, events, victory and computer
decisions. Menus, persistence, presentation, runtime and test-mode differences are retained
in separate sections because they can affect play or explain a recorded difference.
The [side-specific rule inventory](modernize-plan.md#step-4-named-inventory) describes current
differences between the sides, including inherited rules; this document records changes
from canonical. Unchanged canonical quirks awaiting a decision remain in [TODO.md](../TODO.md).

## Keeping this record current

- Update this document in the same change as any rule or observable behavior change, including
  bug fixes, changed random draws, AI decisions and changes made while refactoring. A pure
  rename, move or extraction needs no entry when behavior stays the same.
- Give each change a stable ID and a concrete trigger. Record canonical behavior, current
  behavior, source procedure, the introducing commit when known, and relevant test or replay
  evidence. Keep the existing G, C, U, P and R IDs; append IDs without renumbering old entries.
- When a rule changes again, update its current behavior and retain its earlier behavior and
  commits as history. Record reversions and resolved regressions instead of deleting them.
- Label uncommitted changes explicitly, then replace that label with their commit ID after
  commit. Separate source inspection from tests actually run; date and identify the snapshot
  for each verification result. A proposed change is not current behavior.
- Use procedure names for current source references. Existing line numbers below identify
  the original review snapshot and can become stale. Canonical references stay tied to the
  fixed baseline below. Link new evidence here from plans rather than making another ledger.

The record aims to cover every change from canonical. Its established coverage is the source
review below plus the dated updates that follow; passing branch tests does not establish
exhaustive equivalence to the DOS game.

## Baseline and review coverage

Reviewed 2026-11-14. This compares the complete branch trees, not just the most recent naming commits:

- Reviewed branch: `refactor_naming`, `d8b845d3283ab83f29a8cb92a5efe7919b222a64`.
- Canonical base: local remote-tracking ref `origin/canonical-source`, `45bdab482589d1a4d8d1b47c3e242bb19979f59c`.
- No fetch was performed. These commit IDs identify the comparison even if either branch moves.
- Supplemental source review covers the two commits added during this review, through `b182514fcd1a8e0ff2dcb43b91a0caf6f2a7601d` (`30d424e`, event-reader validation extraction; `b182514`, shared fortification command). No additional gameplay divergence was identified in those two commits. Line references below use the primary `d8b845d` snapshot.
- Current update: the staged fixes in `ui/turn.bm`, `rules/setup.bm` and `rules/events.bm` were inspected on 2026-11-14 and are recorded as R1–R3 below. They are not yet associated with a commit. The verification results at the end remain those of the original review, not a test run of these staged fixes.
- Scope: gameplay, AI, menus, presentation, persistence, startup and test-mode behavior. Renames, formatting, file moves and procedure extraction are excluded unless their behavior differs.

The branch is **not behaviorally equivalent** to canonical. It includes explicit bug fixes and feature changes. Existing recordings describe the branch's behavior; passing them does not establish equivalence to the DOS original.

## Explicit gameplay changes

These are real divergences even where the branch intentionally corrects a canonical bug. The original expressions were checked against the canonical sources, rather than treating historical notes as the specification.

| ID | Trigger / topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| G1 | Battle supply | `CWSTRAT.BAS:918` decrements supply of army slots 1 and 2, regardless of who fights. | Decrements the actual attacker and defender, when their supply is positive. [rules/battle.bm](../rules/battle.bm), `battle_fight:151`; `0e32e1c`. |
| G2 | Casualties with Union attacker 3–20 | `CWSTRAT.BAS:1000` uses `attack > 2` to identify Rebels, assigning those Union attackers' casualties to the wrong side. | Uses `army_side(attacker)`; defender casualties go to the opposite side. [rules/battle.bm](../rules/battle.bm), `battle_apply_losses:251`; `0e32e1c`. |
| G3 | Battle loss scaling above 80,000 troops | `CWSTRAT.BAS:942` and `:953` test `> 300` before `> 800`, so the latter case never runs; the multiplier is .9. | Tests the larger threshold first, applying .8 above 800. Each loss calculation tests the opposing army's size, as canonical does. [rules/battle.bm](../rules/battle.bm), `battle_losses:204` and `battle_size_rate!`; `0e32e1c`. |
| G4 | Defender has less than one fifth of attacker strength | `CWSTRAT.BAS:867` matches `< .5` before `< .2`, applying .8 to defensive strength. | Matches `< .2` first and applies .5, before the existing strength limits. [rules/battle.bm](../rules/battle.bm), `battle_strengths:10`; `c2801af`. |
| G5 | Armies above 80,000 / 100,000 troops move | `CWSTRAT.BAS:2384` matches all sizes above 400 in its first case, so the larger delays never apply. | Sizes above 800 can receive +200 to their move key; above 1000 can receive +300, subject to each case's original key limit. This changes order of combat and captures. [rules/turn.bm](../rules/turn.bm), `turn_set_move_order:280`; `0e32e1c`. |
| G6 | Defender surrenders or is crushed | Canonical's `crushed` block awards 25 points to `3 - s`, the defending side, even when that side just lost its army. | Awards the attacking winner 25 points. Introduced in `0e32e1c`; the attacker-loss path was corrected separately by the staged R1 fix. [rules/turn.bm](../rules/turn.bm), `turn_army_lost`. |
| G7 | Supplies from a surrendered/crushed army | Canonical clears the lost army's supply before transferring it, transferring zero. | Transfers the lost army's supplies to the winner before clearing its slot, up to `MAX_SUPPLY`. Introduced for a defeated defender in `0e32e1c`; the staged R1 fix also passes the correct winner when the attacker is crushed. [rules/turn.bm](../rules/turn.bm), `turn_army_lost`; [ui/turn.bm](../ui/turn.bm), `turn_attack`. |
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
| G20 | Mercenary event | Canonical `CWSTRAT2.BAS`, `events`, adds men, experience and supplies to local `index = 0`, an invisible scratch army. | Reinforces the army in the favored side's capital; if empty, creates an army under the next available commander, with a busy order. Introduced in `0e32e1c`. The staged R3 fix skips this event when the side has no capital, or its capital is empty and no army slot is free, continuing to the next eligible event. [rules/events.bm](../rules/events.bm), `event_possible`, `event_apply`, `event_new_army`. |
| G21 | Player attempts Attack off a friendly or neutral city | Canonical marks Ships done before testing ownership, even though it does not bombard. | Leaves Ships available when no valid attack takes place. [ui/navy.bm](../ui/navy.bm), `menu_navy_attack:95`; `0e32e1c`. |
| G22 | Player chooses naval Build / Attack | Canonical's `AND RND ...` conditions consume AI decision draws even on the player's path. | Removes these otherwise unused draws. Later random events, battles and AI choices can differ even when the immediate action looks identical. [ui/navy.bm](../ui/navy.bm), `menu_navy_build:38`, `menu_navy_attack:95`; `0e32e1c`. |
| G23 | Realism turned off after being on | `CWSTRAT.BAS:622–631` runs `unionplus` only when Realism goes on, so turning it off keeps the Union's income bonus at 70%. It stays there until Balance or the number of players changes. Starting a game recomputes it from the settings. | Recomputes the bonus on both paths, so it always matches the settings. The manual's list of Realism's effects (`docs/CWS.DOC`, section 6.13) does not mention the bonus. [rules/setup.bm](../rules/setup.bm), `option_toggle_realism`. **Uncommitted** (2026-11-14). `TestOptionToggleRealism`. |

## Rule changes within the later shared-rule cleanup

These changes are in `9f49d30`, outside the large explicit bug-fix batch. Its commit message acknowledges the first three topics; unchanged recorded screens did not exercise the distinguishing cases.

| ID | Topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| C1 | AI winter movement in February | `CWSTRAT.BAS:2293` blocks hostile/neutral destinations only in January. The player's menu already blocks January and February. | `winter_stops_move` blocks both months for the computer too. Normal openings advance in two-month steps, but even-month scenarios/saves distinguish this. [rules/turn.bm](../rules/turn.bm), `winter_stops_move:56`; [ai/army.bm](../ai/army.bm), `ai_army_order`. |
| C2 | AI builds onto an existing fleet | Canonical AI does not enforce the player's sea-port check inside Build. | The shared build predicate requires an existing fleet to be off a sea port owned by its side. This can stop AI purchases at river ports, captured ports or neutral ports. Its order loop can now terminate before the old build attempt and random draw. [rules/navy.bm](../rules/navy.bm), `navy_can_build:63`; [ai/navy.bm](../ai/navy.bm), `ai_navy_build` and `ai_navy_adjust`. |
| C3 | Troops on trains in victory checks | `CWSTRAT2.BAS:1761` and `:1763` count only armies with a positive city location. Embarked armies have location 0 and are omitted. | `army_in_field` includes each side's embarked army. This changes annihilation and force-ratio victory decisions, and the associated warnings. [rules/victory.bm](../rules/victory.bm), `victory_forces:6`; [rules/army.bm](../rules/army.bm), `army_in_field:292`. |
| C4 | Troops on trains in AI recruiting decisions | Canonical `smarts` excludes those troops when comparing its own and opposing strength for recruiting. | `ai_count_armies` uses `side_strength`, which includes train passengers. The embarked army still does not count toward its count of city-based armies. [ai/forces.bm](../ai/forces.bm), `ai_count_armies`; [rules/army.bm](../rules/army.bm), `side_strength:298`. |
| C5 | Positive troop counts in inactive, non-embarked slots | Canonical `iterate` sums every army slot when calculating the AI's overall strength ratio, including location 0. | `turn_strength_ratio` uses `side_strength`, which excludes an army with neither a city nor a train. This distinguishes inconsistent/edited saves or otherwise stale slots; train passengers themselves were already included in canonical's overall ratio. [rules/turn.bm](../rules/turn.bm), `turn_strength_ratio:106`. |

## Menus, saves and startup

| ID | Topic | Canonical behavior | Branch behavior and evidence |
|---|---|---|---|
| U1 | Load after creating the first save | The Files menu can set `filel` to 0 but does not restore it when a save appears, keeping Load disabled until a new-game initialization. | Rechecks the disk in both directions, enabling Load after a successful first save. [port/files.bm](../port/files.bm), `saved_games_check:230`; `0e32e1c`. |
| U2 | Resume without successfully loading a game | No save, cancellation, or failure can lead into the main menu without the normal map display. | Returns to the title menu until a game is actually loaded. [cws.bas](../cws.bas), title loop; `0e32e1c`. |
| U3 | F7 in a submenu | Any canonical plain menu accepts F7 and returns 99, which some callers treat as an array index or save slot. | F7 ends a turn only at the main menu. F3 and F4 remain available in plain menus. [ui/menu.bm](../ui/menu.bm), `menu_arrow_key:258`; `0e32e1c`. |
| U4 | Month command availability after Load | Canonical main code tests the Load submenu's returned row; only choosing its first row reopens Troops, Moves and Ships. | Every successful load resets those three command gates, regardless of selected row/slot. [ui/files.bm](../ui/files.bm), `menu_load_game:52`; `0e32e1c`. |
| U5 | Month command availability after Save | Saving in slot 1 can reopen Troops, Moves and Ships through the same returned-row test. | Saving never resets those gates. [ui/files.bm](../ui/files.bm), `menu_save_game:105`; `0e32e1c`. |
| U6 | Esc in Random Events options | The status line can show stale text from an earlier selection, held in main-module `t$`. | Reconstructs the displayed description from the setting currently in force. [ui/options.bm](../ui/options.bm), `menu_option_events:258`; `0e32e1c`. |
| U7 | Saved-game discovery | Canonical uses `*.sav` to determine whether any save exists, although its slot list only enumerates `cws1.sav` through `cws9.sav`. An unrelated `.sav` can enable Load without a valid listed slot. | Only those nine actual slot names count as saved games. [port/files.bm](../port/files.bm), `any_saved_game:238`. |
| U8 | Choosing and retaining a map | Canonical `ALTMAP.BAT` swaps the active files on disk, affecting subsequent launches too. | A Scenario menu follows Start NEW Game when multiple scenarios are listed. Esc returns to the title; one listed scenario skips the menu. The selected scenario remains active for later games in that process, but a fresh process starts with the list's first scenario. No file-swapping batch file is provided. [ui/main_menu.bm](../ui/main_menu.bm), `menu_scenario:175`; [rules/setup.bm](../rules/setup.bm), `game_new:184`; `2ba37f5`, `f97722d`. |
| U9 | Initial random cash when selecting a different scenario | Canonical loads the externally selected map and gives its opening random cash before `RANDOMIZE TIMER`. | Selecting a different scenario runs setup again after `script_start` has seeded the generator. Both opening cash and subsequent random sequence can differ. Repeated scenario changes/restarts also differ in their setup call sequence. [cws.bas](../cws.bas); [rules/setup.bm](../rules/setup.bm), `game_apply_settings:229`; `f97722d`. |
| U10 | Save format and map restoration | Canonical saves begin with numeric month/year/bonus/side data and contain no map identity. They load against whichever map files are installed. | Saves prepend the quoted scenario folder. Loading switches to that scenario's map/leaders when necessary. Unnamed old saves are assigned to the first scenario; an unknown named scenario is refused with a message. **New saves cannot be read directly by canonical**, which expects a numeric first field. [port/files.bm](../port/files.bm), `load_game:126`, `save_game:203`; `fe4d78d`. |
| U11 | No owned city during city-picker arrow navigation | Canonical `newcity` loops indefinitely searching for an owned city on Up/Down. | The search is bounded by `MAX_CITIES` and returns city 0 when none exists. [rules/city.bm](../rules/city.bm), `side_city_step:50`; `d8b845d`. |
| U12 | Enemy Forces in the army report | `CWSTRAT2.BAS:829` prints `INT(aggress! * x)`: the computer's strength ratio times the side's men. The ratio is 0 before the first month's end, so the first turn shows "000". It is computed once a month, and `CWSTRAT.BAS:2621` and `:2626` add .7 when the computer holds fewer than 11 cities. In the Enemy report it multiplies the enemy's men instead. The manual (section 3.9) calls it "the total strength of the enemy forces". | Prints the other side's men in the armies that hold a city, counted as Total Forces counts its own, from the first turn on. The Force summary (F4) already showed every army's strength. [rules/army.bm](../rules/army.bm), `side_troops`; [ui/reports.bm](../ui/reports.bm), `report_armies`. **Uncommitted** (2026-11-14). `TestSideTroops`; `commands` and `union-manassas` recorded again. |
| U13 | Income target in the Victory Conditions menu | `CWSTRAT2.BAS:272` builds "% Total Income" from `vicflag(3)`, the cities rule. The standard map has 80 for both, so it shows the right value by chance. The alternate map shows 70% while the game ends at 60%. | Shows the income rule, `victory_rule(VICTORY_INCOME)`. [ui/reports.bm](../ui/reports.bm), `menu_victory_conditions`. **Uncommitted** (2026-11-14). `war-rebel-altmap` and `war-union-altmap` recorded again. |
| U14 | Victory rules and events in a saved game | Canonical saves neither `vicflag()` nor `emancipate`. A game loaded in a new session can have the Emancipation Proclamation again. One loaded in the same session keeps that session's flag and victory rules, including rules switched off and thresholds raised by playing on. | `save_game` writes the six victory rules, then the events that have happened, by their names in `EVENTS.DAT`. `load_game` clears every event and reads them back; a name `EVENTS.DAT` no longer has is passed over. A save without them, written before this change or by `make_save.py`, loads with the victory rules in memory and no event done. Canonical cannot read the new lines, as for U10. [port/files.bm](../port/files.bm), `save_game`, `load_game`. **Uncommitted** (2026-11-14). `TestSaveGameKeepsVictoryRulesAndEvents`, `TestSaveGameFindsEventsByName`, `TestSaveGameWithoutVictoryRulesLoads`; `files` and `scenario-save` recorded again. |

## DOS presentation, runtime and external files

| ID | Topic | Divergence |
|---|---|---|
| P1 | External title picture | Canonical runs `CWSTITLE.EXE` on its first launch without command-line text. The port omits that picture and its key wait. The internal flags/title/menu remain; a reference image is in `docs/CWSTITLE.png`. [ui/main_menu.bm](../ui/main_menu.bm), `show_title`; `1cff8db`. |
| P2 | Capital-burning picture | Canonical runs `CITYBURN.EXE` on a full-graphics capital capture, then returns to the game map. The port omits the picture and key wait. The later removal of `burn` also removes its extra map redraw. [commands/city.bm](../commands/city.bm), `city_capture`; `1cff8db`, `1727bf9`. |
| P3 | Lincoln picture | Canonical runs `ABELINCO.EXE` during Emancipation. The port keeps the event but omits the external picture and its wait, with the reference image kept in `docs/ABELINCO.png`. [ui/events.bm](../ui/events.bm); `1cff8db`. |
| P4 | F1 help | Canonical menus launch `CWSDOC.COM`, then redraw the map/menu, and the top bar advertises F1. The branch ignores F1 and removes that label; help is read externally from `docs/CWSDOC.TXT` / `docs/CWS.DOC`. [ui/menu.bm](../ui/menu.bm), [ui/screen.bm](../ui/screen.bm); `77136ba`. |
| P5 | Ctrl+B boss screen / screensaver | Canonical Ctrl+B enters `scrnsavr`; Ctrl+B exits it and restores the menu. It also reseeds/consumes the game's random generator. The branch removes this reachable feature and treats Ctrl+B as an unrecognized menu key. `1727bf9` called this dead-code removal, but a user can reach it from canonical menus. Canonical `CWSMENU.BAS:256`, `:487`; [ui/menu.bm](../ui/menu.bm). |
| P6 | Train, cannon and water pixels | The Railroad menu's train uses `U9` in place of `U8`; the cannon wheel arc radius is 27 instead of 29; the two map touchup fills at `(502,160)` and `(108,400)` are omitted. These accommodate QB64 drawing differences but are still visual divergences. [ui/main_menu.bm](../ui/main_menu.bm), [draw/pictures.bm](../draw/pictures.bm), [draw/map.bm](../draw/map.bm); `1cff8db`. |
| P7 | Window sizing | `$RESIZE:STRETCH` permits resizing and scales the 640×480 display; Alt+Enter permits fullscreen. Canonical is a DOS display without this window behavior. [cws.bas](../cws.bas), line 4; `bc7c787`. |
| P8 | Data locations | Canonical opens map/setup/leader/graphics files beside the executable. The branch requires `graphics/`, `scenarios/SCENARIOS.LST`, and per-scenario folders. Old flat installations do not work unchanged. Config, scores, saves and history remain relative to the current working directory. [port/folders.bi](../port/folders.bi), [port/files.bm](../port/files.bm). |
| P9 | Events as editable data / startup failures | Canonical events are embedded in `events`. The branch reads `scenarios/EVENTS.DAT` on each new game, allowing conditions, effects, messages, ordering and chance to be changed without rebuilding. A missing/unreadable file or invalid definition can now stop startup; recognized parse errors report file/line/reason. The supplied definitions otherwise preserve the old event order and chance, apart from the mercenary fix G20. [port/events_file.bm](../port/events_file.bm), [rules/events.bm](../rules/events.bm), [scenarios/EVENTS.DAT](../scenarios/EVENTS.DAT); `6c41775`. |
| P10 | Distributed executable/tooling | A modern single executable replaces the three linked BASIC modules and DOS build/launcher/install/print-help tools. Removed DOS binaries remain on canonical. Building and deploying the new program requires its new folder layout. This is an execution/deployment change, not an additional gameplay-rule change. [README.md](../README.md), [docs/devnotes.md](devnotes.md). |

## Added behavior when test mode is enabled

Canonical has no equivalent of `CWS_SEED`. With it unset, the hooks use normal time, date, sound and random draws; the gameplay differences above still apply. With it set, [port/script.bm](../port/script.bm) adds these divergences:

- A fixed seed replaces `RANDOMIZE TIMER`.
- `CWS_DICE` can supply special-event draws. Consumed forced values replace real random draws, affecting the subsequent generator state too.
- Short timed pauses return immediately. Pauses of at least 99 seconds wait for a key instead of expiring on the timer.
- Audio volume is muted before the title music; later sound statements can still take time.
- New-game history uses the fixed date `01-01-2000`.
- History backup is copied in BASIC instead of executing `SHELL "copy ..."`, avoiding a shell window.
- Keyboard waits write prompt markers to emulated memory for the screen-test driver.

These hooks are intentional test features, not ordinary-play regressions.

## Edge state changed during extraction

Canonical `tupdate` keeps its local battle winner/loser across successive armies' moves. The extracted `turn_attack` initializes them anew for each call. If an inconsistent save gives an occupied city a zero-strength defender, the battle is skipped and the subsequent code can therefore act on different stale/zero army slots. This is a source-level difference on an invalid/inconsistent state, not an established normal-play regression. See [ui/turn.bm](../ui/turn.bm), `turn_attack`, and extraction commit `d7c9378`.

## Regression history and subsequent corrections

These entries retain problems found after the original changes. **Current status: corrected
in the staged working tree, not yet committed**, inspected 2026-11-14. This update inspected
source and test definitions; it did not rerun the tests or recorded games.

| ID | Trigger | Earlier port behavior | Current behavior and evidence |
|----|---------|-----------------------|-------------------------------|
| R1 | Attacker is crushed after a battle | `turn_attack` passed the lost attacker as both loser and winner to `turn_army_surrenders`. The loss helper credited the wrong side and could not transfer supplies to the surviving defender. Canonical credited the defender 25 points in this case, although its supply transfer was zero (G7). | The staged caller passes the surviving defender when the attacker is lost, and the attacking winner when the defender is lost. The winner receives 25 points and the loser's supplies. This restores canonical's point recipient for attacker losses and extends G7's supply fix. [ui/turn.bm](../ui/turn.bm), `turn_attack`, `turn_army_surrenders`; [rules/turn.bm](../rules/turn.bm), `turn_army_lost`. The original failing probe is historical evidence below; runtime verification of the staged caller is not recorded here. |
| R2 | Start another game or change scenario in the same process | `game_reset` left city counts intact, and `load_cities` added the next map's cities. Standard then alternate reported 21 Union cities instead of the alternate map's 10. Canonical's externally selected map starts with its own city count; U8 introduced repeated in-process scenario selection. | The staged `game_reset` clears both sides' city counts before loading. Reports, initial realistic rail capacity and first-turn AI now use the selected map's counts. [rules/setup.bm](../rules/setup.bm), `game_reset`; [tests/rules_test.bas](../tests/rules_test.bas), `TestGameNewCountsOnlyItsScenariosCities` checks both sides across repeated switches. |
| R3 | Mercenary event without a capital or a free army slot | G20's new-army path could use city 0 after the capital was lost, consuming a commander for an army with no city. With no slot, it could announce a reinforcement that formed no army. Canonical placed the reinforcement in scratch army 0 regardless (G20). | The staged `event_possible` requires a capital and either its existing army or a free slot. Otherwise selection continues to the next eligible event; `event_apply` also guards new-army creation against capital 0. [rules/events.bm](../rules/events.bm), `event_possible`, `event_apply`; [tests/rules_test.bas](../tests/rules_test.bas), `TestEventMercenariesNeedTheCapital`, `TestEventMercenariesNeedAnArmySlot`. |

## Original review verification and limits (2026-11-14)

The review followed the commit history from canonical, inspected the original three BASIC sources and include, and checked the changed rule expressions and their current callers. Static findings are tied to the branch commit above. Unrelated working-tree edits appeared during the review; they were left untouched. An exported copy under ignored `tests/out/canonical-review/branch/` was used to separate branch verification from that ongoing work.

- Python tooling/layer checks: **41 passed** on the working tree.
- BASIC rule suite on the exact `d8b845d` snapshot: **188 passed, 0 failed, 0 errors**. A working-tree run that included the new event-reader tests also passed all 190 tests.
- Recorded game checks on the exact `d8b845d` snapshot: **40 passed, 0 failed** with QB64Rust. The separate working-tree run also passed all 40.
- Isolated review probes on the original snapshot: the crushed-attacker, scenario-count and absent-capital expectations **all failed**. R1/R2/R3 above record the later staged corrections; these failures do not describe the corrected working tree.
- An additional probe compared the extracted volunteer-event arithmetic against the canonical expression for initial army sizes 1 through 1250, at event weight 3: it passed. No arithmetic divergence is claimed from storing that event multiplier in the event table.
- The six map/setup/leader files match their canonical standard/alternate counterparts byte for byte. The two canonical leader files themselves are identical, so Git's apparent swapped rename pairing does not change the leaders. `CWS.CFG` and `HISCORE.CWS` have no branch diff.
- The original review changed no game source. Scratch exports, probes and logs are ignored under `tests/out/canonical-review/`. Later source changes and their status are recorded separately above.

The DOS/PDS executable was not replayed side by side, and QB64pe comparison was not rerun. Existing game recordings were rerecorded after intentional rule changes; neither their success nor line coverage proves that every possible play sequence matches canonical. This document records the divergences established by source review and the targeted probes, with inconsistent-state cases identified separately.
