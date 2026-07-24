# Task 09 — Task-free `create-ai-builder`, then generate into it

**Goal:** re-home the task subsystem of the repo formerly known as ai-builder
onto the generator — strip its hand-built `project/tasks/` machinery (content
kept) and regenerate it from `create-project-system`. Closes the loop: the
generator reproduces the very subsystem it was extracted from.

## Progress (2026-07-24)

- [x] **Renamed `ai-builder` → `create-ai-builder`** (it's a *generator* — installs
      an agent build pipeline into a target repo — so it joins the `create-*`
      family). Done in place on the existing `.bare`+worktree container:
      `mv`, then fixed the two absolute gitdir pointers (`main/.git`,
      `.bare/worktrees/main/gitdir`); GitHub repo renamed; origin remote updated;
      `git worktree list` + fetch verified.
- [x] **project-status updated for the rename** — `repos.yml` entry + the daily
      routine's `sources` both `ai-builder` → `create-ai-builder`
      (`enabled: false` preserved). Committed `88db225`.
- [ ] Remaining: surgical machinery strip → regenerate → verify (Parts A–C).

**Approach: transform `create-ai-builder/main` in place** (it's the working
worktree). Work on a branch if you want a reviewable diff before merging to main.

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

## Part A — Strip the machinery in place (content + pipeline kept)

**Exact file classification** (from `create-ai-builder/main/project/tasks/scripts/`,
inventoried 2026-07-24). `project/tasks/scripts/` intermingles three kinds:

**REMOVE — core task machinery** (the generator re-emits these, decoupled):
`complete-subtask.sh` `complete-task.sh` `delete-task.sh` `insert-subtask.sh`
`is-last-task.sh` `is-top-level.sh` `list-tasks.sh` `list-tasks.md` `move-task.sh`
`new-epic.sh` `new-user-subtask.sh` `new-user-task.sh` `next-subtask.sh`
`rename-subtask.sh` `reorder-subtasks.py` `restore-task.sh` `show-task.sh`
`subtasks-complete.sh` `task-id-helpers.sh` `task-json-helpers.sh`
`user-subtask-template.md` `user-task-template.md` `wont-do-subtask.sh`
— plus `list-projects.sh` `new-project.sh` (re-emitted by `--with-projects`).
Also remove machinery docs / `project/tasks/README.md` / `project/README.md`
(regenerated). **Note:** ai-builder has **no** `task-env.sh`/`task-config.sh` —
it's the pre-refactor ancestor; regeneration introduces them.

**⚠️ KEEP — pipeline machinery** (hand-maintained per option b, NOT generated):
`advance-pipeline.sh` `check-stop-after.sh` `new-pipeline-build.sh`
`new-pipeline-subtask.sh` `on-task-complete.sh` `set-current-job.sh`
`pipeline-build-template.md`

**KEEP — content** (irreplaceable): every task dir under `project/tasks/main/`
(and any other epics), `project/tasks/classes.md` (8 real classes),
`project/status/*.md` + `project/reviews/*.md` (dated artifacts),
`project/projects/` if present.

- [ ] Show the exact `git rm` list (core machinery only) for review BEFORE deleting
      — the pipeline files live in the same dir, so a wildcard would be wrong.
- [ ] Remove the core-machinery files listed above; leave the 7 pipeline files.
- [ ] Update `CLAUDE.md` / `bootstrap` references that point at old core paths
      (esp. anything assuming the pre-refactor `../../..` root or hardcoded literals).

## Part B — Generate machinery + reattach content

- [ ] Run `generate.sh` against `create-ai-builder/main`, mount `project/tasks`,
      with the layers it uses — likely **all** of them since it's the origin repo:
      `--with-classes --with-projects --with-status --with-worktree-guard
      --with-skill`, **no `--with-pipeline`** (option b). Confirm `--with-projects`
      is wanted (does `project/projects/` exist?) during execution.
- [ ] Content is preserved in place (the generator is non-destructive: it
      overwrites machinery, never the existing epic/classes/status content), so
      "reattach" = verify the generated scripts read the untouched content.

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
