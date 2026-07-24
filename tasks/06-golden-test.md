# Task 06 — Golden / reproducibility test  ✅ DONE

> **Result:** `tests/run.sh` diffs regenerated output against checked-in fixtures
> `tests/golden/{core,all-layers}` (75 files). Verified deterministic first (two
> independent generations byte-identical; no dates/IDs leak into scaffolding).
> Negative-tested: an injected one-line change is caught with a readable diff.
> `--update` refreshes fixtures intentionally. Folded into `self-test.sh`
> (now 55 assertions) so CI runs it on both platforms.

**Goal:** lock generator output so regressions are caught by diff.

## Steps

- [x] Captured `tests/golden/core/` (35 files) and `tests/golden/all-layers/`
      (40 files, incl. `.claude/skills/`), committed with executable bits intact.
- [x] `tests/run.sh` regenerates into a temp dir and `diff -r`s against each
      fixture; drift fails with the diff printed. Also wired into `self-test.sh`.
- [x] Determinism confirmed up front: two independent generations diffed
      byte-identical; scanned output for today's date -> 0 occurrences. (IDs/dates
      are minted only at task-creation time, never at generation time.)
- [x] `bash tests/run.sh --update` refreshes fixtures; documented in the script
      header and in the drift failure message.

## Done when

`bash tests/run.sh` (or equivalent) generates and diffs clean against the golden
fixtures for both the core and all-layers variants.

Ref: `docs/extraction-analysis.md` §5 (idempotency & testing).
