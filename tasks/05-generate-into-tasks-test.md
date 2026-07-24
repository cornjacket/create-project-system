# Task 05 — `tasks-test/`: the regeneration / upgrade path

**Goal:** answer the question nothing else in the plan answers — **what happens
when you generate over a repo that already has the subsystem installed, with real
tasks in it?**

`tasks-test/` is a sibling repo under `cornjacket/`. Unlike the disposable
`sandbox/` (task 04b), its generated output is **committed**, precisely so that
regenerating produces a reviewable **diff**.

> **Not this task's job.** "Does generation work / do the scripts run" is covered
> faster by the `sandbox/` self-test (04b), and "does output drift" by the golden
> test (06). Keep the smoke check here thin and don't duplicate them.

**Why it matters:** second-brain, captains-log, and ai-builder will all need
regenerating when the generator improves. Task 09 hits the hardest version of
this (ai-builder has dozens of real tasks). This task is where that risk gets
retired cheaply, on a repo nobody depends on.

## Part A — First install (thin)

- [ ] Create `tasks-test/` (`git init`) as a sibling of `create-task-system/`.
- [ ] `generate.sh --target-repo ../tasks-test --tasks-dir tasks --epic main`
- [ ] Smoke-check only: create a task + subtask, list, complete one. (Depth of
      verification lives in 04b.)
- [ ] **Commit the generated output** — this is the baseline every later diff is
      read against.

## Part B — Regeneration over an existing install

This is the substance of the task.

- [ ] Create real content first: a few tasks across `draft/`, `in-progress/`,
      `complete/`, at least one with completed (`X-`) subtasks, and a non-default
      `Next-subtask-id`. Commit it.
- [ ] Re-run the **same** `generate.sh` command unchanged. Then:
      - [ ] `git status` / `git diff` — **user task content must be untouched**.
      - [ ] Machinery may be rewritten, but only where it actually changed.
      - [ ] Status-folder `README.md` task lists must not be clobbered or reset.
- [ ] Change something in `src/` (e.g. a script fix), regenerate, and confirm the
      diff shows **only** that change.
- [x] **Collision policy — DECIDED and implemented in task 04.** Machinery is
      always overwritten; content (epic/status folders, task lists, `classes.md`)
      is created only if missing, never overwritten. An identical re-run yields a
      zero-line diff. `--force` only re-seeds content. Verify that holds here
      against a *committed* install with real history.
- [ ] Test adding a layer to an existing install: regenerate with
      `--with-classes --with-projects --with-worktree-guard` over the core
      install and confirm layers appear without disturbing existing tasks.

## Part C — Git layout matrix

- [ ] **Single git workspace:** `tasks-test/` as above.
- [ ] **Git worktree:** `tasks-test-wt/` set up like ai-builder (`.bare` + linked
      `main/`). Generate into `main/`; confirm root resolves to the worktree root,
      not `.bare`. (Cheap here, decisive in task 09.)

## Done when

Regenerating over an existing, committed install is a **reviewable, non-destructive
diff** — existing task content survives untouched — and the collision policy is
decided and implemented in `generate.sh`.

Ref: `docs/extraction-analysis.md` §5, §7. Feeds task 09 (ai-builder migration).
