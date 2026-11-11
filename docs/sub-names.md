# SUB and FUNCTION names

Every SUB and FUNCTION of the game on the `qb64rust` branch (commit `8c3b185`), with what it does. The test
program `tests\rules_test.bas` is left out. The new names are in "Settled names" below.

All are SUBs except the three marked FUNCTION. Armies 1 to 20 are Union and 21 to 40 are Rebel. Side 1 is the
Union and side 2 is the Rebels.

| Name | File | What it does |
|------|------|--------------|
| `choices` | CWSMENU.BM | Draws a menu's box and prints its title and its options. |
| `ironclad` | CWSMENU.BM | Draws the picture of an ironclad at sea on the lower half of the screen, shown when a fleet led by an ironclad sails. |
| `menu` | CWSMENU.BM | Shows the menu held in `mtx$()`, lets the player pick an option with the arrow keys or a letter, and returns the pick in `choose`. |
| `mxw` | CWSMENU.BM | Returns the width a menu needs: the length of its longest option or of its title. |
| `schooner` | CWSMENU.BM | Draws the picture of a wooden sailing ship on the lower half of the screen, shown when a fleet led by a wooden ship sails. |
| `animate` | CWSTRAT1.BM | Moves an army's icon in steps along the road from its city toward the city it is marching to. |
| `armies` | CWSTRAT1.BM | Takes the player's move order: the player picks an army and a neighboring city, and the move is recorded. |
| `armystat` | CWSTRAT1.BM | Prints an army's name, size, leader rating, experience and supply in the right panel. |
| `barnacle` | CWSTRAT1.BM | Removes one ship from a side's fleet, and clears the fleet when no ship is left. |
| `battle` | CWSTRAT1.BM | Fights a land battle: shows both armies' strengths and the odds, picks the winner, takes the losses from both armies and records the result. |
| `combine` | CWSTRAT1.BM | Merges a side's armies that stand in one city into a single army under the best leader. |
| `cutoff` | CWSTRAT1.BM | Counts the neighboring cities that a side holds; a count of 0 means the city is cut off. |
| `filer` | CWSTRAT1.BM | Reads the scenario and settings for a new game, loads a saved game, or saves the game, as its argument says. |
| `flashcity` | CWSTRAT1.BM | Flashes a city's dot through several colors, then draws it in its owner's color. |
| `fortify` | CWSTRAT1.BM | Lets the player pick a city that holds one of their armies and pay 200 to raise its fort level, up to 2. |
| `icon` | CWSTRAT1.BM | Draws or erases a marker on the map, chosen by `kind`: a move line, a recruiting box, an explosion, a highlight box, an arrow pointer or a road. |
| `iterate` | CWSTRAT1.BM | Ends the turn: moves the date on two months, pays for and uses up each army's supplies, and works out the ratio of the two sides' strengths. |
| `movefrom` | CWSTRAT1.BM | Lets the player pick a city and, when several armies stand there, which army to give an order to. |
| `navy` | CWSTRAT1.BM | Runs the naval commands for the player or the computer: build a ship, bombard a city, sail, raid commerce, invade, and fight the other fleet. |
| `newarmy` | CWSTRAT1.BM | Creates a new army in a city with its leader, size, experience and supply, and charges the side 100. |
| `newcity` | CWSTRAT1.BM | Lets the player step through their own cities with the arrow keys or a first letter and choose one, used for a train's destination. |
| `normal` | CWSTRAT1.BM | Returns a random number from a roughly normal distribution with the given mean and variance. |
| `placearmy` | CWSTRAT1.BM | Draws an army's flag icon at its city, with an "S" on it when the army is out of supplies. |
| `railroad` | CWSTRAT1.BM | Starts a train move for the player or the computer, or finishes the one under way when the army arrives. |
| `recruit` | CWSTRAT1.BM | Offers a few cities for recruiting and spends 100 for each pick, which raises a new army there or adds men to the army already there. |
| `shiptype` | CWSTRAT1.BM | Draws one ship of a fleet as a wooden ship or an ironclad, according to its letter in `fleet$`. |
| `showcity` | CWSTRAT1.BM | Draws all 40 cities in their owners' colors with their fort marks, the capitals, and the roads between cities. |
| `smarts` | CWSTRAT1.BM | Plays the computer's turn: special events, supplies, forts, recruiting, the navy, combining armies, a train move and a move order for each army. |
| `snapshot` | CWSTRAT1.BM | Saves the small square of screen around a point, or puts the saved square back. |
| `strong` | CWSTRAT1.BM | Prints an army's size in men: its size number followed by "00". |
| `tinytrain` | CWSTRAT1.BM | Draws or erases the small train icon at the city where a side's train is. |
| `tupdate` | CWSTRAT1.BM | Carries out the turn: armies move in order of speed, battles are fought, losers retreat or surrender, cities are captured, raiders sink commerce and victory points are updated. |
| `armyxy` | CWSTRAT2.BM | Draws a small Union or Rebel flag icon at a screen position. |
| `bub2` | CWSTRAT2.BM | Sorts the numbers in `brray()` into rising order with a bubble sort. |
| `bubble` | CWSTRAT2.BM | Sorts the menu texts in `mtx$()` alphabetically and keeps `array()` in step with them. |
| `cancel` | CWSTRAT2.BM | Lets the player pick one of their armies that has a move order and cancels the order. |
| `cannon` | CWSTRAT2.BM | Draws the picture of a cannon in the right panel before a battle. |
| `capitol` | CWSTRAT2.BM | Draws the Union victory screen: the Capitol, a quotation from Lincoln and a row of flags, with music. |
| `capture` | CWSTRAT2.BM | Gives a city to the side that took it, adds its victory points, and handles the fall of a capital. |
| `center` | CWSTRAT2.BM | Prints a text centered on a given row of the end-of-game box. |
| `chessie` | CWSTRAT2.BM | Draws the coastline of Chesapeake Bay on the map. |
| `clrbot` | CWSTRAT2.BM | Clears the message line at the bottom of the screen and leaves the cursor at its start. |
| `clrrite` | CWSTRAT2.BM | Clears the panel on the right of the screen. |
| `commander` | CWSTRAT2.BM | Finds a free army slot with an unused leader for a side, and makes up a leader such as "Union IV" when the list is used up. |
| `endit` | CWSTRAT2.BM | Shows the menu where the player turns each victory condition on or off. |
| `engine` | CWSTRAT2.BM | Draws the box at the top left that shows each side's train and where it is going. |
| `evaluate` | CWSTRAT2.BM | Scores each neighboring city as a move for one of the computer's armies and returns the best one, or 0 to stay. |
| `events` | CWSTRAT2.BM | Announces that ironclads are available in 1862, and otherwise may bring a random special event that changes a side's ships, men, cash or victory points. |
| `flags` | CWSTRAT2.BM | Draws a Union or Rebel flag in the right panel, with the side's name under it when it is the main flag. |
| `image2` | CWSTRAT2.BM | Shows a message in a box in the middle of the screen for a few seconds, then puts back what was under it. |
| `integrity` | CWSTRAT2.BM | Checks that every road on the map has a road back, adds the missing ones where there is room, and reports the rest. |
| `maptext` | CWSTRAT2.BM | Draws each city's name under it on the map with the game's own line font. |
| `maxx` | CWSTRAT2.BM | Shows the Hall of Fame, adds the game's scores to it when they qualify, saves it to `hiscore.cws` and marks the game as over. |
| `occupy` | CWSTRAT2.BM | Sets `occupied()` for a city to the first army found there, or to 0 when there is none. |
| `relieve` | CWSTRAT2.BM | Lets the player replace an army's leader with an unused one, at the cost of one point of leadership and one of experience. |
| `report` | CWSTRAT2.BM | Shows the Information menu and its reports: either side's armies, the cities, forces by city, army details on the map, the battle summary and the history of the game. |
| `resupply` | CWSTRAT2.BM | Buys supplies for an army from its side's cash, up to a supply level of 5. |
| `retreat` | CWSTRAT2.BM | Lets the human owner of a beaten army choose the neighboring friendly city it retreats to. |
| `roman` | CWSTRAT2.BM | Builds a made-up army name from an army's number, such as "Union IV" or "Rebel XII". |
| `rwin` | CWSTRAT2.BM | Draws the Rebel victory screen: the Confederate flag over a landscape with a mansion, with "Dixie". |
| `scribe` | CWSTRAT2.BM | Shows a message on the bottom line or in a box, and adds it to the history file `cws.his` when history is on. |
| `shen` | CWSTRAT2.BM | Plays "Shenandoah" when music is on, and stops between phrases if a key is pressed. |
| `shipicon` | CWSTRAT2.BM | Draws a wooden ship or an ironclad with its side's flag at the current drawing position. |
| `ships` | CWSTRAT2.BM | Draws each side's fleet icon on the map at the place where the fleet is. |
| `starfin` | CWSTRAT2.BM | Returns the first and last army numbers of a side: 1 and 20 for the Union, 21 and 40 for the Rebels. |
| `stax` | CWSTRAT2.BM | Draws a small yellow circle at each city where a side has more than one army. |
| `surrender` | CWSTRAT2.BM | Draws the surrender picture in the right panel, an officer giving up his saber, with the winner's flag. |
| `TICK` | CWSTRAT2.BM | Waits for a number of seconds or until a key is pressed. |
| `topbar` | CWSTRAT2.BM | Draws the top line and the right panel for the player's turn: the date, the flag, the difficulty, the funds, the victory points and the key hints. |
| `touchup` | CWSTRAT2.BM | Redraws stretches of coast and river on the map that an erased icon may have wiped out. |
| `traincapacity` | CWSTRAT2.BM | Returns the largest army that a side's railroad can carry. |
| `usa` | CWSTRAT2.BM | Draws the whole map: state borders, coast, rivers, mountains, cities, city names, armies, fleets and trains. |
| `victor` | CWSTRAT2.BM | Checks the victory conditions, warns when a side is close to one, and runs the end of the game when one is met. |
| `void` | CWSTRAT2.BM | Adds up the strength of the player's armies near a city: in full for neighboring cities and a tenth for cities two roads away. |
| `DIR$` (FUNCTION) | QB64.BM | Stands in for the `DIR$` of BASIC PDS 7.1: returns the first file that matches a pattern, or the next match when the pattern is empty. |
| `announce` | SCRIPT.BM | In a scripted run, writes to memory that the program is about to wait for a key and which kind of wait it is. |
| `scriptdate$` (FUNCTION) | SCRIPT.BM | Returns the date that starts the history file: today's, or 01-01-2000 in a scripted run. |
| `scriptshell` | SCRIPT.BM | Runs a `SHELL` command, except that a scripted run does a `copy` command in BASIC so that no console window opens. |
| `scriptstart` | SCRIPT.BM | Seeds the random numbers from the environment variable `CWS_SEED`, which makes the run scripted, or from the clock. |
| `scripttick%` (FUNCTION) | SCRIPT.BM | In a scripted run, takes the place of `TICK`'s pause: it returns at once for a short pause and waits for a key for one of 99 seconds or more. |

