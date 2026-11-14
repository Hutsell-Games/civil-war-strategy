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
Questions 2 and 3 below remain open before steps 1 and 3–4. The later structural cleanups
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
- **Names and declarations.** Shared variables and parameters use snake_case, with the subject
  first (`army_size`, `city_owner`). Constants use uppercase group prefixes (`SIDE_UNION`).
  `OPTION _EXPLICIT` stays on. Rename locals when their procedure is reworked; loop counters
  `i`, `j`, `k` may stay.
- **Arrays stay arrays.** Phase 10 closed without records. The saved-game format is kept
  except for the scenario name added as its first field by the scenario plan.
- **War content belongs in `game\` or `scenarios\`.** Texts go into data files. Original
  decision 19 also specifies data for the map's line work; phase 11 question 2 remains open.
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
| `rules\setup.bm` | `vary_start_conditions` | 2 | The Rebels' army removed by Vary Start; no script's draw removes one. The loop never ran until 2026-11-13 (`FOR k = 21 TO 6`) |
| `ai\navy.bm` | `ai_fleet_orders` | 2 | The `ELSE` for a fleet at sea; a fleet at sea already left a few lines before |
| `ai\navy.bm` | `ai_fleet_orders` | 1 | The Union computer's first fleet, started at city 30 against a Rebel player. `ai_raise_forces` builds the first ship before it. It was the `THEN` part of a one-line `IF` until 2026-11-12 |
| `ai\army.bm` | `ai_attack_score` | 1 | `odds! = 5`: an army of size 0 that still holds a city; no game makes one |
| `rules\battle.bm` | `battle_losses` | 1 | The losses of a defender of more than 80,000 men; no script has one. The case came after `CASE IS > 300` until 2026-11-13 |
| `ai\forces.bm` | `ai_fortify` | 1 | The Union computer stops fortifying when it has no fleet. Since 2026-11-13 a computer without a fleet builds one in the same turn (`ai_fleet_orders`), so no script's computer fortifies without one. A game can still reach it: the Union's fleet sunk in the player's turn, before the computer fortifies |
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

Phase 10 showed that a change can pass every test and still not make the code better. So this
phase has one test of its own: **a second war is made by replacing `game\` and `scenarios\`, and
nothing else.** A step is worth doing when it moves something that fails that test. A step that
only moves text around is not.

### What remains

The original 2026-11-12 survey is in the archive under "Phase 11: the original survey".
The remaining work covers the map and flags, the title and ship pictures, war-naming texts,
the two event tunes and presentation details, and the war's rule constants and side-specific rules.

### Steps, as proposed

1. **Move what is the war's and is already a SUB**: the flags, the map's line work, the title,
   the cannon and the two ship pictures go to `game\`, whole (as phase 6 moved SUBs). The ten
   rule constants go to a `game\rules.bi`.
2. **Remaining event presentation.** The event data and rules are completed in the archive
   ("Phase 11 step 2"). Still in `ui\events.bm`: the two `PLAY` tunes, the alarm of an
   announcement, and the bottom line cleared only for an event of the Union's roll.
3. **The other 24 texts**, each looked at: a text that only uses `side_name$()` already passes
   the test; one that spells "Union" does not. Those that fail go to a data file too (question 1).
4. **List the rules that treat the sides differently**, with a name for each. Whether they move
   is a question for the engine split, not for this phase.
5. **A list of what QB64 made awkward**, kept from step 1 on. It is the evidence for whether
   QB64Rust should gain modules or another feature (user, 2026-11-12).

### Open questions

2. **The map's line work: code in `game\`, or a data file read by a small drawer?** Decision 19
   says a data file.
3. **Are steps 1 to 4 the right size**, given the test above, or should the phase stop after
   step 2?
