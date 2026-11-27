# Where the code is

The main program is `cws.bas`: the title, the main menu's loop, and the map's letters as `DATA`. Its
shared variables and constants are in `cws.bi`. Everything else is a procedure in one of the files
below, which `cws.bas` and `tests\rules_test.bas` include.

Each file says at its top what it holds. This page gives that in one line, and the rule of each
folder. It does not list the procedures: search for `SUB name` or `FUNCTION name` to find one. Until
2026-11-14 it did, and the tables, with where each procedure came from, are in
[the archive](archived/devnotes-completed.md#done-where-each-sub-goes-phase-6).

## The folders and their rules

`tests\test_layers.py` checks the first three rules on the source.

| Folder | What it holds | Its rule |
|--------|---------------|----------|
| `rules\` | The game's rules | Draws, prints, plays and reads nothing, and calls nothing in `ui\`, `draw\`, `game\` or `commands\`. So `tests\rules_test.bas` can call every procedure in it |
| `ai\` | The computer's decisions | Draws nothing itself: its messages are in `ui\ai.bm`, and it carries out an order through `commands\`, as the player's menus do |
| `commands\` | The orders that the player and the computer both give, carried out | Calls the rules and shows what happened. Opens no menu and reads no key |
| `ui\` | The menus and the screens that the player sees | A menu changes no game state itself: it calls `rules\` or `commands\` |
| `draw\` | Drawing on the map and the screen | |
| `game\` | What another war would replace: its colors, tunes and end screens | |
| `io\` | Files and the world outside the program: the scenario, saved games, settings, history, and the hooks of the test scripts | |

`rules\` and `ai\` also leave the menu's shared variables alone (`menu_choice`, `menu_text$()` and the
others): a list is an array the caller passes, and a pick is a FUNCTION's result.

A topic has a file of the same name in each folder that has a part of it: `army.bm` in `rules\`,
`ai\`, `commands\` and `ui\`, for example.

## The files

| File | What it holds |
|------|---------------|
| `rules\army.bm` | The armies: slots and sides, strength, leaders, raising and recruiting, supply, drill, detach and combining |
| `rules\city.bm` | The cities: roads, capture, forts, the capital, and the steps of the city picker |
| `rules\battle.bm` | A land battle: the strengths, the fight and the losses |
| `rules\navy.bm` | The fleets: building, sailing, raiding, bombarding and sea battles |
| `rules\railroad.bm` | A side's train |
| `rules\setup.bm` | The settings of the Utility menu, and the start of a game |
| `rules\events.bm` | The special events: which one happens and what it does |
| `rules\turn.bm` | The month: the moves, supply, retreats, income and victory points |
| `rules\victory.bm` | Victory and the Hall of Fame |
| `ai\forces.bm` | The computer's first decisions of its turn: supply, forts, recruits and new armies |
| `ai\army.bm` | Where each of the computer's armies moves, drill, Join, and razing a fort |
| `ai\navy.bm` | The computer's fleet |
| `ai\railroad.bm` | The computer's train |
| `commands\army.bm` | Combining, raising and supplying armies |
| `commands\city.bm` | A city captured, and a fort built |
| `commands\navy.bm` | The fleets' orders and sea battles |
| `commands\railroad.bm` | A train setting off and arriving |
| `ui\menu.bm` | The menus: filling their rows, `menu_select` and its parts |
| `ui\main_menu.bm` | The main menu and its Railroad, End Turn and Inform entries; the title and its menus |
| `ui\orders.bm` | The Commands menu |
| `ui\army.bm` | The player's menus for the armies |
| `ui\city.bm` | The player's menus for cities: Fortify, Move Capital and the city picker |
| `ui\railroad.bm` | The player's Railroad menu |
| `ui\navy.bm` | The player's Ships command |
| `ui\files.bm` | The Files menu and the menus of saved games |
| `ui\options.bm` | The Utility menu and the menus of its settings |
| `ui\reports.bm` | The Inform menu's reports, the Victory Conditions menu, and Chk Links |
| `ui\screen.bm` | Parts of the screen that many procedures share, the waits for a time or a key, and the sound effects and music that the Noise setting allows |
| `ui\messages.bm` | A message in a box, and a message written to the history file |
| `ui\battle.bm` | A land battle as the player sees it |
| `ui\turn.bm` | The month's moves as the player sees them, and the computer's turn (`ai_turn`) |
| `ui\ai.bm` | The computer's messages |
| `ui\events.bm` | The special events' messages and tunes |
| `ui\victory.bm` | The warnings, the end of the game and the Hall of Fame |
| `draw\map.bm` | The map's line work, the cities, the fleets and the markers |
| `draw\icons.bm` | The flags of armies and trains, and the large flags |
| `draw\ships.bm` | The ships' icons and pictures |
| `draw\pictures.bm` | The cannon, the Chesapeake's shore, the title screen, and `load_picture` |
| `game\colors.bm` | The sides' colors |
| `game\tunes.bm` | Shenandoah and the title's tune |
| `game\victory_screens.bm` | The victory and surrender screens |
| `io\files.bm` | The scenario list, a scenario, the map, saved games, `cws.cfg`, the battle summary, the Hall of Fame and the history file |
| `io\text.bm` | Small text helpers that the data readers and `io\script.bm` share: trim, BOM strip, number test, list items |
| `io\events_file.bm` | The reader of `scenarios\EVENTS.DAT` |
| `io\tuning_file.bm` | The reader of the tuning files: `scenarios\TUNING.DAT`, a scenario's own, and the list a saved game holds |
| `io\tuning_knobs.bm`, `io\tuning_knobs.bi` | The tuning knobs' variables, defaults, names and ranges. Written by `tools\tuning\make_knobs.py` from `tools\tuning\knobs.txt`; not edited by hand |
| `io\script.bm` | The hooks for `tests\play.py`: the seed, forced dice, the key waits and the fixed date |
| `io\folders.bi` | The data folders, `GFXDIR` and `SCNDIR`, and the names of the settings, Hall of Fame and history files |

Inside a file, a topic's procedures are together, and a procedure that is the way in comes before its
parts (`ai_evaluate_move`, `menu_select`).
