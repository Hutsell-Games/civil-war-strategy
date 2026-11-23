#!/usr/bin/env python3
"""Rename the names that group 1 of docs/clarity-review.md found misleading (2026-11-23).

    python tools/refactor/rename_clarity.py report   # counts for each name; changes nothing
    python tools/refactor/rename_clarity.py apply    # rewrite the sources

Works on whole words, in code and in comments alike, since the comments name these procedures
too. Files are read and written as bytes, so the code page 437 characters of ui/ stay as they
are. `menu_item_show_beside` is renamed inside menu_select only, where no other `kind` exists.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FOLDERS = ["ai", "commands", "draw", "game", "io", "rules", "ui", "tests"]
FILES = ["cws.bas", "cws.bi", "docs/modernize-plan.md", "docs/rule-changes.md"]
SUFFIXES = {".bas", ".bi", ".bm"}

# Old name, new name. A longer name comes before a name it starts with.
TABLE = [
    ("victory_reason", "victory_side"),
    ("city_is_connected", "city_friendly_neighbors"),
    ("turn_recruit_state", "turn_recruit_count"),
    ("ai_navy_orders", "ai_navy_carry_out"),
    ("ai_navy", "ai_navy_first_action"),
    ("ai_railroad", "ai_railroad_pick"),
    ("navy_retreat_port", "navy_retreat"),
    ("menu_item_show_beside%", "kind"),
    ("menu_item_show_beside", "kind"),
]


def sources():
    for folder in FOLDERS:
        for path in sorted((ROOT / folder).iterdir()):
            if path.is_file() and path.suffix.lower() in SUFFIXES:
                yield path
    for name in FILES:
        yield ROOT / name


def pattern(old):
    """The old name as a whole word. A name that ends in `%` has no word boundary after it."""
    tail = "" if old.endswith("%") else r"(?![A-Za-z0-9_])"
    return re.compile(rb"(?<![A-Za-z0-9_])" + re.escape(old.encode("ascii")) + tail.encode("ascii"))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    if mode not in ("report", "apply"):
        sys.exit(__doc__)
    counts = {old: 0 for old, _ in TABLE}
    for path in sources():
        data = path.read_bytes()
        changed = data
        for old, new in TABLE:
            changed, n = pattern(old).subn(new.encode("ascii"), changed)
            counts[old] += n
        if mode == "apply" and changed != data:
            path.write_bytes(changed)
            print("changed", path.relative_to(ROOT).as_posix())
    for old, new in TABLE:
        print(f"{counts[old]:4}  {old} -> {new}")


if __name__ == "__main__":
    main()
