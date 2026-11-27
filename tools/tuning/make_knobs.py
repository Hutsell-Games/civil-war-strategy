#!/usr/bin/env python3
"""Writes the tuning knobs' code and the shipped tuning file from tools/tuning/knobs.txt.

    python -I tools/tuning/make_knobs.py            # writes the three files
    python -I tools/tuning/make_knobs.py --check    # exit code 1 when one of them is out of date

    io/tuning_knobs.bi       the knobs' shared variables (included by cws.bi)
    io/tuning_knobs.bm       tuning_defaults, tuning_set, tuning_changes$ and tuning_relations$
    scenarios/TUNING.DAT     every knob at its default, with its comment

BASIC cannot look a variable up by its name, so each knob needs a line in each of these. The table
keeps them in step. A fraction is a DOUBLE: a SINGLE variable does not multiply as the number
written in the code did (.3 * 95 rounds to 28 as a literal and to 29 from a SINGLE; measured
with both compilers, 2026-11-16), and a DOUBLE does.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TABLE = Path(__file__).resolve().parent / "knobs.txt"
NOTE = "Written by tools/tuning/make_knobs.py from tools/tuning/knobs.txt. Do not edit."

FILE_HEAD = """\
; Civil War Strategy: tuning knobs for playtesting.
;
; Each line is "name = value". Change a value and start a new game: the game reads this file at
; each new game. A knob left out keeps its default, the value below. A name the game does not
; know, or a value outside what the knob allows, stops the game with a message naming the file
; and the line.
;
; The values below are the game's own. Keep this file as it is. For an experiment:
;   - a scenario may have a TUNING.DAT of its own in its folder (scenarios/standard), holding
;     only the lines it changes; they count on top of this file for games of that scenario;
;   - tests/autoplay.py --tuning <file> plays the computer against itself with a file's lines on
;     top of both, and counts who wins (tests/README.md, "Autoplay").
; A saved game keeps the knobs it was saved with, and the history file names those that differ
; from the defaults. Each knob has a least and a most, so that the game's arithmetic holds, and
; some knobs must keep an order between them: the rules are at the end of this file.
;
; Written by tools/tuning/make_knobs.py from tools/tuning/knobs.txt, which is where a knob is
; added or its default changed.
"""


@dataclass(frozen=True)
class Knob:
    name: str
    default: str
    least: str
    most: str
    about: str
    group: str

    @property
    def fraction(self) -> bool:
        return "." in self.default

    @property
    def var(self) -> str:
        return self.name + ("#" if self.fraction else "")


@dataclass(frozen=True)
class Check:
    condition: str
    message: str


def read_checks(knobs: list[Knob]) -> list[Check]:
    """The rules between knobs: lines "check | condition | message"."""
    checks = []
    names = {k.name for k in knobs}
    for n, line in enumerate(TABLE.read_text(encoding="utf-8").splitlines(), 1):
        if not line.startswith("check"):
            continue
        parts = [p.strip() for p in line.split("|")]
        if len(parts) != 3 or parts[0] != "check":
            sys.exit(f"knobs.txt line {n}: needs check | condition | message")
        if ";" in parts[2] or '"' in parts[2]:
            sys.exit(f"knobs.txt line {n}: no ; or quote in the message")
        used = set(re.findall(r"[a-z_][a-z0-9_]*", parts[1]))
        if not used & names:
            sys.exit(f"knobs.txt line {n}: the condition names no knob")
        checks.append(Check(parts[1], parts[2]))
    return checks


def basic_condition(condition: str, knobs: list[Knob]) -> str:
    """The condition with each knob's name as its variable (a fraction's ends in #)."""
    vars_ = {k.name: k.var for k in knobs}
    return re.sub(r"(?<![A-Za-z0-9_])([a-z_][a-z0-9_]*)(?![A-Za-z0-9_#!])",
                  lambda m: vars_.get(m.group(1), m.group(1)), condition)


