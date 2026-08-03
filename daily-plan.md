# Daily plan — 2026-08-03

**What this repo is (for a newcomer):** A Cookiecutter-style *generator* that
installs a Markdown-based project-management workspace — a task tracker
(`tasks/`) plus periodic status reports (`status/`) — into any target repo at a
caller-chosen mount, non-destructively and re-runnably.

**Last implemented:** **Task 19 is resolved — `Category` is now `Worktree`**
(`aa757cf`). The field never meant "category": it names which files a task
touches, so unrelated work can run in parallel branches. Three names described
that one concept and none agreed — the `Category` field, the `classes.md` file,
and the `**Worktree branch:**` values inside it — so all three converged. The
compatibility position fell out of this repo's own machinery/content split:
flags and scripts are machinery and rewrite themselves on regeneration, but the
`| Category |` rows in ~134 create-ai-builder tasks are *content* the generator
never touches, so old spellings are permanent state, not transitional state a
migration could drain. The readers therefore accept both **forever** and nothing
needs migrating — verified by running create-ai-builder's own bats suites
unmodified against the new machinery (9/9 and 11/11). Same commit shipped
`set-field.sh`, which is what actually fixes the misuse that started this:
`Tags` was previously settable only at creation, so the wrong tool was easier to
reach than the right one. Self-test 71 → 91 assertions.

**Focus / plan:** the rename is a **breaking change to the v0.1.0 contract that
is still untagged**, and that single gap is blocking work in another repo.

- **Cut and push `v0.2.0`.** Start here; everything else queues behind it.
  `v0.1.0` (`7442b72`) named `generate.sh` and its 10 flags as the layer-1
  contract that create-ai-builder vendors against. Task 19 renamed one of those
  flags (`--with-classes` → `--with-worktrees`), so the tag needs cutting before
  any downstream can pin the new behavior. The annotated message should carry
  the migration position explicitly — **no migration required** — since that is
  the non-obvious part and the reason a consumer can bump without a work order.
- **Then 24** (pipeline-layer doc leakage, captured `c23c3eb`). Cheap, and it is
  the only queued item that misleads *plain* consumers rather than
  create-ai-builder, which overlays the missing scripts and so cannot see it.
- **Then 15 — `--require-worktree`.** Unblocked by 19 and already renamed in its
  task file; sequencing it after 19 is exactly why it waited, so the flag it
  adds does not bake in a name that was about to change.
- Then the remaining discuss-then-resolve queue: **18** (infer the parent in
  `complete-task.sh`), **20** (`project/projects/` layout — leaning
  config-driven over two script copies).
- Cheap wins if there's slack: **21** (delete `tasks-test/` + `tasks-test-wt/`)
  and **16** (skill + `USING.md` as the primary usage vehicle).
- **22** stays a discussion, not a build — the valid outcome is a *written
  trigger* in both copies of the decision, not a shared library today.

**Downstream, not this repo's work:** create-ai-builder carries
`9046c5-adopt-worktree-rename` (`93b219c`), which rewrites 62 live task READMEs,
renames its `classes.md`, and fixes the 8 `--category` mentions in its
hand-written `CLAUDE.md`. That last one is the highest-leverage piece — the
generator can never rewrite it, and it is the surface still teaching agents the
name that caused the original confusion. It waits on `v0.2.0` and on `15d940`
bumping the vendored pin.

```
  [19] ✅ aa757cf — Category -> Worktree, no migration needed
        │
        ▼
   v0.2.0  ◄── TODAY. untagged; breaks the v0.1.0 flag contract
        │
        ├──────────────┬───────────────┐
        ▼              ▼               ▼
   24 (doc leak)   15 (--require-   ai-builder 9046c5
   plain-consumer   worktree)        (pin bump + 62 files
   facing only      unblocked by 19   + CLAUDE.md wording)
        │
        ▼
   18 (parent)   20 (layout)
   slack: 21 (scratch repos) · 16 (skill over CLAUDE.md)
          22 stays a decision, not a build
```