## Worth breaking out

Listed from the safest and most useful down. None changes what the game does. The scripts of `tests\play.py`
compare the screens, so each step can be checked by running them.

One thing to watch in every case: a variable inside a SUB is local unless `CWS14.BI` shares it. Code moved
out of a SUB loses that SUB's locals, so each one it uses must be passed as an argument.

### Small and safe

- **`filer` into three SUBs.** Its argument only picks one of three unrelated jobs, and it has three callers.
  `load_scenario` (case 1), `load_game` (case 2), `save_game` (case 3). The line that reads or writes
  `cws.cfg` appears four times (twice read and once written in `filer`, once written at `CWSTRAT.BAS` line
  689): make it `config_read` and `config_write`.
- **`report` into one SUB for each report.** It holds six reports joined by `GOTO`: armies, cities, force
  summary, intelligence, battle summary and recap. Two callers pass a made-up number to reach one report
  directly: `report(-1)` for the force summary and `report(100 + side)` for the battle summary. With a SUB
  for each report they call it by name, and `menu_report` keeps only the menu.
- **Waiting for a key.** `CALL announce(1, "X"): DO WHILE INKEY$ = "": LOOP` appears 12 times. Make it
  `wait_key (letter$)`.
- **The fleet-sailing screen in `navy`.** The Sail and Raid cases hold the same 16 lines: the row of ships,
  the picture of the lead ship and the pause. Make it `draw_fleet_sailing (who)`.
