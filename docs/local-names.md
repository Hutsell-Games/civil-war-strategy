# Local variable, parameter and label names

The renames of phases 4 and 5 covered the shared variables (`variable-names.md`) and the SUBs (`sub-names.md`).
They left the names inside each SUB: its parameters, its `DIM` locals and its `GOTO` labels. Many of these are
still the original's: `chosit`, `star` and `fin`, `xbar`, `slush`, `killd`, labels such as `deadman` and `puter`.

This document lists them, on branch `refactor_naming` at commit `d70ccbb`. Part 1, the local variables and
parameters, is the table to rename from. It works like the earlier tables: the "Your name" column is empty, and
a name written there replaces Claude's. Parts 2 to 4 list the labels, a few constants and the oddities found
while reading. They come after part 1.

## Rules the proposals follow

These are the rules of `variable-names.md`, used for locals:

- snake_case, and a name says what the value is, not its type.
- The same thing gets the same name in every SUB: an army is `army`, a side is `side`, a city is `city`.
- When a SUB already has that name, the second one says how it differs: `to_city`, `spare_army`.
- QB64 keywords cannot be names. So a color is `side_color` or `dot_color`, never `color`. A width is
  `menu_width`, never `width`. `command$`, `key$` and `line$` are out for the same reason.

Two kinds of name are kept:

- **`i`, `j`, `k` and `n` as loop counters.** Where one holds something else, part 1 lists it.
- **`x` and `y` as a screen position**, in pixels or in text columns and rows. Where one holds a count, a city
  or a strength, part 1 lists it.

A rename inside a SUB touches nothing outside it. The rename can be checked the same way as before:
`tests\rules_test.bas` and the scripts of `tests\play.py` must give the same results. One risk is a local that
gets the name of a shared variable, a CONST, a SUB or a FUNCTION. That would make it hide the shared one, or
not compile. Every proposal below was checked against the 90 shared names in `cws.bi` and against the CONSTs,
SUBs and FUNCTIONs. The shared side is `current_side`, so `side` is free.

## Part 1: local variables and parameters

### 1a. Names with one meaning in many SUBs

Each row is one rename, done in every SUB it lists. Part 1b lists the SUBs where the same name means something
else.

**Done on 2026-11-12**, by `tools\refactor\rename_locals.py` (101 SUBs). Two rows were left out at the user's
word: `kind` stays `kind`, and the sorts' `limit` stays `limit`. The unit tests (123) and the scripts (38, both
compilers) gave the same results as before.

