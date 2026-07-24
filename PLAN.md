# PLAN — Build the Task-Subsystem Generator

**Goal:** extract ai-builder's Markdown task subsystem into `create-project-system`
as a **generator** that materializes the subsystem into any target repo at a
caller-chosen directory. First generation target is `tasks-test/`; the eventual
real target is `second-brain/`.

**Design reference:** [`docs/extraction-analysis.md`](docs/extraction-analysis.md)
— component inventory, coupling analysis, decided scope, and the `generate.sh`
contract (§5).

**Scope (decided):** human core + `--with-classes` + `--with-projects` +
`--with-status` + `--with-worktree-guard`. `--with-status` (task 10) widened the
scope from the `tasks/` pillar alone to ai-builder's full `project/` PM workspace
(tasks + status), which is why the repo is now `create-project-system`. The
`reviews/` and empty project-level `scripts/` pillars are **excluded** (reviews
was never designed; scripts held nothing). The pipeline/orchestrator layer is
**deferred** (kept as an isolated seam, not built now).

**Sibling repo:** `create-context-hygiene` is an orthogonal peer generator that
**copies this repo's generator substrate** (`generate.sh`, root resolution,
golden harness, `sandbox/` self-test). So this repo's substrate (tasks 01, 04,
04b) should land first — it's the source that peer copies from. No runtime
dependency between them; they only compose at a shared target repo.

**Key refactors applied during extraction:**
- Repo root via `git rev-parse --show-toplevel` (walk-up fallback), not `../../..`.
- Mount path + default epic via a generated `task-config.sh` sourced by every
  script — replaces the 61 hardcoded `project/tasks` literals with one value.

---

## Repo layout (target end state)

```
create-project-system/
    PLAN.md                 ← this file
    generate.sh             ← the emitter (task 04)
    src/                    ← shippable master the generator emits (tasks 01–03b)
        scripts/
        templates/
        docs/               ← README.md, task-manager.md, USING.md (portable how-to)
        config/task-config.sh.in
        snippets/claude-md.snippet.md   ← kernel (~15 lines), not the full how-to
        skill/task-system/SKILL.md      ← on-demand skill, points at USING.md
    sandbox/                ← disposable self-test target (git-ignored, task 04b)
    tasks/                  ← build work-items (this plan's tasks)
    docs/                   ← analysis + design docs
```

---

## Tasks (in order)

1. [x] [`01-scaffold-src.md`](tasks/01-scaffold-src.md) — create the `src/` layout. ✅ (env bootstrap verified across workspace/worktree/no-git)
2. [x] [`02-extract-core.md`](tasks/02-extract-core.md) — extract + refactor CORE scripts, templates, docs into `src/`. ✅ (66-assertion e2e test green across repo/nested/worktree)
3. [x] [`03-extract-optional-layers.md`](tasks/03-extract-optional-layers.md) — classes, projects, worktree-guard behind flags. ✅ (26-assertion layers-on/off test green)
3b. [x] [`03b-extract-skill.md`](tasks/03b-extract-skill.md) — task-system AI skill + portable `USING.md` + shrunk CLAUDE.md kernel. ✅ (kernel 11 lines; single-source verified)
4. [x] [`04-build-generate-sh.md`](tasks/04-build-generate-sh.md) — write `generate.sh` per the §5 contract. ✅ (40-assertion suite green; regeneration is non-destructive)
4b. [x] [`04b-self-test-sandbox.md`](tasks/04b-self-test-sandbox.md) — self-test generation into a disposable in-repo `sandbox/`. ✅ (54 assertions green, CI-ready)
4c. [x] [`04c-ci.md`](tasks/04c-ci.md) — run the self-test on every push/PR (Linux + macOS). ✅ (both legs green; GNU `sed` + bash 3.2/5.2 verified)
4d. [x] [`04d-bump-checkout-action.md`](tasks/04d-bump-checkout-action.md) — bump `actions/checkout` + `upload-artifact` v4→v7. ✅ (deprecation annotation gone)
5. [x] [`05-generate-into-tasks-test.md`](tasks/05-generate-into-tasks-test.md) — regeneration/upgrade path over a committed install. ✅ (zero-diff regen verified in standard + worktree layouts)
6. [x] [`06-golden-test.md`](tasks/06-golden-test.md) — reproducibility test. ✅ (tests/run.sh + golden fixtures; folded into self-test)
10. [x] [`10-status-layer-project-workspace.md`](tasks/10-status-layer-project-workspace.md) — `--with-status` + `project/` workspace + repo rename. ✅ (61 assertions; core/all-layers/project fixtures)
11. [x] [`11-sentinel-claude-md-block.md`](tasks/11-sentinel-claude-md-block.md) — sentinel-wrap the CLAUDE.md kernel + in-place update. **Blocks 07's CLAUDE.md step.**
7. [x] [`07-generate-into-second-brain.md`](tasks/07-generate-into-second-brain.md) — the real target; canonical mount `project/tasks --with-status`. ✅ Installed at repo root (5b6d9d4); no cache pollution.
8. [x] [`08-generate-into-captains-log.md`](tasks/08-generate-into-captains-log.md) — roll out to captains-log (after second-brain).
9. [ ] [`09-generate-into-ai-builder-task-free.md` — task-free `create-ai-builder`, then regenerate. Rename + project-status tracking DONE; surgical strip + regen + verify remain.

Mark a task `[x]` here when its task file's checklist is fully done.
