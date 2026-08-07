# PLAN — Build the Task-Subsystem Generator

**Goal:** extract ai-builder's Markdown task subsystem into `create-project-system`
as a **generator** that materializes the subsystem into any target repo at a
caller-chosen directory. First generation target is `tasks-test/`; the eventual
real target is `second-brain/`.

**Design reference:** [`docs/extraction-analysis.md`](docs/extraction-analysis.md)
— component inventory, coupling analysis, decided scope, and the `generate.sh`
contract (§5).

**Scope (decided):** human core + `--with-worktrees` + `--with-projects` +
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
9. [x] [`09-generate-into-ai-builder-task-free.md`](tasks/09-generate-into-ai-builder-task-free.md) — task-free `create-ai-builder`, then regenerate. ✅ **Loop closed** — the generator reproduces the subsystem it was extracted from. Merged as create-ai-builder PR #4 (squash `7845243`, 2026-07-26); parity proven against 134 real tasks.

12–14. **Re-homed to create-ai-builder** (2026-07-26) — created in its own tracker via `new-user-task.sh` (dogfooding the migrated system): `29297c-relocate-pipeline-scripts`, `59ea60-repo-name-rename-audit`, `15d940-target-setup-uses-generator-for-tasks`. The target-composition design doc stays here: [`docs/composition-with-create-ai-builder.md`](docs/composition-with-create-ai-builder.md).
15. [ ] [`15-require-worktree-opt-in.md`](tasks/15-require-worktree-opt-in.md) — `--require-worktree` opt-in enforcement in the generator (surfaced by task 09 CI; lets create-ai-builder restore worktree-required without forking the script). Unblocked by 19, which renamed the flag before it could bake in the old name. **create-project-system-owned.**
16. [ ] [`16-task-manager-skill-over-claude-md.md`](tasks/16-task-manager-skill-over-claude-md.md) — make the task-system skill (+USING.md) the primary usage vehicle so CLAUDE.md keeps only the kernel. **create-project-system-owned.**
18. [ ] [`18-complete-task-infer-parent.md`](tasks/18-complete-task-infer-parent.md) — discuss & resolve: infer/record the parent so `complete-task.sh` doesn't require `--parent` for subtasks. **create-project-system-owned.** (17 relocated to create-context-hygiene.)
19. [x] [`19-rename-category-to-worktree.md`](tasks/19-rename-category-to-worktree.md) — discuss & resolve: rename `Category` to `Worktree`. ✅ Resolved 2026-07-28: full convergence (field, flags, `worktrees.md`, layer dir, `--with-worktrees`), with **dual-read compatibility — no migration of existing tasks**, since both the metadata row and the definitions file are content the generator never rewrites. Also ships `set-field.sh` (Tags/Priority after creation), closing the gap that made the wrong tool easier to reach than the right one. **Breaking: belongs to v0.2.0.** **create-project-system-owned.**
20. [ ] [`20-tooling-support-projects-layout.md`](tasks/20-tooling-support-projects-layout.md) — discuss & resolve: make the rich task view work in `project/projects/` mode. Repo is single-mode (tasks XOR projects) → two script copies vs. one config-driven copy (lean: config-driven). **create-project-system-owned.**
21. [ ] [`21-clean-up-tasks-test-repos.md`](tasks/21-clean-up-tasks-test-repos.md) — retire the `tasks-test/` and `tasks-test-wt/` scratch repos from task 05; the upgrade path is verified and real consumers now exercise both layouts. Local-only, not on any remote. **create-project-system-owned.**
22. [ ] [`22-revisit-shared-generator-substrate.md`](tasks/22-revisit-shared-generator-substrate.md) — discuss & resolve: `create-context-hygiene` copied this repo's generator substrate and deferred a shared lib until "a third module appears", but nothing defines what counts as a third or watches for it. Third *consumer of this substrate* arrives via task 09 + ai-builder's `15d940`; third *generator overall* (`second-brain-devkit`) already exists on a different substrate. Re-homed from captains-log `bb5b51-0004` on 2026-07-27. **create-project-system-owned.**

23. [x] [`23-cut-v0.1.0-release-tag.md`](tasks/23-cut-v0.1.0-release-tag.md) — cut `v0.1.0`, the first release tag, so create-ai-builder's `15d940` can vendor a *named* ref instead of a bare SHA. ✅ Annotated tag → `c003956`, pushed 2026-07-28; names `generate.sh` + its 10 flags as the layer-1 contract. **Tasks 19 and 15 both break that contract — they belong to the next tag, with a migration position for already-generated repos.**

24. [ ] [`24-fix-pipeline-doc-leakage.md`](tasks/24-fix-pipeline-doc-leakage.md) — fix two layer-1/layer-2 doc defects surfaced from create-ai-builder's `15d940`: (1) `docs/composition-with-create-ai-builder.md` overstates the pipeline overlay as "7 scripts + orchestrator/roles/machines" (the installed overlay is the 7 scripts); (2) the generated `src/docs/README.md` documents `new-pipeline-subtask.sh` / `set-current-job.sh`, which `generate.sh` doesn't install — harmless for ai-builder (it overlays them) but a plain consumer gets docs for missing scripts. **create-project-system-owned.**

25. [ ] [`25-backfill-missing-status-folders.md`](tasks/25-backfill-missing-status-folders.md) — bug: `generate.sh:274` skips an existing epic **whole**, so an install that predates a status-folder addition never gets that folder, and regenerating never fixes it. `create-ai-builder` has no `inbox/` while `captains-log` does — the divergence that crashed the workspace's `replan`. Empty status folders are not content: create them if missing, without touching existing task lists. **create-project-system-owned.**
26. [ ] [`26-stamp-generator-version.md`](tasks/26-stamp-generator-version.md) — feat: record the generator version in the generated `task-config.sh`, so an install can declare which layer-1 contract it carries and regeneration can report old→new. Complements the `--json` request: the stamp says *which contract*, JSON says *the data under it*. Must preserve task 06's byte-identical reproducibility — version string only, no dates or SHAs. **create-project-system-owned.**
27. [ ] [`27-list-tasks-json-output.md`](tasks/27-list-tasks-json-output.md) — feat: `list-tasks.sh --json`, so a programmatic consumer stops scraping human text with `sed` and hard-coding the folder vocabulary. Requested by `dev-workspace` 2026-08-04 after the coupling took down a whole `replan` run (`replan.sh:68-73`). Payload must carry the install's own status-folder set, not just tasks. **Design jointly with 28** — they share the payload, versioning and JSON-encoding decisions, and answering those twice is how the two disagree. **create-project-system-owned.**

28. [ ] [`28-declare-mount-in-root-manifest.md`](tasks/28-declare-mount-in-root-manifest.md) — feat: `generate.sh` writes a fixed-name JSON manifest at the target repo root declaring where the task-system is mounted, so consumers stop probing for it. 27 makes an install's *contents* legible; this makes its *location* legible, and a consumer that cannot find the mount never reaches the lister. Requested by `dev-workspace` 2026-08-06 while planning inter-repo mail, which needs the same fact `replan.sh:53-62` currently guesses at. Cannot live in `task-config.sh` (task 26) — that file is inside the directory being located. **create-project-system-owned.**

Mark a task `[x]` here when its task file's checklist is fully done.
