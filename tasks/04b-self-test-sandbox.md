# Task 04b — Self-test generation in a disposable in-repo sandbox  ✅ DONE

> **Result:** `self-test.sh` at the repo root — **54 assertions, all green**, in
> ~15s. Covers core + all-layers generation, full task lifecycle, decoupling
> checks, regeneration safety, the git-worktree layout, and CLAUDE.md injection.
> Tears `sandbox/` down via an EXIT trap (`--keep` to inspect); exits non-zero on
> failure, so it is CI-ready as-is.

**Goal:** a fast, self-contained smoke test that runs `generate.sh` into a
**disposable sandbox repo living inside `create-project-system` itself** — no
external sibling repo needed. This is the quick inner-loop check; the sibling
`tasks-test/` (task 05) and golden test (task 06) build on it.

**Location:** `create-project-system/sandbox/` — throwaway, regenerated each run,
git-ignored (never committed).

## Steps

- [x] Add `sandbox/` to `.gitignore`.
- [x] Write `self-test.sh` that, in a clean temp dir under `sandbox/`:
      - [x] `git init` the disposable target.
      - [x] Run `generate.sh --target-repo sandbox/<tmp> --tasks-dir tasks
            --epic main` (core), then a second run with all in-scope flags
            (`--with-classes --with-projects --with-worktree-guard --with-skill`).
      - [x] Exercise the emitted scripts from the sandbox root: create a
            user-task, nest a subtask, list, complete (verify `[x]` + `X-`).
      - [x] Assert no `project/tasks` / `../../..` leakage; `git rev-parse`
            root resolution works.
      - [x] Tear down the temp dir at the end (idempotent, leaves no trace).
- [x] Cover **both git layouts** in the sandbox (cheap here): single workspace
      and a `.bare`+linked-`main/` worktree (mirrors task 05's matrix).
- [x] Make it runnable as one command: `bash self-test.sh` exits non-zero on any
      failure (CI-ready).

## Why in-repo (vs the sibling `tasks-test/`)

The sandbox is for the **fast, always-available** self-check that runs on every
change to `generate.sh` or `src/`. `tasks-test/` (task 05) is the deliberate,
committed, real-separate-repo validation. Keep both: sandbox = inner loop,
tasks-test = acceptance.

## Done when

`bash self-test.sh` generates, exercises, and tears down cleanly for core and
all-layers variants under both git layouts, leaving `sandbox/` empty.

Ref: `docs/extraction-analysis.md` §5; tasks 04, 05, 06.