| Current | What it holds | SUBs | Proposed | Your name |
|---------|---------------|------|----------|-----------|
| `star`, `fin` | A side's first and last army, from `side_first_army` and `side_last_army`. `star` reads as a star. | `ai_resupply`, `ai_fortify_pick`, `ai_count_armies`, `ai_army_orders`, `ai_drill`, `army_combine_gather`, `load_game`, `army_pick_commander`, `army_list_combine_cities`, `menu_main_inform`, `menu_army_select`, `menu_army_cancel`, `menu_army_relieve`, `menu_supply`, `report_armies`, `report_intelligence` | `first_army`, `last_army` | |
| `who` | A side, 1 or 2. `variable-names.md` planned this rename ("Parameters"); some SUBs were done, these were not. | Parameter: `ai_resupply`, `ai_fortify`, `ai_fortify_pick`, `ai_raise_forces`, `ai_count_armies`, `ai_fleet_orders`, `ai_army_orders`, `ai_army_order`, `ai_drill`, `event_riot_city`, `event_riot`. Local: `draw_army_flag`, `load_game`, `army_buy_supply`, `menu_city_fortify`, `menu_army_select`, `menu_army_retreat` | `side` | |
| `index` | An army. | Local: `navy_bombard`, `railroad_arrive`, `railroad_unload`, `menu_army_move`, `menu_army_cancel`, `menu_army_relieve`, `menu_army_detach`, `menu_army_drill`, `event_roll`. Parameter: `turn_army_surrenders` | `army` | |
| `active` | The army whose move is being carried out. | Parameter: `city_capture`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats`, `turn_army_surrenders`, `turn_enter_city`. Local: `turn_resolve` | `moving_army` | |
| `defend` | The army in the city that is attacked. | `turn_attack` (local), `turn_attacker_withdraws`, `turn_defender_retreats` (parameters) | `defender` | |
| `defend` | The enemy's strength near a city, from `city_nearby_enemy_strength`. It is not an army. | `ai_fortify_pick`, `ai_army_order`, `ai_evaluate_move`, `ai_railroad` | `enemy_strength` | |
| `from` | The city an army or a train sets out from. | `ai_evaluate_move`, `army_recruit`, `railroad_start`, `railroad_board`, `animate_army` | `from_city` | |
| `s` | A side. | `draw_fleets`, `hall_of_fame_load`, `hall_of_fame_save`, `hall_of_fame` (`ui\victory.bm`), `battle_apply_losses`, `turn_army_supply`, `turn_army_lost`, `turn_move_army`, `turn_enter_city`. Parameter: `hall_of_fame_place`, `hall_of_fame_insert` | `side` | |
| `a` | The number of a side's cities next to a city, from `city_is_connected`. 0 means cut off. | `ai_recruit_pick`, `army_raise`, `army_buy_supply`, `army_add_recruits`, `turn_army_supply`, `menu_supply`, and the count itself in `city_is_connected` | `friendly_neighbors` | |
| `a` | A ship's kind for `draw_ship_icon`: 1 wooden, 2 ironclad. | `navy_ship_joins`, `navy_fleet_founded`, `navy_commerce_raid`, `draw_fleets`, `draw_fleet_ship` | `ship_type` | |
| `c` | A side's color: 9 (or 1) for the Union, 7 (or 15) for the Rebels. | `draw_train`, `draw_train_box`, `draw_top_bar`, `draw_player_turn`, `draw_surrender`, `calculate_battle`, `report_armies`, `report_intelligence`, `report_force_summary`, `ai_turn`, `end_game` | `side_color` | |
| `c` | A city dot's color: its owner's, or a flash color. | `animate_city`, `draw_cities`, and the parameter of `draw_city_dot` | `dot_color` | |
| `c` | The color of the computer's messages. | Parameter: `ai_army_orders`, `draw_ai_plan` | `text_color` | |
| `wide` | A menu's width, in columns. | `draw_menu`, `menu_select`, `menu_arrow_key`, `menu_mark_row`, `menu_measure_width`, `show_message_box` | `menu_width` | |
| `b1` | The column where a menu's title starts, from the left of the box. | `draw_menu`, `menu_select`, `menu_arrow_key` | `title_col` | |
| `kind` | The menu's mode: what it shows beside the highlighted row (`MENU_PLAIN`, `MENU_CITY_BOX` and the others). | Parameter: `menu_arrow_key`, `menu_mark_row`, `menu_unmark_row` | `mode` | `kind` (kept) |
| `boxc` | The color of a menu's box. | `draw_menu`, `menu_select` | `box_color` | |
| `hit()` | The hits each fleet still has to give in a sea fight, by side. | `navy_combat_begin`, `navy_combat_volley`, `navy_combat_auto`, `navy_show_hits`, `menu_navy_combat` | `hits()` | |
| `over` | 1 when the sea fight is over. | `navy_combat_volley`, `navy_combat_auto`, `menu_navy_combat` | `combat_over` | |
| `limit` | The largest army the train can carry, from `railroad_capacity`. | `ai_railroad`, `menu_main_railroad`, `menu_railroad`, and the result being worked out in `railroad_capacity` | `capacity` | |
| `limit` | The number of entries to sort. | Parameter: `sort_move_order`, `menu_bubble_sort` | `count` | `limit` (kept) |
| `FALSE` | A local that is always 0, used as false. | `sort_move_order`, `menu_bubble_sort` | Delete; write `0`, or add `CONST FALSE = 0` to `cws.bi` | Deleted; `CONST FALSE = 0` in `cws.bi` |
| `pct!` | A chance, compared with a random number. | `army_recruit_cities` (`event_roll` is in part 1b) | `chance!` | |
| `x`, `y` | The Union's and the Rebels' men in the field, in hundreds (`victory_forces`). | Parameter: `victory_forces`, `victory_rule_met`, `victory_near_force`, `victory_warnings`. Local: `check_victory_conditions` | `union_men`, `rebel_men` | |
| `i` | A side. | Parameter: `victory_rule_met`, `victory_near_cities`, `victory_near_income`, `victory_near_force`, `victory_won`, `victory_warnings`, `end_game`. Local: `check_victory_conditions` | `side` | |
| `j` | A victory rule, 2 to 7. | Parameter: `victory_rule_met`, `victory_play_on`, `victory_won`, `end_game`. Local: `check_victory_conditions` | `rule` | |
| `a$`, `t$` | A message built and then printed or passed to `scribe_message`. About 230 uses. | Most SUBs that print | Kept, or `message$`. Part 1b lists the ones that hold something else. | |

### 1b. Names that mean something of their own in one SUB

By file, in the order of the SUBs. A name in 1a is listed here only where it means something else.

#### `cws.bas` (the main program)

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| main | `chosit` | The option the main menu starts on next time, as `MENU_START` + its row. It is kept from one game to the next. | `main_menu_start` | |
| main | `a$` | The "EVENTS FOR" line written to the history. | `message$` | |
| `DECLARE` lines | `who%`, `flag%`, `xbar%`, `vary%`, `z%`, `w%`, `a%`, `active%` | The parameter names of the 10 `DECLARE` lines that have parameters (of 14). They are the old names and do not match the SUBs. | Delete the `DECLARE` lines (QB64 needs none), or give them the SUBs' names | |

#### `ai\ai.bm`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `ai_fortify` | `side_cash` | A local scalar with the same name as the shared array `side_cash()`. It is always 0. It is read once, in `side_cash < 222` (part 4, item 9); every `side_cash(side)` is the array. | Kept until item 9 is decided | |
| `ai_fortify` | `target` | The city to fortify. | `city` | |
| `ai_fortify` | `x` | The army in that city. | `army` | |
| `ai_fortify_pick` | `target` (parameter) | The city picked to fortify, out. | `fort_city` | |
| `ai_fortify_pick` | `x` | The city of the army being looked at. | `city` | |
| `ai_raise_forces` | `slush` | The cost of a ship, held back from the cash while the computer recruits, then given back. | `ship_reserve` | |
| `ai_raise_forces` | `x` | The number of armies, from `ai_count_armies`. | `army_count` | |
| `ai_count_armies` | `x` | The number of the side's armies, less 2 when outnumbered. The FUNCTION's result. | `army_count` | |
| `ai_count_armies` | `y`, `z` | The other side's and this side's strength, in tenths of the men. | `enemy_strength`, `own_strength` | |
| `ai_army_order` | `target` | The city the army is in. | `city` | |
| `ai_army_order` | `x` | The army's size. | `army_men` (see part 4, item 6) | |
| `ai_army_order` | `k` | A city next to the capital. | `neighbor` | |
| `ai_army_order` | `flag` | The enemy's strength near that city. It is not a flag. | `neighbor_strength` | |
| `ai_army_order` | `best` | The road picked, from `ai_evaluate_move`. | `best_road` | |
| `ai_army_order` | `y` | The army already in the city the order goes to. | `other_army` | |
| `ai_evaluate_move` | `x` (parameter) | Two things. First, how much the computer wants to stay in a fortified city. At the end, the road picked, out. | `best_road` for the parameter, and a new local `stay_weight` for the first use | |
| `ai_evaluate_move` | `best` | Two things: the army's size, then the number of the best road so far. | `own_strength`, then `best_road` | |
| `ai_evaluate_move` | `max` | The number of roads out of the city. | `road_count` | |
| `ai_evaluate_move` | `a` | The city at the end of the road being scored. | `to_city` | |
| `ai_evaluate_move` | `c` | The army in that city. | `occupant` | |
| `ai_evaluate_move` | `m` | A city two roads away. | `far_city` | |
| `ai_evaluate_move` | `y` | The road's score. | `score` | |
| `ai_evaluate_move` | `x1` | How much that city's fort multiplies its defender: 1, 2 or 3. | `fort_factor` | |
| `city_nearby_enemy_strength` | `a` (parameter) | The city. | `city` | |
| `city_nearby_enemy_strength` | `x`, `m` | A city next to it, and a city two roads away. | `neighbor`, `far_city` | |
| `city_nearby_enemy_strength` | `y` | The strength added up. The FUNCTION's result. | `strength` | |
| `ai_recruit_pick` | `x` | Two things: the army in a city, then the best score so far. | `army`, then `best_score` | |
| `ai_recruit_pick` | `target` | A city on the recruiting list. | `city` | |
| `ai_recruit_pick` | `y` | That city's score. | `score` | |
| `ai_railroad` | `max` | The lowest enemy strength found near an army so far. | `least_threat` | |
| `ai_railroad` | `index` | The army picked to send: the one farthest from the enemy. | `spare_army` | |
| `ai_railroad` | `x` | Two things: how many enemy cities are next to an army, then a count of track from `railroad_route_count`. | `enemy_neighbors`, then `routes` | |
| `ai_railroad` | `from` | Two things: a city next to an army's city, then the city the train leaves. | `neighbor`, then `from_city` | |
| `ai_railroad` | `target` | A city looked at as the start or the end of the train ride. | `candidate` | |
| `ai_railroad` | `x1` | The city the train goes to. | `to_city` | |
| `ai_pick_port` | `x` | How many enemy ports are on the list. | `enemy_ports` | |
| `ai_pick_port` | `target` | A port on the list. | `port` | |

#### `commands\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `army_recruit` | `empty` | A free army slot. | `slot` | |
| `city_capture` | `c` (parameter) | The city. | `city` | |
| `city_capture` | `capital` | 1 when the city was the enemy's capital. | `was_capital` | |
| `navy_bombard` | `target` | The city the fleet lies off. | `city` | |
| `navy_bombard` | `killd` | The men the army lost, in hundreds. | `casualties` | |
| `navy_land_army` | `c` | The city the fleet is in. | `city` | |
| `navy_combat_retreat` | `target` | The port the beaten fleet goes to. | `port` | |

