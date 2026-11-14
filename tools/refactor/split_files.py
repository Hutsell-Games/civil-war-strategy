#!/usr/bin/env python3
"""Split ai/ai.bm, ui/orders.bm and port/files.bm into files by topic (2026-11-14).

    python -I tools/refactor/split_files.py report   # what moves where; changes nothing
    python -I tools/refactor/split_files.py apply    # moves the procedures and fixes the includes

Each procedure moves whole, with the comment and blank lines above it, as phase 6 of
docs/modernize-plan.md moved them (move_subs.py). No line inside a procedure changes. Inside a new
file the procedures keep the order they had. A procedure moved into a file that exists goes at its
end. ai/ai.bm is renamed with `git mv` to ai/army.bm, so that no tracked file is deleted by hand.
The files are read and written as bytes, so their CP437 characters and CRLF line ends stay.
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# source file -> {target file: [procedures]}. What is not listed stays in the source.
MOVES = {
    "ai/ai.bm": {
        "ai/forces.bm": ["ai_resupply", "ai_fortify", "ai_fortify_pick", "ai_raise_forces",
                         "ai_count_armies", "ai_recruit", "ai_recruit_pick"],
        "ai/army.bm": ["ai_army_orders", "ai_army_order", "ai_drill", "ai_evaluate_move",
                       "city_nearby_enemy_strength", "ai_combine", "ai_razes_fort"],
        "ai/navy.bm": ["ai_fleet_orders", "ai_pick_port", "ai_navy_orders", "ai_navy_build",
                       "ai_navy_attack", "ai_navy_sail", "ai_navy_raid", "ai_navy_invade", "ai_navy",
                       "ai_navy_adjust"],
        "ai/railroad.bm": ["ai_railroad_orders", "ai_railroad"],
    },
    "ui/orders.bm": {
        "ui/army.bm": ["menu_army_move", "menu_army_select", "menu_army_recruit", "draw_recruit_funds",
                       "menu_recruit_cities", "menu_army_cancel", "menu_army_relieve",
                       "menu_army_retreat", "menu_supply", "menu_army_detach", "menu_army_drill"],
        "ui/city.bm": ["menu_city_fortify", "draw_fort_built", "menu_city_select", "menu_move_capital"],
        "ui/railroad.bm": ["menu_railroad"],
        "ui/navy.bm": ["menu_navy", "menu_navy_items"],
    },
    "port/files.bm": {
        "port/events_file.bm": ["load_events", "event_clear_row", "event_read_line", "event_read_side",
                                "event_read_conditions", "event_read_effect", "event_read_chance",
                                "text_is_number", "text_last_space"],
    },
}

# The source that git mv renames, and the file it becomes.
RENAMED = {"ai/ai.bm": "ai/army.bm"}

# The comment at the top of each new file, and of a source that stays. A source renamed by git mv
# loses its own comment: each new file of ai/ gets one of its own.
HEADERS = {
    "ai/army.bm": [
        "' The computer's decisions for its armies: where each one moves, drill, Join, and razing a",
        "' fort. Like every file of ai/, they draw nothing themselves: their messages are SUBs of",
        "' ui/ai.bm, and they carry out an order through the commands of commands/, as the player's",
        "' menus do.",
    ],
    "ai/forces.bm": [
        "' The computer's first decisions of its turn: supply for its armies, forts, recruits and",
        "' new armies.",
    ],
    "ai/navy.bm": [
        "' The computer's fleet: when it builds a ship, attacks, sails, raids or lands an army. The",
        "' player's half is ui/navy.bm, and both give their orders through commands/navy.bm.",
    ],
    "ai/railroad.bm": [
        "' The computer's train: which army it sends by rail, and where to.",
    ],
    "ui/orders.bm": [
        "' The Commands menu. The menus of its entries are in ui/army.bm and ui/city.bm.",
    ],
    "ui/city.bm": [
        "' The player's menus for cities: Fortify, Move Capital, and the picker of a city of the",
        "' player's side.",
    ],
    "ui/railroad.bm": [
        "' The player's Railroad menu. The main menu's Railroad entry is menu_main_railroad",
        "' (ui/main_menu.bm).",
    ],
    "port/events_file.bm": [
        "' Reads the special events from scenarios/EVENTS.DAT into the events table. The rules that",
        "' roll and apply them are in rules/events.bm.",
    ],
}

# Include lines: an old line, and the lines that take its place, in cws.bas and tests/rules_test.bas.
INCLUDES = {
    "ai/ai.bm": ["ai/forces.bm", "ai/army.bm", "ai/navy.bm", "ai/railroad.bm"],
    "ui/orders.bm": ["ui/orders.bm", "ui/city.bm", "ui/railroad.bm"],
    "port/files.bm": ["port/files.bm", "port/events_file.bm"],
}

PROC = re.compile(rb"^\s*(SUB|FUNCTION)\s+([A-Za-z_][A-Za-z0-9_]*)", re.I)
END_PROC = re.compile(rb"^\s*END\s+(SUB|FUNCTION)\b", re.I)
EOL = b"\r\n"


def is_blank(line):
    return line.strip() == b""


def parse(path):
    """(header, [(name, lines)], trailing): each procedure with every line between it and the one
    before, the file's own comment, and what follows the last procedure."""
    lines = (ROOT / path).read_bytes().split(EOL)
    if lines and lines[-1] == b"":
        lines.pop()
    blocks = []
    start = 0
    name = None
    for n, line in enumerate(lines):
        m = PROC.match(line)
        if m and name is None:
            name = m.group(2).decode().lower()
            continue
        if END_PROC.match(line) and name is not None:
            blocks.append((name, lines[start:n + 1]))
            start = n + 1
            name = None
    trailing = lines[start:]
    header = []
    if blocks:
        first_name, first = blocks[0]
        # The file's comment is what comes before the last blank line above the first procedure.
        sub_line = next(i for i, l in enumerate(first) if PROC.match(l))
        blanks = [i for i in range(sub_line) if is_blank(first[i])]
        if blanks:
            header = first[:blanks[-1] + 1]
            blocks[0] = (first_name, first[blanks[-1] + 1:])
    return header, blocks, trailing


