# 46. Porting Civil War Strategy to QB64Rust: what was done, and what waits for the user

Written 2026-11-06. The port is done and committed. What it did, what it found and the choices D1 to D10
are in `archived\port-study-completed.md`. The user took every recommendation on 2026-11-06. One question
is left, behind D8: whether `qb64rust` replaces the game's `main`.

## 4. Choices made, for the user to rule on

**D8. The workflow's trigger, and what `main` becomes.** `build.yml` builds on each merge into `main`, as the
other two ports do. Here `main` is the 2024 port, not the original. So the workflow runs only once `qb64rust`
is merged into `main`, which would replace the 2024 port.
- (a) As built: leave the trigger. The user decides later whether `qb64rust` replaces `main`.
- (b) Also build on each push to `qb64rust`.

*Panel:* the pragmatic engineer wants (a): which branch is the game's future is the user's call, and (b) spends
CI time on every push. The QB64 user would like one answer for all three games. **Recommended: (a).** The
question behind it, whether `qb64rust` replaces `main` here, is put to the user and not answered by this
study.

## 5. What is left

3. **Open:** D8's question, whether `qb64rust` replaces the game's `main`.