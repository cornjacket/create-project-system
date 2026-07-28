# Task 23 — Cut `v0.1.0`, the first pinnable release tag

**STATUS: DONE — tagged 2026-07-28.** `v0.1.0` → `c003956296d40db76f06fdda016e575486316580`,
annotated, pushed to origin.

## Why a tag exists at all

create-ai-builder is starting `15d940-target-setup-uses-generator-for-tasks`,
which makes its `target/setup-project.sh` delegate a target repo's task layer to
*this* repo's `generate.sh` instead of copying create-ai-builder's own scripts —
the copy-of-a-copy problem described in
[`docs/composition-with-create-ai-builder.md`](../docs/composition-with-create-ai-builder.md).

That design requires create-ai-builder to **pin a specific create-project-system
version** so target installs are reproducible. The pin mechanism chosen is a
**vendored snapshot**: create-ai-builder checks a copy of this generator into
`vendor/create-project-system/` at a named ref. This repo had **zero tags**, so
the pin would otherwise have been a bare SHA — unreadable at the call site and
silent about what it promises. `v0.1.0` gives the layer-1 contract a name.

## What `v0.1.0` guarantees

`generate.sh` and its flag surface, verified against the parser at
`generate.sh:53-62` — all ten flags present, no others:

`--target-repo` `--tasks-dir` `--epic` `--with-status` `--with-skill`
`--inject-claude-md` `--with-classes` `--with-projects` `--with-worktree-guard`
`--force`

Plus the two behavioral promises the downstream depends on: generation is
**non-destructive and re-runnable** (machinery overwritten, task content never
touched), and the three golden fixtures (core, all-layers, project) reproduce
byte-for-byte.

## Why `c003956` was a sound boundary

- **Rollout complete.** Task 09 merged (create-ai-builder PR #4, `7845243`), so
  every "generate into target X" task is closed. The generator demonstrably
  reproduces the subsystem it was extracted from — the strongest evidence
  available that it is fit to pin.
- **Nothing mid-flight.** The whole remaining backlog is discuss-then-resolve;
  no partial implementation was in the tree. Working tree clean at tag time.
- **Green.** `tests/run.sh` passed locally on `c003956` (all three fixtures
  byte-for-byte). `c003956` is docs-only — it touches `PLAN.md`, `daily-plan.md`
  and `tasks/09-*.md` and nothing else — so generator code is *identical* to
  `7042992`, the last commit with green CI on both Linux and macOS.

## Known forward-incompatibility (the reason a pin matters)

Two queued tasks change this contract, and both belong to a later tag:

- **19** — rename `Category` → `Worktree`: changes `--with-classes` semantics and
  the task metadata row.
- **15** — adds `--require-category`, whose name 19 would then change.

Pinning `v0.1.0` insulates create-ai-builder from that rename. When 19 lands, the
next tag is a **minor bump with a stated migration position**, not a patch —
existing generated repos carry the old field name in real task content
(create-ai-builder alone has ~134 tasks).

## Done when

- [x] `main` pushed so the tagged commit exists on the remote.
- [x] Annotated (not lightweight) tag naming the layer-1 contract.
- [x] Tag pushed; both commit and tag verified present on origin.
- [x] SHA reported verbatim for create-ai-builder subtask `0001` to vendor.
