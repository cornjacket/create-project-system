# Task 04d — Bump `actions/checkout` to v5

**Priority: low.** Not blocking anything; CI is green today.

## Context

The first CI run (task 04c) emitted a deprecation annotation on both legs:

> Node.js 20 is deprecated. The following actions target Node.js 20 but are being
> forced to run on Node.js 24: `actions/checkout@v4`

GitHub is currently force-running the v4 action on Node 24, so it works — but
that compatibility shim will eventually be withdrawn, at which point CI breaks
for a reason unrelated to any code change.

## Steps

- [ ] Bump `actions/checkout@v4` → `@v5` in `.github/workflows/self-test.yml`.
- [ ] Push and confirm both legs still pass and the annotation is gone.
- [ ] Do the same in `create-context-hygiene` once its workflow exists
      (copied from this one — see task 04c "Reuse").
- [ ] Consider whether to pin other actions similarly
      (`actions/upload-artifact` is currently `@v4`; check its status too).

## Done when

CI runs clean with no deprecation annotations on either leg.
