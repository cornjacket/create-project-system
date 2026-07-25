# Task 15 — `--require-category` opt-in enforcement

**Motivation (from task 09 CI):** the generic `new-user-task.sh` makes
`--category` **optional** (unset → `—`). create-ai-builder's original scripts
**required** a category on every USER-TASK (its worktree workflow depends on it).
The migration adopted the generic behavior; its test was relaxed (task 09,
`test_new_user_task.bats`). This task adds an **opt-in** way to get enforcement
back **without forking the script** — so any consumer whose workflow needs a
category on every task can turn it on.

## Design

- **Generate-time flag `--require-category`** on `generate.sh`. Implies (and
  should require) `--with-classes` — enforcement only makes sense with a
  `classes.md` to validate against.
- **Emit a config value** into the generated `task-config.sh`, e.g.
  `REQUIRE_CATEGORY=true` (mirrors how `PROJECTS_REL_LINE` is emitted;
  default/off is a comment or `false`).
- **`new-user-task.sh` reads it:** when `REQUIRE_CATEGORY` is true and no
  `--category` is given → error out non-zero with a clear message. When false
  (default), keep today's optional behavior. Unknown-category validation
  (against `classes.md`) stays as-is in both modes.

## Steps

- [ ] Add `--require-category` to `generate.sh` (arg + usage; error if set
      without `--with-classes`).
- [ ] Emit `REQUIRE_CATEGORY` into `task-config.sh.in` / render logic.
- [ ] Gate the required-category check in `src/scripts/new-user-task.sh` on it.
- [ ] Self-test: a `--require-category` fixture — missing category fails,
      present+valid succeeds, present+unknown fails; and default (off) still
      lets a missing category through.
- [ ] Regenerate golden fixtures if the flag adds files/lines.
- [ ] Doc it in `src/docs/USING.md` (Optional layers → Categories) and
      `src/layers/README.md`.

## Downstream

Once shipped, create-ai-builder can regenerate with `--require-category` to
restore its "every USER-TASK has a Category" policy, and its
`test_new_user_task.bats` can re-add a "fails when --category is missing" test
(see the note left there in task 09).

## Done when

`generate.sh --with-classes --require-category` produces a task system where
`new-user-task.sh` refuses to create a category-less task, while the default
(flag off) keeps `--category` optional. Self-test + golden cover both.
