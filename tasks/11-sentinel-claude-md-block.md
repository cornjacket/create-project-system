# Task 11 — Sentinel-wrap the CLAUDE.md task-tracking block  ✅ DONE

> **Result:** the kernel snippet is now wrapped in
> `<!-- task-system:begin -->` / `<!-- task-system:end -->`, and
> `--inject-claude-md` replaces in place between markers (append if absent).
> Self-test 66 assertions green (+5 in section 6: markers present, single begin
> marker after double-inject, drifted block refreshed in place, outside-content
> preserved). Golden fixtures unchanged (they don't use `--inject`).

**Blocks task 07's `CLAUDE.md` step.** Do this first so the block placed into
second-brain is future-updatable from day one.

## Problem

The emitted `## Task tracking` kernel has **no delimiters**. `generate.sh`'s
`--inject-claude-md` only greps for the heading `^## Task tracking` — enough to
detect presence, but it **cannot update the block in place** (no end marker) and
would duplicate if the heading were renamed. This is a one-shot injection.

The fix mirrors a convention already used in `project-status/setup-new-repo.sh`:
a `<!-- name:begin -->` / `<!-- name:end -->` marker pair enabling replace-in-place.

## Steps

- [x] Wrap `src/snippets/claude-md.snippet.md` in
      `<!-- task-system:begin -->` … `<!-- task-system:end -->` (markers inline in
      the template, so both the printed and injected paths carry them).
- [x] `generate.sh` `--inject-claude-md`: if the begin marker is present, replace
      everything between begin/end (inclusive) with the current rendered snippet;
      otherwise append. Makes injection idempotent AND updatable.
- [x] Update self-test section 6: assert both markers present, exactly one begin
      marker after double-inject (no duplication), and that a drifted block is
      refreshed in place on re-inject.
- [x] Run self-test + golden; confirm green. (Goldens don't use `--inject`, so no
      fixture drift expected — but verify.)

## Done when

The injected/printed block is delimited by `task-system:begin/end` markers and
re-running `--inject-claude-md` refreshes it in place. All tests green.
