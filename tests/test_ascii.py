"""The BASIC source is plain ASCII:  python -m unittest discover -s tests -p "test_*.py"

A character above 127, such as a box-drawing line or a check mark, is written with its code
page 437 number: CHR$(201), or STRING$(57, 178). Then QB64pe, QB64Rust and QBJS read the file
the same way, and the file is UTF-8 too, so any editor or tool can change it without changing
its bytes. A file with one byte above 127 is not UTF-8, and editing tools that write UTF-8
refuse the whole file.

A control character (bytes 1 to 31 and 127, but tab, LF and CR) is written the same way, such as
CHR$(14) for the note of the sound menu. In a string it is invisible in diffs and terminals.
"""

import os
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Folders of copies and build output, not source.
SKIP = {"out", "build", ".git", "node_modules"}

SOURCE = {".bas", ".bi", ".bm"}

# The bytes a source file may hold: tab, LF, CR and 32 to 126.
ALLOWED = {9, 10, 13, *range(32, 127)}


def sources():
    """The BASIC files of the repo, outside SKIP."""
    for folder, subfolders, files in os.walk(ROOT):
        subfolders[:] = sorted(d for d in subfolders if d not in SKIP)
        for name in sorted(files):
            if Path(name).suffix.lower() in SOURCE:
                yield Path(folder) / name


class AsciiSource(unittest.TestCase):
    """Every BASIC file holds the bytes of ALLOWED only."""

    def test_sources_are_found(self):
        self.assertIn(ROOT / "cws.bas", list(sources()))

    def test_no_byte_above_127_or_control_character(self):
        problems = []
        for path in sources():
            for number, line in enumerate(path.read_bytes().split(b"\n"), 1):
                column = next((i for i, b in enumerate(line, 1) if b not in ALLOWED), None)
                if column is not None:
                    byte = line[column - 1]
                    what = f"`{bytes([byte]).decode('cp437')}`" if byte > 127 else "a control character"
                    where = f"{path.relative_to(ROOT).as_posix()}:{number}:{column}"
                    problems.append(f"{where}: {what} is byte {byte}; write it as CHR$({byte})")
        self.assertEqual(problems, [], "\n" + "\n".join(problems))


if __name__ == "__main__":
    unittest.main()
