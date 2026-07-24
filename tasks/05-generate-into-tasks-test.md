# Task 05 — `tasks-test/`: the regeneration / upgrade path  ✅ DONE

> **Result:** the upgrade path works. Regenerating over a **committed** install
> holding real task content produces a **zero-line git diff**, and a one-line
> change in `src/` propagates as exactly a one-line diff in the target.
> Verified in both the standard and git-worktree layouts.
>
> Repos created: `tasks-test/` (standard) and `tasks-test-wt/` (`.bare` + linked
> `main/`, mirroring ai-builder).

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

- [x] Create `tasks-test/` (`git init`) as a sibling of `create-task-system/`.
- [x] `generate.sh --target-repo ../tasks-test --tasks-dir tasks --epic main`
- [x] Smoke-check only: create a task + subtask, list, complete one.
- [x] **Commit the generated output** — baseline `0cbf5f4`, 36 files.

## Part B — Regeneration over an existing install

This is the substance of the task.

- [x] Real content created and committed: `design-search` (draft, 3 subtasks, one
      `X-` complete, `Next-subtask-id: 0003`), `build-indexer` (in-progress),
      `spike-tokenizer` (complete).
- [x] Re-ran the **same** command unchanged → **`git status` reported 0 changed
      files**. Task content, status-folder task lists, and `X-` subtasks all
      intact; generator reported `= tasks/main/ (epic exists — task content
      preserved)`.
- [x] One-line probe added to `src/scripts/show-task.sh`, regenerated → diff was
      exactly `1 file changed, 2 insertions(+)`, confined to that file. Probe
      reverted and regenerated → target restored to 0 changed files.
- [x] **Collision policy — DECIDED and implemented in task 04.** Machinery is
      always overwritten; content (epic/status folders, task lists, `classes.md`)
      is created only if missing, never overwritten. An identical re-run yields a
      zero-line diff. `--force` only re-seeds content. Verify that holds here
      against a *committed* install with real history.
- [x] Layers added to the existing install (`--with-classes --with-projects
      --with-worktree-guard --with-skill`): only machinery + new layer files
      changed; existing task content untouched. `task-config.sh` gained
      `PROJECTS_REL`, the template regained its `Category` row.
      **Finding:** tasks created *before* the classes layer existed degrade
      gracefully to `[unclassified]` rather than breaking.
- [x] A **user-authored** class added to `classes.md` survives regeneration, and
      `--category` immediately accepts the new value — confirming `classes.md` is
      treated as content, not machinery.

## Part C — Git layout matrix

- [x] **Single git workspace:** `tasks-test/` — zero-diff regeneration confirmed.
- [x] **Git worktree:** `tasks-test-wt/` (`.bare` + linked `main/`, `main/.git`
      is a FILE). Root resolved to `.../tasks-test-wt/main` (not `.bare`); task
      creation works; regeneration over the committed worktree install also
      produced a **zero-line diff**.

## Done when

Regenerating over an existing, committed install is a **reviewable, non-destructive
diff** — existing task content survives untouched — and the collision policy is
decided and implemented in `generate.sh`.

Ref: `docs/extraction-analysis.md` §5, §7. Feeds task 09 (ai-builder migration).
