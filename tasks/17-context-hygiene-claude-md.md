# Task 17 — Context hygiene for `CLAUDE.md` specifically

**Related to [[16-task-manager-skill-over-claude-md]].** Task 16 moves task
directives *out* of `CLAUDE.md` into a skill; this task is the **general
discipline** behind it: what earns a place in `CLAUDE.md` at all, measured, and
enforced.

**Domain note:** this is squarely **`create-context-hygiene`**'s purpose (the
orthogonal peer generator). It's captured here because it surfaced alongside the
skill idea; **it should re-home into `create-context-hygiene`'s plan** (like the
create-ai-builder tasks re-home to their repo). Kept here as the seed so the
connection isn't lost.

## The question

`CLAUDE.md` is always-on context — every line is paid for on every turn. So it
needs a gate: what belongs there vs. what moves to a skill (on-demand) or
USING.md / a reference doc (pulled when needed)?

## Scope

- [ ] **Budget in tokens, not lines.** A `CLAUDE.md` is "too big" by token cost,
      not line count. Define the measure (pluggable counter — heuristic default,
      exact via a token API) and a target budget.
- [ ] **Placement rubric.** What earns always-on placement: durable, every-turn-
      relevant directives and invariants. What moves out: procedures (→ skill),
      reference tables/format specs (→ USING.md / README), anything reached only
      occasionally. (Mirrors the kernel-vs-skill-vs-USING split from task 16.)
- [ ] **Productize the check.** A pre-commit / CI check (or a
      `create-context-hygiene` generator output) that measures `CLAUDE.md`'s token
      budget and flags sections that look like they belong in a skill/doc — the
      same shape second-brain uses for note size, applied to `CLAUDE.md`.
- [ ] Worked example: run it against `create-ai-builder`'s oversized `CLAUDE.md`
      and show what the rubric would relocate.

## Related

- [[16-task-manager-skill-over-claude-md]] — the skill is *where* task directives
  go; this task is *how you decide* what leaves CLAUDE.md, generalized.
- Reconciles with the earlier context-hygiene design work in
  `create-context-hygiene` (token-budgeting, per-file/per-section manifest).

## Done when

There's a token-budget measure + a placement rubric for `CLAUDE.md`, and a
productized check that flags over-budget / mis-placed content — designed to live
in `create-context-hygiene`.
