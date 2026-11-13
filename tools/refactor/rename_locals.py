#!/usr/bin/env python3
"""Rename local variables and parameters, SUB by SUB (part 1a of docs/local-names.md).

    python tools/refactor/rename_locals.py report
    python tools/refactor/rename_locals.py apply

LOCALS maps a SUB's name to {old name: new name}. Inside that SUB every token of the old name is
renamed: the header, the DIM lines and the body. Other SUBs are untouched, so the same old name can
mean something else elsewhere. A new name that already occurs in the SUB, or an old name that does
not occur, is reported and stops `apply`. Strings, comments, REM and DATA are left alone, and so are
labels (tokens and scopes come from rename_vars.py). It works like rename_params.py, on the files as
they are named since phase 9.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

FILES = sorted(
    p.relative_to(rv.ROOT).as_posix()
    for p in rv.ROOT.rglob("*")
    if p.suffix.lower() in (".bas", ".bm", ".bi")
    and p.relative_to(rv.ROOT).parts[0] not in (".git", "tests", "tools")
) + ["tests/rules_test.bas"]

FIRST_LAST = {"star": "first_army", "fin": "last_army"}
WHO = {"who": "side"}
INDEX = {"index": "army"}
ACTIVE = {"active": "moving_army"}
VICTORY = {"x": "union_men", "y": "rebel_men"}


def merge(*tables):
    out = {}
    for t in tables:
        out.update(t)
    return out


LOCALS = {
    # ai/ai.bm
    "ai_resupply": merge(WHO, FIRST_LAST),
    "ai_fortify": WHO,
    "ai_fortify_pick": merge(WHO, FIRST_LAST, {"defend": "enemy_strength"}),
    "ai_raise_forces": WHO,
    "ai_count_armies": merge(WHO, FIRST_LAST),
    "ai_fleet_orders": WHO,
    "ai_army_orders": merge(WHO, FIRST_LAST, {"c": "text_color"}),
    "ai_army_order": merge(WHO, {"defend": "enemy_strength"}),
    "ai_drill": merge(WHO, FIRST_LAST),
    "ai_evaluate_move": {"defend": "enemy_strength", "from": "from_city"},
    "ai_recruit_pick": {"a": "friendly_neighbors"},
    "ai_railroad": {"defend": "enemy_strength", "limit": "capacity"},
    # commands/
    "army_combine_gather": FIRST_LAST,
    "army_recruit": {"from": "from_city"},
    "city_capture": ACTIVE,
    "navy_ship_joins": {"a": "ship_type"},
    "navy_fleet_founded": {"a": "ship_type"},
    "navy_bombard": INDEX,
    "navy_commerce_raid": {"a": "ship_type"},
    "navy_combat_begin": {"hit": "hits"},
    "navy_combat_volley": {"hit": "hits", "over": "combat_over"},
    "navy_combat_auto": {"hit": "hits", "over": "combat_over"},
    "navy_show_hits": {"hit": "hits"},
    "railroad_start": {"from": "from_city"},
    "railroad_arrive": INDEX,
    # draw/
    "animate_army": {"from": "from_city"},
    "animate_city": {"c": "dot_color"},
    "draw_army_flag": WHO,
    "draw_train": {"c": "side_color"},
    "draw_cities": {"c": "dot_color"},
    "draw_city_dot": {"c": "dot_color"},
    "draw_fleets": {"s": "side", "a": "ship_type"},
    "draw_fleet_ship": {"a": "ship_type"},
    # game/
    "event_roll": INDEX,
    "event_riot_city": WHO,
    "draw_surrender": {"c": "side_color"},
    # port/
    "load_game": merge(WHO, FIRST_LAST),
    "hall_of_fame_load": {"s": "side"},
    "hall_of_fame_save": {"s": "side"},
    # rules/
    "army_raise": {"a": "friendly_neighbors"},
    "army_pick_commander": FIRST_LAST,
    "army_buy_supply": merge(WHO, {"a": "friendly_neighbors"}),
    "army_list_combine_cities": FIRST_LAST,
    "army_add_recruits": {"a": "friendly_neighbors"},
    "army_recruit_cities": {"pct!": "chance!"},
    "battle_apply_losses": {"s": "side"},
    "city_is_connected": {"a": "friendly_neighbors"},
    "railroad_board": {"from": "from_city"},
    "railroad_unload": INDEX,
    "railroad_capacity": {"limit": "capacity"},
    "turn_army_supply": {"s": "side", "a": "friendly_neighbors"},
    "turn_army_lost": {"s": "side"},
    "victory_forces": VICTORY,
    "victory_rule_met": merge(VICTORY, {"i": "side", "j": "rule"}),
    "victory_near_cities": {"i": "side"},
    "victory_near_income": {"i": "side"},
    "victory_near_force": merge(VICTORY, {"i": "side"}),
    "victory_play_on": {"j": "rule"},
    "victory_won": {"i": "side", "j": "rule"},
    "hall_of_fame_place": {"s": "side"},
    "hall_of_fame_insert": {"s": "side"},
    # ui/
    "draw_ai_plan": {"c": "text_color"},
    "calculate_battle": {"c": "side_color"},
    "event_riot": WHO,
    "menu_main_inform": FIRST_LAST,
    "menu_main_railroad": {"limit": "capacity"},
    "draw_menu": {"b1": "title_col", "wide": "menu_width", "boxc": "box_color"},
    "menu_select": {"b1": "title_col", "wide": "menu_width", "boxc": "box_color"},
    "menu_arrow_key": {"b1": "title_col", "wide": "menu_width"},
    "menu_mark_row": {"wide": "menu_width"},
    "menu_measure_width": {"wide": "menu_width"},
    "show_message_box": {"wide": "menu_width"},
    "menu_navy_combat": {"hit": "hits", "over": "combat_over"},
    "menu_army_move": INDEX,
    "menu_city_fortify": WHO,
    "menu_army_select": merge(WHO, FIRST_LAST),
    "menu_army_cancel": merge(FIRST_LAST, INDEX),
    "menu_army_relieve": merge(FIRST_LAST, INDEX),
    "menu_army_retreat": WHO,
    "menu_supply": merge(FIRST_LAST, {"a": "friendly_neighbors"}),
    "menu_railroad": {"limit": "capacity"},
    "menu_army_detach": INDEX,
    "menu_army_drill": INDEX,
    "report_armies": merge(FIRST_LAST, {"c": "side_color"}),
    "report_intelligence": merge(FIRST_LAST, {"c": "side_color"}),
    "report_force_summary": {"c": "side_color"},
    "draw_train_box": {"c": "side_color"},
    "draw_top_bar": {"c": "side_color"},
    "draw_player_turn": {"c": "side_color"},
    "turn_resolve": ACTIVE,
    "turn_move_army": merge(ACTIVE, {"s": "side"}),
    "turn_attack": merge(ACTIVE, {"defend": "defender"}),
    "turn_attacker_withdraws": merge(ACTIVE, {"defend": "defender"}),
    "turn_defender_retreats": merge(ACTIVE, {"defend": "defender"}),
    "turn_army_surrenders": merge(ACTIVE, INDEX),
    "turn_enter_city": merge(ACTIVE, {"s": "side"}),
    "ai_turn": {"c": "side_color"},
    "hall_of_fame": {"s": "side"},
    "check_victory_conditions": merge(VICTORY, {"i": "side", "j": "rule"}),
    "victory_warnings": merge(VICTORY, {"i": "side"}),
    "end_game": {"i": "side", "j": "rule", "c": "side_color"},
}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    done = set()
    problems = []
    out = {}
    total = 0
    for f in FILES:
        path = rv.ROOT / f
        lines = path.read_bytes().decode("latin-1").split("\n")
        changed = False
        for name, first, last in rv.split_scopes(lines):
            if name is None or name.lower() not in LOCALS:
                continue
            table = {rv.key_of(o): n for o, n in LOCALS[name.lower()].items()}
            present = set()
            for i in range(first, last + 1):
                present.update(rv.key_of(t[2]) for t in rv.tokens(lines[i]))
            bad = [n for n in table.values() if rv.key_of(n) in present]
            missing = [o for o in table if o not in present]
            if bad:
                problems.append((f, name, "new name already used: " + ", ".join(bad)))
            if missing:
                problems.append((f, name, "old name not found: " + ", ".join(missing)))
            stats = {"count": {}, "shadowed": [], "label_or_sub": []}
            for i in range(first, last + 1):
                new = rv.rename_line(lines[i], table, set(), stats, f"{f}:{i + 1}")
                if new != lines[i]:
                    total += 1
                    lines[i] = new
                    changed = True
            for where in stats["label_or_sub"]:
                problems.append((f, name, "left alone as a label or a SUB name at " + where))
            done.add(name.lower())
        if changed:
            out[path] = "\n".join(lines)
    for f, name, what in problems:
        print(f"PROBLEM {f} {name}: {what}")
    print("SUBs not found:", sorted(set(LOCALS) - done))
    print(f"{len(done)} SUBs, {total} lines changed, {len(out)} files")
    if mode == "report":
        return 0
    if problems or set(LOCALS) - done:
        print("refusing to apply")
        return 1
    for path, text in out.items():
        path.write_bytes(text.encode("latin-1"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
