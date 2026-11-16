#!/usr/bin/env python3
"""Rename port/ to io/, order rules/army.bm by topic, move five procedures to their callers'
files, and give each file without one a comment at its top (2026-11-14).

    python -I tools/refactor/arrange_files.py report   # what moves where; changes nothing
    python -I tools/refactor/arrange_files.py apply    # git mv's port/ to io/ and rewrites the files

Each procedure moves whole, with the comment and blank lines above it, as split_files.py moved
them. No line inside a procedure changes. A file whose order is not given keeps its order, blank
lines and all; a procedure moved into it goes after the one named in MOVES. The files are read and
written as bytes, so their CP437 characters and CRLF line ends stay.
"""
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import split_files as sf  # noqa: E402

ROOT = sf.ROOT
# The line ends of the working tree: CRLF or LF, as git checked the files out.
EOL = b"\r\n" if b"\r\n" in (ROOT / "cws.bas").read_bytes() else b"\n"
sf.EOL = EOL

# (procedure, from, to, the procedure it goes after in the new file; None for the end)
MOVES = [
    ("sort_move_order", "rules/army.bm", "rules/turn.bm", "turn_set_move_order"),
    ("random_discard", "rules/navy.bm", "ai/navy.bm", "ai_navy_attack"),
    ("draw_army_stats", "ui/reports.bm", "ui/screen.bm", None),
    ("print_army_size", "ui/reports.bm", "ui/screen.bm", None),
    ("troops_text", "ui/reports.bm", "ui/screen.bm", None),  # troops_text$: names lose the $
]

# The new order of a file's procedures, all of them.
ORDER = {
    "rules/army.bm": [
        # slots and sides
        "side_first_army", "side_last_army", "army_side", "other_side", "army_exists",
        "army_has_move", "army_has_acted", "army_set_order", "army_clear", "army_in_field",
        # strength
        "side_troops", "side_strength",
        # leaders
        "army_appoint", "army_free_leader", "army_take_leader", "army_pick_commander",
        "army_generate_name",
        # raising and recruiting
        "army_raise", "army_recruit_cities", "army_add_recruits", "recruit_troops",
        "recruits_cut_off", "army_recruit_bonus",
        # supply, drill and detach
        "army_buy_supply", "army_can_drill", "army_drill", "side_can_detach", "army_detach",
        # combining
        "army_list_combine_cities", "army_combine_start", "army_combine_add",
        "army_combine_absorb", "army_combine_finish",
    ],
}

# The comment at the top of each file that has none.
HEADERS = {
    "rules/city.bm": [
        "' The rules of the cities: their roads, capture, forts and the capital, and the steps of the",
        "' city picker. They draw nothing. The player's menus are in ui/city.bm, and a capture as the",
        "' player sees it is city_capture (commands/city.bm).",
    ],
    "rules/setup.bm": [
        "' The settings and the start of a game. They draw nothing. The Utility menu that changes the",
        "' settings is in ui/options.bm. game_new reads a new game's files (io/files.bm and",
        "' io/events_file.bm).",
    ],
    "ui/menu.bm": [
        "' The menus. A menu's rows are in menu_text$() and menu_value() (cws.bi). The SUBs at the",
        "' top fill them. menu_select shows the menu and reads the player's choice; the SUBs after it",
        "' are its parts.",
    ],
    "ui/messages.bm": [
        "' A message in a box over the screen, and scribe_message, which also writes a message to the",
        "' history file (cws.his) when the History setting is on.",
    ],
    "ui/reports.bm": [
        "' The Inform menu's reports (menu_report), the Victory Conditions menu of Utility, and Chk",
        "' Links (check_map_links).",
    ],
    "ui/screen.bm": [
        "' Parts of the screen that many SUBs share: the bottom line, the right panel and an army's",
        "' numbers there, the top bar, the train's box, the screen between two players' turns, and",
        "' the waits for a time or a key.",
    ],
    "draw/map.bm": [
        "' The map: its line work (draw_map), the cities and their names, the fleets, and the markers",
        "' of armies and moves (draw_map_marker, draw_stack_markers).",
    ],
    "draw/icons.bm": [
        "' The flags: an army's or a train's flag beside a city and its animation, the flash of a",
        "' city, and the large flags of the other screens.",
    ],
    "draw/pictures.bm": [
        "' Pictures drawn line by line: the cannon of the battle screen, the shore of the Chesapeake",
        "' on the map, and the title screen; and load_picture, for the .vga files.",
    ],
    "draw/ships.bm": [
        "' The ships: a fleet's icons on the map, the pictures of the ironclad and the schooner, a",
        "' fleet putting to sea, and a ship sunk.",
    ],
    "game/tunes.bm": [
        "' The war's tunes: Shenandoah and the title's tune.",
    ],
    "game/victory_screens.bm": [
        "' The war's end screens: the Union's victory, the Rebels' victory, and an army's surrender.",
    ],
    "io/files.bm": [
        "' The game's files: the list of scenarios, a scenario's setup and map, the saved games, the",
        "' settings (cws.cfg), the battle summary, the Hall of Fame and the history file. The events",
        "' file is read by io/events_file.bm.",
    ],
}

