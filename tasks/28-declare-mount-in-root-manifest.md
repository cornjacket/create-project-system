# Task 28 — a root manifest that declares the mount

**Type: feat.** Task 27 removes the need to scrape a task-system's *contents*.
This removes the need to probe for its *location*. Requested by `dev-workspace`
on 2026-08-06 while planning inter-repo mail
(`create-git-workspace/docs/plans/mail/PLAN.md`). Filed here because the
workspace states the problem and this repo owns what a generated install declares
about itself.

**Design this with task 27, not after it.** They share a payload shape, a
versioning decision, and a JSON-encoding decision. Answering those twice is how
the two end up disagreeing about the same install.

## Why

Task 27's first listed coupling, verbatim:

> **Probe for the mount** — `find_tasks_dir()` tries `project/tasks` then
> `tasks`, because nothing in an install declares where it is
> (`replan.sh:53-62`).

**Task 27 does not fix that.** A consumer that cannot *find* the task-system
cannot call the lister at all, whatever flags it grows. `--json` makes the
contents legible to a consumer that has already arrived; nothing makes arrival
reliable. The probe is a guess with exactly two guesses in it, and the third
layout — or a repo that mounts somewhere deliberate — fails it silently.

**A second consumer is arriving now.** The workspace's mail effort files a task
into another repo's inbox, and its first question is the same one: where is this
repo's task-system. If it answers by re-implementing the probe, there are two
consumers guessing the same fact two ways, which is how they start disagreeing.
That is the argument for fixing it here rather than in each consumer.

The cost of *not* declaring is already on the record. From `replan.sh:68-73`,
quoted in task 27: a vocabulary difference read as a failure, `set -e` plus
`pipefail` killed the run mid-repo, and every repo after it silently lost its
plan. That was the *contents* half of the same root cause — an install that
cannot describe itself, and consumers left to infer.

## The shape of the fix

`generate.sh` writes a small JSON manifest at the **target repo root**, under a
fixed name, declaring what it just installed.

**Fixed path, fixed name, repo root — that is the entire point.** A consumer must
be able to find it while knowing nothing about this repo's layout. That is
precisely the condition the probe fails, so any answer that requires knowing
where to look is not an answer.

This rules out carrying it in `task-config.sh`, which is where task 26 puts the
generator stamp. That file lives *inside* the directory you are trying to locate.
It can hold anything a consumer reads **after** discovery; it cannot hold
discovery itself. The two are complementary, not competing.

Minimum payload: where the task-system is mounted, and enough to route an inbox
message to it (which epic, which status folder). Whether it carries more is the
first decision below.

## Decisions to make

- **Single-purpose file, or a manifest.** An `inbox.json` answers only the mail
  consumer; a `repo.json` with a `tasks` key answers `replan` too. **Lean:
  manifest.** The mount is wanted by both consumers, and a file named for one of
  them makes the other's need look like a special case. It also gives later
  cross-repo capabilities somewhere to land without another root file.
- **The filename.** Whatever is chosen is permanent in practice — consumers pin
  to it and old installs keep the old name forever. Decide it once, deliberately.
- **Schema version of its own, or lean on task 26's generator stamp.** This is
  the *same* decision task 27 is holding. **Answer both identically**, in one
  sitting. Two files disagreeing about how they are versioned is worse than
  either choice.
- **Machinery or content.** **Lean: machinery** — it describes what the generator
  just did, so a hand edit is a false statement waiting to be believed. The
  apparent counter-case (a repo with a hand-rolled task system writing one by
  hand) is not a conflict: this generator never regenerates a repo it never
  generated, so it never clobbers a hand-written manifest.
- **Repos this generator never touched.** The manifest should be a convention
  any repo can adopt, not a `create-project-system` exclusive — consumers must
  not be able to tell the difference. That means the schema cannot assume this
  repo's folder vocabulary; it declares *paths and names*, and lets `--json`
  (task 27) describe what lives under them.

## What to do

- [ ] Resolve the decisions above **jointly with task 27's** — payload shape,
      versioning, and the `python3`-vs-bash JSON encoding are shared questions.
- [ ] Emit the manifest from `generate.sh` at the target repo root.
- [ ] Preserve task 06's byte-identical reproducibility: declared values only, no
      dates and no SHAs (same constraint task 26 carries).
- [ ] Document the payload, and say plainly that the file is the *supported* way
      to locate an install — so consumers stop probing on purpose, not by
      accident.
- [ ] Coordinate the consumer side with `create-git-workspace`: `replan.sh` can
      retire `find_tasks_dir()`'s probe only behind a fallback, since installs
      predating this task carry no manifest. The probe becomes the fallback, not
      the primary.

**create-project-system-owned.**
