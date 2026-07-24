# Task 08 — Generate into `captains-log` (later)

**Goal:** install the task subsystem into the `captains-log` repo via
`generate.sh`.

**Do not start until task 07 (second-brain) succeeds** — captains-log is a
follow-on rollout, not part of validation.

**Target:** `../captains-log` (sibling repo under `cornjacket/`).

## Open questions to resolve first

- [ ] Confirm the mount dir inside captains-log (e.g. `tasks/` vs `.tasks/`).
- [ ] Which optional layers does captains-log want? (classes / projects /
      worktree-guard) — confirm before generating.
- [ ] `--inject-claude-md` vs. manual snippet placement, given any existing
      agent instructions in captains-log.

## Steps

- [ ] Run `generate.sh` against captains-log with the confirmed flags + mount.
- [ ] Smoke-test the scripts from the captains-log root.
- [ ] Commit the generated subsystem in captains-log (separate from this repo).
- [ ] Record the generation command for future re-runs/upgrades.

## Done when

captains-log has a working, generated task subsystem and its generation command
is recorded.

Ref: `docs/extraction-analysis.md` §7 (generation targets).
