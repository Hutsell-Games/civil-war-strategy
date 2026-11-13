# Constants

The bare numbers of the game on the `qb64rust` branch (commit `8c3b185`) that stand for a limit, a side, a
kind of behavior or a rule, with a proposed constant for each. This is the table that phase 3 of
`modernize-plan.md` works from. It works like `sub-names.md`: a name written in the "Your name" column
replaces Claude's.

"Uses" counts the places in `CWSTRAT.BAS`, `CWSTRAT1.BM`, `CWSTRAT2.BM` and `CWSMENU.BM` where the number
appears with that meaning. A count marked "about" comes from a search pattern and may miss a few.

Constants are written in upper case with a group prefix (decision 18). A constant replaces a number only
where the number has that meaning: `40` as the count of cities becomes `MAX_CITIES`, while `40` as a size
of 4,000 men stays `40`. So each replacement is read, not done by a blind search.

Names in the tables use the SUB names of today. Phase 2 has renamed the SUBs by the time phase 3 runs.

## 1. Sides and limits

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `0` | No side: a neutral city, no fleet raiding. | (read case by case) | `SIDE_NONE` | |
| `1`, `2` | The Union, the Rebels. | (read case by case) | `SIDE_UNION`, `SIDE_REBEL` | |
| `1 TO 2` | A loop over both sides. | 26 | `SIDE_UNION TO SIDE_REBEL` | |
| `3 - who` | The other side. | 60 | `other_side(side)`, a FUNCTION (answer 1) | |
| `40` | The number of cities. | 47 together with the next row; not yet split | `MAX_CITIES` | |
| `40` | The number of army slots. | | `MAX_ARMIES` | |
| `20`, `21` | The Union's last army slot and the Rebels' first. | 11 in loops | `ARMIES_PER_SIDE`, and `side_army_range` for the loops | |
| `< 21`, `> 20` | "This army is Union" or "is Rebel". | 33 | `army_side(army)`, a FUNCTION (answer 1) | |
| `6` | The roads a city can have. | about 20 | `MAX_ROADS` | |
| `10` | The most ships in a fleet. | about 8 | `MAX_FLEET_SHIPS` | |
| `2` | The highest fort level. | about 5 | `MAX_FORT` | |
| `10` | The highest supply level and experience. | about 6 | `MAX_SUPPLY`, `MAX_EXPERIENCE` | |
| `9` | The highest leader rating. | 2 | `MAX_LEADER_RATING` | |
| `19999` | The most money a side can hold. | 1 | `MAX_CASH` | |

## 2. Special values

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `navyloc() = 99` | The fleet is at sea, raiding commerce. | about 12 | `FLEET_AT_SEA` | |
| `matrix(c, 7) = 99` | The city is a port. Also written `> 90` and `< 99`. | 5 and about 10 | `PORT_SEA = 99` and `PORT_RIVER = 90`: phase 4 made the column `city_port_type()`, not `city_is_port` (`variable-names.md`, note 1). | |
| `armymove() = 0` | The army has no order. | (read case by case) | `ORDER_NONE` | |
| `armymove() = -1` | The army cannot be given an order this turn: it drilled, fortified, combined, was just raised or came by train. | 8 | `ORDER_BUSY` | |
| `armymove() = -2` | The army has moved or lost its order in this turn's update. | 2 | `ORDER_DONE` | |
| `choose = -1` | The player left the menu with Esc. | about 10 | `MENU_ESCAPED` | |
| `choose = 99` | The player pressed F7 in a plain menu (end the turn). | 1 set, read in the main module | `MENU_END_TURN_KEY` | |
| `choose = 21 + n` going in | Start the menu on option `n`. Written `choose = 23`. | 55 | `MENU_START + 2`, with `MENU_START = 21` | |
| `brray() = 999` | The army does not move this turn. | 3 | `MOVE_KEY_NONE` | |
| `icon(999, …)` | No city: draw nothing. | 1 | Deleted: the line above it already sends every city above 40 to `noshow`. | |

