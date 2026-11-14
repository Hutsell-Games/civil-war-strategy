# Plan: modernize the code of Civil War Strategy

Started 2026-11-11; active plan updated 2026-11-14. Completed work, the original numbered
decisions and phase table, and historical surveys are in
[the archive](archived/modernize-plan-completed.md).

## Goal

Make the code clean enough for future work, without changing how the game plays or looks.
This plan cleans Civil War Strategy and gathers the war's content apart from the engine.
Splitting the engine into a separate project is a second plan.

## Where to resume

Phases 0 to 10 are complete; phase 10 closed with no records. Phase 11 is the remaining phase.
Its event data and rules are already in `scenarios\EVENTS.DAT` (archive, "Phase 11 step 2").
Step 4's named inventory is complete below; it makes no decision about moving rules.
Step 5's [QB64 friction list](qb64-friction.md) is started with evidence from the work
already done; keep it current through the remaining content moves.
Questions 2 and 3 below remain open before steps 1 and 3. The later structural cleanups
have their own [active review](structure-review.md).

## Current decisions and working rules

- **QB64, built by both compilers.** Use nothing accepted only by QB64Rust. The DOS source
  stays on `canonical-source`.
- **Refactors keep recorded screens identical.** Run `play.py check`, `play.py compare` and
  the unit tests. Preserve the order of random draws and screen statements. A deliberate
  behavior or screen change is a separate commit; record only the scripts whose checkpoints
  differ and list them in the commit message. Remaining known bugs are in `TODO.md`.
