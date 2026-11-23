#!/usr/bin/env python3
"""The Python half of tests/web/play_qbjs.js: what a script needs from tests/play.py.

    python tests/web/play_setup.py prepare <script> <folder>   fills <folder> as play.py fills a run's
                                                               folder; prints the script's set-up as JSON
    python tests/web/play_setup.py native <script> <folder>    runs the script in the QB64Rust build with a
                                                               full state at each checkpoint; writes
                                                               <folder>/native-<n>.png, one per checkpoint

<script> is a name of tests/scripts or the path of a keys file. "prepare" gives the run's folder the
game's data files, the script's CWS.CFG, its "#! data" folders and saves, less its "#! without" files,
by play.py's own functions, so a QBJS run starts from the same files as a native one. Its JSON holds
the seed, the dice, the files to hash after the run, the timeout, and the recorded checkpoints: the
digest and file lines of <script>.screen.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import play  # noqa: E402


def prepare(script: play.Script, work: Path) -> dict:
    work.mkdir(parents=True, exist_ok=True)
    play.copy_data(work)
    play.write_cfg(work, script.cfg)
    for name in script.data:
        play.copy_test_folder(work, play.TEST_DATA / name)
    play.remove_files(work, script.without)
    recorded = []
    if script.recorded.is_file():
        for entry in play.entries(script.recorded.read_bytes()):
            recorded.append(play.as_digest(entry).decode(errors="replace"))
    return {
        "name": script.name,
        "keys": str(script.keys),
        "seed": script.seed,
        "dice": script.dice,
        "files": script.files,
        "timeout": script.timeout,
        "checkpoints": play.checkpoints(script.keys.read_text()),
        "recorded": recorded,
    }


def native(script: play.Script, out: Path) -> dict:
    tools = play.find_tools(argparse.Namespace(qb64rust_repo=None))
    exe = play.build(tools, "rust", program=script.program)
    run = play.run_script(tools, exe, script, "rust", tag="web", full_states=True)
    problem = play.run_problem(run)
    out.mkdir(parents=True, exist_ok=True)
    for old in out.glob("native-*.png"):
        old.unlink()
    written = play.pngs(tools, run.folder / "screen.txt", out / "native.png")
    return {"problem": problem, "pngs": [str(p) for p in written]}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["prepare", "native"])
    parser.add_argument("script")
    parser.add_argument("folder")
    args = parser.parse_args()
    try:
        script = play.find_scripts([args.script])[0]
        folder = Path(args.folder).resolve()
        result = prepare(script, folder) if args.command == "prepare" else native(script, folder)
    except play.SetupError as e:
        print(json.dumps({"error": str(e)}))
        return 2
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
