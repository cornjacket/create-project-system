# Task 04 — Build `generate.sh`  ✅ DONE

> **Result:** `generate.sh` at the repo root. 40-assertion suite green: core-only,
> all-layers at a nested mount with custom epic, regeneration safety, and CLAUDE.md
> injection.
>
> **Collision policy decided (feeds task 05):** machinery (scripts, templates,
> docs, config, skill) is ALWAYS overwritten; content (epic/status folders, their
> task lists, `classes.md`) is created ONLY IF MISSING and never overwritten.
> Regeneration is therefore safe by default — an identical re-run produces a
> zero-line git diff. `--force` only re-seeds content.

**Goal:** the emitter that materializes `src/` into a target repo at a chosen
mount path, per the analysis §5 contract.

## Contract

```sh
generate.sh \
    --target-repo <path>        # required
    --tasks-dir   <rel-path>    # default "tasks"
    --epic        <name>        # default "main"
    [--with-classes]
    [--with-projects]
    [--with-worktree-guard]
    [--with-skill]              # emit .claude/skills/task-system/ (task 03b)
    [--inject-claude-md]        # else just print the kernel snippet
    [--force]                   # overwrite existing mount dir
```

## Steps

- [x] Parse flags; validate `--target-repo` exists. (Non-git targets warn rather
      than fail — the root resolver has a walk-up fallback.)
- [x] ~~Refuse to clobber a non-empty `<target-repo>/<tasks-dir>` unless `--force`.~~
      **Deliberately not implemented as specified.** Refusing would make the
      normal upgrade path (task 05) require `--force`, training users to pass the
      dangerous flag routinely. Replaced with the machinery/content split above:
      regeneration is safe by default and needs no flag, so `--force` stays rare
      and meaningful.
- [x] Copy `src/scripts/` (+ selected optional scripts) → `<tasks-dir>/scripts/`.
- [x] Render `task-config.sh` from `task-config.sh.in` with `TASKS_REL` =
      `<tasks-dir>` and `DEFAULT_EPIC` = `<epic>`.
- [x] Copy templates + docs (classes/projects/guard files only if flagged).
      Always emit `docs/USING.md` (the portable source-of-truth how-to).
- [x] With `--with-skill`: emit `.claude/skills/task-system/SKILL.md` (points at
      `<tasks>/docs/USING.md`). Without it, USING.md alone is the reference.
- [x] Scaffold the starter epic: create `inbox draft backlog in-progress complete
      wont-do`, each with a seeded `README.md` (empty task list).
- [x] Print (or with `--inject-claude-md`, append) the CLAUDE.md **kernel**
      snippet (~15 lines: always-fire rules + pointer to skill/USING.md).
- [x] Print a post-install summary: files created + next commands.

## Done when

`generate.sh --target-repo <scratch> --tasks-dir tasks` produces a working task
subsystem whose scripts run correctly from the target repo root.

Ref: `docs/extraction-analysis.md` §5.
