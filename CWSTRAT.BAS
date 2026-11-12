OPTION _EXPLICIT
DEFINT A-Z
DECLARE SUB draw_flag_icon (x%, y%, z%)
DECLARE SUB navy_remove_ship (who%)
DECLARE SUB draw_flag (who%, w%, a%)
DECLARE SUB check_map_links ()
DECLARE SUB draw_ironclad ()
DECLARE SUB normal_random_number (xbar%, vary%, result%)
DECLARE SUB menu_army_relieve (who%)
DECLARE SUB menu_army_retreat (active%, x%)
DECLARE SUB draw_schooner ()
DECLARE SUB draw_fleet_ship (who%, i%)
DECLARE SUB draw_stack_markers (who%)
DECLARE SUB draw_train (who%, flag%)
DECLARE FUNCTION railroad_capacity% (who%)
DECLARE SUB draw_top_bar ()
' $INCLUDE: 'cws14.bi'
DIM replay AS INTEGER: DIM k AS INTEGER: DIM i AS INTEGER: DIM a$: DIM chosit AS INTEGER: DIM action AS INTEGER: DIM ended AS INTEGER

CALL script_mute
replay = 0
newgame:
game_over = 0: turn_recruit_state = 0
FOR k = 1 TO MAX_ARMIES: army_size(k) = 0: army_city(k) = 0: army_order(k) = ORDER_NONE: army_leader_rating(k) = 0: army_name$(k) = "": NEXT k
union_income_bonus = 0: emancipation_done = 0
FOR k = SIDE_UNION TO SIDE_REBEL
fleet_size(k) = 0: fleet_city(k) = 0
train_army(k) = 0: side_victory_points(k) = 0: train_city(k) = 0
NEXT k

saves_exist = 1: victory_rule(VICTORY_MONTH) = 1
CALL load_scenario
IF LEN(DIR$(GFXDIR + "mtn.vga")) > 0 THEN
	CALL load_picture(GFXDIR + "mtn.vga", pic_mountain())
ELSE
	COLOR COLOR_WHITE: BEEP: PRINT "ERROR: Missing File  'MTN.VGA'": wait_seconds PAUSE_LONG
END IF

RESTORE
FOR k = 1 TO 26: READ map_font$(k): NEXT k

IF opt_realism >= REALISM_ON AND turn_year < IRONCLAD_YEAR THEN
		FOR i = SIDE_UNION TO SIDE_REBEL
			a$ = STRING$(LEN(fleet_ships$(i)), "W")
			fleet_ships$(i) = a$
		NEXT i
END IF
iron:
IF opt_players < PLAYERS_ONE OR opt_players > PLAYERS_TWO THEN opt_players = PLAYERS_ONE
IF opt_players = PLAYERS_TWO OR current_side = SIDE_NONE THEN current_side = SIDE_UNION
IF current_side = SIDE_UNION THEN opt_event_balance = 7
IF current_side = SIDE_REBEL THEN opt_event_balance = 3
	IF opt_pause! < 1 THEN opt_pause! = 2
	IF current_side = SIDE_UNION AND opt_difficulty < 3 THEN side_cash(SIDE_REBEL) = side_cash(SIDE_REBEL) + 600 - 100 * opt_difficulty
	IF current_side = SIDE_REBEL AND opt_difficulty > 3 THEN side_cash(SIDE_UNION) = side_cash(SIDE_UNION) + 100 * opt_difficulty


FOR i = SIDE_UNION TO SIDE_REBEL: side_income(i) = side_cash(i): side_cash(i) = side_cash(i) + 50 * RND: NEXT i
menu_choice = 0
a$ = COMMAND$: IF a$ <> "" OR replay > 0 GOTO notitle2

band:           ' SHELL "cwstitle.exe" (a DOS program with no source; cannot run on 64-bit Windows)
notitle2:
CALL draw_title
IF replay = 0 AND opt_sound = SOUND_MUSIC AND menu_choice = 0 THEN CALL play_title_music
CALL set_union_advantage

CALL load_cities
CALL clear_bottom_line

CALL script_start
wait_seconds .3
menu_box_type = BOX_DOUBLE
menu_highlight = COLOR_WHITE
replay = 1
IF opt_players = PLAYERS_TWO THEN CALL draw_player_turn
menu_text$(0) = "VGA CIVILWAR STRATEGY"
menu_text$(1) = "Resume Saved Game"
menu_text$(2) = "Start NEW Game"
menu_text$(3) = "Quit to DOS"
menu_col = 33: menu_row = 20: menu_color = COLOR_MAGENTA: menu_item_count = 3
menu_choice = MENU_START + 2
CALL menu_select(MENU_PLAIN)
IF menu_choice = 1 THEN
	CLS
	CALL menu_load_game
	GOTO menu0
END IF
IF menu_choice = 3 THEN CLS : END
IF opt_history = 1 THEN
	CLS
	IF LEN(DIR$("cws.his")) > 0 THEN CALL script_shell("copy cws.his oldhist.ory")
	OPEN "O", 2, "cws.his"
	PRINT #2, TAB(20); "[ HISTORY OF GAME BEGUN "; script_date$; " ]"
	CLOSE #2
ELSE
	SCREEN 12: CLS
