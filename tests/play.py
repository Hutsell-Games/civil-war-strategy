#!/usr/bin/env python3
"""Plays the game from keys files and compares its screens (tests/README.md).

    python tests/play.py check   [script ...]   the QB64Rust build against the recorded screens
    python tests/play.py compare [script ...]   the QB64pe and QB64Rust builds against each other
    python tests/play.py record  [script ...]   both builds, twice each; writes <script>.screen
    python tests/play.py coverage [--unit-tests] [script ...]
                                                a coverage build; the lines the scripts and the unit tests reach
    python tests/play.py explore <keys file>    one run, a PNG of every state, stops at the next wait

A script is tests/scripts/<name>.keys, a keys file of QB64Rust's screen-state check
(QB64Rust/tools/screen/README.md). Its recorded screens are tests/scripts/<name>.screen. A script
names no files: "check" with no name runs them all.

Lines of a script that start with "#!" set up its run (other "#" lines are comments):
    #! seed <n>              the random seed (CWS_SEED; default 1)
    #! cfg <field>=<value>   a field of the CWS.CFG the run starts with (CFG_FIELDS below)
    #! timeout <seconds>     the longest the run may take (default 300)
    #! program <name>        the program the script plays: cws (CWSTRAT.BAS, the game), the
                             only one and the default
    #! altmap                the run starts on the alternate map: the three ALTMAP files take the
                             places of the game's map, setup and leaders, as ALTMAP.BAT does
    #! files <name> ...      files of the run's folder to check after the run: each becomes a
                             last entry "file <name> <hash>" (or "file <name> missing")
    #! data <folder>         the files of tests/data/<folder> go into the run's folder, over those
                             of the same name; a <name>.save there is a description that
                             make_save.py turns into the saved game <name>.sav
    #! without <name> ...    files the run starts without, as graphics/MTN.VGA
    #! dice <groups>         forced random numbers for the special events (CWS_DICE, port/script.bm):
                             a group for each month, as 0,.05,.95;0,.9

Exit code: 0 when every script passed, 1 when one failed, 2 when a build or the set-up failed.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import make_save  # noqa: E402

GAME =Path(__file__).resolve().parent.parent
SCRIPTS = GAME / "tests" / "scripts"
OUT = GAME / "tests" / "out"

# The source files of the game; a build is made again when one of them changes.
SOURCE_SUFFIXES = {".bas", ".bi", ".bm"}
SOURCE_FOLDERS = ["rules", "ai", "commands", "ui", "draw", "game", "port"]
# Top-level files that a run does not need: sources, DOS programs and objects, documents.
NOT_DATA_SUFFIXES = SOURCE_SUFFIXES | {
    ".exe", ".obj", ".lnk", ".mak", ".zip", ".md", ".qlb", ".com", ".drv", ".bat", ".btm",
    ".pif", ".doc", ".txt", ".png", ".1st",
}
# The folders of data files, copied whole into a run's folder.
DATA_FOLDERS: tuple[str, ...] = ("graphics", "scenarios")
# Files that every run takes from here instead of the repo's folder, when this folder exists.
TEST_DATA = GAME / "tests" / "data"
# The name of the configuration file the run starts with; play.py writes it.
CFG_NAME = "CWS.CFG"

# The fields of CWS.CFG in the order the game reads and writes them (filer, CWSTRAT1.BM; Files,
# New Game, CWSTRAT.BAS), with the values a run starts with. They are those of the CWS.CFG that
# came with the game, but noise: 0 (no sound, and no title music, which waits for its notes)
# where the file has 2.
CFG_FIELDS = {
    "side": "1",        # 1 the Union, 2 the Rebels
    "graf": "3",        # the map: 0 disabled, 1 roads, 2 city names, 3 full
    "noise": "0",       # 0 quiet, 1 sound, 2 music and sound
    "difficult": "3",   # play balance, 1 (Rebel ++) to 5 (Union ++)
    "player": "1",      # 1 or 2 players
    "turbo": "1",       # display speed: 1 fast, 2 normal, 3 slow, 8 very slow
    "randbal": "7",     # random events: 0 off, 3 favor the Union, 5 neutral, 7 favor the Rebels
    "train1": "600",    # railroad capacity, the Union
    "train2": "300",    # railroad capacity, the Rebels
    "jancam": "1",      # January campaigns allowed
    "realism": "1",
    "batwon1": "36",    # battles won by the Union in all games so far
    "batwon2": "134",
    "casualty1": "3992",
    "casualty2": "5041",
    "history": "0",     # 1: the game writes its events to cws.his
    "bold": "3",        # the computer's aggression, 0 to 5
}

COMPILERS = ("pe", "rust")
DEFAULT_TIMEOUT = 300
# The programs a script can play: the source each is built from. The build keeps the name of
# the DOS program, cws.exe.
PROGRAMS = {"cws": "CWSTRAT.BAS"}
DEFAULT_PROGRAM = "cws"


# ---------------------------------------------------------------------------------- the tools


@dataclass
class Tools:
    qb64rust_repo: Path
    exes: dict[str, Path]
    screen_state: Path
    press_any_key: Path
    state_to_png: Path


def find_tools(args: argparse.Namespace) -> Tools:
    """Finds the compilers and QB64Rust's screen tools. QB64Rust's repo is beside this one unless
    --qb64rust-repo or CWS_QB64RUST_REPO says otherwise; QB64pe is beside QB64Rust's repo."""
    repo = Path(args.qb64rust_repo or os.environ.get("CWS_QB64RUST_REPO") or GAME.parent / "QB64Rust")
    exe = ".exe" if os.name == "nt" else ""
    rust = os.environ.get("QB64RUST") or repo / "target" / "release" / f"qb64rust{exe}"
    pe = os.environ.get("QB64PE") or repo.parent / "QB64pe" / f"qb64pe{exe}"
    tools = Tools(
        qb64rust_repo=repo,
        exes={"rust": Path(rust), "pe": Path(pe)},
        screen_state=repo / "tools" / "screen" / "screen_state.cpp",
        press_any_key=repo / "tools" / "legacy_tests" / "press_any_key.py",
        state_to_png=repo / "tools" / "screen" / "state_to_png.py",
    )
    for path in (tools.screen_state, tools.press_any_key, tools.state_to_png):
        if not path.is_file():
            sys.exit(f"play.py: not found: {path} (set --qb64rust-repo or CWS_QB64RUST_REPO)")
    return tools


