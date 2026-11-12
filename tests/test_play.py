"""Tests of play.py's parts that need no build:  python -m unittest discover -s tests -p "test_*.py" """

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

STATE = b"screen-state 1\npages 1 display 0 write 0 read 0\np 00*640\nend\n"


class EntriesTest(unittest.TestCase):
    def test_states_digests_and_stopped(self):
        data = b"digest 0123456789ABCDEF\n" + STATE + b"stopped k line 3: no prompt in time\n"
        self.assertEqual(
            play.entries(data),
            [b"digest 0123456789ABCDEF", STATE, b"stopped k line 3: no prompt in time"],
        )

    def test_a_state_cut_short_is_kept(self):
        self.assertEqual(play.entries(b"screen-state 1\np 00\n"), [b"screen-state 1\np 00\n"])

    def test_empty(self):
        self.assertEqual(play.entries(b""), [])


class DigestTest(unittest.TestCase):
    def test_fnv1a64_known_values(self):
        self.assertEqual(play.fnv1a64(b""), 0xCBF29CE484222325)
        self.assertEqual(play.fnv1a64(b"a"), 0xAF63DC4C8601EC8C)

    def test_a_digest_matches_its_state(self):
        digest = play.as_digest(STATE)
        self.assertTrue(play.same(digest, STATE))
        self.assertTrue(play.same(STATE, digest))
        self.assertFalse(play.same(b"digest 0000000000000000", STATE))

    def test_first_difference(self):
        a = [b"digest 1", STATE]
        self.assertIsNone(play.first_difference(a, [b"digest 1", play.as_digest(STATE)]))
        self.assertEqual(play.first_difference(a, [b"digest 2", STATE]), 0)
        self.assertEqual(play.first_difference(a, a[:1]), 1)


class CheckpointsTest(unittest.TestCase):
    def test_repeat_blocks_are_unrolled(self):
        keys = "\n".join([
            "digest",          # 1
            "repeat 2",        # 2
            "play until 2:M",  # 3
            "state  # here",   # 4
            "repeat 2",        # 5
            "digest",          # 6
            "end",             # 7
            "end",             # 8
            "state",           # 9
            "repeat space",    # 10
        ])
        self.assertEqual(play.checkpoints(keys), [1, 4, 6, 6, 4, 6, 6, 9])

    def test_describe(self):
        keys = Path("k.keys")
        self.assertIn("line 9", play.describe(1, [1, 9], keys))
        self.assertIn("the state at exit", play.describe(2, [1, 9], keys))


