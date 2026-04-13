# `regression/r4.1-main-baseline`

Baseline regression fixture for the CAMARA Validation Framework r4.1 ruleset,
pinned to a known-good state of `camaraproject/ReleaseTest` main.

## Purpose

This branch is a snapshot of `main` at the time of capture. Its
`regression-expected.yaml` records every finding the Validation Framework
produces on that snapshot, so that:

- **Rule regressions** — an engine or rule change that starts producing
  different findings against the same specs shows up as a FAIL.
- **Stable-state verification** — the runner confirms "clean stays clean"
  after any framework change.

No specs on this branch are intentionally broken. All samples are the
unmodified `main` content.

## Pinned tooling ref

The Validation Framework caller workflow hardcodes
`uses: camaraproject/tooling/.github/workflows/validation.yml@v1-rc` and does
not forward `workflow_dispatch` inputs, so OIDC inside the reusable locks to
whatever commit `v1-rc` currently points at. Local dispatchers cannot
override this.

At last capture (see `captured_at` in `regression-expected.yaml`), `v1-rc`
resolved to commit SHA recorded under the `tooling_ref` field. If `v1-rc`
moves, this branch must be recaptured — run the regression runner in
capture mode and commit the updated fixture.

## How to run

From the tooling worktree:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.1-main-baseline'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.1-main-baseline \
    --out /tmp/expected.yaml \
    --capture-description "baseline - ReleaseTest main, unmodified"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
