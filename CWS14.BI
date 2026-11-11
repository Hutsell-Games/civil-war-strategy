DEFINT A-Z
' $INCLUDE: 'port/folders.bi'
'==========================================================================
COMMON SHARED menu_choice%, menu_col%, menu_row%, menu_item_count%, menu_text$(), menu_box_type%, menu_color%, menu_highlight%
COMMON SHARED city_x(), city_y(), city_value(), city_owner(), city_name$(), leader_name$(), saves_exist
COMMON SHARED side_cash(), side_city_count(), city_road(), city_port_type(), side_income(), saved_under_army(), leader_rating(), turn_recruit_state
COMMON SHARED turn_navy_done, opt_ai_aggression, opt_pause!, train_army(), flag_star_x(), flag_star_y(), pic_mountain(), train_from_city()
COMMON SHARED saved_under_marker(), side_name$(), army_city(), army_name$(), opt_players, ai_strength_ratio!
COMMON SHARED army_size(), army_leader_rating(), army_experience(), army_supply(), month_name$()
COMMON SHARED turn_recruit_city(), victory_rule(), train_city(), side_battles_won(), city_first_owner()
COMMON SHARED army_order(), turn_month, turn_year, menu_value(), turn_moves_done, current_side, rule_attack_loss, rule_defend_loss, rule_strength_cap
COMMON SHARED fleet_city(), fleet_size(), navymove(), city_army(), total_income, city_fort()
COMMON SHARED side_victory_points(), opt_graphics, opt_sound, side_capital(), opt_difficulty, union_income_bonus, opt_alt_colors
COMMON SHARED train_capacity(), map_font$(), move_order_key(), opt_winter_campaigns, opt_event_balance, opt_realism, side_casualties&()
COMMON SHARED game_over, opt_history, victory_reason, fleet_ships$(), raiding_side, raid_loss, fleet_pursuit
'==========================================================================
DIM SHARED city_x(40), city_y(40), city_value(40), city_owner(40), city_name$(40), leader_name$(40), turn_recruit_city(5)
DIM SHARED side_cash(2), side_city_count(2), city_road(40, 6), city_port_type(40), side_income(2), saved_under_army(300), leader_rating(40)
DIM SHARED menu_text$(21), saved_under_marker(300), side_name$(2), army_city(40), army_name$(40), victory_rule(6)
DIM SHARED army_size(40), army_leader_rating(40), army_experience(40), army_supply(40), month_name$(12)
DIM SHARED army_order(40), menu_value(40), flag_star_x(8), flag_star_y(8), pic_mountain(1 TO 1564), train_from_city(2)
DIM SHARED fleet_city(2), fleet_size(2), navymove(2), city_army(40), city_fort(40), train_army(2)
DIM SHARED side_victory_points(2), side_capital(2), emancipation_done, train_city(2), fleet_ships$(2)
DIM SHARED train_capacity(2), map_font$(26), move_order_key(40), side_casualties&(2), side_battles_won(2), city_first_owner(40)
' The pictures' arrays: graphic and Ncap were declared in CWSTRAT.BAS, graft in CWSMENU.BAS.
DIM SHARED pic_loaded(1 TO 1564), pic_capital(60)
DIM SHARED pic_face(1 TO 1564)
' Set by scriptstart (SCRIPT.BM) when tests\play.py runs the program.
DIM SHARED scripted
