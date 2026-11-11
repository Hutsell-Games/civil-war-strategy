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
DECLARE SUB railroad_capacity (who%, limit%)
DECLARE SUB draw_top_bar ()
' $INCLUDE: 'cws14.bi'
DIM fin AS INTEGER: DIM max AS INTEGER: DIM index AS INTEGER: DIM empty AS INTEGER: DIM t$: DIM c AS INTEGER
DIM replay AS INTEGER: DIM k AS INTEGER: DIM i AS INTEGER: DIM a$: DIM a AS INTEGER: DIM j AS INTEGER: DIM x AS INTEGER: DIM chosit AS INTEGER: DIM z AS INTEGER: DIM y AS INTEGER: DIM limit AS INTEGER: DIM star AS INTEGER: DIM target AS INTEGER

replay = 0
newgame:
game_over = 0: turn_recruit_state = 0
FOR k = 1 TO MAX_ARMIES: army_size(k) = 0: army_city(k) = 0: army_order(k) = ORDER_NONE: army_leader_rating(k) = 0: army_name$(k) = "": NEXT k
union_income_bonus = 0: emancipation_done = 0
FOR k = SIDE_UNION TO SIDE_REBEL
fleet_size(k) = 0: fleet_city(k) = 0: navymove(k) = 0
train_army(k) = 0: side_victory_points(k) = 0: train_city(k) = 0
NEXT k

saves_exist = 1: victory_rule(VICTORY_MONTH) = 1
CALL file_management(1)
IF LEN(DIR$(GFXDIR + "mtn.vga")) > 0 THEN
	DEF SEG = VARSEG(pic_mountain(1))
	BLOAD GFXDIR + "mtn.vga", VARPTR(pic_mountain(1))
	DEF SEG
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
SCREEN 12
	DEF SEG = VARSEG(pic_loaded(1))
	BLOAD GFXDIR + "cwsicon.vga", VARPTR(pic_loaded(1))
	DEF SEG

	PUT (100, 100), pic_loaded, PSET
	GET (101, 101)-(113, 113), pic_capital
CLS
COLOR COLOR_LIGHT_CYAN: LOCATE 14, 27: PRINT "VGA CIVIL WAR STRATEGY GAME"
COLOR COLOR_RED: LOCATE 15, 32: PRINT "Registered Edition"
COLOR COLOR_YELLOW: LOCATE 28, 1: PRINT TAB(8); "(c) 1998 W. R. Hutsell"
LOCATE 28, 60: PRINT "v1.57"
LINE (190, 170)-(440, 260), 1, B
LINE (180, 180)-(450, 250), 7, B
CALL draw_flag(SIDE_UNION, -440, 0): CALL draw_flag(SIDE_REBEL, -100, 0)
IF replay = 0 AND opt_sound = SOUND_MUSIC AND menu_choice = 0 THEN
IF current_side = SIDE_UNION THEN
	IF INKEY$ <> "" GOTO notitle
	PLAY "MST170o1e8o0b8o1e8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "e8e4f#8g4f#8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "g4e8d2o0b8o1d2 "
	IF INKEY$ <> "" GOTO notitle
	PLAY "o1e8o0b8o1e8e8e4f#8g4f#8g4a8b2g8b2MLg16a16"
	IF INKEY$ <> "" GOTO notitle
	PLAY "MSb4b8b8a8g8a4a8a4f#8g4g8MLg8f#8"
	IF INKEY$ <> "" GOTO notitle
	PLAY "MSe8f#4f#8f#8g8a8b4.a4.g4.f#4.o0b8o1e8e8e4d8e2."
    ELSE
	CALL play_shenandoah
    END IF
END IF
notitle:
GOSUB unionplus

