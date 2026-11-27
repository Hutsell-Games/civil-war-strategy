DEFINT A-Z
' $INCLUDE: 'io/folders.bi'
'==========================================================================
' Sides. other_side and army_side (rules/army.bm) work with them.
CONST SIDE_NONE = 0
CONST SIDE_UNION = 1
CONST SIDE_REBEL = 2
' A yes or no. TRUE is -1, as a comparison gives, so that NOT turns one into the other. Every
' flag and every FUNCTION that answers yes or no holds one of the two.
CONST FALSE = 0
CONST TRUE = -1
' Limits. Army slots 1 to 20 are the Union's, 21 to 40 the Rebels'.
CONST MAX_CITIES = 40
CONST MAX_ARMIES = 40
CONST ARMIES_PER_SIDE = 20
CONST MAX_LEADERS = 40
CONST MAX_ROADS = 6
CONST MAX_FLEET_SHIPS = 10
CONST MAX_FORT = 2
CONST MAX_SUPPLY = 10
' The cash that a day of supplies for 100 troops costs (army_buy_supply and army_supply_days,
' rules/army.bm).
CONST SUPPLY_PRICE = .1#
CONST MAX_EXPERIENCE = 10
CONST MAX_LEADER_RATING = 9
CONST MAX_CASH = 19999
CONST MAX_SCENARIOS = 9
' fleet_city(): the fleet is at sea, raiding commerce.
CONST FLEET_AT_SEA = 99
' fleet_ships$(): a letter for each ship of the fleet.
CONST SHIP_WOODEN$ = "W"
CONST SHIP_IRONCLAD$ = "I"
' city_port_type(): 0 for no port.
CONST PORT_RIVER = 90
CONST PORT_SEA = 99
' army_order(): a city to move to, or one of these.
CONST ORDER_NONE = 0
CONST ORDER_BUSY = -1
CONST ORDER_DONE = -2
' turn_recruit_count: how many cities the player's Troops list holds this month (turn_recruit_city()),
' 0 before the list is drawn, or this when Troops is closed for the month.
CONST RECRUIT_CLOSED = -1
' move_order_key(): the army does not move this turn.
CONST MOVE_KEY_NONE = 999
' The most rows a menu holds (menu_text$() and menu_value()). A row past them is not added.
CONST MENU_MAX_ROWS = 21
' menu_choice after menu_select: the row chosen, or one of these. F7 ends the turn at the main
' menu only.
CONST MENU_ESCAPED = -1
CONST MENU_END_TURN_KEY = 99
' The rows of the title menu (menu_title) and of the main menu (menu_main).
CONST TITLE_RESUME = 1
CONST TITLE_NEW_GAME = 2
CONST TITLE_QUIT = 3
CONST MAIN_TROOPS = 1
CONST MAIN_MOVES = 2
CONST MAIN_SHIPS = 3
CONST MAIN_RAILROAD = 4
CONST MAIN_END_TURN = 5
CONST MAIN_INFORM = 6
CONST MAIN_COMMANDS = 7
CONST MAIN_UTILITY = 8
CONST MAIN_FILES = 9
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
' What menu_army_select picks an army for: any army with no order, or one that Army Drill can
' improve (army_can_drill), or one that Detach can split (army_can_detach).
CONST PICK_ANY = 0
CONST PICK_DRILL = 1
CONST PICK_DETACH = 2
' The modes of menu_select: what it shows beside the option the player is on.
CONST MENU_PLAIN = 0
CONST MENU_CITY_BOX = 1
CONST MENU_CITY_ARMY = 2
CONST MENU_RAW_KEYS = 3
CONST MENU_ARMY_STATS = 4
CONST MENU_ARMY_POINTER = 6
CONST MENU_FACES = 8
CONST MENU_CITY_POINTER = 9
CONST MENU_MAIN_KEYS = 10
' A plain menu without F3 and F4, which draw the map: the Utility menu, and the menus with no
' map under them (the title, the scenarios and the naval fight).
CONST MENU_NO_KEYS = -1
' menu_box_type: a double line round the menu (0, no line, and 1, a single line, have no caller).
CONST BOX_DOUBLE = 2
' The computer's order for its fleet (ai_navy_carry_out): the rows of the Ships menu.
CONST NAVY_BUILD = 1
CONST NAVY_ATTACK = 2
CONST NAVY_SAIL = 3
CONST NAVY_RAID = 4
CONST NAVY_INVADE = 5
' scribe_message's display: write to the history only, or also on the bottom line, or in a box.
CONST SHOW_HISTORY_ONLY = 0
CONST SHOW_LINE = 1
CONST SHOW_BOX = 2
' draw_train's show, and screen_snapshot's put_back.
CONST DRAW_ERASE = 0
CONST DRAW_SHOW = 1
CONST SNAP_SAVE = 0
CONST SNAP_RESTORE = 1
' animate_army's flag: take the picture of the army from its city first, or use the one taken already.
CONST ANIMATE_TAKE_PICTURE = 0
CONST ANIMATE_PICTURE_TAKEN = 1
' army_combine_add's status: the army does not join, would make army 0 too large, or joins.
CONST COMBINE_SKIPPED = 0
CONST COMBINE_TOO_LARGE = 1
CONST COMBINE_JOINED = 2
' army_buy_supply's result: the army is cut off, the cash is not enough, or supplies were bought.
CONST SUPPLY_CUT_OFF = -1
CONST SUPPLY_NO_CASH = 0
CONST SUPPLY_BOUGHT = 1
' navy_blast's result: the city stands firm, is the enemy's capital and stays loyal, or turns neutral.
CONST BOMBARD_HOLDS = 0
CONST BOMBARD_CAPITAL_HOLDS = 1
CONST BOMBARD_TURNS_NEUTRAL = 2
' menu_files' action: what the main module does after the Files menu.
CONST FILES_BACK = 0
CONST FILES_NEW_GAME = 1
CONST FILES_QUIT = 2
' event_roll's event: a row of the events table (1 to event_count), or this.
CONST EVENT_NONE = 0
' The events table, read from scenarios/EVENTS.DAT (load_events, io/events_file.bm).
CONST MAX_EVENTS = 40
CONST MAX_EVENT_TEXTS = 4
CONST MAX_EVENT_CONDITIONS = 120
CONST MAX_CHANCE_FACTORS = 6
' chance_kind(): a factor of the month's chance of an event (event_chance!, rules/events.bm).
CONST CHANCE_NUMBER = 1
CONST CHANCE_WEIGHT = 2
CONST CHANCE_YEAR = 3
CONST CHANCE_DIFFICULTY = 4
' event_effect(): what an event does (event_apply, rules/events.bm).
CONST EFFECT_NONE = 0
CONST EFFECT_POINTS = 1
CONST EFFECT_ENEMY_POINTS_TIMES = 2
CONST EFFECT_CASH = 3
CONST EFFECT_SHIPS = 4
CONST EFFECT_SHIPS_TO_PORT = 5
CONST EFFECT_REINFORCE = 6
CONST EFFECT_ARMIES_GROW = 7
CONST EFFECT_ENEMY_ARMIES_TIMES = 8
CONST EFFECT_EXPERIENCE = 9
CONST EFFECT_CITY_NEUTRAL = 10
' condition_subject(): what a condition of an event tests.
CONST SUBJECT_ROLL = 1
CONST SUBJECT_YEAR = 2
CONST SUBJECT_MONTH = 3
CONST SUBJECT_CITIES = 4
CONST SUBJECT_ONCE = 5
CONST SUBJECT_REALISM = 6
' condition_relation(): how the subject is compared with condition_value!().
CONST RELATION_IS = 1
CONST RELATION_ABOVE = 2
CONST RELATION_BELOW = 3
CONST RELATION_AT_LEAST = 4
CONST RELATION_AT_MOST = 5
' event_redraw(): what is drawn again after an event's message.
CONST REDRAW_NONE = 0
CONST REDRAW_FLEETS = 1
CONST REDRAW_MAP = 2
' Settings: opt_graphics, opt_sound, opt_realism, opt_history, opt_players.
CONST GRAPHICS_OFF = 0
CONST GRAPHICS_BASIC = 1
CONST GRAPHICS_NAMES = 2
CONST GRAPHICS_FULL = 3
CONST SOUND_OFF = 0
CONST SOUND_EFFECTS = 1
CONST SOUND_MUSIC = 2
CONST REALISM_OFF = 0
CONST REALISM_ON = 1
CONST HISTORY_OFF = 0
CONST HISTORY_ON = 1
CONST PLAYERS_ONE = 1
CONST PLAYERS_TWO = 2
' opt_difficulty runs from 1 to 5; at 3 neither side gets help.
CONST DIFFICULTY_LOWEST = 1
CONST DIFFICULTY_EVEN = 3
CONST DIFFICULTY_HIGHEST = 5
' opt_pause!: the seconds of the Display menu's speeds Fast, Normal, Slow and Very Slow, its
' first DISPLAY_SPEED_ROWS rows (display_speed_of_row!).
CONST SPEED_FAST = 1
CONST SPEED_NORMAL = 2
CONST SPEED_SLOW = 3
CONST SPEED_VERY_SLOW = 8
CONST DISPLAY_SPEED_ROWS = 4
' opt_event_balance: the Rndom Evt menu's off, favor the Union, neutral and favor the Rebels,
' its EVENT_BALANCE_ROWS rows (event_balance_of_row).
CONST EVENTS_OFF = 0
CONST EVENTS_FAVOR_UNION = 3
CONST EVENTS_NEUTRAL = 5
CONST EVENTS_FAVOR_REBELS = 7
CONST EVENT_BALANCE_ROWS = 4
' opt_ai_aggression runs from AGGRESSION_LOWEST to AGGRESSION_HIGHEST.
CONST AGGRESSION_LOWEST = 0
CONST AGGRESSION_HIGHEST = 5
' CWS.CFG holds CONFIG_FIELDS fields, in config_write's order. The battle totals of all games
' are four of them from CONFIG_TOTALS_FIELD on: the battles won by the Union and the Rebels,
' then their losses.
CONST CONFIG_FIELDS = 17
CONST CONFIG_TOTALS_FIELD = 12
' The rules of victory_rule(): when the time runs out, and the cities, income, capital and force ratio
' that win. A rule that is off is 0 or negative.
CONST VICTORY_MONTH = 1
CONST VICTORY_YEAR = 2
CONST VICTORY_CITIES = 3
CONST VICTORY_INCOME = 4
CONST VICTORY_CAPITAL = 5
CONST VICTORY_FORCE_RATIO = 6
' victory_rule_met's rule is one of the rules above, or this: the enemy has no troops left.
CONST VICTORY_WIPED_OUT = 7
' The Civil War's own rule numbers. Phase 11 moves them to game\. The costs and the capital's
' income are tuning knobs now: see the knobs at the end of this file.
CONST FIRST_YEAR = 1861
' The ironclads' date. The announcement [ironclads] of scenarios/EVENTS.DAT names it too
' (TestEventIroncladsMatchTheRule checks that the two agree).
CONST IRONCLAD_YEAR = 1862
CONST IRONCLAD_MONTH = 3
' army_size is in hundreds of troops. The largest army, the small army that fights at reduced
' strength, the detach size and the supply level are knobs too (max_army_size and the others).
CONST MONTHS_PER_TURN = 2
CONST MONTHS_PER_YEAR = 12
' Cities that a rule names, by their number in both scenarios' CITIES.GRD.
' Vary Start puts a Rebel fleet at New Orleans, and may move the Rebel capital to Montgomery.
CONST VARY_REBEL_FLEET_CITY = 27
CONST VARY_REBEL_CAPITAL = 25
' The Union computer builds its first fleet at Philadelphia (ai_fleet_orders). A Rebel fleet
' there holds its place half the time (ai_pick_port).
CONST AI_UNION_FLEET_CITY = 30
CONST AI_REBEL_HOLD_CITY = 30
' Named colors for COLOR statements and the menu's colors. The pictures keep their numbers.
CONST COLOR_BLACK = 0
CONST COLOR_BLUE = 1
CONST COLOR_CYAN = 3
CONST COLOR_RED = 4
CONST COLOR_MAGENTA = 5
CONST COLOR_BROWN = 6
CONST COLOR_GRAY = 7
CONST COLOR_DARK_GRAY = 8
CONST COLOR_LIGHT_BLUE = 9
CONST COLOR_LIGHT_GREEN = 10
CONST COLOR_LIGHT_CYAN = 11
CONST COLOR_LIGHT_RED = 12
CONST COLOR_LIGHT_MAGENTA = 13
CONST COLOR_YELLOW = 14
CONST COLOR_WHITE = 15
' Keys: ASC of INKEY$, and the second byte of a key that starts with CHR$(0).
CONST KEY_ENTER = 13
CONST KEY_ESC = 27
CONST KEY_UP$ = "H"
CONST KEY_DOWN$ = "P"
CONST KEY_PAGE_UP$ = "I"
CONST KEY_PAGE_DOWN$ = "Q"
CONST KEY_F3$ = "="
CONST KEY_F4$ = ">"
CONST KEY_F7$ = "A"
' A long pause that a key ends (wait_seconds). A pause of 99 means "press a key"; see io/script.bm.
CONST PAUSE_LONG = 9
' The column of the right panel, where most menus go.
CONST PANEL_COL = 67
' The map's right edge in pixels. The right panel starts after it.
CONST MAP_RIGHT = 527
' The train's outline for DRAW. Each picture adds its own color, scale and last strokes.
CONST TRAIN_OUTLINE$ = "R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3"
' The sizes of the GET buffers. saved_under_army() holds the 19-by-14 area under a city's flag
' (draw/icons.bm), saved_under_marker() a marker's area of at most 21 by 21 (ui/screen.bm), and
' pic_capital() the 13-by-13 star (draw/pictures.bm). The sizes are the DOS game's. They are not
' made smaller, since what GET needs has not been measured in each compiler.
CONST FLAG_BUFFER_SIZE = 300
CONST MARKER_BUFFER_SIZE = 300
CONST CAPITAL_BUFFER_SIZE = 60
'==========================================================================
' The menu that menu_select shows (ui/menu.bm).
DIM SHARED menu_choice%, menu_col%, menu_row%, menu_item_count%, menu_box_type%, menu_color%, menu_highlight%, menu_key$
' The turn and the game.
DIM SHARED turn_month, turn_year, current_side, turn_moves_done, turn_navy_done, turn_recruit_count
DIM SHARED game_over, victory_side, saves_exist
' The options.
DIM SHARED opt_players, opt_graphics, opt_sound, opt_pause!, opt_difficulty, opt_alt_colors, opt_ai_aggression
DIM SHARED opt_winter_campaigns, opt_event_balance, opt_realism, opt_history
' The rules, the income and the computer's strength.
DIM SHARED rule_attack_loss, rule_defend_loss, rule_strength_cap, union_income_bonus, total_income, ai_strength_ratio!
' Commerce raiding at sea.
DIM SHARED raiding_side, raid_loss, fleet_pursuit
DIM SHARED city_x(MAX_CITIES), city_y(MAX_CITIES), city_value(MAX_CITIES), city_owner(MAX_CITIES), city_name$(MAX_CITIES), leader_name$(MAX_LEADERS), turn_recruit_city(5)
DIM SHARED side_cash(2), side_city_count(2), city_road(MAX_CITIES, MAX_ROADS), city_port_type(MAX_CITIES), side_income(2), saved_under_army(FLAG_BUFFER_SIZE), leader_rating(MAX_LEADERS)
DIM SHARED menu_text$(MENU_MAX_ROWS), saved_under_marker(MARKER_BUFFER_SIZE), side_name$(2), army_city(MAX_ARMIES), army_name$(MAX_ARMIES), victory_rule(6)
DIM SHARED army_size(MAX_ARMIES), army_leader_rating(MAX_ARMIES), army_experience(MAX_ARMIES), army_supply(MAX_ARMIES), month_name$(MONTHS_PER_YEAR)
DIM SHARED army_order(MAX_ARMIES), menu_value(MENU_MAX_ROWS), flag_star_x(8), flag_star_y(8), train_from_city(2)
DIM SHARED fleet_city(2), fleet_size(2), city_army(MAX_CITIES), city_fort(MAX_CITIES), train_army(2)
DIM SHARED side_victory_points(2), side_capital(2), train_city(2), fleet_ships$(2)
DIM SHARED train_capacity(2), map_font$(26), move_order_key(MAX_ARMIES), side_casualties&(2), side_battles_won(2), city_first_owner(MAX_CITIES)
' The battles won and the men lost (in hundreds) by each side: side_battles_won() and
' side_casualties&() in the game played, all_battles_won&() and all_casualties&() in every game
' played on this machine. The game's are saved with it, the others in CWS.CFG.
DIM SHARED all_battles_won&(2), all_casualties&(2)
' The scenarios of scenarios/SCENARIOS.LST (load_scenario_list, io/files.bm): each one's folder
' and title. scenario_now is the row of the scenario the game is on.
DIM SHARED scenario_count, scenario_now, scenario_folder$(MAX_SCENARIOS), scenario_title$(MAX_SCENARIOS)
' TRUE while the Utility menu's Vary Start may be used: in a new game until its first End Turn
' (game_reset, turn_next_player). A loaded game sets it to FALSE (load_game).
DIM SHARED vary_start_open
' The events table: one row for each special event of scenarios/EVENTS.DAT, in the file's order.
' event_favors() is the side the event is good for, and event_for() the side its effect is
' for when that is another (SIDE_NONE when it is the same). event_before() is TRUE for an
' announcement, which is tried before the month's roll. event_instead() and event_then() are
' rows, 0 for none. event_done() is set when the event has happened in this game.
DIM SHARED event_count, event_banner$, event_file_error$
DIM SHARED event_name$(MAX_EVENTS), event_favors(MAX_EVENTS), event_listed(MAX_EVENTS), event_done(MAX_EVENTS)
DIM SHARED event_before(MAX_EVENTS), event_for(MAX_EVENTS)
DIM SHARED event_effect(MAX_EVENTS), event_amount!(MAX_EVENTS, 1), event_redraw(MAX_EVENTS)
DIM SHARED event_text$(MAX_EVENTS, MAX_EVENT_TEXTS), event_text_count(MAX_EVENTS), event_outcome$(MAX_EVENTS)
DIM SHARED event_instead(MAX_EVENTS), event_then(MAX_EVENTS)
' An event's conditions are two runs of the condition arrays: those of its "if" line and
' those of its "instead" line.
DIM SHARED event_if_first(MAX_EVENTS), event_if_count(MAX_EVENTS), event_instead_first(MAX_EVENTS), event_instead_count(MAX_EVENTS)
DIM SHARED condition_count, condition_subject(MAX_EVENT_CONDITIONS), condition_relation(MAX_EVENT_CONDITIONS), condition_value!(MAX_EVENT_CONDITIONS)
' The month's chance of an event: the product of its factors, then chance_plus#, then at most
' chance_most# when chance_has_most is TRUE (the chance line of EVENTS.DAT).
DIM SHARED chance_count, chance_kind(MAX_CHANCE_FACTORS), chance_value#(MAX_CHANCE_FACTORS), chance_plus#, chance_most#, chance_has_most
' Set by event_roll for the texts of the event: the city of a riot and the army that was
' reinforced. They fill {city} and {army}.
DIM SHARED event_city, event_army
' The capital's star, taken from the icon with GET (draw_title), and the image handle of the mountains,
' loaded by show_title. The other pictures are loaded when drawn (draw_picture, draw/pictures.bm).
DIM SHARED pic_capital(CAPITAL_BUFFER_SIZE)
DIM SHARED pic_mountain AS LONG
' A copy of the map without its cities and marks, kept by draw_map_area for draw_map_restore.
DIM SHARED map_base AS LONG
' Set by script_start (io/script.bm) when tests\play.py runs the program.
DIM SHARED scripted
' Set by script_start when CWS_AUTOPLAY is 1 as well: the computer plays both sides.
DIM SHARED autoplay
' The forced dice of special_events under a script: the groups still to come, and what is
' left of this call's group (script_dice_next and script_rnd!, io/script.bm).
DIM SHARED script_dice$, script_dice_now$
' The tuning knobs: numbers that set the game's balance, read from scenarios/TUNING.DAT at each new
' game (load_tuning, io/tuning_file.bm). Each has the name of its line in that file, and what it
' does is said there and in tools/tuning/knobs.txt, from which io/tuning_knobs.bi is written. Their
' defaults are set here, when the program starts, so that the unit tests see them too.
' $INCLUDE: 'io/tuning_knobs.bi'
DIM SHARED tuning_error$
CALL tuning_defaults
