# Local variable, parameter and label names

The renames of phases 4 and 5 covered the shared variables (`variable-names.md`) and the SUBs (`sub-names.md`).
They left the names inside each SUB: its parameters, its `DIM` locals and its `GOTO` labels. Many of these are
still the original's: `chosit`, `star` and `fin`, `xbar`, `slush`, `killd`, labels such as `deadman` and `puter`.

This document listed them, on branch `refactor_naming` at commit `d70ccbb`. Parts 1 and 2, the renames of the
locals and the labels removed, are done, and so is part 3, the constants; they are in
`local-names-completed.md`. What is left: the possible bugs of part 4.

## Rules the proposals follow

These are the rules of `variable-names.md`, used for locals:

- snake_case, and a name says what the value is, not its type.
- The same thing gets the same name in every SUB: an army is `army`, a side is `side`, a city is `city`.
- When a SUB already has that name, the second one says how it differs: `to_city`, `spare_army`.
- QB64 keywords cannot be names. So a color is `side_color` or `dot_color`, never `color`. A width is
  `menu_width`, never `width`. `command$`, `key$` and `line$` are out for the same reason.

Two kinds of name are kept:

- **`i`, `j`, `k` and `n` as loop counters.** Where one holds something else, part 1 lists it.
- **`x` and `y` as a screen position**, in pixels or in text columns and rows. Where one holds a count, a city
  or a strength, part 1 lists it.

A rename inside a SUB touches nothing outside it. The rename can be checked the same way as before:
`tests\rules_test.bas` and the scripts of `tests\play.py` must give the same results. One risk is a local that
gets the name of a shared variable, a CONST, a SUB or a FUNCTION. That would make it hide the shared one, or
not compile. Every proposal below was checked against the 90 shared names in `cws.bi` and against the CONSTs,
SUBs and FUNCTIONs. The shared side is `current_side`, so `side` is free.

## Part 1: local variables and parameters

Done on 2026-11-12. The tables are in `local-names-completed.md`.

## Part 2: `GOTO` and `GOSUB` labels

The labels that only skipped or left a loop were removed on 2026-11-12 (`local-names-completed.md`).

The last five, in `menu_city_select` (`ui\orders.bm`), went the same day when its key loop was rewritten
(`modernize-completed.md`, "the last labels"). No label is left.

## Part 3: constants that read unclearly

Done on 2026-11-12 with the proposed names. The table is in `local-names-completed.md`.

## Part 4: found while reading

None of these is fixed by a rename. Items 1 to 3 and 7 were names that said the wrong thing; part 1b renamed
them, and they are in `local-names-completed.md`. Items 4 to 6, 8 and 9 look like bugs of the original, kept
like the others (decision 3). Fixing one changes how the game plays, so each would be its own decision and a
`TODO.md` row.

4. **`ai_army_order`, the capital check** (`ai\ai.bm` line 148): `neighbor = city_road(city, j): IF j = 0 GOTO
   nocap`. `j` runs from 1, so the test is never true. It most likely meant `neighbor = 0`. As written,
   `city_nearby_enemy_strength(0)` is called for an empty road.
5. **`ai_evaluate_move`, the fort factor** (line 206): `IF city_fort(to_city) = 3 THEN fort_factor = 3`. Forts go up to 2
   (`MAX_FORT`), so the factor is never 3.
6. **`ai_army_order`, "eliminate crossing moves"** (line 158): `IF army_order(other_army) = army_troops`, where
   `army_troops` is the army's size, not a city. It most likely meant the army's city (`city`). As written it matches only by chance,
   so crossing moves are mostly not removed.
8. **`event_roll`, the mercenaries**: `index` is never set, so they join army 0. Already in `TODO.md`.
9. **`ai_fortify`, the Union's cash** (`ai\ai.bm` line 35): `IF side = SIDE_UNION AND fleet_size(SIDE_UNION) < 1
   AND RND > .5 AND side_cash < 222 THEN EXIT SUB`. `side_cash` here is the local scalar, always 0, so the test
   is always true. It most likely meant `side_cash(side) < 222`. The original has the same with `cash`.