city_name$(0) = "NONE"
OPEN "I", 1, SCNDIR + "cities.grd"
total_income = union_income_bonus + 200
FOR i = 1 TO MAX_CITIES: INPUT #1, a, city_x(i), city_y(i), city_name$(i), city_owner(i), city_value(i)
city_first_owner(i) = city_owner(i)
CALL city_update_occupier(i)
FOR j = 1 TO MAX_ROADS: INPUT #1, city_road(i, j): NEXT j: INPUT #1, city_port_type(i), city_fort(i)
IF city_owner(i) > 0 THEN x = city_owner(i): side_city_count(x) = side_city_count(x) + 1: side_victory_points(x) = side_victory_points(x) + city_value(i)
IF city_owner(i) > 0 THEN side_cash(city_owner(i)) = side_cash(city_owner(i)) + city_value(i)
total_income = total_income + city_value(i)
NEXT i
CLOSE #1: CALL clear_bottom_line

CALL script_start
wait_seconds .3
menu_box_type = BOX_DOUBLE
menu_highlight = COLOR_WHITE
replay = 1
IF opt_players = PLAYERS_TWO THEN GOSUB blanken
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
side_city_count(SIDE_UNION) = 0: side_city_count(SIDE_REBEL) = 0

FOR i = SIDE_UNION TO SIDE_REBEL
side_income(i) = 0
IF side_cash(i) > MAX_CASH THEN side_cash(i) = MAX_CASH
IF side_cash(i) < 0 THEN side_cash(i) = 0
NEXT i
IF opt_players = PLAYERS_ONE AND current_side = SIDE_REBEL THEN side_income(SIDE_UNION) = side_income(SIDE_UNION) + union_income_bonus

FOR i = 1 TO MAX_CITIES
IF city_owner(i) > 0 THEN x = city_owner(i): side_city_count(x) = side_city_count(x) + 1: side_income(x) = side_income(x) + city_value(i)
army_order(i) = ORDER_NONE
NEXT i

FOR i = SIDE_UNION TO SIDE_REBEL: navymove(i) = 0: IF side_capital(i) > 0 THEN side_income(i) = side_income(i) + CAPITAL_INCOME
side_cash(i) = side_cash(i) + side_income(i)
IF raiding_side > 0 AND i <> raiding_side THEN side_cash(i) = side_cash(i) - raid_loss
NEXT i
total_income = side_income(SIDE_UNION) + side_income(SIDE_REBEL)

chosit = 22
IF opt_players = PLAYERS_TWO THEN GOSUB blanken: CALL draw_map
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
	DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U9L2U5R1BF4"
	z = 9: IF current_side = SIDE_REBEL THEN z = 7
	x = POINT(0): y = POINT(1)
	PAINT (x, y), z, 15
	COLOR COLOR_WHITE: IF current_side = SIDE_UNION THEN COLOR COLOR_LIGHT_CYAN
	CALL railroad_capacity(current_side, limit)
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
	IF opt_players = PLAYERS_TWO THEN current_side = current_side + 1: IF current_side = SIDE_REBEL THEN GOSUB blanken: CALL draw_map: GOTO menu0
	GOTO newmonth
'==========================================================================
	CASE 6
	CALL menu_report((current_side)): chosit = 27
	CALL side_army_range(star, fin, current_side)
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
		CALL side_army_range(star, fin, (current_side))
		menu_text$(0) = "Supply"
		menu_col = PANEL_COL: menu_row = 5: menu_color = COLOR_MAGENTA
		menu_item_count = 0
		FOR i = star TO fin
		IF army_city(i) = 0 OR army_supply(i) > 1 GOTO alone
		IF opt_realism >= REALISM_ON THEN
			CALL city_is_connected(current_side, army_city(i), a)
			IF a < 1 THEN CALL clear_bottom_line: COLOR COLOR_WHITE: PRINT side_name$(current_side); " army in "; city_name$(army_city(i)); " is CUT OFF !"; : wait_seconds opt_pause!: GOTO alone
		END IF
		menu_item_count = menu_item_count + 1
		max = 11: IF LEN(army_name$(i)) < 11 THEN max = LEN(army_name$(i))
		menu_text$(menu_item_count) = LEFT$(army_name$(i), max)
		menu_value(menu_item_count) = i
