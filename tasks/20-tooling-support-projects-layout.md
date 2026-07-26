# Task 20 — Task tooling for the `project/projects/` layout (single vs config-driven)

**Type: discuss then resolve.** Decide the approach before implementing.

## The gap (surfaced while listing tasks)

The rich task view — `list-tasks.sh` with `--group-by-category --sort-priority
--depth`, plus `show-task`/`move-task`/`complete-task` etc. — is anchored to
`TASKS_ROOT` (= `project/tasks/`). Its `--root` resolves *under* `project/tasks/`
(`ROOT_DIR="$TASKS_ROOT/$ROOT"`), so it **cannot** traverse into
`project/projects/<name>/` task trees. Today the only view of `project/projects/`
is `list-projects.sh`, a shallow **project → build-N + status** summary — no
grouped/priority/depth task listing inside a project.

## Operator constraint (the framing)

**A repo uses EITHER `project/tasks/` OR `project/projects/`, not both** — it
picks one organizing model:
- **tasks mode:** one tracker, epic-based (`project/tasks/<epic>/<status>/…`).
- **projects mode:** many long-running projects, each its own tree
  (`project/projects/<name>/<epic>/<status>/…`).

Because a repo is single-mode, we don't need scripts that handle both *at once* in
one repo — we need scripts that can be **configured** for whichever mode the repo
chose. That yields two implementation options.

## The decision

- [ ] **Option A — two copies of the scripts** (one set anchored at
      `project/tasks/`, one at `project/projects/<name>/`). Simple per-copy, but
      duplicated logic → drift risk; the generator would emit one set or the other.
- [ ] **Option B (preferred) — one config-driven copy.** Add a **mode** to the
      generated `task-config.sh` (e.g. `LAYOUT=tasks|projects`) that sets the
      traversal root(s); the same `list-tasks.sh` / `move-task.sh` / etc. operate
      against whichever layout. The scripts are *already* config-driven via
      `task-env.sh` / `task-config.sh` (`TASKS_REL` / `PROJECTS_REL`), so this is a
      natural extension, not a rewrite.

Lean: **Option B** — keep one source of truth, no duplicated scripts to drift.

## To resolve

- [ ] Confirm the single-mode constraint holds for all consumers (create-ai-builder
      is tasks mode today; is any repo actually projects mode yet?).
- [ ] If B: what does "projects mode" mean for each script? e.g. `list-tasks.sh`
      iterates `project/projects/*/<epic>/…`; `new-user-task.sh` needs a
      `--project` selector; `classes.md` / status folders live per-project.
- [ ] How the generator selects the mode (`generate.sh` flag → `LAYOUT` in
      `task-config.sh`). Interacts with the existing `--with-projects` layer
      (`new-project.sh` / `list-projects.sh`).
- [ ] Golden + self-test coverage for the chosen mode.

## Done when

A decision is recorded, and — if implemented — the full task view works in
`project/projects/` mode via the chosen approach (one config-driven copy, ideally),
with tests.