#### `draw\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `animate_army` | `background_saved` (parameter) | 1 when the caller has already saved the screen under the icon (`TODO.md` notes the name is wrong). | `picture_taken` | |
| `animate_army` | `to2` | The city the army marches to. | `to_city` | |
| `animate_army` | `x1`, `y1` | The icon's place on the way, between the two cities. | `step_x`, `step_y` | |
| `draw_train` | `from` | The city where the train is drawn. | `city` | |
| `draw_flag` | `w` (parameter) | How far right of x = 585 the flag goes. 0 is the main flag, which also gets the side's name. | `x_offset` | |
| `draw_flag` | `a` (parameter) | The flag's top row, in pixels. 0 for the default. | `top_y` | |
| `draw_city_names`, `draw_map` | `x` | A letter's number in `map_font$()`, 1 for A. | `letter` | |
| `draw_city_names` | `a` | The x position of that letter. | `letter_x` | |
| `draw_stack_markers` | `target` | The city of the army. | `city` | |
| `draw_fleet_ship` | `i` (parameter) | The ship's place in the fleet. | `ship` | |
| `draw_fleet_sailing` | `a` | The letter code of the lead ship. | `lead_ship` | |

#### `game\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `event_roll` | `who` (parameter) | The side the event was rolled for, out. A roll for the Union gives an event good for the South. | `event_side` | |
| `event_roll` | `pct!` | Two things: the chance of an event (line 23), then the share of each army's men kept after the uprising (lines 70 to 76). | `chance!`, then `share_kept!` | |
| `event_roll` | `plus` | The difficulty, turned round for the Union. It makes events likelier and bigger. | `event_weight` | |
| `event_roll` | `empty` | The Rebel port that the English ships sail to. | `port` | |
| `event_roll` | `x` | Two things: the ships to add to a fleet, then a counter of armies. | `new_ships`, then `count` | |
| `event_riot_city` | `x` | A city picked at random. | `city_tried` | |
| `draw_union_victory` | `x` | Which of the Capitol's two wings is being drawn. | `wing` | |
| `draw_surrender` | `side` (parameter) | An army, not a side. The caller passes `index`, an army (`ui\turn.bm` line 196). | `army` | |
| `draw_surrender` | `s` | The army's side. | `side` | |
| `draw_surrender` | `w` | The left edge of the right panel, 514 pixels. | `panel_x` | |

