# Daily plan — 2026-07-24

**What this repo is (for a newcomer):** A Cookiecutter-style *generator* that
installs a Markdown-based project-management workspace — a task tracker
(`tasks/`) plus periodic status reports (`status/`) — into any target repo at a
caller-chosen mount, non-destructively and re-runnably.

**Last implemented:** Option B — added the `--with-status` layer so the
generator reproduces the whole `project/` workspace (tasks + status), not just
the tasks pillar; renamed the repo `create-task-system` → `create-project-system`
to match. Self-test at 61 assertions green; new `project` golden fixture pins the
container layout.

**Focus / plan:**

- **Task 07 — first real rollout: generate into `second-brain/`.** Run at repo
  root (siblings of `vault/`, never inside it):
  `--tasks-dir project/tasks --epic main --with-status --with-skill`.
- Smoke-test the emitted scripts from the second-brain root; **review the diff
  before committing** anything into that live repo.
- Confirm no overlap with second-brain's own `install_skill.py` / `.claude/`.
- Low-priority cleanup: update the 3 second-brain notes that still cite the old
  `create-task-system` name.
- If 07 lands cleanly, tee up **task 08** (captains-log).

```
today ─┐
       ▼
   [07] second-brain  ──►  [08] captains-log  ──►  [09] task-free ai-builder
   generate @ root         (next)                  (closes the loop)
   project/{tasks,status}
```
