# W.R. Hutsell's Civil War Strategy Game
A strategic level, one or two player wargame simulating the American Civil War (1861-1865).

See the [changelog](CHANGELOG.md) for player-facing changes in the current port and earlier releases.

## This branch: the QB64 port
W.R. Hutsell wrote the game in Microsoft BASIC PDS 7.1 for DOS and gave the source to Dave Mackey. The
original source is kept unchanged on the branch `canonical-source`.

To compile on Windows:

```
qb64rust -x cws.bas -o cws.exe
```

On Linux, build a native executable with `qb64rust -x cws.bas -o cws`, then run `./cws`
from this folder.

The build is not committed (`.gitignore`). It takes the name of the DOS program, `CWS.EXE`. A GitHub Actions
workflow (`.github\workflows\build.yml`) builds the game too. It runs on each
merge into `main`, and by hand once it is on `main` (Actions, Build, Run workflow). Its artifact
`civil-war-strategy` holds the game with its data files, ready to play. The workflow then runs the tests
(Python tests and unit tests on Windows, the whole-game scripts on Linux).

Run the program from this folder. It reads its pictures from `graphics` and its map, setup, leaders
and special events from `scenarios`. Its settings (`CWS.CFG`), its Hall of Fame (`HISCORE.CWS`),
saved games and history files stay beside the program. Each map is a folder of
`scenarios`: `standard` and `alternate`.

The window opens at 1280 by 960, when the desktop has room for it
(`window_open`, `cws.bas`). It can be resized: drag its edge and the screen is stretched to fill it
(`$RESIZE:STRETCH`). Alt+Enter switches to full screen and back.

The game no longer has F1 help. The quick help is
[docs/CWSDOC.TXT](docs/CWSDOC.TXT), and the full manual is [docs/CWS.DOC](docs/CWS.DOC).

The tests are described in [tests/README.md](tests/README.md). Work still to do is in [TODO.md](TODO.md).

The original documentation of the game is in `docs`: the manual `CWS.DOC`. The DOS game's release notes (its `README.1ST`) are in [CHANGELOG.md](CHANGELOG.md).
The notes on the port are in [docs/devnotes.md](docs/devnotes.md).
The permanent record of gameplay-rule and AI changes from the canonical DOS game is
[docs/rule-changes.md](docs/rule-changes.md).
