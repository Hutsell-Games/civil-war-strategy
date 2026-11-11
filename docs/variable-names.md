# Shared variable and parameter names

Every shared variable of the game on the `qb64rust` branch (commit `8c3b185`), with what it holds and a
proposed name. This is the table that phase 4 of `modernize-plan.md` renames from. It works like
`sub-names.md`: the "Your name" column is empty, and a name written there replaces Claude's.

The shared variables are declared in `CWS14.BI`. "Uses" counts where the name appears in `CWSTRAT.BAS`,
`CWSTRAT1.BM`, `CWSTRAT2.BM` and `CWSMENU.BM`. "Record field" is the name the variable gets in phase 10,
when the arrays become records; it is here to show that each proposed name maps onto one.

Rules the proposals follow (decisions 17 and 18 of the plan):

- The subject comes first, in snake_case: `army_`, `city_`, `side_`, `fleet_`, `train_`, `menu_`, `opt_`,
  `turn_`, `pic_`.
- An array indexed by side (1 Union, 2 Rebel) starts with `side_`, unless it belongs to the fleet or the
  train, which each side has one of.
- A setting that `CWS.CFG` saves starts with `opt_`.
- A name says what the value is, not its type: `army_city`, not `army_loc`.

## Armies

Indexed by army, 1 to 40. Armies 1 to 20 are Union, 21 to 40 Rebel. Index 0 is a scratch army in `combine`.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `armyname$()` | The army's name, which is its leader's name. Empty when the slot is free. | 76 | `army_name$()` | `armies(i).name` | |
| `armysize()` | Its size in hundreds of men. 0 when the slot is free. | 139 | `army_size()` | `armies(i).size` | |
| `armylead()` | Its leader's rating, 1 to 9. | 35 | `army_leader_rating()` | `armies(i).leader_rating` | settled 2026-11-11 (first proposal `army_leadership()`, your note `armies(i).leader`) |
| `armyexper()` | Its experience, 0 to 10. | 49 | `army_experience()` | `armies(i).experience` | |
| `supply()` | Its supply level, 0 to 10. | 72 | `army_supply()` | `armies(i).supply` | |
| `armyloc()` | The city it is in. 0 when the slot is free. | 143 | `army_city()` | `armies(i).city` | |
| `armymove()` | Its order: the city it marches to, 0 for none, or below 0 when it cannot move this turn (it drilled, fortified, was just raised, or came by train). | 88 | `army_order()` | `armies(i).order` | |
| `lname$()` | The leaders not yet used, by army slot. A slot's entry is emptied when its leader takes an army. | 24 | `leader_name$()` | `leaders(i).name` | |
| `rating()` | The rating of the leader in `lname$()`. | 13 | `leader_rating()` | `leaders(i).rating` | |
| `brray()` | The order of movement for this turn: one sort key for each army, sorted by `bub2`. | 24 | `move_order_key()` | (stays an array) | |

## Cities

Indexed by city, 1 to 40.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `city$()` | The city's name. `city$(0)` is "NONE". | 86 | `city_name$()` | `cities(c).name` | |
| `cityx()`, `cityy()` | Its place on the screen, in pixels. | 37, 46 | `city_x()`, `city_y()` | `cities(c).x`, `.y` | |
| `cityv()` | Its value: income each turn and victory points. | 21 | `city_value()` | `cities(c).value` | |
| `cityp()` | Its owner now: 0 neutral, 1 Union, 2 Rebel. | 73 | `city_owner()` | `cities(c).owner` | |
| `cityo()` | Its owner when the game began. | 3 | `city_first_owner()` | `cities(c).first_owner` | |
| `fort()` | Its fort level, 0 to 2. | 44 | `city_fort()` | `cities(c).fort` | |
| `occupied()` | The first army found in the city, or 0. Set by `occupy`. | 59 | `city_army()` | `cities(c).army` | |
| `matrix()` | `matrix(c, 1 TO 6)`: the cities joined to city `c` by road, 0 for none. `matrix(c, 7)`: 99 when the city is a port. | 43 | `city_road()` and `city_port_type()` (see note 1) | `cities(c).road(1 TO 6)`, `.is_port` | |
| `capcity()` | By side: the side's capital city, 0 when it has fallen. | 37 | `side_capital()` | `sides(s).capital` | |