def read_table() -> list[Knob]:
    knobs, group = [], ""
    for n, line in enumerate(TABLE.read_text(encoding="utf-8").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("check"):
            continue
        if line.startswith("["):
            group = line.strip("[]")
            continue
        parts = [p.strip() for p in line.split("|", 4)]
        if len(parts) != 5:
            sys.exit(f"knobs.txt line {n}: needs name | default | least | most | what it is")
        knob = Knob(*parts, group)
        if not float(knob.least) <= float(knob.default) <= float(knob.most):
            sys.exit(f"knobs.txt line {n}: {knob.name}'s default is outside its least and most")
        if ";" in knob.about:
            sys.exit(f"knobs.txt line {n}: no ; in the text, it ends a line of TUNING.DAT")
        knobs.append(knob)
    names = [k.name for k in knobs]
    for name in names:
        if names.count(name) > 1:
            sys.exit(f"knobs.txt: {name} is there twice")
    return knobs


def make_bi(knobs: list[Knob]) -> str:
    lines = [f"' The tuning knobs' shared variables. {NOTE}"]
    for i in range(0, len(knobs), 4):
        lines.append("DIM SHARED " + ", ".join(k.var for k in knobs[i:i + 4]))
    return "\n".join(lines) + "\n"


def make_bm(knobs: list[Knob], checks: list[Check]) -> str:
    out = [f"' The tuning knobs' defaults, names and ranges. {NOTE}",
           "' load_tuning and the SUBs these call are in io/tuning_file.bm.",
           "",
           "' Sets every knob to its default: the number the game had before it was a knob.",
           "SUB tuning_defaults"]
    out += [f"    {k.var} = {k.default}" for k in knobs]
    out += ["END SUB",
            "",
            "' Sets the knob named key$ to value#. why$ is \"\" when it was set; otherwise it says why",
            "' not: no knob of that name, a value outside the knob's least and most, or a fraction for",
            "' a knob that takes whole numbers.",
            "SUB tuning_set (key$, value#, why$)",
            "    why$ = \"\"",
            "    SELECT CASE key$"]
    for k in knobs:
        out += [f"        CASE \"{k.name}\"",
                f"            why$ = tuning_check$(key$, value#, {k.least}, {k.most}, {'FALSE' if k.fraction else 'TRUE'})",
                "            IF why$ = \"\" THEN",
                f"                {k.var} = value#",
                "            END IF"]
    out += ["        CASE ELSE",
            "            why$ = \"unknown knob: \" + key$",
            "    END SELECT",
            "END SUB",
            "",
            "' The knobs that are not at their defaults, as \"name=value;name=value;\". \"\" when all are.",
            "FUNCTION tuning_changes$",
            "    DIM list$"]
    out += [f"    list$ = list$ + tuning_note$(\"{k.name}\", ({k.var}), {k.default})" for k in knobs]
    out += ["    tuning_changes$ = list$", "END FUNCTION",
            "",
            "' The rules between knobs: \"\" when the knobs keep them all; otherwise the first one broken.",
            "FUNCTION tuning_relations$",
            "    tuning_relations$ = \"\""]
    for c in checks:
        out += [f"    IF NOT ({basic_condition(c.condition, knobs)}) THEN",
                f"        tuning_relations$ = \"{c.message}\"",
                "        EXIT FUNCTION",
                "    END IF"]
    out += ["END FUNCTION"]
    return "\n".join(out) + "\n"


def make_dat(knobs: list[Knob], checks: list[Check]) -> str:
    out = [FILE_HEAD.rstrip("\n")]
    width = max(len(f"{k.name} = {k.default}") for k in knobs) + 2
    group = None
    for k in knobs:
        if k.group != group:
            group = k.group
            out += ["", f"; {group}."]
        out.append(f"{k.name} = {k.default}".ljust(width) + f"; {k.about}")
    out += ["", "; Rules between knobs, checked when every file has been read:"]
    out += [f";   {c.message}" for c in checks]
    return "\n".join(out) + "\n"


def main(argv: list[str] | None = None) -> int:
    check = "--check" in (argv if argv is not None else sys.argv[1:])
    knobs = read_table()
    checks = read_checks(knobs)
    files = {"io/tuning_knobs.bi": make_bi(knobs), "io/tuning_knobs.bm": make_bm(knobs, checks),
             "scenarios/TUNING.DAT": make_dat(knobs, checks)}
    stale = 0
    for name, text in files.items():
        path = ROOT / name
        # The line ends of the working tree may be CR LF; compare and write LF.
        now = path.read_bytes().replace(b"\r\n", b"\n") if path.exists() else None
        if now == text.encode("utf-8"):
            continue
        stale += 1
        if check:
            print(f"out of date: {name} (run tools/tuning/make_knobs.py)")
        else:
            path.write_bytes(text.encode("utf-8"))
            print(f"wrote {name}")
    if not check:
        print(f"{len(knobs)} knobs")
    return 1 if check and stale else 0


if __name__ == "__main__":
    sys.exit(main())
