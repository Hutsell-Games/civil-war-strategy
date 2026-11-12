#!/usr/bin/env python3
"""Writes a saved game from a short description (tests/README.md, "Prepared saved games").

    python tests/make_save.py <description> <out.sav>      for a look at what a description gives

play.py calls write_save for each `<name>.save` file of a script's `#! data` folder and puts
`<name>.sav` in the run's folder. The save starts as the scenario's opening position (CWS.INI,
CITIES.GRD and CWSLEAD.DAT of the run's scenarios folder), and each line of the description
changes one thing. Blank lines and lines that start with "#" are skipped.

    date <month> <year>               the turn, as 11 1864
    side <1|2>                        the side that gives orders (1 the Union, 2 the Rebels)
    bonus <n>                         the Union's income bonus (default 252: balanced play, one
                                      player, realism on)
    cash <union> <rebel>
    points <union> <rebel>            victory points
    capital <union city> <rebel city> 0 for a capital that fell
    fleet <1|2> <ships> <city>        ships: a letter each, W wooden or I ironclad; "-" for none.
                                      city: its port, 0 for no fleet, 99 for at sea
    train <1|2> <army> <city>         an army on the side's train, and where it goes
    owner <0|1|2> <cities>            who holds the cities: numbers and ranges, as 1-12 20 33
    fort <level> <cities>
    army <n> <field>=<value> ...      army slot n (1 to 20 the Union's, 21 to 40 the Rebels').
                                      Fields: city size lead exp supply order name. A name with
                                      blanks is written with "_" for each blank.
    noarmy <slots>                    empty slots: numbers and ranges

The file has the 85 lines that save_game writes (port/files.bm): the date, 40 armies, 40 cities,
and two lines for each side. A side's count of cities and its income are worked out from the
owners, as the game does at each new month.
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

MAX_CITIES = 40
MAX_ARMIES = 40
ARMIES_PER_SIDE = 20
CAPITAL_INCOME = 100
ARMY_FIELDS = ("city", "size", "lead", "exp", "supply", "order", "name")


class SaveError(Exception):
    pass


def find(folder: Path, name: str) -> Path:
    """A file of the folder by its name, whatever its case."""
    for path in folder.iterdir():
        if path.name.lower() == name.lower():
            return path
    raise SaveError(f"no {name} in {folder}")


def values(path: Path) -> list[str]:
    """Every value of a file that INPUT # reads: parted by commas and line ends, quotes taken off."""
    out: list[str] = []
    for row in csv.reader(path.read_text(encoding="latin-1").splitlines(), skipinitialspace=True):
        out += [v.strip() for v in row]
    return out


def opening(scenarios: Path) -> dict:
    """The scenario's opening position, as load_scenario and the main module read it."""
    lead = values(find(scenarios, "cwslead.dat"))
    leaders = [(lead[2 * i], int(lead[2 * i + 1])) for i in range(40)]
    ini = iter(values(find(scenarios, "cws.ini")))
    for _ in range(3 + 12):  # the side names and the month names
        next(ini)
    game: dict = {"month": int(next(ini)), "year": int(next(ini)), "side": 1, "bonus": 252}
    for _ in range(6):  # the victory rules
        next(ini)
    armies = {n: None for n in range(1, MAX_ARMIES + 1)}
    for first in (1, ARMIES_PER_SIDE + 1):
        for n in range(first, first + int(next(ini))):
            city, size, exp, supply = (int(next(ini)) for _ in range(4))
            armies[n] = {"city": city, "size": size, "lead": leaders[n - 1][1], "exp": exp, "supply": supply,
                         "order": 0, "name": leaders[n - 1][0]}
    game["armies"] = armies
    game["cash"] = [int(next(ini)), int(next(ini))]
    for _ in range(3):  # the battle rule numbers
        next(ini)
    game["fleet"] = []
    for _ in range(2):
        game["fleet"].append([next(ini), int(next(ini))])
    game["capital"] = [int(next(ini)), int(next(ini))]
    game["train"] = [[0, 0], [0, 0]]
    grd = values(find(scenarios, "cities.grd"))
    per = 14  # number, x, y, name, owner, value, six roads, port, fort
    game["owner"] = {i + 1: int(grd[per * i + 4]) for i in range(MAX_CITIES)}
    game["value"] = {i + 1: int(grd[per * i + 5]) for i in range(MAX_CITIES)}
    game["fort"] = {i + 1: int(grd[per * i + 13]) for i in range(MAX_CITIES)}
    game["points"] = [sum(v for c, v in game["value"].items() if game["owner"][c] == s) for s in (1, 2)]
    return game


