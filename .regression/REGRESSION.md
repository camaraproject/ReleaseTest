# `regression/r4.1-broken-spec-error-handling`

Broken-spec regression fixture for the CAMARA Validation Framework r4.1
ruleset. This branch applies a set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger
error-handling rules: error code format checks, success response
requirements, and secured/validation error response requirements.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces --
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

All edits live in `code/API_definitions/sample-service.yaml`. The file is
otherwise the unmodified request-response sample from `main`.

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | `NOT_FOUND` error code changed to `"404"` (purely numeric) | `S-025` / `camara-error-code-not-numeric` (error) |
| 2 | `IDENTIFIER_NOT_FOUND` error code changed to `identifier_not_found` (lowercase) | `S-026` / `camara-error-code-screaming-snake-case` (warn) |
| 3 | New error code `"SAMPLE_SERVICE.not-found"` added (bad dot format) | `S-027` / `camara-error-code-api-specific-format` (warn) |
| 4 | `"204"` success response removed from DELETE operation | `S-221` / `operation-success-response` (warn) |
| 5 | `"401"` response removed from GET `/resources` operation | `S-307` / `owasp:api8:2023-define-error-responses-401` (error) |
| 6 | `"400"` and `"422"` responses removed from POST `/resources` operation | `S-318` / `owasp:api8:2023-define-error-validation` (warn) |

Example values in `ResourceNotFound404` were updated to match the changed
enum values (edits 1 and 2) to avoid cascading into `oas3-valid-media-example`.

Edit 1 also triggers `S-026` (warn) because `"404"` does not match
SCREAMING_SNAKE_CASE. Edit 3 also triggers `S-026` (warn) because
`not-found` in the dot-format code is not SCREAMING_SNAKE_CASE. These
cascades are expected and documented in the fixture.

This branch tests the 6 rules listed above plus the S-026 cascades, no more.

## Theme and scope

This is branch 3 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **Error handling** -- error code format validation,
success response existence, and secured/validation error response
requirements. The targeted edits modify well-defined error-response
sections stable across Commonalities minor bumps, so this branch is a
LOW-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 -> r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to `regression/r4.2-broken-spec-error-handling`,
  recapture the fixture, force-push. The `r4.1-*` branch is then deleted.
- **Major bump** (e.g. r4.3 -> r5.1): keep the last `r4.x-*` branch as
  permanent regression coverage for the previous major, and create a
  fresh `r5.1-*` branch from `r5.1` main.

## Tooling ref this branch tracks

Same as the baseline branch: ReleaseTest's caller workflow hardcodes
`uses: camaraproject/tooling/.github/workflows/validation.yml@validation-framework`
-- the HEAD of the `validation-framework` branch. Every push to
`validation-framework` is exercised against this regression branch before
`v1-rc` is moved for the rest of the org.

The `tooling_ref` field in `regression-expected.yaml` records the SHA the
validation orchestrator actually resolved at capture time, read from
`context.json` in the diagnostics artifact.

## How to run

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.1-broken-spec-error-handling'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.1-broken-spec-error-handling \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: error-code/success-response/401/validation edits on sample-service.yaml"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
