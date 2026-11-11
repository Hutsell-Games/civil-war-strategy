DEFINT A-Z
' $INCLUDE: 'port/folders.bi'
'==========================================================================
' Sides. other_side and army_side (rules/army.bm) work with them.
CONST SIDE_NONE = 0
CONST SIDE_UNION = 1
CONST SIDE_REBEL = 2
' Limits. Army slots 1 to 20 are the Union's, 21 to 40 the Rebels'.
CONST MAX_CITIES = 40
CONST MAX_ARMIES = 40
CONST ARMIES_PER_SIDE = 20
CONST MAX_ROADS = 6
CONST MAX_FLEET_SHIPS = 10
CONST MAX_FORT = 2
CONST MAX_SUPPLY = 10
CONST MAX_EXPERIENCE = 10
CONST MAX_LEADER_RATING = 9
CONST MAX_CASH = 19999
' fleet_city(): the fleet is at sea, raiding commerce.
CONST FLEET_AT_SEA = 99
' city_port_type(): 0 for no port.
CONST PORT_RIVER = 90
CONST PORT_SEA = 99
' army_order(): a city to move to, or one of these.
CONST ORDER_NONE = 0
CONST ORDER_BUSY = -1
CONST ORDER_DONE = -2
' move_order_key(): the army does not move this turn.
CONST MOVE_KEY_NONE = 999
' menu_choice: set to MENU_START + n before menu_select to start on option n; after it, these.
CONST MENU_START = 21
CONST MENU_ESCAPED = -1
CONST MENU_END_TURN_KEY = 99
' The marks of draw_map_marker, its third argument.
CONST MARK_MOVE_LINE = 1
CONST MARK_RECRUIT = 2
CONST MARK_EXPLOSION = 3
CONST MARK_ERASE_ARMY = 4
CONST MARK_ERASE_LINE = 5
CONST MARK_FLASH_FRAME = 6
CONST MARK_BOX = 7
CONST MARK_RESTORE = 8
CONST MARK_POINTER = 9
CONST MARK_ROAD = 11
' The modes of menu_select: what it shows beside the option the player is on.
CONST MENU_PLAIN = 0
CONST MENU_CITY_BOX = 1
CONST MENU_CITY_ARMY = 2
CONST MENU_RAW_KEYS = 3
CONST MENU_ARMY_STATS = 4
CONST MENU_ARMY_POINTER = 6
CONST MENU_FACES = 8
CONST MENU_CITY_POINTER = 9
' menu_box_type: a double line round the menu (0, no line, and 1, a single line, have no caller).
CONST BOX_DOUBLE = 2
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
DIM SHARED city_x(MAX_CITIES), city_y(MAX_CITIES), city_value(MAX_CITIES), city_owner(MAX_CITIES), city_name$(MAX_CITIES), leader_name$(40), turn_recruit_city(5)
DIM SHARED side_cash(2), side_city_count(2), city_road(MAX_CITIES, MAX_ROADS), city_port_type(MAX_CITIES), side_income(2), saved_under_army(300), leader_rating(40)
DIM SHARED menu_text$(21), saved_under_marker(300), side_name$(2), army_city(MAX_ARMIES), army_name$(MAX_ARMIES), victory_rule(6)
DIM SHARED army_size(MAX_ARMIES), army_leader_rating(MAX_ARMIES), army_experience(MAX_ARMIES), army_supply(MAX_ARMIES), month_name$(12)
DIM SHARED army_order(MAX_ARMIES), menu_value(40), flag_star_x(8), flag_star_y(8), pic_mountain(1 TO 1564), train_from_city(2)
DIM SHARED fleet_city(2), fleet_size(2), navymove(2), city_army(MAX_CITIES), city_fort(MAX_CITIES), train_army(2)
DIM SHARED side_victory_points(2), side_capital(2), emancipation_done, train_city(2), fleet_ships$(2)
DIM SHARED train_capacity(2), map_font$(26), move_order_key(MAX_ARMIES), side_casualties&(2), side_battles_won(2), city_first_owner(MAX_CITIES)
' The pictures' arrays: graphic and Ncap were declared in CWSTRAT.BAS, graft in CWSMENU.BAS.
DIM SHARED pic_loaded(1 TO 1564), pic_capital(60)
DIM SHARED pic_face(1 TO 1564)
' Set by scriptstart (SCRIPT.BM) when tests\play.py runs the program.
DIM SHARED scripted
