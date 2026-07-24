# Task 03b — Task-system AI skill (layered instructions)  ✅ DONE

> **Result:** three-layer split shipped. Always-on kernel is **11 non-blank lines**
> (vs ~300 lines of always-on task procedure in ai-builder's CLAUDE.md). All 9
> command examples live solely in `USING.md` — verified single-source; the kernel
> and skill contain zero code blocks. No ai-builder-specific terms leaked.

**Goal:** ship the task-system how-to as an on-demand **skill** with a single
portable source-of-truth doc, and shrink the always-on CLAUDE.md footprint to a
kernel. Runs after task 02 (core extracted).

**Why:** CLAUDE.md is loaded every session/turn. ai-builder's is 550 lines,
~300 of them task-system + worktree procedure — an always-on tax paid even when
no task work happens. A skill uses progressive disclosure (only its one-line
description sits in context until invoked). See `docs/extraction-analysis.md`
and the design discussion that produced this task.

## Three layers to emit

1. **Portable source-of-truth doc** — `src/docs/USING.md`: the full how-to (task
   types, script reference, status transitions, `NNNN` ordering, granularity
   rules, lifecycle walkthrough). One file, agent-agnostic. Everything else
   points at it — no duplication.
   - [x] Move the bulk procedural content out of the CLAUDE.md snippet into here.

2. **Claude skill** — `src/skill/task-system/SKILL.md`: thin wrapper with
   frontmatter (`name: task-system`, one-line `description:` that triggers on
   "create/close/list a task, manage subtasks") whose body **points to**
   `<tasks>/docs/USING.md` rather than re-stating it.
   - [x] Author SKILL.md so the substance stays in USING.md (single source).

3. **CLAUDE.md kernel snippet** — `src/snippets/claude-md.snippet.md`, shrunk to
   ~10–15 lines: only always-fire rules (e.g. "any work outside `/sandbox`
   requires a task — check/create one first") + a pointer: "task work is governed
   by the `task-system` skill / `<tasks>/docs/USING.md`."
   - [x] Rewrite the snippet to the kernel; nothing procedural remains in it.

## Multi-agent parity

Skills are Claude-specific; ai-builder is also driven by Gemini
(`GEMINI.md → CLAUDE.md`). Keep parity:

- [x] Emit a `GEMINI.md` pointer (or snippet) that references the same
      `USING.md`. Single source, two loaders. Non-Claude targets skip the skill
      and use `USING.md` directly.

## Generator flag

- [x] `--with-skill` emits `.claude/skills/task-system/` into the target.
      `USING.md` and the kernel snippet are emitted **always** (the skill is an
      accelerator, never the only copy).

## Done when

Generating with `--with-skill` yields a working skill that loads on demand, a
target CLAUDE.md that grew by ~15 lines (not ~300), and one `USING.md` that both
the skill and GEMINI.md reference.

Ref: `docs/extraction-analysis.md` §2 (docs), §5 (generate contract).