Tests by sign keep their numbers: `army_order() > 0` (the army has a city to move to) and `choose < 0` or
`< 1`. The `menu` mode that `newcity` uses returns a letter as a negative number, so `< 0` is not the same
test as `= MENU_ESCAPED`.

## 3. Map marks: the third argument of `icon`

| Number | What `icon` draws | Calls | Proposed | Your name |
|-------:|-------------------|------:|----------|-----------|
| 1 | The dotted white line of a move order, from a city to a city. | 5 | `MARK_MOVE_LINE` | |
| 2 | A yellow box around a city where men were recruited. | 1 | `MARK_RECRUIT` | |
| 3 | An explosion at a city, three times. | 2 | `MARK_EXPLOSION` | |
| 4 | Erase the army's box at a city and its move line. | 6 | `MARK_ERASE_ARMY` | |
| 5 | Erase a move line only. | 2 | `MARK_ERASE_LINE` | |
| 6 | Flash a white frame around a city. | 5 | `MARK_FLASH_FRAME` | |
| 7 | Save what is under the mark, then draw a white box. | 1 | `MARK_BOX` | |
| 8 | Put back what marks 7 and 9 saved. | 4 | `MARK_RESTORE` | |
| 9 | Save what is under the mark, then draw the red arrow pointer. | 5 | `MARK_POINTER` | |
| 11 | A dotted black line: a road between two cities. | 1 | `MARK_ROAD` | |

10 has no case and no caller.

## 4. Menu modes: the argument of `menu`

The mode says what `menu` shows beside the options while the player moves through them.

| Number | What `menu` does | Calls | Proposed | Your name |
|-------:|------------------|------:|----------|-----------|
| 0 | Nothing more. F3 redraws the map, F4 shows the force summary, F7 ends the turn. | 51 | `MENU_PLAIN` | |
| 1 | The options are cities: a white box marks the city. | 2 | `MENU_CITY_BOX` | |
| 2 | The options are cities: a pointer marks the city, and the army there is named with its size. | 2 | `MENU_CITY_ARMY` | |
| 3 | Returns the key itself: up, down, Enter, or a letter as a negative number. Used by `newcity`. | 1 | `MENU_RAW_KEYS` | |
| 4 | The options are armies: `armystat` shows the army's figures. | 1 | `MENU_ARMY_STATS` | |
| 5 | Prints an army's experience and the cash. No caller passes it. | 0 | Delete the case in phase 1. | |
| 6 | The options are armies: a pointer marks the army's city. | 2 | `MENU_ARMY_POINTER` | |
| 8 | The difficulty menu: shows a general's face for each level. | 1 | `MENU_FACES` | |
| 9 | The options are cities: a pointer marks the city. | 5 | `MENU_CITY_POINTER` | |

`wtype`, the kind of box: 0 no line, 1 a single line, 2 a double line. Every caller sets 2. Proposed:
`BOX_DOUBLE = 2`, and the cases for 0 and 1 stay until phase 9.

## 5. Other behavior codes

