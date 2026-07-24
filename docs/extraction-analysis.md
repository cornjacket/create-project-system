# Extraction Analysis — ai-builder Task Subsystem → `create-task-system`

**Goal:** turn ai-builder's in-repo task subsystem into a reusable **generator**.
`create-task-system` should materialize the entire task subsystem into *any*
target repo, at a caller-chosen directory (the "mount path"), with the
ai-builder-specific bits made optional.

**Bottom line:** the subsystem is ~90% repo-agnostic already. Almost all of its
coupling to ai-builder collapses to **two mechanical points** (a hardcoded
`project/tasks` path literal and a fixed `../../..` depth assumption) plus **two
optional layers** (the pipeline/orchestrator integration and the `classes.md`
worktree-category system). Fix the two mechanical points once and the rest
extracts cleanly.

Source analyzed: `ai-builder/main/project/tasks/` and `ai-builder/main/ai-builder/docs/task-manager.md`.

---

## 1. What the subsystem is (recap)

Filesystem-native, Markdown-based task tracker where **every task is a directory
containing a `README.md`**, mutated only through shell/Python scripts. Three task
types (USER-TASK, USER-SUBTASK, PIPELINE-SUBTASK), six status folders
(`inbox/ draft/ backlog/ in-progress/ complete/ wont-do/`) per epic, subtask
ordering via a zero-padded `NNNN` counter, completion signalled by an `X-`
directory-name prefix, and priority tracked by list order in each status
folder's `README.md`.

---

## 2. Component inventory & classification

Each component is tagged for extraction:

- **CORE** — repo-agnostic; extract as-is once paths are parameterized.
- **CONFIG** — must be parameterized by the generator.
- **OPT-PIPELINE** — only meaningful with the ai-builder orchestrator; emit behind a flag.
- **OPT-CLASSES** — the worktree-category system; emit behind a flag.
- **AB-ONLY** — ai-builder-specific; do **not** extract (reference only).

### Scripts (`project/tasks/scripts/`)

| File | Class | Notes |
|---|---|---|
| `task-id-helpers.sh` | CORE | Shared lib. Already cross-platform (`_sed_i` handles BSD/GNU sed). ID parsing, `Next-subtask-id` increment, `X-` resolution. |
| `task-json-helpers.sh` | CORE | Generic JSON field helpers; not pipeline-specific despite the name. |
| `new-user-task.sh` | CORE + OPT-CLASSES | Core creation logic, but `--category` is **required** and validated against `classes.md` at runtime. Make category optional when classes layer is off. |
| `new-user-subtask.sh` | CORE | |
| `new-epic.sh` | CORE | Scaffolds an epic with all status folders. |
| `move-task.sh` | CORE | Status-folder transitions. |
| `complete-task.sh` / `complete-subtask.sh` | CORE | `X-` rename + checkbox/Status sync. |
| `delete-task.sh` / `restore-task.sh` | CORE | Soft-delete (dot-prefix) + restore. |
| `show-task.sh` | CORE | |
| `list-tasks.sh` | CORE (+ minor OPT) | Tree view, filters. Has `--category`/`--group-by-category` flags that no-op without the classes layer. |
| `next-subtask.sh` | CORE | Next incomplete subtask path. |
| `insert-subtask.sh` / `rename-subtask.sh` / `reorder-subtasks.py` | CORE | `NNNN` ordering manipulation. |
| `wont-do-subtask.sh` / `subtasks-complete.sh` / `is-last-task.sh` / `is-top-level.sh` | CORE | |
| `new-project.sh` / `list-projects.sh` | CONFIG | The `project/projects/` "long-running service" variant. Extract, but its mount path is a second parameter. |
| `new-pipeline-subtask.sh` / `new-pipeline-build.sh` | OPT-PIPELINE | Creates PIPELINE-SUBTASK nodes / `build-N` entry points. |
| `set-current-job.sh` | OPT-PIPELINE | Writes `current-job.txt` for the orchestrator. |
| `advance-pipeline.sh` / `check-stop-after.sh` / `on-task-complete.sh` | OPT-PIPELINE | Pipeline run coordination. |

### Templates

| File | Class |
|---|---|
| `user-task-template.md` | CORE |
| `user-subtask-template.md` | CORE |
| `pipeline-build-template.md` | OPT-PIPELINE |

### Docs & conventions

| File | Class | Notes |
|---|---|---|
| `project/tasks/README.md` | CORE | Structure/usage doc. Contains `project/tasks` literals to rewrite. |
| `project/tasks/classes.md` | OPT-CLASSES | Worktree-class definitions; ai-builder's 8 classes are examples, not content to ship. Emit an **empty/starter** version behind the flag. |
| `ai-builder/docs/task-manager.md` | OPT (Oracle guide) | Judgment rules (sizing, TESTER-failure table). Generic enough to offer as an optional starter doc. |
| Status-folder `README.md` (×6 per epic) | CONFIG | Generated scaffolding, not copied. |
| `bootstrap/check-task-complete.py` | AB-ONLY / OPT | Worktree-removal guard. Reusable, but tied to ai-builder's git-worktree flow. Offer as opt-in. |
| `CLAUDE.md` task-management section | CONFIG | Ship as an injectable **snippet**, not the whole file. |
| `lessons/*.md` (009, 016, 003, 004, 014, …) | AB-ONLY | Rationale/history. Reference only; do not extract. |

