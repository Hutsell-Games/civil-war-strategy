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
- When it recruits, the computer prefers a city whose army is small, and no longer
  picks an empty city because of the size of its last Join.
- The computer keeps its armies in its capital only while taking the capital wins
  the game; before, it did so with the capital rule turned off too.
- The Rebel computer decides on an invasion by the enemy near its own fleet. Before,
  it looked near the Union's fleet, and the game stopped when that was at sea.
- When your last raiding ship is lost, the computer's fleet stops chasing it. Before,
  the computer's fleet stood idle until you built a fleet again.

### Armies and fleets

- An army has at most 125,000 troops, as a Join already allowed. Recruiting in a
  city whose army is full costs nothing and says so; before, a very large army
  wrapped to a negative size.
- Join no longer loses the armies when every leader that joins has a rating of 0.
- A leader relieved, or freed by a Join, goes back to the list with his own
  rating, and no longer writes over another free leader.
- Cancel cancels the move of the army picked. Before, picking "Rebel II" could
  cancel the move of "Rebel III" in the same city.
- A fleet with no other sea port cannot retreat from a battle. Before, it retreated
  to no port, kept its ships and was lost from the map.
- After a refused city, the railroad's next destination is again picked from the
  army's own city, which can no longer be chosen as a destination.
- An army on the train keeps its place while it travels. Before, a new army raised
  or sent by a special event that month could take its place, and the game stopped
  with "subscript out of range" when the train arrived.
- Inform, Intelligence no longer stops the game while an army is on the train.
- A Rebel fleet at sea that receives England's ships is in port, and stops raiding.
- A relieved leader waiting on the list is no longer lost when the army in his slot
  is crushed or surrenders.
- Switching between one and two players works out the Union's extra income again.
- Supply buys only the whole days the cash pays for. Before, cash for 0.6 of a day
  bought a whole day.
- Join lists only the cities where two armies or more can join. Before, it listed
  cities where only one could, and then said it could not combine.
- Fortify lists a city once. Before, a city with two armies was listed twice.
- Army Drill lists only the armies that drill can still improve, and the Commands
  menu shows it as "-" when there are none. Before, it listed every army without an
  order, and one already drilled to its most was refused.
- Detach lists only the armies large enough to detach, and says so when there are
  none. Before, it listed every army without an order, and a small one was refused.
- Moves, Railroad, Detach and Army Drill list a city once. Before, a city was listed
  once for each of its armies.
- In a two-player game, an army that takes a fortified city without a battle asks
  "Raze ?", as in a one-player game. Before, no fort could be razed.
- When the month's Troops list has no city, Troops closes for the month. Before,
  opening Troops again drew the cities again.

### Vary Start

- Vary Start is offered only before the first End Turn of a new game. It starts the
  game again from a varied start and keeps the settings and victory conditions you
  set. Before, it could be used at any time, and it set the date, the cash, the
  victory conditions and the settings back while keeping the armies raised since.
- The Union's ships are ironclads more often than the Rebels', whichever side you
  play. Under Realism, a game of 1861 has no ironclads after Vary Start either.
- A Rebel fleet of no ships is no longer left in port.

### The end of a game

- When time runs out, the Rebels' technical victory is shown in their color, and the
  battle summary marks them as the winner.
- After taking the enemy's capital, the Options read "No - Press Onward" instead of
  "No - Press Onward to NONE".
- The warning that a side nears the strength ratio has its missing space.
- A technical victory shows the Rebels' victory points, and the history records that
  victory instead of "END GAME VICTORY CONDITION 1 REACHED".
- A commander's name in the Hall of Fame keeps 12 characters and no quotes, so the
  table stays in its columns and the name is saved as shown.
- A missing Hall of Fame file gives an empty Hall of Fame instead of an error at the
  end of the game.

### New Game and Load

- Files, New Game starts with Moves and Ships open, and with no raid on commerce
  left over from the game before.
- A loaded game keeps no raid of the game played before it. A fleet saved at sea
  raids on commerce from the first month after the load; before, it waited until
  some fleet moved.
- After Files, New Game or a Load, the computer's first turn no longer plays by the
  strength ratio of the game before.
- A Load gives back every leader of the scenario who commands no army in the saved
  game, including those the game before had used. The leader of an army on the
  train is not among them.
- A train loaded with an army aboard arrives as any other train does. Before, its
  arrival could leave the computer fortifying a city that does not exist.
