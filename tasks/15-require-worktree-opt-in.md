# Task 15 — `--require-worktree` opt-in enforcement

> **Renamed by task 19 (2026-07-28).** The field is now `Worktree`, so the flag
> this task adds is `--require-worktree`, gated on `--with-worktrees`. Task 19
> shipped first precisely so this would not bake in the old name.

**Motivation (from task 09 CI):** the generic `new-user-task.sh` makes
`--worktree` **optional** (unset → `—`). create-ai-builder's original scripts
**required** a worktree on every USER-TASK (its worktree workflow depends on it).
The migration adopted the generic behavior; its test was relaxed (task 09,
`test_new_user_task.bats`). This task adds an **opt-in** way to get enforcement
back **without forking the script** — so any consumer whose workflow needs a
worktree on every task can turn it on.

## Design

- **Generate-time flag `--require-worktree`** on `generate.sh`. Implies (and
  should require) `--with-worktrees` — enforcement only makes sense with a
  `worktrees.md` to validate against.
- **Emit a config value** into the generated `task-config.sh`, e.g.
  `REQUIRE_WORKTREE=true` (mirrors how `PROJECTS_REL_LINE` is emitted;
  default/off is a comment or `false`).
- **`new-user-task.sh` reads it:** when `REQUIRE_WORKTREE` is true and no
  `--worktree` is given → error out non-zero with a clear message. When false
  (default), keep today's optional behavior. Unknown-worktree validation
  (against `worktrees.md`) stays as-is in both modes.

## Steps

- [ ] Add `--require-worktree` to `generate.sh` (arg + usage; error if set
      without `--with-worktrees`).
- [ ] Emit `REQUIRE_WORKTREE` into `task-config.sh.in` / render logic.
- [ ] Gate the required-worktree check in `src/scripts/new-user-task.sh` on it.
- [ ] Self-test: a `--require-worktree` fixture — missing worktree fails,
      present+valid succeeds, present+unknown fails; and default (off) still
      lets a missing worktree through.
- [ ] Regenerate golden fixtures if the flag adds files/lines.
- [ ] Doc it in `src/docs/USING.md` (Optional layers → Worktrees) and
      `src/layers/README.md`.

## Downstream

Once shipped, create-ai-builder can regenerate with `--require-worktree` to
restore its "every USER-TASK has a Worktree" policy, and its
`test_new_user_task.bats` can re-add a "fails when --worktree is missing" test
(see the note left there in task 09).

## Done when

`generate.sh --with-worktrees --require-worktree` produces a task system where
`new-user-task.sh` refuses to create a worktree-less task, while the default
(flag off) keeps `--worktree` optional. Self-test + golden cover both.