END IF
CALL draw_map
GOTO menu0
'==========================================================================
'                              New Month
'==========================================================================
newmonth:
IF current_side > 2 THEN current_side = SIDE_UNION
a$ = "--------> EVENTS FOR " + month_name$(turn_month) + " " + STR$(turn_year) + " --------"
CALL scribe_message(a$, SHOW_NOT)
CALL turn_resolve
CALL turn_collect_income

chosit = 22
IF opt_players = PLAYERS_TWO THEN CALL draw_player_turn: CALL draw_map
CALL check_victory_conditions
ON ERROR GOTO 0
IF game_over > 0 THEN
	FOR k = 1 TO MAX_ARMIES: army_city(k) = 0: NEXT k
	GOTO newgame
END IF

'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
'                              Main Menu
'±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
menu0:
CALL menu_main(chosit)
'==========================================================================
'                            Main Menu
'==========================================================================
SELECT CASE menu_choice
	CASE 1
	IF side_cash(current_side) < COST_RECRUIT OR turn_recruit_state < 0 THEN CALL turn_close_recruiting: GOTO menu0
	CALL menu_army_recruit((current_side))
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 2
	CALL menu_army_move
	chosit = 23
	GOTO menu0
'==========================================================================
	CASE 3
	IF turn_navy_done = 0 THEN CALL navy_commands((current_side), NAVY_ASK)
	chosit = 25
	CASE 4
	CALL menu_main_railroad
'==========================================================================
	CASE 5
	CALL menu_main_end_turn(ended): IF ended = 0 THEN chosit = 24: GOTO menu0
endrnd:
	CALL turn_reset_commands
	IF opt_players = PLAYERS_TWO THEN current_side = current_side + 1: IF current_side = SIDE_REBEL THEN CALL draw_player_turn: CALL draw_map: GOTO menu0
	GOTO newmonth
'==========================================================================
	CASE 6
	CALL menu_main_inform: chosit = 27
'==========================================================================
'                            Commands
'==========================================================================
	CASE 7
	chosit = 28
	CALL menu_commands
'==========================================================================
'                               Utility Menu
'==========================================================================
	CASE 8
	chosit = 29
	CALL menu_utility
'==========================================================================
'                               Files
'==========================================================================
	CASE 9
	chosit = 30
	CALL menu_files(action)
	IF action = FILES_NEW_GAME GOTO newgame
	IF action = FILES_QUIT THEN END
'==========================================================================
	CASE MENU_END_TURN_KEY
	GOTO endrnd
CASE ELSE
	chosit = 22
	GOTO menu0
END SELECT
GOTO menu0
'............................................................................
DATA "U2E2F2D2BU1L3","U4R3F1G1L2BR2BF1G1L2","H1U2E1R2F1BD2G1L1"
DATA "U4R3F1D1D1G1L2","U4R3BD2BL1L2D2R3","U4R3BD2BL1L2","H1U2E1R3BD2L2BD2R2U1"
DATA "U4BD2BR1R3U2BD3D1","R1U4L1R2BL1BD4R1","R1E1U3BG3F1","U4BR3G2F2"
DATA "U4BD4BR1R1","U4F2E2D4","U4F4U4","H1U2E1R2F1D2G1L1","U4R3F1G1L2"
DATA "H1U2E1R2F1D2G1L1BE1F1R1","U4R3F1G1L2BR1F2","R3E1H1L2H1E1R3"
DATA "U4L2BR3R1","H1U3BR4D3G1L1","H2U2BR4D2G2","H2U2BF3BU1D1F1E2U2"
DATA "E4BD4H4","U2H2BR4G2","E4L4BD4R4"
' $INCLUDE: 'rules/army.bm'
' $INCLUDE: 'rules/city.bm'
' $INCLUDE: 'rules/battle.bm'
' $INCLUDE: 'rules/navy.bm'
' $INCLUDE: 'rules/railroad.bm'
' $INCLUDE: 'rules/setup.bm'
' $INCLUDE: 'rules/turn.bm'
' $INCLUDE: 'rules/victory.bm'
' $INCLUDE: 'ai/ai.bm'
' $INCLUDE: 'ui/menu.bm'
' $INCLUDE: 'ui/main_menu.bm'
' $INCLUDE: 'ui/orders.bm'
' $INCLUDE: 'ui/files.bm'
' $INCLUDE: 'ui/options.bm'
' $INCLUDE: 'ui/reports.bm'
' $INCLUDE: 'ui/screen.bm'
' $INCLUDE: 'ui/messages.bm'
' $INCLUDE: 'ui/battle.bm'
' $INCLUDE: 'ui/railroad.bm'
' $INCLUDE: 'ui/city.bm'
' $INCLUDE: 'ui/army.bm'
' $INCLUDE: 'ui/navy.bm'
' $INCLUDE: 'ui/turn.bm'
' $INCLUDE: 'ui/ai.bm'
' $INCLUDE: 'ui/events.bm'
' $INCLUDE: 'ui/victory.bm'
' $INCLUDE: 'draw/map.bm'
' $INCLUDE: 'draw/icons.bm'
' $INCLUDE: 'draw/ships.bm'
' $INCLUDE: 'draw/pictures.bm'
' $INCLUDE: 'game/victory_screens.bm'
' $INCLUDE: 'game/tunes.bm'
' $INCLUDE: 'game/events.bm'
' $INCLUDE: 'port/files.bm'
' $INCLUDE: 'port/qb64.bm'
' $INCLUDE: 'port/script.bm'
