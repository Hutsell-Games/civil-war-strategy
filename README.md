# W.R. Hutsell's Civil War Strategy Game
A strategic level, one or two player wargame simulating the American Civil War (1861-1865).

## This branch: the QB64 port
W.R. Hutsell wrote the game in Microsoft BASIC PDS 7.1 for DOS and gave the source to Dave Mackey. The
original source is kept unchanged on the branch `canonical-source`.

This branch, `qb64rust`, changes that source as little as possible so that the game builds with QB64Rust
and QB64pe, and so that its SUBs can be tested. It builds one program, `CWSTRAT.BAS`, which includes the other
source files (`CWS14.BI`, `FOLDERS.BI`, `CWSTRAT1.BM`, `CWSTRAT2.BM`, `CWSMENU.BM`, `QB64.BM`, `SCRIPT.BM`, and
the six files of the drawing SUBs in `drawings\`):

```
qb64rust -x CWSTRAT.BAS -o cws.exe
```

The build is not committed (`.gitignore`). It takes the name of the DOS program, `CWS.EXE`. A GitHub Actions
workflow (`.github\workflows\build.yml`) builds the game too. As in the World War 2 port, it runs on each
merge into `main`, and by hand once it is on `main` (Actions, Build, Run workflow). Its artifact
`civil-war-strategy` holds the game with its data files, ready to play. This branch is not merged into `main`
yet, so the workflow has not run.

Run the program from this folder. It reads its pictures from `graphics` and its map, setup and leaders from
`scenarios`. Its settings (`CWS.CFG`), its Hall of Fame (`HISCORE.CWS`), saved games and history files stay
beside the program. To play on the alternate map, run `ALTMAP.BAT` in `scenarios`; run it again to switch
back.

Four things of the DOS game are pictures and text in `docs` now, because the DOS programs that showed them
have no source: the title screen, the burning capital, the picture of Lincoln, and the help screens of F1
([docs/devnotes.md](docs/devnotes.md), items 5 and 6). The game no longer has F1 help. The quick help is
[docs/CWSDOC.TXT](docs/CWSDOC.TXT), and the full manual is [docs/CWS.DOC](docs/CWS.DOC).

The branch `main` holds an earlier port, of 2024, for QB64pe. This branch does not build on it.

The tests are described in [tests/README.md](tests/README.md). Work still to do is in [TODO.md](TODO.md).

The original documentation of the game is in `docs`: the manual `CWS.DOC`, `README.1ST` and `WRHGAMES.DOC`.
The notes on the port are in [docs/devnotes.md](docs/devnotes.md).