def numbers(words: list[str], top: int, where: str) -> list[int]:
    """Numbers and ranges, as 1-12 20 33."""
    out: list[int] = []
    for word in words:
        a, _, b = word.partition("-")
        if not a.isdigit() or (b and not b.isdigit()):
            raise SaveError(f"{where}: not a number or a range: {word}")
        out += range(int(a), int(b or a) + 1)
    if not out or min(out) < 1 or max(out) > top:
        raise SaveError(f"{where}: numbers from 1 to {top} wanted")
    return out


def apply(game: dict, text: str, name: str) -> None:
    """Changes the position by each line of a description."""
    for n, line in enumerate(text.splitlines(), 1):
        words = line.split()
        if not words or words[0].startswith("#"):
            continue
        where = f"{name} line {n}"
        key, rest = words[0], words[1:]
        try:
            if key == "date" and len(rest) == 2:
                game["month"], game["year"] = int(rest[0]), int(rest[1])
            elif key in ("side", "bonus") and len(rest) == 1:
                game[key] = int(rest[0])
            elif key in ("cash", "points", "capital") and len(rest) == 2:
                game[key] = [int(rest[0]), int(rest[1])]
            elif key == "fleet" and len(rest) == 3 and rest[0] in ("1", "2"):
                ships = "" if rest[1] == "-" else rest[1].upper()
                if ships.strip("WI"):
                    raise SaveError(f"{where}: ships are W or I")
                game["fleet"][int(rest[0]) - 1] = [ships, int(rest[2])]
            elif key == "train" and len(rest) == 3 and rest[0] in ("1", "2"):
                game["train"][int(rest[0]) - 1] = [int(rest[1]), int(rest[2])]
            elif key in ("owner", "fort") and len(rest) >= 2:
                for city in numbers(rest[1:], MAX_CITIES, where):
                    game[key][city] = int(rest[0])
            elif key == "army" and len(rest) >= 2:
                slot = numbers(rest[:1], MAX_ARMIES, where)[0]
                army = game["armies"][slot] or {"city": 0, "size": 0, "lead": 0, "exp": 0, "supply": 0,
                                                "order": 0, "name": ""}
                for item in rest[1:]:
                    f, _, v = item.partition("=")
                    if f not in ARMY_FIELDS or not v:
                        raise SaveError(f"{where}: not an army field: {item} (fields: {' '.join(ARMY_FIELDS)})")
                    army[f] = v.replace("_", " ") if f == "name" else int(v)
                game["armies"][slot] = army
            elif key == "noarmy" and rest:
                for slot in numbers(rest, MAX_ARMIES, where):
                    game["armies"][slot] = None
            else:
                raise SaveError(f"{where}: not a line of a save description: {line}")
        except ValueError:
            raise SaveError(f"{where}: a number is wanted: {line}") from None


def save_text(game: dict) -> str:
    """The saved game as save_game's WRITE # statements write it."""
    lines = [f"{game['month']},{game['year']},{game['bonus']},{game['side']}"]
    for n in range(1, MAX_ARMIES + 1):
        a = game["armies"][n]
        if a is None or a["city"] == 0:
            lines.append('"",0,0,0,0,0,0')
        else:
            lines.append(f'"{a["name"]}",{a["size"]},{a["lead"]},{a["city"]},{a["exp"]},{a["supply"]},{a["order"]}')
    for city in range(1, MAX_CITIES + 1):
        first = next((n for n in range(1, MAX_ARMIES + 1)
                      if game["armies"][n] and game["armies"][n]["city"] == city), 0)
        lines.append(f"{first},{game['owner'][city]},{game['fort'][city]}")
    for s in (1, 2):
        held = [c for c in game["owner"] if game["owner"][c] == s]
        income = sum(game["value"][c] for c in held) + (CAPITAL_INCOME if game["capital"][s - 1] else 0)
        lines.append(f"{game['cash'][s - 1]},{len(held)},{income},{game['points'][s - 1]},{game['capital'][s - 1]}")
        ships, city = game["fleet"][s - 1]
        lines.append(f'"{ships}",{city},0,{game["train"][s - 1][0]},{game["train"][s - 1][1]}')
    return "\n".join(lines) + "\n"


def write_save(description: Path, scenarios: Path, out: Path) -> None:
    game = opening(scenarios)
    apply(game, description.read_text(), description.name)
    out.write_text(save_text(game), newline="\r\n")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(__doc__)
        return 2
    try:
        write_save(Path(argv[0]), Path(__file__).resolve().parent.parent / "scenarios", Path(argv[1]))
    except SaveError as e:
        print(f"make_save.py: {e}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
