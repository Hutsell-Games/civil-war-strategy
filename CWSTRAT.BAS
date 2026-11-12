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
DIM fin AS INTEGER: DIM index AS INTEGER: DIM empty AS INTEGER: DIM t$
DIM replay AS INTEGER: DIM k AS INTEGER: DIM i AS INTEGER: DIM a$: DIM x AS INTEGER: DIM chosit AS INTEGER: DIM z AS INTEGER: DIM y AS INTEGER: DIM limit AS INTEGER: DIM star AS INTEGER: DIM target AS INTEGER

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
	GOTO loader
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
CALL draw_top_bar
IF opt_players = PLAYERS_TWO AND current_side = SIDE_NONE THEN current_side = SIDE_UNION
IF side_cash(current_side) < COST_SHIP AND fleet_city(current_side) = 0 THEN turn_navy_done = 1

menu_highlight = COLOR_LIGHT_CYAN
menu_color = COLOR_RED
menu_col = PANEL_COL: menu_row = 13
menu_text$(0) = "Main"
menu_text$(1) = "Troops": IF turn_recruit_state < 0 OR side_cash(current_side) < COST_RECRUIT THEN menu_text$(1) = "-": chosit = 23
menu_text$(2) = "Moves": IF turn_moves_done > 0 THEN menu_text$(2) = "-": IF chosit = 23 THEN chosit = 24
menu_text$(3) = "Ships": IF turn_navy_done > 0 THEN menu_text$(3) = "-": IF chosit = 24 THEN chosit = 25
menu_text$(4) = "Railroad": IF train_army(current_side) > 0 THEN menu_text$(4) = "-": IF chosit = 25 THEN chosit = 26
menu_text$(5) = "END TURN"
menu_text$(6) = "Inform"
menu_text$(7) = "COMMANDS"
menu_text$(8) = "UTILITY"
menu_text$(9) = "Files"

menu_item_count = 9
menu_choice = chosit
CALL menu_select(MENU_PLAIN): CALL clear_right_panel
'==========================================================================
'                            Main Menu
'==========================================================================
SELECT CASE menu_choice
	CASE 1
	IF side_cash(current_side) < COST_RECRUIT OR turn_recruit_state < 0 THEN turn_recruit_state = -1: GOTO menu0
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
IF train_army(current_side) = 0 THEN
	COLOR COLOR_WHITE: LOCATE 4, 68: PRINT "RAILROAD MOVE"
	PSET (550, 20), 0
	DRAW "C15S6" + TRAIN_OUTLINE$ + "U9L2U5R1BF4"
	z = 9: IF current_side = SIDE_REBEL THEN z = 7
	x = POINT(0): y = POINT(1)
	PAINT (x, y), z, 15
	COLOR COLOR_WHITE: IF current_side = SIDE_UNION THEN COLOR COLOR_LIGHT_CYAN
	limit = railroad_capacity(current_side)
	CALL clear_bottom_line: PRINT "Railroad capacity ="; RTRIM$(STR$(limit)); "00";
	CALL railroad_move(current_side)
ELSE
	CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN: PRINT "Railroad is already carrying "; army_name$(train_army(current_side)); " to "; city_name$(army_order(train_army(current_side))); : GOTO menu0
END IF
'==========================================================================
	CASE 5
	menu_col = PANEL_COL: menu_row = 15
	menu_highlight = COLOR_WHITE: menu_color = COLOR_CYAN: menu_choice = MENU_START + 2
	menu_text$(0) = "End Turn"
	menu_text$(1) = "Yes"
	menu_text$(2) = "NOT YET"
	menu_item_count = 2: CALL menu_select(MENU_PLAIN): CALL clear_right_panel: IF menu_choice <> 1 THEN chosit = 24: GOTO menu0
endrnd:
	turn_recruit_state = 0: turn_moves_done = 0: turn_navy_done = 0
	IF opt_players = PLAYERS_TWO THEN current_side = current_side + 1: IF current_side = SIDE_REBEL THEN CALL draw_player_turn: CALL draw_map: GOTO menu0
	GOTO newmonth
