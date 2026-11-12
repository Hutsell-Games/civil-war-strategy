#!/usr/bin/env python3
"""Turn shared arrays into fields of records (phase 10 of docs/modernize-plan.md).

    python -I tools/refactor/make_records.py report <record> ...   # counts and problems; changes nothing
    python -I tools/refactor/make_records.py apply <record> ...    # rewrite the sources

<record> is a record of the "Record field" column of docs/variable-names.md; today that is only
armies. `army_size(expr)` becomes `armies(expr).size`, and an array of two indexes, `a(c, j)` with
the field `recs(c).f(...)`, becomes `recs(c).f(j)`.

Uses the tokens of rename_vars.py, so strings, comments, REM and DATA are left alone. A name that a
SUB declares for itself (a parameter, DIM, REDIM or STATIC) is left alone and reported. The
declarations in cws.bi (the COMMON SHARED and DIM SHARED lines) are written by hand: the script
skips them and reports them. The old arrays are then gone, so any use the script missed is a
compile error under OPTION _EXPLICIT.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

ROOT = rv.ROOT
FOLDERS = ["rules", "ai", "commands", "ui", "draw", "game", "port"]
FIELD = re.compile(r"^([a-z_]+)\([^)]*\)\.([a-z_]+)")


def source_files():
    files = [ROOT / "cws.bas", ROOT / "cws.bi", ROOT / "tests" / "rules_test.bas"]
    for folder in FOLDERS:
        files += sorted(p for p in (ROOT / folder).iterdir() if p.suffix.lower() in (".bm", ".bi"))
    return files


def load_table():
    """{old name key: (record, field)} from the "Proposed" and "Record field" columns."""
    text = rv.TABLE.read_text(encoding="utf-8")
    text = text.split("## Armies", 1)[1].split("## Settings", 1)[0]
    table = {}
    for line in text.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 5 or not cells[0].startswith("`"):
            continue
        olds = [n.replace("()", "") for n in re.findall(r"`([^`]+)`", cells[3])]
        fields = re.findall(r"`([^`]+)`", cells[4])
        if not fields or not FIELD.match(fields[0]):
            continue  # not a record: "(stays an array)", "`game\` (phase 11)"
        if len(olds) != len(fields):
            raise SystemExit(f"variable-names.md: {len(olds)} names but {len(fields)} fields: {line}")
        record = None
        for old, f in zip(olds, fields):
            m = FIELD.match(f)
            if m:
                record, field = m.group(1), m.group(2)
            elif f.startswith(".") and record:
                field = f[1:]
            else:
                raise SystemExit(f"variable-names.md: cannot read the field {f!r}: {line}")
            table[rv.key_of(old)] = (record, field)
    return table


def local_arrays(lines, first, last, in_sub):
    """Keys of the arrays a SUB declares for itself: a parameter `a()` or a DIM / REDIM / STATIC
    `a(...)`. A local scalar of a shared array's name does not hide the array: in BASIC,
    `side_cash` and `side_cash()` are two variables (ai_fortify has both)."""
    names = set()
    if not in_sub:
        return names
    for i in range(first, last + 1):
        toks = rv.tokens(lines[i])
        if i == first:
            bodies = [toks[2:]]
        else:
            bodies, statement = [], []
            for t in toks + [(0, 0, ":")]:
                if t[2] != ":":
                    statement.append(t)
                    continue
                if statement and statement[0][2].lower() in ("dim", "redim", "static") and not (
                        len(statement) > 1 and statement[1][2].lower() == "shared"):
                    bodies.append(statement[1:])
                statement = []
        for body in bodies:
            declared = {rv.key_of(n) for n in rv.header_names(body)}
            for n in range(len(body) - 1):
                if body[n + 1][2] == "(" and rv.key_of(body[n][2]) in declared:
                    names.add(rv.key_of(body[n][2]))
    return names


def is_declaration(path, toks):
    """A COMMON SHARED or DIM SHARED line of cws.bi, which is edited by hand."""
    if path.name.lower() != "cws.bi" or len(toks) < 2:
        return False
    return toks[0][2].lower() in ("common", "dim") and toks[1][2].lower() == "shared"


def convert(line, table, hidden, scalars, stats, where):
    """Rewrite the uses of one line, the rightmost first, reading the tokens again after each.
    A use that is skipped (the SUB's own name, or no index after it) is skipped on every pass."""
    while True:
        toks = rv.tokens(line)
        hit = None
        for n in range(len(toks) - 1, -1, -1):
            s, e, tx = toks[n]
            k = rv.key_of(tx)
            if k not in table:
                continue
            if k in hidden:
                stats["shadowed"].add(f"{where}: {tx}")
                continue
            if n + 1 >= len(toks) or toks[n + 1][2] != "(":
                if k not in scalars:  # the SUB's own scalar of that name is not the array
                    stats["bare"].add(f"{where}: {tx}")
                continue
            hit = n
            break
        if hit is None:
            return line
        s, e, tx = toks[hit]
        depth, comma, close = 0, None, None
        for m in range(hit + 1, len(toks)):
            t = toks[m][2]
            if t == "(":
                depth += 1
            elif t == ")":
                depth -= 1
                if depth == 0:
                    close = m
                    break
            elif t == "," and depth == 1 and comma is None:
                comma = m
        if close is None:
            raise SystemExit(f"{where}: no closing parenthesis: {line}")
        record, field = table[rv.key_of(tx)]
        open_end = toks[hit + 1][1]
        if comma is None:
            index = line[open_end:toks[close][0]]
            new = f"{record}({index}).{field}"
        else:
            first = line[open_end:toks[comma][0]]
            second = line[toks[comma][1]:toks[close][0]].lstrip()
            new = f"{record}({first}).{field}({second})"
        line = line[:s] + new + line[toks[close][1]:]
        stats["count"][tx.lower()] = stats["count"].get(tx.lower(), 0) + 1


def main():
    if len(sys.argv) < 3 or sys.argv[1] not in ("report", "apply"):
        print(__doc__)
        return 2
    mode, records = sys.argv[1], {r.lower() for r in sys.argv[2:]}
    table = {k: v for k, v in load_table().items() if v[0] in records}
    if not table:
        raise SystemExit(f"no fields for {sorted(records)} in variable-names.md")
    stats = {"count": {}, "shadowed": set(), "bare": set(), "declarations": []}
    new_text = {}
    all_tokens = set()
    for path in source_files():
        lines = path.read_bytes().decode("latin-1").split("\n")
        for line in lines:
            toks = rv.tokens(line)
            if not is_declaration(path, toks):  # the record's own DIM SHARED is written by hand
                all_tokens.update(rv.key_of(t[2]) for t in toks)
        rel = path.relative_to(ROOT).as_posix()
        for name, first, last in rv.split_scopes(lines):
            hidden = local_arrays(lines, first, last, name is not None)
            scalars = rv.local_names(lines, first, last, name is not None) - hidden
            for i in range(first, last + 1):
                toks = rv.tokens(lines[i])
                if is_declaration(path, toks):
                    if any(rv.key_of(t[2]) in table for t in toks):
                        stats["declarations"].append(f"{rel}:{i + 1}")
                    continue
                lines[i] = convert(lines[i], table, hidden, scalars, stats,
                                   f"{rel}:{i + 1} ({name or 'module'})")
        new_text[path] = "\n".join(lines)
    clash = sorted(r for r in records if r in all_tokens)
    for k, n in sorted(stats["count"].items()):
        record, field = table[rv.key_of(k)]
        print(f"{n:5d}  {k} -> {record}().{field}")
    print("total", sum(stats["count"].values()))
    unused = sorted(k for k in table if k not in {rv.key_of(c) for c in stats["count"]})
    for kind in ("shadowed", "bare", "declarations"):
        for where in sorted(stats[kind]):
            print(f"{kind}: {where}")
    print("fields never used:", unused)
    print("record names that already exist:", clash)
    if mode == "report":
        return 0
    if clash or stats["shadowed"] or stats["bare"]:
        print("refusing to apply: see above")
        return 1
    for path, text in new_text.items():
        if text != path.read_bytes().decode("latin-1"):
            path.write_bytes(text.encode("latin-1"))
            print("wrote", path.relative_to(ROOT).as_posix())
    return 0


if __name__ == "__main__":
    sys.exit(main())
