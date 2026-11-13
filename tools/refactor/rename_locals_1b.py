#!/usr/bin/env python3
"""Rename the locals and parameters of part 1b of docs/local-names.md, SUB by SUB.

    python tools/refactor/rename_locals_1b.py report
    python tools/refactor/rename_locals_1b.py apply

It works like rename_locals.py (part 1a), with two additions:

- A name that holds two things in one SUB is split. Its entry is a list of (new name, first line,
  last line), with the line numbers of the file as it was at commit 7dc14c5. Each use of the old
  name on those lines gets that new name. The DIM of the old name becomes a DIM of each new name.
  A new name that is a parameter of the SUB gets no DIM. When the old name is a parameter itself,
  the DIMs of its other new names are added to the SUB's first DIM line.
- MODULE renames names in the main module of a file.

It was applied once, on 2026-11-12. Run again, it reports the old names as not found. After it,
these were edited by hand: the 14 DECLARE lines of cws.bas (deleted), `x` in army_pick_commander,
`turbo` in menu_army_cancel, a dead line each in ai_evaluate_move and menu_railroad, and the
comments that used an old name.

A use of a split name outside its line ranges stops `apply`. So does a new name that is a shared
variable, a CONST, a SUB or a FUNCTION, or that the SUB already uses for something else.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

FILES = sorted(
    p.relative_to(rv.ROOT).as_posix()
    for p in rv.ROOT.rglob("*")
    if p.suffix.lower() in (".bas", ".bm", ".bi")
    and p.relative_to(rv.ROOT).parts[0] not in (".git", "tests", "tools")
)

SLOT = {"slot": "army_slot"}
TROOPS = {"union_men": "union_troops", "rebel_men": "rebel_troops"}

MODULE = {
    "cws.bas": {"chosit": "main_menu_start", "a$": "message$"},
}

LOCALS = {
    # ai/ai.bm
    "ai_fortify": {"target": "city", "x": "army"},
    "ai_fortify_pick": {"target": "city", "x": "candidate_city"},
    "ai_raise_forces": {"slush": "ship_reserve", "x": "army_count"},
    "ai_count_armies": {"x": "army_count", "y": "enemy_strength", "z": "own_strength"},
    "ai_army_order": {"target": "city", "x": "army_troops", "k": "neighbor", "flag": "neighbor_strength",
                      "best": "best_road", "y": "other_army"},
    "ai_evaluate_move": {
        "x": [("best_road", 177, 177), ("stay_weight", 181, 200), ("best_score", 256, 259), ("best_road", 263, 263)],
        "best": [("own_strength", 185, 200), ("best_road", 256, 263)],
        "max": "road_count", "a": "to_city", "c": "occupant", "m": "far_city", "y": "score", "x1": "fort_factor",
    },
    "city_nearby_enemy_strength": {"a": "city", "x": "neighbor", "m": "far_city", "y": "strength"},
    "ai_recruit_pick": {"x": [("army", 303, 307), ("best_score", 312, 324)], "target": "city", "y": "score"},
    "ai_railroad": {
        "max": "least_threat", "index": "spare_army", "target": "candidate_city", "x1": "to_city",
        "x": [("enemy_neighbors", 374, 376), ("routes", 379, 396)],
        "from": [("neighbor", 374, 374), ("from_city", 384, 391)],
    },
    "ai_pick_port": {"x": "enemy_ports", "target": "port"},
    "ai_navy_invade": SLOT,
    # commands/
    "army_new": SLOT,
    "army_get_commander": SLOT,
    "army_recruit": {"empty": "army_slot"},
    "city_capture": {"c": "city", "capital": "was_enemy_capital"},
    "navy_bombard": {"target": "city", "killd": "casualties"},
    "navy_land_army": {"c": "city", "slot": "army_slot"},
    "navy_combat_retreat": {"target": "port"},
    # draw/
    "animate_army": {"background_saved": "picture_taken", "to2": "to_city", "x1": "step_x", "y1": "step_y"},
    "draw_train": {"from": "city"},
    "draw_flag": {"w": "x_offset", "a": "top_y"},
    "draw_city_names": {"x": "letter", "a": "letter_x"},
    "draw_map": {"x": "letter"},
    "draw_stack_markers": {"target": "city"},
    "draw_fleet_ship": {"i": "ship"},
    "draw_fleet_sailing": {"a": "lead_ship"},
    # game/
    "event_roll": {
        "who": "event_side", "plus": "event_weight", "empty": "port",
        "pct!": [("chance!", 23, 24), ("share_kept!", 70, 76)],
        "x": [("new_ships", 48, 89), ("count", 94, 94)],
    },
    "event_riot_city": {"x": "candidate_city"},
    "draw_union_victory": {"x": "capitol_wing"},
    "draw_surrender": {"side": "army", "s": "side", "w": "panel_left"},
    # port/
    "load_scenario": {"a": "army_count"},
    "load_cities": {"a": "unused", "x": "owner"},
    "load_game": {"a": "saved_side", "myside": "config_side"},
    "save_game": {"myside": "config_side"},
    "dir$": {"f$": "found_file$"},
    "script_shell": {"sp": "space_at", "c$": "trimmed$", "d$": "contents$", "f": "file_num"},
    # rules/
    "army_combine_add": {"pct!": "share!"},
    "army_raise": {"x": "troops", "slot": "army_slot"},
    "army_pick_commander": {"a$": "generated_name$", "slot": "army_slot"},
    "army_buy_supply": {"x": "supply_added", "y": "new_supply"},
    "army_generate_name": {"x": "ones"},
    "army_detach": SLOT,
    "army_place_new": SLOT,
    "army_add_recruits": {"x": "troops"},
    "army_recruit_bonus": SLOT,
    "army_recruit_cities": {"max": "offer_count", "x": "city"},
    "battle_strengths": {"x": "attack_strength", "x1": "defend_strength", "r!": "size_ratio!"},
    "battle_fight": {"attack": "attack_strength", "defend": "defend_strength", "star": "attack_roll",
                     "fin": "defend_roll", "hit": "attacker_hit", "hit1": "defender_hit"},
    "battle_losses": {"pct!": "loss_rate!", "xbar": "mean", "vary": "variance"},
    "normal_random_number": {"xbar": "mean", "vary": "variance", "pct!": "sum!"},
    "city_is_connected": {"y": "neighbor"},
    "city_fix_return_routes": {"index": "neighbor"},
    "city_update_occupier": {"x": "city"},
    "navy_bombard_army": {"pct!": "loss_rate!", "x": "supply_loss"},
    "navy_shot_hits": {"pct!": "ironclad_bonus!", "a$": "ship$"},
    "railroad_route_count": {"x": "routes", "y": "neighbor", "z": "far_city"},
    "railroad_capacity": {"x": [("base_cities", 46, 47), ("max_capacity", 48, 50)]},
    "game_apply_settings": {"a$": "ships$"},
    "turn_strength_ratio": {"x": "rebel_strength", "y": "union_strength"},
    "turn_retreat_city": {"flee": "best_road", "x": "neighbor"},
    "turn_collect_income": {"x": "owner"},
    "victory_forces": TROOPS,
    "victory_rule_met": TROOPS,
    "victory_near_force": TROOPS,
    "hall_of_fame_insert": {"i": "place"},
    # ui/
    "draw_ai_fort": {"target": "city"},
    "draw_ai_plan": {"i": "army"},
    "draw_ai_drill": {"i": "army"},
    "calculate_battle": {
        "attack": "attack_strength", "defend": "defend_strength", "y": "col",
        "a": [("odds_pct", 46, 47), ("winner_side", 71, 72)],
        "k": [("fort_level", 54, 55), ("k", 64, 65)],
        "t$": [("file$", 55, 57), ("message$", 86, 88)],
    },
    "special_events": {"who": "event_side"},
    "event_riot": {"x": "city"},
    "menu_main_railroad": {"z": "side_color"},
    "menu_select": {"row1": "previous_row", "leave": "done", "a$": "pressed$", "c1$": "menu_initial_letter$",
                    "flag": "row_shown"},
    "menu_arrow_key": {"k$": "pressed$", "leave": "done"},
    "menu_mark_row": {"flag": "row_shown", "target": "army", "a": "face_pic",
                      "t$": [("short_name$", 185, 189), ("file$", 203, 205)]},
    "menu_measure_width": {"x": "menu_option_length"},
    "show_message_box": {"seconds": "box_color", "g2": "saved_screen"},
    "menu_army_move": {"target": "city"},
    "menu_city_fortify": {"x": "army"},
    "menu_city_select": {"a$": "letter$", "x": "tries", "y": "start_city"},
    "menu_army_cancel": {"target": "city", "x": "found_at"},
    "menu_army_relieve": {"t$": "old_name$", "a$": "new_name$"},
    "menu_army_retreat": {"x": "retreat_city", "y": "city"},
    "menu_supply": {"max": "name_width"},
    "menu_railroad": {"index": "chosen_army", "a": "chosen_city", "x": "routes", "target": "route_city",
                      "from": "from_city", "x1": "to_city"},
    "menu_army_detach": {"target": "city", "empty": "army_slot"},
    "menu_army_drill": {"target": "city"},
    "menu_navy_invade": SLOT,
    "menu_victory_conditions": {"chosit": "start_option"},
    "report_armies": {
        "x": [("total_points", 93, 97), ("percent", 101, 105), ("total_troops", 107, 120), ("ironclads", 123, 127)],
        "y": [("percent", 97, 98), ("all_income", 103, 105), ("row", 111, 116)],
    },
    "report_intelligence": {"z": "box_width"},
    "report_force_summary": {"summ": "city_troops"},
    "report_recap": {"x": "line_count"},
    "check_map_links": {"x": "unresolved", "y": "fixed"},
    "print_centered": {"y": "row", "x": "col"},
    "draw_top_bar": {"x": "total_points", "y": "percent"},
    "turn_move_army": {"target": "to_city"},
    "turn_attack": {"target": "city", "win": "winner", "lose": "loser"},
    "turn_attacker_withdraws": {"target": "city"},
    "turn_defender_retreats": {"target": "city", "s": "attacker_side", "flee": "chosen_city",
                               "move2": "retreat_city"},
    "turn_army_surrenders": {"x": "side"},
    "turn_enter_city": {"c": "city", "target": "to_city"},
    "ai_turn": {"who": "ai_side"},
    "hall_of_fame": {"a$": "commander$"},
    "check_victory_conditions": TROOPS,
    "victory_warnings": TROOPS,
}

NAME = re.compile(r"[A-Za-z_]")


def shared_names():
    """Keys of the shared variables, the CONSTs and the SUBs and FUNCTIONs."""
    names = set()
    for f in FILES:
        for line in (rv.ROOT / f).read_bytes().decode("latin-1").split("\n"):
            toks = rv.tokens(line)
            low = [t[2].lower() for t in toks]
            if not toks:
                continue
            if low[0] in ("sub", "function") and len(toks) > 1:
                names.add(rv.key_of(toks[1][2]))
            elif low[0] == "const" and len(toks) > 1:
                names.add(rv.key_of(toks[1][2]))
            elif "shared" in low[:3] and low[0] in ("common", "dim"):
                names.update(rv.key_of(n) for n in rv.header_names(toks[low.index("shared") + 1:]))
    return names


def new_names(table):
    out = []
    for new in table.values():
        out.extend(n for n, _, _ in new) if isinstance(new, list) else out.append(new)
    return out


def rename_token(line, picks):
    """Rename the name tokens of a line; picks maps a key to its new name on this line."""
    pieces = []
    toks = rv.tokens(line)
    for n, (s, e, tx) in enumerate(toks):
        if not NAME.match(tx) or rv.key_of(tx) not in picks:
            continue
        prev = toks[n - 1][2].lower() if n else None
        nxt = toks[n + 1][2] if n + 1 < len(toks) else None
        if prev in ("goto", "gosub", "resume", "sub", "function", "call") or (n == 0 and nxt == ":"):
            continue
        suffix = tx[-1] if tx[-1] in "$%&!#" else ""
        pieces.append((s, e, picks[rv.key_of(tx)].rstrip("$&!#") + suffix))
    for s, e, new in reversed(pieces):
        line = line[:s] + new + line[e:]
    return line


def expand_dim(line, old, names):
    """In a DIM line, the DIM of old becomes a DIM of each of names. Returns the line and whether
    old was declared there."""
    parts = line.split(":")
    found = False
    for n, part in enumerate(parts):
        toks = rv.tokens(part)
        if len(toks) >= 2 and toks[0][2].lower() == "dim" and rv.key_of(toks[1][2]) == old:
            found = True
            s, e = toks[1][0], toks[1][1]
            suffix = toks[1][2][-1] if toks[1][2][-1] in "$%&!#" else ""
            lead = " " if n else ""
            parts[n] = ": ".join(
                (lead if m == 0 else "") + (part[:s] + name.rstrip("$&!#") + suffix + part[e:]).strip()
                for m, name in enumerate(names)
            )
    return ":".join(parts), found


def rename_scope(lines, first, last, table, problems, where, shared, is_sub):
    table = {rv.key_of(o): n for o, n in table.items()}
    present = set()
    for i in range(first, last + 1):
        present.update(rv.key_of(t[2]) for t in rv.tokens(lines[i]))
    for new in new_names(table):
        k = rv.key_of(new)
        if k in shared:
            problems.append((where, "new name is shared, a CONST or a SUB: " + new))
        if k in present and k not in table:
            problems.append((where, "new name already used: " + new))
    for old in table:
        if old not in present:
            problems.append((where, "old name not found: " + old))
    params = set()
    if is_sub:
        params = {rv.key_of(n) for n in rv.header_names(rv.tokens(lines[first])[2:])}
    changed = 0
    dimmed = set()  # the new names of splits that have their DIM: two splits may share a name
    for i in range(first, last + 1):
        line = lines[i]
        toks = rv.tokens(line)
        is_dim = bool(toks) and toks[0][2].lower() == "dim" and i > first
        picks = {}
        for old, new in table.items():
            if not isinstance(new, list):
                picks[old] = new
                continue
            if is_dim:
                continue
            hit = [n for n, a, b in new if a <= i + 1 <= b]
            if hit:
                picks[old] = hit[0]
            elif any(rv.key_of(t[2]) == old for t in toks):
                problems.append((where, f"{old} is used on line {i + 1}, outside its ranges"))
        new_line = rename_token(line, picks)
        if is_dim:
            for old, new in table.items():
                if isinstance(new, list):
                    names = []
                    for n, _, _ in new:
                        if rv.key_of(n) not in params and rv.key_of(n) not in dimmed:
                            names.append(n)
                            dimmed.add(rv.key_of(n))
                    new_line, _ = expand_dim(new_line, old, names)
        if new_line != line:
            lines[i] = new_line
            changed += 1
        if i == first and is_sub:
            # the parameters under their new names: a split's new name may be one of them
            params |= {rv.key_of(n) for n in rv.header_names(rv.tokens(lines[first])[2:])}
    # a split parameter: its other names need a DIM
    for old, new in table.items():
        if isinstance(new, list) and old in params:
            header_name = [n for n, a, b in new if a <= first + 1 <= b]
            extra = []
            for n, _, _ in new:
                if n not in extra and n not in header_name and rv.key_of(n) not in params:
                    extra.append(n)
            for i in range(first + 1, last + 1):
                toks = rv.tokens(lines[i])
                if toks and toks[0][2].lower() == "dim":
                    for n in extra:
                        tail = n if n[-1] in "$&!#" else n + " AS INTEGER"
                        lines[i] = lines[i] + ": DIM " + tail
                    break
            else:
                problems.append((where, "no DIM line for the new names of " + old))
    return changed


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    shared = shared_names()
    done = set()
    problems = []
    out = {}
    total = 0
    for f in FILES:
        path = rv.ROOT / f
        lines = path.read_bytes().decode("latin-1").split("\n")
        before = list(lines)
        for name, first, last in rv.split_scopes(lines):
            if name is None:
                if f in MODULE and first == 0:
                    total += rename_scope(lines, first, last, MODULE[f], problems, f, shared, False)
                    done.add(f)
                continue
            if name.lower() not in LOCALS:
                continue
            where = f"{f} {name}"
            total += rename_scope(lines, first, last, LOCALS[name.lower()], problems, where, shared, True)
            done.add(name.lower())
        if lines != before:
            out[path] = "\n".join(lines)
            if mode == "show":
                for n, (a, b) in enumerate(zip(before, lines)):
                    if a != b:
                        print(f"{f}:{n + 1}: {b.strip()[:150]}")
    for where, what in problems:
        print(f"PROBLEM {where}: {what}")
    print("not found:", sorted((set(LOCALS) | set(MODULE)) - done))
    print(f"{len(done)} scopes, {total} lines changed, {len(out)} files")
    if mode != "apply":
        return 0
    if problems or (set(LOCALS) | set(MODULE)) - done:
        print("refusing to apply")
        return 1
    for path, text in out.items():
        path.write_bytes(text.encode("latin-1"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
