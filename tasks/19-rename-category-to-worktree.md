# Task 19 — Discuss & resolve: rename `Category` to `Worktree`

**Type: discuss then resolve.** Not a foregone implementation — decide the
approach first.

## The issue

The field is called **Category**, but it does not mean *category*. It names the
**worktree class** a task belongs to: which files the task touches, so unrelated
groups can be worked in parallel branches without colliding. Valid values are the
**worktree branch names** declared in `classes.md` — the semantics are entirely
about parallel-work isolation, not about what a task is *about*.

The name mis-signals that. "Category" is the obvious word for a topical grouping,
so an operator wanting to class a task as `video` or `education` reaches for
`--category` first, finds it validates against a `classes.md` of branch names,
and has to be told the real mechanism is **`Tags`**. Observed in
`captains-log` (2026-07-26) — the misreading was immediate and reasonable.

Surface area of the current name: `--category` on `new-user-task.sh`, `--category`
/ `--group-by-category` on `list-tasks.sh`, the `Category` metadata row in the
user-task template, the `classes.md` file that defines the valid values, the
`--with-classes` and `--require-category` generate-time flags (task 15), and the
"Categories (`classes.md`)" section in `src/docs/USING.md`.

## To decide

- [ ] Rename to **`Worktree`**, to something else (`Class`, `Branch`,
      `Worktree-class`), or leave it and fix the naming purely in docs?
      `Worktree` is concrete and matches the values; `Class` matches `classes.md`
      but is nearly as vague as `Category`.
- [ ] Does `classes.md` get renamed too (`worktrees.md`)? Renaming the field but
      keeping `classes.md` leaves a second inconsistent name in place.
- [ ] Compatibility: hard rename, or accept `--category` as a deprecated alias
      that warns? Note the field appears in **existing generated repos** —
      create-ai-builder has ~134 tasks — so a hard rename of the metadata row
      needs a migration story, or a reader that accepts both.
- [ ] Interaction with task 15 (`--require-category`): if that ships first, this
      renames the flag it adds. Sequence them, or fold the naming decision into
      15 before it lands.
- [ ] Is the confusion actually solved by better docs plus making `Tags` more
      discoverable — e.g. surfacing `--tag` in the USING.md quick reference,
      where topical grouping is what people are looking for?

## Related gap (worth deciding alongside)

The reason the misuse surfaced at all is that the *correct* mechanism is
awkward: **`Tags` can only be set at creation.** There is no `set-tags.sh`, so
retagging an existing task means hand-editing the metadata row (against the
"scripts only" rule, though safe — `Tags` mirrors nothing on the filesystem) or
delete-and-recreate with `--id`, which destroys the task's subtasks. A
`set-field.sh` covering `Tags` and `Priority` would make the right tool as easy
to reach for as the wrong one.

## Done when

A decision is recorded with rationale, and — if we rename — the field, flags,
`classes.md`, templates, `USING.md`, self-test fixtures and golden files move
together, with a stated compatibility position for already-generated repos.
