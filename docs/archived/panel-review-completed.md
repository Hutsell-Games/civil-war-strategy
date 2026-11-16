# Done: panel review of the code, 2026-11-14

The findings of [../panel-review.md](../panel-review.md) that are done, under the same headings.

## Biggest opportunities

2. **Merge it and make CI real.** The branch is 95 commits ahead of `qb64rust`, and `main` is
   still the 2024 port.
   - [build.yml](../../.github/workflows/build.yml) has never run and will fail: it copies
     `docs\README.1ST` and `docs\WRHGAMES.DOC`, and neither is on this branch.
   - No CI job runs the 198 unit tests, the Python tests or the 40 scripts.

   Done in part: the port reached `main` on 2026-11-14, and `55e608e` fixed the copied
   documents and added the three test steps. The scripts still fail in CI; that part stays
   open in the review as item 2.
3. **Make the BASIC copy the only path for the history file.** `script_shell`
   (`port\script.bm`) already copies in BASIC under every script. Dropping
   the real `SHELL "copy ..."` removes an untested path, the console window a player sees, and
   the Windows-only half of `TODO.md`'s Linux item. What is left for Linux is file-name case.

   Done 2026-11-14, in the staged set (not committed when this was written): `history_start`
   (`io\files.bm`) renames `cws.his` to `oldhist.ory` with `NAME` in all play, and the source
   has no `SHELL` left. The file-name case was fixed with it ([devnotes.md](../devnotes.md),
   "Linux file access and history backups").

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
