# Review: the structure of the game's code

Remaining work from the reviews of 2026-11-13 and 2026-11-14. The original findings,
recommendations, resolved decisions and completed changes are in
[the archive](archived/structure-review-completed.md). Updated 2026-11-14.

## Remaining from the first review: city numbers in the code

Move city-specific behavior into the scenario's data, so that a second war replaces only `game\`
and `scenarios\` (phase 11 of `modernize-plan.md`). City 30 is still used in `ai\navy.bm` and
`draw\map.bm`, city 27 in `rules\setup.bm`, and city 24 in `draw\map.bm`.
The layer check, state predicates, single-value FUNCTIONs, removal of menu globals from the
rules and computer, and shared victory-point calculation are completed in the archive.

## The third review: the size of files and procedures

Written 2026-11-14. It asked whether procedures should be broken up or filed elsewhere. Of 388
procedures, 276 are 25 lines or fewer and 11 are over 100. The user took its order ("do file
splits", then "continue", 2026-11-14). What is done is in `archived\structure-review-completed.md`.

Still to do, each a commit that keeps every screen:

1. **`menu_city_select`** (`ui\city.bm`, nesting 6 deep): three loops that step to the side's next
   city become one FUNCTION.
2. **`load_events`** (`port\events_file.bm`, 123 lines): the checks after the file is read.
3. **The fort command.** `ai_fortify` calls `draw_fort_built` (`ui\city.bm`), the one exception of
   `tests\test_layers.py`. A command `city_fortify` in `commands\city.bm` would remove it.
4. **The computer's enemy as a parameter.** `ai_evaluate_move`, `ai_railroad_city` and
   `city_nearby_enemy_strength` read the enemy from `current_side`; the other `ai_*` take `side`.

Left alone: `battle_strengths` (see the deferred items below), `menu_utility`, `report_armies` and
`end_game`, which are long but read top to bottom, and the four pictures drawn line by line
(`draw_map`, `draw_schooner`, `draw_ironclad`, `draw_surrender`).

## Deliberately deferred from the second review

The user accepted the pragmatic engineer's plan on 2026-11-13. These items were left out:

- **The two halves of `battle_strengths`** share three steps. It is one SUB read top to bottom, in the
  order of the right panel; helpers would make one battle harder to follow and risk its rounding.
- **The sea ports of a side** (`navy_list_shipyards`, `event_delivery_port`, `navy_retreat_port`): their
  tests differ in three ways, so one FUNCTION would need a parameter for each.
- **Small repeats**: the menus' lists in `ui\army.bm` and `ui\city.bm`, the three ways of shortening an army's name,
  the two-row menus, the road loops' three ways of stopping, the cannon's sound and the `"00"` texts.
  Each is done when its SUB is next changed for another reason.
