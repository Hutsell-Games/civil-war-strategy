' ===========================================================================
' FOLDERS.BI - the folders that hold the game's data files, relative to the
' folder the game runs in.
' Included by cws.bi. The forward slash works on Windows too.
' ===========================================================================
CONST GFXDIR = "graphics/" ' pictures (.PNG): the icon, the mountains, the faces and the forts
CONST SCNDIR = "scenarios/" ' the special events (EVENTS.DAT), the list of scenarios (SCENARIOS.LST), and a folder for each scenario
' Each scenario's folder holds its map (CITIES.GRD), its setup (CWS.INI) and its leaders (CWSLEAD.DAT).
' SCENARIOS.LST has a line for each: its folder and its title, in quotes and parted by a comma. The
' first line is the scenario a game starts on.

' The files the game keeps in the folder it runs in.
CONST SETTINGS_FILE = "CWS.CFG" ' the settings and the battle totals (config_read, config_write)
CONST HALL_OF_FAME_FILE = "HISCORE.CWS" ' the Hall of Fame (hall_of_fame_load, hall_of_fame_save)
CONST HISTORY_FILE = "cws.his" ' the game's history, when History is on (history_start)
CONST OLD_HISTORY_FILE = "oldhist.ory" ' the history of the game before (history_start)
CONST BATTLE_SUMMARY_FILE = "battsumm" ' both sides' battle totals, when History is on (save_battle_summary)
CONST SAVE_FILE_PREFIX = "cws" ' a save slot's file is the prefix, the slot's number and the suffix:
CONST SAVE_FILE_SUFFIX = ".sav" ' cws1.sav to cws9.sav (save_file_name$)