---

## 3. Coupling points the generator MUST solve

### 3.1 The `project/tasks` path literal (61 occurrences) — **primary blocker**

The mount path `project/tasks` is hardcoded literally across the scripts, in two
roles: path construction (`"$REPO_ROOT/project/tasks/$EPIC/..."`) and error
messages. The target repo may want the subsystem at `tasks/`, `.tasks/`,
`pm/tasks/`, etc.

**Fix (recommended): collapse 61 coupling points to 1.** Introduce a single
generated config file, e.g. `task-config.sh`, that every script sources:

```sh
# task-config.sh (generated)
TASKS_REL="tasks"          # mount path relative to repo root (caller-chosen)
DEFAULT_EPIC="main"
```

Scripts reference `"$REPO_ROOT/$TASKS_REL/$EPIC/..."` instead of the literal.
This is a small refactor done **once during extraction**, and it makes the
generator's job a search-and-emit of one value rather than a 61-site rewrite.

### 3.2 The `$SCRIPTS_DIR/../../..` repo-root assumption — **second blocker**

Every script computes:

```sh
REPO_ROOT="$(cd "$SCRIPTS_DIR/../../.." && pwd)"
```

This hard-codes that scripts live exactly **three levels** below repo root
(`<root>/project/tasks/scripts/`). If the caller mounts at `tasks/`, scripts sit
at `<root>/tasks/scripts/` — two levels — and every path silently resolves wrong.

**Fix (recommended): make root resolution mount-depth-independent.** Replace the
`../../..` walk with `git rev-parse --show-toplevel` (with a non-git fallback
that walks up until it finds the tasks dir or a `.git`). Then the subsystem works
at any mount depth with no generator arithmetic. If a git dependency is
undesirable, the generator can instead compute and emit the correct `../..`
count into `task-config.sh`.

**Worktree caveat — must be handled and tested.** The current ai-builder repo is
organized as a **git worktree** (`.bare` bare repo + a linked `main/` working
tree; task scripts live at `main/project/tasks/scripts/`). Two consequences for
`resolve_repo_root`:

- `git rev-parse --show-toplevel` must return the **linked-worktree root**
  (`.../ai-builder/main`), *not* the `.bare` container. It does by default —
  which is exactly why git-toplevel beats the `../../..` walk here — but this
  must be verified, not assumed.
- The **walk-up fallback** must treat `.git` as a **file** (worktree marker),
  not only as a directory — in a linked worktree, `.git` is a text file
  containing `gitdir: …`, and a `[[ -d .git ]]` check would miss it.

Both the **worktree** layout and the **single git workspace** layout must be part
of the test matrix (see tasks 05 and 09).

### 3.3 The `classes.md` runtime coupling (category validation)

`new-user-task.sh` **requires** `--category` and validates it against the
worktree branches parsed from `classes.md`, aborting if the file is missing.
Without the classes layer, this is dead weight and a hard failure.

**Fix:** gate category on the classes flag. When classes are off, drop the
`--category` requirement and the `classes.md` read; when on, emit a starter
`classes.md` (empty table + instructions) so validation has something to read.

### 3.4 Default epic name `main`

Minor. Parameterize as `DEFAULT_EPIC` in `task-config.sh`; the generator seeds
one starter epic (default `main`).

### 3.5 Pipeline / orchestrator coupling

`new-pipeline-*`, `set-current-job.sh`, `advance-pipeline.sh`,
`check-stop-after.sh`, `on-task-complete.sh`, `pipeline-build-template.md`, and
the `task.json` `execution_log` all assume the ai-builder orchestrator
(`orchestrator.py`, `current-job.txt`, RUN_DIR, ARCHITECT→IMPLEMENTOR→TESTER
roles). This is a **clean seam**: the human task-management core has no
dependency on it. Emit the whole pipeline layer behind `--with-pipeline`.

---

## 4. The extraction, in tiers

**Decided scope (2026-07-22):** ship the human core plus the classes, projects,
and worktree-guard layers. **The pipeline/orchestrator layer is deferred** — it
is strictly not part of the task subsystem, and is kept as an isolated, addable
seam (see §3.5) in case that decision changes.

1. **Tier 1 — Human core (always).** All CORE scripts + templates + `README.md`
   + generated status scaffolding + one starter epic. A complete task tracker on
   its own.