'==========================================================================
	CASE 6
	CALL menu_report((current_side)): chosit = 27
	star = side_first_army(current_side): fin = side_last_army(current_side)
	FOR i = star TO fin
	IF army_order(i) > 0 THEN CALL draw_map_marker(army_city(i), army_order(i), MARK_MOVE_LINE)
	NEXT i
'==========================================================================
'                            Commands
'==========================================================================
	CASE 7
optmen:
	menu_col = PANEL_COL: menu_row = 13
	COLOR COLOR_LIGHT_CYAN: LOCATE menu_row - 2, menu_col: PRINT "esc=Main Menu"
	menu_highlight = COLOR_WHITE: menu_color = COLOR_CYAN: chosit = 24
	menu_text$(0) = "Commands"
	menu_text$(1) = "Cancel"
	menu_text$(2) = "Fortify": IF side_cash(current_side) < COST_FORT THEN menu_text$(2) = "-"
	menu_text$(3) = "Join"
	menu_text$(4) = "Supply"
	menu_text$(5) = "Capital": IF side_capital(current_side) = 0 OR side_cash(current_side) < COST_MOVE_CAPITAL THEN menu_text$(5) = "-"
	menu_text$(6) = "Detach": IF current_side = SIDE_UNION THEN menu_text$(6) = "-"
	menu_text$(7) = "Army Drill"
	menu_text$(8) = "Relieve"
	menu_text$(9) = "MAIN MENU"
	menu_item_count = 9
	CALL menu_select(MENU_PLAIN): CALL clear_right_panel
	chosit = 28
     SELECT CASE menu_choice
'---------------------------------------------------------------------------
'                               Cancel
'---------------------------------------------------------------------------
		CASE 1
	CALL menu_army_cancel(current_side): turn_moves_done = 0
	menu_choice = MENU_START + 1
'---------------------------------------------------------------------------
'                               Fortify
'---------------------------------------------------------------------------
		CASE 2
	IF side_cash(current_side) < COST_FORT THEN COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "Not enough money for fort"; : GOTO menu0
	CALL menu_city_fortify(target)
	IF side_cash(current_side) < COST_FORT GOTO menu0
	menu_choice = MENU_START + 2
	GOTO optmen
'---------------------------------------------------------------------------
'                               Combine
'---------------------------------------------------------------------------
		CASE 3
	x = current_side
	CALL army_combine(x)
	IF x < 0 THEN
		CALL clear_bottom_line
		COLOR COLOR_LIGHT_CYAN
		PRINT "No eligible armies in same city to combine";
		CALL draw_stack_markers(current_side)
		GOTO menu0
	END IF
	menu_choice = MENU_START + 3
	GOTO optmen
'---------------------------------------------------------------------------
'                               Supply
'---------------------------------------------------------------------------
		CASE 4
		CALL menu_supply(index)
		IF index = 0 GOTO menu0
		menu_choice = MENU_START + 4
		GOTO optmen
'-------------------------------------------------------------------------
'                               Move Capital
'-------------------------------------------------------------------------
		CASE 5
	CALL menu_move_capital(index)
	IF index = 0 GOTO menu0
'-------------------------------------------------------------------------
'                               Detach
'-------------------------------------------------------------------------
		CASE 6
	IF current_side = SIDE_UNION THEN CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN: PRINT "Option not available to Union"; : GOTO menu0
	COLOR COLOR_YELLOW: LOCATE 4, 68: PRINT "DETACH UNIT"
	CALL menu_army_select(index, target): IF target < 1 OR index < 1 GOTO menu0
	IF army_size(index) < MIN_DETACH_SIZE THEN CALL clear_bottom_line: PRINT "Too small to detach"; : CALL wait_seconds(opt_pause!): GOTO menu0
	CALL army_get_commander(2, empty): IF empty = 0 GOTO menu0
	CALL army_detach(index, target, empty)
	COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "Unit #"; empty; " with "; : CALL print_army_size(empty): PRINT " men detached under "; army_name$(empty); : CALL wait_seconds(opt_pause!): IF opt_sound >= SOUND_EFFECTS THEN SOUND 2222, 1
	CALL draw_stack_markers(current_side)
	menu_choice = MENU_START + 6
	GOTO optmen