alone:
		NEXT i
		IF menu_item_count = 0 THEN COLOR COLOR_LIGHT_CYAN: CALL clear_bottom_line: PRINT "All eligible "; side_name$(current_side); " armies have supplies"; : GOTO menu0
		CALL menu_select(MENU_ARMY_POINTER): CALL clear_right_panel
		IF menu_choice < 0 GOTO menu0
		index = menu_value(menu_choice)
		IF army_supply(index) < 2 THEN
		CALL army_resupply(index)
		CALL draw_army_flag(index)
		END IF
		menu_choice = MENU_START + 4
		GOTO optmen
'-------------------------------------------------------------------------
'                               Move Capital
'-------------------------------------------------------------------------
		CASE 5
	IF side_capital(current_side) = 0 OR side_cash(current_side) < COST_MOVE_CAPITAL THEN CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN: PRINT "Cannot move capital"; : GOTO menu0
	side_cash(current_side) = side_cash(current_side) - COST_MOVE_CAPITAL
	side_victory_points(other_side(current_side)) = side_victory_points(other_side(current_side)) + 50
	CALL clear_right_panel
	menu_text$(0) = "Capital"
	a$ = city_name$(side_capital(current_side))
	index = side_capital(current_side): CALL menu_city_select(index)
	IF index = 0 GOTO menu0
	side_capital(current_side) = index
	CALL clear_bottom_line: PRINT side_name$(current_side); " capital moved from "; a$; " to "; city_name$(side_capital(current_side));
	CALL clear_right_panel
	CALL draw_cities
	CALL wait_seconds(PAUSE_LONG): CALL clear_bottom_line
'-------------------------------------------------------------------------
'                               Detach
'-------------------------------------------------------------------------
		CASE 6
	IF current_side = SIDE_UNION THEN CALL clear_bottom_line: COLOR COLOR_LIGHT_CYAN: PRINT "Option not available to Union"; : GOTO menu0
	COLOR COLOR_YELLOW: LOCATE 4, 68: PRINT "DETACH UNIT"
	CALL menu_army_select(index, target): IF target < 1 OR index < 1 GOTO menu0
	IF army_size(index) < MIN_DETACH_SIZE THEN CALL clear_bottom_line: PRINT "Too small to detach"; : CALL wait_seconds(opt_pause!): GOTO menu0
	CALL army_get_commander(2, empty): IF empty = 0 GOTO menu0
	army_supply(empty) = .3 * army_supply(index): army_supply(index) = army_supply(index) - army_supply(empty): IF army_supply(index) < 0 THEN army_supply(index) = 0
	army_size(empty) = .3 * army_size(index): army_size(index) = army_size(index) - army_size(empty)
	army_city(empty) = target: army_experience(empty) = army_experience(index): army_order(empty) = ORDER_NONE
	army_leader_rating(empty) = leader_rating(empty)
	army_name$(empty) = leader_name$(empty): leader_name$(empty) = ""
	army_experience(empty) = army_experience(index)
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
	army_experience(index) = army_experience(index) + 1
	CALL clear_bottom_line: PRINT army_name$(index); " has drilled to reach experience level "; army_experience(index); : IF opt_sound >= SOUND_EFFECTS THEN SOUND 2222, 1
	CALL wait_seconds(opt_pause!): clear_bottom_line
	army_order(index) = ORDER_BUSY
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
		GOSUB unionplus
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
		 CALL script_mark_key_wait(1, "R"): DO WHILE INKEY$ = "": LOOP
		 CLS
		 CALL draw_map
		 menu_choice = MENU_START + 8
		 GOTO utile