2. **`--with-classes` (in scope).** Adds the `Category` field, a `classes.md`
   starter, and the category filters in `list-tasks.sh` / `new-user-task.sh`.
3. **`--with-projects` (in scope).** The `project/projects/` long-running service
   variant (`new-project.sh` / `list-projects.sh`).
4. **`--with-worktree-guard` (in scope).** `check-task-complete.py` — blocks
   worktree removal until a task's subtasks are done.
5. **`--with-pipeline` (deferred, keep the seam).** OPT-PIPELINE scripts,
   pipeline-build template, PIPELINE-SUBTASK support. Do not build now; keep the
   source isolated so it can be added later without disturbing the core.

---

## 5. Proposed generator architecture

```
create-task-system/
    generate.sh              # entry point: read flags, emit into target
    src/                     # source-of-truth copy of the subsystem
        scripts/             #   CORE + OPT scripts, refactored to source task-config.sh
        templates/           #   *-template.md
        docs/                #   README.md, task-manager.md, classes.md starter
        config/
            task-config.sh.in   # template with {{TASKS_REL}}, {{DEFAULT_EPIC}}
        snippets/
            claude-md.snippet.md # injectable CLAUDE.md rules block
    tasks/                   # build work-item files for this repo (see §7)
    docs/                    # this analysis + design docs
```

**`generate.sh` contract (proposed):**

```sh
generate.sh \
    --target-repo <path>        # repo to install into (required)
    --tasks-dir   <rel-path>    # mount path, default "tasks"
    --epic        <name>        # starter epic, default "main"
    [--with-classes]
    [--with-pipeline]
    [--with-projects]
    [--with-worktree-guard]
    [--force]                   # overwrite existing mount dir
```

**What it does:**
1. Refuse to clobber an existing non-empty `<target-repo>/<tasks-dir>` unless `--force`.
2. Copy `src/scripts/` + selected optional scripts into `<tasks-dir>/scripts/`.
3. Render `task-config.sh` from `.in` with the chosen `TASKS_REL` / `DEFAULT_EPIC`.
4. Copy templates + docs (classes.md/pipeline template only if flagged).
5. Scaffold the starter epic: create the six status folders, each with a seeded
   `README.md` (empty task list).
6. Print the CLAUDE.md snippet (or append with `--inject-claude-md`).
7. Emit a short post-install summary of what was created and next commands.

**Idempotency & testing:** generating into a scratch dir should be
byte-reproducible given the same flags — good fit for a golden-file test
(cf. the second-brain devkit/test split: the generator lives here, golden
outputs live in a test repo).

---

## 6. Design decisions (resolved 2026-07-22)

1. **Root resolution — DECIDED:** `git rev-parse --show-toplevel` for repo root,
   with a walk-up fallback for non-git checkouts. Mount path via a generated
   `task-config.sh`. Depth-independent; survives directory moves.
2. **Config indirection — DECIDED:** introduce `task-config.sh` sourced by every
   script (collapses the 61 path literals to one value). Not an emit-time sed
   rewrite.
3. **Pipeline layer — DECIDED:** deferred (see §4). Keep the source isolated as a
   clean seam; do not extract now.
4. **Scope layers — DECIDED:** classes, projects, worktree-guard are in scope;
   pipeline is out for now.
5. **CLAUDE.md — OPEN:** print snippet vs. auto-inject. *Recommend print +
   opt-in `--inject-claude-md`.*

---

## 7. Repo layout & directory roles (confirmed 2026-07-22)

`create-task-system` does **not** dogfood the task subsystem. Its own build is
planned with a plain `PLAN.md` + Markdown task files — deliberately lighter than
the subsystem it emits.

- `PLAN.md` (repo root) — the build plan; an ordered list linking to task files.
- `tasks/` — plain Markdown **work-item files** (one per build step). No status
  folders, no scripts, no installed subsystem.
- `docs/` — this analysis and design docs.
- `src/` (to be created) — the shippable **master copy** the generator emits.
- `generate.sh` (to be created) — the emitter (§5 contract).

### Generation targets

1. **`tasks-test/`** — a separate sibling repo; the **first** target for
   `generate.sh`. Proves the extraction end-to-end.
2. **`second-brain/`** — the eventual real target, generated once `tasks-test/`
   validates.

---

## 8. Recommended next steps

Tracked in `PLAN.md` → `tasks/`. In order:

1. **Scaffold `src/`** — the shippable layout (`scripts/`, `templates/`, `docs/`,
   `config/`, `snippets/`).
2. **Extract & refactor the core** into `src/` — `git rev-parse` root resolution
   + sourced `task-config.sh`, `project/tasks` literals stripped.
3. **Extract the in-scope optional layers** — classes, projects, worktree-guard
   (each flag-gated).
4. **Build `generate.sh`** per the §5 contract.
5. **Generate into `tasks-test/`** and validate end-to-end.
6. **Add a golden/reproducibility test**.
7. **(Later)** Generate into `second-brain/`.