- The first game after you start the program has random starting cash. Before, it
  was the same in every first game.
- After a Load, the army report shows the saved game's total income; before, it
  showed the total of the game played before until the month's end.
- The Battle Summary shows two sets of totals: those of this war, which a new game
  starts at none and a saved game keeps, and those of all games played on this
  computer. Before, it showed only one set, which a new game never set back to
  zero, and the game came with 36 and 134 battles won already in it. Now both
  start at none.

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
- Random events that you turn off stay off when you change sides or start a new
  game. Before, both turned them on again, in favor of the computer.
- An event balance of 1, which no menu sets, is read from `CWS.CFG` as neutral.
  Before, the original turned it into 3 when a Rebel player turned Realism on, and
  kept the 3 after Realism went off.
- In an events file, tabs around a line's parts read as spaces: around the `=`,
  around a name in brackets, and around each part of a value.
- The history file keeps the whole text of an event. Before, a message longer than
  59 characters lost its end: "furloughs to vote in 1864 elections" was saved
  without its last letter.
- An event text of 64 characters or more in an events file is shown cut to 59 in
  its box. Before, the game stopped with an error.

### Menus

- The Commands menu shows Supply as "-" when it would give no army supplies:
  every army has them, or is cut off, or the treasury cannot buy a day of them.
  After a purchase that leaves Supply as "-", the main menu comes back, as it does
  after the last fort the treasury can pay for.
- The army report's income line shows the right total of both sides' income.
  Before, it counted the two capitals twice, so the total was 200 too high.
- The main menu comes back on the row you left, also when you cannot pay for
  troops. Before, a side short of cash always came back to Moves, or to the
  first open row after it.
- Esc on the title menu does nothing. Before, it started a new game.
- F3 and F4 do nothing at the title menu, the scenario menu and a naval fight's
  Attack or Retreat. Before, they drew the map over those screens.
- Utility, Side gives the side you take its own list of cities for Troops. Before,
  it kept the other side's list, so you could recruit in the enemy's cities.
- A letter in the city picker finds your city even when it is the one just before
  the first city with that letter. Before, the letter did nothing then.
- The Save Game and Load menus number their slots, and a digit picks one. Before,
  the digits did nothing, and the key C saved over `cws1.sav` at once.
- A train with an army aboard stays on the map after a Save, and whenever else the
  map is drawn again. Before, only a Load drew it.
- A train that arrives leaves no black mark beside the city it left. Before, three
  pixels of its outline stayed on the map until it was drawn again.
- Esc at the Port menu of a new fleet builds nothing and costs nothing. Before, the
  Port menu came back until you picked a port.
- The Ships menu starts on Sail when Build and Attack are both "-". Before, it
  started on the "-" of Build.
- The Display and Random Events menus start on the setting in force. Before,
  Display started on Fast when the speed was Very Slow, and Random Events always
  on OFF.
- The line below the Random Events menu names the setting without the menu's
  marker.
- A pause that runs past midnight ends on time. Before, it lasted until a key was
  pressed.
- The army report's second line starts with the number of cities controlled.
  Before, when the victory points were few, that number could end the first line,
  and its "/ 40" start the second.
- Recap shows each line of the history as it was written. Before, a comma split a
  line in two, and the heading lost its indent.
- Chk Links names each city with its own number. Before, a road without a way back
  showed the number of the city at the road's other end.
- Realism is off or on. The original also read a level 2, which no menu or shipped
  file set and the manual did not describe; it only made the computer a little more
  careful when it attacked. A `CWS.CFG` written by hand with 2 now plays as Realism
  on everywhere, with a check mark in the Utility menu. Before, some rules read 2 as
  on and others as off, and turning it off gave -1.
- Every setting read from `CWS.CFG` is one the menus give. A number past a scale's
  end is read as that end, such as a Balance of 9 as 5. Any other number the menus
  do not offer is read as the default: the Union, one player, Normal speed and
  neutral events. Before, a Display speed of 5 had no row in its menu, and January
  campaigns of 2 became -1 when switched.
- A message box is as wide as its message. Before, a short message got a box as
  wide as the heading of the last menu shown.
- Utility, the menus it opens, Ships and the Port menu of a new fleet keep their
  usual colors. Before, Utility and its menus took Victory Conditions' yellow on
  cyan after that menu was shown, and Ships and Port took the light blue of
  Build's ship-type menu.

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