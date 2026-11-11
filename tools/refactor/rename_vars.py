#!/usr/bin/env python3
"""Rename shared variables from the tables of docs/variable-names.md (phase 4 of docs/modernize-plan.md).

    python tools/refactor/rename_vars.py report   # counts, shadowed names, collisions; changes nothing
    python tools/refactor/rename_vars.py apply    # rewrite the sources

Works on tokens, so strings, comments, REM and DATA lines are left alone. Case is ignored, as in
BASIC; `%` is ignored too, because the game says DEFINT A-Z (`size%` is `size`). The suffixes
`$`, `&`, `!` and `#` make a different variable.

Scope: a SUB or FUNCTION that has a parameter, or a DIM / REDIM / STATIC variable, with the name of a
shared variable hides it. Its uses are left alone and listed as SHADOWED. Labels (a name at the start
of a line followed by a colon, or after GOTO / GOSUB) are left alone too.

Skipped on purpose: side (a separate step, note 3), matrix (split, note 1), navymove (phase 7,
note 2), scripted (kept) and price (deleted).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TABLE = ROOT / "docs" / "variable-names.md"
FILES = ["CWSTRAT.BAS", "CWSTRAT1.BM", "CWSTRAT2.BM", "CWSMENU.BM", "CWS14.BI",
         "QB64.BM", "SCRIPT.BM", "FOLDERS.BI", "tests/rules_test.bas"]
SKIP = {"side", "matrix", "navymove", "scripted", "price"}
TOKEN = re.compile(r'"[^"]*"|\'.*$|[A-Za-z_][A-Za-z0-9_]*[$%&!#]?|\s+|.', re.S)
BODY_STOP = ("## Unused", "## Parameters", "## Notes")


def key_of(name):
    """Lower-case name with `%` dropped: the variable's identity under DEFINT A-Z."""
    name = name.lower()
    return name[:-1] if name.endswith("%") else name


def load_table():
    text = TABLE.read_text(encoding="utf-8")
    text = text.split("## Armies", 1)[1]
    for stop in BODY_STOP:
        text = text.split(stop, 1)[0]
    table = {}
    for line in text.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4 or not cells[0].startswith("`"):
            continue
        olds = re.findall(r"`([^`]+)`", cells[0])
        news = re.findall(r"`([^`]+)`", cells[3])
        olds = [o.replace("()", "") for o in olds]
        news = [n.replace("()", "") for n in news]
        if len(olds) != len(news):
            continue
        for old, new in zip(olds, news):
            if old.rstrip("$&!#").lower() in SKIP:
                continue
            table[key_of(old)] = new
    return table


def tokens(line):
    """Significant tokens of a line as (start, end, text); stops at a comment, REM or DATA."""
    out = []
    for m in TOKEN.finditer(line):
        tx = m.group()
        if tx.isspace() or tx.startswith("'"):
            continue
        out.append((m.start(), m.end(), tx))
    for n, (_, _, tx) in enumerate(out):
        prev = out[n - 1][2] if n else None
        if tx.lower() in ("rem", "data") and (prev is None or prev == ":" or prev.lower() in ("then", "else")):
            return out[:n]
    return out


def header_names(toks):
    """The names declared by a SUB / FUNCTION header or by DIM / REDIM / STATIC: the identifier that
    starts each comma-separated item, ahead of AS or '('."""
    names = []
    depth = 0
    start_item = True
    for _, _, tx in toks:
        if tx == "(":
            depth += 1
        elif tx == ")":
            depth -= 1
        elif tx == "," and depth <= 1:
            start_item = True
        elif start_item and depth <= 1 and re.match(r"[A-Za-z_]", tx):
            if tx.lower() not in ("shared", "byval", "static", "as"):
                names.append(tx)
                start_item = False
    return names