class ScriptTest(unittest.TestCase):
    def load(self, text):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "s.keys"
            path.write_text(text)
            return play.load_script(path)

    def test_setup_lines(self):
        s = self.load("#! seed 42\n#! cfg side=2 difficult=1\n#! timeout 60\n# a comment\nkey space\n")
        self.assertEqual(s.seed, "42")
        self.assertEqual(s.timeout, 60)
        self.assertEqual(s.cfg["side"], "2")
        self.assertEqual(s.cfg["difficult"], "1")
        self.assertEqual(s.cfg["noise"], "0")

    def test_unknown_field(self):
        with self.assertRaises(play.SetupError):
            self.load("#! cfg colour=3\n")

    def test_unknown_setup_line(self):
        with self.assertRaises(play.SetupError):
            self.load("#! speed 3\n")

    def test_program_files_and_altmap(self):
        s = self.load("#! program cws\n#! files cws.his HISCORE.CWS\n#! files cws1.sav\n#! altmap\n")
        self.assertEqual(s.program, "cws")
        self.assertEqual(s.files, ["cws.his", "HISCORE.CWS", "cws1.sav"])
        self.assertTrue(s.altmap)
        plain = self.load("key space\n")
        self.assertEqual(plain.program, "cws")
        self.assertFalse(plain.altmap)

    def test_unknown_program(self):
        with self.assertRaises(play.SetupError):
            self.load("#! program demo\n")

    def test_file_entries(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "cws.his").write_bytes(b"a\r\nb\r\n")
            (Path(d) / "lf.txt").write_bytes(b"a\nb\n")
            lines = play.file_entries(Path(d), ["CWS.HIS", "lf.txt", "none.dat"]).decode().splitlines()
            # CRLF and LF give the same hash; the name matches whatever its case.
            self.assertEqual(lines[0].split()[:2], ["file", "CWS.HIS"])
            self.assertEqual(lines[0].split()[2], lines[1].split()[2])
            self.assertEqual(lines[2], "file none.dat missing")
            # Each line is an entry of its own, after the states.
            self.assertEqual(play.entries(STATE + "\n".join(lines).encode() + b"\n")[1:],
                             [line.encode() for line in lines])

    def test_file_entries_in_a_folder(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "Scenarios").mkdir()
            (Path(d) / "Scenarios" / "cities.grd").write_bytes(b"a\n")
            names = ["scenarios/CITIES.GRD", "scenarios/none.grd", "nofolder/a.grd", "Scenarios"]
            lines = play.file_entries(Path(d), names).decode().splitlines()
            # Each part matches whatever its case; a folder is not a file.
            self.assertEqual(lines[0].split()[:2], ["file", "scenarios/CITIES.GRD"])
            self.assertEqual(lines[1:], ["file scenarios/none.grd missing",
                                         "file nofolder/a.grd missing", "file Scenarios missing"])

    def test_files_only_after_a_run_that_ended_well(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "a.dat").write_bytes(b"a\n")
            script = self.load("#! files a.dat\n")
            ok = play.with_files(play.Run(script, "c", "", 0, STATE, Path(d)), Path(d))
            self.assertTrue(play.entries(ok.state)[-1].startswith(b"file a.dat "))
            # A stopped run keeps "stopped" as its last entry, so the reason for the failure shows.
            stopped = STATE + b"stopped k line 3: no prompt in time\n"
            bad = play.with_files(play.Run(script, "c", "", 125, stopped, Path(d)), Path(d))
            self.assertEqual(bad.state, stopped)
            self.assertIn("no prompt in time", play.run_problem(bad))

    def test_cfg_is_one_line_in_the_games_order(self):
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "Cws.cfg").write_text("old")
            play.write_cfg(Path(d), dict(play.CFG_FIELDS, side="2"))
            # The copy of the repo's file goes, whatever the case of its name.
            self.assertEqual([p.name for p in Path(d).iterdir()], ["CWS.CFG"])
            self.assertEqual((Path(d) / "CWS.CFG").read_text(),
                             "2,3,0,3,1,1,7,600,300,1,1,36,134,3992,5041,0,3\n")

    def test_altmap_switches_the_three_files(self):
        with tempfile.TemporaryDirectory() as d:
            for name in ("CITIES.GRD", "CWS.INI", "CWSLEAD.DAT"):
                (Path(d) / name).write_text("own " + name)
            for name in ("altmap.grd", "ALTMAP.INI", "ALTLEAD.DAT"):
                (Path(d) / name).write_text("alt " + name)
            play.swap_altmap(Path(d))
            self.assertEqual((Path(d) / "CITIES.GRD").read_text(), "alt altmap.grd")
            self.assertEqual((Path(d) / "altmap.grd").read_text(), "own CITIES.GRD")
            self.assertEqual((Path(d) / "CWS.INI").read_text(), "alt ALTMAP.INI")
            self.assertEqual((Path(d) / "CWSLEAD.DAT").read_text(), "alt ALTLEAD.DAT")


class CopyDataTest(unittest.TestCase):
    def make_game(self, game):
        """A game folder with its two data folders, one file in each."""
        game.mkdir()
        for folder, name in (("graphics", "MTN.VGA"), ("scenarios", "CITIES.GRD")):
            (game / folder).mkdir()
            (game / folder / name).write_text(name)

    def test_data_files_and_test_data(self):
        with tempfile.TemporaryDirectory() as d:
            game, data, work = Path(d) / "game", Path(d) / "data", Path(d) / "work"
            self.make_game(game)
            data.mkdir()
            work.mkdir()
            (game / "CWS.CFG").write_text("settings")
            (game / "CWSTRAT.BAS").write_text("source")
            (game / "README.md").write_text("document")
            (game / "cws.exe").write_text("build")
            (game / "HISCORE.CWS").write_text("repo")
            (data / "HISCORE.CWS").write_text("test data")
            play.copy_data(work, game, data)
            # The data folders are copied whole; sources, documents and builds are left out.
            self.assertEqual(sorted(p.name for p in work.iterdir()),
                             ["CWS.CFG", "HISCORE.CWS", "graphics", "scenarios"])
            self.assertEqual((work / "scenarios" / "CITIES.GRD").read_text(), "CITIES.GRD")
            self.assertEqual((work / "HISCORE.CWS").read_text(), "test data")

    def test_no_test_data_folder(self):
        with tempfile.TemporaryDirectory() as d:
            game, work = Path(d) / "game", Path(d) / "work"
            self.make_game(game)
            work.mkdir()
            (game / "HISCORE.CWS").write_text("x")
            play.copy_data(work, game, Path(d) / "none")
            self.assertEqual(sorted(p.name for p in work.iterdir()), ["HISCORE.CWS", "graphics", "scenarios"])


