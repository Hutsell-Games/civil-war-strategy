OPTION _EXPLICIT
DEFINT A-Z
' $INCLUDE: 'cws.bi'
DIM replay AS INTEGER: DIM message$: DIM main_menu_start AS INTEGER: DIM action AS INTEGER: DIM ended AS INTEGER
DIM new_game AS INTEGER: DIM month_over AS INTEGER

CALL script_mute
replay = 0
' Each game: the title, then the main menu until the game ends or a new one is asked for.
' main_menu_start, the row the main menu starts on, is kept from one game to the next.
DO
    CALL game_new
    IF event_file_error$ <> "" THEN PRINT event_file_error$: END
    CALL show_title(replay): replay = 1
    CALL script_start
    CALL menu_title
    IF menu_choice = TITLE_QUIT THEN CLS : END
    IF menu_choice = TITLE_RESUME THEN CLS : CALL menu_load_game ELSE CALL show_new_game
    new_game = 0
    DO
        CALL menu_main(main_menu_start)
        ended = 0
        SELECT CASE menu_choice
            CASE MAIN_TROOPS
                IF side_cash(current_side) < COST_RECRUIT OR turn_recruit_state < 0 THEN CALL turn_close_recruiting ELSE CALL menu_army_recruit((current_side)): main_menu_start = MENU_START + MAIN_MOVES
            CASE MAIN_MOVES
                CALL menu_army_move
                main_menu_start = MENU_START + MAIN_MOVES
            CASE MAIN_SHIPS
                IF turn_navy_done = 0 THEN CALL menu_navy_commands((current_side))
                main_menu_start = MENU_START + MAIN_RAILROAD
            CASE MAIN_RAILROAD
                CALL menu_main_railroad
            CASE MAIN_END_TURN
                CALL menu_main_end_turn(ended): IF ended = 0 THEN main_menu_start = MENU_START + MAIN_SHIPS
            CASE MAIN_INFORM
                CALL menu_main_inform: main_menu_start = MENU_START + MAIN_INFORM
            CASE MAIN_COMMANDS
                main_menu_start = MENU_START + MAIN_COMMANDS
                CALL menu_commands
            CASE MAIN_UTILITY
                main_menu_start = MENU_START + MAIN_UTILITY
                CALL menu_utility
            CASE MAIN_FILES
                main_menu_start = MENU_START + MAIN_FILES
                CALL menu_files(action)
                IF action = FILES_NEW_GAME THEN new_game = 1
                IF action = FILES_QUIT THEN END
            CASE MENU_END_TURN_KEY
                ended = 1
            CASE ELSE
                main_menu_start = MENU_START + MAIN_TROOPS
        END SELECT
        IF ended = 1 THEN
            CALL turn_reset_commands
            CALL turn_next_player(month_over)
            IF month_over = 0 THEN
                CALL draw_player_turn: CALL draw_map
            ELSE
                message$ = "--------> EVENTS FOR " + month_name$(turn_month) + " " + STR$(turn_year) + " --------"
                CALL scribe_message(message$, SHOW_HISTORY_ONLY)
                CALL turn_resolve
                CALL turn_collect_income
                main_menu_start = MENU_START + MAIN_TROOPS
                IF opt_players = PLAYERS_TWO THEN CALL draw_player_turn: CALL draw_map
                CALL check_victory_conditions
                IF game_over > 0 THEN new_game = 1
            END IF
        END IF
    LOOP UNTIL new_game = 1
LOOP
' The map's letters, for DRAW: A to Z (show_title reads them).
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
' $INCLUDE: 'rules/events.bm'
' $INCLUDE: 'rules/turn.bm'
' $INCLUDE: 'rules/victory.bm'
' $INCLUDE: 'ai/ai.bm'
' $INCLUDE: 'commands/army.bm'
' $INCLUDE: 'commands/city.bm'
' $INCLUDE: 'commands/navy.bm'
' $INCLUDE: 'commands/railroad.bm'
' $INCLUDE: 'ui/menu.bm'
' $INCLUDE: 'ui/main_menu.bm'
' $INCLUDE: 'ui/orders.bm'
' $INCLUDE: 'ui/files.bm'
' $INCLUDE: 'ui/options.bm'
' $INCLUDE: 'ui/reports.bm'
' $INCLUDE: 'ui/screen.bm'
' $INCLUDE: 'ui/messages.bm'
' $INCLUDE: 'ui/battle.bm'
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
' $INCLUDE: 'port/files.bm'
' $INCLUDE: 'port/qb64.bm'
' $INCLUDE: 'port/script.bm'