#### `port\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `load_scenario` | `a` | The number of armies the scenario has for a side. | `army_count` | |
| `load_cities` | `a` | The city's number in `cities.grd`, read and not used. | `unused` | |
| `load_cities` | `x` | The city's owner. | `owner` | |
| `load_game` | `a` | The side whose turn it is, read from the saved game. | `saved_side` | |
| `load_game` | `myside` | The side in `CWS.CFG`. It is read and then not used. | `config_side` | |
| `save_game` | `myside` | The side written to `CWS.CFG`. | `config_side` | |
| `DIR$` | `f$` | The file name found. | `found$` | |
| `script_shell` | `sp` | Where the first space is. | `space_at` | |
| `script_shell` | `c$` | The command, trimmed. `command$` is a keyword. | `trimmed$` | |
| `script_shell` | `d$` | The file's contents. | `contents$` | |
| `script_shell` | `f` | A file number. | `file_num` | |

#### `rules\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `army_combine_add` | `pct!` | The army's share of the men in the combined army. | `share!` | |
| `army_raise` | `x` | The new army's size. | `men` | |
| `army_add_recruits` | `x` | The men added. | `men` | |
| `army_pick_commander` | `x` | The army slot passed to `army_generate_name`. | Delete; pass `i` | |
| `army_pick_commander` | `a$` | The made-up leader's name. | `name$` | |
| `army_buy_supply` | `x` | The supply the cash can buy, then the supply bought. | `supply_added` (`SUPPLY_BOUGHT` is a CONST) | |
| `army_buy_supply` | `y` | The army's new supply level. | `new_supply` | |
| `army_generate_name` | `x` | The number written as a Roman numeral. | `number` | |
| `army_recruit_cities` | `max` | How many cities are offered. | `offer_count` | |
| `army_recruit_cities` | `x` | A city on the list. | `city` | |
| `battle_strengths` | `x`, `x1` | The attacker's and the defender's strength, built step by step. | `attack_strength`, `defend_strength` | |
| `battle_strengths` | `R!` | The defender's size over the attacker's. | `size_ratio!` | |
| `battle_fight` | `attack`, `defend` (parameters) | The two strengths. | `attack_strength`, `defend_strength` | |
| `battle_fight` | `scale` | The size of the die: the larger strength, plus 1. | `die_size` | |
| `battle_fight` | `star`, `fin` | Here two dice rolls, not two armies. | `attack_roll`, `defend_roll` | |
| `battle_fight` | `hit`, `hit1` | 1 when the attacker's roll hits, and when the defender's does. | `attacker_hit`, `defender_hit` | |
| `battle_losses` | `pct!` | The share of an army lost. | `loss_rate!` | |
| `battle_losses`, `normal_random_number` | `xbar`, `vary` | The mean and the variance of the losses. `xbar` is the statistics name for a mean (x̄). | `mean`, `variance` | |
| `normal_random_number` | `pct!` | The sum of 11 random numbers, less 5.5. | `sum!` | |
| `city_is_connected` | `y` | A city next to the city. | `neighbor` | |
| `city_fix_return_routes` | `index` | A city next to city `i`. | `neighbor` | |
| `city_update_occupier` | `x` (parameter) | The city. | `city` | |
| `navy_bombard_army` | `pct!` | The share of the army lost. | `loss_rate!` | |
| `navy_bombard_army` | `x` | The supply the army loses. | `supply_loss` | |
| `navy_shot_hits` | `pct!` | The ironclad's bonus or penalty to the chance of a hit. | `ironclad_bonus!` | |
| `navy_shot_hits` | `a$` | The letter of the last ship in the fleet. | `ship$` | |
| `railroad_route_count` | `x` | The count of track. The FUNCTION's result. | `routes` | |
| `railroad_route_count` | `y`, `z` | A city next to the city, and a city two roads away. | `neighbor`, `far_city` | |
| `railroad_capacity` | `x` | Two things: a number of cities, then the most the train can carry. | `base_cities`, then `most` | |
| `game_apply_settings` | `a$` | A row of ship letters. | `ships$` | |
| `turn_strength_ratio` | `x`, `y` | The Rebels' and the Union's strength. The letters are the other way round from `victory_forces`. | `rebel_strength`, `union_strength` | |
| `turn_retreat_city` | `flee` | The best city found so far. | `best_city` | |
| `turn_retreat_city` | `x` | A city next to the city. | `neighbor` | |
| `turn_collect_income` | `x` | A city's owner. | `owner` | |
| `turn_set_move_order` | `x` | Set to 1 to 4 by army size, and never read. | Delete | |
| `hall_of_fame_insert` | `i` (parameter) | The place in the Hall of Fame. | `place` | |

