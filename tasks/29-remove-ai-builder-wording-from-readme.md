# Task 29 — Remove ai-builder wording from the generated README

**Type: doc fix.** Found on 2026-11-17 while doing task 24. The generated
README still describes the install as part of ai-builder. This is the same
layer-1 / layer-2 leakage that task 24 fixed for pipeline scripts.

## Why

`generate.sh` emits `src/docs/README.md` into every install. Two lines in it
name the repo it was extracted from, not the repo it is installed into:

- **Line 3:** "This directory contains all tasks for the ai-builder project".
- **The `main` row of the Epics table:** "Default epic. Core ai-builder
  platform work."

A plain consumer (second-brain, captains-log, any other repo) reads that its
tasks belong to ai-builder. That statement is false for every install except
create-ai-builder.

## What to do

- [ ] Replace both lines with wording that does not name a specific repo. For
      example: "all tasks for this repository" and "Default epic."
- [ ] Sweep `src/docs/` for any other `ai-builder` mention that a plain install
      would receive, and fix each one the same way.
- [ ] Refresh the golden fixtures (`bash tests/run.sh --update`). Make sure the
      diff is limited to the emitted docs.
- [ ] Run `bash self-test.sh`.

## Done when

A freshly generated install's docs do not name ai-builder, except where they
describe create-ai-builder as an example of a pipeline overlay.

**create-project-system-owned.**
