# Task 04c — CI: run the self-test on every change  ✅ DONE

> **Result:** `.github/workflows/self-test.yml` — runs the 54-assertion suite on
> `ubuntu-latest` **and** `macos-latest` for every push/PR, `fail-fast: false` so
> one platform's failure never hides the other's result. Failure re-runs with
> `--keep` and uploads `sandbox/` as an artifact. Badge added to README.
>
> **Not yet executed** — CI first runs when the repo is pushed.

**Goal:** actually *run* `self-test.sh` automatically. It is already CI-ready
(one command, meaningful exit code, no external deps, self-cleaning) — but
nothing invokes it, so it only protects the repo when someone remembers to.

Runs after 04b (the suite exists), before 05 (which reads diffs and wants a
known-green baseline).

## Steps

- [x] Add `.github/workflows/self-test.yml`, triggered on `push`,
      `pull_request`, and `workflow_dispatch`.
- [x] **Matrix: `ubuntu-latest` *and* `macos-latest`**, with `fail-fast: false`.
- [x] Steps: checkout → print toolchain (records *which* `sed` branch the leg
      exercised) → `bash self-test.sh`.
- [x] Fail the job on non-zero exit (default; not swallowed).
- [x] On failure, re-run with `--keep` and upload `sandbox/` as an artifact —
      necessary because the EXIT trap otherwise deletes the evidence.
- [x] Add a status badge to `README.md`.

## Why the Linux leg is the point

The scripts carry a BSD/GNU `sed` wrapper (`_sed_i` in `task-id-helpers.sh` /
`task-json-helpers.sh`) that branches on `uname`:

```sh
if [[ "$(uname)" == "Darwin" ]]; then sed -i '' "$@"; else sed -i "$@"; fi
```

Everything to date has been developed and tested **only on macOS**, so the GNU
branch is currently **untested code** — and `sed -i` is used for every README
mutation (checkbox flips, `Next-subtask-id` increments, status-field updates).
If that branch is wrong, task creation and completion break on Linux and nobody
would know. The Linux CI leg is what retires that risk.

**Revised risk assessment (measured, not assumed).** The specific hazard feared
here — `\n` in a `sed` replacement being written as a literal `n` — **does not
reproduce**: macOS `sed` expands it to a real newline, and GNU `sed` does too. The
subtask-list region was inspected byte-wise and is correct on macOS. So the
wrapper's only real job is the `-i` argument difference, which it handles
explicitly, and the residual risk is lower than this task originally claimed.

That said, the GNU path has still **never been executed**. Lower risk is not
verification — the Linux leg remains the only thing that converts "probably fine"
into evidence.

## Optional extras (decide, don't assume)

- [x] **`shellcheck` — DECIDED: deferred, not added.** A job that is permanently
      yellow/ignored trains you to ignore CI, which is worse than no job. Adopting
      it properly means pinning a severity and fixing the backlog — real work,
      not a checkbox. Revisit as its own task.
- [x] **Separate coupling-regression job — DECIDED: not added.** Already asserted
      inside `self-test.sh`; a second job would only rename the failure.

## Reuse

`create-context-hygiene` needs the same workflow (its design assumes CI for the
authoritative token counts). Once this one works, copy it — same substrate-by-copy
rule as `generate.sh`.

## Done when

Every push and PR runs the full 54-assertion suite on both Linux and macOS, and
a red run blocks with a readable failure list.
