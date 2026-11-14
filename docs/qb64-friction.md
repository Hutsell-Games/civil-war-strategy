# What QB64 made awkward in Civil War Strategy

Started 2026-11-14 for [modernize-plan.md](modernize-plan.md), phase 11 step 5
(requested 2026-11-12). Keep adding evidence as the war's content leaves the engine.
This starts with the port and modernization work already done; phase 11 step 1
has not been completed.

The strongest case so far is for scope and visibility across files. Smaller cases
concern named groups of constants, parameter intent and diagnostics. These are
inputs to a QB64Rust decision, not decisions to add features. The game continues
to use source accepted by both QB64Rust and QB64pe.

## 1. Files do not give names a scope

**Evidence.** [cws.bas](../cws.bas) textually includes the procedure files, and
[cws.bi](../cws.bi) holds their shared declarations and constants. Moving a SUB
to `game\` changes its home but does not give it a private namespace. During the
2026-11-13 predicate extraction, both compilers rejected the proposed FUNCTION
`fleet_at_sea`: it collides with `FLEET_AT_SEA` because names ignore case. The
function is now `fleet_is_at_sea` in [rules/navy.bm](../rules/navy.bm).
The failed name is recorded in the
[completed structure review](archived/structure-review-completed.md), under
"Item 2, the state predicates".

**Cost and current answer.** Names need project-wide coordination. Subject
prefixes such as `army_`, `menu_` and `event_` provide that coordination by
convention; a move between folders provides no isolation.

**QB64Rust question.** Would qualified names and private declarations let a
`game` file and an engine file coexist with fewer coordinated renames? This is
concrete evidence for module scope. It does not establish a need for separate
compilation, a package manager or dynamic plugins.

## 2. Folder boundaries need checks outside BASIC

**Evidence.** Rules and computer decisions once used the menu's shared arrays
and selection as scratch space and results. The completed structure review's
"The menu's globals are a return channel" records the uses and their removal.
Current [rules/army.bm](../rules/army.bm), `army_list_combine_cities` and
`army_recruit_cities`, fill caller-provided arrays instead.
[tests/test_layers.py](../tests/test_layers.py) checks forbidden calls, screen
statements and access to menu state. Its `ALLOWED` table is currently empty.

**Cost and current answer.** `OPTION _EXPLICIT` catches undeclared names, but
does not stop rules from using declared UI state. The Python check enforces the
project's boundaries by reading source text. It is an additional tool to maintain.

**QB64Rust question.** Private state and explicit imports could enforce access
to names at compilation. This needs more than namespaces alone. A module system
would not automatically prohibit drawing or keyboard input; those restrictions
would still need a project check or a separately designed compiler facility.

## 3. The application and tests assemble the same source twice

**Evidence.** [cws.bas](../cws.bas) and
[tests/rules_test.bas](../tests/rules_test.bas) each list the procedure includes.
Both include `cws.bi`, including declarations for menus, pictures and test hooks.
[devnotes.md](devnotes.md), items 1 to 3, records why the original three linked
BASIC modules became one included program and why procedures and picture arrays
had to be moved so tests could include them without the main loop.

**Cost and current answer.** A file move must update both entry points. The
[modernization archive](archived/modernize-plan-completed.md), phase 9 step 7,
records a preceding commit that renamed files without updating the includes;
the next step repaired the build. Explicit include lists currently keep the
application and test program assembled correctly.

**QB64Rust question.** Could a module declare its own dependencies so application
and test entry points import the same unit? Dependency handling would address
this cost; scoped names alone would not. This example does not measure a build
speed benefit from separate compilation.

## 4. Groups of constants still share the integer domain

**Evidence.** `cws.bi` groups constants for menu results, event effects,
condition subjects, relations, redraw modes and victory rules. For example,
`REDRAW_NONE`, `REDRAW_FLEETS` and `REDRAW_MAP` describe `event_redraw()`, while
`VICTORY_MONTH` through `VICTORY_WIPED_OUT` describe victory results. These values
are stored and passed as ordinary integers. The completed structure review
explicitly identified the lack of `ENUM` as an input to this list.

**Cost and current answer.** Prefixes and comments identify the groups; their
membership is not expressed in the variable or parameter type. A wrong group's
integer can look valid. This is a maintenance risk, not a recorded failure here.

**QB64Rust question.** Would named enum groups improve declarations and checks?
Distinguish scoped integer constants from checked enum types: only the latter
would diagnose mixing groups. Preserve the numeric values used by files. Mixed
city-or-state values such as `fleet_city()` need a separate decision; an enum
alone would not model their full range.

## 5. Call syntax does not identify inputs and outputs

**Evidence.** [rules/battle.bm](../rules/battle.bm), `battle_fight`, returns
`winner`, `loser` and `rounds` through parameters; `battle_strengths` fills two
arrays. [rules/army.bm](../rules/army.bm), `army_generate_name`, changes both its
army argument and its name result. `TestRomanChangesItsTarget` in the rule suite
pins that mutation. Calls such as `menu_army_recruit((current_side))` in
`cws.bas` use an expression to pass a copy of shared state.

**Cost and current answer.** A reader must consult the procedure to learn which
arguments change. Pure single-result procedures have become FUNCTIONs; commands
that change state and return a status remain SUBs. Multiple outputs and array
results remain explicit parameters.

**QB64Rust question.** Would parameter intent declarations or diagnostics make
these contracts clearer? Multiple return values are another possibility, but
these examples do not choose a syntax or justify converting state-changing
commands into expressions. Default reference passing remains necessary for
existing programs.

## 6. A scalar and an array can conceal a mistaken reference

**Evidence.** [ai/forces.bm](../ai/forces.bm), `ai_fortify`, explicitly declares
local scalar `side_cash`, while the shared array is also named `side_cash()`.
The fortification stop test reads the scalar, which stays zero, rather than
the side's funds. The comment preserves this original behavior. The
modernization archive's phase 10 notes also record this distinction.

**Cost and current answer.** Declaring the scalar satisfies `OPTION _EXPLICIT`
while preserving a misleading name. This is a known behavior kept by the
refactor, not a new fix to make as part of this list.

**QB64Rust question.** An optional warning for a same-named scalar and visible
array, or a local never assigned before it is read, could expose this case.
Whether an existing warning already covers it should be checked before adding
one. Namespaces alone would not resolve an explicitly declared local scalar.

## 7. Editable events require a parser and a shared table

**Evidence.** [port/events_file.bm](../port/events_file.bm) parses event names,
conditions, effects and chance factors into the parallel arrays in `cws.bi`.
Its `text_is_number` validates numbers before conversion, and `load_events`
reports recognized definition errors through shared `event_file_error$`.
[rules/events.bm](../rules/events.bm) consumes the resulting table.

**Cost and current answer.** Moving events to data removed the need to rebuild
for content edits, but introduced parsing, limits and validation code. Some of
that work is inherent in the chosen event format. Private table state and a
clear loader result could improve the interface; modules would not remove the
parser.

**QB64Rust question.** Keep this as evidence to revisit if other ports repeat
the same parsing work. It does not yet justify a new language feature or a
general serialization library.

## Findings that do not justify modules or records

- **Records already work.** Phase 10's
  [record trials](archived/modernize-plan-completed.md) measured strings, field
  arguments, copies, swaps and file input in both compilers. Records were
  reverted because longer field expressions bought little and whole-record
  copying would change which fields the game preserves. Shared arrays stay
  arrays, as decided on 2026-11-12.
- **War-specific choices still need design work.** Fixed city numbers, side
  privileges and Civil War rule constants would remain war-specific inside a
  module. Moving them behind a module name does not satisfy the second-war test.
- **DOS compatibility is a separate concern.** The GOSUB-stack and drawing
  differences measured in [the port archive](archived/devnotes-completed.md)
  required control-flow and pixel adjustments. They are evidence for
  compatibility work, not module scope.

## Keeping the evidence current

For each phase 11 step, add a concrete procedure or file, the obstruction, the
workaround used, and the smallest capability that might remove it. Keep resolved
examples and their outcomes. Record compiler trials with their versions when a
feature decision depends on compiler behavior.

The next additions should come from moving the map, pictures and rule constants
in step 1, and the remaining presentation and texts in steps 2 and 3. Keep those
observations separate from this initial evidence; those moves have not happened
yet. Revisit the QB64Rust feature decision when the engine split has a concrete
interface to assess.
