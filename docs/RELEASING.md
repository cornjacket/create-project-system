# Releasing create-project-system

A release is a **pinnable ref for the layer-1 contract**: `generate.sh` plus its
flags, plus the two behavioural promises downstream depends on — generation is
non-destructive and re-runnable, and the three golden fixtures reproduce
byte-for-byte. Consumers vendor a named tag rather than a bare SHA
(create-ai-builder does exactly this), so the tag is an interface, not a
bookmark.

## The version lives in `VERSION`

The root `VERSION` file is the single source of truth. `generate.sh` reads it
and stamps it into every generated install's `task-config.sh` as
`GENERATOR_VERSION`. It is deliberately **not** derived from `git describe`:
describe breaks when this generator is vendored as a tarball or run from a
shallow or detached checkout, and it would make generated output depend on repo
state — which the golden test's byte-identical property forbids.

Between releases `VERSION` carries a `-dev` suffix (`0.3.0-dev`), so an install
generated from an untagged working tree says so rather than impersonating the
last release.

## Procedure

1. **Working tree clean, suite green.** `bash self-test.sh` — every assertion,
   including the golden fixtures. CI must be green on both Linux and macOS.
2. **Bump `VERSION`** to the release value: drop the `-dev` suffix
   (`0.3.0-dev` → `0.3.0`).
3. **Refresh the golden fixtures**: `bash tests/run.sh --update`. In practice
   this is a no-op for a version bump alone — the harness normalises the
   `GENERATOR_VERSION` value before diffing, precisely so a release bump does
   not produce a noisy fixture diff that hides a real regression. Run it anyway
   and confirm the diff is empty.
4. **Commit** the bump, and push `main` so the tagged commit exists on the remote.
5. **Annotated tag** (never lightweight), naming the contract and any breaking
   change with its migration position:
   `git tag -a v0.3.0 -m "..."` then `git push origin v0.3.0`.
6. **Verify** both the commit and the tag are present on origin.
7. **Bump `VERSION` again** to the next `-dev` value (`0.3.1-dev` or
   `0.4.0-dev`) and commit, so `main` stops claiming to be the release.
8. **Report the SHA verbatim** to any downstream waiting to vendor it.

## What forces which bump

- **Breaking** — a generate-time flag renamed or removed, or a change to task
  content's shape that existing installs carry (the `Category` → `Worktree`
  rename in v0.2.0). Minor bump *with a stated migration position*, not a patch.
  Generate-time flags are typed once during a deliberate upgrade, so removing
  one **errors and names its replacement** rather than silently aliasing.
- **Additive** — a new flag, a new script, a new status folder in the
  vocabulary. Minor bump. Note that a status-folder addition now reaches every
  already-generated install on its next regeneration, via
  `new-epic.sh --repair`.
- **Fixes and docs** — patch bump.
