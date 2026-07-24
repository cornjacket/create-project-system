# Task 10 — Status-report layer + `project/` workspace (option B)  ✅ DONE

> **Result:** the generator now reproduces the wider **project management
> workspace**, not just the `tasks/` pillar. Added `--with-status`, which emits
> a `status/` sibling of the tasks mount plus a container `README.md` describing
> the `project/` workspace. Repo renamed `create-task-system` →
> `create-project-system` to match the wider scope. Self-test: **61 assertions
> green**; three golden fixtures (`core`, `all-layers`, `project`).

## Why

ai-builder's `project/` is a PM workspace with four pillars —
`tasks/` + `status/` + `reviews/` + `scripts/` — not just tasks. The generator
originally extracted only `tasks/`. Decision (with operator): reproduce the
workspace, but only the **built** pillars.

- **`tasks/`** — the core (already extracted).
- **`status/`** — NEW layer. Periodic delta status reports; a convention + an
  agent workflow, **no scripts**.
- **`reviews/`** — **excluded.** Never fully designed upstream (its README says
  "artifact format not yet finalised"; log is empty). Nothing reusable to emit.
- **`scripts/` (project-level)** — **excluded.** Empty upstream (its one script,
  `log-add.sh`, was retired). Nothing to copy.

## What was built

- [x] `--with-status` flag in `generate.sh`.
- [x] Sibling derivation `STATUS_REL` (mirrors `PROJECTS_REL`):
      `tasks → status`, `project/tasks → project/status`. New generator-time
      placeholders `{{STATUS_REL}}`, `{{CONTAINER_REL}}`, `{{TASKS_BASE}}`.
- [x] `src/layers/status/README.md` — thin log-table stub (CONTENT, seeded).
- [x] `src/layers/status/container-README.md` — `project/` workspace overview
      (CONTENT, seeded). Emitted **only** when the mount sits in a container dir
      (never at repo root — that would clobber the target's own `README.md`).
- [x] Authoritative "write a status report" workflow → `docs/USING.md`
      (machinery, single-source), pointer added to the skill.
- [x] `src/layers/README.md` documents the layer + the exclusions.

## Rename

- [x] GitHub repo renamed (redirects preserved); origin remote updated.
- [x] Local dir + all in-repo references swept; goldens regenerated.
- [ ] Update the 3 second-brain notes that reference the old name
      (`cookiecutter-pattern`, `agent-instruction-placement`,
      `orthogonal-features-not-nesting`). *Low priority — separate repo.*

## Canonical layout going forward

```
generate.sh --target-repo <repo> --tasks-dir project/tasks --epic main --with-status [--with-skill]
```
→ grows a `project/` workspace with `tasks/` + `status/` siblings. This is the
recommended mount for tasks 07–09.

## Done when

Generator emits tasks + status under a `project/` container; self-test + golden
cover both the container layout and the bare-root fallback. ✅
