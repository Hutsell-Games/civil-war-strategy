# Someday

Ideas for the QB64 port that may be worth doing, but are not planned. Open work that is planned is in
[../TODO.md](../TODO.md).

## Bad saves and settings files stop the program

A missing or cut-short save (`cws<n>.sav`) or `CWS.CFG` stops the game with a runtime error. It does
not show a message. This is the open part of item 7 in [code-smells-review.md](code-smells-review.md),
together with item 6. The plan below came from a pragmatic engineer's review on 2026-11-27. It is
not a priority yet (user, 2026-11-27).

`load_game` (`io\files.bm`) returns a `problem$` only for a save of a scenario that is not in
`SCENARIOS.LST`. An empty or cut-short `cws<n>.sav` gives a runtime error (Input past end of file)
in the middle of the load. By then the load has changed part of the game, so an `ON ERROR` alone
would leave a game half loaded. This was a `TODO.md` entry, found on 2026-11-24 in a review of
`ui\files.bm`, and moved here on 2026-11-27 (user, 2026-11-27).

The files the game writes on the player's machine are the risk. The files that ship with the game
(`SCENARIOS.LST`, `CWS.INI`, `CWSLEAD.DAT`, `CITIES.GRD`) only break with a broken install or a
scenario being edited, and stopping there is acceptable. At most, a check at startup could show one
plain message when one of them is missing.

1. **Keep a save from being cut short.** `save_game` opens the save itself for output
   (`io\files.bm`), which empties the old save before the new one is written. A crash or a full disk
   then loses both. Write to a temporary file, then `KILL` the old save and `NAME` the new one, as
   `history_start` already does.
2. **Fall back to the defaults for `CWS.CFG`.** `config_read` is one `INPUT #` and then range
   checks. When the file is missing or short, take the defaults and write the file again.
3. **Check a save before loading it.** Read it one field per `INPUT #` into a string array, with an
   `EOF` check before each. Check the count, then set the game's values from the array. Nothing in
   the game changes until the whole file is known to be good. The count also tells which format the
   save has, which replaces the `IF NOT EOF` tests of item 6.

Not checked yet:

- That a one-field `INPUT #` after an `EOF` check never stops on a cut-short file. The measured case
  (2026-11-26) was one `INPUT #` of several variables. A test with a cut-short save must show it.
- That `VAL` of a field read as a string gives the same number as `INPUT #` into a number. The saves
  are written by `WRITE #`, so the values are plain. A test should load every recorded save both
  ways.
- That QBJS handles `KILL` and `NAME`, and that the QBJS port's saves still work.

Not covered: `save_game` stops on its `OPEN` when the folder is read-only. It needs a design of its
own.

## Cosmetic effects draw from the game's dice

Two effects call the same `RND` as the rules. So the Sound and Graphics settings change the
battles, events and computer moves that come after them. This was item 1 of
[code-smells-review.md](code-smells-review.md), moved here on 2026-11-27 (user, 2026-11-27).

- **The explosion's sound** (`draw\map.bm`, lines 39 to 42) draws `RND` only when
  `opt_sound >= SOUND_EFFECTS`. It sits in loops of 3 by 7, so one explosion draws 21 numbers with
  the sound on and none with it off. The comment there says this keeps the original's behavior.
- **The schooner's sparks** (`draw\ships.bm`, lines 507 to 511) draw `RND` four times.
  `draw_schooner` runs only from `draw_fleet_sailing`, with `opt_graphics >= GRAPHICS_FULL` and a
  schooner as the lead ship. `draw_ironclad` draws none.

A normal game seeds with `RANDOMIZE TIMER`, so it cannot be replayed anyway. A scripted run or a
replay from a seed also needs the player's Sound and Graphics settings. Scripts mute sound with
`PLAY "V0"` but leave `opt_sound` as it is, so the explosion still draws under a script.

A random stream of its own for effects would fix it. It is a gameplay change: it needs a row in
`rule-changes.md`, and every script whose run reaches an explosion or a schooner's picture needs
`record` again.
