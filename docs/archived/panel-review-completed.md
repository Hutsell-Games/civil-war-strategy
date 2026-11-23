# Done: panel review of the code, 2026-11-14

The findings of [../panel-review.md](../panel-review.md) that are done, under the same headings.

## Biggest opportunities

2. **Merge it and make CI real.** The branch is 95 commits ahead of `qb64rust`, and `main` is
   still the 2024 port.
   - [build.yml](../../.github/workflows/build.yml) has never run and will fail: it copies
     `docs\README.1ST` and `docs\WRHGAMES.DOC`, and neither is on this branch.
   - No CI job runs the 198 unit tests, the Python tests or the 40 scripts.

   Done in part: the port reached `main` on 2026-11-14, and `55e608e` fixed the copied
   documents and added the three test steps.

   Then the scripts failed in CI. On `main` at `55e608e` (2026-11-14), the build, the Python
   tests and the unit tests passed, but all 41 scripts stopped before the title menu: the
   game never reached a prompt on the Windows runner. The most likely cause was the first
   sound statement on a runner with no sound device. `039e402` moved the scripts to a Linux
   job, under Xvfb with ALSA's null sound device, as QB64Rust's CI runs its window programs.

   Done 2026-11-15: the merge of pull request 27 (`69e0cec`) ran both jobs, and all 41
   scripts passed on Linux.
3. **Make the BASIC copy the only path for the history file.** `script_shell`
   (`port\script.bm`) already copies in BASIC under every script. Dropping
   the real `SHELL "copy ..."` removes an untested path, the console window a player sees, and
   the Windows-only half of `TODO.md`'s Linux item. What is left for Linux is file-name case.

   Done 2026-11-14, in the staged set (not committed when this was written): `history_start`
   (`io\files.bm`) renames `cws.his` to `oldhist.ory` with `NAME` in all play, and the source
   has no `SHELL` left. The file-name case was fixed with it ([devnotes.md](../devnotes.md),
   "Linux file access and history backups").
4. **One batch ruling on the computer's inherited typos.** `TODO.md` has three: the fort of 2
   counted as none, `ai_fortify`'s local `side_cash`, and `ai_beyond_score`'s owner compared with a
   city. A fourth, `ai_army_order`'s test of `j = 0`, changed no play and was fixed on
   2026-11-15. A fifth is in `ai_attack_score`: the army's leader rating is added and
   subtracted, so it cancels. The original has the same line (`CWSTRAT2.BAS` line 364). One
   batch means one re-record.

   Done 2026-11-15: the user ruled to fix all four, and they were fixed in one batch
   ([rule-changes.md](../rule-changes.md), G25 to G28).

## Records that are wrong now

- **[rule-changes.md](../rule-changes.md) and [devnotes.md](../devnotes.md)** mark G23 and U12 to U14 "Uncommitted" and R1 to R3
  "staged". The changes are committed: the working tree holds only three document edits.
- **[README.md](../../README.md) and [devnotes.md](../devnotes.md)** still say the source changes "as
  little as possible" and that no variable is renamed.

  Done 2026-11-15: G23, U12 to U14 and R1 to R3 name `db5deb2`, which holds them. G24 and the
  Linux file-name note stay "uncommitted", because they are in the staged set. The README's
  sentence went with the staged set; `devnotes.md` now says the code was modernized, and that
  the port is on `main`.

- **[file-layout.md](../file-layout.md)** misses 23 procedures (`wait_key`, `menu_scenario` and
  the `report_` SUBs among them) and lists five that are gone (`army_combine`,
  `draw_fort_built`, `event_riot`, `file_management`, `railroad_move`). Generate its tables, or
  cut it to the folder rules.

  Done 2026-11-14: cut to the folder rules and one line per file. The old tables are in
  [file-layout-completed.md](file-layout-completed.md).

## Decisions for the user

3. Fix the four computer typos left in one batch?

   Answered 2026-11-15 (user): yes. Fixed as G25 to G28.
