# Where each SUB goes (phase 6)

Phase 6 of `modernize-plan.md` moves every SUB whole into the file below. No line inside a SUB changes. This is
the draft for the user to check before anything moves. Names are the settled names.

"Mixed" means the SUB both works out a rule and draws, prints or reads a key. It goes to the file of its topic
now and is split in phase 7, so for now `rules\` and `ai\` hold a few SUBs that still draw. The folder rule
(nothing there draws) holds once phase 7 is done.

The main program (`CWSTRAT.BAS`, with its `GOSUB` routines) becomes `cws.bas`. `CWS14.BI` becomes `cws.bi`.
`QB64.BM` and `SCRIPT.BM` move to `port\`. `FOLDERS.BI` moves to `port\` too.

## rules\

| File | SUBs |
|------|------|
| `army.bm` | `army_combine`, `army_detach`, `army_drill`, `army_recruit` (mixed), `army_recruit_bonus`, `army_new`, `army_resupply`, `army_get_commander`, `army_generate_name`, `side_first_army`, `side_last_army`, `sort_move_order`, `army_side`, `other_side` |
| `city.bm` | `city_capture` (mixed), `city_is_connected`, `city_update_occupier`, `check_map_links` |
| `battle.bm` | `calculate_battle` (mixed), `normal_random_number` |
| `navy.bm` | `navy_remove_ship`, `navy_commands`, `navy_action`, `navy_build_ship` (mixed), `navy_bombard` (mixed), `navy_sail_to_port` (mixed), `navy_raid_commerce` (mixed), `navy_land_army`, `navy_finish_move` (mixed), `navy_commerce_raid` (mixed), `navy_combat` (mixed), `navy_show_hits` (mixed) |
| `railroad.bm` | `railroad_move` (mixed), `railroad_start` (mixed), `railroad_arrive` (mixed), `railroad_route_count`, `railroad_capacity` |
| `turn.bm` | `turn_date_and_supply` (mixed), `turn_resolve` (mixed), `turn_collect_income`, `turn_set_move_order`, `turn_update_victory_points` |
| `setup.bm` | `set_union_advantage`, `vary_start_conditions` (new in phase 7) |
| `victory.bm` | `check_victory_conditions` (mixed), `victory_warnings` (mixed), `end_game` (mixed), `hall_of_fame` (mixed) |

## ai\

| File | SUBs |
|------|------|
| `ai.bm` | `ai_turn` (mixed), `ai_resupply`, `ai_fortify` (mixed), `ai_raise_forces`, `ai_count_armies`, `ai_fleet_orders`, `ai_army_orders` (mixed), `ai_drill` (mixed), `ai_recruit`, `ai_recruit_pick`, `ai_railroad`, `ai_pick_port`, `ai_navy`, `ai_navy_adjust`, `ai_evaluate_move`, `city_nearby_enemy_strength` |

## ui\

| File | SUBs |
|------|------|
| `menu.bm` | `menu_select`, `menu_measure_width`, `menu_bubble_sort`, `draw_menu` |
| `orders.bm` | `menu_army_move`, `menu_army_select`, `menu_army_recruit`, `menu_army_relieve`, `menu_army_retreat`, `menu_army_cancel`, `menu_city_select`, `menu_city_fortify`, `menu_supply`, `menu_move_capital`, `menu_recruit_cities`, `menu_railroad`, `menu_navy`, `menu_navy_items` |
| `reports.bm` | `menu_report`, `menu_victory_conditions`, `draw_army_stats`, `print_army_size` |
| `screen.bm` | `clear_bottom_line`, `clear_right_panel`, `screen_snapshot`, `wait_seconds`, `print_centered`, `draw_top_bar`, `draw_train_box`, `draw_player_turn`, `draw_update_box` |
| `messages.bm` | `show_message_box`, `scribe_message` |

## draw\

| File | SUBs |
|------|------|
| `map.bm` | `draw_map`, `draw_map_touchup`, `draw_cities`, `draw_city_names`, `draw_map_marker`, `draw_stack_markers`, `draw_fleets` |
| `icons.bm` | `draw_flag_icon`, `draw_flag`, `draw_army_flag`, `draw_train`, `animate_army`, `animate_city` |
| `ships.bm` | `draw_fleet_ship`, `draw_ship_icon`, `draw_ironclad`, `draw_schooner`, `draw_fleet_sailing`, `draw_navy_box`, `draw_ship_sunk` |
| `pictures.bm` | `draw_cannon`, `draw_chesapeake`, `draw_title` |

## game\ (what another war replaces)

| File | SUBs |
|------|------|
| `victory_screens.bm` | `draw_union_victory`, `draw_rebel_victory`, `draw_surrender` |
| `tunes.bm` | `play_shenandoah`, `play_title_music` |
| `events.bm` | `special_events` (mixed), `event_riot` (mixed) |

## port\

| File | SUBs |
|------|------|
| `files.bm` | `hall_of_fame_load`, `hall_of_fame_save`, `load_scenario`, `load_cities`, `load_game` (mixed), `save_game` (mixed), `config_read`, `config_write` (`file_management` until phase 7 split it) |
| `qb64.bm` | `DIR$` (from `QB64.BM`) |
| `script.bm` | `script_start`, `script_date$`, `script_tick%`, `script_shell`, `script_mark_key_wait` (from `SCRIPT.BM`) |

## Questions for the user

1. `file_management` is saved-game work, not a port of QB64. `port\files.bm` is my pick. Phase 7 splits it
   into the file work and the screen work; the file part could then go to `rules\save.bm`.
2. `draw_cannon` and `draw_chesapeake` are Civil War pictures. They could go to `game\` with the victory
   screens. I put them in `draw\pictures.bm` because the plan names that file; say if you prefer `game\`.
3. `draw_ironclad` and `draw_schooner` are the same: ship pictures of this war, kept in `draw\ships.bm`.
4. 80 SUBs and FUNCTIONs, 11 of them marked mixed. The count per file runs from 1 to 8.
