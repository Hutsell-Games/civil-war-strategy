#!/usr/bin/env python3
"""Split the shared matrix() into city_road(c, 1 TO 6) and city_port_type(c) (phase 4 of docs/modernize-plan.md).

    python tools/refactor/split_matrix.py report
    python tools/refactor/split_matrix.py apply

matrix(c, 7) becomes city_port_type(c); every other matrix(a, b) becomes city_road(a, b).
Inside SUB hall_of_fame, matrix is only scratch space for the scores: it becomes hall_score, a local array.
The line that reads cities.grd is rewritten by hand-written text below.
Uses the tokens of rename_vars.py, so strings, comments and DATA are left alone.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

READ_OLD = "FOR j = 1 TO 7: INPUT #1, matrix(i, j): NEXT j: INPUT #1, city_fort(i)"
READ_NEW = "FOR j = 1 TO 6: INPUT #1, city_road(i, j): NEXT j: INPUT #1, city_port_type(i), city_fort(i)"


def convert(line, in_hall):
    """Rewrite the matrix( ... ) calls of one line; return (new line, count)."""
    toks = rv.tokens(line)
    out = line
    count = 0
    for n in range(len(toks) - 1, -1, -1):
        s, e, tx = toks[n]
        if rv.key_of(tx) != "matrix" or n + 1 >= len(toks) or toks[n + 1][2] != "(":
            continue
        # find the comma at depth 1 and the closing paren
        depth = 0
        comma = close = None
        for m in range(n + 1, len(toks)):
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
        if comma is None or close is None:
            raise SystemExit("cannot parse: " + line)
        if in_hall:
            new = "hall_score"
        else:
            second = "".join(t[2] for t in toks[comma + 1:close]).strip()
            if second == "7":
                # matrix(first, 7) -> city_port_type(first)
                first_end = toks[comma][0]
                out = out[:s] + "city_port_type" + out[toks[n + 1][0]:first_end] + out[toks[close][0]:]
                count += 1
                continue
            new = "city_road"
        out = out[:s] + new + out[e:]
        count += 1
    return out, count


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    total = 0
    out = {}
    for f in rv.FILES:
        path = rv.ROOT / f
        if not path.exists():
            continue
        lines = path.read_bytes().decode("latin-1").split("\n")
        for name, first, last in rv.split_scopes(lines):
            in_hall = (name or "").lower() == "hall_of_fame"
            for i in range(first, last + 1):
                if lines[i].strip() == READ_OLD:
                    lines[i] = lines[i].replace(READ_OLD, READ_NEW)
                    total += 1
                    continue
                if f.endswith(".BI") and "matrix" in lines[i].lower():
                    continue  # declarations are edited by hand
                lines[i], c = convert(lines[i], in_hall)
                total += c
        out[path] = "\n".join(lines)
    print(total, "changes")
    if mode == "report":
        return 0
    for path, text in out.items():
        path.write_bytes(text.encode("latin-1"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
