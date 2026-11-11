#!/usr/bin/env python3
"""Move the SUBs into the files of docs/file-layout.md (phase 6 of docs/modernize-plan.md).

    python -I tools/refactor/move_subs.py report   # checks the table against the sources; changes nothing
    python -I tools/refactor/move_subs.py apply    # git mv's the files, writes the new ones, fixes the includes

Each SUB moves whole, with the comment lines just above it. Inside a file the SUBs keep their old order
(CWSTRAT1.BM, then CWSTRAT2.BM, then CWSMENU.BM). The three old files are renamed with `git mv` to a new
file, so that no tracked file is deleted by hand. SCRIPT.BM, QB64.BM and FOLDERS.BI move whole into port\\.
"""
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename_vars as rv  # noqa: E402

ROOT = rv.ROOT
LAYOUT = ROOT / "docs" / "file-layout.md"
OLD = ["CWSTRAT1.BM", "CWSTRAT2.BM", "CWSMENU.BM"]
# old file -> the new file it is renamed to (git mv), whose content is then replaced
RENAMED = {"CWSTRAT1.BM": "rules/army.bm", "CWSTRAT2.BM": "ui/screen.bm", "CWSMENU.BM": "ui/menu.bm"}
WHOLE = {"SCRIPT.BM": "port/script.bm", "QB64.BM": "port/qb64.bm", "FOLDERS.BI": "port/folders.bi"}
FOLDERS = ["rules", "ai", "ui", "draw", "game", "port"]


def load_layout():
    """{sub name lower: new file}, and the new files in the order of the table."""
    where = {}
    order = []
    folder = None
    for line in LAYOUT.read_text(encoding="utf-8").split("## Questions", 1)[0].splitlines():
        m = re.match(r"## (\w+)\\", line)
        if m:
            folder = m.group(1)
            continue
        m = re.match(r"\| `([a-z_0-9.]+)` \| (.*) \|$", line)
        if not m or folder is None or m.group(1) in ("qb64.bm", "script.bm"):
            continue
        path = f"{folder}/{m.group(1)}"
        order.append(path)
        for name in re.findall(r"`([A-Za-z_0-9$%]+)`", m.group(2)):
            where[name.lower()] = path
    return where, order


def blocks(lines, label):
    """[(name, [lines])]: each SUB with the comment and blank lines above it."""
    out = []
    pending = []
    for name, first, last in rv.split_scopes(lines):
        chunk = lines[first:last + 1]
        if name is None:
            for l in chunk:
                s = l.strip()
                if s and not s.startswith("'"):
                    raise SystemExit(f"{label}: code outside a SUB: {s[:60]}")
            pending = chunk
        else:
            out.append((name, pending + chunk))
            pending = []
    return out


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    where, order = load_layout()
    found = {}
    for f in OLD:
        lines = (ROOT / f).read_bytes().decode("latin-1").split("\n")
        for name, chunk in blocks(lines, f):
            found[name.lower()] = (f, chunk)
    missing = sorted(set(found) - set(where))
    unknown = sorted(set(where) - set(found))
    print(len(found), "SUBs in the old files;", len(where), "in the table")
    if missing or unknown:
        print("not in the table:", missing)
        print("in the table but not in the sources:", unknown)
        return 1
    # keep the old order inside each new file
    old_pos = {n: i for i, n in enumerate(found)}
    files = {}
    for name in sorted(found, key=old_pos.get):
        files.setdefault(where[name], []).append(found[name][1])
    for path in order:
        print(f"{path:28s} {len(files.get(path, []))} SUBs")
    if mode == "report":
        return 0
    for d in FOLDERS:
        (ROOT / d).mkdir(exist_ok=True)
    for old, new in {**RENAMED, **WHOLE}.items():
        subprocess.run(["git", "mv", old, new], cwd=ROOT, check=True)
    for path, chunks in files.items():
        text = []
        for chunk in chunks:
            while chunk and not chunk[0].strip():
                chunk = chunk[1:]
            text.extend(chunk + [""])
        (ROOT / path).write_bytes("\n".join(text).encode("latin-1"))
    # the includes of the main program and of the folders file
    main_bas = ROOT / "CWSTRAT.BAS"
    lines = main_bas.read_bytes().decode("latin-1").split("\n")
    keep = [l for l in lines if not re.match(r"' \$INCLUDE: '(cwstrat1|cwstrat2|cwsmenu|qb64|script)\.bm'", l)]
    incl = [f"' $INCLUDE: '{p}'" for p in order] + ["' $INCLUDE: 'port/qb64.bm'", "' $INCLUDE: 'port/script.bm'"]
    # the old includes were the last five lines; put the new ones at the end
    eol = "\r" if lines[-2].endswith("\r") else ""
    while keep and not keep[-1].strip():
        keep.pop()
    keep += [l + eol for l in incl] + [""]
    main_bas.write_bytes("\n".join(keep).encode("latin-1"))
    bi = ROOT / "CWS14.BI"
    t = bi.read_bytes().decode("latin-1").replace("' $INCLUDE: 'folders.bi'", "' $INCLUDE: 'port/folders.bi'")
    bi.write_bytes(t.encode("latin-1"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
