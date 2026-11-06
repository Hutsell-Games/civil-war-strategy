#!/usr/bin/env python3
"""Writes the generated scripts of tests/scripts (tests/README.md, "Generated scripts").

    python tests/make_scripts.py [--only <name> ...]

Each generated script plays a whole game in which the player only ends each turn, so that the
computer's side alone acts: it recruits, moves, builds ships, fights and wins. Two styles:

    pass-<side>-<seed>   the game ends at the first victory condition the computer reaches,
                         after a few months
    war-<side>-<seed>    the player first turns off every victory condition but the time limit
                         (Utility, End Cond), so the game lasts until March 1865 or until one
                         side has no army left

Each is one of GAMES: a style, a seed, a side, whether the game is played on the alternate map
(the files ALTMAP.BAT switches in), and the settings that go with the seed (the map's detail, the
play balance, the computer's aggression ...). The names of the games on the alternate map have
"altmap" in place of the seed.

A script takes a digest at every main menu, so a difference shows in the month where it starts,
and checks the history file the game wrote. How many months a game lasts and whether the Hall of
Fame asks for a name depends on the game, so this tool plays each one first with a probe and
writes what it found. Run it again only when a change of the game is meant to change how its
games go; then record.
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

SIDES = {1: ("union", "Union", "Rebel"), 2: ("rebel", "Rebel", "Union")}
# The settings that go with each seed (fields of CWS.CFG, play.CFG_FIELDS). Every game writes
# its history.
SETTINGS = {
    1861: {},
    1862: {"bold": "5", "difficult": "1", "graf": "2", "jancam": "0"},
    1863: {"bold": "0", "difficult": "5", "graf": "1", "realism": "0", "randbal": "3"},
    1864: {"bold": "4", "difficult": "2", "graf": "0", "randbal": "5", "turbo": "2"},
    1865: {},
    1866: {},
    1867: {"bold": "5", "difficult": "2", "graf": "2"},
    1868: {"realism": "0", "graf": "1"},
    1869: {"bold": "4", "randbal": "3"},
}


@dataclass(frozen=True)
class Game:
    style: str  # "pass" or "war"
    seed: int
    side: int
    altmap: bool = False

    @property
    def name(self) -> str:
        return f"{self.style}-{SIDES[self.side][0]}-{'altmap' if self.altmap else self.seed}"

    @property
    def settings(self) -> dict[str, str]:
        return {"side": str(self.side), "history": "1", **SETTINGS[self.seed]}


GAMES = (
    [Game("pass", seed, side) for seed in (1861, 1862, 1863, 1864) for side in SIDES]
    + [Game("pass", 1865, side, altmap=True) for side in SIDES]
    + [Game("war", 1866, 1), Game("war", 1867, 2), Game("war", 1868, 1, altmap=True),
       Game("war", 1869, 2, altmap=True)]
)
# The letters of the pauses (place 1, SCRIPT.BM) but G, "Game Over".
PAUSES_BEFORE_THE_END = "RTPBUKINSHFL"
PROBE_MONTHS = 500
PROBE_PROMPT_MS = "20000"


def header(game: Game, about: str, probe: bool = False) -> list[str]:
    """The lines up to the first month's main menu. A probe has no rule for "Game Over" (1:G), so
    that it stops there."""
    _, player, computer = SIDES[game.side]
    cfg = " ".join(f"{k}={v}" for k, v in game.settings.items())
    lines = [
        f"# A whole game as the {player} side, which only ends each turn; the computer plays the "
        f"{computer} side{', on the alternate map' if game.altmap else ''}.",
        *(["# Every victory condition but the time limit is turned off first."] if game.style == "war" else []),
        f"# {about}",
        "# Written by tests/make_scripts.py.",
        f"#! seed {game.seed}",
        f"#! cfg {cfg}",
        *(["#! altmap"] if game.altmap else []),
        "#! files cws.his HISCORE.CWS",
        "#! timeout 900",
        "",
        "# Pauses that any key ends; End Turn and End Game: Yes; a Retreat: the first city; the",
        "# Options at the game's end: Quit this Game.",
        *([f"rule 1:{letter} key space" for letter in PAUSES_BEFORE_THE_END] if probe else ["rule 1 key space"]),
        "rule 2:E text y",
        "rule 2:R key enter",
        "rule 2:O text q",
        "",
        "# The title menu: Start NEW Game.",
        "play until 2:V",
        "digest",
        "text s",
    ]
    if game.style == "war":
        lines += [
            "",
            "# The main menu: UTILITY, End Cond. Victory Conditions starts on Time: down and Enter",
            "# turn off each of the four others. Esc there, and Esc at the Utility menu.",
            "play until 2:M",
            "text u",
            "prompt",
            "text e",
            *(["prompt", "key down", "prompt", "key enter"] * 4),
            "prompt",
            "digest",
            "key esc",
            "prompt",
            "key esc",
        ]
    return lines


def months(count: int) -> list[str]:
    return ["", "# Each month's main menu: a digest, then END TURN.",
            f"repeat {count}", "play until 2:M", "digest", "text e", "end"]


def ending(name_asked: bool) -> list[str]:
    lines = [""]
    if name_asked:
        lines += ["# The game ends. The Hall of Fame asks for the commander's name.",
                  "play until 4", "text Tester", "key enter"]
    else:
        lines += ["# The game ends. The Hall of Fame asks for no name."]
    return lines + [
        "play until 1:G",
        "digest",
        "key space",
        "",
        "# The title menu: Quit to DOS, and a key for END's \"Press any key to continue\".",
        "play until 2:V",
        "digest",
        "text q",
        "repeat space",
    ]


def probe_run(tools: play.Tools, exe: Path, name: str, lines: list[str]) -> tuple[list[bytes], str, int | None]:
    """Runs a probe: its digests, the last line of its state file and its exit code."""
    keys = play.OUT / "probe" / f"{name}.keys"
    keys.parent.mkdir(parents=True, exist_ok=True)
    keys.write_text("\n".join(lines) + "\n")
    run = play.run_script(tools, exe, play.load_script(keys), "rust",
                          extra_env={"QB64_SCREEN_PROMPT_MS": PROBE_PROMPT_MS})
    found = play.entries(run.state)
    last = play.short(found[-1]) if found else f"exit code {run.rc}, no state"
    if run.rc is None:
        last = f"killed after {run.script.timeout} s; " + last
    return [e for e in found if e.startswith(b"digest ")], last, run.rc


def probe(tools: play.Tools, exe: Path, game: Game) -> list[str] | str:
    """The script's lines, or why the probe could not play the game to its end."""
    name = "probe-" + game.name
    # Every month until the game is over: the Hall of Fame asks for a name (place 4, which has no
    # rule), or "Game Over" comes (1:G, which the probe leaves without a rule too).
    head = header(game, "", probe=True)
    lines = head + [f"repeat {PROBE_MONTHS}", "play until 2:M", "digest", "text e", "end"]
    digests, last, _ = probe_run(tools, exe, name, lines)
    if last.endswith("no rule for the wait at place 4"):
        name_asked = True
    elif last.endswith("no rule for the wait at place 1"):
        name_asked = False
    else:
        return f"the game did not end: {last}"
    count = len(digests) - sum(1 for x in head if x == "digest")
    about = f"A digest at each of the {count} main menus, at Game Over and at the title menus."
    lines = header(game, about) + months(count) + ending(name_asked)
    _, last, rc = probe_run(tools, exe, name, lines)
    if rc != 0:
        return f"the script does not end the game: exit code {rc}, {last}"
    return lines


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--qb64rust-repo")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--only", nargs="*", help="names of the scripts to write (default: all)")
    args = parser.parse_args(argv)
    tools = play.find_tools(args)
    exe = play.build(tools, "rust")
    games = [g for g in GAMES if not args.only or g.name in args.only]
    found = play.parallel(args.jobs, [lambda g=g: probe(tools, exe, g) for g in games])
    failed = 0
    for game, lines in zip(games, found):
        if isinstance(lines, str):
            failed += 1
            print(f"FAIL  {game.name}: {lines}")
            continue
        (play.SCRIPTS / f"{game.name}.keys").write_text("\n".join(lines) + "\n", newline="\n")
        months_played = next(x.split()[1] for x in lines if x.startswith("repeat ") and x.split()[1].isdigit())
        print(f"wrote {game.name}.keys: {months_played} months")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