# The files whose include lines name port/: they name io/ instead.
INCLUDERS = ["cws.bas", "cws.bi", "tests/rules_test.bas"]


def src(path):
    """The file's path now: io/ is still port/ before the rename."""
    if path.startswith("io/") and not (ROOT / "io").is_dir():
        return "port/" + path[3:]
    return path


def parse(path):
    return sf.parse(src(path))


def plan():
    files = {}
    report = []
    touched = sorted({m[1] for m in MOVES} | {m[2] for m in MOVES} | set(ORDER) | set(HEADERS))
    parsed = {p: list(parse(p)) for p in touched}
    for proc, source, target, after in MOVES:
        header, blocks, trailing = parsed[source]
        i = next((k for k, b in enumerate(blocks) if b[0] == proc), None)
        if i is None:
            raise SystemExit(f"{source}: no procedure {proc}")
        name, lines = blocks.pop(i)
        lines = [b""] + sf.strip_leading_blanks(lines)
        tblocks = parsed[target][1]
        if after is None:
            tblocks.append((name, lines))
        else:
            k = next((k for k, b in enumerate(tblocks) if b[0] == after), None)
            if k is None:
                raise SystemExit(f"{target}: no procedure {after}")
            tblocks.insert(k + 1, (name, lines))
        report.append(f"{source} -> {target}: {proc}" + (f" (after {after})" if after else " (at the end)"))
    for path in touched:
        header, blocks, trailing = parsed[path]
        if path in ORDER:
            names = [b[0] for b in blocks]
            if sorted(names) != sorted(ORDER[path]):
                raise SystemExit(f"{path}: ORDER does not list its procedures: "
                                 f"{sorted(set(names) ^ set(ORDER[path]))}")
            by_name = dict(blocks)
            body = header + sf.join_blocks([(n, by_name[n]) for n in ORDER[path]]) + trailing
            report.append(f"{path}: ordered by topic")
        else:
            body = header[:]
            for _, lines in blocks:
                body += lines
            body = body + trailing
        if path in HEADERS:
            if header:
                raise SystemExit(f"{path}: has a comment at its top already")
            body = [l.encode("cp437") for l in HEADERS[path]] + [b""] + sf.strip_leading_blanks(body)
            report.append(f"{path}: a comment at its top")
        files[path] = body
    for main in INCLUDERS:
        lines = (ROOT / main).read_bytes().split(EOL)[:-1]
        out = [l.replace(b"'port/", b"'io/").replace(b"'../port/", b"'../io/") for l in lines]
        changed = sum(1 for a, b in zip(lines, out) if a != b)
        if changed == 0:
            raise SystemExit(f"{main}: no include of port/")
        files[main] = out
        report.append(f"{main}: {changed} include lines name io/")
    return files, report


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    files, report = plan()
    print("\n".join(report))
    if mode != "apply":
        return
    if not (ROOT / "io").is_dir():
        subprocess.run(["git", "mv", "port", "io"], cwd=ROOT, check=True)
    for path, lines in files.items():
        (ROOT / path).write_bytes(EOL.join(lines) + EOL)
        print("wrote", path)


if __name__ == "__main__":
    main()