class CoverageTest(unittest.TestCase):
    UNIT = (
        "coverage 2\n"
        "file\t0\taaaa\trules_test.bas.test-entry.bas\n"
        "file\t1\tbbbb\trules_test.bas\n"
        "file\t2\tcccc\t../cwstrat2.bm\n"
        "0\t3\t1\t1\t\n"
        "1\t9\t1\t1\t\n"
        "2\t10\t1\t1\tLEN\n"
        "2\t11\t1\t0\t\n"
        "end\n"
    )

    def test_rebase_keeps_only_the_games_files(self):
        self.assertEqual(
            play.rebase_records(self.UNIT * 2),
            ("coverage 2\nfile\t2\tcccc\tcwstrat2.bm\n2\t10\t1\t1\tLEN\n2\t11\t1\t0\t\nend\n") * 2,
        )

    def test_rebase_keeps_a_file_in_a_folder_of_the_game(self):
        text = "coverage 2\nfile\t5\tcccc\t../rules/army.bm\n5\t10\t1\t1\t\nend\n"
        self.assertEqual(play.rebase_records(text), "coverage 2\nfile\t5\tcccc\trules/army.bm\n5\t10\t1\t1\t\nend\n")

    def test_reached_only_by_the_unit_tests(self):
        with tempfile.TemporaryDirectory() as d:
            unit, script = Path(d) / "unit.txt", Path(d) / "script.txt"
            unit.write_text(play.rebase_records(self.UNIT), encoding="latin-1")
            # The script ran line 11, which the unit tests did not, and not line 10, which they did.
            script.write_text(
                "coverage 2\nfile\t5\tcccc\tcwstrat2.bm\n5\t10\t1\t0\t\n5\t11\t1\t4\t\nend\n", encoding="latin-1"
            )
            self.assertEqual(play.reached_only_by(unit, [script]), 1)
            self.assertEqual(play.statement_counts([unit, script])[("cwstrat2.bm", 11, 1)], 4)

    def test_sub_table_names_the_main_module_of_the_program(self):
        with tempfile.TemporaryDirectory() as d:
            counts = Path(d) / "cws.txt"
            counts.write_text("coverage 2\nfile\t1\tcccc\tCWSTRAT.BAS\n1\t50\t1\t2\t\nend\n", encoding="latin-1")
            # Line 50 of CWSTRAT.BAS is in its main module, which has no SUB.
            self.assertIn("(main module)", play.sub_table([counts], "cwstrat.bas"))


class MakeScriptsTest(unittest.TestCase):
    def test_script_names(self):
        import make_scripts
        self.assertEqual(make_scripts.Game("pass", 1861, 1).name, "pass-union-1861")
        self.assertEqual(make_scripts.Game("pass", 1865, 2, altmap=True).name, "pass-rebel-altmap")
        self.assertEqual(make_scripts.Game("war", 1867, 2).name, "war-rebel-1867")
        names = [g.name for g in make_scripts.GAMES]
        self.assertEqual(len(names), len(set(names)))

    def test_settings_go_with_the_seed(self):
        import make_scripts
        game = make_scripts.Game("pass", 1862, 2)
        self.assertEqual(game.settings["side"], "2")
        self.assertEqual(game.settings["history"], "1")
        self.assertEqual(game.settings["bold"], "5")
        for g in make_scripts.GAMES:
            for field in g.settings:
                self.assertIn(field, play.CFG_FIELDS)

    def test_months_and_checkpoints(self):
        import make_scripts
        game = make_scripts.Game("pass", 1861, 1)
        lines = [*make_scripts.header(game, ""), *make_scripts.months(3), *make_scripts.ending(True)]
        # The title menu, three months, Game Over and the title menu again.
        self.assertEqual(len(play.checkpoints("\n".join(lines))), 1 + 3 + 2)
        war = make_scripts.header(make_scripts.Game("war", 1866, 1), "")
        # A war game adds one digest, at the Victory Conditions menu.
        self.assertEqual(len(play.checkpoints("\n".join(war))), 2)
        self.assertNotIn("play until 4", make_scripts.ending(False))

    def test_a_probe_has_no_rule_for_game_over(self):
        import make_scripts
        game = make_scripts.Game("pass", 1861, 1)
        probe = make_scripts.header(game, "", probe=True)
        self.assertNotIn("rule 1 key space", probe)
        self.assertNotIn("rule 1:G key space", probe)
        self.assertIn("rule 1:B key space", probe)
        self.assertIn("rule 1 key space", make_scripts.header(game, ""))