#### `ui\`

| SUB | Current | What it holds | Proposed | Your name |
|-----|---------|---------------|----------|-----------|
| `draw_ai_fort` | `target` (parameter) | The city. | `city` | |
| `draw_ai_plan`, `draw_ai_drill` | `i` (parameter) | The army. | `army` | |
| `calculate_battle` | `attack`, `defend` | The two strengths. | `attack_strength`, `defend_strength` | |
| `calculate_battle` | `a` | Two things: the odds in percent, then the winner's side. | `odds_pct`, then `winner_side` | |
| `calculate_battle` | `k` | The defender's fort level, for the picture. | `fort_level` | |
| `calculate_battle` | `t$` | Two things: the fort picture's file name, then a message. | `file$`, then `message$` | |
| `calculate_battle` | `y` | The column of the right panel, 68. | `col` | |
| `special_events` | `who` | The side the event was rolled for (`event_roll`). | `event_side` | |
| `event_riot` | `x` | The city that riots. | `city` | |
| `menu_main_railroad` | `z` | The side's color. | `side_color` | |
| `menu_select` | `row1` | The row that was highlighted before the key. | `previous_row` | |
| `menu_select` | `brx`, `bry` | The box's right and bottom edge. Set and never read. | Delete | |
| `menu_select`, `menu_arrow_key` | `leave` | 1 when the menu is to close. | `done` | |
| `menu_select` | `a$` | The key pressed. | `pressed$` | |
| `menu_arrow_key` | `k$` (parameter) | The key's second byte. | `pressed$` | |
| `menu_select` | `c1$` | An option's first letter. | `initial$` | |
| `menu_select`, `menu_mark_row` | `flag` | 1 when `menu_mark_row` has printed the row itself. | `row_shown` | |
| `menu_mark_row` | `target` | The army in the row's city. | `army` | |
| `menu_mark_row` | `t$` | Two things: the army's name, then the face picture's file name. | `name$`, then `file$` | |
| `menu_mark_row` | `a` | The face picture's number. | `face` | |
| `menu_measure_width` | `x` | An option's length. | `length` | |
| `show_message_box` | `seconds` (parameter) | The box's fill color, not a time. Every caller passes 4 (red). The box waits `PAUSE_LONG`. | `box_color` | |
| `show_message_box` | `x`, `y` | Set and never read. | Delete | |
| `show_message_box` | `g2()` | The screen under the box, put back at the end. | `saved_screen()` | |
| `menu_army_move` | `target` | The army's city, from `menu_army_select`. | `city` | |
| `menu_city_fortify` | `x` | The army in the city. | `army` | |
| `menu_city_select` | `a$` | The letter the player typed. | `letter$` | |
| `menu_city_select` | `x` | How many cities have been tried. | `tries` | |
| `menu_city_select` | `y` | The city it started from. | `start_city` | |
| `menu_army_cancel` | `target` | The city picked. | `city` | |
| `menu_army_cancel` | `x` | Where a space or the picked name is found in an army's name. | `found_at` | |
| `menu_army_cancel` | `turbo` | Always 0. The original's integer `turbo`, not the setting `turbo!` (now `opt_pause!`), so `wait_seconds(turbo + 1)` waits 1 second. | Delete; write `wait_seconds(1)` | |
| `menu_army_relieve` | `target` | Set to 0 and never read. | Delete | |
| `menu_army_relieve` | `t$`, `a$` | The old leader's name and the new one's. | `old_name$`, `new_name$` | |
| `menu_army_retreat` | `x` (parameter) | The city the army retreats to, out. | `retreat_city` | |
| `menu_army_retreat` | `y` | The city the army is in. | `city` | |
| `menu_supply` | `max` | The width of the longest army name. | `name_width` | |
| `menu_railroad` | `index` | The army picked. The SUB already has `army` for its result. | `chosen_army` | |
| `menu_railroad` | `a` | The city from `menu_army_select`. Only tested for 0. | `chosen_city` | |
| `menu_railroad` | `x` | Two things: the army's side (never read), then a count of track. | `routes` | |
| `menu_railroad` | `target`, `from`, `x1` | The city whose track is counted, the city the train leaves, the city it goes to. | `route_city`, `from_city`, `to_city` | |
| `menu_army_detach`, `menu_army_drill` | `target` | The army's city. | `city` | |
| `menu_army_detach` | `empty` | A free army slot. | `slot` | |
| `menu_victory_conditions` | `chosit` | The option the menu starts on next time, as 21 + its row. | `start_option` | |
| `report_armies` | `x`, `y` | Several numbers in turn: the two sides' victory points added up, three percents, the income of both sides with the capitals' bonus. | `total_points`, `percent`, `all_income` (`total_income` is shared) | |
| `report_intelligence` | `z` | The width of an army's box, in columns. | `box_width` | |
| `report_force_summary` | `summ()` | The men in each city. | `city_men()` | |
| `report_recap` | `x` | The lines printed. | `line_count` | |
| `check_map_links` | `x`, `y` | The roads that could not be fixed, and the roads fixed. | `unresolved`, `fixed` | |
| `print_centered` | `y` (parameter), `x` | The row, and the column it starts at. | `row`, `col` | |
| `draw_top_bar` | `x`, `y` | The two sides' victory points added up, and the side's percent of them. | `total_points`, `percent` | |
| `turn_move_army` | `target` | The city the army marches to. | `to_city` | |
| `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats` | `target` (parameter) | The city that is attacked. | `city` | |
| `turn_attack` | `win`, `lose` | The armies that won and lost. | `winner`, `loser` | |
| `turn_defender_retreats` | `s` | The attacker's side, passed to `turn_retreat_city`. | `attacker_side` | |
| `turn_defender_retreats` | `flee` | The city the player picked to retreat to. | `chosen_city` | |
| `turn_defender_retreats` | `move2` | The city the army retreats to. | `retreat_city` | |
| `turn_army_surrenders` | `x` | The army's side. | `side` | |
| `turn_enter_city` | `c` | The city entered. | `city` | |
| `ai_turn` | `who` | The computer's side. | `ai_side` | |
| `hall_of_fame` | `a$` | The commander's name, typed in. | `commander$` | |
| `hall_of_fame`, `end_game` | `j`, `k` | Declared and never used. | Delete | |

