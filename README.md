# W.R. Hutsell's Civil War Strategy Game
A strategic level, one or two player wargame simulating the American Civil War (1861-1865).

## This branch: the QB64 port
W.R. Hutsell wrote the game in Microsoft BASIC PDS 7.1 for DOS and gave the source to Dave Mackey. The
original source is kept unchanged on the branch `canonical-source`.

This branch, `qb64rust`, changes that source as little as possible so that the game builds with QB64Rust
and QB64pe, and so that its SUBs can be tested. It builds one program, `cws.bas`, which includes the other
source files (`cws.bi` and the `.BM` files in `rules\`, `ai\`, `commands\`, `ui\`, `draw\`, `game\` and `port\`; `docs\file-layout.md` lists them):

```
qb64rust -x cws.bas -o cws.exe
```

The build is not committed (`.gitignore`). It takes the name of the DOS program, `CWS.EXE`. A GitHub Actions
workflow (`.github\workflows\build.yml`) builds the game too. As in the World War 2 port, it runs on each
merge into `main`, and by hand once it is on `main` (Actions, Build, Run workflow). Its artifact
`civil-war-strategy` holds the game with its data files, ready to play. This branch is not merged into `main`
yet, so the workflow has not run.

Run the program from this folder. It reads its pictures from `graphics` and its map, setup, leaders
and special events from `scenarios`. Its settings (`CWS.CFG`), its Hall of Fame (`HISCORE.CWS`),
saved games and history files stay beside the program. Each map is a folder of
`scenarios`: `standard` and `alternate`. After Start NEW Game the game asks which map to play;
`scenarios\SCENARIOS.LST` names the folders and their titles.

The window can be resized: drag its edge and the 640 by 480 screen is stretched to fill it
(`$RESIZE:STRETCH`, `cws.bas`). Alt+Enter switches to full screen and back.

Four things of the DOS game are pictures and text in `docs` now, because the DOS programs that showed them
have no source: the title screen, the burning capital, the picture of Lincoln, and the help screens of F1
([docs/devnotes.md](docs/devnotes.md), items 5 and 6). The game no longer has F1 help. The quick help is
[docs/CWSDOC.TXT](docs/CWSDOC.TXT), and the full manual is [docs/CWS.DOC](docs/CWS.DOC).

The branch `main` holds an earlier port, of 2024, for QB64pe. This branch does not build on it.

The tests are described in [tests/README.md](tests/README.md). Work still to do is in [TODO.md](TODO.md).

The original documentation of the game is in `docs`: the manual `CWS.DOC`, `README.1ST` and `WRHGAMES.DOC`.
The notes on the port are in [docs/devnotes.md](docs/devnotes.md).
The permanent record of rule and behavior changes from the canonical DOS game is
[docs/rule-changes.md](docs/rule-changes.md).