| Where | Numbers | Meaning | Proposed | Your name |
|-------|---------|---------|----------|-----------|
| `navy (who, chx)` | 0 | The player's Ships menu. | `NAVY_ASK`, until phase 9 gave the player's menu its own SUB. | |
| | 1 to 5 | The computer's action: build, attack a port, sail, raid commerce, invade. | `NAVY_BUILD`, `NAVY_ATTACK`, `NAVY_SAIL`, `NAVY_RAID`, `NAVY_INVADE` | |
| `scribe (a$, flag)` | 0, 1, 2 | Write to the history only; also show on the bottom line; also show in a box. | `SHOW_NOT`, `SHOW_LINE`, `SHOW_BOX` | `SHOW_HISTORY_ONLY` for 0 (user, 2026-11-12) |
| `filer (switch)` | 1, 2, 3 | New game, load, save. | None: phase 7 splits `filer` into three SUBs. | |
| `report (who)` | -1, 100 + side | Go straight to the force summary; to the battle summary. | None: phase 7 gives each report a SUB. | |
| `tinytrain`, `snapshot`, `animate` | 0, 1 | Erase or draw; save or restore; for `animate`, take the army's picture from its city first, or use the one taken already (not march or retreat: both pass 0). | `DRAW_ERASE = 0`, `DRAW_SHOW = 1`; `SNAP_SAVE = 0`, `SNAP_RESTORE = 1`; `ANIMATE_TAKE_PICTURE = 0`, `ANIMATE_PICTURE_TAKEN = 1` (user, 2026-11-11) | |
| `flags (who, w, a)` | `w` | An offset in pixels, or below 0 for a small flag at `-w`. | None in phase 3: the SUB is reworked in phase 8. | |
| `army_combine_add`'s `status` (phase 8) | 0, 1, 2 | The army does not join; it would make army 0 more than 125,000 men; it joins. | `COMBINE_SKIPPED`, `COMBINE_TOO_LARGE`, `COMBINE_JOINED` | |
| `army_buy_supply`'s `result` (phase 8) | -1, 0, 1 | The army is cut off under the Realism setting; the cash is not enough; supplies were bought. | `SUPPLY_CUT_OFF`, `SUPPLY_NO_CASH`, `SUPPLY_BOUGHT` | |
| `navy_blast`'s `result` (phase 8) | 0, 1, 2 | The city stands firm; it is the other side's capital and stays loyal; it turns neutral. | `BLAST_FIRM`, `BLAST_LOYAL`, `BLAST_NEUTRAL` | `BOMBARD_HOLDS`, `BOMBARD_CAPITAL_HOLDS`, `BOMBARD_TURNS_NEUTRAL` (user, 2026-11-12) |
| `menu_files`' `action` (phase 9) | 0, 1, 2 | Back to the main menu; a new game; the program ends. | `FILES_BACK`, `FILES_NEW_GAME`, `FILES_QUIT` | |
| `event_roll`'s `event` (phase 8) | 0 to 15 | No event; ironclads available; riots; English ships; mercenaries; a loan; cotton sales; the uprising; Union shipworks; volunteers; the Emancipation Proclamation; Lincoln reelected; donations; Rebel deserters; repeating rifles; Stanton's prediction. | `EVENT_NONE`, `EVENT_IRONCLADS`, `EVENT_RIOTS`, `EVENT_ENGLISH_SHIPS`, `EVENT_MERCENARIES`, `EVENT_LOAN`, `EVENT_COTTON`, `EVENT_UPRISING`, `EVENT_SHIPWORKS`, `EVENT_VOLUNTEERS`, `EVENT_EMANCIPATION`, `EVENT_REELECTION`, `EVENT_DONATIONS`, `EVENT_DESERTERS`, `EVENT_RIFLES`, `EVENT_STANTON` | |

## 6. Settings and victory rules

| Variable | Numbers | Meaning | Proposed | Your name |
|----------|---------|---------|----------|-----------|
| `graf` | 0, 1, 2, 3 | Off; basic; city names; full, with pictures. | `GRAPHICS_OFF`, `GRAPHICS_BASIC`, `GRAPHICS_NAMES`, `GRAPHICS_FULL` | |
| `noise` | 0, 1, 2 | Off; effects; effects and music. | `SOUND_OFF`, `SOUND_EFFECTS`, `SOUND_MUSIC` | |
| `realism` | 0, 1, 2 | Off; on; on, and the computer is more careful. | `REALISM_OFF`, `REALISM_ON`, `REALISM_HIGH` | |
| `player` | 1, 2 | One player against the computer; two players. | `PLAYERS_ONE`, `PLAYERS_TWO` | |
| `vicflag(1)` to `(6)` | 1 to 6 | Month and year of the time limit, cities, income, capital, force ratio. 43 uses. | `VICTORY_MONTH`, `VICTORY_YEAR`, `VICTORY_CITIES`, `VICTORY_INCOME`, `VICTORY_CAPITAL`, `VICTORY_FORCE_RATIO` | |

`graf`, `noise` and `realism` are compared with a number in 79 places, often as `> 0` or `> 2`.
`graf > 2` becomes `graf >= GRAPHICS_FULL`: the same test, written with the level it means.