# ---------------------------------------------------------------------------------- building


def source_stamp(tools: Tools, compiler: str) -> str:
    """A hash of what a build depends on: the game's sources, the compiler, the screen hook."""
    h = hashlib.sha256()
    folders = [GAME] + [GAME / d for d in SOURCE_FOLDERS if (GAME / d).is_dir()]
    for path in sorted(p for folder in folders for p in folder.iterdir()):
        if path.is_file() and path.suffix.lower() in SOURCE_SUFFIXES:
            h.update(path.relative_to(GAME).as_posix().encode() + b"\0" + path.read_bytes() + b"\0")
    exe = tools.exes[compiler]
    st = exe.stat()
    h.update(f"{exe}\0{st.st_size}\0{st.st_mtime_ns}\0".encode())
    h.update(tools.screen_state.read_bytes())
    return h.hexdigest()


def build(tools: Tools, compiler: str, coverage: bool = False, program: str = DEFAULT_PROGRAM) -> Path:
    """Builds a program (PROGRAMS) with the screen hook linked in, unless the build of the same
    sources is there. With coverage (QB64Rust only) the build counts each statement it runs."""
    exe = tools.exes[compiler]
    if not exe.is_file():
        raise SetupError(f"compiler not found: {exe}")
    name = compiler + ("-coverage" if coverage else "") + f"-{program}"
    folder = OUT / "build" / name
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / (f"{program}.exe" if os.name == "nt" else program)
    stamp_file = folder / "stamp.txt"
    stamp = source_stamp(tools, compiler)
    if target.is_file() and stamp_file.is_file() and stamp_file.read_text() == stamp:
        return target
    target.unlink(missing_ok=True)
    log = folder / "build-log.txt"
    # The path of the hook must hold no blank (tools/screen/README.md); forward slashes suit both.
    hook = tools.screen_state.resolve().as_posix()
    cmd = [str(exe), "-x", *(["--coverage"] if coverage else []), str(GAME / PROGRAMS[program]), "-o",
           str(target), f"-f:ExtraLinkerFlags={hook}"]
    print(f"building {PROGRAMS[program]} with {compiler}{' --coverage' if coverage else ''} ...", flush=True)
    with open(log, "wb") as out:
        rc = subprocess.run(cmd, stdout=out, stderr=subprocess.STDOUT, cwd=GAME).returncode
    if rc != 0 or not target.is_file():
        raise SetupError(f"the {compiler} build failed (exit code {rc}); see {rel(log)}")
    stamp_file.write_text(stamp)
    return target


def build_all(tools: Tools, compilers: tuple[str, ...], scripts: list[Script],
              coverage: bool = False) -> dict[tuple[str, str], Path]:
    """The builds the scripts need, by (compiler, program); the builds of one compiler one after
    the other, the compilers at once."""
    programs = sorted({s.program for s in scripts})

    def one(compiler: str) -> list[tuple[tuple[str, str], Path]]:
        return [((compiler, p), build(tools, compiler, coverage, p)) for p in programs]

    return dict(pair for found in parallel(len(compilers), [lambda c=c: one(c) for c in compilers])
                for pair in found)


class SetupError(Exception):
    pass


# ---------------------------------------------------------------------------------- scripts


@dataclass
class Script:
    name: str
    keys: Path
    seed: str = "1"
    cfg: dict[str, str] = field(default_factory=lambda: dict(CFG_FIELDS))
    timeout: int = DEFAULT_TIMEOUT
    program: str = DEFAULT_PROGRAM
    files: list[str] = field(default_factory=list)
    altmap: bool = False
    data: list[str] = field(default_factory=list)
    without: list[str] = field(default_factory=list)
    dice: str = ""

    @property
    def recorded(self) -> Path:
        return self.keys.with_suffix(".screen")