## Part 2: `GOTO` and `GOSUB` labels

There are about 90 labels. Many are jokes or abbreviations, and a few mislead. Many do nothing but skip to the
next pass of a loop (`GOTO puter` lands on `puter: NEXT i`) or to the end of a SUB. QB64's `_CONTINUE` and
`EXIT SUB` can replace those, and then the label goes away. Proposals come when this part is reached.

| File | Labels |
|------|--------|
| `ai\ai.bm` | `alle`, `alleval`, `allof`, `capital`, `city2`, `deadman` (two), `endlook`, `isok`, `move9`, `movenavy`, `neutral`, `nocap`, `ourn`, `picked`, `puted`, `puter`, `tally3`, `tally4`, `tally5` |
| `commands\army.bm` | `add2` |
| `commands\navy.bm` | `blast`, `deserted`, `firemore`, `hitem`, `hitme1`, `hurt1`, `raid` |
| `draw\icons.bm` | `already` |
| `draw\map.bm` | `float`, `nextc`, `nocon`, `nosee`, `noshow`, `sink` |
| `draw\ships.bm` | `jack` (`GOSUB`) |
| `game\events.bm` | `abe`, `cotton`, `dull1`, `dull2`, `event2`, `float1`, `mercen`, `money`, `purse`, `uprising` |
| `game\victory_screens.bm` | `lwing`, `relee`, `stars` (`GOSUB`) |
| `rules\army.bm` | `add1s` (`GOSUB`), `alldone`, `foe` |
| `rules\city.bm` | `done`, `holdup`, `ret` |
| `rules\navy.bm` | `found1` |
| `rules\turn.bm` | `horde` |
| `ui\orders.bm` | `aboard`, `alone`, `counter`, `dudd`, `finix`, `fnew`, `have2`, `minus1`, `morecap`, `movopt`, `nocity`, `notarg`, `plus1`, `spin2`, `tent` |
| `ui\reports.bm` | `cheer`, `deadeye`, `what4` |
| `ui\screen.bm` | `notrain`, `notrane` |
| `ui\turn.bm` | `enemy`, `holdon`, `horde`, `outta`, `rip` |
| `ui\victory.bm` | `automate`, `death`, `foun`, `play4ever`, `who4` |
| `rules\victory.bm` | `finis` |

