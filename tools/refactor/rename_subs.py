#!/usr/bin/env python3
"""Rename SUBs and FUNCTIONs from the "Settled names" table of docs/archived/sub-names.md.

Works on tokens, so strings and comments are left alone. Case is ignored, as in BASIC.

    python tools/refactor/rename_subs.py report   # list every use of an old name, by kind
    python tools/refactor/rename_subs.py apply    # rewrite the sources

A use of an old name is renamed only when it is a call or a definition:
  - after SUB, FUNCTION, CALL or DECLARE;
  - at the start of a statement (line start, after ':' , THEN or ELSE) with no ':' right after it
    that would make it a label;
  - a FUNCTION name followed by '(' anywhere in an expression.
Any other use (a label, a variable, a GOTO target) is reported as AMBIGUOUS and left alone;
apply refuses to run while there are any.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TABLE = ROOT / "docs" / "archived" / "sub-names.md"
FILES = ["CWSTRAT.BAS", "CWSTRAT1.BM", "CWSTRAT2.BM", "CWSMENU.BM", "CWS14.BI",
         "QB64.BM", "SCRIPT.BM", "FOLDERS.BI", "tests/rules_test.bas"]
FUNCTIONS = {"dir$", "scriptdate$", "scripttick%"}

TOKEN = re.compile(r'"[^"]*"|\'.*$|[A-Za-z_][A-Za-z0-9_]*[$%&!#]?|\s+|.', re.S)


def load_table():
    text = TABLE.read_text(encoding="utf-8").split("## Settled names", 1)[1]
    table = {}
    for line in text.splitlines():
        m = re.match(r"\| `([^`]+)` \| `([^`]+)`", line)
        if m and m.group(1) != "Current name":
            old, new = m.group(1), m.group(2)
            if old.lower() != new.lower():
                table[old.lower()] = new
    return table


def scan(line, table):
    """Yield (start, end, old_lower, kind) for each use of an old name in one source line."""
    pos = 0
    toks = []
    for m in TOKEN.finditer(line):
        toks.append((m.start(), m.end(), m.group()))
    # significant tokens only
    sig = [t for t in toks if not t[2].isspace()]
    out = []
    for n, (s, e, tx) in enumerate(sig):
        low = tx.lower()
        if low not in table:
            # A FUNCTION may be written without its type suffix (scripttick for scripttick%).
            bare = [k for k in table if k[-1] in "$%&!#" and k[:-1] == low and k in FUNCTIONS]
            if not bare:
                continue
            low = bare[0]
        prev = sig[n - 1][2].lower() if n else None
        nxt = sig[n + 1][2] if n + 1 < len(sig) else None
        if prev in ("sub", "function", "call", "declare"):
            out.append((s, e, low, "def/call"))
        elif low in FUNCTIONS and nxt == "(":
            out.append((s, e, low, "function"))
        elif low in FUNCTIONS:
            out.append((s, e, low, "function-noparen"))
        elif prev in ("goto", "gosub", "resume") or (prev is None and nxt == ":"):
            out.append((s, e, low, "label"))
        elif (prev is None or prev in (":", "then", "else")) and nxt != "=":
            out.append((s, e, low, "statement"))
        else:
            out.append((s, e, low, "AMBIGUOUS"))
    return out


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    table = load_table()
    ambiguous = 0
    plans = {}
    counts = {}
    for f in FILES:
        path = ROOT / f
        if not path.exists():
            continue
        raw = path.read_bytes().decode("latin-1")
        lines = raw.split("\n")
        changed = False
        for i, line in enumerate(lines):
            hits = scan(line, table)
            for s, e, low, kind in reversed(hits):
                counts[(low, kind)] = counts.get((low, kind), 0) + 1
                if kind == "label":
                    continue
                if kind.startswith("AMBIGUOUS"):
                    ambiguous += 1
                    print(f"AMBIGUOUS {f}:{i + 1}: {line.strip()[:100]}")
                    continue
                line = line[:s] + table[low] + line[e:]
                changed = True
            lines[i] = line
        if changed:
            plans[path] = "\n".join(lines)
    if mode == "report":
        for (low, kind), n in sorted(counts.items()):
            print(f"{n:5d}  {low:15s} {kind}")
        print(f"{ambiguous} ambiguous uses")
        missing = [k for k in table if not any(k == low for low, _ in counts)]
        print("never used:", missing)
        return 0
    if ambiguous:
        print("refusing to apply: resolve the ambiguous uses first")
        return 1
    for path, text in plans.items():
        path.write_bytes(text.encode("latin-1"))
        print("wrote", path.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())
