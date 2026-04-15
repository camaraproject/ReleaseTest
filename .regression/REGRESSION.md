# `regression/r4.1-broken-spec-api-metadata`

Broken-spec regression fixture for the CAMARA Validation Framework r4.1
ruleset. This branch applies a small set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger a
specific group of "API metadata" rules.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces —
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

All edits live in `code/API_definitions/sample-service.yaml`. The file is
otherwise the unmodified request-response sample from `main`.

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | `info.description` block deleted | `S-201` / `info-description` (warn) |
| 2 | `info.license.name` changed from `Apache 2.0` to `MIT` | `S-018` / `camara-license-name` (error) |
| 3 | `info.license.url` changed from the Apache URL to an MIT URL | `S-019` / `camara-license-url-value` (error) |
| 4 | `info.contact` block added (`name: CAMARA`) | `S-020` / `camara-no-contact` (warn) |
| 5 | Global tag and all operation references renamed `Resources` → `resources` | `S-021` / `camara-tag-name-title-case` (hint) |
| 6 | `servers[0].variables.apiRoot.default` changed from `http://localhost:9091` to `https://api.example.com` | `S-022` / `camara-api-root-default` (hint) |
| 7 | `servers[0].variables.apiRoot.description` changed away from the standard CAMARA text | `S-023` / `camara-api-root-description` (hint) |
| 8 | `"403"` response removed from the `POST /resources` operation | `S-024` / `camara-response-403` (warn) |
| 9 | Trailing slash added to the first server URL template | `S-210` / `oas3-server-trailing-slash` (warn) |

The operation tag references (4 occurrences) were renamed alongside the
global tag to avoid a cascade into `operation-tag-defined` (S-222). This
branch tests the 9 rules listed above, no more.

## Theme and scope

This is branch 1 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **API metadata** — `info`, `servers`, and `tags`.
The targeted section of the spec is stable across Commonalities minor
bumps, so this branch is a LOW-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 → r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to `regression/r4.2-broken-spec-api-metadata`,
  recapture the fixture, force-push. The `r4.1-*` branch is then deleted.
- **Major bump** (e.g. r4.3 → r5.1): keep the last `r4.x-*` branch as
  permanent regression coverage for the previous major, and create a
  fresh `r5.1-*` branch from `r5.1` main.

## Tooling ref this branch tracks

Same as the baseline branch: ReleaseTest's caller workflow hardcodes
`uses: camaraproject/tooling/.github/workflows/validation.yml@validation-framework`
— the HEAD of the `validation-framework` branch. Every push to
`validation-framework` is exercised against this regression branch before
`v1-rc` is moved for the rest of the org.

The `tooling_ref` field in `regression-expected.yaml` records the SHA the
validation orchestrator actually resolved at capture time, read from
`context.json` in the diagnostics artifact.

## How to run

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.1-broken-spec-api-metadata'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.1-broken-spec-api-metadata \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: info/license/servers/tags/403/trailing-slash edits on sample-service.yaml"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