- **Clearing an army.** The same line that sets an army's size, place, leader, experience, move and supply
  to zero is in `tupdate` (the army that surrenders), `combine`, the "Vary Start" menu case (twice) and the
  start of a new game. Make it `army_clear (index)`.
- **A city's dot.** `flashcity` and `showcity` both draw the dot with the same three lines. Erasing a fort's
  square and calling `showcity` appears in `navy`, `capture` and `tupdate`. Make them `draw_city_dot` and
  `city_redraw_fort`.
- **The train picture.** The same `DRAW` string is in `engine`, `tinytrain` and the Railroad case of the
  main menu.
- **The menu's box.** `menu` draws the box and then calls `choices`, which draws the same box again. The
  copy in `menu` can go.
- **Dead code in `CWSTRAT.BAS`.** The label `topbar:` near the end (lines 706 to 710) is never reached; the
  SUB `topbar` replaced it.
- **Numbers that pick a behavior.** `icon`'s `kind` (1 to 11) and `menu`'s `switch` (0 to 9) are bare
  numbers at about 50 call sites. Named constants (`CONST MARK_MOVE_LINE = 1`) explain each call without
  changing a SUB.

### The main module, `CWSTRAT.BAS`

It is 745 lines with no SUB of its own; the menus hold the game's rules inline. These pieces stand alone:

- **Detach** (lines 358 to 373): `army_detach`.
- **Drill** (lines 377 to 387): `army_drill`. The computer's drill at the end of `smarts` applies the same
  rule.
- **Supply menu** (lines 311 to 337): `menu_supply`.
- **Move capital** (lines 341 to 354): `menu_move_capital`.
- **Vary Start** (lines 571 to 606): `vary_start_conditions`.
- **The title screen and its music** (lines 63 to 95): `draw_title` and `play_title_music`.
- **Reading `cities.grd`** (lines 99 to 110): `load_cities`.
- **The month's income** (lines 150 to 168): `turn_collect_income`.
- **The `GOSUB` routines** `blanken` (the "player's turn" screen) and `unionplus` (the Union's income
  bonus): `draw_player_turn` and `set_union_advantage`.

The Utility menu and the Commands menu could each become a SUB later. Their cases leave by `GOTO menu0`, so
that takes more care.

### `navy` (435 lines)

- **Ship against ship** (the label `pirate:` to the end of its `SELECT`, with `showhit`, `clr1`, `boxes` and
  `xout`): `navy_combat (who, chx)`. It is about 100 lines and is entered from two places.
- **The computer's choice of port** (the `GOSUB` routine `nest`): `ai_pick_port`.
- **One SUB for each action** (build, bombard, sail, raid, invade) is the end state, with `navy_commands`
  keeping the menu. The cases jump into each other with `GOTO ahoy`, `GOTO anchor` and `GOTO ships`, so do
  this last.
- **The menu, apart from the computer's choices** (agreed): `menu_navy (who)` for the human's Ships menu,
  `ai_navy (who, chx)` for the computer's choice of action, and `navy_action (who, action)` for what is left.
  The computer's path runs through the code that builds the menu (the label `ahoy:`), because three of its
  decisions are made there: it invades when "Invasion" is added to the menu, a "Sail" order becomes "Build"
  when it has no fleet, and its loop of building ships ends there. Those move to `ai_navy` first.

### Other SUBs that serve both the human and the computer

`navy` is not the only one. Two more mix the human's menu with the computer's choice:

- **`recruit`:** `IF who <> side THEN GOSUB randsel` swaps the menu for the computer's pick (the `GOSUB`
  routine `randsel`). Split it into `menu_army_recruit` (the human's menu), `ai_recruit` (the pick) and
  `army_recruit (who, city)` (pay 100, then raise a new army or add men to the one there).
- **`railroad`:** four parts in one SUB. The computer's choice of army and city (case 0 up to the label
  `human:`), the human's choice (`human:` to `haul:`), starting the train (`haul:`) and the train's arrival
  (case `IS > 0`). They become `ai_railroad`, `menu_railroad`, `railroad_start` and `railroad_arrive`. The
  `GOSUB` routine `route`, which counts the friendly track out of a city, becomes `railroad_route_count`.

### Rules apart from the screen

- **Losses in `battle`** (lines 199 to 228): the same eight lines appear twice, once for each army, with the
  attacker and the defender swapped. They print nothing. Make them `battle_losses`; `tests\rules_test.bas`
  can then test the losses directly.
- **Strengths in `battle`** (lines 85 to 151): the attack and defense values are worked out step by step,
  and each step is printed in the right panel. Splitting out the arithmetic means returning each step's value
  for the panel. Worth doing only together with tests of the combat rules.
- **An army's side**: `who = 1: IF index > 20 THEN who = 2` and its variants appear 10 times. Make it
  `FUNCTION army_side (index)`. Leave out the line in `battle` that tests `attack > 2` (see the bugs below):
  using the FUNCTION there would fix the bug, which changes the game.
- **`maxx` borrows `city$()` and `matrix()`** to hold the Hall of Fame's names and scores while it shows
  them. That works only because the game is over and a new game reads the cities again. Give the Hall of
  Fame its own arrays, with `hall_of_fame_load` and `hall_of_fame_save`.
- **`victor`**: the warnings that a side is close to winning are one block; make it `victory_warnings (i)`.
  The end of the game, from the label `finis:`, becomes `end_game`.

### Screen helpers

- **Loading a picture**: `DEF SEG`, `BLOAD` and `DEF SEG` again load a `.vga` file four times (`menu`,
  `battle` and twice in `CWSTRAT.BAS`). Make it `load_picture (file$, picture())`.
- **What `menu` shows beside the highlighted row**: two `SELECT CASE switch` blocks in `menu` draw an arrow
  at an army's city, the army's name and size, the army's details, or a leader's face. This is why `menu`
  needs to know about armies and cities. Moving them to `menu_highlight (switch, row)` and
  `menu_unhighlight (switch, row)` leaves `menu` a plain menu.

### Not worth doing now

- Every menu is set up by assigning shared variables (`tlx`, `tly`, `size`, `colour`, `hilite`, `mtx$()`)
  before `CALL menu`. Passing them as arguments would touch every menu in the game, which goes beyond
  breaking code out.
- `CALL clrbot: PRINT ...: CALL TICK(turbo!)` (a message, then a pause) is everywhere, but most of the
  messages are built from several pieces and calls to `strong`. A helper would cover few of them.

### `tupdate` (270 lines)

- **The order of movement** (lines 1637 to 1658, with `bub2`): `turn_set_move_order`.
- **Commerce raiding** (the label `allthru:`, lines 1841 to 1871): `navy_commerce_raid`.
- **Victory points** (lines 1878 to 1885): `turn_update_victory_points`.
- **The `GOSUB` routine `upbox`**: `draw_update_box`.
- The attack, retreat and surrender part in the middle is one knot of `GOTO`s. Leave it until the rest is
  done.

### `smarts` and `events`

- `smarts` already has headed sections: supply, fortify, recruit, navy, army moves, drill. Each can become
  an `ai_` SUB. The `GOSUB` routine `enufarmies` becomes `ai_count_armies`.
- `events`: the `GOSUB` routine `riot` becomes `event_riot`.

### Found while reading, not to fix as part of a rename

These look like bugs in the original. Fixing them changes how the game plays, so each is its own decision.

- `CWSTRAT.BAS` line 582: `FOR k = 21 TO 6` never runs, so "Vary Start" never removes a Rebel army.
- `battle`: `s = 1: IF attack > 2 THEN s = 2` most likely meant `attack > 20`. As written, casualties are
  counted for the wrong side when Union armies 3 to 20 attack.
