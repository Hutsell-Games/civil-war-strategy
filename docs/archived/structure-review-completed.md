# Done: the review of the structure of the game's code

The finished parts of `structure-review.md`, moved here on 2026-11-13, under the same headings. The
review keeps its findings, what is left to do and the questions still open.

## Already done

**Step 1 of the `ai\ai.bm` plan**, in the working tree on 2026-11-13, not committed. Six procedures read
names in place of repeated lookups. In `ai_evaluate_move`, `city_nearby_enemy_strength` and `ai_railroad`,
`current_side` is the player, so the local `enemy_side` says so. `own_side` replaces
`other_side(current_side)`. `ai_pick_port` gets `enemy_side` for `other_side(side)`. The 40 scripts
passed `play.py check` and `play.py compare` on unchanged recordings, and the 152 unit tests passed.

Two of step 1's names were taken back after item 2 (user, 2026-11-13). `army_troops` in
`ai_evaluate_move` only renamed `army_size(army)`, made the odds lines lopsided beside
`army_size(occupant)`, and shared its name with `ai_army_order`'s local of another use. `port` and
`port_owner` in `ai_fleet_orders` and `ai_navy_attack` hid two tests of `fleet_city()` from item 2's
rewrite; those now read `fleet_is_at_sea(side)` and `NOT fleet_exists(side)`. With `own_side` in place,
`ai_evaluate_move`'s `enemy_bound` read wrong: its loop walks the computer's own armies, so it is
`ally_bound` now. Step 1 also brought out a kept bug, the test for crossing moves (`TODO.md`).

