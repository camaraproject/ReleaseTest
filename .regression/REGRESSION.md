# `regression/r4.2-main-baseline`

Baseline regression fixture for the CAMARA Validation Framework ruleset,
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

## Tooling ref this branch tracks

ReleaseTest's caller workflow hardcodes
`uses: camaraproject/tooling/.github/workflows/validation.yml@validation-framework`
— that is, the **HEAD of the `validation-framework` branch**, not the
`v1-rc` tag. This is intentional: ReleaseTest is the canary repo for the
validation framework. Every push to `validation-framework` is exercised
against this regression branch *before* `v1-rc` is moved for the rest of
the org.

The `tooling_ref` field in `regression-expected.yaml` records the SHA that
the validation orchestrator actually resolved at capture time — read from
`context.json` in the diagnostics artifact. It will match the
`validation-framework` HEAD that GitHub resolved when the dispatched run
started, which may or may not coincide with `v1-rc`.

If `validation-framework` HEAD advances and starts producing different
findings against the same specs:

- **Intended change** (new rule, severity adjustment, etc.) → recapture
  the fixture: run the regression runner in `--capture` mode, review the
  new finding set, commit the updated `regression-expected.yaml`.
- **Unintended regression** → fix the code on `validation-framework`
  before merging, then re-run.

## How to run

From the tooling worktree:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.2-main-baseline'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.2-main-baseline \
    --out /tmp/expected.yaml \
    --capture-description "baseline - ReleaseTest main, unmodified"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
