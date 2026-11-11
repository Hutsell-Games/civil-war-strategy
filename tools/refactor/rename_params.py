#!/usr/bin/env python3
"""Rename SUB and FUNCTION parameters, SUB by SUB (phase 4 of docs/modernize-plan.md).

    python tools/refactor/rename_params.py report
    python tools/refactor/rename_params.py apply

PARAMS maps a SUB's current name to {old parameter: new parameter}. Inside that SUB every token of the old
name is renamed (the header and the body); other SUBs are untouched, so the same old name can mean different
things elsewhere. A new name that already occurs in the SUB is reported as a clash and stops `apply`.
Strings, comments, REM and DATA are left alone (tokens come from rename_vars.py).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

PARAMS = {
    # who -> side
    "navy_remove_ship": {"who": "side"},
    "army_combine": {"who": "side"},
    "city_is_connected": {"who": "side", "target": "city"},
    "navy_commands": {"who": "side", "chx": "action"},
    "army_new": {"who": "side", "empty": "slot", "target": "city"},
    "railroad_move": {"who": "side"},
    "menu_army_recruit": {"who": "side"},
    "draw_fleet_ship": {"who": "side"},
    "draw_train": {"who": "side", "flag": "show"},
    "army_get_commander": {"who": "side", "empty": "slot"},
    "draw_flag": {"who": "side"},
    "menu_army_relieve": {"who": "side"},
    "menu_report": {"who": "side"},
    "draw_ship_icon": {"who": "side", "flag": "ship_type"},
    "side_army_range": {"who": "side"},
    "draw_stack_markers": {"who": "side"},
    "draw_surrender": {"who": "side"},
    "railroad_capacity": {"who": "side"},
    # an army or a city
    "animate_army": {"index": "army", "flag": "background_saved"},
    "draw_army_stats": {"index": "army"},
    "print_army_size": {"index": "army"},
    "army_resupply": {"index": "army"},
    "ai_evaluate_move": {"index": "army"},
    "menu_army_select": {"index": "army", "target": "city"},
    "menu_city_select": {"index": "city"},
    "menu_city_fortify": {"target": "city"},
    "draw_army_flag": {"which": "army"},
    "animate_city": {"which": "city"},
    "army_generate_name": {"target": "army", "a$": "name$"},
    # battle
    "calculate_battle": {"attack": "attacker", "defend": "defender", "win": "winner", "lose": "loser"},
    "menu_army_retreat": {"defend": "defender"},
    # others
    "draw_map_marker": {"from": "from_city", "dest": "to_city", "kind": "mark"},
    "menu_select": {"switch": "menu_item_show_beside"},
    "file_management": {"switch": "job"},
    "draw_flag_icon": {"z": "side"},
    "city_capture": {"s": "side", "flag": "weaken_fort"},
    "show_message_box": {"s": "seconds", "a$": "text$"},
    "print_centered": {"a$": "text$"},
    "scribe_message": {"a$": "text$", "flag": "display"},
    "screen_snapshot": {"flag": "put_back"},
    "wait_seconds": {"sec!": "seconds!"},
    "script_tick%": {"sec!": "seconds!"},
}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    done = set()
    clashes = []
    out = {}
    for f in rv.FILES:
        path = rv.ROOT / f
        if not path.exists():
            continue
        lines = path.read_bytes().decode("latin-1").split("\n")
        for name, first, last in rv.split_scopes(lines):
            if name is None or name.lower() not in PARAMS:
                continue
            table = {rv.key_of(o): n for o, n in PARAMS[name.lower()].items()}
            present = set()
            for i in range(first, last + 1):
                present.update(rv.key_of(t[2]) for t in rv.tokens(lines[i]))
            bad = [n for n in table.values() if rv.key_of(n) in present]
            missing = [o for o in table if o not in present]
            if bad:
                clashes.append((f, name, bad))
            if missing:
                clashes.append((f, name, ["old name not found: " + ",".join(missing)]))
            for i in range(first, last + 1):
                lines[i] = rv.rename_line(lines[i], table, set(), {"count": {}, "shadowed": [], "label_or_sub": []}, "")
            done.add(name.lower())
        out[path] = "\n".join(lines)
    for f, name, bad in clashes:
        print(f"PROBLEM {f} {name}: {bad}")
    print("SUBs not found:", sorted(set(PARAMS) - done))
    print(len(done), "SUBs renamed")
    if mode == "report":
        return 0
    if clashes or set(PARAMS) - done:
        print("refusing to apply")
        return 1
    for path, text in out.items():
        path.write_bytes(text.encode("latin-1"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