**Item 1 of the recommendation, the layer check**, in the working tree on 2026-11-13, not committed.
`tests\test_layers.py` reads the source and fails when `rules\` or `ai\` uses the screen, the speaker or
the keyboard, when `rules\` calls into `ui\`, `draw\`, `game\` or `commands\`, when `ai\` calls into them
other than `ui\ai.bm` and `commands\`, or when `commands\` opens a menu or reads a key. It runs with the
other Python tests. Five calls break a rule today and are listed in its `ALLOWED`, each with its reason:

- `army_list_combine_cities` and `army_recruit_cities` (`rules\army.bm`) call `menu_bubble_sort`
  (`ui\menu.bm`), which sorts the menu's arrays and draws nothing (cause 2).
- `ai_navy_adjust` calls `menu_navy_items` (`ui\orders.bm`), which fills the Ships menu's texts (cause 2).
- `ai_recruit` calls `menu_recruit_cities` (`ui\orders.bm`), which sets the `COLOR` that `draw_ai_funds`
  prints in.
- `ai_fortify` calls `draw_fort_built` (`ui\orders.bm`), the fort's message shared with the player's
  Fortify.

A row whose call is gone fails the test too, so the list cannot go stale.

**Item 2, the state predicates**, in the working tree on 2026-11-13, not committed. Five FUNCTIONs name
what the arrays hold. Each gives -1 or 0, as the comparison it replaces, so `AND` and `OR` work as before:

| FUNCTION | File | Replaces |
|----------|------|----------|
| `army_exists(army)` | `rules\army.bm` | `army_city() > 0`; with `NOT`, `= 0` and `< 1` |
| `army_has_move(army)` | `rules\army.bm` | `army_order() > 0`; with `NOT`, `< 1` |
| `army_has_acted(army)` | `rules\army.bm` | `army_order() < 0`; with `NOT`, `> -1` |
| `fleet_exists(side)` | `rules\navy.bm` | `fleet_city() > 0`; with `NOT`, `= 0`, `< 1` and `<= 0` |
| `fleet_is_at_sea(side)` | `rules\navy.bm` | `= FLEET_AT_SEA`; with `NOT`, `<> FLEET_AT_SEA`, `< 41` and `<= MAX_CITIES` |

A script rewrote 70 comparisons on 64 lines in 14 files, and one more by hand in `ui\reports.bm`. It left
assignments alone, such as `fleet_city(side) = 0`. It also left the tests of city numbers (30, 27, 24),
which are item 6. The rewrite is the same only while neither array is negative. Nothing sets a negative
value: the train sets `army_city()` from an order that is a city. Both compilers read `NOT f(x) AND y` as
`(NOT f(x)) AND y` (checked with a small program). Every changed line runs under the tests
(`play.py coverage`). `TestArmyStateByName` and `TestFleetStateByName` in `tests\rules_test.bas` pin the
values. The 40 scripts passed `check` and `compare` on unchanged recordings, and the 154 unit tests
passed.

For phase 11's list of what QB64 made awkward: the FUNCTION was first named `fleet_at_sea`, and neither
compiler accepted it. Names ignore case, so it is the same name as the constant `FLEET_AT_SEA`.

**Item 5, one SUB for both sides**, in the working tree on 2026-11-13, not committed.
`turn_update_victory_points (side)` (`rules\turn.bm`) does one side's month; `turn_resolve` (`ui\turn.bm`)
and the unit test call it for the Union, then the Rebels. The two halves differed in one line: only the
Union's points stop at 0. That line is kept behind `side = SIDE_UNION`, and `TODO.md` has a row for it.
A new unit test, `TestOnlyUnionVictoryPointsStopAtZero`, pins it and the strength ratio. The 40 scripts
passed `check` and `compare` on unchanged recordings, and the 158 unit tests passed.

**Item 3, SUBs that return one value**, in the working tree on 2026-11-13, not committed. 76 SUBs assign
to a parameter, and 55 to exactly one. Four became FUNCTIONs: `ai_fortify_pick (side)`,
`normal_random_number (mean, variance)`, `turn_retreat_city (city, attacker_side)` and
`text_replace$ (text$, find$, with$)`. Each only picks, draws a number or builds a text.
The others stay SUBs, for these reasons:

- Most change the game as their main work (buy supply, bombard, move a fleet, set an order) and return
  only a flag such as `again`, `raised` or `sailed`. A FUNCTION would hide that work.
- The menus draw and read keys.
- `ai_navy` leaves `action` as it was when no rule applies, so it is an input too.
- `victory_rule_met` also gives 300 victory points, and `army_pick_commander` also writes a made-up name.
- `ai_evaluate_move` keeps its scores in `menu_value()`, so it waits for item 4.

`TestTextReplaceEveryPlace` is new. The 40 scripts passed `check` and `compare` on unchanged
recordings, and the 159 unit tests passed.

**Item 4, the menu's globals out of `rules\` and `ai\`**, in the working tree on 2026-11-13, not
committed. Neither folder names a menu variable any more, and `tests\test_layers.py` checks it
(`test_rules_and_ai_leave_the_menu_alone`). Four rows of its `ALLOWED` are gone; `ai_fortify`'s call
of `draw_fort_built` is the one left.

- **Lists.** `army_list_combine_cities`, `army_recruit_cities`, `navy_list_shipyards` and
  `navy_list_ports` fill an array the caller passes, with a count. `city_list_sort` (`rules\city.bm`)
  sorts by name as `menu_bubble_sort` did, so the lists keep their order. The player's menus copy a
  list into the menu with `menu_set_cities` (`ui\menu.bm`), and set the menu's place and colors
  that the rules set before.
- **Picks.** `ai_recruit_pick` and `ai_pick_port` are FUNCTIONs that give a city. `ai_navy_orders`
  chooses by its `action`, not `menu_choice`. `ai_army_order` lost a line that never ran.
- **Scores.** `ai_evaluate_move` keeps its scores in a local `road_score()`.
- **Invasion.** `navy_can_invade` (`rules\navy.bm`) is the test that the Ships menu and
  `ai_navy_adjust` share. The computer filled the Ships menu to read its row count.
- **The computer's screen.** `draw_ai_funds` takes the list's count. `draw_ai_recruit_color`
  (`ui\ai.bm`) sets the color the player's list set for the computer before.

What the computer left in the menu's variables could change no screen. The menus that open in its
turn, Retreat and End Game, set their own place and colors. The values it left in `menu_choice` give
row 1, as the player's End Turn does. One read was a bug: `ai_pick_port` set the row to 30, and
`menu_value(30)` was always 0, so the fleet stayed in port. It returns 0 now (`TODO.md`). The 40
scripts passed `check` and `compare` on unchanged recordings, the 161 unit tests passed, and every
changed line runs under the tests.

## The second review: one idea written in several places

### Done, keeping every screen

In the working tree on 2026-11-13, not committed. Each part passed the unit tests and the 40 scripts'
`check` on unchanged recordings.

1. **The Balance setting's help for the computer.** `balance_help (side)` (`rules\setup.bm`) is how
   many steps the setting helps the computer's side. The extra recruits are 5 times it, the attack and
   the defense in battle 2 times it, and the starting cash 100 times 3 more than it. The four places
   wrote the same test and formula each in its own way. `TestBalanceHelpGoesToTheComputer` pins it.
2. **A slot takes a free leader.** `army_appoint (army, leader)` (`rules\army.bm`) replaces the same
   three lines in `army_raise`, `army_detach`, `event_new_army` and `load_scenario_armies`, and in
   `army_take_leader`. `army_combine_absorb` calls `army_free_leader`. `TestArmyAppointAndFreeLeader`.
3. **The other two side palettes.** `side_bright_color` (light blue and white: the trains, the army
   report's heading, the computer's turn) and `side_panel_color` (blue and gray: the player's turn,
   victory, surrender), in `game\colors.bm`. They replace 7 places that wrote the numbers.
4. **The ship letters.** `SHIP_WOODEN$` and `SHIP_IRONCLAD$` (`cws.bi`), `ship_cost` (`rules\navy.bm`)
   and `ship_icon` (`draw\ships.bm`). The tests keep the letters as data. `TestShipKinds`.
5. **The fleet is gone.** `navy_clear_fleet` (`rules\navy.bm`) clears the ships, their count and the
   port, for `navy_remove_ship`, `navy_fleet_lost`, `navy_fleet_defeated` and `ai_fleet_orders`. No
   place left the count and the list disagreeing. `navy_cancel_new_fleet` keeps `fleet_city()` on
   purpose: `ai_fleet_orders` sets city 30 for the computer's first Union ship before it is built, and
   `ai_raise_forces` reads it after. `TestNavyClearFleet`.
6. **The flag's place beside a city.** `flag_x`, `flag_y`, `draw_erase_flag`, `flag_picture_save` and
   `flag_picture_restore` (`draw\icons.bm`) replace six places that worked it out. Two were in
   `commands\` (`army_recruit`, `railroad_arrive`), which no longer draw pixels themselves.

## Questions for the user

2. **The kept bugs:** rule on `TODO.md`'s "The game" rows in one batch now, or leave them until after
   this work? The merge of the player's and the computer's commands waits on that. Answered 2026-11-13
   (user): now. All but three are fixed (`TODO.md`, "The game").
