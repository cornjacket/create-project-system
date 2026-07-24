# Task 07 — Generate into `second-brain/` (real target)  ✅ DONE

> **Result (2026-07-24):** installed at repo root via
> `--tasks-dir project/tasks --epic main --with-status --with-skill`. Root
> resolution + full task lifecycle smoke-tested from the second-brain root;
> sentinel-wrapped `## Task tracking` pointer hand-placed in `CLAUDE.md` (task 11
> markers). **Zero semantic-cache pollution** — the pre-commit `embed_staged.py`
> only touches `vault/<para-root>/`, so the root-level `project/` + `.claude/`
> files are ignored (confirmed: no `.embed.json` sidecars created). Committed to
> second-brain as `5b6d9d4`. No collision with the brain's own `install_skill.py`
> (its skill is named `second-brain`; ours is `task-system`).

**Goal:** install the task subsystem into the actual second-brain repo once the
generator is validated against `tasks-test/`.

## Decisions (from the option-B discussion)

- **Mount:** `project/tasks` — grows a `project/` workspace with `tasks/` +
  `status/` siblings. second-brain's pre-commit hook already exempts `tasks/`,
  and top-level machinery stays out of `vault/` (so task READMEs are never
  embedded into the semantic cache).
- **Layers:** `--with-status --with-skill`. **No** `--with-projects` — the word
  collides with second-brain's PARA `vault/projects/`. **No** classes/guard
  (single-workspace repo, no worktrees).
- **CLAUDE.md:** manual, not `--inject-claude-md` — second-brain's CLAUDE.md is
  tightly curated with sentinel blocks; hand-place the 1–2 line pointer.

## Still to confirm before running

- [ ] Reconcile the container `project/README.md` with anything second-brain
      already keeps at that path (none today).
- [ ] Confirm the brain's `install_skill.py` doesn't also manage
      `.claude/skills/` (different mechanism — verify no overlap).

## Steps

- [ ] Run:
      `generate.sh --target-repo /Users/david/second-brain --tasks-dir project/tasks --epic main --with-status --with-skill`
- [ ] Smoke-test the scripts from the second-brain root.
- [ ] Commit the generated subsystem in second-brain (separate from this repo).

## Done when

second-brain has a working, generated task subsystem and the generation command
is recorded for future re-runs/upgrades.

Ref: `docs/extraction-analysis.md` §7 (generation targets).
