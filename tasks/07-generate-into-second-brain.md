# Task 07 — Generate into `second-brain/` (real target, later)

**Goal:** install the task subsystem into the actual second-brain repo once the
generator is validated against `tasks-test/`.

**Do not start until tasks 05–06 pass.**

## Open questions to resolve first

- [ ] Confirm the target repo path and the desired mount dir inside it
      (e.g. `tasks/` vs `pm/tasks/` vs `.tasks/`).
- [ ] Which optional layers does second-brain want? (classes / projects /
      worktree-guard) — likely projects for long-running notes work; confirm.
- [ ] Decide `--inject-claude-md` vs. manual snippet placement for second-brain's
      existing agent instructions.

## Steps

- [ ] Run `generate.sh` against second-brain with the confirmed flags + mount.
- [ ] Smoke-test the scripts from the second-brain root.
- [ ] Commit the generated subsystem in second-brain (separate from this repo).

## Done when

second-brain has a working, generated task subsystem and the generation command
is recorded for future re-runs/upgrades.

Ref: `docs/extraction-analysis.md` §7 (generation targets).
