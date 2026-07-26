# Task 16 — Make the task-manager skill the primary usage vehicle (not CLAUDE.md)

**Insight (operator):** task-usage directives bloat `CLAUDE.md`. A repo that
adopts the task system shouldn't carry the whole "how to use the task manager"
manual in its always-on `CLAUDE.md` — it belongs in an **on-demand skill**, with
`CLAUDE.md` holding only the small always-on kernel.

**Reference case:** `create-ai-builder`'s `CLAUDE.md` inlines a very large Task
Management section (task types, naming, status folders, the standard task
workflow, TESTER decisions, the full scripts table, ~a dozen rules). Most of that
is *procedure* that should be reached on demand, not paid for on every turn.

## Where we already are

create-project-system already ships the layered design:
- `src/snippets/claude-md.snippet.md` — the ~11-line always-on kernel
- `src/skill/task-system/SKILL.md` — the on-demand skill (currently a **thin
  pointer** to USING.md + the one critical rule)
- `src/docs/USING.md` — the single source of truth

So the vehicle exists; this task is about making the **skill** carry enough that
`CLAUDE.md` never needs more than the kernel.

## Scope

- [ ] Audit what task-usage content currently tends to land in `CLAUDE.md`
      (using create-ai-builder's CLAUDE.md Task Management section as the worked
      example). Classify each part: **generic task-manager usage** (→ skill /
      USING.md) vs **repo-specific policy/workflow** (stays, or its own skill).
- [ ] Decide the skill's depth: keep it a thin pointer, or promote the
      highest-value operating rules into `SKILL.md` itself so it's useful without
      opening USING.md. (Progressive disclosure — skill is the accelerator.)
- [ ] Ensure the kernel + skill + USING.md split has **no duplication** and one
      source of truth (USING.md). Skill and kernel point to it.
- [ ] Verify an adopting repo can delete its inline task directives and rely on
      kernel (always-on) + skill (on-demand) with no loss.

## Related / downstream

- **create-ai-builder** then slims its `CLAUDE.md`: move generic task directives
  out (rely on the emitted skill), keep only pipeline/worktree-class specifics.
  (create-ai-builder-domain follow-up; pairs with the deferred CLAUDE.md
  reconciliation from task 09 / [[13-rename-audit-create-ai-builder]].)
- Pairs with **create-context-hygiene task 12** (`12-claude-md-first-and-skill-
  handoff`) — the budget/hygiene side of the same "keep CLAUDE.md small" goal.
  That task wires "procedure that leaves CLAUDE.md" to *this* skill as its landing
  zone. (Relocated there — it's context-hygiene's domain.)

## Done when

The task-system skill (+ USING.md) fully covers task-manager usage, `CLAUDE.md`
carries only the kernel, and there is exactly one source of truth with no
duplication across the three layers.
