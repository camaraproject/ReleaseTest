# `regression/r4.2-broken-spec-schema-constraints`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset. This branch applies a small set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger a
specific group of "schema constraints" rules — required-properties
integrity, OWASP numeric-id avoidance, OWASP resource-consumption limits,
and OWASP operation-security restrictions.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces —
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

All edits live in `code/API_definitions/sample-service.yaml`. No edits to
`code/common/**` — the common schemas are owned by the baseline fixture
and collisions are avoided by design.

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | `ResourceId` schema changed from `type: string, format: uuid, maxLength: 36` to `type: integer, format: int64, minimum: 1, maximum: 999999`. The path parameter `resourceId` (name matches the `/(_id\|Id\|-id)$/` heuristic) now carries an integer schema. | `S-037` / `camara-no-numeric-resource-ids` (error) |
| 2 | `email` added to `CreateResource.required` without a matching entry in `properties` | `S-030` / `camara-required-properties-exist` (warn) |
| 3 | `maxItems: 1000` removed from the inline array schema in `GET /resources` 200 response | `S-309` / `owasp:api4:2023-array-limit` (warn) |
| 4 | `quota: { type: integer, description: ... }` added to `CreateResource.properties` — no `format:` | `S-310` / `owasp:api4:2023-integer-format` (warn) |
| 5 | `priority: { type: integer, format: int32, description: ... }` added to `CreateResource.properties` — no `minimum` / `maximum` | `S-311` / `owasp:api4:2023-integer-limit-legacy` (warn) |
| 6 | `label: { type: string, description: ... }` added to `CreateResource.properties` — no `maxLength` / `enum` / `const` | `S-312` / `owasp:api4:2023-string-limit` (warn) |
| 7 | Top-level `security:` block removed, leaving every operation without an inherited security scope | `S-303` / `owasp:api2:2023-write-restricted` (error, POST + DELETE) + `S-308` / `owasp:api2:2023-read-restricted` (warn, GET + GET + GET) |
| 8 | New path `/list` (standalone reserved word as path segment) with a minimal GET operation. | `S-012` / `camara-reserved-words` (warn) |
| 9 | Query parameter `phoneNumber` added to GET `/resources/{resourceId}`. Schema declares description, maxLength, pattern to keep S-009 / S-312 / S-313 silent. | `S-017` / `camara-security-no-secrets-in-path-or-query-parameters` (warn) |

This branch tests the 10 rules listed above (S-012, S-017, S-030, S-037,
S-303, S-308, S-309, S-310, S-311, S-312).

### Expected cascades

- **S-311** (`owasp:api4:2023-integer-limit-legacy`): fires on both the
  new `quota` property (no format / no min-max) and the `priority`
  property (format set but no min-max). Count = 2.
- **S-313** (`owasp:api4:2023-string-restricted`) on `sample-service.yaml`:
  the new `label` property (`type: string` without `format` / `pattern` /
  `enum`) increments the baseline S-313 count on this file. The post-filter
  keeps S-313 at hint level. Accepted.
- **Edit 7 count**: S-303 fires on every state-mutating operation that
  lacks a write-scope security context. POST `/resources` and DELETE
  `/resources/{resourceId}` both fire, giving count = 2. S-308 fires on
  GET operations without a read scope — GET `/resources`, GET
  `/resources/{resourceId}`, and the new GET `/list` (edit 8), giving
  count = 3. Both counts reflect the scope absence created by edit 7
  amplified by the new GET introduced in edit 8.

### Cascade guardrails in the edits

- Integer `ResourceId` (edit 1) keeps `format: int64` and `minimum` /
  `maximum` present to avoid cascading into S-310 / S-311 on the path
  parameter schema.
- `priority` (edit 5) keeps `format: int32` present to keep the S-311
  finding clean from S-310 noise.

## Theme and scope

This is branch 5 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **schema constraints** — required-properties
integrity, OWASP numeric-id avoidance, OWASP resource-consumption limits
(array / integer / string), and operation security. The rule surface is
more sensitive to Commonalities pre-release evolution than metadata /
error-handling, so this branch is a MEDIUM-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 → r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to
  `regression/r4.2-broken-spec-schema-constraints`, recapture the fixture,
  force-push. The `r4.1-*` branch is then deleted. MEDIUM risk — OWASP
  thresholds and required-properties semantics can shift across
  Commonalities pre-releases; re-inspect edits 1, 3, 4–6, 7 after rebase.
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
    --branch-filter 'regression/r4.2-broken-spec-schema-constraints'
```

## How to recapture

After an intentional framework change:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.2-broken-spec-schema-constraints \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: schema constraints, OWASP limits, operation security"
```

Review `/tmp/expected.yaml`, commit to `.regression/regression-expected.yaml`,
push, and re-run without `--capture` to confirm PASS.
