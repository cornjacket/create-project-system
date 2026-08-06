# Task 27 — `list-tasks.sh --json`: a machine-readable task interface

**Type: feat.** `list-tasks.sh` emits only human-formatted text, so every
programmatic consumer scrapes it with `sed` and hard-codes the folder
vocabulary. Requested by `dev-workspace` (the git-workspace that manages this
repo) on 2026-08-04, after the coupling caused a real outage in its `replan`
verb. Filed here because the workspace states the problem and this repo owns the
interface.

## Why

A generated task-system is currently **readable by humans and by no one else**.
The workspace's `replan` builds each repo's daily plan from its task-system, and
to do that it must:

1. **Probe for the mount** — `find_tasks_dir()` tries `project/tasks` then
   `tasks`, because nothing in an install declares where it is
   (`replan.sh:53-62`).
2. **Verify the interface by exercising it** — `check_lister()` runs
   `--folder in-progress --depth 1 --all` and treats a non-zero exit as "this
   task-system does not speak the dialect we read" (`replan.sh:87-89`).
3. **Scrape indentation** — `sed -n 's/^    \([^ ].*\)$/\1/p'` on the human
   output, which means the four-space indent of a top-level task row is now a
   load-bearing part of this repo's public contract (`replan.sh:74-78`).
4. **Hard-code the vocabulary** — it reads `in-progress`, `backlog`, `inbox`,
   and `draft` by name and maps them onto plan sections
   (`replan.sh:124-129`).

Every one of those four is a coupling this repo could remove with one flag.

**The coupling already failed loudly.** From `replan.sh:68-73`, verbatim:

> A NON-ZERO EXIT HERE MEANS "no such folder", NOT "something broke". Generated
> task-systems differ by version — an older epic has no `inbox` — and treating
> that as fatal once took down the entire run: `set -e` plus `pipefail` killed
> the script mid-repo, and every repo after it silently lost its plan, unnamed.

That is the missing-`inbox` drift (task 25) arriving at a consumer that had no
way to distinguish a **vocabulary difference** from a **failure**. It had to
adopt a defensive rule — *absent folder means empty folder* — which necessarily
also swallows genuine errors. A consumer scraping human output cannot do better
than that, because the text carries no way to tell the two apart.

## The shape of the fix

Add `--json` to `list-tasks.sh`: same traversal, same filters, structured
output instead of formatted text. Then a consumer asks for what it wants and
branches on data rather than on indentation.

At minimum the payload must answer the four scrapes above — meaning it carries
**the folder vocabulary itself**, not just tasks filed under it. A consumer
should be able to enumerate the statuses this install has, rather than name them
from memory and hope. Per-task fields should cover what the human view already
renders: id, name, status, `Worktree`, `Tags`, `Priority`, completion state,
and parent/depth for subtasks.

Include the generator version from task 26 in the payload envelope if that has
landed — it is the field that turns "this install differs" from an inference into
a statement.

## Decisions to make

- **Whether `--json` alone is the answer, or the vocabulary needs its own
  query.** `--json` on the *lister* still requires a consumer to ask
  folder-by-folder unless the all-folders form (no `--folder`) returns the full
  set with statuses as keys. **Lean: the no-`--folder` JSON form returns every
  status folder present, including empty ones** — that single call replaces both
  the vocabulary hard-coding and the folder-by-folder loop, and makes "this
  install has no `inbox`" an explicit absence in data.
- **Schema stability.** A machine interface is a contract in a way human output
  never was; consumers will pin to it. Decide now whether the payload carries a
  schema version of its own, or leans on task 26's generator stamp. **Lean: lean
  on task 26** — a second version number to keep true is a liability, and the
  two would never disagree usefully.
- **How it's implemented.** Bash string-concatenating JSON gets quoting wrong on
  the first task title containing a quote, a backslash, or a newline — and task
  titles are free text. There is already a precedent in-tree:
  `src/scripts/task-json-helpers.sh` does all its JSON through `python3`, on the
  stated grounds that python3 is always available. **Lean: follow that
  precedent** and encode through `python3 -c 'import json,sys; ...'` rather than
  hand-rolling escapes. Note this makes `--json` python3-dependent while the
  rest of the lister is not — acceptable if the flag degrades with a clear
  error, not a mangled payload.
- **Whether the human formatter and the JSON emitter share a traversal.** Two
  code paths over the same tree will drift, and then the JSON and the text
  disagree about the same epic — worse than no JSON. **Lean: one traversal,
  two renderers.**
- **Scope of the filters.** `--tag`, `--worktree`, `--sort-priority`,
  `--group-by-worktree`, `--depth`, `--all`, `--root` all exist. Sorting and
  grouping are presentation concerns a consumer can do itself; the cheap
  position is that `--json` honours the *filters* and ignores the
  *presentation* flags. Decide explicitly, and error rather than silently
  ignore, if someone combines `--json --group-by-worktree`.

## What to do

- [ ] Resolve the decisions above.
- [ ] Implement `--json` in `src/scripts/list-tasks.sh`, sharing the existing
      traversal.
- [ ] Document the payload in `src/scripts/list-tasks.md` and mention the flag
      in `src/docs/USING.md` — a machine interface nobody can find is not an
      interface.
- [ ] Self-test coverage: valid JSON for core and all-layers installs; a task
      whose title contains a quote and a backslash round-trips intact; the
      no-`--folder` form lists every status folder present including empty ones;
      the JSON agrees with the human output for the same query.
- [ ] Golden fixtures updated for the changed `list-tasks.sh` / docs.
- [ ] Tell `dev-workspace` when it ships, so `replan.sh` can drop the `sed`
      scrape, the four hard-coded folder names, and the `check_lister` probe.
      **That repo owns that commit** — this task is done at the interface.

## Done when

`list-tasks.sh --json` returns the task data and the install's own status-folder
vocabulary, `replan` can be rewritten to read it without scraping text or
naming folders, and a task title containing shell- and JSON-hostile characters
survives the round trip.

## Related

- Task 26 (version stamp) — the same root cause from the other side. The stamp
  says *which contract*; this says *the data under it*. Both exist because a
  consumer could not tell drift from breakage.
- Task 25 (backfill status folders) — supplies the concrete drift that broke the
  scraping consumer.
- Task 20 (`project/projects/` layout) also touches `list-tasks.sh` traversal.
  If both land, do 20 first or expect a merge conflict in the same function.
