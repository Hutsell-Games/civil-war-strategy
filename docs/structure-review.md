# Review: the structure of the game's code

Remaining work from the reviews of 2026-11-13 and 2026-11-14. The original findings,
recommendations, resolved decisions and completed changes are in
[the archive](archived/structure-review-completed.md). Updated 2026-11-14.

## Remaining from the first review: city numbers in the code

Move city-specific behavior out of the engine's code, so that a second war replaces only `game\`
and `scenarios\` (phase 11 of `modernize-plan.md`). The first review named four uses; a count on
2026-11-14 found 11 in three files.

The rules' and the computer's four are named constants since 2026-11-14 (user: "make constants
now", 2026-11-14, rather than wait for the engine split as step 4 of `modernize-plan.md` said).
They sit in the group of the war's own numbers in `cws.bi`, which step 1 moves to `game\`:

| Constant | City | Used in |
|----------|------|---------|
| `VARY_REBEL_FLEET_CITY` | 27 New Orleans | `rules\setup.bm`, `vary_start_conditions` |
| `VARY_REBEL_CAPITAL` | 25 Montgomery | `rules\setup.bm`, `vary_start_conditions` |
| `AI_UNION_FLEET_CITY` | 30 Philadelphia | `ai\navy.bm`, `ai_fleet_orders` |
| `AI_REBEL_HOLD_CITY` | 30 Philadelphia | `ai\navy.bm`, `ai_pick_port` |

Still to move are the map's seven uses in `draw\map.bm`. They go with the map's line work in step 1,
so open question 2 decides where they live:

- `draw_fleets`: fixed icon positions for a fleet at 30 Philadelphia, 28 Norfolk and 17 Jackson MS,
  and a shifted icon at 24 Mobile.
- `draw_map`: the box drawn when a fleet is at 30.
- `draw_map_marker`, `MARK_ERASE_ARMY`: erasing an army at 27 New Orleans or 28 Norfolk redraws the
  coast (`draw_map_touchup`).

A constant of 0 would not turn a rule off: `city_owner(0)` is a real element, which
`rules\navy.bm` writes. A second war that drops one of these rules needs a guard then.

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
