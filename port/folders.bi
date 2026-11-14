' ===========================================================================
' FOLDERS.BI - the folders that hold the game's data files, relative to the
' folder the game runs in. The DOS game kept every file beside the program.
' Included by cws.bi. The forward slash works on Windows too.
' ===========================================================================
CONST GFXDIR = "graphics/" ' pictures (.VGA): the icon, the mountains, the faces and the forts
CONST SCNDIR = "scenarios/" ' the special events (EVENTS.DAT), the list of scenarios (SCENARIOS.LST), and a folder for each scenario
' Each scenario's folder holds its map (CITIES.GRD), its setup (CWS.INI) and its leaders (CWSLEAD.DAT).
' SCENARIOS.LST has a line for each: its folder and its title, in quotes and parted by a comma. The
' first line is the scenario a game starts on.
