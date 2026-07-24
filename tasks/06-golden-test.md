# Task 06 — Golden / reproducibility test

**Goal:** lock generator output so regressions are caught by diff.

## Steps

- [ ] Generate into a scratch dir with a fixed flag set and capture the output
      tree as a checked-in expected fixture (e.g. `tests/golden/core/` and
      `tests/golden/all-layers/`).
- [ ] Write a test that regenerates into a temp dir and diffs against the
      fixture; fails on any drift.
- [ ] Ensure determinism: no timestamps / random IDs in generated scaffolding
      (task IDs are only minted at task-creation time, not at generation time).
- [ ] Document how to refresh the fixture intentionally.

## Done when

`bash tests/run.sh` (or equivalent) generates and diffs clean against the golden
fixtures for both the core and all-layers variants.

Ref: `docs/extraction-analysis.md` §5 (idempotency & testing).
