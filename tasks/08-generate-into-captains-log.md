# Task 08 — Generate into `captains-log`  ✅ DONE

> **Result (2026-07-24):** full canonical layout installed —
> `--tasks-dir project/tasks --epic main --with-status --with-skill
> --inject-claude-md`. User chose the full workspace (tasks + status) despite the
> existing `log/` narrative overlap. First real use of the task-11 sentinel
> injection: the `task-system:begin/end` block appended cleanly to CLAUDE.md and
> coexists with the existing `ai-project-status` managed block (different marker
> namespaces, no collision). Root resolution + full lifecycle smoke-tested from
> the captains-log root; no placeholder leaks. No embed hooks in captains-log, so
> no cache concern. Committed as `3c436c3`. Skill named `task-system`, no
> collision with captains-log's `.claude/` (which had only hooks, no skills).

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
