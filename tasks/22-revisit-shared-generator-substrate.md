# Task 22 — Discuss & resolve: revisit the shared generator substrate on the third consumer

**Type: discuss then resolve.** The decision may well stay "copy". What is missing
is a defined trigger and an owner, so the question gets answered deliberately
rather than by drift.

## The standing decision

`create-context-hygiene` copied this repo's generator substrate — `generate.sh`,
root resolution, the golden harness, the `sandbox/` self-test — rather than
depending on it, and recorded the rationale in two places:

- `docs/hygiene-design.md` §7: *"Shares the substrate with `create-project-system`
  — **copied, not shared-lib** (two consumers don't justify a shared dependency
  yet; promote later if a third module appears)."*
- `PLAN.md`: *"a copy-once dependency, not a runtime one; promote to a shared lib
  only if a third generator appears."*

That is a good call at two consumers. It also wrote a cheque against a future
event — **"if a third appears"** — that nobody is currently watching for.

## Why this is being filed now

Origin: `captains-log` task `bb5b51-task-devkit-pluggable-subsystems`, subtask
`0004-generalize-shared-engine-on-third-consumer`, closed 2026-07-27 as
superseded. That roadmap encoded a deliberate three-step rule — *use it by hand,
extract on the second need, generalize shared machinery on the third consumer* —
and steps one and two executed exactly as written (this repo is step two). Step
three was the only strand with no owner when the task closed, because the repo
that owns the substrate is this one, not the log.

## The actual question: what counts as "a third"?

This is the crux, and it is genuinely ambiguous today.

**Reading A — a third consumer of *this* substrate.** Does not exist yet, but is
arriving: `create-ai-builder` installs into a target through its own hand-rolled
`target/setup-project.sh`, and its tracker already holds
`15d940-target-setup-uses-generator-for-tasks` — i.e. a live task to route that
installer through this generator. Task 09 here is the other half of the same
move. If that lands, the third consumer exists and the trigger has fired.

**Reading B — a third generator overall.** Already exists: `second-brain-devkit`.
But it is **not** a consumer of this substrate and arguably never should be — it
is a *different* substrate solving the same shape of problem in a different
language and idiom:

| | `create-project-system` / `create-context-hygiene` | `second-brain-devkit` |
| --- | --- | --- |
| Emit driver | `generate.sh` (shell) | `tools/generate.py` (Python) |
| What to emit | `src/` tree + flags | `emit-manifest.toml`, a partitioned manifest |
| Re-run semantics | regenerate, verified zero-diff | `update_brain.py`, strictly additive |
| Correctness harness | `sandbox/` self-test + golden fixtures | golden repo (`second-brain-test`) + `check_structural_diff.py` |

Two independent implementations of *emit a subsystem into a target repo, safely,
repeatedly* is exactly the evidence a shared engine would want — and also a
strong argument that the two are different enough that unifying them would be the
wrong abstraction. The source roadmap's own warning applies here: don't build the
framework before the common surface is visible.

## To decide

- [ ] Which reading fires the trigger — third *consumer of this substrate*
      (Reading A) or third *generator* (Reading B)? Pick one and write it down;
      the current wording ("if a third module appears") does not distinguish
      them, which is why nothing has fired.
- [ ] Is `create-ai-builder` via `15d940` the third consumer? If yes, this task
      is sequenced behind task 09 and `15d940`, not independent of them.
- [ ] Is `second-brain-devkit` in scope at all, or explicitly out — a peer
      substrate that stays separate by design? Recording "out, deliberately" is a
      valid and probably cheap outcome, and stops the question resurfacing.
- [ ] If we promote: what is the shared unit — a vendored `substrate/` directory
      copied by a script, a git submodule/subtree, or an installable package? The
      spectrum here mirrors the one the source roadmap laid out for devkits
      (manual copy → subtree → cookiecutter → additive-update), and the answer
      likely differs for shell vs. Python.
- [ ] What does drift between the copies cost *today*? Diff `generate.sh` and the
      root-resolution/golden/sandbox pieces across this repo and
      `create-context-hygiene` and measure it. If they have already diverged
      meaningfully, that is the real argument for promoting; if they are still
      near-identical, copy is working and the answer is "not yet".
- [ ] Who owns the substrate once shared? Today this repo is the de-facto source
      and `create-context-hygiene` the copier. A shared lib needs a stated home.

## Done when

A decision is recorded with rationale — including an explicit **"not yet, and
here is the trigger"** if that is the outcome — and the trigger is written into
this repo's `PLAN.md` and `create-context-hygiene`'s design §7 so both copies
state the same rule. If the decision is to promote, the substrate's new home,
sync mechanism, and ownership are named before any code moves.

## Related

- Task 09 — `09-generate-into-ai-builder-task-free.md` (strip + regen + verify
  remain); the third consumer arrives through it.
- `create-ai-builder` — `15d940-target-setup-uses-generator-for-tasks`.
- `docs/composition-with-create-ai-builder.md` — target-composition design.
- `create-context-hygiene` — `docs/hygiene-design.md` §7, `PLAN.md`.
