# Where each SUB goes (phase 6)

Phase 6 of `modernize-plan.md` moves every SUB whole into the file below. No line inside a SUB changes. This is
the draft for the user to check before anything moves. Names are the settled names.

"Mixed" means the SUB both works out a rule and draws, prints or reads a key. It goes to the file of its topic
now and is split in phase 8. Since phase 8 the folder rule holds: nothing in `rules\` or `ai\` draws.
The last two marked, `load_game` and `save_game` in `port\`, lost their menus in phase 9.

The main program (`CWSTRAT.BAS`, with its `GOSUB` routines) became `cws.bas` in phase 9. `CWS14.BI` became `cws.bi`.
`QB64.BM` and `SCRIPT.BM` move to `port\`. `FOLDERS.BI` moves to `port\` too.

## rules\

| File | SUBs |
|------|------|
| `army.bm` | `army_list_combine_cities`, `army_set_order`, `army_free_leader`, `army_take_leader` (new in phase 9), `army_combine_start`, `army_combine_add`, `army_combine_absorb`, `army_combine_finish`, `army_raise`, `army_pick_commander`, `army_buy_supply`, `army_add_recruits`, `army_recruit_cities`, `army_detach`, `army_drill`, `army_recruit_bonus`, `army_generate_name`, `side_first_army`, `side_last_army`, `sort_move_order`, `army_side`, `other_side`, `recruit_troops`, `recruits_cut_off` (new after the plan), `army_exists`, `army_has_move`, `army_has_acted` (new 2026-11-13, `structure-review.md` item 2), `army_clear` (new 2026-11-13: the six fields that five SUBs cleared) (`army_combine`, `army_new`, `army_get_commander`, `army_resupply` and `army_recruit` until phase 8 moved them to `ui\army.bm`) |
| `city.bm` | `city_build_fort`, `capital_move_pay`, `capital_move_to` (new in phase 9), `city_take`, `city_is_connected`, `city_fix_return_routes`, `city_update_occupier`, `city_list_sort` (new 2026-11-13, `structure-review.md` item 4) (`city_capture` and `check_map_links` until phase 8 moved them to `ui\city.bm`) |
| `battle.bm` | `battle_strengths`, `battle_fight`, `battle_size_rate!` (new 2026-11-13), `battle_losses`, `battle_apply_losses`, `normal_random_number` (`calculate_battle` until phase 8 split it) |
| `navy.bm` | `fleet_exists`, `fleet_is_at_sea` (new 2026-11-13, `structure-review.md` item 2), `navy_mark_side`, `navy_count_ships`, `navy_has_ironclads`, `navy_list_shipyards`, `navy_list_ports`, `navy_can_invade` (new 2026-11-13, item 4), `random_discard` (new in phase 9), `navy_remove_ship`, `navy_add_ship`, `navy_found_fleet`, `navy_cancel_new_fleet`, `navy_bombard_army`, `navy_shore_battery`, `navy_fleet_lost`, `navy_blast`, `navy_move_fleet`, `navy_go_raiding`, `navy_landed`, `navy_note_raiding_side`, `navy_raid_round`, `navy_ship_hits`, `navy_shot_hits`, `navy_fleet_defeated`, `navy_retreat_port` (the rest until phase 8 moved them to `ui\navy.bm`) |
| `railroad.bm` | `railroad_board`, `railroad_unload`, `railroad_route_count`, `railroad_capacity` (`railroad_move`, `railroad_start` and `railroad_arrive` until phase 8 moved them to `ui\railroad.bm`) |
| `turn.bm` | `turn_set_moves_done`, `turn_set_navy_done`, `turn_reset_commands`, `turn_check_commands`, `turn_close_recruiting`, `turn_next_player` (new in phase 9), `turn_advance_month`, `turn_army_supply`, `turn_strength_ratio`, `turn_army_marches`, `turn_battle_experience`, `turn_withdraw`, `turn_defender_halts`, `turn_retreat_city`, `turn_retreat_to`, `turn_army_lost`, `turn_occupy`, `turn_raze_fort`, `turn_army_forages`, `turn_collect_income`, `turn_set_move_order`, `turn_update_victory_points` (the eight others until phase 8 moved them to `ui\turn.bm`) |
| `setup.bm` | `set_union_advantage`, `vary_start_conditions` (new in phase 7); the Utility menu's settings (new in phase 9): `option_swap_side`, `option_toggle_players`, `option_next_graphics`, `option_set_sound`, `option_set_display_speed`, `option_toggle_alt_colors`, `option_set_balance`, `option_set_event_balance`, `option_toggle_winter_campaigns`, `option_toggle_realism`, `option_toggle_history`, `option_next_aggression`, `option_events_favor_computer` (new after the plan); the start of a game (new in phase 9, out of the main module): `game_new`, `game_reset`, `game_apply_settings` |
| `victory.bm` | `victory_toggle_rule` (new in phase 9), `victory_forces`, `victory_time_near`, `victory_rule_met`, `victory_near_cities`, `victory_near_income`, `victory_near_force`, `victory_play_on`, `victory_won`, `victory_technical_points`, `hall_of_fame_place`, `hall_of_fame_insert` (`check_victory_conditions`, `victory_warnings`, `end_game` and `hall_of_fame` until phase 8 moved them to `ui\victory.bm`) |
| `events.bm` | `event_roll`, `event_pick`, `event_target`, `event_chance!`, `event_conditions_hold`, `event_possible`, `event_delivery_port`, `event_apply`, `event_riot_city`, `event_find` (in `game\` until phase 11 made the events data: `scenarios\EVENTS.DAT`) |

## ai\

| File | SUBs |
|------|------|
| `ai.bm` | `ai_combine`, `ai_razes_fort`, `ai_railroad_orders`, `ai_navy_orders`, `ai_navy_build`, `ai_navy_attack`, `ai_navy_sail`, `ai_navy_raid`, `ai_navy_invade` (new in phase 9: the computer's half of the navy's commands), `ai_resupply`, `ai_fortify`, `ai_fortify_pick`, `ai_raise_forces`, `ai_count_armies`, `ai_fleet_orders`, `ai_army_orders`, `ai_army_order`, `ai_drill`, `ai_recruit`, `ai_recruit_pick`, `ai_railroad`, `ai_pick_port`, `ai_navy`, `ai_navy_adjust`, `ai_evaluate_move`, `city_nearby_enemy_strength` (`ai_turn` until phase 8 moved it to `ui\turn.bm`) |

## commands\

The orders that the player's menus and the computer both give (new in phase 9). A command calls rules
and shows what happened. Nothing here opens a menu or reads a key.

| File | SUBs |
|------|------|
| `army.bm` | `army_combine_gather`, `army_combine_done`, `army_combine_redraw`, `army_new`, `army_get_commander`, `army_resupply`, `army_recruit` (from `ui\army.bm`; `army_combine` until phase 9 split it) |
| `city.bm` | `city_capture` (from `ui\city.bm`) |
| `railroad.bm` | `railroad_finish`, `railroad_start`, `railroad_arrive` (from `ui\railroad.bm`; `railroad_move` until phase 9 split it) |
| `navy.bm` | `navy_ship_joins`, `navy_fleet_founded`, `navy_bombard`, `navy_say_no_ships`, `navy_sail_to`, `navy_start_raid`, `navy_land_army`, `navy_finish_move`, `navy_redraw_map`, `navy_commerce_raid`, `navy_combat_begin`, `navy_combat_draw`, `navy_combat_volley`, `navy_combat_retreat`, `navy_combat_auto`, `navy_show_hits` (from `ui\navy.bm`) |

## ui\

| File | SUBs |
|------|------|
| `menu.bm` | `menu_select`, `menu_arrow_key` (new in phase 9), `menu_mark_row`, `menu_unmark_row`, `menu_measure_width`, `menu_bubble_sort`, `menu_set_cities` (new 2026-11-13), `draw_menu` |
| `main_menu.bm` | `menu_main`, `menu_main_railroad`, `menu_main_end_turn`, `menu_main_inform`, `show_title`, `menu_title`, `show_new_game` (new in phase 9: the main menu and the title, out of the main module) |
| `orders.bm` | `menu_commands`, `menu_army_detach`, `menu_army_drill` (new in phase 9: the Commands menu, out of the main module), `menu_army_move`, `menu_army_select`, `menu_army_recruit`, `menu_army_relieve`, `menu_army_retreat`, `menu_army_cancel`, `menu_city_select`, `menu_city_fortify`, `menu_supply`, `menu_move_capital`, `menu_recruit_cities`, `menu_railroad`, `menu_navy`, `menu_navy_items`, `draw_fort_built` (`draw_ai_fort` of `ui\ai.bm` until after the plan), `draw_recruit_funds` (new after the plan) |
| `options.bm` | `menu_utility`, `menu_option_side`, `menu_option_players`, `menu_option_graphics`, `menu_option_sound`, `menu_option_display`, `menu_option_balance`, `menu_option_events`, `menu_option_january`, `menu_option_realism`, `menu_option_history`, `menu_option_aggression` (new in phase 9: the Utility menu, out of the main module) |
| `files.bm` | `menu_files`, `menu_load_game`, `menu_save_game`, `menu_quit` (new in phase 9: the Files menu, out of the main module and `port\files.bm`) |
| `reports.bm` | `menu_report`, `menu_victory_conditions`, `draw_army_stats`, `print_army_size`, `check_map_links` (from `ui\city.bm` in phase 9) |
| `screen.bm` | `clear_bottom_line`, `clear_right_panel`, `screen_snapshot`, `wait_seconds`, `print_centered`, `draw_top_bar`, `draw_train_box`, `draw_player_turn`, `draw_update_box` |
| `messages.bm` | `show_message_box`, `scribe_message` |
| `battle.bm` | `calculate_battle` (new in phase 8: the battle's screen) |
| `army.bm` | `menu_army_combine`, `menu_raze_fort` (new in phase 9: the player's Join and Raze menus; the file of phase 8 moved to `commands\army.bm`) |
| `navy.bm` | `menu_navy_commands`, `menu_navy_build`, `menu_navy_attack`, `menu_navy_sail`, `menu_navy_raid`, `menu_navy_invade`, `menu_navy_combat` (new in phase 9: the player's half of the navy's commands; the file of phase 8 moved to `commands\navy.bm`) |
| `turn.bm` | `turn_date_and_supply`, `turn_resolve`, `turn_move_army`, `turn_attack`, `turn_attacker_withdraws`, `turn_defender_retreats`, `turn_army_surrenders`, `turn_enter_city`, `ai_turn` (new in phase 8: the month's moves) |
| `ai.bm` | `draw_ai_plan`, `draw_ai_drill`, `draw_ai_funds`, `draw_ai_navy_color` (new in phase 8: the computer's messages), `draw_ai_recruit_color` (new 2026-11-13) |
| `events.bm` | `special_events`, `event_show_city` (`event_riot` until phase 11), `event_message$`, `text_replace` (new in phase 8: the special events' messages and tunes) |
| `victory.bm` | `check_victory_conditions`, `victory_warnings`, `end_game`, `hall_of_fame` (new in phase 8: the warnings, the victory screens and the Hall of Fame) |

## draw\

| File | SUBs |
|------|------|
| `map.bm` | `draw_map`, `draw_map_touchup`, `draw_cities`, `draw_city_names`, `draw_map_marker`, `draw_stack_markers`, `draw_fleets` |
| `icons.bm` | `draw_flag_icon`, `draw_large_flag`, `draw_army_flag`, `draw_train`, `animate_army`, `animate_city` |
| `ships.bm` | `draw_fleet_ship`, `draw_ship_icon`, `draw_ironclad`, `draw_schooner`, `draw_fleet_sailing`, `draw_navy_box`, `draw_ship_sunk` |
| `pictures.bm` | `draw_cannon`, `draw_chesapeake`, `draw_title` |

## game\ (what another war replaces)

| File | SUBs |
|------|------|
| `victory_screens.bm` | `draw_union_victory`, `draw_rebel_victory`, `draw_surrender` |
| `tunes.bm` | `play_shenandoah`, `play_title_music` |
| `colors.bm` | `side_color_of`, `city_dot_color` (new after the plan: the sides' colors, once written out in 11 places) |

## port\

| File | SUBs |
|------|------|
| `files.bm` | `hall_of_fame_load`, `hall_of_fame_save`, `load_scenario`, `load_scenario_armies` (new 2026-11-13: one side's armies, once written twice), `load_events` (with `event_clear_row`, `event_read_line`, `event_read_side`, `event_read_conditions`, `event_read_effect`, `event_read_chance`, `text_is_number`, `text_last_space`), `load_cities`, `load_game`, `save_game`, `saved_games_check`, `any_saved_game`, `save_file_name$` (new 2026-11-13), `history_start`, `config_read`, `config_write`, `save_battle_summary` (`file_management` until phase 7 split it; the menus of `load_game` and `save_game` until phase 9 moved them to `ui\files.bm`) |
| `script.bm` | `script_start`, `script_date$`, `script_tick%`, `script_shell`, `script_mark_key_wait` (from `SCRIPT.BM`) |

## Questions for the user

1. `file_management` is saved-game work, not a port of QB64. `port\files.bm` is my pick. Phase 7 splits it
   into the file work and the screen work; the file part could then go to `rules\save.bm`.
2. `draw_cannon` and `draw_chesapeake` are Civil War pictures. They could go to `game\` with the victory
   screens. I put them in `draw\pictures.bm` because the plan names that file; say if you prefer `game\`.
3. `draw_ironclad` and `draw_schooner` are the same: ship pictures of this war, kept in `draw\ships.bm`.
4. 80 SUBs and FUNCTIONs, 11 of them marked mixed. The count per file runs from 1 to 8.