class TestDataTest(unittest.TestCase):
    def load(self, text):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "s.keys"
            path.write_text(text)
            return play.load_script(path)

    def test_without_and_dice_lines(self):
        s = self.load("#! without graphics/MTN.VGA\n#! dice 0,.05,r;0,.9\n")
        self.assertEqual(s.without, ["graphics/MTN.VGA"])
        self.assertEqual(s.dice, "0,.05,r;0,.9")
        self.assertEqual(self.load("key space\n").dice, "")

    def test_bad_dice_and_unknown_data_folder(self):
        with self.assertRaises(play.SetupError):
            self.load("#! dice 0.5 0.6\n")
        with self.assertRaises(play.SetupError):
            self.load("#! dice high\n")
        with self.assertRaises(play.SetupError):
            self.load("#! data no-such-folder-of-test-data\n")

    def test_a_data_folder_replaces_files_whatever_their_case(self):
        with tempfile.TemporaryDirectory() as d:
            work, source = Path(d) / "work", Path(d) / "source"
            (work / "scenarios").mkdir(parents=True)
            (work / "scenarios" / "CITIES.GRD").write_text("the game's")
            (source / "Scenarios").mkdir(parents=True)
            (source / "Scenarios" / "cities.grd").write_text("broken")
            (source / "cws1.sav").write_text("a save")
            play.copy_test_folder(work, source)
            self.assertEqual([p.name for p in (work / "scenarios").iterdir()], ["cities.grd"])
            self.assertEqual((work / "scenarios" / "cities.grd").read_text(), "broken")
            self.assertEqual((work / "cws1.sav").read_text(), "a save")

    def test_without_removes_a_file_or_fails(self):
        with tempfile.TemporaryDirectory() as d:
            work = Path(d)
            (work / "graphics").mkdir()
            (work / "graphics" / "MTN.VGA").write_text("x")
            play.remove_files(work, ["GRAPHICS/mtn.vga"])
            self.assertEqual(list((work / "graphics").iterdir()), [])
            with self.assertRaises(play.SetupError):
                play.remove_files(work, ["graphics/mtn.vga"])


class MakeSaveTest(unittest.TestCase):
    SCENARIOS = play.GAME / "scenarios"

    def game(self, description=""):
        import make_save
        game = make_save.opening(self.SCENARIOS)
        make_save.apply(game, description, "test")
        return game

    def test_the_opening_position(self):
        import make_save
        game = self.game()
        self.assertEqual((game["month"], game["year"]), (3, 1861))
        self.assertEqual(game["cash"], [300, 50])
        self.assertEqual(game["capital"], [39, 33])
        self.assertEqual(game["fleet"], [["WWWW", 30], ["W", 24]])
        self.assertEqual(game["armies"][1]["name"], "McDowell")
        self.assertEqual(game["armies"][1]["city"], 39)
        self.assertEqual(sum(1 for a in game["armies"].values() if a), 9)
        lines = make_save.save_text(game).splitlines()
        self.assertEqual(len(lines), 85)
        self.assertEqual(lines[0], "3,1861,252,1")
        self.assertEqual(lines[1], '"McDowell",400,4,39,1,9,0')
        # City 39 holds army 1; city 1 is the Rebels' and holds no army.
        self.assertEqual(lines[41 + 38].split(",")[0], "1")
        self.assertEqual(lines[41], "0,2,0")
        self.assertEqual(lines[82], '"WWWW",30,0,0,0')

    def test_a_description_changes_the_position(self):
        import make_save
        game = self.game("# late in the war\ndate 11 1864\nside 2\ncash 5 9000\nowner 1 1-40\nowner 2 1-30\nfort 2 5 6\n"
                         "fleet 1 - 0\nfleet 2 wwi 99\narmy 22 city=4 size=50 name=Old_Jack\nnoarmy 2-5\n"
                         "capital 39 0\ntrain 1 1 2\n")
        lines = make_save.save_text(game).splitlines()
        self.assertEqual(lines[0], "11,1864,252,2")
        self.assertEqual(lines[2], '"",0,0,0,0,0,0')
        self.assertEqual(lines[22].split(",")[:2], ['"Old Jack"', "50"])
        self.assertEqual(sum(1 for line in lines[41:81] if line.split(",")[1] == "2"), 30)
        self.assertEqual(lines[41 + 4], lines[41 + 4].split(",")[0] + ",2,2")
        self.assertEqual(lines[81].split(",")[0], "5")
        self.assertEqual(lines[82], '"",0,0,1,2')
        self.assertEqual(lines[83].split(",")[1], "30")
        self.assertEqual(lines[83].split(",")[4], "0")
        self.assertEqual(lines[84], '"WWI",99,0,0,0')

    def test_bad_lines(self):
        import make_save
        for bad in ("owner 2 41", "army 1 colour=3", "date eleven 1864", "fleet 1 XX 3", "speed 3"):
            with self.assertRaises(make_save.SaveError):
                self.game(bad)


if __name__ == "__main__":
    unittest.main()