def strip_leading_blanks(lines):
    while lines and is_blank(lines[0]):
        lines = lines[1:]
    return lines


def join_blocks(blocks):
    out = []
    for _, lines in blocks:
        if out:
            out.append(b"")
        out += strip_leading_blanks(lines)
    return out


def comment(path):
    return [l.encode("cp437") for l in HEADERS[path]]


def plan():
    """{file: its new lines}, and the report's lines."""
    files = {}
    report = []
    for source, targets in MOVES.items():
        header, blocks, trailing = parse(source)
        names = [b[0] for b in blocks]
        wanted = [p for t in targets.values() for p in t]
        for p in wanted:
            if p not in names:
                raise SystemExit(f"{source}: no procedure {p}")
        if len(set(wanted)) != len(wanted):
            raise SystemExit(f"{source}: a procedure is listed twice")
        moved = set(wanted)
        for target, procs in targets.items():
            chosen = [b for b in blocks if b[0] in procs]
            if (ROOT / target).exists() and target != source:
                body = files.get(target) or (ROOT / target).read_bytes().split(EOL)[:-1]
                new = body + [b""] + join_blocks(chosen)
            else:
                new = comment(target) + [b""] + join_blocks(chosen)
            files[target] = new
            report.append(f"{source} -> {target}: {', '.join(b[0] for b in chosen)}")
        kept = [b for b in blocks if b[0] not in moved]
        if source in RENAMED:
            if kept:
                raise SystemExit(f"{source}: is renamed, but keeps {[b[0] for b in kept]}")
            continue
        # The source keeps its other procedures as they are, blank lines and all.
        body = header[:]
        for _, lines in kept:
            body += lines
        body = strip_leading_blanks(body + trailing)
        if source in HEADERS:
            body = comment(source) + [b""] + body
        files[source] = body
        report.append(f"{source} keeps: {', '.join(b[0] for b in kept)}")
    for main, prefix, form in (("cws.bas", "", "' $INCLUDE: '{}'"),
                               ("tests/rules_test.bas", "../", "'$INCLUDE: '{}'")):
        lines = (ROOT / main).read_bytes().split(EOL)[:-1]
        out = []
        for line in lines:
            for old, new in INCLUDES.items():
                if line == form.format(prefix + old).encode():
                    out += [form.format(prefix + n).encode() for n in new]
                    break
            else:
                out.append(line)
        if len(out) != len(lines) + sum(len(n) - 1 for n in INCLUDES.values()):
            raise SystemExit(f"{main}: an include line was not found")
        files[main] = out
    return files, report


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    files, report = plan()
    print("\n".join(report))
    if mode != "apply":
        return
    for old, new in RENAMED.items():
        subprocess.run(["git", "mv", old, new], cwd=ROOT, check=True)
    for path, lines in files.items():
        (ROOT / path).write_bytes(EOL.join(lines) + EOL)
        print("wrote", path)


if __name__ == "__main__":
    main()
