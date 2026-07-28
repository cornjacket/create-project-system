# Task 19 — Discuss & resolve: rename `Category` to `Worktree`

**STATUS: DONE — resolved and shipped 2026-07-28.** Renamed to `Worktree`, full
convergence, with a permanent dual-read compatibility position. Breaking change
to the generator contract → belongs to **v0.2.0**; `v0.1.0` stays pinnable.

## The issue

The field was called **Category**, but it did not mean *category*. It names the
**worktree** a task belongs to: which files the task touches, so unrelated
groups can be worked in parallel branches without colliding. Valid values are
the **worktree branch names** declared in `classes.md` — the semantics are
entirely about parallel-work isolation, not about what a task is *about*.

The name mis-signalled that. "Category" is the obvious word for a topical
grouping, so an operator wanting to class a task as `video` or `education`
reached for `--category` first, found it validated against a `classes.md` of
branch names, and had to be told the real mechanism is **`Tags`**. Observed in
`captains-log` (2026-07-26) — the misreading was immediate and reasonable.

## Decision

**The root cause was that one concept carried three disagreeing names**: the
field was `Category`, the file was `classes.md`, and the values inside that file
were already labelled `**Worktree branch:**` — the only place the real meaning
appeared was a label the operator never sees. Converging all three on
**worktree** is the fix; renaming the field alone would have left the
inconsistency that produced the confusion.

### 1. The name: `Worktree`

`| Worktree | task-tooling |` now reads straight through to the
`**Worktree branch:** \`task-tooling\`` line that defines it — and that label
was *already* what both parsers keyed on, so this is the name the code was using
all along. Rejected: `Class` (matches only the filename, as vague as `Category`,
and collides with the OOP/CSS senses), `Branch` (over-claims — it is a class of
branch, not a branch), and docs-only (the mis-signal is in the name; prose next
to a wrong name loses).

### 2. Scope: full convergence

| | before | after |
|---|---|---|
| field | `Category` | `Worktree` |
| create flag | `--category` | `--worktree` |
| list flags | `--category`, `--group-by-category` | `--worktree`, `--group-by-worktree` |
| definitions file | `classes.md` | `worktrees.md` |
| generate flag | `--with-classes` | `--with-worktrees` |
| layer dir | `src/layers/classes/` | `src/layers/worktrees/` |

### 3. Compatibility: dual-read, permanently — no migration

The decisive observation is that **the compatibility question splits along this
repo's existing machinery/content line**, so it mostly answers itself:

- Flags, scripts, templates and docs are **machinery** — always overwritten, so
  the rename propagates on regeneration at zero cost.
- The `| Category |` rows in ~134 create-ai-builder tasks, and `classes.md`
  itself, are **content** — which the generator *by design* never touches.

So the old spellings are not transitional state that a migration could drain;
in an install that is never regenerated they persist forever. The readers
therefore accept both, permanently, and **no existing task needs rewriting**:

- `list-tasks.sh` reads `| Worktree |`, falling back to `| Category |`. A repo
  may hold a mix of both rows indefinitely and group/filter correctly.
- Both scripts read `worktrees.md`, falling back to `classes.md`.
- `generate.sh` seeds `worktrees.md` only when **neither** name exists — even
  under `--force`. Seeding beside an existing `classes.md` would leave the
  reader preferring a fresh empty starter over the operator's real definitions;
  that failure is silent, and noticing your worktrees vanished is not a
  recovery path.

Rejected: a migration script that rewrites the metadata row across existing
tasks. It would add destructive machinery that rewrites content this generator
otherwise never touches — to solve a problem the dual-read already solves.

**Flags are treated asymmetrically, deliberately:**

- **Runtime flags** (`--category`, `--group-by-category`) stay as deprecated
  aliases that warn. They are typed from muscle memory, by humans and agents,
  and appear in hand-written references inside consumer repos' own `CLAUDE.md`
  — which regeneration does not rewrite. A warning turns a hard failure into a
  nudge for near-zero cost.
- **`--with-classes` errors out**, naming its replacement. Generate-time flags
  are typed once, during a deliberate upgrade — and `v0.1.0` (cut two days
  earlier, `7442b72`, explicitly to give downstream a pinnable ref) is the
  escape hatch for anyone not ready to move.

### 4. The `Tags` gap — fixed here, not deferred

The rename alone would not have fixed the observed misuse. The operator wanted
topical grouping; `Tags` was the right answer but could only be set **at
creation** — retagging meant hand-editing the metadata row (against the "scripts
only" rule) or delete-and-recreate, which destroys the task's subtasks. The
*wrong* tool was easier to reach than the right one, so this task also ships:

- **`src/scripts/set-field.sh`** — sets `Tags` and `Priority` on an existing
  task or subtask. Scoped to fields that mirror nothing on the filesystem;
  `Status` and location stay owned by `move-task.sh` / `complete-task.sh`.
  Uses `python3` rather than `sed` so values containing `|` or `/` cannot
  corrupt the metadata table.
- **Discoverability** — `--tags` and `--tag` now appear in the `USING.md` quick
  reference (Creating / Viewing), `worktrees.md` states the Worktree-vs-Tags
  distinction up front, and the unknown-`--worktree` error explicitly points at
  `--tags` for topical grouping. That last one intercepts the exact captains-log
  mistake at the moment it is made.

## Deliberately left open

`set-field.sh` **refuses `Worktree`** (with a message pointing at
`new-user-task.sh --worktree`). It is pure metadata like `Tags`, so it is a
natural candidate — but setting it requires the `worktrees.md` validation logic
that currently lives in `new-user-task.sh`, and this task's agreed scope for
`set-field.sh` was `Tags` + `Priority`. Worth a follow-up: an operator who
mis-assigns a worktree currently has no scripted way to correct it.

## Done when

- [x] Decision recorded with rationale (this file).
- [x] Field, flags, `worktrees.md`, layer dir and template moved together.
- [x] `USING.md`, `docs/README.md`, `list-tasks.md`, `layers/README.md`, root
      `README.md` updated. (`list-tasks.md`'s "Category Order" section also
      dropped a stale claim that the order was hard-coded — it is read at
      runtime — and a list of create-ai-builder-specific class names.)
- [x] Compatibility position stated for already-generated repos, and **tested**
      rather than asserted: self-test §7 covers the legacy row, the
      `classes.md` fallback, the no-shadowing seed rule, and both flag paths.
- [x] `set-field.sh` + `--tag` discoverability (self-test §8).
- [x] Golden fixtures regenerated; self-test green (91 assertions).

## Follow-on

Task 15 (`--require-category`) is unblocked and its flag is now
**`--require-worktree`**; its task file has been updated. This change and 15
both break the `v0.1.0` contract and belong to the **v0.2.0** tag.
