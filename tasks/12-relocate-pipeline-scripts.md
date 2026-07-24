# Task 12 — Relocate create-ai-builder's pipeline scripts out of the generated mount

> **OWNERSHIP: this is create-ai-builder-domain work (Pipeline Abstraction
> Layer), not generator-build work.** It lives here only as a placeholder. Once
> task 09 Part B regenerates create-ai-builder's task tracker, **re-home this as a
> real task inside create-ai-builder** (created via its own `new-user-task.sh` —
> dogfoods the fresh install) and delete it from this repo's plan, leaving a
> cross-reference in task 09.

**Deferred: do NOT start until task 09 is proven** (task-free create-ai-builder
regenerated and verified). Sequencing matters — relocating during the strip/regen
would entangle two independent changes.

## Problem

After task 09, `create-ai-builder/project/tasks/scripts/` will hold **two owners'**
scripts side by side:
- generator-owned core task machinery (overwritten on every regen), and
- create-ai-builder's hand-maintained **pipeline** scripts (`advance-pipeline.sh`,
  `check-stop-after.sh`, `new-pipeline-build.sh`, `new-pipeline-subtask.sh`,
  `on-task-complete.sh`, `set-current-job.sh`, `pipeline-build-template.md`).

Cohabitation is fragile: a reader can't tell which files are safe to edit, and a
future `--force` regen or a generator that adds a same-named script could clash.

## Goal

Relocate the 7 pipeline files to a **dedicated, non-generated location** (e.g.
`project/pipeline/scripts/` or `ai-builder/orchestrator/scripts/` — pick during
execution), so `project/tasks/scripts/` is 100% generator-owned and the pipeline
scripts have a clear, hand-maintained home.

## Steps (sketch)

- [ ] Choose the new home; confirm it's outside any generator mount.
- [ ] `git mv` the 7 pipeline files there.
- [ ] Update every caller (orchestrator, bootstrap, CLAUDE.md, task READMEs) that
      references the old `project/tasks/scripts/<pipeline>.sh` paths.
- [ ] Re-run create-ai-builder's tests; confirm the pipeline still drives tasks.
- [ ] Re-run `generate.sh` and confirm a zero-diff regen (no pipeline files in the
      generated mount to be touched).

## Done when

`project/tasks/scripts/` contains only generator-emitted files, the pipeline
scripts live in their own hand-maintained dir, and both regen and the pipeline
still work.
