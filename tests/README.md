# Tests

Two kinds of test live here:

- **Unit tests** (`rules_test.bas`) call the SUBs that draw nothing and check what they return. Run them with
  `qb64rust test tests\rules_test.bas` (`qb64rust test tests` also runs any copy of it under `tests\out`).
- **Whole-game scripts** (`scripts\*.keys`) play the game from the title menu to its end, with a fixed random
  seed, and compare its screens with the screens recorded earlier. They are what makes a change safe: a change
  that alters any screen of any script fails.

The scripts use QB64Rust's screen-state check. That is a C++ file linked into the program. It gives the program
keys from a file and writes the screen out at the points the file asks for. Its manual is QB64Rust's
`tools\screen\README.md`, which this file does not repeat. `play.py`, `make_scripts.py` and `test_play.py` were
adapted from the Civil War Battleset port (`Hutsell-Games/civil-war-battleset`, branch `qb64rust`).

## Running them

From the repo's folder, with QB64Rust's repo beside it (`..\QB64Rust`, built in release) and QB64pe beside
that (`..\QB64pe\qb64pe.exe`):

```
python tests\play.py check                       # every script with the QB64Rust build, against the recorded screens
python tests\play.py check union-manassas        # one script
python tests\play.py compare                     # the QB64pe and QB64Rust builds against each other
python tests\play.py record [script ...]         # both builds, twice each; writes scripts\<name>.screen
python tests\play.py coverage                    # the lines and the SUBs the scripts and unit tests reach
python tests\play.py explore <keys file>         # one run, a PNG of every screen; for writing a script
python tests\make_scripts.py                     # writes the generated scripts again (below)
python tests\make_save.py <description> <out>    # writes a saved game from a description (below)
python -m unittest discover -s tests -p "test_*.py"   # the tests of play.py and make_scripts.py
```

`--jobs N` (before the command) sets how many runs go at once (default 4). `CWS_SHOW_WINDOWS=1` shows the
program's window. Otherwise it runs on a desktop of its own that is never shown, and your keys and mouse cannot
reach it. Everything a run makes goes into `tests\out\`, which git ignores. A build is made again only when a
source file, the compiler or the screen hook changed. What a command prints also goes to
`tests\out\last-<command>.txt`. All 39 scripts take about half a minute with four jobs.

Each run starts in a fresh copy of the game's data files in `tests\out\run\`, so the files in the repo are never
changed. The copy takes the top-level files that are not sources, documents or DOS programs, and the folders
`graphics` and `scenarios`. Then it takes the files of `tests\data\` over those of the same name: the empty
`HISCORE.CWS` that came with the game. So a Hall of Fame left in the repo's folder by playing does not change
what the scripts see.

### When a check fails

`check` names the first checkpoint that differs and the line of the keys file that took it:

```
FAIL  rebel [rust]: differs at checkpoint 4, tests/scripts/rebel.keys line 41
    recorded: digest 8E575CF04FCA4E58
    now:      digest 52B151F891A7FB5A
    the screen now:      tests/out/fail/rebel-now-4.png
    the screen recorded: tests/out/fail/rebel-recorded-4.png