'-------------------------------------------------------------------------
'                               Drill
'-------------------------------------------------------------------------
		CASE 7
	COLOR COLOR_YELLOW: LOCATE 4, 68: PRINT "DRILL ARMY"
	CALL menu_army_select(index, target)
	IF target < 1 OR index < 1 THEN COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "No armies remain eligible for drills in "; month_name$(turn_month); : GOTO menu0
	IF army_experience(index) > 5 OR army_experience(index) >= army_leader_rating(index) THEN COLOR COLOR_LIGHT_RED: CALL clear_bottom_line: PRINT army_name$(index); ": Army has reached maximum improvement through drilling"; : GOTO optmen
	CALL army_drill(index)
	CALL clear_bottom_line: PRINT army_name$(index); " has drilled to reach experience level "; army_experience(index); : IF opt_sound >= SOUND_EFFECTS THEN SOUND 2222, 1
	CALL wait_seconds(opt_pause!): clear_bottom_line
	menu_choice = MENU_START + 7
	GOTO optmen
'-------------------------------------------------------------------------
'                               Relieve
'-------------------------------------------------------------------------
		CASE 8
		CALL menu_army_relieve(current_side)
		menu_choice = MENU_START + 8
		GOTO optmen
'-------------------------------------------------------------------------
		CASE ELSE
		chosit = 28
		GOTO menu0
      END SELECT
	menu_choice = MENU_START + menu_choice: GOTO optmen
'==========================================================================
'                               Utility Menu
'==========================================================================
	CASE 8
utile:
	chosit = 29
	menu_text$(0) = "Utility"
	menu_text$(1) = "Side": IF opt_players = PLAYERS_TWO THEN menu_text$(2) = ""
	menu_text$(2) = "1 Player": IF opt_players = PLAYERS_TWO THEN menu_text$(2) = "2 Player"
	menu_text$(3) = "Graphics" + STR$(opt_graphics)
	menu_text$(4) = "Noise": IF opt_sound >= SOUND_EFFECTS THEN menu_text$(4) = menu_text$(4) + STRING$(opt_sound, "*")
	menu_text$(5) = "Display" + STR$(opt_pause!)
	a$ = STR$(opt_difficulty): IF current_side = SIDE_UNION THEN a$ = STR$(6 - opt_difficulty)
	menu_text$(6) = "Balance" + a$
	menu_text$(7) = "End Cond"
	a$ = "û": IF opt_event_balance = 0 THEN a$ = ""
	menu_text$(8) = "Rndom Evt " + a$
	menu_text$(9) = "Vary Start"
	a$ = "": IF opt_winter_campaigns = 1 THEN a$ = "û"
	menu_text$(10) = "Jan Campgn" + a$
	a$ = "": IF opt_realism = REALISM_ON THEN a$ = "û"
	menu_text$(11) = "Realism " + a$
	menu_text$(12) = "Chk Links"
	a$ = "": IF opt_history = 1 THEN a$ = "û"
	menu_text$(13) = "History" + a$
	menu_item_count = 13: menu_col = PANEL_COL: menu_row = 11
	COLOR COLOR_LIGHT_CYAN: LOCATE menu_row - 2, menu_col: PRINT "esc=Main Menu"
	IF opt_players = PLAYERS_ONE THEN menu_item_count = 14: menu_text$(14) = "Aggress" + STR$(opt_ai_aggression)
	CALL menu_select(-1): CALL clear_right_panel
	    SELECT CASE menu_choice