Two to note now:

- **`notrain` and `notrane`** (`draw_train_box`, `ui\screen.bm`) are two labels in one SUB that differ by one
  letter. `notrane` skips one side's train; `notrain` skips the whole box.
- **`game\events.bm` labels name the next test, not what happens.** `GOTO cotton` runs when the loan does
  *not* happen, and `GOTO purse` jumps over the cotton test to pay the loan.

## Part 3: constants that read unclearly

| Constant | What it means | Proposed | Your name |
|----------|---------------|----------|-----------|
| `SHOW_NOT` | `scribe_message` writes to the history only. | `SHOW_HISTORY_ONLY` | |
| `BLAST_FIRM`, `BLAST_LOYAL`, `BLAST_NEUTRAL` | The result of `navy_blast`, an attack on a city with no army and no fort: it stands firm, it is the capital and stays loyal, or it turns neutral. | `BOMBARD_HOLDS`, `BOMBARD_CAPITAL_HOLDS`, `BOMBARD_TURNS_NEUTRAL` | |

## Part 4: found while reading

None of these is fixed by a rename. Items 1 to 3 are names that say the wrong thing, and their rows are in part 1.
Items 4 to 9 look like bugs of the original, kept like the others (decision 3). Fixing one changes how the game
plays, so each would be its own decision and a `TODO.md` row.

