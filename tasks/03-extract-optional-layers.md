# Task 03 — Extract the in-scope optional layers  ✅ DONE

> **Result:** three layers under `src/layers/` (classes, projects, worktree-guard).
> Verified by a 26-assertion test: each layer works when ON, and the core degrades
> cleanly when OFF. Also resolved the two items flagged in task 02 — `PROJECTS_REL`
> wiring and the hardcoded ai-builder `CATEGORY_ORDER`.

**Goal:** add the three decided optional layers, each flag-gated so the human
core works without them.

**Source:** `../ai-builder/main/`

## `--with-classes` (worktree categories)

- [x] Emit a **starter** `classes.md` (empty class table + instructions), not
      ai-builder's 8 classes.
- [x] In `new-user-task.sh`: require + validate `--category` against `classes.md`
      **only when this layer is on**; otherwise drop the requirement and skip the
      `classes.md` read (so it never hard-fails without the file).
- [x] Keep `list-tasks.sh` `--category` / `--group-by-category` filters
      (harmless no-ops when the layer is off).
- [x] Include the `Category` field in `user-task-template.md` only when on.

## `--with-projects` (long-running services)

- [x] Extract `new-project.sh`, `list-projects.sh` (the `projects/` variant).
- [x] Parameterize its mount path via `task-config.sh` (second location under
      the repo).

## `--with-worktree-guard`

- [x] Extract `bootstrap/check-task-complete.py` into the layer; parameterize the
      tasks-root argument.

## Done when

Each layer is a self-contained set of files the generator includes only when its
flag is passed; core generation with no flags omits all three cleanly.

Ref: `docs/extraction-analysis.md` §3.3, §4 (in-scope layers).
