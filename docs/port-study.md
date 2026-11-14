# 46. Porting Civil War Strategy to QB64Rust: settled workflow

Written 2026-11-06. The port is done and committed. What it did, what it found and the choices D1 to D10
are in `archived\port-study-completed.md`. The user took every recommendation on 2026-11-06.
The remaining D8 question was settled on 2026-11-14: `qb64rust` will eventually merge into `main`
and replace the previous port.

## 4. Workflow choice settled

**D8. The workflow's trigger, and what `main` becomes.** `build.yml` builds on each merge into `main`, as the
other two ports do. Here `main` is the 2024 port, not the original. So the workflow runs only once `qb64rust`
is merged into `main`, which would replace the 2024 port.

**Chosen: (a)** (user, 2026-11-14). Leave the trigger as built: builds on merges into `main`, with no
additional trigger for pushes to `qb64rust`.

## Historical main

**Decided** (user, 2026-11-14): `qb64rust` will eventually merge into `main` and replace what was there.
Keep `old-main` as the historical branch: **main as it was before the latest rewrite**.
Its snapshot is commit `b02d2188115c7d9e5182696631d0f0372e947de3`
(`Merge pull request #23 from Hutsell-Games/minor-updates-for-release`).
The future merge is separate work; D8 has no remaining open question.
