# Task 13 — Rename audit inside create-ai-builder (repo-name vs product-name)

> **OWNERSHIP: create-ai-builder-domain work** (editing its own README/bootstrap/
> docs), not generator-build work — same as [[12-relocate-pipeline-scripts]].
> Placeholder here; re-home into create-ai-builder's task tracker after task 09
> Part B, then delete from this repo's plan.

**Context:** after renaming the repo `ai-builder` → `create-ai-builder`, the
string `ai-builder` still appears **912 times** in the repo. The overwhelming
majority are the **product/artifact** name and MUST stay. Only true
**repo self-references** change. Do NOT blanket find-replace.

## STAYS `ai-builder` (do not touch)

- **The inner `ai-builder/` directory** and every path into it
  (`ai-builder/orchestrator/...`, `ai-builder/docs/...`). This is the product/
  engine — the thing generated into target repos. This is exactly the
  "ai-builder target generation" case.
- **`.gitignore`** runtime-artifact entries (`ai-builder/logs/`,
  `ai-builder/execution.log`, `ai-builder/TASK-*.md`, `ai-builder/orchestrator/*`).
- **Regression recordings** (`tests/regression/**/runs/*/execution.log`, gold
  outputs, `*.log`) — historical fidelity; renaming corrupts the recordings.
- **Task-content history** (`project/tasks/main/**/README.md`, task names like
  `f1b8a0-establish-ai-builder-documentation`) — the historical record of past
  work; do not rewrite it.

## CHANGES to `create-ai-builder` (repo self-references)

- [ ] `README.md`: line 1 title `# ai-builder`, `git clone …/ai-builder.git`,
      `cd ai-builder`. (Leave every `ai-builder/orchestrator/...` path as-is.)
- [ ] `bootstrap/setup-workspace.sh` — **setup-critical, test after editing**:
      `WORKSPACE="$PARENT_DIR/ai-builder"` and the `~/.claude/projects/
      ...cornjacket-ai-builder-*` path hints refer to the container/repo, not the
      product. The `ai-builder-bootstrap` clone-dir convention and the inner
      `ai-builder/` product dir in its tree stay.
- [ ] Sweep `CLAUDE.md` + `bootstrap/README.md` + top-level docs case-by-case:
      "this repo, ai-builder" → rename; "the ai-builder orchestrator/engine" → keep.
- [ ] After edits, run `bootstrap/setup-workspace.sh` in a scratch dir to confirm
      worktree setup still works end to end.

## Method

Go file-by-file for the CHANGES list; never a repo-wide `sed`. For each hit ask:
"does this name **this repo/container**, or the **product it builds/installs**?"
Repo → rename. Product → keep.

## Done when

Repo self-references read `create-ai-builder`; all product/artifact/historical
references still read `ai-builder`; `setup-workspace.sh` verified working.
