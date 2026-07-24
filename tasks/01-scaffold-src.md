# Task 01 — Scaffold `src/`  ✅ DONE

**Goal:** create the shippable master layout the generator will emit from.

## Steps

- [x] Create `src/` with subdirs: `scripts/`, `templates/`, `docs/`,
      `config/`, `snippets/`.  (empty dirs hold `.gitkeep`)
- [x] Add `src/config/task-config.sh.in` — the sourced-config template
      (`TASKS_REL`, `DEFAULT_EPIC` placeholders).
- [x] Add the root-resolution helper: `src/scripts/task-env.sh` (chose a
      dedicated env bootstrap over folding it into `task-id-helpers.sh`, so root
      + config live in one place every script sources). It:
      - sources `task-config.sh` (rendered beside the scripts) → `TASKS_REL`,
        `DEFAULT_EPIC`;
      - `resolve_repo_root()` via `git rev-parse --show-toplevel`, with a
        walk-up fallback that matches `.git` as a **file** (linked-worktree
        marker) or a dir;
      - exports `REPO_ROOT` and `TASKS_ROOT="$REPO_ROOT/$TASKS_REL"`.
- [x] **Worktree-aware — verified.** Smoke-tested (bash, invoked by path from
      repo root and from a deep unrelated cwd) across four layouts:
      single workspace (`tasks`), nested mount (`pm/tasks`), **git worktree**
      (resolves to the linked-worktree root, not `.bare`), and no-git fallback
      (finds root via the `.git` file). All pass, no `BASH_SOURCE` warnings.
- [x] Add `src/snippets/claude-md.snippet.md` — stub kernel (filled in task 03b).

## Done when

`src/` exists with the layout above and the config/env-bootstrap stubs in place.
✅ Met. Consumers wire in with:
```sh
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/task-env.sh"   # → REPO_ROOT, TASKS_REL, DEFAULT_EPIC, TASKS_ROOT
```

Ref: `docs/extraction-analysis.md` §5, §3.1, §3.2.
