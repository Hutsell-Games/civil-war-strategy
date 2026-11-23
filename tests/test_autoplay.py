"""Tests of autoplay.py's keys file and results (no game is run)."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import autoplay  # noqa: E402


class KeysTest(unittest.TestCase):
    def test_two_player_game_with_even_balance(self):
        keys = autoplay.keys_for(7, "two", 1, False)
        self.assertIn("#! seed 7", keys)
        self.assertIn("player=2", keys)
        self.assertIn("difficult=3", keys)
        self.assertIn("bold=1", keys)  # 7 mod 6
        self.assertIn("realism=1", keys)  # 7 mod 2

    def test_ends_in_a_play_until_that_never_comes(self):
        # Rules answer waits only during a play until; without this one every pause after the
        # map menu would wait forever.
        lines = [x for x in autoplay.keys_for(1, "one", 2, True).splitlines() if x and not x.startswith("#")]
        self.assertEqual("play until 5", lines[-1])
        self.assertIn("text a", lines)

    def test_seed_ranges(self):
        self.assertEqual([3], autoplay.parse_seeds("3"))
        self.assertEqual([1, 2, 3], autoplay.parse_seeds("1-3"))

    def test_sign_test(self):
        self.assertEqual(1, autoplay.sign_test(0, 0))
        self.assertLess(autoplay.sign_test(10, 0), 0.01)


if __name__ == "__main__":
    unittest.main()
