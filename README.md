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
