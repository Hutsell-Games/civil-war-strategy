# Introduction
Fairly detailed notes on the changes to the code base.

# Changes to Code
1. Update logic in another place that checks if saved games exist, see next entry for more details on why this is necessary.
    - Replace `IF _FILEEXISTS("*.sav") = 0 THEN choose = -1: EXIT SUB` with:
        ```vb
        FOR j = 1 to 9
            t$ = "cws" + LTRIM$(STR$(j)) + ".sav"
            IF _FILEEXISTS(t$) THEN 
                EXIT FOR
            ELSE
                choose = -1: EXIT SUB
            END IF
    	NEXT j
        ```
1. Update the logic for checking if saved games exist.
    - It seems that QB64 may have changed how `_FILEEXISTS` works. In the past passing in `*.sav` would treat `*` as a wildcard. This is no longer the case.
    - Replace `IF _FILEEXISTS("*.sav") = 0 THEN filel = 0` with:
        ```vb
        FOR j = 1 to 9
		    t$ = "cws" + LTRIM$(STR$(j)) + ".sav"
			IF _FILEEXISTS(t$) THEN 
				filel = 1: EXIT FOR
			ELSE
				filel = 0
			END IF
		NEXT j
        ```
1. Remove from touchup the following code that creates bleeds on the map: `PAINT (502, 160), 1, 10` and `PAINT (108, 400), 1, 10`
1. When calling cannon, replace `CIRCLE (x + 5, y), 29, 1, 4, 1.5, 1.4` with `CIRCLE (x + 5, y), 27, 1, 4, 1.5, 1.4`
1. When calling railroad from main menu, replace `DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U8L2U5R1BF4"` with `DRAW "C15S6R9D4R6U3R3D3R7U5H3U2R9D3G2D6F1D3F5L10D1G1L4H2L7G2L3H2L3U9L2U5R1BF4"` to fix bleed issue with train.
1. Remove non-existent SUB declarations: `banner`, `blastem`, `mountain`, `sndblst`,`sndfx`, `usamap`, and `war`.
1. Remove calls to external image files, they were 16-bit.
1. Remove old screensaver code, not needed.
1. Replace a number of old ASCII characters with modern substitutions. 
1. Replace `DIR$` with QB64 equivalent `_FILEEXISTS`, QB64 does not support the former.
1. Combine CWS14.BI, CWSMENU.BAS, CWSTRAT.BAS, and CWSTRAT2.BAS into CWSTRAT.BAS