def load_script(keys: Path) -> Script:
    """Reads a script's "#!" lines."""
    script = Script(name=keys.stem, keys=keys)
    for n, line in enumerate(keys.read_text().splitlines(), 1):
        if not line.startswith("#!"):
            continue
        words = line[2:].split()
        where = f"{rel(keys)} line {n}"
        if not words:
            continue
        if words[0] == "seed" and len(words) == 2:
            script.seed = words[1]
        elif words[0] == "timeout" and len(words) == 2 and words[1].isdigit():
            script.timeout = int(words[1])
        elif words[0] == "cfg" and len(words) > 1:
            for item in words[1:]:
                key, _, value = item.partition("=")
                if key not in CFG_FIELDS or not value:
                    raise SetupError(f"{where}: unknown cfg field {item!r} (fields: {', '.join(CFG_FIELDS)})")
                script.cfg[key] = value
        elif words[0] == "program" and len(words) == 2:
            if words[1] not in PROGRAMS:
                raise SetupError(f"{where}: unknown program {words[1]!r} (programs: {', '.join(PROGRAMS)})")
            script.program = words[1]
        elif words == ["altmap"]:
            script.altmap = True
        elif words[0] == "files" and len(words) > 1:
            script.files += words[1:]
        elif words[0] == "data" and len(words) == 2:
            if not (TEST_DATA / words[1]).is_dir():
                raise SetupError(f"{where}: no folder {rel(TEST_DATA / words[1])}")
            script.data.append(words[1])
        elif words[0] == "without" and len(words) > 1:
            script.without += words[1:]
        elif words[0] == "dice" and len(words) == 2 and not words[1].strip("0123456789.,;r"):
            script.dice = words[1]
        else:
            raise SetupError(f"{where}: not a set-up line: {line}")
    return script


def find_scripts(names: list[str]) -> list[Script]:
    """The scripts named (a name, or the path of a keys file), or all of them."""
    if not names:
        paths = sorted(SCRIPTS.glob("*.keys"))
        if not paths:
            raise SetupError(f"no scripts in {rel(SCRIPTS)}")
    else:
        paths = []
        for name in names:
            path = Path(name)
            if not path.suffix:
                path = SCRIPTS / f"{name}.keys"
            if not path.is_file():
                raise SetupError(f"no script {name}")
            paths.append(path)
    return [load_script(p) for p in paths]


def checkpoints(keys_text: str) -> list[int]:
    """The line numbers of the keys file's `state` and `digest` steps in the order they run, with
    `repeat <n>` ... `end` blocks unrolled. Each is one entry of the state file, before the state at exit."""
    lines = keys_text.splitlines()

    def run(start: int, stop: int) -> list[int]:
        found: list[int] = []
        i = start
        while i < stop:
            words = lines[i].split("#", 1)[0].split()
            if words[:1] == ["repeat"] and len(words) == 2 and words[1].isdigit():
                end = block_end(i)
                found += run(i + 1, end) * int(words[1])
                i = end + 1
                continue
            if words in (["state"], ["digest"]):
                found.append(i + 1)
            i += 1
        return found

    def block_end(i: int) -> int:
        depth = 0
        for j in range(i, len(lines)):
            words = lines[j].split("#", 1)[0].split()
            if words[:1] == ["repeat"] and len(words) == 2 and words[1].isdigit():
                depth += 1
            elif words == ["end"]:
                depth -= 1
                if depth == 0:
                    return j
        return len(lines)

    return run(0, len(lines))


# ---------------------------------------------------------------------------------- state files


def entries(data: bytes) -> list[bytes]:
    """The entries of a state file in order: each state from `screen-state 1` to `end` (with its
    line ends), each `digest` line, and a last `stopped` line if a `prompt` stopped the run."""
    found: list[bytes] = []
    current: list[bytes] | None = None
    for line in data.splitlines(keepends=True):
        if current is not None:
            current.append(line)
            if line.rstrip(b"\r\n") == b"end":
                found.append(b"".join(current))
                current = None
        elif line.startswith(b"screen-state "):
            current = [line]
        elif line.strip():
            found.append(line.rstrip(b"\r\n"))
    if current is not None:
        found.append(b"".join(current))  # a state cut short
    return found


