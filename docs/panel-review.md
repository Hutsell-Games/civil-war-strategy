# Panel review of the code, 2026-11-14

A review of branch `refactor_naming` at `846b079`, after phases 0 to 10 of
[modernize-plan.md](modernize-plan.md). It asks where the biggest opportunities are and what is
not worth doing. Nits are left out. Its findings that are done are in
[the archive](archived/devnotes-completed.md#done-panel-review-of-the-code-2026-11-14).

**Verdict:** the code is in good shape, and the cleanup has reached diminishing returns. The
biggest opportunities are now outside the refactor: shipping, and testing phase 11 against the
real second war.

What was read: `cws.bas`, `cws.bi`, six source files in full (`ui\turn.bm`, `ai\army.bm`,
`ui\menu.bm`, `io\files.bm`, `io\script.bm`, `rules\battle.bm`), the plan, `TODO.md` and
the documents in `docs\`. The rest was measured by a script. No test was run for this review.

## Biggest opportunities

1. **Stop phase 11 here and use Wars of Napoleon as the second war.** This answers the plan's
   open question 3.
   - Phase 11's test is "a second war is made by replacing `game\` and `scenarios\`". The real
     second war fails that test whatever steps 1 to 3 do: its strategic game has nationalities
     (`newarmy(..., nat%)`), `disband`, `equip.dat` and a hand-off to tactical battles.
   - `pretzel-wargames`' `README.md` measured 60% of Wars of Napoleon's strategic lines word for
     word in Civil War Strategy, with 53 procedures of the same name (2026-11-10). The renames
     since then have removed that overlap.
   - The useful next step is to run this repo's `tools\refactor` rename tables over Wars of
     Napoleon and measure again. That shows the engine boundary instead of guessing it.

## Not worth doing

- **The map's line work as a data file** (the plan's open question 2): `draw_map` is 336 lines
  of order-dependent `DRAW` and `PAINT`, and Wars of Napoleon's map should set the format.
- **Phase 11 steps 1 and 3**: moving the flags, ships and 24 texts only moves text until the
  engine's shape is known.
- **Unit tests for `ai\` and `commands\`**: the scripts already run all but about 11 lines
  ([modernize-plan.md](modernize-plan.md), "Lines that no test runs").

## The panel

A player was added to the usual five roles, because "worth doing" depends on who plays.

- **Pragmatic engineer:** ship it; phase 11 is preparing for a test the real second war does
  not pass.
- **Compiler/languages engineer:** [qb64-friction.md](qb64-friction.md) has made its case for
  scope across files; more moves add no evidence.
- **Rust engineer:** nothing to add here.
- **Player:** wants the pictures and a computer that plays as it was written to.
