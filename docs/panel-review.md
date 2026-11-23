# Panel review of the code, 2026-11-14

A review of branch `refactor_naming` at `846b079`, after phases 0 to 10 of
[modernize-plan.md](modernize-plan.md). It asks where the biggest opportunities are and what is
not worth doing. Nits are left out. Its findings that are done are in
[archived/panel-review-completed.md](archived/panel-review-completed.md).

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
5. **Show the three lost pictures** (title, burning capital, Lincoln). They are the only DOS
   content a player lost, and Wars of Napoleon has the same item, so one helper serves both.

## Not worth doing

- **The map's line work as a data file** (the plan's open question 2): `draw_map` is 336 lines
  of order-dependent `DRAW` and `PAINT`, and Wars of Napoleon's map should set the format.
- **Phase 11 steps 1 and 3**: moving the flags, ships and 24 texts only moves text until the
  engine's shape is known.
- **More splitting**: there are 420 procedures with a median of 12 lines. Nine exceed 100
  lines, and five of those are pictures (`draw_map`, `draw_schooner`, `draw_ironclad`,
  `draw_surrender`, `draw_rebel_victory`).
- **Unit tests for `ai\` and `commands\`**: the scripts already run all but about 11 lines
  ([modernize-plan.md](modernize-plan.md), "Lines that no test runs").
- **Records, a `FLEET_NONE` constant and the other "left alone" rows of `TODO.md`**: these are
  settled notes, not work.

## The panel

A player was added to the usual five roles, because "worth doing" depends on who plays.

- **Pragmatic engineer:** ship it; phase 11 is preparing for a test the real second war does
  not pass.
- **QB64 engineer:** drop the `SHELL` and settle file-name case, which is cheap.
- **Compiler/languages engineer:** [qb64-friction.md](qb64-friction.md) has made its case for
  scope across files; more moves add no evidence.
- **Test engineer:** CI is the gap, not coverage.
- **Rust engineer:** nothing to add here.
- **Player:** wants the pictures and a computer that plays as it was written to.

The panel recommended items 2 and 3 now, item 1 as the next plan, and item 4 when the user rules.
Items 2 to 4 are done.

## Decisions for the user

1. Stop phase 11 after step 2?
2. May the renames go to Wars of Napoleon? `pretzel-wargames`' `README.md` lists "Hutsell's
   short names stay until one engine exists" under "Decided so far" (2026-11-10). That file does
   not say whether it was the user's ruling.
