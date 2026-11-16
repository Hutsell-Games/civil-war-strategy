"""Tests of the tuning knobs' table and the files written from it (no game is run)."""
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools" / "tuning"))
import make_knobs  # noqa: E402


class KnobsTest(unittest.TestCase):
    def test_written_files_are_current(self):
        # io/tuning_knobs.bi, io/tuning_knobs.bm and scenarios/TUNING.DAT match knobs.txt.
        self.assertEqual(0, make_knobs.main(["--check"]))

    def test_shipped_file_names_every_knob_at_its_default(self):
        text = (ROOT / "scenarios" / "TUNING.DAT").read_text(encoding="utf-8")
        found = dict(re.findall(r"^(\w+) = (\S+)", text, re.M))
        knobs = make_knobs.read_table()
        self.assertEqual({k.name: k.default for k in knobs}, found)

    def test_every_knob_is_used_in_the_code(self):
        source = "\n".join(p.read_text(encoding="latin-1") for folder in ("rules", "ai", "ui", "commands")
                           for p in (ROOT / folder).glob("*.bm")) + (ROOT / "cws.bas").read_text(encoding="latin-1")
        unused = [k.name for k in make_knobs.read_table()
                  if not re.search(r"(?<![A-Za-z0-9_])" + re.escape(k.var) + r"(?![A-Za-z0-9_#!])", source)]
        self.assertEqual([], unused)

    def test_a_fraction_is_a_double(self):
        knobs = {k.name: k for k in make_knobs.read_table()}
        self.assertEqual("defense_per_size#", knobs["defense_per_size"].var)
        self.assertEqual("cost_fort", knobs["cost_fort"].var)


if __name__ == "__main__":
    unittest.main()
