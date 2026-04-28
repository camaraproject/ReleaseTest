# `regression/r4.2-broken-spec-descriptions`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset. This branch applies a small set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger a
specific group of "description" rules — descriptions on operations,
parameters, properties, responses, and array items.

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
| 1 | `summary:` removed from `POST /resources` | `S-006` / `camara-operation-summary` (warn) |
| 2 | `description:` removed from `POST /resources` operation | `S-014` / `camara-routes-description` (warn) + `S-215` / `operation-description` (warn) |
| 3 | `description:` removed from `GET /resources` operation | `S-014` / `camara-routes-description` (warn) + `S-215` / `operation-description` (warn) |
| 4 | `description:` on `POST /resources` 201 response replaced with empty string `""` | `S-013` / `camara-response-descriptions` (warn) |
| 5 | `tags:` array removed from `GET /resources/{resourceId}` | `S-223` / `operation-tags` (warn) |
| 6 | `operationId:` removed from `DELETE /resources/{resourceId}` | `S-216` / `operation-operationId` (warn) |
| 7 | `description:` removed from `ResourceId` path parameter | `S-009` / `camara-parameters-descriptions` (warn) |
| 8 | `description:` removed from `Resource.properties.name` | `S-011` / `camara-properties-descriptions` (warn) |
| 9 | `createdAt` property (`type: string`, `format: date-time`, `maxLength: 40`) added to `Resource.properties` with a non-RFC-3339 description | `S-028` / `camara-datetime-rfc3339-description` (hint) |
| 10 | `validFor` property (`type: string`, `format: duration`, `maxLength: 40`) added to `Resource.properties` with a non-RFC-3339 description | `S-029` / `camara-duration-rfc3339-description` (hint) |
| 11 | `labels` array property (`maxItems: 10`, inner `items: { type: string, maxLength: 32 }`) added to `Resource.properties` — the inner items schema has no `description:` | `S-031` / `camara-array-items-description` (warn) |

This branch tests the 11 rules listed above (S-006, S-009, S-011, S-013,
S-014, S-028, S-029, S-031, S-215, S-216, S-223).

### Expected cascades

- **S-014 and S-215** both target operation-level descriptions (the first
  is CAMARA custom, the second is Spectral built-in). Both fire on edits 2
  and 3, producing a count of 2 for each rule on this file. This is the
  designed overlap — the two rules have different audiences (CAMARA
  convention vs OAS compliance).
- **S-313** (`owasp:api4:2023-string-restricted`) on `sample-service.yaml`:
  the new `labels` inner string items (`maxLength` only, no `format` /
  `pattern` / `enum`) cascade into S-313 at hint level. The baseline count
  of 2 on `sample-service.yaml` increases on this branch. Match-key
  semantics are "at least N"; the elevated count is accepted.

### Cascade guardrails in the edits

- `createdAt` and `validFor` carry `maxLength: 40` to avoid S-312
  (`string-limit`) noise — the rules targeted for S-028 / S-029 are the
  format-description rules, not the string-constraint rules.
- `labels` carries `maxItems: 10` to avoid S-309 (`array-limit`) noise.
- Empty-string response description (edit 4) preserves OAS 3.0.x schema
  validity — removing the key outright triggers `oas3-schema` hard errors
  that would mask the targeted S-013 finding.

## Theme and scope

This is branch 4 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **descriptions** — operation summaries and
descriptions, parameter / property / response descriptions, and array-item
descriptions. Description rules can reshuffle meaningfully across
Commonalities pre-releases, so this branch is a MEDIUM-risk rebase
candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 → r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to
  `regression/r4.2-broken-spec-descriptions`, recapture the fixture,
  force-push. The `r4.1-*` branch is then deleted. MEDIUM risk — a new
  Commonalities release may introduce new `format:` strings or change
  description expectations; re-inspect edits 9–11 after rebase.
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
    --branch-filter 'regression/r4.2-broken-spec-descriptions'
```

## How to recapture

After an intentional framework change:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.2-broken-spec-descriptions \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: descriptions on operations, parameters, properties, responses, array items"
```

Review `/tmp/expected.yaml`, commit to `.regression/regression-expected.yaml`,
push, and re-run without `--capture` to confirm PASS.
