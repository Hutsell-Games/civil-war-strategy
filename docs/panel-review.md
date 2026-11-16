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
2. **Make CI's scripts pass.** The port is on `main`, and
   [build.yml](../.github/workflows/build.yml) builds it and runs every test. Its first run on
   `main` (2026-11-14, at `55e608e`) passed the build, the Python tests and the unit tests.
   All 41 whole-game scripts failed at checkpoint 1: `bad-events` was killed after 300 s, and
   each of the others stopped with "no prompt in time" a few lines into its keys file. The
   game never reached a prompt on the runner. The run's `test-failures` artifact holds the logs.

   2026-11-15: the scripts moved to a Linux job, under Xvfb with ALSA's null sound device, as
   QB64Rust's own CI runs its window programs. The Windows hang was most likely the first sound
   statement on a runner with no sound device. This stays open until a run on `main` passes.
4. **One batch ruling on the computer's inherited typos.** `TODO.md` has three: the fort of 2
   counted as none, `ai_fortify`'s local `side_cash`, and `ai_beyond_score`'s owner compared with a
   city. A fourth, `ai_army_order`'s test of `j = 0`, changed no play and was fixed on
   2026-11-15. A fifth is in `ai_attack_score`
   ([ai/army.bm:293](../ai/army.bm#L293)): the army's leader rating is added and subtracted, so
   it cancels. The original has the same line (`CWSTRAT2.BAS` line 364). One batch means one
   re-record.
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

The panel recommends items 2 and 3 now (item 3 is done), item 1 as the next plan, and item 4 when the user rules.

## Decisions for the user

1. Stop phase 11 after step 2?
2. May the renames go to Wars of Napoleon? `pretzel-wargames`' `README.md` lists "Hutsell's
   short names stay until one engine exists" under "Decided so far" (2026-11-10). That file does
   not say whether it was the user's ruling.
3. Fix the four computer typos left in one batch?