1. **`show_message_box (text$, seconds)`**: `seconds` is the box's color. Every caller passes 4.
2. **`draw_surrender (side)`** is passed an army and calls `army_side(side)` on it.
3. **`ai_evaluate_move (army, x)`**: `x` is a weight going in and the chosen road coming out.
4. **`ai_army_order`, the capital check** (`ai\ai.bm` line 148): `k = city_road(target, j): IF j = 0 GOTO
   nocap`. `j` runs from 1, so the test is never true. It most likely meant `k = 0`. As written,
   `city_nearby_enemy_strength(0)` is called for an empty road.
5. **`ai_evaluate_move`, the fort factor** (line 206): `IF city_fort(a) = 3 THEN x1 = 3`. Forts go up to 2
   (`MAX_FORT`), so the factor is never 3.
6. **`ai_army_order`, "eliminate crossing moves"** (line 158): `IF army_order(y) = x`, where `x` is the army's
   size, not a city. It most likely meant the army's city (`target`). As written it matches only by chance,
   so crossing moves are mostly not removed.
7. **`turn_strength_ratio`** uses `y` for the Union and `x` for the Rebels. `victory_forces` and its callers
   use them the other way round. Not a bug, but easy to get wrong. The proposed names remove it.
8. **`event_roll`, the mercenaries**: `index` is never set, so they join army 0. Already in `TODO.md`.
9. **`ai_fortify`, the Union's cash** (`ai\ai.bm` line 35): `IF side = SIDE_UNION AND fleet_size(SIDE_UNION) < 1
   AND RND > .5 AND side_cash < 222 THEN EXIT SUB`. `side_cash` here is the local scalar, always 0, so the test
   is always true. It most likely meant `side_cash(side) < 222`. The original has the same with `cash`.

**Dead locals, deleted on 2026-11-12.** A scan listed every local and parameter that is never read in its SUB.
These eight locals were deleted, with the lines that only set them: `brx` and `bry` (`menu_select`), `x` and
`y` (`show_message_box`), `x` (`turn_set_move_order`, which also lost its empty `CASE ELSE`), `target`
(`menu_army_relieve`), `j` (`hall_of_fame`) and `k` (`end_game`).

Found by the same scan and kept:

- `unused!` in `random_discard`: it is set and never read on purpose, to use up one random number.
- Two parameters that are never used: `side` of `army_combine_done` and `city` of `navy_blast`. Taking them out
  changes their callers too.
- Parameters that are only set: these are the SUBs' results (`ordered`, `again`, `result` and the others).
- `turbo` in `menu_army_cancel` is read but never set, so it is always 0 (part 1b).
- In `cws.bas`, 10 `DECLARE` lines still carry the old parameter names.
