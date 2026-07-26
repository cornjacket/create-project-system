# Task 18 — Discuss & resolve: `complete-task.sh` requiring `--parent`

**Type: discuss then resolve.** Not a foregone implementation — decide the
approach first.

## The issue

Completing a **subtask** requires `--parent`:
```
complete-task.sh --folder <status> --parent <task> --name <subtask>
```
The script uses `--parent` to build the parent path and then mutate the parent
(`[ ] → [x]` in the parent README for user subtasks; the subtask entry in the
parent `task.json` for pipeline subtasks) — so the parent is intrinsic to the
operation, not just a locator. But the caller having to *know and pass* the
parent is friction, and it's arguably derivable.

## Two ways the parent is already knowable

1. **From the subtask id.** Subtasks are named `{parent-short-id}-{NNNN}-{name}`,
   so the parent's short-id is embedded in `--name`. The script could extract it
   and search `<folder>/` for the matching parent dir.
   - Caveats: needs 0/>1-match handling; the current model assumes one level
     (`<folder>/<parent>/<name>`) — deeper nesting breaks a single derived id.

2. **From the task itself (operator's point).** The parent can be recorded **in
   the subtask's own metadata** (a `Parent:` field in its README, and/or in
   `task.json`) at creation time by `new-user-subtask.sh` /
   `new-pipeline-subtask.sh`. Completion then **reads the parent back from the
   subtask** instead of requiring it on the CLI. This is more robust than a prefix
   search — no ambiguity, and it carries the *full* parent path, so it handles
   nesting. (Check whether `task.json` already stores enough to reconstruct this.)

## To decide

- [ ] Prefer approach 2 (record parent in metadata, read it back), approach 1
      (infer from id + search), keep `--parent` required, or make it **optional**
      (explicit still works; inferred when omitted)?
- [ ] If approach 2: which store — README `Parent:` field, `task.json`, or both?
      Confirm `new-*-subtask.sh` write it and that existing tasks (e.g.
      create-ai-builder's 134) either already have it or degrade gracefully.
- [ ] Keep the explicit `--parent` as an override/guardrail regardless.
- [ ] Scope: does this generalize to other subtask ops that take `--parent`
      (`new-user-subtask`, `move-task`, `rename-subtask`) for consistency?

## Done when

A decision is recorded with rationale, and — if we implement — `complete-task.sh`
resolves the parent without requiring it for the common case, with tests and the
explicit form still working.
