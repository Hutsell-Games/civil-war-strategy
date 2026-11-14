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

## Deliberately deferred from the second review

The user accepted the pragmatic engineer's plan on 2026-11-13. These items were left out:

- **The two halves of `battle_strengths`** share three steps. It is one SUB read top to bottom, in the
  order of the right panel; helpers would make one battle harder to follow and risk its rounding.
- **The sea ports of a side** (`navy_list_shipyards`, `event_delivery_port`, `navy_retreat_port`): their
  tests differ in three ways, so one FUNCTION would need a parameter for each.
- **Small repeats**: the menus' lists in `ui\army.bm` and `ui\city.bm`, the three ways of shortening an army's name,
  the two-row menus, the road loops' three ways of stopping, the cannon's sound and the `"00"` texts.
  Each is done when its SUB is next changed for another reason.
