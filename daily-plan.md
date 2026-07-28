# Daily plan — 2026-07-28

**What this repo is (for a newcomer):** A Cookiecutter-style *generator* that
installs a Markdown-based project-management workspace — a task tracker
(`tasks/`) plus periodic status reports (`status/`) — into any target repo at a
caller-chosen mount, non-destructively and re-runnably.

**Last implemented:** Task-tracker curation day — bootstrapped project-status
tracking here (daily-plan, kernel rule block, SessionStart hook) and captured the
two orphaned decisions nothing was watching: task 21 (retire the `tasks-test`
scratch repos) and task 22 (the deferred shared-generator-substrate call).

**Focus / plan:**

- **Close task 09 — the last open rollout.** Parts A–C are proven on
  create-ai-builder's `task-system-generator-migration` branch (strip `712379b`,
  regen `c86c49e`, parity verified against 134 real tasks); the branch is
  *unmerged and awaiting review*. Review the machinery-swap diff and merge —
  that work lands **in create-ai-builder**, from a session rooted there.
- Once merged, mark 09 `[x]` in `PLAN.md`. The generator then reproduces the
  subsystem it was extracted from — the loop is closed.
- Then start the discuss-then-resolve backlog, which is now the bulk of the
  queue. Suggested order: **19** (rename `Category` → `Worktree`) before **15**
  (`--require-category` opt-in), since 15 bakes the field name into a generate
  flag; then **18** (infer the parent in `complete-task.sh`) and **20**
  (`project/projects/` layout in the rich view).
- Cheap wins if there's slack: **21** (delete `tasks-test/` + `tasks-test-wt/`,
  silencing the un-bootstrapped-repo nudge) and **16** (skill + `USING.md` as the
  primary usage vehicle, kernel-only CLAUDE.md).
- **22** stays a discussion, not a build — the valid outcome is a *written
  trigger* in both copies of the decision, not a shared library today.

```
today ─┐
       ▼
  [09] merge task-system-generator-migration   ← in create-ai-builder
       (strip + regen proven, review pending)
            │  loop closed
            ▼
  discuss-then-resolve queue (this repo)
       19 ──► 15        18        20
    (rename)  (flag)  (parent)  (layout)
            │
            └─ slack: 21 (scratch-repo cleanup) · 16 (skill over CLAUDE.md)
                      22 stays a decision, not a build
```
