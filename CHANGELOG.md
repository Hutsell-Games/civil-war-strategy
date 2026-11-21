# Civil War Strategy changelog

Changes for players, newest first. The original DOS release notes are kept separate
from the later Windows ports. The current port starts from Hutsell's original DOS
source rather than extending version 1.61.

## Unreleased

### Computer play

- When weighing an attack, the computer counts a fort of 2 as stronger than a fort
  of 1; before, it counted it as no fort. A cautious computer compares its leader
  and experience with the defender's.
- The computer values a road that leads to the enemy's capital.
- The Union's computer without a fleet keeps fortifying when it has 222 or more
  in cash; before, it stopped half the time whatever its cash.

### New Game and Load

- Files, New Game starts with Moves and Ships open, and with no raid on commerce
  left over from the game before.
- A loaded game keeps no raid of the game played before it. A fleet saved at sea
  raids on commerce from the first month after the load; before, it waited until
  some fleet moved.
- After Files, New Game or a Load, the computer's first turn no longer plays by the
  strength ratio of the game before.
- A Load gives back every leader of the scenario who commands no army in the saved
  game, including those the game before had used.

### Playtesting

- `scenarios/TUNING.DAT` holds 135 numbers that set the game's balance: costs and
  income, recruiting, supply, the battle formulas, victory points, the navy, the
  railroad, and how the computer weighs its moves. Edit a value and start a new
  game to play with it. The shipped file keeps the game as it was.
- A scenario's folder may hold a `TUNING.DAT` of its own, with only the lines it
  changes.
- A saved game keeps the knobs it was saved with, and the history file names those
  that differ from the defaults.

### Events

- Random events happen in a game of two players too, once a month after both
  players have given their orders. Before, only a game against the computer had them.

### Menus

- The Commands menu shows Supply as "-" when it would give no army supplies:
  every army has them, or is cut off, or the treasury cannot buy a day of them.
  After a purchase that leaves Supply as "-", the main menu comes back, as it does
  after the last fort the treasury can pay for.

## Version 1.7

The current port, on `main`, supports QB64Rust and QB64pe. Its title screen, manual and
quick reference show version 1.7; the original DOS game showed 1.57. These changes cover
November 6–14, 2026.

### Playing and choosing a map

- Run the game as a modern Windows or Linux program, without DOSBox. The source can be
  built with either QB64Rust or QB64pe.
  Windows builds are automated. Data-file references now match their exact
  filenames for case-sensitive Linux filesystems, and history backups use a
  portable BASIC file rename instead of a Windows command.
  Linux gameplay, saves and history have been checked on Ubuntu under WSL2.
- The window opens at 1280×960, twice the original 640×480 display, when the
  screen has room for it. Resize it by dragging its edge and the display scales
  to fill the window; Alt+Enter switches between windowed and fullscreen play.
- Choose the Standard or Alternate Map after Start NEW Game. There is no longer
  any need to run `ALTMAP.BAT` or swap map files before launching the game.
- Starting another game or switching maps resets city counts correctly, so the
  new game's reports and railroad capacity use the selected map's cities.
- Adjusted the train, cannon and map fills for QB64 drawing behavior, preventing
  color from flooding surrounding parts of the map.

### Saved games and menus

- Saves remember their map (standard or alternate) and restore it when loaded.
- Saves also retain victory conditions and special events that have already
  happened, including the Emancipation Proclamation.
- Older saves without a map name load against the Standard Map. Older saves
  without victory conditions or event history keep the conditions already in
  memory and begin with no events marked as completed. New saves cannot be read
  by the original DOS game.
- Load becomes available after the first save is created. Only the nine actual
  save slots count when deciding whether saved games exist.
- Resume is shown only when a saved game exists. Choosing Resume without
  successfully loading a game returns to the title menu instead of entering an
  incompletely displayed game.
- Loading any save slot restores the availability of Troops, Moves and Ships.
  Saving no longer accidentally restores those commands when slot 1 is used.
- F7 ends the turn only at the main menu, avoiding invalid selections in submenus.
- City selection no longer loops indefinitely when the side owns no cities.
- Leaving the Random Events settings with Esc shows the description of the
  setting actually in effect.
- The army report shows the opposing side's troops in cities from the first turn,
  rather than a stale estimate that could initially read zero.
- The Victory Conditions menu shows the correct income target on the Alternate Map.

### Battles and victory

- Battle supply is deducted from the armies actually fighting.
- Casualties for Union attackers are credited to the correct side in the battle
  summary.
- Corrected casualty scaling when the opposing army exceeds 80,000 men and the
  defensive strength penalty when a defender has less than one fifth of the
  attacker's strength.
- Corrected movement delays for armies above 80,000 and 100,000 men, affecting the
  order in which they move and fight.
