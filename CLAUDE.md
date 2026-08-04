# CLAUDE.md

Project-specific operating directives for Claude Code.

<!-- ai-project-status:begin -->
<!--
  This block is injected and refreshed by project-status:
  https://github.com/cornjacket/project-status

  Do not edit between the begin/end markers — local edits will be
  overwritten on the next `setup-new-repo.sh --update`. To change
  the rules, edit templates/claude-rule.md in project-status
  and re-run `setup-new-repo.sh --update <this-repo-remote>`.

  This block is deliberately a KERNEL: only the rules that would be too
  late if they loaded on demand. Rationale, examples, and the daily-plan
  body structure live in ./project-status-guide.md.
-->
## project-status: commit + daily-plan discipline

This repo is monitored by [`project-status`](https://github.com/cornjacket/project-status): it reconstructs activity from your **git history** and aggregates your `daily-plan.md` across every tracked repo. **Read [`project-status-guide.md`](project-status-guide.md)** (repo root) before writing a daily plan, or whenever a commit message needs more than the rules below.

### Commits

1. Every commit follows this shape. `[Context]` and `[Impact]` are required on any non-trivial commit (a typo or pure formatting may omit them):

   ```
   <domain>(<scope>): <high-level functional summary>
   - [Context]: why this was done / what was learned
   - [Impact]: how it alters the project or system behavior
   ```

2. Title the **system change, not the files**, and write it for a reader who has never seen this repo — these messages are summarized across the whole portfolio. `feat(auth): let users reset a forgotten password by email`, not `add token TTL check to reset handler`.

3. Commit at **task granularity** — never per-prompt — and commit completed work **before the session ends**. Uncommitted work is invisible to the tracker.

4. Immediately after committing, print `✅ <short-hash> — <title>` on its own line.

### Daily plan (`daily-plan.md`, repo root)

5. The first line is exactly `# Daily plan — YYYY-MM-DD` and nothing else — no repo URL. The file is **one** day's plan: always overwritten, never appended.

6. Write the *next* day's plan only when the user explicitly asks to plan ahead — not on an ambiguous "let's stop here". On Friday, write Monday's.

<!-- ai-project-status:end -->

<!-- git-workspace-commits:begin -->
<!--
  Injected and refreshed by a git-workspace that tracks this repo:
  https://github.com/cornjacket/create-git-workspace

  Do not edit between the markers — the next injection overwrites this block.
  Everything OUTSIDE the markers is yours and is preserved.

  This block is deliberately a KERNEL: only the rules that would be too late if
  they loaded on demand. It is also deliberately WORKSPACE-AGNOSTIC — it is
  committed to this shared repo, and several developers may each track it from
  their own workspace. Nothing here may name one workspace, one developer, or
  one generator version, or two developers would overwrite each other's block on
  every injection.
-->
## Commit discipline

Your commits are this repo's telemetry. A workspace reconstructs what happened
here from `git log` alone and summarizes it across a whole portfolio, so a commit
that does not say what changed is work nobody can see.

1. Every commit follows this shape. `[Context]` and `[Impact]` are required on any
   non-trivial commit (a typo or pure formatting may omit them):

   ```
   <domain>(<scope>): <high-level functional summary>
   - [Context]: why this was done / what was learned
   - [Impact]: how it alters the project or system behavior
   ```

2. Title the **system change, not the files**, and write it for a reader who has
   never seen this repo — these messages are read across the whole portfolio.
   `feat(auth): let users reset a forgotten password by email`, not
   `add token TTL check to reset handler`.

3. Commit at **task granularity** — never per-prompt — and commit completed work
   **before the session ends**. Uncommitted work is invisible to the tracker.

4. Immediately after committing, print `✅ <short-hash> — <title>` on its own line.

### Daily plans do not live here

Do **not** create a `daily-plan.md` in this repo. Plans are *per-developer*
intent, so each developer keeps their own in their own workspace
(`.workspace/daily-plans/<repo>/daily-plan.md`). A shared plan file in a shared repo is
a file two people overwrite.

<!-- git-workspace-commits:end -->
