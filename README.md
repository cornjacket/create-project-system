# create-project-system

[![self-test](https://github.com/cornjacket/create-project-system/actions/workflows/self-test.yml/badge.svg)](https://github.com/cornjacket/create-project-system/actions/workflows/self-test.yml)

A **generator** that installs a filesystem-native, Markdown-based task subsystem
into any target repo, at a caller-chosen directory. Extracted from the
[ai-builder](../ai-builder) project's hand-built task tracker.

Each task is a directory containing a `README.md`; tasks are managed entirely
through shell/Python scripts, organized by epic and status folder
(`inbox / draft / backlog / in-progress / complete / wont-do`), with three task
types (USER-TASK, USER-SUBTASK, PIPELINE-SUBTASK).

## What it emits

Into `<target-repo>/<tasks-dir>/`: the management scripts, task templates, status
scaffolding, a starter epic, an on-demand **task-system skill** + portable
`USING.md`, and a small always-on CLAUDE.md kernel. Optional layers behind flags:
`--with-worktrees` (parallel-work isolation), `--with-projects` (long-running
services), `--with-worktree-guard`, `--with-skill`. The pipeline/orchestrator
layer is deferred.

```sh
generate.sh --target-repo <path> --tasks-dir tasks --epic main [--with-...]
```

## What it declares — `discovery.json`

An install also writes its keys into **`discovery.json`** at the target repo
root: one file, one fixed name, listing what this repo offers to the outside.
A consumer reads it instead of probing directories to work out what is installed
and where.

This generator owns **two keys** and never touches the rest of the file:

```json
{
  "tasks": { "version": 1, "mount": "project/tasks", "epic": "main" },
  "inbox": { "version": 1, "path": "project/tasks/main/inbox", "format": "user-task" }
}
```

- **`tasks`** — where the task-system is mounted, so a consumer stops guessing
  between `project/tasks` and `tasks`.
- **`inbox`** — where another repo files a message for this one. A repo with no
  task-system can write this key by hand and still receive mail.

Other generators write their own keys into the same file — `create-context-hygiene`
owns `context-hygiene`. The rules: **a generator owns its keys and never rewrites
another's**, and the version is **per key**, since different generators write at
different times. See [`tasks/28`](tasks/28-declare-mount-in-root-manifest.md).

## Status

Design + plan stage. See:
- [`PLAN.md`](PLAN.md) — the build plan and ordered task list.
- [`docs/extraction-analysis.md`](docs/extraction-analysis.md) — component
  inventory, coupling analysis, decided scope, and the generator contract.
- [`tasks/`](tasks/) — the individual build work-items.

## Related

- [`create-context-hygiene`](../create-context-hygiene) — an orthogonal peer
  generator (keeps agent-facing instruction files lean and well-placed). Shares
  this repo's generator substrate by copy; composes with it at a target repo.