def fnv1a64(data: bytes) -> int:
    h = 0xCBF29CE484222325
    for b in data:
        h = ((h ^ b) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return h


def as_digest(entry: bytes) -> bytes:
    """A full state as the `digest` line the same screen gives; any other entry as it is."""
    if entry.startswith(b"screen-state "):
        return b"digest %016X" % fnv1a64(entry)
    return entry


def same(a: bytes, b: bytes) -> bool:
    """Two entries show the same screen. A digest matches the full state it hashes."""
    if a == b:
        return True
    if a.startswith(b"digest ") or b.startswith(b"digest "):
        return as_digest(a) == as_digest(b)
    return False


def first_difference(a: list[bytes], b: list[bytes]) -> int | None:
    """The index of the first entry that differs, or None when the two lists show the same screens."""
    for i in range(max(len(a), len(b))):
        if i >= len(a) or i >= len(b) or not same(a[i], b[i]):
            return i
    return None


def describe(index: int, marks: list[int], keys: Path) -> str:
    """Where entry index comes from: a step of the keys file, or the state at exit."""
    if index < len(marks):
        return f"checkpoint {index + 1}, {rel(keys)} line {marks[index]}"
    if index == len(marks):
        return f"checkpoint {index + 1}, the state at exit"
    return f"entry {index + 1}, after the state at exit"


def short(entry: bytes | None) -> str:
    if entry is None:
        return "nothing"
    if entry.startswith(b"screen-state "):
        return "a state, " + as_digest(entry).decode()
    return entry.decode(errors="replace")


# ---------------------------------------------------------------------------------- running


@dataclass
class Run:
    script: Script
    compiler: str
    tag: str
    rc: int | None  # None: killed at the timeout
    state: bytes
    folder: Path

    @property
    def label(self) -> str:
        return f"{self.script.name} [{self.compiler}{' ' + self.tag if self.tag else ''}]"


def copy_data(work: Path, game: Path = GAME, test_data: Path = TEST_DATA) -> None:
    """Fills a run's folder: the game's data files, then the files of tests/data when that folder
    exists, which replace those of the same name."""
    for path in game.iterdir():
        if path.is_file() and path.suffix.lower() not in NOT_DATA_SUFFIXES:
            shutil.copy2(path, work / path.name)
    for folder in DATA_FOLDERS:
        shutil.copytree(game / folder, work / folder)
    if test_data.is_dir():
        for path in test_data.iterdir():
            if path.is_file():
                shutil.copy2(path, work / path.name)


def find_in(folder: Path, name: str) -> Path | None:
    """A file or folder of `folder` by its name, whatever its case. The name may start with folders,
    parted by "/"."""
    path: Path | None = folder
    for part in name.split("/"):
        if path is None or not path.is_dir():
            return None
        path = next((p for p in path.iterdir() if p.name.lower() == part.lower()), None)
    return path


def copy_test_folder(work: Path, source: Path) -> None:
    """Puts the files of a script's `#! data` folder into the run's folder, each over the file of the
    same name whatever its case. A `<name>.save` is a description: make_save.py writes the saved game
    `<name>.sav` from it and the run's scenario."""
    for path in sorted(source.rglob("*")):
        if not path.is_file():
            continue
        folder = work
        for part in path.relative_to(source).parts[:-1]:
            folder = find_in(folder, part) or folder / part
            folder.mkdir(exist_ok=True)
        name = path.with_suffix(".sav").name if path.suffix == ".save" else path.name
        old = find_in(folder, name)
        if old is not None:
            old.unlink()
        if path.suffix == ".save":
            try:
                make_save.write_save(path, work / "scenarios", folder / name)
            except make_save.SaveError as e:
                raise SetupError(str(e)) from None
        else:
            shutil.copy2(path, folder / name)


def remove_files(work: Path, names: list[str]) -> None:
    """Takes the files of a script's `#! without` out of the run's folder."""
    for name in names:
        path = find_in(work, name)
        if path is None or not path.is_file():
            raise SetupError(f"#! without {name}: no such file in the run's folder")
        path.unlink()


# The files ALTMAP.BAT switches: the alternate map, setup and leaders, and the game's own.
ALTMAP_PAIRS = (("ALTMAP.GRD", "CITIES.GRD"), ("ALTMAP.INI", "CWS.INI"), ("ALTLEAD.DAT", "CWSLEAD.DAT"))


def swap_altmap(work: Path, folder: str = "") -> None:
    """Switches the alternate map's three files with the game's, as ALTMAP.BAT does by renaming."""
    where = work / folder
    names = {p.name.lower(): p for p in where.iterdir()}
    for alt, own in ALTMAP_PAIRS:
        a, b = names[alt.lower()], names[own.lower()]
        data = a.read_bytes()
        a.write_bytes(b.read_bytes())
        b.write_bytes(data)


def write_cfg(work: Path, cfg: dict[str, str]) -> None:
    """Writes CWS.CFG: one line of numbers, as the game's WRITE # writes them."""
    for old in work.iterdir():
        if old.name.lower() == CFG_NAME.lower():
            old.unlink()
    (work / CFG_NAME).write_text(",".join(cfg[name] for name in CFG_FIELDS) + "\n")


def kill_tree(proc: subprocess.Popen) -> None:
    if os.name == "nt":
        subprocess.run(["taskkill", "/F", "/T", "/PID", str(proc.pid)], capture_output=True)
    else:
        proc.kill()
    proc.wait()


def run_script(tools: Tools, exe: Path, script: Script, compiler: str, tag: str = "",
               keys: Path | None = None, full_states: bool = False,
               extra_env: dict[str, str] | None = None) -> Run:
    """Runs the game once in a fresh copy of its data files, with the script's keys."""
    folder = OUT / "run" / f"{script.name}-{compiler}{'-' + tag if tag else ''}"
    work = folder / "game"
    shutil.rmtree(folder, ignore_errors=True)
    work.mkdir(parents=True)
    copy_data(work)
    write_cfg(work, script.cfg)
    if script.altmap:
        swap_altmap(work, "scenarios")
    for name in script.data:
        copy_test_folder(work, TEST_DATA / name)
    remove_files(work, script.without)
    game = work / exe.name
    shutil.copy2(exe, game)
    state = folder / "screen.txt"
    env = dict(os.environ)
    env["CWS_SEED"] = script.seed
    env.pop("CWS_DICE", None)
    if script.dice:
        env["CWS_DICE"] = script.dice
    # A runtime error ends the program instead of asking "Continue?" on a desktop nobody sees.
    env["QB64PE_NOPROMPT"] = "y"
    env["QB64_SCREEN_KEYS"] = str((keys or script.keys).resolve())
    env["QB64_SCREEN_STATE"] = str(state)
    if full_states:
        env["QB64_SCREEN_DIGEST_AS_STATE"] = "1"
    else:
        env.pop("QB64_SCREEN_DIGEST_AS_STATE", None)
    env.update(extra_env or {})
    if os.name == "nt":
        # END waits for a key event of the console; the helper gives it. The window goes on a
        # desktop that is never shown, unless CWS_SHOW_WINDOWS=1.
        cmd = [sys.executable, "-I", str(tools.press_any_key)]
        if os.environ.get("CWS_SHOW_WINDOWS") != "1":
            cmd.append("--hidden-desktop")
        cmd.append(str(game))
        flags = subprocess.CREATE_NO_WINDOW
    else:
        cmd, flags = [str(game)], 0
    with open(folder / "log.txt", "wb") as log:
        proc = subprocess.Popen(cmd, cwd=work, env=env, stdout=log, stderr=subprocess.STDOUT,
                                stdin=subprocess.DEVNULL, creationflags=flags)
        try:
            rc: int | None = proc.wait(timeout=script.timeout)
        except subprocess.TimeoutExpired:
            kill_tree(proc)
            rc = None
    data = state.read_bytes() if state.is_file() else b""
    return with_files(Run(script, compiler, tag, rc, data, folder), work)


def with_files(run: Run, work: Path) -> Run:
    """Adds the entries of the script's "#! files" to a run that ended as it should. A failed run
    is left as it is, so that its last entry still says why it failed (run_problem)."""
    if not run.script.files or run_problem(run) is not None:
        return run
    run.state += file_entries(work, run.script.files)
    return run


def file_entries(work: Path, names: list[str]) -> bytes:
    """A line "file <name> <hash>" for each file the script names, after its run. The hash is of
    the file with CRLF line ends taken as LF, so that the same text gives the same hash on every
    system. A name may start with a folder, as in scenarios/WW1939.INI. Each part matches whatever
    its case, as on Windows."""
    out = b""
    for name in names:
        path = find_in(work, name)
        if path is None or not path.is_file():
            out += f"file {name} missing\n".encode()
        else:
            digest = hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()[:16].upper()
            out += f"file {name} {digest}\n".encode()
    return out


def run_problem(run: Run) -> str | None:
    """Why a run cannot count: killed, a bad exit code, no state, or stopped by a prompt."""
    if run.rc is None:
        return f"killed after {run.script.timeout} s (log: {rel(run.folder / 'log.txt')})"
    if not run.state:
        return f"exit code {run.rc} and no state written (log: {rel(run.folder / 'log.txt')})"
    last = entries(run.state)[-1]
    if last.startswith(b"stopped "):
        return f"exit code {run.rc}: {last.decode(errors='replace')}"
    if run.rc != 0:
        return f"exit code {run.rc}"
    return None


def pngs(tools: Tools, state_file: Path, out_base: Path, numbers: list[int] | None = None) -> list[Path]:
    """Writes PNGs of the states of a state file (all, or those numbered, from 1)."""
    out_base.parent.mkdir(parents=True, exist_ok=True)
    which = ["--all"] if numbers is None else []
    written: list[Path] = []
    for args in ([which] if numbers is None else [["--state", str(n)] for n in numbers]):
        out = out_base if numbers is None else out_base.with_name(f"{out_base.stem}-{args[1]}.png")
        r = subprocess.run([sys.executable, "-I", str(tools.state_to_png), *args, str(state_file), "-o", str(out)],
                           capture_output=True, text=True)
        for line in r.stdout.splitlines():
            if line.startswith("written: "):
                written.append(Path(line[len("written: "):]))
    return written


# ---------------------------------------------------------------------------------- commands


def parallel(jobs: int, work: list) -> list:
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        return list(pool.map(lambda f: f(), work))


def state_number(found: list[bytes], index: int) -> int | None:
    """The number, from 1, of entry index among the states of a file, if that entry is a state."""
    if index >= len(found) or not found[index].startswith(b"screen-state "):
        return None
    return sum(1 for e in found[: index + 1] if e.startswith(b"screen-state "))


def explain(tools: Tools, exe: Path, script: Script, compiler: str, want: list[bytes]) -> str:
    """After a digest differed: runs the script again with full states and writes a PNG of the first
    screen that differs, and one of the recorded screen when record kept a copy of it here."""
    run = run_script(tools, exe, script, compiler, tag="full", full_states=True)
    got = entries(run.state)
    index = first_difference(got, want)
    if index is None:
        return ""
    lines = ""
    fail = OUT / "fail"
    for old in fail.glob(f"{script.name}-*.png"):
        old.unlink()
    number = state_number(got, index)
    if number:
        written = pngs(tools, run.folder / "screen.txt", fail / f"{script.name}-now.png", [number])
        lines += "".join(f"\n    the screen now:      {rel(p)}" for p in written)
    copy = full_copy(script)
    if copy.is_file():
        kept = entries(copy.read_bytes())
        number = state_number(kept, index) if first_difference(kept, want) is None else None
        if number:
            written = pngs(tools, copy, fail / f"{script.name}-recorded.png", [number])
            lines += "".join(f"\n    the screen recorded: {rel(p)}" for p in written)
    return lines


def cmd_check(args: argparse.Namespace, tools: Tools) -> int:
    scripts = find_scripts(args.scripts)
    compiler = args.compiler
    missing = [s.name for s in scripts if not s.recorded.is_file()]
    if missing:
        raise SetupError(f"not recorded: {', '.join(missing)} (python tests/play.py record <name>)")
    exes = build_all(tools, (compiler,), scripts)
    runs = parallel(args.jobs, [lambda s=s: run_script(tools, exes[compiler, s.program], s, compiler)
                                for s in scripts])
    failed = 0
    for run in runs:
        want = entries(run.script.recorded.read_bytes())
        problem = run_problem(run)
        got = entries(run.state)
        index = first_difference(got, want)
        if problem is None and index is None:
            print(f"ok    {run.label}: {len(got)} checkpoints")
            continue
        failed += 1
        if index is None:
            print(f"FAIL  {run.label}: {problem}")
            continue
        marks = checkpoints(run.script.keys.read_text())
        print(f"FAIL  {run.label}: differs at {describe(index, marks, run.script.keys)}"
              + (f"; {problem}" if problem else ""))
        print(f"    recorded: {short(want[index] if index < len(want) else None)}")
        print(f"    now:      {short(got[index] if index < len(got) else None)}", end="")
        print(explain(tools, exes[compiler, run.script.program], run.script, compiler, want))
    print(f"{len(runs) - failed} passed, {failed} failed")
    return 1 if failed else 0


def cmd_compare(args: argparse.Namespace, tools: Tools) -> int:
    scripts = find_scripts(args.scripts)
    exes = build_all(tools, COMPILERS, scripts)
    work = [lambda s=s, c=c: run_script(tools, exes[c, s.program], s, c) for s in scripts for c in COMPILERS]
    runs = parallel(args.jobs, work)
    failed = 0
    for pe, rust in zip(runs[0::2], runs[1::2]):
        name = pe.script.name
        problems = [f"{r.compiler}: {p}" for r in (pe, rust) if (p := run_problem(r))]
        a, b = entries(pe.state), entries(rust.state)
        index = first_difference(a, b)
        if index is None and not problems:
            note = ""
            if pe.script.recorded.is_file():
                rec = first_difference(a, entries(pe.script.recorded.read_bytes()))
                note = "; same as recorded" if rec is None else "; NOT the recorded screens"
                failed += rec is not None
            print(f"{'ok  ' if 'NOT' not in note else 'FAIL'}  {name}: both builds show the same {len(a)} checkpoints{note}")
            continue
        failed += 1
        if index is None:
            print(f"FAIL  {name}: {'; '.join(problems)}")
            continue
        marks = checkpoints(pe.script.keys.read_text())
        print(f"FAIL  {name}: the builds differ at {describe(index, marks, pe.script.keys)}"
              + (f"; {'; '.join(problems)}" if problems else ""))
        print(f"    qb64pe:   {short(a[index] if index < len(a) else None)}")
        print(f"    qb64rust: {short(b[index] if index < len(b) else None)}")
    print(f"{len(scripts) - failed} passed, {failed} failed")
    return 1 if failed else 0


def cmd_record(args: argparse.Namespace, tools: Tools) -> int:
    scripts = find_scripts(args.scripts)
    exes = build_all(tools, COMPILERS, scripts)
    work = [lambda s=s, c=c, t=t: run_script(tools, exes[c, s.program], s, c, tag=t)
            for s in scripts for c in COMPILERS for t in ("1", "2")]
    runs = parallel(args.jobs, work)
    failed = 0
    for i, script in enumerate(scripts):
        group = runs[4 * i: 4 * i + 4]
        problems = [f"{r.label}: {p}" for r in group if (p := run_problem(r))]
        first = entries(group[0].state)
        differ = [r.label for r in group[1:] if first_difference(first, entries(r.state)) is not None]
        if problems or differ:
            failed += 1
            print(f"FAIL  {script.name}: not recorded")
            for p in problems:
                print(f"    {p}")
            if differ:
                print(f"    differs from {group[0].label}: {', '.join(differ)}")
            continue
        script.recorded.write_bytes(group[0].state)
        print(f"ok    {script.name}: {len(first)} checkpoints, the same in 4 runs; wrote {rel(script.recorded)}")
    # A copy with full states, kept on this machine only (tests/out/recorded), so that a check that
    # fails later can show the screen as it was recorded beside the screen now.
    done = [s for s in scripts if s.recorded.is_file()]
    full = parallel(args.jobs, [lambda s=s: run_script(tools, exes["rust", s.program], s, "rust", tag="full",
                                                       full_states=True)
                                for s in done])
    for run in full:
        if first_difference(entries(run.state), entries(run.script.recorded.read_bytes())) is None:
            full_copy(run.script).parent.mkdir(parents=True, exist_ok=True)
            full_copy(run.script).write_bytes(run.state)
        else:
            print(f"note  {run.script.name}: the run with full states differs; no local copy kept")
    return 1 if failed else 0


def full_copy(script: Script) -> Path:
    """The full states of a script's recording, kept on this machine by `record`."""
    return OUT / "recorded" / f"{script.name}.txt"


def cmd_coverage(args: argparse.Namespace, tools: Tools) -> int:
    """Runs the scripts with a coverage build, and the unit tests with `qb64rust test --coverage`
    when no script is named or --unit-tests is given, and reports the lines they reach (QB64Rust's tools/coverage/coverage.py).
    The report goes to tests/out/coverage/report.txt."""
    scripts = find_scripts(args.scripts)
    exes = build_all(tools, ("rust",), scripts, coverage=True)
    folder = OUT / "coverage"
    shutil.rmtree(folder, ignore_errors=True)
    folder.mkdir(parents=True)
    counts = {s.name: folder / f"{s.name}.txt" for s in scripts}
    work = [lambda s=s: run_script(tools, exes["rust", s.program], s, "rust", tag="coverage",
                                   extra_env={"QB64RUST_COVERAGE": str(counts[s.name])}) for s in scripts]
    runs = parallel(args.jobs, work)
    for run in runs:
        problem = run_problem(run)
        print(f"{'FAIL' if problem else 'ok  '}  {run.label}" + (f": {problem}" if problem else ""))
    for program in PROGRAMS:
        script_counts = [counts[s.name] for s in scripts if s.program == program and counts[s.name].is_file()]
        have = [str(p) for p in script_counts]
        if program == DEFAULT_PROGRAM and (args.unit_tests or not args.scripts):
            unit = unit_test_counts(tools, folder, args.jobs)
            if unit:
                have.append(str(unit))
                added = reached_only_by(unit, script_counts)
                print(f"  the unit tests reach {added} statements that no script reaches")
        if have:
            coverage_report(tools, folder, program, have)
        elif any(s.program == program for s in scripts):
            raise SetupError(f"no run of {PROGRAMS[program]} wrote its counts")
    return 0


def coverage_report(tools: Tools, folder: Path, program: str, have: list[str]) -> None:
    """Writes the coverage report of one program from its count files, and its table per SUB."""
    suffix = "" if program == DEFAULT_PROGRAM else f"-{program}"
    print(f"{PROGRAMS[program]}:")
    tool = tools.qb64rust_repo / "tools" / "coverage" / "coverage.py"
    r = subprocess.run([sys.executable, "-I", str(tool), "--program", str(GAME / PROGRAMS[program]), *have],
                       capture_output=True, text=True)
    report = folder / f"report{suffix}.txt"
    report.write_text(r.stdout + r.stderr)
    if r.returncode != 0:
        print(r.stdout + r.stderr)
        raise SetupError(f"coverage.py failed (exit code {r.returncode})")
    # One line per file: "<file>: <n> lines with a statement: <a> run, <b> partly run, <c> not run".
    total = [0, 0, 0, 0]
    for line in r.stdout.splitlines():
        name, sep, rest = line.partition(": ")
        if not sep or line.startswith(" ") or "lines with a statement" not in rest:
            continue
        numbers = [int(w) for w in rest.replace(",", " ").replace(":", " ").split() if w.isdigit()]
        if len(numbers) == 4 and numbers[0]:
            total = [t + n for t, n in zip(total, numbers)]
            print(f"  {name:12} {100 * (numbers[1] + numbers[2]) / numbers[0]:5.1f}%  {rest}")
    if total[0]:
        print(f"  {'all':12} {100 * (total[1] + total[2]) / total[0]:5.1f}%  {total[0]} lines with a statement: "
              f"{total[1]} run, {total[2]} partly run, {total[3]} not run")
    subs = folder / f"subs{suffix}.txt"
    subs.write_text(sub_table([Path(p) for p in have], PROGRAMS[program].lower()))
    print(f"report: {rel(report)}; per SUB: {rel(subs)}")


def unit_test_counts(tools: Tools, folder: Path, jobs: int) -> Path | None:
    """Runs the unit tests (`qb64rust test tests --coverage`) and writes their counts to
    folder/unit-tests.txt, with the game's files named as the scripts' records name them. None when
    no test wrote a record."""
    raw = folder / "unit-tests-raw.txt"
    log = folder / "unit-tests-log.txt"
    print("running the unit tests with --coverage ...", flush=True)
    env = dict(os.environ, QB64RUST_COVERAGE=str(raw))
    cmd = [str(tools.exes["rust"]), "test", "tests", "--coverage", "--jobs", str(jobs)]
    with open(log, "wb") as out:
        rc = subprocess.run(cmd, stdout=out, stderr=subprocess.STDOUT, cwd=GAME, env=env).returncode
    print(f"{'FAIL' if rc else 'ok  '}  unit tests" + (f": exit code {rc}; see {rel(log)}" if rc else ""))
    if not raw.is_file():
        return None
    rebased = folder / "unit-tests.txt"
    rebased.write_text(rebase_records(raw.read_text(encoding="latin-1")), encoding="latin-1")
    return rebased


def rebase_records(text: str) -> str:
    """Coverage records of the unit tests, made from tests/, as records of the game's folder. A file
    named `../<name>` becomes `<name>` (as `../rules/army.bm`); the test entry point, the test library and the test file are
    left out with their counts, as they are not files of the game."""
    out: list[str] = []
    keep: set[str] = set()
    for line in text.splitlines():
        parts = line.split("\t")
        if parts[0] == "file" and len(parts) == 4:
            name = parts[3]
            if name.startswith("../"):
                keep.add(parts[1])
                out.append("\t".join([*parts[:3], name[3:]]))
        elif len(parts) >= 4 and parts[0].isdigit():
            if parts[0] in keep:
                out.append(line)
        else:
            if line.startswith("coverage "):
                keep = set()
            out.append(line)
    return "\n".join(out) + "\n"


def statement_counts(count_files: list[Path]) -> dict[tuple[str, int, int], int]:
    """Each statement's count, merged over the records of the files: by (file name in lower case,
    line, column)."""
    counts: dict[tuple[str, int, int], int] = {}
    for path in count_files:
        names: dict[str, str] = {}
        for line in path.read_text(encoding="latin-1").splitlines():
            parts = line.split("\t")
            if parts[0] == "file" and len(parts) >= 4:
                names[parts[1]] = parts[3]
            elif len(parts) >= 4 and parts[0] in names and parts[1].isdigit():
                key = (names[parts[0]].lower(), int(parts[1]), int(parts[2]))
                counts[key] = counts.get(key, 0) + int(parts[3])
    return counts


def reached_only_by(unit: Path, scripts: list[Path]) -> int:
    """How many statements the counts of `unit` ran that no record of `scripts` ran."""
    by_scripts = statement_counts(scripts)
    return sum(1 for key, n in statement_counts([unit]).items() if n and not by_scripts.get(key))


def sub_table(count_files: list[Path], main: str = PROGRAMS[DEFAULT_PROGRAM].lower()) -> str:
    """The statements each SUB and FUNCTION has and runs, from coverage records, the least covered first.
    main is the file of the main module, in lower case."""
    counts = statement_counts(count_files)
    # Each file's lines, mapped to the procedure they are in.
    starts: dict[str, list[tuple[int, str]]] = {}
    for name in {k[0] for k in counts}:
        source = find_in(GAME, name)
        found: list[tuple[int, str]] = []
        if source and source.is_file():
            for n, text in enumerate(source.read_text(encoding="latin-1").splitlines(), 1):
                words = text.split()
                if len(words) >= 2 and words[0].upper() in ("SUB", "FUNCTION"):
                    found.append((n, words[1].split("(")[0]))
        starts[name] = found
    table: dict[tuple[str, str], list[int]] = {}
    for (name, line, _), count in counts.items():
        proc = "(main module)" if name == main else "(outside procedures)"
        for n, sub in starts[name]:
            if n <= line:
                proc = sub
        entry = table.setdefault((name, proc), [0, 0])
        entry[0] += 1
        entry[1] += count > 0
    rows = sorted(table.items(), key=lambda kv: (-(kv[1][0] - kv[1][1]), kv[0]))
    out = [f"{'file':10} {'procedure':22} {'statements':>10} {'run':>6} {'not run':>8} {'run %':>6}"]
    for (name, proc), (total, run) in rows:
        out.append(f"{name:10} {proc:22} {total:10} {run:6} {total - run:8} {100 * run / total:6.1f}")
    return "\n".join(out) + "\n"


def cmd_explore(args: argparse.Namespace, tools: Tools) -> int:
    script = load_script(Path(args.keys))
    exe = build(tools, args.compiler, program=script.program)
    # The keys; if the last step gave a key, a state at the next wait; then a prompt that no wait
    # answers, so the run stops there and writes the state at exit.
    folder = OUT / "explore"
    folder.mkdir(parents=True, exist_ok=True)
    keys = folder / f"{script.name}.keys"
    text = script.keys.read_text()
    steps = [line.split("#", 1)[0].split() for line in text.splitlines()]
    steps = [s for s in steps if s]
    last = steps[-1] if steps else []
    if last[:1] == ["repeat"] and len(last) == 2 and not last[1].isdigit():
        added = ""  # `repeat <key>` must be the last line; the game ends by itself
    elif last[:1] and last[0] in {"text", "key", "hold", "lift", "mouse", "press", "release", "wheel"}:
        added = "prompt\nstate\nprompt\n"
    else:
        added = "prompt\n"
    keys.write_text(text.rstrip("\n") + "\n" + ("# added by explore\n" + added if added else ""))
    run_env_ms = os.environ.get("QB64_SCREEN_PROMPT_MS")
    os.environ["QB64_SCREEN_PROMPT_MS"] = str(args.wait_ms)
    try:
        run = run_script(tools, exe, script, args.compiler, tag="explore", keys=keys, full_states=True)
    finally:
        if run_env_ms is None:
            os.environ.pop("QB64_SCREEN_PROMPT_MS", None)
        else:
            os.environ["QB64_SCREEN_PROMPT_MS"] = run_env_ms
    for old in folder.glob(f"{script.name}-*.png"):
        old.unlink()
    written = pngs(tools, run.folder / "screen.txt", folder / f"{script.name}.png")
    found = entries(run.state)
    print(f"exit code {run.rc}; {len(found)} entries; last: {short(found[-1]) if found else 'none'}")
    for path in written:
        print(f"  {rel(path)}")
    return 0


# ---------------------------------------------------------------------------------- main


def rel(path: Path) -> str:
    try:
        return Path(path).resolve().relative_to(GAME).as_posix()
    except ValueError:
        return str(path)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--qb64rust-repo", help="QB64Rust's repo (default: ../QB64Rust beside this repo)")
    parser.add_argument("--jobs", type=int, default=4, help="runs at a time (default 4)")
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("check", help="the QB64Rust build against the recorded screens")
    p.add_argument("--compiler", choices=COMPILERS, default="rust")
    p.add_argument("scripts", nargs="*")
    p = sub.add_parser("compare", help="the two builds against each other")
    p.add_argument("scripts", nargs="*")
    p = sub.add_parser("record", help="both builds, twice each; writes the recorded screens")
    p.add_argument("scripts", nargs="*")
    p = sub.add_parser("coverage", help="the lines of the game the scripts and the unit tests reach")
    p.add_argument("--unit-tests", action="store_true",
                   help="run the unit tests too when scripts are named (they always run when none is)")
    p.add_argument("scripts", nargs="*")
    p = sub.add_parser("explore", help="one run with a PNG of every state; stops at the next wait")
    p.add_argument("--compiler", choices=COMPILERS, default="rust")
    p.add_argument("--wait-ms", type=int, default=5000, help="how long the last prompt waits (default 5000)")
    p.add_argument("keys")
    args = parser.parse_args(argv)
    # What the command prints also goes to tests/out/last-<command>.txt, so that a failure seen once
    # can be read again.
    OUT.mkdir(parents=True, exist_ok=True)
    log = open(OUT / f"last-{args.command}.txt", "w", encoding="utf-8")
    sys.stdout = Tee(sys.stdout, log)
    try:
        tools = find_tools(args)
        command = {"check": cmd_check, "compare": cmd_compare, "record": cmd_record, "coverage": cmd_coverage,
                   "explore": cmd_explore}
        return command[args.command](args, tools)
    except SetupError as e:
        print(f"play.py: {e}", file=sys.stderr)
        print(f"play.py: {e}", file=log)
        return 2
    finally:
        sys.stdout = sys.stdout.streams[0]
        log.close()


class Tee:
    """Writes to several streams at once."""

    def __init__(self, *streams):
        self.streams = streams

    def write(self, text: str) -> int:
        for s in self.streams:
            s.write(text)
            s.flush()
        return len(text)

    def flush(self) -> None:
        for s in self.streams:
            s.flush()


if __name__ == "__main__":
    sys.exit(main())