'-------------------------------------------------------------------------
'                               Swap Sides
'-------------------------------------------------------------------------
	    CASE 1
		IF opt_players = PLAYERS_TWO GOTO menu0
		current_side = other_side(current_side): COLOR COLOR_LIGHT_BLUE: IF current_side = SIDE_REBEL THEN COLOR COLOR_GRAY
		CALL clear_bottom_line: PRINT "Now playing "; side_name$(current_side); " side"; : IF opt_sound >= SOUND_EFFECTS THEN SOUND 999, 1
		IF current_side = SIDE_UNION THEN opt_event_balance = 7
		IF current_side = SIDE_REBEL THEN opt_event_balance = 3
		CALL draw_top_bar
		GOTO menu0
'-------------------------------------------------------------------------
'                               Solo or 2 Player
'-------------------------------------------------------------------------
	    CASE 2
		opt_players = PLAYERS_ONE + PLAYERS_TWO - opt_players: CALL clear_bottom_line: COLOR COLOR_LIGHT_RED
		IF opt_sound >= SOUND_EFFECTS THEN SOUND 999, 1
		a$ = "Solo": IF opt_players = PLAYERS_TWO THEN a$ = "2 Player"
		PRINT a$; " Game";
		menu_choice = MENU_START + 2: GOTO utile
'-------------------------------------------------------------------------
'                               Graphics
'-------------------------------------------------------------------------
	    CASE 3
		opt_graphics = opt_graphics + 1
		IF opt_graphics > GRAPHICS_FULL THEN opt_graphics = GRAPHICS_OFF
		a$ = "ROADS"
		IF opt_graphics = GRAPHICS_OFF THEN a$ = "DISABLED"
		IF opt_graphics = GRAPHICS_NAMES THEN a$ = "CITY NAMES"
		IF opt_graphics = GRAPHICS_FULL THEN a$ = "FULL"
		CLS
		CALL draw_map
		CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN: PRINT "Graphics : "; a$; : IF opt_sound >= SOUND_EFFECTS THEN SOUND 2700, 1
		menu_choice = MENU_START + 3: GOTO utile
'-------------------------------------------------------------------------
'                               Sounds
'-------------------------------------------------------------------------
	    CASE 4
		CALL clear_right_panel: menu_choice = MENU_START + 1 + opt_sound
		menu_text$(0) = "SOUNDS"
		menu_text$(1) = "Quiet"
		menu_text$(2) = "Sound"
		menu_text$(3) = " & Sound"
		menu_item_count = 3: menu_col = PANEL_COL: menu_row = 12
		CALL menu_select(MENU_PLAIN): CALL clear_right_panel
		IF menu_choice < 1 GOTO menu0
		COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "Sound Option : "; menu_text$(menu_choice);
		opt_sound = menu_choice - 1
		IF opt_sound >= SOUND_EFFECTS THEN SOUND 999, 1
		menu_choice = MENU_START + 4: GOTO utile
'-------------------------------------------------------------------------
'                               Display Speed
'-------------------------------------------------------------------------
	    CASE 5
		menu_choice = opt_pause! + 21
		menu_text$(0) = "Display"
		menu_text$(1) = "Fast"
		menu_text$(2) = "Normal"
		menu_text$(3) = "Slow"
		menu_text$(4) = "Very Slow"
		menu_text$(5) = "Reg Color": IF opt_alt_colors > 0 THEN menu_text$(5) = "Alt Color"
		menu_col = PANEL_COL: menu_row = 15: menu_item_count = 5
		CALL menu_select(MENU_PLAIN): CALL clear_right_panel
		SELECT CASE menu_choice
			CASE IS < 1
			CASE IS < 5
				opt_pause! = menu_choice
				IF opt_pause! = 4 THEN opt_pause! = 8
				CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN
				PRINT "Display Speed : "; menu_text$(menu_choice);
			CASE 5
				opt_alt_colors = 1 - opt_alt_colors
				CLS
				CALL draw_map
				CALL draw_top_bar
		END SELECT
		menu_choice = MENU_START + 5: GOTO utile
