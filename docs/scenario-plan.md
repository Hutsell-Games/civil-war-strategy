# Plan: scenarios in folders, picked in the game

Drafted 2026-11-13. Step 1 is in the working tree.

## Goal

The player picks the map inside the game. `scenarios\ALTMAP.BAT` goes away. A saved game knows which
scenario it belongs to. A new scenario is added by adding a folder and one line to a list.

This also serves phase 11 of `modernize-plan.md`, whose test is that a second war is made by replacing
`game\` and `scenarios\`.

## What is wrong today

- **The switch is outside the game.** `ALTMAP.BAT` renames six files in `scenarios\`. It runs only on
  Windows. Nothing in the game says which map is active.
- **A saved game does not know its map.** `save_game` (`port\files.bm`) writes armies and city owners by
  city number, with no map name. Read from the code, not tried: a game saved on one map and loaded after
  the switch loads without complaint onto the other map.
- **The file names are fixed.** `load_scenario` opens `cws.ini` and `cwslead.dat`, and `load_cities` opens
  `cities.grd`. `game_new` calls both before the title menu (`cws.bas` line 12).
- **The tests go around the batch file.** `play.py` has its own `swap_altmap`, and `TODO.md` lists
  `ALTMAP.BAT` itself as untested.

## Decided (user, 2026-11-13)

1. **It is built in this repo**, not in `pretzel-wargames`.
2. **One folder for each scenario**, not a suffix in the file names.

## Decided as proposed (user, 2026-11-13)

Claude proposed P1 to P6. The user accepted all six ("implement per your recommendations").

- **P1. Change decisions 3 and 6 of `modernize-plan.md`.** Decision 3 says every step keeps the recorded
  screens identical. Decision 6 says the saved-game file keeps its format. Steps 2 and 3 below break both.
  Proposed wording for decision 3: "A refactor step keeps the recorded screens identical. A change to
  behavior or the screen that is meant is its own commit. It records again only the scripts whose
  checkpoints differ, and its commit message lists them." Decision 6 gets the same exception for the
  scenario name. The user asked on 2026-11-13 whether the rule must be held rigidly; this is the answer
  proposed.
- **P2. A list file names the scenarios**: `scenarios\SCENARIOS.LST`, one line for each scenario with its
  folder and its title. The menu shows the titles in the file's order. The first line is the scenario that
  loads before the title menu. A list avoids `DIR$` on folders, which is untested on Linux.
- **P3. The titles**: "Standard Map" and "Alternate Map". `docs\CWS.DOC` may have better names.
- **P4. A saved game without a scenario name loads as the first scenario**, which is what happens today.
  The other choice is to refuse it.
- **P5. The scenario menu is not shown when the list has one line.**
- **P6. The leaders stay a file of each scenario.** `CWSLEAD.DAT` and `ALTLEAD.DAT` are the same bytes
  today. Wars of Napoleon has leaders for each scenario, so the file stays in the folder.

## The layout

```
scenarios\
    EVENTS.DAT                 the war's events, for every scenario (as today)
    SCENARIOS.LST              the list: folder and title
    standard\
        CITIES.GRD  CWS.INI  CWSLEAD.DAT
    alternate\
        CITIES.GRD  CWS.INI  CWSLEAD.DAT       (today ALTMAP.GRD, ALTMAP.INI, ALTLEAD.DAT)
```

The six files move with `git mv`. Their contents do not change.

## Steps

Each step is one commit. After each, `python tests\play.py check` and the unit tests run with both
compilers, as in the modernize plan.

### Step 1: the folders (a refactor step: no screen changes)

- `git mv` the six files into `standard\` and `alternate\`. Add `SCENARIOS.LST`.
- A shared `scenario_folder$` (`cws.bi`) holds the scenario's folder. A FUNCTION `scenario_file$(name$)`
  gives `SCNDIR + scenario_folder$ + "/" + name$`. `load_scenario` and `load_cities` use it.
- `game_new` reads the list and sets `scenario_folder$` to its first line.
- `play.py`: `#! altmap` copies the three files of `alternate\` over those of `standard\` in the run's
  folder. This keeps the four alternate-map scripts running until step 2 replaces the directive.
- `make_save.py` reads the opening from `scenarios\standard\`. `tests\data\bad-map\scenarios\CITIES.GRD`
  moves to `bad-map\scenarios\standard\`.
- The user runs `git rm scenarios/ALTMAP.BAT`. The batch file cannot work after the move.
- **Check:** all 39 scripts pass with nothing recorded again.

### Step 2: the menu (changes the screen)

- After "Start NEW Game", `menu_scenario` (`ui\main_menu.bm`) lists the titles. Esc goes back to the
  title menu.
- When the choice is not the scenario already loaded, `game_new` runs again with that folder. To check:
  the second load draws no random number, so a game on the standard map plays as before.
- Every script that chooses Start NEW Game gets one more line to answer the menu. `make_scripts.py` writes
  it for the 14 generated games. The scripts that resume a prepared save do not pass the menu.
- `#! altmap` goes. The four alternate-map scripts pick the second row. `swap_altmap` and its test in
  `test_play.py` are deleted.
- To check first: which wait letter the new menu announces, and that no `rule` line of a script already
  answers that letter.
- **Check:** the digests at the title menu and the main menus should not change, because the menu is gone
  before the map is drawn. Any script whose digest does change is recorded again and named in the commit
  message.

### Step 3: the saved game (changes the file)

- `save_game` writes the scenario's folder name as the first field. `load_game` reads it. When it names
  another scenario than the one loaded, the leaders and the cities of that scenario are read first.
- To check: `load_cities` adds to each side's city count, points and cash. `load_game` must still end
  with the saved values.
- A save that names a folder that is missing gives a message and goes back to the menu.
- A save without the field follows P4.
- `make_save.py` writes the field. The round-trip test in `tests\rules_test.bas` (near line 1855) gets
  the scenario.
- One new script: start on the alternate map, save, New Game, Resume Saved Game. Its digest shows the
  alternate map.
- **Check:** `files` checks `cws1.sav` and `cws2.sav` by their hashes, so it is recorded again. No other
  script names a `.sav` file in `#! files`.

### Step 4: the documents

- `README.md`: how to pick the map. `docs\devnotes.md` item 9, `docs\file-layout.md` and `tests\README.md`
  (`#! altmap`, the script table).
- `TODO.md`: the row "`ALTMAP.BAT` itself" goes.
- Comments: `port\folders.bi` (the `SCNDIR` line) and `port\files.bm` ("ALTMAP does not swap this file").
- `modernize-plan.md`: decisions 3 and 6 as P1 is answered. `modernize-completed.md`: what each step did.

## Not in this plan

- **Splitting `CWS.INI`.** Its side names, month names and flag star positions are the war's, and they
  are the same in both scenarios. Wars of Napoleon keeps such lines in `gamedata.ini`. This is a step for
  phase 11 or the engine split.
- **Settings and the Hall of Fame for each scenario.** `CWS.CFG` and `HISCORE.CWS` stay shared.
- **Linux file names.** The game opens lower-case names of upper-case files. That row stays in `TODO.md`.
- **The copy in `pretzel-wargames`.** It is a copy of 2026-11-10 and is not updated by this plan.