- `battle` and `tupdate`: `SELECT CASE` tests `IS > 300` before `IS > 800` (and `IS > 400` before `IS > 800`
  and `IS > 1000`), so the later cases are never reached.
- `tupdate`: `victory(2) = victory(1) + 100` in the Rebel line most likely meant `victory(2) + 100`.

## Settled names

One row for each SUB and FUNCTION, in alphabetical order of its current name.

`draw_` is for a SUB that puts a fixed piece of the screen in place, whether lines or text. `print_` is only
for a SUB that writes at the cursor, as a `PRINT` statement does.

| Current name | Settled name |
|--------------|--------------|
| `animate` | `animate_army` |
| `announce` | `script_mark_key_wait` |
| `armies` | `menu_army_move` |
| `armystat` | `draw_army_stats` |
| `armyxy` | `draw_flag_icon` |
| `barnacle` | `navy_remove_ship` |
| `battle` | `calculate_battle` |
| `bub2` | `sort_move_order` |
| `bubble` | `menu_bubble_sort` |
| `burn` | (deleted) |
| `cancel` | `menu_army_cancel` |
| `cannon` | `draw_cannon` |
| `capitol` | `draw_union_victory` |
| `capture` | `city_capture` |
| `center` | `print_centered` |
| `chessie` | `draw_chesapeake` |
| `choices` | `draw_menu` |
| `clrbot` | `clear_bottom_line` |
| `clrrite` | `clear_right_panel` |
| `combine` | `army_combine` |
| `commander` | `army_get_commander` |
| `cutoff` | `city_is_connected` |
| `DIR$` | `DIR$` (kept) |
| `endit` | `menu_victory_conditions` |
| `engine` | `draw_train_box` |
| `evaluate` | `ai_evaluate_move` |
| `events` | `special_events` |
| `filer` | `file_management` |
| `flags` | `draw_flag` |
| `flashcity` | `animate_city` |
| `fortify` | `menu_city_fortify` |
| `icon` | `draw_map_marker` |
| `image2` | `show_message_box` |
| `integrity` | `check_map_links` |
| `ironclad` | `draw_ironclad` |
| `iterate` | `turn_date_and_supply` |
| `maptext` | `draw_city_names` |
| `maxx` | `hall_of_fame` |
| `menu` | `menu_select` |
| `movefrom` | `menu_army_select` |
| `mxw` | `menu_measure_width` |
| `navy` | `navy_commands` |
| `newarmy` | `army_new` |
| `newcity` | `menu_city_select` |
| `normal` | `normal_random_number` |
| `occupy` | `city_update_occupier` |
| `placearmy` | `draw_army_flag` |
| `railroad` | `railroad_move` |
| `recruit` | `menu_army_recruit` |
| `relieve` | `menu_army_relieve` |
| `report` | `menu_report` |
| `resupply` | `army_resupply` |
| `retreat` | `menu_army_retreat` |
| `roman` | `army_generate_name` |
| `rwin` | `draw_rebel_victory` |
| `schooner` | `draw_schooner` |
| `scribe` | `scribe_message` |
| `scriptdate$` | `script_date$` |
| `scriptshell` | `script_shell` |
| `scriptstart` | `script_start` |
| `scripttick%` | `script_tick%` |
| `scrnsavr` | (deleted) |
| `shen` | `play_shenandoah` |
| `shipicon` | `draw_ship_icon` |
| `ships` | `draw_fleets` |
| `shiptype` | `draw_fleet_ship` |
| `showcity` | `draw_cities` |
| `smarts` | `ai_turn` |
| `snapshot` | `screen_snapshot` |
| `starfin` | `side_army_range` |
| `stax` | `draw_stack_markers` |
| `strong` | `print_army_size` |
| `surrender` | `draw_surrender` |
| `TICK` | `wait_seconds` |
| `tinytrain` | `draw_train` |
| `topbar` | `draw_top_bar` |
| `touchup` | `draw_map_touchup` |
| `traincapacity` | `railroad_capacity` |
| `tupdate` | `turn_resolve` |
| `usa` | `draw_map` |
| `victor` | `check_victory_conditions` |
| `void` | `city_nearby_enemy_strength` |