'-------------------------------------------------------------------------
'                               Play Balance
'-------------------------------------------------------------------------
	   CASE 6
		menu_choice = MENU_START + opt_difficulty
		menu_text$(0) = "Balance"
		menu_text$(1) = "Rebel ++"
		menu_text$(2) = "Rebel +"
		menu_text$(3) = "Balanced"
		menu_text$(4) = "Union +"
		menu_text$(5) = "Union ++"
		menu_col = PANEL_COL: menu_row = 15: menu_item_count = 5
		CALL menu_select(MENU_FACES): CALL clear_right_panel
		IF menu_choice < 1 GOTO menu0
		CALL clear_bottom_line
		COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "Play Balance : "; menu_text$(menu_choice);
		opt_difficulty = menu_choice
		CALL set_union_advantage
		menu_choice = MENU_START + 6: GOTO utile
'-------------------------------------------------------------------------
'                               Ending Conditions
'-------------------------------------------------------------------------
	   CASE 7
		CALL menu_victory_conditions
		menu_choice = MENU_START + 7: GOTO utile
'-------------------------------------------------------------------------
'                           Random Events Options
'-------------------------------------------------------------------------
	   CASE 8
		 menu_text$(0) = "Random Events"
		 menu_item_count = 4: menu_col = 30: menu_row = 8
		 menu_text$(1) = "OFF"
		 menu_text$(2) = "Favor Union ": IF opt_event_balance = 3 THEN menu_text$(2) = menu_text$(2) + " "
		 menu_text$(3) = "Neutral     ": IF opt_event_balance = 5 THEN menu_text$(3) = menu_text$(3) + " "
		 menu_text$(4) = "Favor Rebels": IF opt_event_balance = 7 THEN menu_text$(4) = menu_text$(4) + " "
		 menu_color = COLOR_MAGENTA
		 CALL menu_select(MENU_PLAIN)
		 menu_color = COLOR_RED

		 SELECT CASE menu_choice
		 CASE 1
		 opt_event_balance = 0: t$ = ""
		 CASE 2
		 opt_event_balance = 3
		 CASE 3
		 opt_event_balance = 5
		 CASE 4
		 opt_event_balance = 7
		 CASE ELSE
		 END SELECT
		 IF menu_choice > 1 AND menu_choice < 5 THEN t$ = menu_text$(menu_choice)
		 CALL clear_bottom_line
		 a$ = "": IF opt_event_balance = 0 THEN a$ = "OFF"
		 COLOR COLOR_LIGHT_CYAN: PRINT "Random Events : "; a$; " "; t$;
		 COLOR COLOR_YELLOW: PRINT "			press a key";
		 CALL wait_key("R")
		 CLS
		 CALL draw_map
		 menu_choice = MENU_START + 8
		 GOTO utile
'-------------------------------------------------------------------------
'                              Vary Start Conditions
'-------------------------------------------------------------------------
	   CASE 9
		CALL vary_start_conditions
		CLS
		CALL draw_map
		menu_choice = MENU_START + 9: GOTO utile
'-------------------------------------------------------------------------
'                               January Campaigns
'-------------------------------------------------------------------------
	   CASE 10
		opt_winter_campaigns = 1 - opt_winter_campaigns
		a$ = "PROHIBITED": IF opt_winter_campaigns = 1 THEN a$ = "ALLOWED"
		COLOR COLOR_LIGHT_CYAN
		CALL clear_bottom_line
		PRINT "January Campaigns : "; a$;
		menu_choice = MENU_START + 10: GOTO utile
