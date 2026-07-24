# Task 09 — Build a task-free ai-builder, then generate into it (later)

**Goal:** re-home ai-builder's task subsystem onto the generator — build a
**task-free** variant of ai-builder (the hand-built `project/tasks/` subsystem
removed) and regenerate it from `create-task-system`. This closes the loop: the
generator reproduces the very subsystem it was extracted from.

**Do not start until task 08 (captains-log) succeeds.**

## Terminology (read first — these are three different things)

- **Task subsystem** — the whole markdown task tracker.
- **Machinery** — the *replaceable* parts: `scripts/`, templates, `classes.md`,
  `README.md`. This is what the generator emits.
- **Task content** — the *irreplaceable* parts: the actual task directories
  ai-builder has accumulated (dozens of real tasks under each epic, with their
  `README.md`, `task.json`, `X-` completion prefixes, `Next-subtask-id`
  counters, `Category` values). This must be **migrated, never regenerated**.

"Task-free ai-builder" means **machinery removed, content preserved** — not a
repo with no tasks. It is a swap of the engine while keeping the cargo.

## Part A — Prepare the task-free ai-builder (machinery out, content kept)

- [ ] Create the task-free ai-builder variant (new branch/worktree or repo).
- [ ] Set aside the **task content** (all task directories under every epic +
      the `projects/` tree) — do not delete.
- [ ] Remove only the **human-core machinery** the generator will replace: the
      core scripts, templates, `classes.md`, `project/tasks/README.md`.
- [ ] **Keep the pipeline scripts** (`new-pipeline-*`, `set-current-job`,
      `advance-pipeline`, `check-stop-after`, `on-task-complete`) — under the
      decided option (b) these stay hand-maintained (see pipeline note).
- [ ] Update ai-builder's `CLAUDE.md` / `bootstrap` references pointing at the
      old core `project/tasks/scripts/` paths.

## Part B — Generate machinery + reattach content

- [ ] Run `generate.sh` against the task-free ai-builder with mount
      `project/tasks` and the layers ai-builder uses
      (`--with-classes --with-projects --with-worktree-guard`, **no
      `--with-pipeline`** — option b).
- [ ] Reattach the preserved task content under the generated epic status folders.

## Task-content migration — first-order concern

The generator emits the **same on-disk task format** (only script *path
resolution* was refactored, not the format), so existing task dirs should drop in
unchanged. **Verify that invariant explicitly:**

- [ ] Confirm the generated scripts read the existing dirs as-is: metadata table
      fields, `X-` prefix, `Next-subtask-id`, subtask `NNNN` ordering.
- [ ] Confirm `task.json` schema (pipeline subtasks) matches — or migrate if the
      generator changed anything.
- [ ] Confirm existing `Category` values still validate against the **emitted**
      `classes.md` (ai-builder's 8 classes must be re-seeded into it, since the
      generator ships only a starter `classes.md`).
- [ ] Rebuild each status folder's `README.md` task list to match the reattached
      content (`list-tasks.sh` should render the full tree with no orphans).
- [ ] Spot-check completed (`X-`) and `wont-do` tasks survive the round-trip.

## Pipeline layer — what "iff it exists" means

The generator's `--with-pipeline` is **deferred/unbuilt**. Until it exists, the
generated machinery covers the human core + classes/projects/guard, but **not**
the orchestrator-coupled pipeline scripts (`new-pipeline-*`, `set-current-job`,
`advance-pipeline`, `task.json` execution log).

**DECIDED: option (b) — ship pipeline-free.** The generator manages ai-builder's
*human-core* task machinery; ai-builder's existing pipeline scripts stay in place,
hand-maintained, outside the generator. ai-builder keeps working throughout; only
the pipeline scripts are not generator-owned yet. Revisit building
`--with-pipeline` (option a) later if we want the orchestrator layer generated
too — not a blocker for closing the loop.

Concretely, for this task under (b):
- [ ] Do **not** remove ai-builder's pipeline scripts in Part A — they are not
      machinery the generator replaces; leave them untouched.
- [ ] Run `generate.sh` **without** `--with-pipeline`.
- [ ] Ensure the generated human-core scripts and the retained hand-maintained
      pipeline scripts coexist in the same `project/tasks/` mount without path or
      naming collisions.

## Part C — Verify parity, under BOTH git layouts

The current ai-builder is a **git worktree** (`.bare` + linked `main/`). The
generated subsystem must work there **and** in a plain single-workspace repo.

- [ ] **Git-worktree layout:** generate into the worktree's working root
      (`main/`) at mount `project/tasks`; verify `git rev-parse --show-toplevel`
      resolves to `main/` (not `.bare`) and all scripts run from `main/`.
- [ ] **Single git workspace:** generate into a plain (non-worktree) clone of
      ai-builder at the same mount; verify identical behavior.
- [ ] Diff the generated scripts/templates against the original hand-built ones;
      explain every intended difference (config indirection, git-root resolution).
- [ ] Run ai-builder's existing task/bats tests against the generated subsystem
      in both layouts.
- [ ] Confirm the orchestrator still consumes tasks via the retained
      hand-maintained pipeline scripts (option b).

## Not blocked

Under the decided option (b), task 09 is **not** blocked on `--with-pipeline`.
Building that layer is a possible future task, not a prerequisite here.

## Done when

Task-free ai-builder runs its **human-core** task machinery entirely from
generator-produced scripts (with the retained pipeline scripts still hand-owned),
parity to the original verified by tests and diff review.

Ref: `docs/extraction-analysis.md` §3.5 (pipeline seam), §4 (scope), §7.
