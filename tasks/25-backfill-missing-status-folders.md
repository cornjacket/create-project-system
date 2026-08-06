# Task 25 — Backfill missing status folders when regenerating over an existing epic

**Type: bug fix.** Regeneration cannot add a status folder to an epic that
already exists, so any install that predates a vocabulary addition stays
permanently short a folder. Found 2026-08-06 while confirming whether the
generator emits an `inbox` at all — it does; `create-ai-builder`'s install
doesn't have one.

## The defect

`generate.sh:274` skips the epic **whole**:

```bash
if [[ -d "$MOUNT/$EPIC" ]]; then
    skipped+=("$TASKS_DIR/$EPIC/  (epic exists — task content preserved)")
else
    ( cd "$TARGET" && "$SCRIPTS_OUT/new-epic.sh" --name "$EPIC" >/dev/null )
    created+=("$TASKS_DIR/$EPIC/{inbox,draft,backlog,in-progress,complete,wont-do}/")
fi
```

The collision policy from task 04 is right — *content is created only if
missing, never overwritten* — but the **granularity is the epic, not the folder
inside it**. Once `<epic>/` exists, every status folder under it is invisible to
the generator forever. An empty status folder is not content: it holds no task,
so creating it destroys nothing.

## Evidence

Both repos run generated task-systems from this repo. Folder inventory, taken
2026-08-06:

| | inbox | draft | backlog | in-progress | complete | wont-do |
|---|---|---|---|---|---|---|
| `captains-log` | present (0 tasks) | 0 | 2 | 2 | 2 | 0 |
| `create-ai-builder` | **absent** | 20 | 46 | 6 | 56 | 5 |

`captains-log` was generated fresh (task 08) and got all six.
`create-ai-builder` was migrated onto the generator over its pre-existing
`main/` epic (task 09), so the skip branch fired and `inbox/` was never created.
Regenerating will never fix it. That divergence is what crashed the workspace's
`replan` probe, which assumed the folder vocabulary.

`inbox` is only the instance. The class of bug is *any* future addition to
`STATUS_DIRS` silently failing to reach every already-generated repo.

## Why `new-epic.sh` can't be reused as-is

`src/scripts/new-epic.sh` hard-errors when the epic exists
(`new-epic.sh:59-62`), and its loop **unconditionally overwrites** every status
`README.md` (`new-epic.sh:74-82`) — which would wipe the `task-list-start`
blocks holding real task ordering. Backfill needs a create-if-missing path, not
this one.

## Decisions to make

- **Where the loop lives.** Either a create-if-missing sweep inside
  `generate.sh`'s skip branch, or an idempotent mode on `new-epic.sh`
  (`--repair`) that generate.sh calls. The second keeps the vocabulary in one
  place (`STATUS_DIRS`) and gives consumers a manual repair command; the first
  is fewer moving parts. **Lean: `--repair`**, since `STATUS_DIRS` and
  `list-tasks.sh`'s `STATUSES` are already two copies of the vocabulary and a
  third in `generate.sh` makes it worse.
- **The epic-level README table.** A drifted epic's `README.md`
  (`new-epic.sh:86-99`) is missing its `inbox` row too, and that file *is*
  content — the generator never rewrites it. Options: leave it (a missing row is
  cosmetic), or insert the absent row without touching the rest. **Lean: leave
  it**, and say so in the report line, rather than start editing content files.
- **Reporting.** A backfill is neither "created" nor "skipped" in the current
  summary. It should be visible — a repo silently gaining a directory is how
  drift got missed in the first place.

## What to do

- [ ] Resolve the three decisions above.
- [ ] Add the create-if-missing backfill so regenerating over an existing epic
      creates any absent status folder (plus its seeded `README.md`), and leaves
      every existing folder and task list byte-identical.
- [ ] Report backfilled folders distinctly in `generate.sh`'s summary.
- [ ] Self-test coverage: generate, delete one status folder, regenerate —
      assert the folder is back, its README is the empty-list template, and the
      other five folders' task lists are unchanged. Also assert the zero-diff
      regeneration property from task 05 still holds when nothing is missing.
- [ ] Run the backfill against `create-ai-builder` to restore its `inbox/`
      (that repo owns the commit; this task owns the fix).

## Done when

Regenerating over an install missing a status folder creates it, an install
missing nothing still produces a zero-line git diff, and `create-ai-builder`'s
epic has all six folders.

## Related

- Task 26 (version stamping) — the other half of this problem. This task stops
  drift from *persisting*; 26 makes existing drift *diagnosable*.
- Task 05 established the zero-diff regeneration guarantee this must not break.