## Sides

Indexed by side: 1 Union, 2 Rebel.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `force$()` | The side's name: "Union", "Rebel". | 45 | `side_name$()` | `sides(s).name` | |
| `cash()` | Its money. | 89 | `side_cash()` | `sides(s).cash` | |
| `income()` | Its income this turn. | 28 | `side_income()` | `sides(s).income` | |
| `control()` | The number of cities it holds. | 31 | `side_city_count()` | `sides(s).city_count` | |
| `victory()` | Its victory points. | 72 | `side_victory_points()` | `sides(s).victory_points` | |
| `batwon()` | Battles it has won. | 13 | `side_battles_won()` | `sides(s).battles_won` | |
| `casualty&()` | Men it has lost. | 15 | `side_casualties&()` | `sides(s).casualties` | |
| `vptotal` | The two sides' incomes added, used for percentages in the reports. | 6 | `total_income` | (stays a scalar) | |
| `usadv` | The Union's income bonus, set from the difficulty. | 9 | `union_income_bonus` | `game\` (phase 11) | |
| `emancipate` | 1 once the Emancipation Proclamation event has happened. | 3 | `emancipation_done` | `game\` (phase 11) | |

## Navy

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `fleet$()` | By side: one letter for each ship, "W" wooden or "I" ironclad. | 41 | `fleet_ships$()` | `fleets(s).ships` | |
| `navysize()` | By side: the number of ships. Kept equal to `LEN(fleet$())`. | 82 | `fleet_size()` | `fleets(s).size` | |
| `navyloc()` | By side: the port city the fleet is in, 0 for no fleet, 99 for at sea raiding commerce. | 96 | `fleet_city()` | `fleets(s).city` | |
| `navymove()` | By side: set to 0 and saved, never read. | 4 | `fleet_unused()` (see note 2) | none | |
| `commerce` | The side whose fleet is raiding commerce, or 0. | 27 | `raiding_side` | (stays a scalar) | |
| `raider` | The money the raiders sank this turn. | 9 | `raid_loss` | (stays a scalar) | |
| `grudge` | 1 when the last sea fight left a fleet that the computer should go after. | 8 | `fleet_pursuit` | (stays a scalar) | |

## Railroad

Indexed by side.

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `rr()` | The army on the side's train, or 0. | 21 | `train_army()` | `trains(s).army` | |
| `rrfrom()` | The city the train left. | 4 | `train_from_city()` | `trains(s).from_city` | |
| `tracks()` | The city where the train icon is drawn. | 7 | `train_city()` | `trains(s).city` | |
| `train()` | The largest army the side's train can carry (from `CWS.CFG`). | 11 | `train_capacity()` | `trains(s).capacity` | |

## The turn and the game

| Current | What it holds | Uses | Proposed | Record field | Your name |
|---------|---------------|-----:|----------|--------------|-----------|
| `month`, `year` | The date. | 30, 30 | `turn_month`, `turn_year` | | |
| `month$()` | The months' names. | 14 | `month_name$()` | | |
| `side` | The side that gives orders now: the human's side in a one-player game, each side in turn in a two-player game. | 163 | `current_side` (see note 3) | | |
| `player` | The number of human players, 1 or 2. | 32 | `opt_players` | | |
| `rflag` | Recruiting this turn: 0 not yet offered, above 0 the number of cities on offer, below 0 no more. | 11 | `turn_recruit_state` | | |
| `rcity()` | The cities on offer for recruiting this turn. | 2 | `turn_recruit_city()` | | |
| `mflag` | Above 0 when no army is left to give a move order to. | 5 | `turn_moves_done` | | |
| `nflag` | Above 0 when the navy has acted this turn. | 10 | `turn_navy_done` | | |
| `aggress!` | The computer's strength against the player's, as a ratio. It makes the computer bolder. | 14 | `ai_strength_ratio!` | | |
| `pcode` | 1 when the game is over and a new one must start. | 3 | `game_over` | | |
| `thrill` | The victory condition that ended the game, marked in the last report. | 2 | `victory_reason` | | |
| `vicflag()` | The victory conditions: (1) month and (2) year of the time limit, (3) a number of cities, (4) a percent of the total income, (5) capital captured, (6) force ratio. Above 0 means on. | 50 | `victory_rule()` | | |
| `filel` | 0 when no saved game was found, so Load shows as "-". | 4 | `saves_exist` | | |
| `scripted` | 1 when `tests\play.py` runs the program. | (in `SCRIPT.BM`) | `scripted` (kept) | | |

## Settings

Saved in `CWS.CFG`, except `bw`.

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `graf` | Graphics level, 0 to 3: 0 off, 2 city names, 3 full with pictures. | 23 | `opt_graphics` | |
| `noise` | Sound: 0 off, 1 effects, 2 effects and music. | 49 | `opt_sound` | |
| `difficult` | Difficulty, 1 to 5. | 30 | `opt_difficulty` | |
| `turbo!` | The length of a pause, in seconds. | 58 | `opt_pause!` | |
| `randbal` | Random events: 0 off, else how far they favor a side. | 23 | `opt_event_balance` | |
| `jancam` | 1 when campaigns in January and February are allowed. | 10 | `opt_winter_campaigns` | |
| `realism` | Realism, 0 to 2. | 27 | `opt_realism` | |
| `history` | 1 when messages are written to `cws.his`. | 12 | `opt_history` | |
| `bold` | The computer's aggression, 0 to 5. | 19 | `opt_ai_aggression` | |
| `bw` | 1 for the alternate colors of menus and city names. | 6 | `opt_alt_colors` | |
| `ATKFAC`, `DEFAC` | The attacker's and the defender's loss factors, read from `CWS.INI`. | 2, 2 | `rule_attack_loss`, `rule_defend_loss` | |
| `TCR` | The cap on an army's strength in a battle, read from `CWS.INI`. | 25 | `rule_strength_cap` | |

## Menus

`menu` takes its input and gives its answer through these shared variables.

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `mtx$()` | The menu's title (0) and its options (1 and up). Also used as scratch text. | 227 | `menu_text$()` | |
| `size` | The number of options. | 163 | `menu_item_count` | settled 2026-11-11 (first proposal `menu_count`, your note `menu_items`) |
| `choose` | Going in: 21 plus the option to start on. Coming out: the option picked, below 1 for none. | 176 | `menu_choice` | |
| `array()` | A value for each option, such as the city or army it stands for. | 68 | `menu_value()` | |
| `tlx`, `tly` | The column and row of the menu's top left corner. | 83, 83 | `menu_col`, `menu_row` | |
| `colour` | The color of the menu's box. | 36 | `menu_color` | |
| `hilite` | The color of the chosen option. | 18 | `menu_highlight` | |
| `wtype` | The kind of box: 2 with a title bar; above 10 it also carries the box color. | 13 | `menu_box_type` | |

## Pictures and drawing

| Current | What it holds | Uses | Proposed | Your name |
|---------|---------------|-----:|----------|-----------|
| `graphic()` | A picture loaded with `BLOAD`: the icon sheet, then a general's face before a battle. | 6 | `pic_loaded()` | |
| `graft()` | A picture loaded by `menu`: a leader's face (case 8). | 3 | `pic_face()` | |
| `mtn()` | The mountain picture, drawn 8 times by `usa`. | 10 | `pic_mountain()` | |
| `Ncap()` | The capital's star, cut from the icon sheet. | 2 | `pic_capital()` | |
| `image()` | The piece of screen saved under a map marker or a moving army. | 8 | `saved_under_marker()` | |
| `anima()` | The piece of screen saved under an army's icon. | 4 | `saved_under_army()` | |
| `font$()` | The `DRAW` string of each letter, A to Z, of the map's own font. | 4 | `map_font$()` | |
| `starx()`, `stary()` | Where the 8 stars go on the Rebel flag of the victory screen (from `CWS.INI`). | 2 | `flag_star_x()`, `flag_star_y()` | |

## Unused

| Current | Finding | Proposed |
|---------|---------|----------|
| `price()` | Declared, never used. | Delete in phase 1. |
| `DECLARE SUB banner`, `blastem`, `sndblst`, `sndfx`, `usamap`, `war` | No such SUB exists. QB64 needs no `DECLARE` lines at all. | Delete every `DECLARE` in phase 1. |

## Parameters

A parameter gets the name of what is passed, the same in every SUB.

| Current | Where | What is passed | Proposed |
|---------|-------|----------------|----------|
| `who` | 17 SUBs | A side, 1 or 2. | `side` (see note 3) |
| `s` | `capture`, `image2` | In `capture` a side; in `image2` a number of seconds. | `side`; `seconds` |
| `index` | `animate`, `armystat`, `strong`, `resupply`, `evaluate`, `movefrom` | An army. | `army` |
| `index` | `newcity` | A city, in and out. | `city` |
| `which` | `placearmy` an army; `flashcity` a city | | `army`; `city` |
| `attack`, `defend` | `battle`, `retreat` | The attacking and the defending army. | `attacker`, `defender` |
| `win`, `lose` | `battle` | The armies that won and lost, out. | `winner`, `loser` |
| `target` | `cutoff`, `fortify`, `newarmy`, `movefrom`, `roman` | A city (in `roman` an army). | `city`; `army` in `roman` |
| `from`, `dest` | `icon` | Two cities. | `from_city`, `to_city` |
| `kind` | `icon` | Which mark to draw, 1 to 11. | `mark` (with the `MARK_` constants) |
| `switch` | `menu` | What to show beside the highlighted item, a bare number (3 changes how keys return). | `menu_item_show_beside` (with constants) |
| `switch` | `filer` | Which job: 1 scenario, 2 load, 3 save. | `job` (with constants) |
| `chx` | `navy` | The naval action the computer wants, 0 for the player's menu. | `action` |
| `empty` | `newarmy`, `commander` | A free army slot. | `slot` |
| `flag` | `animate`, `snapshot`, `tinytrain`, `scribe`, `shipicon`, `capture` | A different yes-or-no or choice in each. | Named in each SUB: `show` (draw_train), `ship_type` (draw_ship_icon), `background_saved` (animate_army), `weaken_fort` (city_capture), `display` (scribe_message), `put_back` (screen_snapshot). |
| `a`, `x`, `y`, `limit`, `result` | `cutoff`, `void`, `evaluate`, `retreat`, `traincapacity`, `normal` | The value the SUB gives back. | Goes away in phase 5, when the SUB becomes a FUNCTION. |
| `x`, `y`, `z` | `armyxy`, `snapshot` | A screen position; `z` a side. | `x`, `y` kept; `z` to `side` |
| `a$` | `center`, `image2`, `scribe`, `roman` | A text. | `text$`; `name$` in `roman` |
| `sec!` | `TICK` | Seconds. | `seconds!` |

## Notes

1. **`matrix()` holds two things.** Columns 1 to 6 are roads and column 7 is the port mark. The proposal
   splits it into `city_road(c, 1 TO 6)` and `city_port_type(c)`. Column 7 is not a yes-or-no: it is 0 for
   no port, 90 for a river port and 99 for a sea port (`cities.grd`), so it is `city_port_type`, not
   `city_is_port`. That is more than a rename: each `matrix(i, 7) = 99` becomes `city_port_type(i) = 99`. The split is its own step in phase 4, after the plain
   renames. `maxx` also uses `matrix()` as scratch space for the Hall of Fame's scores; it gets a local
   array of its own in the same step.
2. **`navymove()` is never read**, but `filer` writes it to the saved game, and the save format is frozen
   (decision 6). It could become a constant 0 in the `WRITE #` and a dummy in the `INPUT #`, and the array
   could go. That is proposed for phase 7, when `filer` is split.
3. **`side` and `who`.** Today the shared `side` is "the side that gives orders now", and 17 SUBs take a
   parameter `who` for "the side this call is about". Decision 11's example renames `who` to `side`. Both
   cannot be `side`, so the shared one becomes `current_side`. The rename script must do the shared one
   first. `cancel (side)` already has a parameter with the shared variable's name; it keeps `side`.
4. **`mtx$()` and `array()` as scratch.** Several SUBs use them for things that are not a menu (`endit`
   keeps texts in `mtx$(8)` and `mtx$(9)`; `bubble` sorts both). They are renamed as menu variables now.
   A SUB that misuses them gets locals when it is reworked.
5. **Locals with the same name as a shared variable.** The rename script works on tokens, so it must know
   scope: a parameter or a `DIM` inside a SUB hides the shared name. Known case: `cancel (side)`. Turning on `OPTION _EXPLICIT` at the end of phase 4 finds any that were missed.
