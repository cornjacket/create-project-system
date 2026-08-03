# Task 24 — Fix pipeline-layer leakage in generated + composition docs

**Type: doc fix.** Two documentation defects, both surfaced from
create-ai-builder while working `15d940-target-setup-uses-generator-for-tasks`
(the target-setup-uses-generator refactor). Neither is a runtime bug; both
mis-describe the layer-1 / layer-2 boundary this generator is supposed to keep
clean.

## Why

The generator emits **layer 1** (the task subsystem). The **pipeline layer**
(orchestrator, roles, machines, and the `*-pipeline-*` / job scripts) is
create-ai-builder's, laid on top as **layer 2**. Two docs blur that line — one
overstates what layer 2 contains, the other ships layer-2 script references
inside layer-1's own generated README, so a plain create-project-system
consumer (no pipeline overlay) reads docs for scripts they were never given.

## The two issues

### 1. `docs/composition-with-create-ai-builder.md` overstates layer 2

The "Pipeline overlay" row (line ~16) lists the 7 pipeline scripts **plus
`orchestrator/roles/machines`**. Layer 2 as *installed on top of a target repo*
is the **7 scripts** — the orchestrator/roles/machines are create-ai-builder's
build-time machinery, not part of the overlay dropped into a target. Trim the
row to the 7 scripts (or split "installed overlay" from "create-ai-builder's own
build machinery" so the table doesn't imply the latter is copied into targets).

**Evidence (from create-ai-builder):** the orchestrator holds
`orchestrator/roles/machines` in *its own* repo and only ever reaches into the
target's **scripts** dir — `orchestrator.py:182` sets
`PM_SCRIPTS_DIR = TARGET_REPO/project/tasks/scripts`, and the handlers shell out
to it (`decompose.py` → `new-pipeline-subtask.sh`, `set-current-job.sh`;
`lch.py` → `on-task-complete.sh`). Nothing reads an engine, machine, or role
file from *inside* a target. So what actually lands in a target is scripts, not
machinery.

### 2. Generated `src/docs/README.md` documents scripts `generate.sh` never installs

`src/docs/README.md` (the README template the generator emits) references
pipeline-only scripts that are **not** in `src/scripts/` — grep-confirmed
`2026-07-28`:

- `new-pipeline-subtask.sh` — lines ~43, ~83, ~114, ~128, ~242
- `set-current-job.sh` — line ~309

`src/scripts/` ships only the user-task layer (no `new-pipeline-*`,
`set-current-job`, `advance-pipeline`, etc.). Harmless for **create-ai-builder**
because it overlays those scripts, but a plain create-project-system consumer
gets docs for commands they don't have. Gate/remove the pipeline sections from
the generated README so it documents only what `generate.sh` actually installs
(e.g. behind the same seam that defers the pipeline layer, or strip them
outright and let the pipeline overlay own its own docs).

> **Note on script names:** the reporting detail cited `new-pipeline-build.sh`
> and `set-current-job.sh`. A grep of `src/docs/README.md` on `2026-07-28` finds
> `set-current-job.sh` (line 309) and `new-pipeline-subtask.sh` (5 places) but
> **not** `new-pipeline-build.sh`. Whoever fixes this should sweep the emitted
> README for *all* uninstalled `*-pipeline-*` / job-script references, not just
> the two names above — the exact set may drift.

## What to do

- [ ] Trim the layer-2 row in `docs/composition-with-create-ai-builder.md` to
      the installed overlay (7 scripts), separating it from create-ai-builder's
      build machinery.
- [ ] Remove or conditionally-gate the `new-pipeline-subtask.sh` /
      `set-current-job.sh` references in `src/docs/README.md` so the emitted
      README matches the scripts `generate.sh` installs.
- [ ] Regenerate the self-test sandbox and confirm the emitted README no longer
      names uninstalled scripts.

## Done when

The composition doc's overlay row lists only what is installed on a target, and
a freshly generated target's README documents no script absent from
`src/scripts/`.