- When an army surrenders or is crushed, the victorious side receives the 25
  victory points and captures the defeated army's remaining supplies, up to the
  supply limit. This works when either the attacker or defender is defeated.
- Destroying an enemy fleet awards its 10 victory points to the victorious side.
- The Rebels' bonus for controlling at least 35 cities adds to their own points
  instead of replacing them with a total based on Union points. Monthly victory
  points cannot fall below zero for either side.
- Troops aboard trains count toward annihilation and force-ratio victory checks.

### Recruiting and computer play

- Balance settings that favor the computer now give the extra recruits to the
  army being raised or reinforced.
- Realistic railroad capacity uses the correct baseline for the side operating
  the train, including the computer's side.
- Vary Start can remove Rebel starting armies as well as Union starting armies.
- The computer checks the correct cities when avoiding armies crossing each
  other's paths and when reinforcing an empty threatened capital by rail.
- The computer can establish a fleet without being blocked by an unrelated city
  ownership value, and pays the full price for ironclads.
- Building onto an existing computer fleet requires a friendly sea port, matching
  the player's shipbuilding restriction.
- When the computer's fleet decides to sail away from an enemy city that holds an
  army, it does so. Before, it bombarded the city anyway.
- With winter campaigning disabled, the computer observes the January and
  February restriction on entering enemy or neutral cities already applied to
  the player.
- The computer includes troops aboard trains when comparing forces for recruiting.
  Inactive army slots that are neither in a city nor aboard a train do not inflate
  its overall strength comparison.
- An invasion with no available army slot or commander is abandoned safely.
  The player's resources are preserved, and the computer cannot get stuck
  repeatedly asking for a commander.
- Trying to bombard a friendly or neutral city no longer uses up the player's
  Ships command.

### Events and settings

- Mercenary reinforcements now reach an army at the favored side's capital,
  creating one when necessary and possible. The event is skipped if the side has
  no capital or cannot form the army.
- Turning Realism off restores the Union's income bonus to the value appropriate
  for the current settings.
- Special events are defined in `scenarios/EVENTS.DAT`, allowing their chances,
  conditions, effects and messages to be changed without rebuilding the game.
  Invalid event definitions produce an error identifying the file, line and reason.
- Corrected rules and changes to random-number use mean battles, events and
  computer decisions can differ from the DOS game even with the same opening moves.

### Documentation and distribution

- The original external title picture, burning-capital picture and Lincoln
  picture are preserved as images in `docs`; their DOS viewers no longer run
  during play. The game's internal title screen remains.
- F1 help is replaced by the readable quick reference, [CWSDOC.TXT](docs/CWSDOC.TXT),
  and [full manual](docs/CWS.DOC). The Ctrl+B boss screen/screensaver is removed.
- The source has been reorganized and extensively cleaned up to make fixes and
  further development easier. The detailed record of gameplay-rule and AI changes
  is in [rule-changes.md](docs/rule-changes.md).

## Version 1.61

Released December 14, 2024. This earlier QB64pe port is preserved on `old-main`.

- Rebuilt the port from the original source with a small set of compatibility changes.
- Combined the BASIC modules into one program and adapted file checks for QB64.
- Corrected graphics fills around the train, cannon and map.
- Started in fullscreen mode and added an application icon and window title.
- Updated title, copyright and Quit wording, and replaced DOS drawing characters.
- Removed the screensaver and calls to the old DOS picture and help programs.
- Provided the manual and quick reference as text, along with contribution and
  licensing information.

## Version 1.6

Released April 17, 2022.

- Ported the DOS game to QB64, combining the source modules into one program.
- Replaced DOS file discovery with QB64-compatible checks, including checks for
  existing saved games.
- Fixed color bleeding around the train, cannon and map.
- Replaced unsupported DOS characters and removed the screensaver and obsolete
  DOS executables. Removed the in-game F1 help link.
- Updated the title spacing, copyright credits and displayed version.

## Original source publication in 2021

- Published Hutsell's original source with an MIT license. The unchanged DOS
  source is preserved on `canonical-source`.
- The supplied game identifies itself as version 1.57. Its accompanying release
  notes describe the older releases below; they do not list separate changes for
  versions 1.56 or 1.57.

## Original DOS version 1.55

- Improved capital-city graphics.
- Displayed a city's fortification level as a small number to the right of its icon.

## Original DOS version 1.54

- Updated the title graphics screen.
- Adjusted the Alternate Map scenario to improve game balance.
- Allowed the initialization file to specify a Rebel fleet at the start of a game.

## Original DOS version 1.53

- Added F4 at the main menu to open the force summary directly.
- Added up to nine saved games, CWS1.SAV to CWS9.SAV, chosen from a menu when
  loading or saving. A slot that already holds a saved game is marked with a "√".
- With Realism on, armies in isolated cities, with no road to a friendly city,
  cannot be resupplied. Such a city is under siege until a connection lifts it.