def split_scopes(lines):
    """Yield (scope_name or None, first_index, last_index) covering all lines."""
    scopes = []
    start = 0
    name = None
    for i, line in enumerate(lines):
        toks = tokens(line)
        if len(toks) >= 2 and toks[0][2].lower() in ("sub", "function") and name is None:
            if start < i:
                scopes.append((None, start, i - 1))
            start, name = i, toks[1][2]
        elif len(toks) >= 2 and toks[0][2].lower() == "end" and toks[1][2].lower() in ("sub", "function"):
            scopes.append((name, start, i))
            start, name = i + 1, None
    if start < len(lines):
        scopes.append((name, start, len(lines) - 1))
    return scopes


def local_names(lines, first, last, in_sub):
    """Keys of the names a SUB hides: its parameters and its DIM / REDIM / STATIC variables."""
    names = set()
    if not in_sub:
        return names
    for i in range(first, last + 1):
        toks = tokens(lines[i])
        if not toks:
            continue
        head = toks[0][2].lower()
        if i == first:
            body = toks[2:]
            names.update(key_of(n) for n in header_names(body))
        elif head in ("dim", "redim", "static") and not any(t[2].lower() == "shared" for t in toks[:2]):
            names.update(key_of(n) for n in header_names(toks[1:]))
    return names


def rename_line(line, table, hidden, stats, where):
    toks = tokens(line)
    pieces = []
    for n, (s, e, tx) in enumerate(toks):
        if not re.match(r"[A-Za-z_]", tx):
            continue
        k = key_of(tx)
        if k not in table:
            continue
        prev = toks[n - 1][2].lower() if n else None
        nxt = toks[n + 1][2] if n + 1 < len(toks) else None
        if prev in ("goto", "gosub", "resume", "sub", "function", "call") or (n == 0 and nxt == ":"):
            stats["label_or_sub"].append(where)
            continue
        if k in hidden:
            stats["shadowed"].append((where, k))
            continue
        suffix = tx[-1] if tx[-1] in "$%&!#" else ""
        new = table[k].rstrip("$&!#")
        pieces.append((s, e, new + suffix))
        stats["count"][k] = stats["count"].get(k, 0) + 1
    for s, e, new in reversed(pieces):
        line = line[:s] + new + line[e:]
    return line


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    table = load_table()
    # `old=new` arguments replace the table: python rename_vars.py apply side=current_side
    pairs = [a.split("=", 1) for a in sys.argv[2:] if "=" in a]
    if pairs:
        table = {key_of(o): n for o, n in pairs}
    stats = {"count": {}, "shadowed": [], "label_or_sub": []}
    new_text = {}
    all_tokens = set()
    for f in FILES:
        path = ROOT / f
        if not path.exists():
            continue
        lines = path.read_bytes().decode("latin-1").split("\n")
        for line in lines:
            all_tokens.update(key_of(t[2]) for t in tokens(line))
        for name, first, last in split_scopes(lines):
            hidden = local_names(lines, first, last, name is not None)
            for i in range(first, last + 1):
                lines[i] = rename_line(lines[i], table, hidden, stats, f"{f}:{i + 1} ({name or 'module'})")
        new_text[path] = "\n".join(lines)
    # a new name that already exists as a token would merge two variables
    clash = sorted(k for k in (key_of(v) for v in table.values()) if k in all_tokens)
    unused = sorted(k for k in table if k not in stats["count"])
    if mode == "report":
        for k, n in sorted(stats["count"].items()):
            print(f"{n:5d}  {k} -> {table[k]}")
        for where, k in stats["shadowed"]:
            print(f"SHADOWED {k} at {where}")
        for where in stats["label_or_sub"]:
            print(f"left (label or SUB name) {where}")
        print("table entries never used:", unused)
        print("NEW NAMES THAT ALREADY EXIST:", clash)
        print(len(table), "names in the table")
        return 0
    if clash:
        print("refusing to apply: a new name already exists:", clash)
        return 1
    for path, text in new_text.items():
        path.write_bytes(text.encode("latin-1"))
        print("wrote", path.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())
