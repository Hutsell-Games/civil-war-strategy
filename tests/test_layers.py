"""The folder rules of the source, checked on its text:  python -m unittest discover -s tests -p "test_*.py"

Each folder keeps a rule (docs\\modernize-plan.md, "File layout at the end"):

- rules\\ draws nothing, prints nothing, plays nothing and reads no key. It calls nothing in ui\\,
  draw\\, game\\ or commands\\, so tests\\rules_test.bas can call every SUB in it.
- ai\\ draws, prints and reads nothing itself. Its messages are SUBs of ui\\ai.bm, and it carries out
  an order through commands\\, as the player's menus do. It calls nothing else in ui\\, draw\\ or game\\.
- commands\\ may draw and print, but opens no menu and reads no key.

The few calls that break a rule today are listed in ALLOWED, each with its reason. A new one fails
the test. Remove a row when its call goes.
"""

import re
import unittest
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Statements and functions that use the screen, the speaker or the keyboard.
SCREEN = {
    "print", "locate", "color", "cls", "pset", "preset", "circle", "paint", "draw", "line", "view",
    "window", "palette", "pcopy", "point", "csrlin", "pos", "screen", "_display", "_putimage",
    "_printstring", "get", "put", "sound", "play", "beep",
}
KEYS = {"inkey$", "input", "_keyhit", "_keydown", "sleep"}

# (folder of the caller, caller, callee): why the call stays for now.
ALLOWED = {
    ("ai", "ai_fortify", "draw_fort_built"):
        "the fort's message and flash, shared with the player's Fortify (ui/orders.bm)",
    ("ai", "ai_navy_adjust", "menu_navy_items"):
        "fills the Ships menu's texts and draws nothing; ai_navy_adjust reads menu_item_count = 5 "
        "for Invasion",
    ("ai", "ai_recruit", "menu_recruit_cities"):
        "sets COLOR_LIGHT_RED, the color that draw_ai_funds then prints in, and lists the cities",
    ("rules", "army_list_combine_cities", "menu_bubble_sort"):
        "sorts the menu's arrays and draws nothing; the list is returned in the menu's globals",
    ("rules", "army_recruit_cities", "menu_bubble_sort"):
        "sorts the menu's arrays and draws nothing; the list is returned in the menu's globals",
}

TOKEN = re.compile(r'"[^"]*"?|\'.*|[A-Za-z_][A-Za-z0-9_.]*[$!%&#]?')
PROC = re.compile(r"^\s*(SUB|FUNCTION)\s+([A-Za-z_][A-Za-z0-9_.]*[$!%&#]?)", re.I)
END_PROC = re.compile(r"^\s*END\s+(SUB|FUNCTION)\b", re.I)


def words(line):
    """The names and keywords of a line, lower case, without its strings and its comment."""
    out = []
    for tok in TOKEN.findall(line):
        if tok.startswith('"'):
            continue
        if tok.startswith("'"):
            break
        tok = tok.lower()
        if tok == "rem":
            break
        out.append(tok)
    return out


def read_source():
    """Each procedure's folder, and the words of its body: {name: (folder, [(line number, words)])}."""
    procs = {}
    for path in sorted(ROOT.glob("*/*.bm")):
        folder = path.parent.name
        if folder in ("tests", "tools"):
            continue
        name = None
        for n, line in enumerate(path.read_text(encoding="cp437").splitlines(), 1):
            m = PROC.match(line)
            if m:
                name = m.group(2).lower()
                procs[name] = (folder, path.relative_to(ROOT).as_posix(), [])
                continue
            if END_PROC.match(line):
                name = None
                continue
            if name:
                procs[name][2].append((n, words(line)))
    return procs


class LayersTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.procs = read_source()
        cls.home = {name: folder for name, (folder, _, _) in cls.procs.items()}
        cls.file = {name: file for name, (_, file, _) in cls.procs.items()}

    def problems(self, folder, forbidden_words, forbidden_folders, allowed_files=()):
        found = []
        used = set()
        for caller, (where, file, body) in self.procs.items():
            if where != folder:
                continue
            for n, line in body:
                for i, w in enumerate(line):
                    if w in forbidden_words:
                        # LINE INPUT # and INPUT # read a file, not the keyboard.
                        if w in ("input", "line") and i + 1 < len(line) and line[i + 1] in ("input",):
                            continue
                        found.append(f"{file}:{n} {caller}: {w.upper()}")
                    callee_home = self.home.get(w)
                    if callee_home in forbidden_folders and self.file[w] not in allowed_files:
                        key = (folder, caller, w)
                        if key in ALLOWED:
                            used.add(key)
                            continue
                        found.append(f"{file}:{n} {caller}: calls {w} ({self.file[w]})")
        return found, used

    def test_rules_draw_nothing_and_call_no_screen(self):
        found, _ = self.problems("rules", SCREEN | KEYS, {"ui", "draw", "game", "commands"})
        self.assertEqual(found, [], "rules\\ must not use the screen, the keyboard or a screen SUB")

    def test_ai_draws_nothing_itself(self):
        found, _ = self.problems("ai", SCREEN | KEYS, {"ui", "draw", "game"}, allowed_files=("ui/ai.bm",))
        self.assertEqual(found, [], "ai\\ shows its messages through ui/ai.bm and acts through commands\\")

    def test_commands_open_no_menu_and_read_no_key(self):
        found = []
        for caller, (where, file, body) in self.procs.items():
            if where != "commands":
                continue
            for n, line in body:
                for i, w in enumerate(line):
                    if w in KEYS and not (w == "input" and i > 0 and line[i - 1] == "line"):
                        found.append(f"{file}:{n} {caller}: {w.upper()}")
                    if w == "menu_select" or (w in self.home and w.startswith("menu_") and self.home[w] == "ui"):
                        found.append(f"{file}:{n} {caller}: calls {w}")
        self.assertEqual(found, [], "commands\\ must not open a menu or read a key")

    def test_every_allowed_call_still_happens(self):
        used = set()
        for folder in {k[0] for k in ALLOWED}:
            forbidden = {"ui", "draw", "game"} | ({"commands"} if folder == "rules" else set())
            _, u = self.problems(folder, set(), forbidden, allowed_files=("ui/ai.bm",) if folder == "ai" else ())
            used |= u
        self.assertEqual(sorted(set(ALLOWED) - used), [], "remove the rows of ALLOWED whose call is gone")

    def test_the_check_sees_the_source(self):
        # A guard against a check that passes because it read nothing.
        folders = defaultdict(int)
        for folder, _, _ in self.procs.values():
            folders[folder] += 1
        for folder in ("rules", "ai", "commands", "ui", "draw"):
            self.assertGreater(folders[folder], 0, folder)
        self.assertEqual(self.home.get("ai_evaluate_move"), "ai")
        self.assertEqual(self.home.get("draw_map"), "draw")


if __name__ == "__main__":
    unittest.main()
