# Task 02 — Extract & refactor the CORE subsystem into `src/`  ✅ DONE

> **Result:** 22 files in `src/scripts/`, 2 templates, 2 docs. Zero
> `project/tasks` / `../../..` coupling remains in code (only deliberate
> explanatory comments in `task-env.sh` / `task-config.sh.in`). Verified by a
> 66-assertion end-to-end integration test across three layouts — standard repo
> (`tasks`), nested mount (`pm/tasks`), and a **git worktree** — all green.

**Goal:** copy the repo-agnostic core from ai-builder into `src/`, refactored to
remove the two coupling points.

**Source:** `../ai-builder/main/project/tasks/`

## Scripts → `src/scripts/`

Copy and refactor these CORE scripts:

- [x] `task-id-helpers.sh`, `task-json-helpers.sh` (shared libs)
- [x] `new-user-task.sh` (make `--category` handling gated — see task 03),
      `new-user-subtask.sh`, `new-epic.sh`
- [x] `move-task.sh`, `complete-task.sh`, `complete-subtask.sh`
- [x] `delete-task.sh`, `restore-task.sh`
- [x] `show-task.sh`, `list-tasks.sh`, `list-tasks.md`, `next-subtask.sh`
- [x] `insert-subtask.sh`, `rename-subtask.sh`, `reorder-subtasks.py`
- [x] `wont-do-subtask.sh`, `subtasks-complete.sh`, `is-last-task.sh`, `is-top-level.sh`

## Refactor applied to every script

- [x] Replace `REPO_ROOT="$(cd "$SCRIPTS_DIR/../../.." && pwd)"` with the
      `resolve_repo_root` helper (git toplevel + walk-up fallback).
- [x] `source "$SCRIPTS_DIR/task-config.sh"` and replace every hardcoded
      `project/tasks` literal (path building **and** error strings) with
      `"$TASKS_REL"`. Target: zero `project/tasks` literals remain.
- [x] Confirm `_sed_i` (BSD/GNU sed wrapper) is carried over — keep portability.

## Templates → `src/templates/`

- [x] `user-task-template.md`, `user-subtask-template.md`

## Docs → `src/docs/`

- [x] `README.md` (rewrite `project/tasks` literals to `{{TASKS_REL}}` /
      generated value)
- [x] `task-manager.md` (optional Oracle-guide starter)
- [x] **Do not** dump the full task-management rules into the CLAUDE.md snippet.
      The bulk how-to goes into `src/docs/USING.md` and the snippet becomes a
      thin kernel — both handled in **task 03b**. Leave
      `src/snippets/claude-md.snippet.md` as a stub here.

## Done when

The core scripts run correctly against a scratch dir at an arbitrary mount path
(e.g. `tasks/`, `pm/tasks/`) with no `project/tasks` or `../../..` assumptions.

Ref: `docs/extraction-analysis.md` §2, §3.1–§3.4.