## 7. Rule numbers

These are the Civil War's own numbers. Phase 3 names them in `CWS14.BI`; phase 11 moves them to `game\`
(decision 19).

| Number | Meaning | Uses | Proposed | Your name |
|--------|---------|-----:|----------|-----------|
| `100` | The price of raising an army or adding men. | about 12 | `COST_RECRUIT` | |
| `100` | The price of a wooden ship; an ironclad costs twice that. | 1 | `COST_SHIP` | |
| `200` | The price of a fort level. | 5 | `COST_FORT` | |
| `500` | The price of moving the capital. | 2 | `COST_MOVE_CAPITAL` | |
| `100` | The income a side gets for holding its capital. | 2 | `CAPITAL_INCOME` | |
| `1861` | The first year. | 3 | `FIRST_YEAR` | |
| `1862`, month 3 | When ironclads can be built. | 3 | `IRONCLAD_YEAR`, `IRONCLAD_MONTH` | |
| `65` | The smallest army that can detach a part. | 1 | `MIN_DETACH_SIZE` | |
| `5` | The supply level that Resupply fills to. | 2 | `RESUPPLY_LEVEL` | |

Not named in phase 3: the factors inside the formulas of `battle`, `evaluate`, `smarts` and `events`
(`.3 * armylead(attack)`, `IF RND > .9`). Each is used once and its line says what it does. They are looked
at again in phase 8, when the rule SUBs are split out.

## 8. Colors

`COLOR n` appears 171 times with 15 values. The most used: 11 light cyan (57, messages), 14 yellow (32),
15 white (23), 7 gray (11), 12 light red (11). The drawing statements (`LINE`, `PSET`, `CIRCLE`, `PAINT`,
`DRAW`) carry about 1,000 more color numbers.

Settled (answer 2): constants for the 16 colors, `COLOR_BLACK` to `COLOR_WHITE`, used in the `COLOR`
statements and in the menu variables (`colour`, `hilite`). The pictures (`cannon`, `schooner`, `usa` and
the like) keep their numbers: there a number is a pixel's color in a drawing, and phase 11 turns the map's
lines into data anyway.

## 9. Keys and pauses

| Number or text | Meaning | Uses | Proposed | Your name |
|----------------|---------|-----:|----------|-----------|
| `ASC(a$) = 13`, `= 27` | Enter, Esc. | about 12 | `KEY_ENTER`, `KEY_ESC` | |
| `"H"`, `"P"`, `"I"`, `"Q"` after a 0 byte | Up, Down, Page Up, Page Down. | 6 | `KEY_UP$`, `KEY_DOWN$`, `KEY_PAGE_UP$`, `KEY_PAGE_DOWN$` | |
| `"="`, `">"`, `"A"` after a 0 byte | F3, F4, F7. | 3 | `KEY_F3$`, `KEY_F4$`, `KEY_F7$` | |
| `TICK 9` | A long pause that a key ends. | 13 | `PAUSE_LONG` | |
| `TICK 99` | Wait for a key. | 2 | Goes away in phase 7, with `wait_key` (`sub-names.md`, "Waiting for a key"). Phase 3 left it: outside a script, `TICK 99` gives up after 99 seconds, which the key loops do not. | |
| `tlx = 67` | The column of the right panel, where most menus go. | 22 | `PANEL_COL` | |

## Answers (user, 2026-11-11)

1. **The other side, and an army's side: two FUNCTIONs.** `3 - who` (60 places) becomes
   `other_side(side)`, and `attack > 20` (33 places) becomes `army_side(attacker) = SIDE_REBEL`. A FUNCTION
   call draws no random number and no pixel, so the screens stay identical. Another war that does not
   split its armies 20 and 20 then changes one FUNCTION.
2. **Colors: the 16 are named and used in text only.** `COLOR_BLACK` to `COLOR_WHITE` go into the `COLOR`
   statements and the menu's color variables. The pictures keep their numbers.
3. **Phase 3 does all nine groups**, each group as its own commit.
4. **The proposed names are taken as they stand.** No name in the "Your name" column (user, 2026-11-11).
