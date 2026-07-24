# Task 04d — Bump `actions/checkout` to v5  ✅ DONE

**Priority: low.** Not blocking anything; CI is green today.

> **Result:** bumped `actions/checkout` **and** `actions/upload-artifact` `v4 → v7`
> (v5 was the deprecation fix when this task was written, but v7 is the current
> major — v5 would have shipped two majors stale). Confirmed via the CI run that
> both legs stay green and the Node-20 deprecation annotation is gone.

## Context

The first CI run (task 04c) emitted a deprecation annotation on both legs:

> Node.js 20 is deprecated. The following actions target Node.js 20 but are being
> forced to run on Node.js 24: `actions/checkout@v4`

GitHub is currently force-running the v4 action on Node 24, so it works — but
that compatibility shim will eventually be withdrawn, at which point CI breaks
for a reason unrelated to any code change.

## Steps

- [x] Bump `actions/checkout@v4` → `@v7` in `.github/workflows/self-test.yml`
      (current major, not the now-stale v5 the title named).
- [x] Push and confirm both legs still pass and the annotation is gone.
- [x] `actions/upload-artifact` bumped `v4` → `v7` in the same pass.
- [ ] Apply the same to `create-context-hygiene` once its workflow exists
      (copied from this one — see task 04c "Reuse"). *Deferred: no workflow yet.*

## Done when

CI runs clean with no deprecation annotations on either leg.
