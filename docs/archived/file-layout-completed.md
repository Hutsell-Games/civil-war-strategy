# Done: where each SUB goes (phase 6)

The finished parts of `file-layout.md`, moved here on 2026-11-13, under the same headings: the questions
asked before phase 6 moved the SUBs. Phase 6 is done. Questions 2 and 3, whether the war's pictures go to
`game\`, are now phase 11's step 1 (`modernize-plan.md`).

## Questions for the user

1. `file_management` is saved-game work, not a port of QB64. `port\files.bm` is my pick. Phase 7 splits it
   into the file work and the screen work; the file part could then go to `rules\save.bm`.
2. `draw_cannon` and `draw_chesapeake` are Civil War pictures. They could go to `game\` with the victory
   screens. I put them in `draw\pictures.bm` because the plan names that file; say if you prefer `game\`.
3. `draw_ironclad` and `draw_schooner` are the same: ship pictures of this war, kept in `draw\ships.bm`.
4. 80 SUBs and FUNCTIONs, 11 of them marked mixed. The count per file runs from 1 to 8.