```

A checkpoint is usually a digest, a hash of the screen. To show the screen, `check` plays the script again with
full screens and writes a PNG of the one that differs. The recorded screen gets a PNG too when `record` ran on
this machine: it keeps a copy with full screens in `tests\out\recorded\`.

A difference is either a mistake in the change or a change of behavior that was meant. If it was meant, record
the script again (`record <name>`) and say so in the commit message.

## How the game takes part

The game has hooks for the scripts, all in `port\script.bm`. They do nothing unless the program is started with the
environment variable `CWS_SEED` set, as `play.py` does:

1. **A fixed seed.** `RANDOMIZE` takes `CWS_SEED` instead of `TIMER`, so every run of a script is the same game.
2. **Announced waits.** Before each wait for a key, the program says what kind of wait it is (`announce place,
   letter$`). The keys file then gives each key only when the program waits for it, and can answer waits by
   rules.
3. **Pauses.** `TICK` with less than 99 seconds (a message shown for a moment, which a key may cut short)
   returns at once. A game then takes seconds, and nothing depends on how fast the machine is. A message shown
   during such a pause is drawn and gone before the next checkpoint, so no script sees it. `TICK 99` is how the
   game says "read this, then press a key" (Chk Links, "There are still defenders"): under a script it waits
   for a key, as place `1:L`.
4. **No sound.** `PLAY "V0"` sets QB64's volume to 0. A script that turns the sound on in the Utility menu runs
   the `SOUND` and `PLAY` statements, which take their time, and nothing is heard. `script_mute` does this
   at the program's start, before the title music.
5. **A fixed date.** The history file starts with 01-01-2000 instead of today's date.
6. **No `SHELL`.** The game keeps the history of the game before with `SHELL "copy cws.his oldhist.ory"`. Under
   a script `scriptshell` copies the file in BASIC. A `SHELL` starts a `cmd.exe`, and its console window shows
   on your desktop even though the program runs on a hidden one.

The places a script can name (`play until <place>[:<letter>]`, `rule <place>[:<letter>] <keys>`):

| Place | Wait | Where |
|---|---|---|
| 1 | A pause that any key ends. The letter says which (below) | `wait_key` (`ui\screen.bm`), and `TICK` |
| 2 | A menu. The letter is the first letter of the menu's title | `menu`, `ui\menu.bm` |
| 4 | A line of text: the commander's name for the Hall of Fame | `maxx`, `rules\victory.bm` |

The letters of place 1: `R` the Random Events menu's "press a key"; `T` a player's turn begins, in a two-player
game; `P` a battle, when the odds show; `B` a battle's "hit any key to continue"; `U` the month's update, "press
any key for ... events"; `K` the update's end in a two-player game; `I` the ironclads' development; `N` an event
good for the Union; `S` an event good for the South; `H` "press a key" before the Hall of Fame; `G` "Game
Over"; `F` a report's "press a key"; `L` a `TICK` of 99 seconds. `rule 1 key space` answers them all.

Menu letters: `2:V` the title menu (VGA CIVILWAR STRATEGY) and Victory Conditions; `2:M` the main menu; `2:E` End Turn and End Game;
`2:O` the Files menu's Options, and the Options at a game's end; `2:C` Commands, Capital and Cancel; `2:U`
Utility; `2:R` Retreat, Recruit, Relieve, Random Events and Raze ?; `2:S` Ships, Supply, SOUNDS and Save Game;
`2:L` Load; `2:I` Information; `2:F` From and Fortify; `2:T` To and Type; `2:Q` Quit.

A rule for a letter answers every menu with that letter. A script that must tell them apart uses `prompt` and
plain keys, or `play until` that menu.

A menu takes Up, Down, PgUp and PgDn, and the first letter of an entry, which chooses it at once. A "-" entry
(one that is not available) is chosen by the key `-`. A letter that matches no entry is ignored, and the menu
announces its wait again. At a main menu, F3 draws the screen again, F4 shows the force report and F7 ends the
turn without the End Turn menu. F1 showed the help in DOS; the port removed it, and a menu ignores F1.

## The scripts

Each script is a keys file with lines that set up its run, which `play.py` reads:

```
#! seed 1861                 the random seed (default 1)
#! cfg side=2 history=1      fields of the CWS.CFG the program starts with
#! timeout 600               the longest the run may take, in seconds (default 300)
#! altmap                    the run starts on the alternate map
#! files cws.his cws1.sav    files to check after the run, by their hashes
#! data events-south         the files of tests\data\events-south go into the run's folder
#! without graphics/MTN.VGA  files the run starts without
#! dice 0,.05,.95;1          forced random numbers for the special events, a group for each month
```

Each file a `#! files` line names becomes a last checkpoint, `file <name> <hash>`, or `file <name> missing`.
The hash takes CRLF line ends as LF. A name may start with a folder, written with `/`. Each part of the name
matches whatever its case.

The `CWS.CFG` of a run is written fresh. By default it is the one that came with the game, with the sound off:
the Union side, the full map, balanced play, one player, fast display, random events that favor the Rebels,
January campaigns and realism on, history off, aggression 3. The fields are `CFG_FIELDS` in `play.py`.

`#! altmap` copies the three files of `scenarios\alternate` (`CITIES.GRD`, `CWS.INI`, `CWSLEAD.DAT`) over those
of `scenarios\standard` in the run's folder, so that the game starts on the alternate map.

### Prepared saved games

`#! data <folder>` copies the files of `tests\data\<folder>\` into the run's folder, each over the file of the
same name whatever its case. A folder inside it (`scenarios`, `graphics`) goes into the folder of that name. So
a script can start with a broken `CITIES.GRD`. `#! without` takes a file away.

A file `<name>.save` there is a description of a saved game. `play.py` writes `<name>.sav` from it into the
run's folder (`make_save.py`), and the script loads it with Resume Saved Game. The save starts as the
scenario's opening position, and each line of the description changes one thing:

```
date 11 1863           the turn
owner 2 2 18-21 29     the Rebels hold these cities
fleet 1 WWWWWWWWW 30   the Union's fleet: nine wooden ships at Philadelphia
army 22 city=4 size=50 an army slot's fields
```

The lines are listed at the top of `make_save.py`. `python tests\make_save.py <description> <out.sav>` writes
the save for a look.

What a save does not hold: whether the Emancipation Proclamation was made (it starts as not made), the
settings (`#! cfg`), and the leaders' names of the scenario, which the game reads at its start.

### Forced dice

`#! dice` gives the random numbers of the special events (`special_events`, `rules\events.bm`), so that a
script can make an event happen. The events draw their numbers through `script_rnd!` (`port\script.bm`).
Without `#! dice` it returns `RND`, so every other script plays as before.

The line holds one group for each month, parted by `;`. A group holds the numbers the month's draws take, in
order, parted by `,`. An `r` in place of a number is a real `RND`, and so is every draw after the group's last
number. The first draw decides whether there is an event (0 for yes, 1 for no). The second decides whom it
favors: with random events set to favor the Rebels, below .7 for the South and above for the Union. The rest
follow the code of `special_events`, branch by branch. A month whose events are skipped (the ironclads'
month) still takes its group.

A script ends the program the way a player does: Quit to DOS at the title menu or Quit and Yes in the Files
menu, then `repeat space` for END's "Press any key to continue". A run that ends any other way (a `prompt` that
times out, no rule for a wait, a crash) fails, and the last line of its state file says why. `play.py` sets
`QB64PE_NOPROMPT`, so a runtime error ends the program at once instead of waiting for an answer to "Continue?"
on a desktop nobody sees.

### Scripts written by hand

