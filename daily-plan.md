# Daily plan — 2026-07-28

**What this repo is (for a newcomer):** A Cookiecutter-style *generator* that
installs a Markdown-based project-management workspace — a task tracker
(`tasks/`) plus periodic status reports (`status/`) — into any target repo at a
caller-chosen mount, non-destructively and re-runnably.

**Last implemented:** **The loop is closed.** Task 09 merged as create-ai-builder
PR #4 (squash `7845243`, 2026-07-26): the generator now produces the task
subsystem it was originally extracted from, parity proven against 134 real tasks.
The create-ai-builder-domain follow-ups went home to that repo's own tracker
(`afe148a`) via its freshly-migrated `new-user-task.sh`. Closing 09 today was
bookkeeping — the plan had gone two days stale claiming the branch was still
awaiting review.

**Focus / plan:** every rollout task is done; what's left is the
**discuss-then-resolve backlog**. These are decisions, not builds — the output of
each is a recorded rationale, and only then a change.

- **19 — rename `Category` → `Worktree`.** Start here; it gates 15. The field
  names a *worktree class* (which files a task touches, so unrelated work can run
  in parallel branches) but "Category" reads as topical grouping, so operators
  reach for it when they want `Tags` — observed in captains-log on 2026-07-26.
  The real work is the decision, and the hard part is **compatibility**: the field
  is live in ~134 create-ai-builder tasks, so a hard rename needs a migration
  story or a reader that accepts both. Decide alongside: does `classes.md` become
  `worktrees.md`, and is a `set-field.sh` (for `Tags`/`Priority`) the actual fix —
  the misuse persists partly because `Tags` can only be set at creation.
- **15 — `--require-category` opt-in.** Strictly after 19: it adds a flag that
  bakes the field name in, so shipping it first means renaming it immediately.
- Then **18** (infer the parent in `complete-task.sh`) and **20** (`project/projects/`
  layout in the rich view — leaning config-driven over two script copies).
- Cheap wins if there's slack: **21** (delete `tasks-test/` + `tasks-test-wt/`,
  which also silences the un-bootstrapped-repo nudge) and **16** (skill + `USING.md`
  as the primary usage vehicle, kernel-only CLAUDE.md).
- **22** stays a discussion, not a build — the valid outcome is a *written
  trigger* in both copies of the decision, not a shared library today. Note its
  premise now holds: the third consumer of this substrate landed with 09.

```
  [09] ✅ merged 2026-07-26 — loop closed
        │
        ▼
  discuss-then-resolve queue (all this repo)

   19 ──────► 15          18          20
 (rename)    (flag)     (parent)   (layout)
   ▲
 today — 19 must precede 15;
 15 would bake in the old name

   slack: 21 (scratch-repo cleanup) · 16 (skill over CLAUDE.md)
          22 stays a decision, not a build
```
