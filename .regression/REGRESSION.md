# `regression/r4.1-broken-spec-test-files`

Broken-spec regression fixture for the CAMARA Validation Framework r4.1
ruleset. This branch exercises the Python engine (P-*) and gherkin engine
(G-*) -- engines that are otherwise unpinned by regression -- via surgical
edits to `release-plan.yaml`, two API specs, and one `.feature` file.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces --
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

Edits span four files.

### `release-plan.yaml` (1 edit)

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | Synthetic API appended with `api_name: Bad_Name_Api`, `target_api_status: draft` | `P-001` / `check-filename-kebab-case` (error) and `P-002` / `check-filename-matches-api-name` (error) |

One edit triggers two rules on the same synthetic API: the name violates
kebab-case, and the derived spec path
`code/API_definitions/Bad_Name_Api.yaml` does not exist.

Side effect: the existing `P-006` baseline finding on
`code/Test_definitions` gains one additional hit because the synthetic API
has no matching `.feature` file. The baseline pin for `P-006` stays with
`regression/r4.1-main-baseline`; this branch's fixture just records the
higher count (3 instead of 2) as part of its independent snapshot.

Per-API Python checks that load the spec file (P-003, P-004, P-005, P-011,
P-014, P-016, ...) bail early when the spec is missing, so no unintended
fallout. Spectral and yamllint are glob-driven and ignore nonexistent
files.

### `code/API_definitions/sample-service.yaml` (1 edit)

| # | Edit | Rule expected to fire |
|---|---|---|
| 2 | `servers[0].url` changed from `"{apiRoot}/sample-service/vwip"` to `"{apiRoot}/Sample-Service/v1broken"` | `P-004` / `check-server-url-version` (error) and `P-005` / `check-server-url-api-name` (error) |

One edit triggers two rules: the version segment `v1broken` does not match
the expected `vwip` (derived from `info.version: wip`), and the api-name
segment `Sample-Service` does not match the release-plan `api_name`
`sample-service` (case-sensitive comparison).

`info.version` is deliberately left at `wip` here so
`build_version_segment()` returns `vwip` and `check-server-url-version`
actually runs -- it bails early on unparseable versions.

### `code/API_definitions/sample-service-subscriptions.yaml` (1 edit)

| # | Edit | Rule expected to fire |
|---|---|---|
| 3 | `info.version` changed from `wip` to `draft` | `P-003` / `check-info-version-format` (error) |

Kept on a separate API from edit 2 so the `build_version_segment → None`
short-circuit on unparseable `info.version` does not mask `P-004` over
there.

### `code/Test_definitions/sample-service-createResource.feature` (8 edits)

| # | Edit | Rule expected to fire |
|---|---|---|
| 4 | Feature line version `vwip` → `v1.0.0` | `P-007` / `check-test-file-version` (hint) |
| 5 | Add `@wip` to the first scenario's tag line | `G-016` / `no-restricted-tags` (warn) |
| 6 | Change a Background `And` step to `Given` (consecutive `Given` keywords) | `G-025` / `use-and` (warn) |
| 7 | Indent one step with 3 spaces instead of 4 | `G-002` / `indentation` (warn) |
| 8 | Add 2+ blank lines between scenarios | `G-014` / `no-multiple-empty-lines` (warn) |
| 9 | Remove the tag line from the second scenario | `G-024` / `required-tags` (warn) |
| 10 | Blank out the second scenario's name (`Scenario:`) | `G-021` / `no-unnamed-scenarios` (warn) |
| 11 | Add trailing whitespace on one step line | `G-019` / `no-trailing-spaces` (warn) |

Edits 9 and 10 both touch the second scenario -- one removes its tag, the
other blanks its name. They fire independently.

This branch tests the 13 rules listed above (P-001, P-002, P-003, P-004,
P-005, P-007, G-002, G-014, G-016, G-019, G-021, G-024, G-025), no more.

## Deliberately out of scope

- **P-006** `check-test-files-exist` -- already pinned by
  `regression/r4.1-main-baseline`. Pinning it again on this branch would
  double-count. The +1 count delta from the synthetic API is captured in
  the fixture but ownership stays with the baseline branch.
- **P-008** `check-test-directory-exists` -- can only be triggered by
  removing `code/Test_definitions/` entirely, which would void all G-*
  coverage on the same branch. Revisit as a dedicated micro-branch if
  needed.

## Theme and scope

This is branch 8 (optional) of a planned set of 8 broken-spec branches
covering the r4.1 rule set by logical concern area. The set is tracked
upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **Python + gherkin engines** -- filename /
api-name / version / server URL checks plus gherkin quality rules. The
targeted rules are stable across Commonalities minor bumps, so this
branch is a LOW-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 -> r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to
  `regression/r4.2-broken-spec-test-files`, recapture the fixture,
  force-push. The `r4.1-*` branch is then deleted.
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
    --branch-filter 'regression/r4.1-broken-spec-test-files'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.1-broken-spec-test-files \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: P-001..P-005, P-007 + gherkin rules"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