'-------------------------------------------------------------------------
'                              Vary Start Conditions
'-------------------------------------------------------------------------
	   CASE 9
		CALL file_management(1)
		side_cash(SIDE_UNION) = side_cash(SIDE_UNION) - 100 + 200 * RND
		side_cash(SIDE_REBEL) = side_cash(SIDE_REBEL) + 100 + 200 * RND
		opt_ai_aggression = 5 * RND
		FOR k = 1 TO 6
			IF RND > .6 THEN
			army_city(k) = 0: army_size(k) = 0: army_leader_rating(k) = 0
			army_experience(k) = 0: army_order(k) = ORDER_NONE: army_supply(k) = 0
			END IF
		NEXT k
		FOR k = 21 TO 6
			IF RND > .6 THEN
			army_city(k) = 0: army_size(k) = 0: army_leader_rating(k) = 0
			army_experience(k) = 0: army_order(k) = ORDER_NONE: army_supply(k) = 0
			END IF
		NEXT k
		FOR k = 1 TO MAX_CITIES: CALL city_update_occupier(k): NEXT k
		fleet_size(SIDE_UNION) = 10 * RND: IF fleet_size(SIDE_UNION) = 0 THEN fleet_city(SIDE_UNION) = 0
		fleet_size(SIDE_REBEL) = 10 * RND: IF fleet_size(SIDE_REBEL) > 0 THEN fleet_city(SIDE_REBEL) = 27
		FOR i = SIDE_UNION TO SIDE_REBEL
			fleet_ships$(i) = ""
			FOR j = 1 TO fleet_size(i)
			a$ = "W": IF RND > .45 * current_side THEN a$ = "I"
			fleet_ships$(i) = fleet_ships$(i) + a$
		NEXT j
		NEXT i
		IF RND > .7 THEN side_capital(SIDE_REBEL) = 25

		FOR k = 1 TO 40
		IF RND > .8 THEN leader_rating(k) = leader_rating(k) - 3 + 6 * RND: IF leader_rating(k) > MAX_LEADER_RATING THEN leader_rating(k) = MAX_LEADER_RATING
		IF leader_rating(k) < 1 THEN leader_rating(k) = 1
		NEXT k
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
		GOSUB unionplus
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
			CALL file_management(menu_choice + 1)
			IF menu_choice = 1 THEN turn_recruit_state = 0: turn_moves_done = 0: turn_navy_done = 0
			GOTO menu0
		CASE 3
			OPEN "O", 1, "cws.cfg"
			WRITE #1, current_side, opt_graphics, opt_sound, opt_difficulty, opt_players, opt_pause!, opt_event_balance, train_capacity(SIDE_UNION), train_capacity(SIDE_REBEL), opt_winter_campaigns, opt_realism, side_battles_won(SIDE_UNION), side_battles_won(SIDE_REBEL), side_casualties&(SIDE_UNION), side_casualties&(SIDE_REBEL), opt_history, opt_ai_aggression
			CLOSE #1
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
unionplus: union_income_bonus = 120 * opt_difficulty: IF opt_players = PLAYERS_TWO THEN union_income_bonus = 50 * opt_difficulty
	   IF opt_realism >= REALISM_ON THEN union_income_bonus = union_income_bonus * .7
	   RETURN
'............................................................................
blanken:        c = 1: IF current_side = SIDE_REBEL THEN c = 7
		CLS : LINE (100, 200)-(500, 300), c, BF
		LINE (100, 200)-(500, 300), 8 - c, B
		COLOR COLOR_GRAY: LOCATE 14, 31: PRINT " "; month_name$(turn_month); turn_year
		COLOR COLOR_LIGHT_CYAN: LOCATE 17, 30: PRINT side_name$(current_side); " PLAYER TURN"
		CALL script_mark_key_wait(1, "T"): DO WHILE INKEY$ = "": LOOP
		RETURN
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
' $INCLUDE: 'rules/turn.bm'
' $INCLUDE: 'rules/victory.bm'
' $INCLUDE: 'ai/ai.bm'
' $INCLUDE: 'ui/menu.bm'
' $INCLUDE: 'ui/orders.bm'
' $INCLUDE: 'ui/reports.bm'
' $INCLUDE: 'ui/screen.bm'
' $INCLUDE: 'ui/messages.bm'
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