- **One reviewable step per commit.** Run the checks and hand over a commit message; the user
  stages and commits. Keep rename and move scripts and their tables in `tools\refactor\`.
- **Keep the rule-change record current.** Record every rule or observable behavior change
  from the canonical game in [rule-changes.md](rule-changes.md), including bug fixes and
  resolved regressions, in the same change as the code. Keep its IDs and history permanent.
- **Names and declarations.** Shared variables and parameters use snake_case, with the subject
  first (`army_size`, `city_owner`). Constants use uppercase group prefixes (`SIDE_UNION`).
  `OPTION _EXPLICIT` stays on. Rename locals when their procedure is reworked; loop counters
  `i`, `j`, `k` may stay.
- **Folder responsibilities.** Rules and computer decisions draw nothing, print nothing and
  read no key. Commands carry out orders for the player or computer and may show results,
  but open no menu and read no key. Menus and other screens live in `ui\`.
  `tests\test_layers.py` enforces these boundaries and records the remaining exception.
  [file-layout.md](file-layout.md) lists the current files and procedures.

The original numbered decisions are preserved in the archive under "Original plan: baseline,
decisions and phases".

## Which model does which phase

Phase 11, the one phase left, is marked for Fable: `DRAW` and `PAINT` depend on order; expect several
tries. **When the next step is one marked Opus or Fable, stop and tell the user to switch model** before
starting it. The table for every phase is in `archived\modernize-plan-completed.md`, "Which model did which phase".

## How a SUB is split

- Put pure rule work in `rules\` and pure computer decisions in `ai\`. Return what the caller
  needs through parameters or a FUNCTION; do not use the menu's globals as a return channel.
- Keep screen work in `ui\` and drawing helpers in `draw\`; put commands shared by the player
  and computer in `commands\`. Screen code delegates game-state changes to rules or commands.
- Preserve statement order, random draws, cursor position and color across the split. Return
  a count when a rule's repeated work determines how many sounds or animations to play.
- Give result codes named constants when callers distinguish several outcomes. Keep simple
  flags and one-use formula factors as they are unless changing them improves readability.
- Replace `GOSUB` routines with SUBs or FUNCTIONs. Replace `GOTO` when it obstructs a split;
  a short local jump in a clear SUB may stay.

## How a menu is split

- Use one `menu_` SUB per menu and entry in `ui\`. It fills the menu, calls `menu_select`,
  and delegates the chosen action to rules or commands.
- A menu changes no shared game state itself. Change a setting before showing its new value.
- A menu that shows again is a loop; an entry that finishes uses `EXIT SUB`.
- Set the starting row where the menu is filled. Keep a value needed between calls as a local
  `STATIC` when it belongs to that menu.
- Preserve remaining known oddities explicitly, with a unit test or a `TODO.md` entry.

## Lines that no test runs

Phase 0 measured the coverage and added the scripts (`archived\modernize-plan-completed.md`, "Phase 0: coverage").
The coverage rule still holds for new changes:

- Before the step, read `tests\out\coverage\report.txt` for the lines the step moves or rewrites.
- A line that no test runs is either reached first by a new script or unit test, or moved whole with no
  change inside it. The hand-over names the lines that moved without a test.
- A step that must rewrite lines no test runs waits for tests that reach them.

The last recorded inventory lists 11 lines that no test runs. The table names the SUB rather
than line numbers, because refactors move them; consult a fresh `report.txt` before changing them.

| File | SUB | Lines | Why |
|------|-----|-------|-----|
| `rules\setup.bm` | `vary_start_conditions` | 2 | The Rebels' army removed by Vary Start; no script's draw removes one. |
| `ai\navy.bm` | `ai_fleet_orders` | 2 | The `ELSE` for a fleet at sea; a fleet at sea already left a few lines before |
| `ai\navy.bm` | `ai_fleet_orders` | 1 | The Union computer's first fleet, started at city 30 against a Rebel player. |
| `ai\army.bm` | `ai_attack_score` | 1 | `odds! = 5`: an army of size 0 that still holds a city; no game makes one |
| `rules\battle.bm` | `battle_losses` | 1 | The losses of a defender of more than 80,000 men; no script has one. |
| `ai\forces.bm` | `ai_fortify` | 1 | The Union computer stops fortifying when it has no fleet. |
| `ai\navy.bm` | `ai_navy_raid` | 1 | The computer's fleet goes raiding and meets no enemy at sea. It raids only in answer to the player's raiders, which are at sea |
| `ui\city.bm` | `menu_city_select` | 1 | `CASE ELSE` of the picker's menu; the menu returns only a key, 1, 2 or 3 |
| `ui\reports.bm` | `report_armies` | 1 | The army report when both sides have 0 victory points; a side gets points for its cities at the start |

Of the 178 lines run in part, most are a one-line `IF` whose `THEN` part did not run, or a sound that plays
only with the sound on. In `rules\events.bm` one is left: the riot's early return for a side with one city.

A step that rewrites a line still looks that line up in `tests\out\coverage\report.txt`
first (`play.py coverage`).

## Phase 11: the war's own content

Drafted 2026-11-12. Question 1 answered 2026-11-13: data files
(`archived\modernize-plan-completed.md`). Questions 2 and 3 are still open.

### The test of this phase

This phase has one test of its own: **a second war is made by replacing `game\` and `scenarios\`, and
nothing else.** A step is worth doing when it moves something that fails that test. A step that
only moves text around is not.

### What remains

The original 2026-11-12 survey is in the archive under "Phase 11: the original survey".
The remaining work covers the map and flags, the title and ship pictures, war-naming texts,
the two event tunes and presentation details, and the war's rule constants. The side-specific
rules are inventoried below; deciding whether to move them belongs to the engine split.

### Steps, as proposed

1. **Move what is the war's and is already a SUB**: the flags, the map's line work, the title,
   the cannon and the two ship pictures go to `game\`, whole (as phase 6 moved SUBs). The ten
   rule constants go to a `game\rules.bi`.
2. **Remaining event presentation.** The event data and rules are completed in the archive
   ("Phase 11 step 2"). Still in `ui\events.bm`: the two `PLAY` tunes, the alarm of an
   announcement, and the bottom line cleared only for an event of the Union's roll.
3. **The other 24 texts**, each looked at: a text that only uses `side_name$()` already passes
   the test; one that spells "Union" does not. Those that fail go to a data file too (question 1).
4. **Complete, 2026-11-14: list the rules that treat the sides differently**, with a name for
   each. See "Step 4: named inventory" below. Whether they move is a question for the engine
   split, not for this phase.
5. **Started, 2026-11-14: [a list of what QB64 made awkward](qb64-friction.md)**,
   seeded from the port and modernization work already done. Keep it current from step 1
   on. It is the evidence for whether QB64Rust should gain modules or another feature
   (user, 2026-11-12); no feature decision has been made.

### Open questions

2. **The map's line work: code in `game\`, or a data file read by a small drawer?** Decision 19
   says a data file.
3. **Are steps 1 to 4 the right size**, given the test above, or should the phase stop after
   step 2?

### Step 4: named inventory

Completed 2026-11-14 against the current source. These are names for the inventory, not new
constants or procedures. No rule was moved or changed. The archived survey's "not yet counted"
entry is the historical starting point; this inventory supersedes it.

Reviewed `rules\`, `ai\`, their callers in `commands\` and `ui\`, setup and loading in
`port\files.bm`, and `scenarios\EVENTS.DAT`. The tables include explicit side tests, arithmetic
using a side number, fixed city references, and ordering that gives one side precedence.
Locations name the procedure so they survive changes to line numbers. There are 26 named
code rules below, followed by the 17 side-specific event entries already in data.

#### Army, navy, economy and balance

| Name | Current difference | Location |
|------|--------------------|----------|
| Union starting supplies | A newly raised Union army gets two extra supply above `3 + 5 * RND`. | [rules/army.bm](../rules/army.bm), `army_raise` |
| Rebel starting experience | A newly raised Rebel army starts at experience 2; a Union army starts at 1. | `rules/army.bm`, `army_raise` |
| Rebel detach privilege | Only the Rebels may detach part of an army. | `rules/army.bm`, `side_can_detach`; [ui/army.bm](../ui/army.bm), `menu_army_detach` |
| Union realistic naval invasion | With Realism on, only the Union may land an army from a fleet. With it off, either side may. Both still need at least two ships off a neutral city. | [rules/navy.bm](../rules/navy.bm), `navy_can_invade` |
| Railroad city baselines | With Realism on, capacity changes by 5 hundred men per city above or below 11 for the Union, 23 for the Rebels. Both use the same limits: half to twice their configured capacity. | [rules/railroad.bm](../rules/railroad.bm), `railroad_capacity` |
| Union computer income bonus | `union_income_bonus` is `120 * opt_difficulty` (50 instead of 120 with two players), reduced to 70% with Realism. Monthly collection actually adds it only in a one-player game with a Rebel player. It also enters the initial `total_income = union_income_bonus + 200`. | [rules/setup.bm](../rules/setup.bm), `set_union_advantage`; [rules/turn.bm](../rules/turn.bm), `turn_collect_income`; [port/files.bm](../port/files.bm), `load_cities` |
| Side-directed balance help | Above Even favors the Union computer; below Even favors the Rebel computer. `balance_help` returns the distance from Even only for that favored computer side. Starting cash uses `100 * (DIFFICULTY_EVEN + help)` when help is positive; recruitment adds `5 * help` hundred men; battle strength adds `2 * help`. | `rules/setup.bm`, `balance_help`, `game_apply_settings`; `rules/army.bm`, `army_recruit_bonus`; [rules/battle.bm](../rules/battle.bm), `battle_strengths` |
| Side-directed event weight | Event weight is `6 - opt_difficulty` for a Union player, `opt_difficulty` for a Rebel player. It controls event chance and effects multiplied by weight. | [rules/events.bm](../rules/events.bm), `event_roll`, `event_chance!`, `event_apply` |
| Event beneficiary selection | A roll at or below `.1 * opt_event_balance` favors the Rebels; above it favors the Union. The option maps Favor Union/Neutral/Favor Rebels to 3/5/7; changing side or applying settings defaults to favoring the computer (7 for a Union player, 3 for a Rebel player). `event_side` names the disadvantaged side. | `rules/events.bm`, `event_roll`; `rules/setup.bm`, `option_set_event_balance`, `option_events_favor_computer`, `game_apply_settings` |

#### Starting conditions and settings

| Name | Current difference | Location |
|------|--------------------|----------|
| Vary Start cash offsets | Union cash becomes scenario cash minus 100 plus `200 * RND`; Rebel cash becomes scenario cash plus 100 plus `200 * RND`. | `rules/setup.bm`, `vary_start_conditions` |
| Vary Start fleet locations | Both fleet sizes are redrawn with `10 * RND`. A zero Union fleet clears its location; otherwise its scenario location stays. A positive Rebel fleet is placed at city 27; otherwise its scenario location stays. | `rules/setup.bm`, `vary_start_conditions` |
| Vary Start Rebel capital | On `RND > .7`, only the Rebel capital changes, to city 25. The Union capital stays as loaded. | `rules/setup.bm`, `vary_start_conditions` |
| Vary Start player-dependent ironclads | For both fleets, a ship is ironclad when `RND > .45 * current_side`: the threshold is .45 for a Union player, .9 for a Rebel player. This depends on the player's side, not the fleet's side. | `rules/setup.bm`, `vary_start_conditions` |
| Union first player | A two-player game starts with the Union, then the Rebels give orders before the month resolves. A missing player side also defaults to Union. | `rules/setup.bm`, `game_apply_settings`; `rules/turn.bm`, `turn_check_commands`, `turn_next_player` |
| Rebel-player Realism event adjustment | Turning Realism on adds 2 to event balance only for a Rebel player with `opt_event_balance = 1` (the further `< 5` test is redundant). The current event menu sets only 0/3/5/7, so this is a legacy setting path, not the usual option behavior. | `rules/setup.bm`, `option_toggle_realism` |

#### Computer decisions

| Name | Current difference | Location |
|------|--------------------|----------|
| Union first ship before recruiting | A Union computer with no ships and more than `COST_SHIP` cash tries to build before recruiting. There is no corresponding Rebel branch. | [ai/forces.bm](../ai/forces.bm), `ai_raise_forces` |
| Union first fleet at city 30 | Against a Rebel player, a Union computer with neither fleet nor ships, ownership of city 30 and more than `COST_SHIP` cash sets its fleet location to 30 and tries to build. | [ai/navy.bm](../ai/navy.bm), `ai_fleet_orders` |
| Union fortification stop without ships | After fortifying, a Union computer with no ships may stop on `RND > .5` and local `side_cash < 222`. That scalar is always zero; it is not the shared cash array. This records the existing quirk. | `ai/forces.bm`, `ai_fortify` |
| Player-dependent computer army limit | Recruiting stops when the adjusted army count exceeds `2 + 3 * current_side + 3 * RND`: `5 + 3 * RND` for the Rebel computer facing a Union player, `8 + 3 * RND` for the Union computer facing a Rebel player. | `ai/forces.bm`, `ai_raise_forces`, `ai_count_armies` |
| Computer march direction | A Rebel computer gets 2 extra move-score points for decreasing map y (toward the Union); a Union computer gets them for increasing y (toward the Rebels). | [ai/army.bm](../ai/army.bm), `ai_evaluate_move` |
| Computer rail direction | Among otherwise eligible rail destinations, the Rebel computer selects decreasing map y, the Union computer increasing y. Fort and capital choices can override this preference. | [ai/railroad.bm](../ai/railroad.bm), `ai_railroad_city` |
| Rebel fleet holds at city 30 | At the end of port selection, a Rebel fleet already at city 30 selects 30 again on `RND > .5`, so it stays. Earlier returns from port selection bypass this test. | `ai/navy.bm`, `ai_pick_port` |
| Union fleet reference for invasion | The computer's invasion decision checks enemy strength below 100 at the Union fleet's location, even when deciding for the Rebels. Rebel invasion eligibility still requires Realism off. | `ai/navy.bm`, `ai_navy_adjust`; `rules/navy.bm`, `navy_can_invade` |

#### Order and victory

| Name | Current difference | Location |
|------|--------------------|----------|
| Union precedence within a move priority | Move keys include the army slot as their last two digits. Within the same priority band, Union slots 1–20 sort before Rebel slots 21–40. This also orders armies forced into the out-of-supply band. | `rules/turn.bm`, `turn_set_move_order`; `rules/army.bm`, `sort_move_order`, `side_first_army`, `side_last_army`; [ui/turn.bm](../ui/turn.bm), `turn_resolve` |
| Union first victory check | Victory checks run Union then Rebel and stop at the first met condition. This gives the Union precedence when both qualify, including the shared time-limit condition. | [ui/victory.bm](../ui/victory.bm), `check_victory_conditions`; [rules/victory.bm](../rules/victory.bm), `victory_rule_met` |
| Rebel technical victory | Accepting the time limit announces a Confederate technical victory and draws the Rebel victory screen; both sides' points are multiplied by .7. The recorded `victory_reason` still receives the side passed by the first victory check, normally Union. Preserve this distinction when considering the engine split. | `ui/victory.bm`, `end_game`; `rules/victory.bm`, `victory_won`, `victory_technical_points` |

#### Named event rules already in data

The side-specific event rules are already named by their section in
[scenarios/EVENTS.DAT](../scenarios/EVENTS.DAT). The table records each, including silent and
chained entries. These are conditions within the event-selection process, not guaranteed
calendar triggers: announcements run first, otherwise the chance and beneficiary rolls must
pass. Events are tried in file order; silent effects continue the search, and the first
eligible event with text ends it. Effects must also be possible.
Cash, ships and reinforcement amounts below multiply by event weight; army sizes are in
hundreds. Other effects do not multiply by weight unless stated.

| Name (data section) | Side and rule |
|---------------------|---------------|
| `bonus 1864` | Rebels: in January 1864, silently add 50 victory points and continue searching. |
| `bonus 1865` | Rebels: in January 1865, silently add 100 victory points and continue searching. |
| `riots` | Normally favors Rebels on a roll above .9; with Realism, an unoccupied city the enemy captured from another owner can turn neutral. Also reached as a Union-favoring substitute from `shipworks`, then targets a Rebel-held city. |
| `english ships` | Rebels: roll at most .2; add 2 wooden ships times weight and place the fleet at a delivery sea port. |
| `mercenaries` | Rebels: roll at most .1 and at least 30 cities; reinforce an army at the capital by 100 times weight, with full experience and supply. Skipped when the side has no capital, or no army there and no free army slot. |
| `loan` | Rebels: roll at most .3 and at least 12 cities; add 100 cash times weight. |
| `cotton` | Rebels: roll at most .5 and at least 12 cities; add 100 cash times weight. |
| `uprising` | Rebels: fallback event reduces all Union armies to .9 of their size, unless replaced by `furloughs`. |
| `furloughs` | Rebels: unlisted substitute for `uprising` after May 1864, within 1864; reduces Union armies to .8 instead. |
| `shipworks` | Union: roll at most .1; add 1 wooden ship times weight to an existing fleet. A further roll above .95 substitutes `riots` if possible. |
| `volunteers` | Union: roll at least .7; each of the first five Union army slots with men, on its own roll above .5, becomes `1.1 * size + weight`. |
| `emancipation` | Union: once, after 1862; add 100 Union victory points and subtract 100 Rebel points. |
| `reelection` | Union: November 1864; halve Rebel victory points. |
| `donations` | Union: roll above .5; add 100 cash times weight. |
| `deserters` | Union: roll above .5 after 1861; multiply every Rebel army's size by .92. |
| `rifles` | Union: roll above .5 after 1861; add 2 experience to each Union army only if the result is at most the maximum, then also apply `stanton`. |
| `stanton` | Union: add 10 victory points. It is both chained from `rifles` and the listed fallback Union event. |

#### Boundaries of the inventory

- Scenario differences in starting armies, leaders, cash, fleets, capitals, city ownership and
  configured railroad capacities are already data in `scenarios\`. They are not separate code
  rules; the Vary Start overrides and hard-coded railroad baselines above are.
- Equal treatment written twice is not a side-specific rule: force ratios, casualties,
  city bonuses, the victory-point floor, supply costs and ship combat use the same rules for
  both sides. The old one-sided victory-point floor and Vary Start army-removal bug have
  already been fixed; they are not current differences.
- Slot partitioning and names alone are representation, not unequal rules. Slot order is
  included above where it changes move precedence. Colors, flags, tunes, labels and screen
  layout belong to presentation steps 1–3, including the Union-roll event-line clear and
  the side-dependent Balance display. `calculate_battle` also has an extra-key-wait predicate
  whose Rebel-player branch is outside the one-player guard; this is a presentation quirk,
  not a combat-strength rule.
- This completes the inventory only. It neither approves moving these rules nor changes
  their behavior; those decisions belong to the engine split.
