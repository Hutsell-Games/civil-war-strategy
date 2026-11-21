#!/usr/bin/env python3
"""Plays games in which the computer plays both sides, and counts who wins (tests/README.md,
"Autoplay").

    python tests/autoplay.py run <out.json> [--seeds 1-100] [--mode two|one] [--map standard|alternate]
                                            [--tuning <file>]
    python tests/autoplay.py summary <results.json>
    python tests/autoplay.py compare <before.json> <after.json>

The game is started with CWS_AUTOPLAY=1 (io/script.bm). At each main menu the computer's code
plays the player's side (ai_player_turn, ui/turn.bm), and the game writes autoplay.txt and ends
when a victory rule ends it.

    two   a two-player game: the computer plays both players, and no rule favors either side as
          the computer. This is the fair match.
    one   a one-player game: the player's side is played by the computer's code, against the
          computer as the game plays it, with the help the rules give the computer's side
          (the Union's income bonus, its victory points). Each seed is played once as each side.

Each seed is one game. The seed also sets the computer's aggression (seed mod 6) and Realism
(seed mod 2); the play balance is Even and the random events are neutral, so that neither side
gets help. Run it on two versions of the game and compare the results to see what a change does.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

# The rules of victory_rule_met (cws.bi): below VICTORY_CITIES the time limit ended the game.
VICTORY_CITIES = 3
RULE_NAMES = {1: "time", 2: "time", 3: "cities", 4: "income", 5: "capital", 6: "force ratio",
              7: "wiped out"}
SIDE_NAMES = {1: "Union", 2: "Rebels"}


def keys_for(seed: int, mode: str, side: int, alternate: bool) -> str:
    cfg = {"side": str(side), "player": "2" if mode == "two" else "1", "difficult": "3",
           "randbal": "5", "bold": str(seed % 6), "realism": str(seed % 2), "history": "0"}
    return "\n".join([
        f"# Autoplay: seed {seed}, {mode}-player game, the player's side {SIDE_NAMES[side]}. "
        "Written by tests/autoplay.py.",
        f"#! seed {seed}",
        "#! cfg " + " ".join(f"{k}={v}" for k, v in cfg.items()),
        "#! timeout 900",
        "",
        "# Pauses: any key. End Turn and End Game: Yes. A retreat: the first city. The game's end:",
        "# Quit this Game (autoplay ends the program before it).",
        "rule 1 key space",
        "rule 2:E text y",
        "rule 2:R key enter",
        "rule 2:O text q",
        "",
        "# The title menu: Start NEW Game; then the map.",
        "play until 2:C",
        "text s",
        "play until 2:S",
        f"text {'a' if alternate else 's'}",
        "",
        "# The game plays itself to its end. Rules answer waits only during a play until, so the",
        "# script plays until place 5, which the game never announces; it ends with the program.",
        "play until 5",
        "",
    ])


def play_game(tools: play.Tools, exe: Path, seed: int, mode: str, side: int, alternate: bool,
              tuning: Path | None = None) -> dict:
    name = f"autoplay-{mode}-{side}-{'alt' if alternate else 'std'}-{seed}"
    keys = play.OUT / "autoplay" / f"{name}.keys"
    keys.parent.mkdir(parents=True, exist_ok=True)
    keys.write_text(keys_for(seed, mode, side, alternate), encoding="utf-8")
    # A month of both sides' play may come between two waits, so the wait for one is longer.
    env = {"CWS_AUTOPLAY": "1", "QB64_SCREEN_PROMPT_MS": "300000"}
    if tuning:
        # The game reads this file on top of its tuning files (load_tuning, io/tuning_file.bm).
        env["CWS_TUNING"] = str(tuning.resolve())
    run = play.run_script(tools, exe, play.load_script(keys), "rust", extra_env=env)
    game = {"seed": seed, "mode": mode, "side": side, "map": "alternate" if alternate else "standard"}
    result = run.folder / "game" / "autoplay.txt"
    if not result.exists():
        found = play.entries(run.state)
        last = play.short(found[-1]) if found else "no state"
        return {**game, "error": f"exit code {run.rc}: {last}"}
    fields = next(csv.reader(result.read_text().splitlines()))
    named, rule, month, year, points1, points2, cities1, cities2 = (int(float(f)) for f in fields)
    # The time limit names the Rebels, who win a technical victory (victory_winner, G39). A build
    # before G39 named the Union.
    winner = 2 if rule < VICTORY_CITIES else named
    return {**game, "winner": winner, "rule": RULE_NAMES.get(rule, str(rule)), "month": month,
            "year": year, "points": [points1, points2], "cities": [cities1, cities2]}


def parse_seeds(text: str) -> list[int]:
    first, _, last = text.partition("-")
    return list(range(int(first), int(last or first) + 1))


def cmd_run(args: argparse.Namespace) -> int:
    tools = play.find_tools(args)
    exe = play.build(tools, "rust")
    sides = (1,) if args.mode == "two" else (1, 2)
    games = [(seed, side) for seed in parse_seeds(args.seeds) for side in sides]
    alternate = args.map == "alternate"
    tuning = Path(args.tuning) if args.tuning else None
    if tuning and not tuning.is_file():
        print(f"no tuning file {tuning}")
        return 2
    found = play.parallel(args.jobs, [lambda s=s, d=d: play_game(tools, exe, s, args.mode, d, alternate, tuning)
                                      for s, d in games])
    # Each game records the tuning it was played with: the shipped file, the scenario's own when
    # there is one, and the --tuning file, each as its text ("" for none).
    scenario_file = play.GAME / "scenarios" / args.map / "TUNING.DAT"
    used = {"tuning": str(tuning) if tuning else "",
            "tuning_text": tuning.read_text(encoding="utf-8") if tuning else "",
            "tuning_base_text": (play.GAME / "scenarios" / "TUNING.DAT").read_text(encoding="utf-8"),
            "tuning_scenario_text": scenario_file.read_text(encoding="utf-8") if scenario_file.is_file() else ""}
    found = [{**g, **used} for g in found]
    Path(args.out).write_text(json.dumps(found, indent=1), encoding="utf-8")
    print(f"{len(found)} games written to {args.out}")
    summarize(found)
    return 1 if any("error" in g for g in found) else 0


def months_played(g: dict) -> int:
    return (g["year"] - 1861) * 12 + g["month"]


def groups(results: list[dict]) -> dict:
    found: dict = {}
    for g in results:
        found.setdefault((g["mode"], g["map"], g["side"]), []).append(g)
    return found


def summarize(results: list[dict]) -> None:
    for (mode, map_name, side), games in sorted(groups(results).items()):
        done = [g for g in games if "winner" in g]
        label = f"{mode}-player, {map_name} map" + ("" if mode == "two" else f", player {SIDE_NAMES[side]}")
        print(f"== {label}: {len(games)} games, {len(games) - len(done)} did not finish")
        for w in (1, 2):
            wins = [g for g in done if g["winner"] == w]
            print(f"   {SIDE_NAMES[w]} won {len(wins)}")
        if done:
            rules: dict = {}
            for g in done:
                rules[g["rule"]] = rules.get(g["rule"], 0) + 1
            print("   ended by: " + ", ".join(f"{k} {v}" for k, v in sorted(rules.items())))
            print(f"   game end, mean: month {statistics.mean(months_played(g) for g in done):.1f} "
                  "counted from January 1861")
        for g in games:
            if "error" in g:
                print(f"   seed {g['seed']}: {g['error'][:150]}")


def sign_test(more: int, fewer: int) -> float:
    n = more + fewer
    if n == 0:
        return 1.0
    k = min(more, fewer)
    return min(1.0, 2 * sum(math.comb(n, i) for i in range(k + 1)) / 2 ** n)


def cmd_compare(args: argparse.Namespace) -> int:
    before = groups(json.loads(Path(args.before).read_text(encoding="utf-8")))
    after = groups(json.loads(Path(args.after).read_text(encoding="utf-8")))
    for key in sorted(set(before) & set(after)):
        mode, map_name, side = key
        b = {g["seed"]: g for g in before[key] if "winner" in g}
        a = {g["seed"]: g for g in after[key] if "winner" in g}
        seeds = sorted(set(b) & set(a))
        label = f"{mode}-player, {map_name} map" + ("" if mode == "two" else f", player {SIDE_NAMES[side]}")
        print(f"== {label}: {len(seeds)} games finished in both")
        for w in (1, 2):
            wb = sum(1 for s in seeds if b[s]["winner"] == w)
            wa = sum(1 for s in seeds if a[s]["winner"] == w)
            print(f"   {SIDE_NAMES[w]} won: before {wb}, after {wa}")
        flips_to_rebels = sum(1 for s in seeds if b[s]["winner"] == 1 and a[s]["winner"] == 2)
        flips_to_union = sum(1 for s in seeds if b[s]["winner"] == 2 and a[s]["winner"] == 1)
        print(f"   games whose winner changed: to the Rebels {flips_to_rebels}, to the Union "
              f"{flips_to_union} (sign test p = {sign_test(flips_to_rebels, flips_to_union):.3f})")
        if seeds:
            mb = statistics.mean(months_played(b[s]) for s in seeds)
            ma = statistics.mean(months_played(a[s]) for s in seeds)
            print(f"   game end, mean month: before {mb:.1f}, after {ma:.1f}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--qb64rust-repo", help="QB64Rust's repo (default: ../QB64Rust beside this repo)")
    parser.add_argument("--jobs", type=int, default=4 if os.name == "nt" else 1)
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("run", help="play the games and write their results")
    p.add_argument("out")
    p.add_argument("--seeds", default="1-100", help="a seed or a range, as 1-100 (default)")
    p.add_argument("--mode", choices=("two", "one"), default="two")
    p.add_argument("--map", choices=("standard", "alternate"), default="standard")
    p.add_argument("--tuning", help="a tuning file whose lines count on top of scenarios/TUNING.DAT")
    p = sub.add_parser("summary", help="who won the games of a results file")
    p.add_argument("results")
    p = sub.add_parser("compare", help="the same games on two versions of the game")
    p.add_argument("before")
    p.add_argument("after")
    args = parser.parse_args(argv)
    if args.command == "run":
        return cmd_run(args)
    if args.command == "summary":
        summarize(json.loads(Path(args.results).read_text(encoding="utf-8")))
        return 0
    return cmd_compare(args)


if __name__ == "__main__":
    sys.exit(main())
