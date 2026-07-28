# Task 21 — Clean up and delete the `tasks-test/` and `tasks-test-wt/` scratch repos

**Type: cleanup.** Retire the throwaway test-target repos created by task 05.

## Why

Task 05 (`05-generate-into-tasks-test.md`, ✅ DONE) created two **local sibling
repos under `cornjacket/`** purely to verify the generator's regeneration /
upgrade path against a *committed* install:

- `tasks-test/` — standard single-workspace layout.
- `tasks-test-wt/` — git-worktree layout (`.bare` + linked `main/`, mirroring
  ai-builder), to prove worktree-root resolution.

Both were, in task 05's own words, "a repo nobody depends on." The upgrade path
is verified and the worktree layout is now exercised by real consumers, so these
scratch repos are dead weight. They are also **not** on any remote and **not**
tracked by project-status, so deleting them is a local-only operation.

## Facts confirmed (2026-07-27)

- Neither repo has a git remote; neither exists on GitHub (`cornjacket/tasks-test`
  / `cornjacket/tasks-test-wt` both 404). Deletion is `rm -rf`, nothing to
  un-publish.
- Neither is in project-status `repos.yml` — no untracking needed.
- `tasks-test-wt/` is a worktree layout: `main/.git` is a **file** pointing into
  `.bare/`. A plain `rm -rf tasks-test-wt/` removes it all (no external worktree
  registration to prune), but confirm nothing else links into its `.bare`.
- References to these repos inside this repo: `PLAN.md`, `tasks/04b-…`,
  `tasks/05-…`, `tasks/07-…`, `docs/extraction-analysis.md`.

## What to do

- [ ] Delete `../tasks-test/` and `../tasks-test-wt/` from the local workspace.
- [ ] Sanity-check first: `git -C ../tasks-test status` / worktree has no
      un-pushed unique work worth keeping (there is no remote, so anything there
      is lost on delete — expected, but eyeball it once).
- [ ] Decide the reference policy:
      - **Completed task docs (04b, 05, 07) + `docs/extraction-analysis.md`** are
        historical records — leave them as-is (they describe what was done).
      - **`PLAN.md`** — if it carries a *live* pointer implying these repos still
        exist, add a one-line "retired 2026-07-27" note; otherwise leave it.
- [ ] Removing them also silences the user-level `check-repo-bootstrap.py`
      SessionStart nudge, which flags any un-bootstrapped git repo under the
      workspace root (these two qualify). Confirm the nudge is gone afterward.

## Done when

Both scratch repos are gone from the workspace, no dangling worktree or
remote references remain, and any *live* mention in `PLAN.md` is reconciled
(historical task docs left intact as the record).
