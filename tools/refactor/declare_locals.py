#!/usr/bin/env python3
"""Declare the variables that OPTION _EXPLICIT reports (phase 4 of docs/modernize-plan.md).

    python -I tools/refactor/declare_locals.py <qb64rust.exe>

Compiles CWSTRAT.BAS, reads each "variable `x` (TYPE) is not declared" error, and puts a DIM line with
the variable at the top of the SUB or FUNCTION it is in (or of the main program, after the include of
cws14.bi). Repeats, because the compiler stops after 100 errors. Nothing else is touched. A variable
gets the type the compiler reports, which under DEFINT A-Z is the type it already has.
"""
import re
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

ERR = re.compile(r"^(.+?):(\d+):\d+: error: variable `([^`]+)` \((\w+)\) is not declared")
MAIN = "CWSTRAT.BAS"


def compile_errors(exe):
    out = Path(tempfile.gettempdir()) / "declare_locals.exe"
    r = subprocess.run([exe, "-c", MAIN, "-o", str(out)], cwd=rv.ROOT, capture_output=True, text=True)
    return r.stdout + r.stderr


def declaration(name, typ):
    if name[-1] in "$%&!#":
        return "DIM " + name
    return f"DIM {name} AS {typ}"


def main():
    exe = sys.argv[1]
    for rounds in range(60):
        text = compile_errors(exe)
        found = {}  # (file, scope first line) -> {key: (name, type)}
        other = []
        files = {}
        for line in text.splitlines():
            m = ERR.match(line)
            if not m:
                if " error: " in line and "too many errors" not in line:
                    other.append(line)
                continue
            f, n, name, typ = m.group(1).replace("\\", "/"), int(m.group(2)) - 1, m.group(3), m.group(4)
            if f not in files:
                files[f] = (rv.ROOT / f).read_bytes().decode("latin-1").split("\n")
            lines = files[f]
            for scope, first, last in rv.split_scopes(lines):
                if first <= n <= last:
                    if scope is None:
                        at = next(i for i, l in enumerate(lines) if "$include" in l.lower() and "cws14.bi" in l.lower())
                    else:
                        at = first
                    found.setdefault((f, at), {})[rv.key_of(name)] = (name, typ)
                    break
        if other:
            print("\n".join(other[:20]))
            return 1
        if not found:
            print("no more undeclared variables after", rounds, "rounds")
            return 0
        for f in {k[0] for k in found}:
            lines = files[f]
            for (ff, at), names in sorted(found.items(), key=lambda kv: -kv[0][1]):
                if ff != f:
                    continue
                eol = "\r" if lines[at].endswith("\r") else ""
                dim = ": ".join(declaration(n, t) for n, t in names.values())
                lines.insert(at + 1, dim + eol)
            (rv.ROOT / f).write_bytes("\n".join(lines).encode("latin-1"))
        print("round", rounds, ":", sum(len(v) for v in found.values()), "names declared")
    return 1


if __name__ == "__main__":
    sys.exit(main())