| Script | What it plays |
|---|---|
| `title` | The title menu, then Quit to DOS |
| `union-manassas` | Two turns as the Union: a recruit, two moves, a ship, a railroad move, the reports, Fortify, the Utility menu, a save, and two battles. A state at each new kind of screen |
| `commands` | Each entry of COMMANDS, each report of Inform, ships that land an army, a railroad move; then to the game's end |
| `options` | Every entry of the Utility menu, then a game with what they set, with sound and history on |
| `files` | The Files menu: two games saved, Resume Saved Game at the title menu, Load, New Game, and the history file with Recap. Checks `cws1.sav`, `cws2.sav`, `cws.his`, `oldhist.ory` and `CWS.CFG` |
| `navy` | The Union navy against New Orleans: three attacks, then an invasion |
| `rebel` | The Rebels attack Washington three times; No-Override and Press Onward at the game's end |
| `two-player` | Two players: the blank screen between their turns, Detach (the Rebels' own command), and 47 main menus to the time limit |
| `union-events` | A whole game as the Union with many random events, a capital moved, commerce raided, and recruits each month until the named leaders run out |
| `union-time` | A whole game as the Union to the time limit in March 1865, with the keys F3, F4 and F7 |
| `endings` | Three games in one run, each to another ending: income, a captured capital, and an army annihilated |
| `events-south` | From a prepared save of November 1863, the events that favor the South, by forced dice: riots in a city the Union took, England's ships, mercenaries, furloughs for the 1864 election, a loan, and the victory points of January 1864 and 1865 |
| `events-union` | From a prepared save of May 1864, the events that favor the Union: riots in a city the Rebels took, extra ships up to the fleet's limit, the Emancipation Proclamation, and Lincoln reelected. The Rebel fleet starts at sea, so the computer sails it home |
| `refusals` | From a prepared save, one month of commands that the game refuses or that need a certain state: no commander left for a new army, a blocked track, an army too large for the train, the Which menu, a train's destination with no track, "Railroad is already carrying", the Supply menu with an army cut off, armies too large to combine, the Cancel menu, and an ironclad from the Type menu |
| `refusals-rebel` | From a prepared save, as the Rebels with little cash, entries of the Commands menu that the game refuses: no money for a fort or to move the capital, an army too small to detach from, an army that cannot drill further, and no army left to drill |
| `navy-fights` | From a prepared save: the Options menu of a sea fight and a retreat, a raid on commerce without and with the lead ship's picture, a fleet that sails home from raiding, and a Union army that beats the army in Richmond, which flees |
| `join` | From a prepared save: the player combines two armies in Washington (COMMANDS, Join), and a Rebel army's train arrives in the computer's turn |
| `navy-build` | From a prepared save with no Union fleet: the Ships menu's entries that need a fleet, the Type menu, a new fleet through the Port menu, a sea fight in which the player attacks and wins, and the entries refused to a fleet at sea |
| `navy-raid-back` | From a prepared save: the player raids commerce, the computer's fleet pursues and sinks the raider, the player builds a new fleet and raids again, and the computer's fleet goes raiding in answer and fights at sea |
| `navy-losses` | From a prepared save, as the Rebels: a shore battery sinks their only ship, no army is left free to move, the Balance menu's faces, the Raze menu, and "NO SHIPYARDS AVAILABLE" |
| `menu-keys` | At the main menu, PgDn, Down from the last row round to the first, PgDn and PgUp |
| `bad-files` | A run without `MTN.VGA`, with a `CWS.CFG` that names no player count and no display speed, and with a map that has two one-way roads, which Chk Links reports |
| `bad-events` | A run with a `scenarios\EVENTS.DAT` that has a line the game cannot read: the game names the file, the line and the reason, and ends before the title |
| `sound-union` | The game starts with music on as the Union: the title tune, the ironclads' announcement and an event's tune run, unheard |
| `sound-rebel` | The same as the Rebels: "Shenandoah" at the title, and the tune of an event that favors the South |

All but `title` and `files` are the scripts that QB64Rust's test corpus plays on its copy of this repo's
`main` (`tests\corpus\screen\g12_game.*.keys` there), with this port's places. `files` was written again for
this port, which can load a saved game (`docs\devnotes.md`, "Found").

### Generated scripts

`make_scripts.py` writes two styles. In both, the player only ends each turn, so the computer's side alone acts:
it recruits, moves, builds ships, fights and wins.

| Script | How the game goes |
|---|---|
| `pass-<side>-<seed>` | The game ends at the first victory condition the computer reaches, after 1 to 11 turns. Eight games: the seeds 1861 to 1864 as each side, each seed with settings of its own (the map's detail, the play balance, the computer's aggression, random events, realism). `pass-<side>-altmap`: two more on the alternate map |
| `war-<side>-<seed>` | The player first turns off every victory condition but the time limit (Utility, End Cond). The game lasts 10 to 21 turns, until the player's side has no army left. `war-union-1866`, `war-rebel-1867`, and `war-union-altmap` and `war-rebel-altmap` on the alternate map |

Each takes a digest at every main menu, names the commander "Tester" when the Hall of Fame asks, and quits.
Each runs with history on and checks the history file `cws.his` and `HISCORE.CWS` after the run. The history
file names every battle and event of the game, so a change in how a game goes shows there even when no digest
catches it.

How many turns a game lasts, and whether the Hall of Fame asks for a name, depends on the game. So
`make_scripts.py` first plays each game with a probe, then writes what it found. Run it again only when a
change is meant to change how the games go, then `record`. It takes about 20 seconds with four jobs.

### Writing a script by hand

Start from a few lines and let `explore` show where they lead:

```
python tests\play.py explore my.keys
```

It plays the keys, then writes a state at the next wait and stops there. Each screen of the run becomes a PNG in
`tests\out\explore\`. Add a few lines, look, repeat. When the script ends the program, put it in `scripts\`, run
`record <name>`, and check that `record` says the four runs were the same.

Points that matter:

- **Look at every screen before recording.** A step that lands on another wait than the one meant puts the
  following keys out of step, and the game often still reaches the end. The first `files` script did this.
- **A wait that `play until` stops at is the script's to answer.** The next step after it must be its key.
- **`prompt` before every key** that a plain step gives.
- **The commander's name is an `INPUT`**: after `play until 4`, a `text` step and `key enter` give the whole
  line. A rule cannot answer it.
- **Choose menu entries by letter where you can**, but check the menu: the first entry with the letter wins.

## What the scripts do not cover

`play.py coverage` writes the lines that no script and no unit test reaches (`tests\out\coverage\report.txt`) and
a table per SUB, the least covered first (`tests\out\coverage\subs.txt`).

Not covered:

- **18 lines that no test runs**, most of them code that cannot be reached. They are listed with their
  reasons in `docs\modernize-plan.md`, "Lines that no test runs".
- **What the tunes sound like.** The sound scripts run the `PLAY` and `SOUND` statements; nothing checks the
  notes.
- **The real `SHELL "copy ..."`**, which `scriptshell` replaces under a script.
- **Linux.** The game opens lower-case names of upper-case files, and copies its history with a Windows
  command.