'-------------------------------------------------------------------------
'                               Realism Switch
'-------------------------------------------------------------------------
	   CASE 11
		opt_realism = 1 - opt_realism
		CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN
	IF opt_realism = REALISM_OFF THEN
		PRINT "Recruiting FIXED :  7000 for NEW Armies   4500 for Additions";
	ELSE
		PRINT "REALISM ON: Recruiting based on CITY SIZE";
		IF current_side = SIDE_REBEL AND opt_event_balance = 1 AND opt_event_balance < 5 THEN opt_event_balance = opt_event_balance + 2
		CALL set_union_advantage
	END IF
		menu_choice = MENU_START + 11: GOTO utile
'-------------------------------------------------------------------------
'                               Check Map Linakges
'-------------------------------------------------------------------------
	   CASE 12
		CALL check_map_links
		CALL wait_seconds(99)
		CALL draw_map
'-------------------------------------------------------------------------
'                               History
'-------------------------------------------------------------------------
	   CASE 13
		opt_history = 1 - opt_history
		a$ = "OFF": IF opt_history = 1 THEN a$ = "ON"
		CALL clear_bottom_line: PRINT "History is now "; a$;
		menu_choice = MENU_START + 13: GOTO utile
'-------------------------------------------------------------------------
'                               Aggression
'-------------------------------------------------------------------------
	   CASE 14
		opt_ai_aggression = opt_ai_aggression + 1: IF opt_ai_aggression > 5 THEN opt_ai_aggression = 0
		SELECT CASE opt_ai_aggression
		CASE 0: a$ = "PASSIVE"
		CASE 1: a$ = "TIMID"
		CASE 2: a$ = "CAUTIOUS"
		CASE 3: a$ = "NORMAL"
		CASE 4: a$ = "BOLD"
		CASE 5: a$ = "RECKLESS"
		END SELECT
		CALL clear_bottom_line
		COLOR COLOR_LIGHT_CYAN
		PRINT "Enemy Aggression : "; a$; " ("; opt_ai_aggression; ")";
		menu_choice = MENU_START + 14: GOTO utile
		CASE ELSE
	   END SELECT
'==========================================================================
'                               Files
'==========================================================================
	CASE 9
	IF LEN(DIR$("*.sav")) = 0 THEN saves_exist = 0
filex:
	menu_choice = MENU_START + 2: chosit = 30: IF turn_year = FIRST_YEAR THEN menu_choice = MENU_START + 1
	menu_text$(0) = "Options"
	menu_text$(1) = "Load": IF saves_exist = 0 THEN menu_text$(1) = "-": menu_choice = MENU_START + 2
	menu_text$(2) = "Save"
	menu_text$(3) = "New Game"
	menu_text$(4) = "Quit to DOS"
	menu_item_count = 4: menu_col = PANEL_COL: menu_row = 15
	CALL menu_select(MENU_PLAIN): CALL clear_right_panel
	SELECT CASE menu_choice
		CASE IS < 1: GOTO menu0
		CASE 1, 2
loader:
			IF menu_choice = 1 AND saves_exist = 0 GOTO filex
			IF menu_choice = 1 THEN CALL load_game ELSE CALL save_game
			IF menu_choice = 1 THEN turn_recruit_state = 0: turn_moves_done = 0: turn_navy_done = 0
			GOTO menu0
		CASE 3
			CALL config_write(current_side)
			CLS
			GOTO newgame
		CASE 4: GOTO rusure
	END SELECT
'==========================================================================
	CASE MENU_END_TURN_KEY
	GOTO endrnd
CASE ELSE
	chosit = 22
	GOTO menu0
END SELECT
GOTO menu0
'............................................................................
'                               Subs
'............................................................................
rusure:
menu_choice = MENU_START + 2
menu_text$(0) = "Quit"
menu_text$(1) = "Yes"
menu_text$(2) = "No"
menu_item_count = 2: menu_color = COLOR_MAGENTA
menu_col = PANEL_COL: menu_row = 15
CALL menu_select(MENU_PLAIN): CALL clear_right_panel: IF menu_choice = 1 THEN END ELSE GOTO menu0
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
' $INCLUDE: 'ui/orders.bm'
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
