# `regression/r4.3-broken-spec-routing`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset. This branch applies a small set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger a
specific group of "routing" rules — path naming, HTTP method discipline,
operationId conventions, path parameter declaration, tags, and server URL
protocol.

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
| 1 | Path key `/resources` renamed to `/resources/` (trailing slash). | `S-225` / `path-keys-no-trailing-slash` (warn) |
| 2 | POST `/resources/` `operationId` changed from `createResource` to `CreateResource` (PascalCase). | `S-007` / `camara-operationid-casing-convention` (hint) |
| 3 | A second tag `Lookup` added to the global `tags:` array and to GET `/resources/.tags`. The GET operation now carries two tags. | `S-220` / `operation-singular-tag` (warn) |
| 4 | Path key `/resources/{resourceId}` renamed to `/resources/{id}` and the component parameter `ResourceId.name` renamed from `resourceId` to `id`. The path parameter name is now bare `id`. | `S-010` / `camara-path-param-id` (warn) |
| 5 | GET `/resources/{id}` `operationId` changed from `getResource` to `listResources` — duplicates the existing GET `/resources/.operationId`. | `S-217` / `operation-operationId-unique` (error) |
| 6 | A `requestBody:` block (`required: false`, JSON object schema) added to GET `/resources/{id}`. | `S-002` / `camara-get-no-request-body` (error) |
| 7 | DELETE `/resources/{id}.tags` changed from `[Resources]` to `[NonExistent]` — a single, undefined tag. | `S-222` / `operation-tag-defined` (warn) |
| 8 | A new `trace:` operation added to `/resources/{id}` (`operationId: traceResource`, `tags: [Resources]`, summary + description, `200` response). `trace` is not in CAMARA's allowed HTTP method set. | `S-003` / `camara-http-methods` (error) |
| 9 | A new path `/Widgets/{widgetId}` added with a single GET operation (`operationId: getWidget`, `tags: [Resources]`, summary + description, `200` response) whose `parameters:` block documents only the `x-correlator` header — **`widgetId` is not declared**. The path key is PascalCase, breaking kebab-case. | `S-008` / `camara-parameter-casing-convention` (error) + `S-227` / `path-params` (error) |
| 10 | A second entry appended to `servers:` with `url: http://insecure.example.com/sample-service`. The plain `http://` URL violates the OWASP HTTPS-only rule. | `S-306` / `owasp:api8:2023-no-server-http` (error) |
| 11 | A query parameter `Filter_id` (PascalCase + underscore) added to GET `/resources/{id}`. The schema declares `description:`, `maxLength: 64`, and `pattern:` to avoid S-009 / S-312 / S-313 cascades — only the parameter name is the intended defect. | `S-036` / `camara-parameter-name-casing-convention` (warn) |

This branch tests the 12 rules listed above (S-002, S-003, S-007, S-008,
S-010, S-036, S-217, S-220, S-222, S-225, S-227, S-306).

**S-008 fires twice** (count=2): once on `/resources/` (the trailing-slash
path also fails the kebab-case regex because the pattern requires content
between slashes) and once on `/Widgets/{widgetId}` (PascalCase first
segment). The trailing-slash path is the primary trigger for S-225; the
S-008 cascade is a structural side-effect.

### Expected cascades (observed in captured fixture)

- **S-024** / `camara-response-403` (warn) on `sample-service.yaml` — the
  new `getWidget` operation lacks a `403` response; already pinned in
  branch 1 (api-metadata).
- **S-307** / `owasp:api8:2023-define-error-responses-401` (error, count=2)
  on `sample-service.yaml` — the new `trace:` and `getWidget` operations
  both lack a `401` response; already pinned in branch 3 (error-handling).
- **S-318** / `owasp:api8:2023-define-error-validation` (warn, count=2)
  on `sample-service.yaml` — the same two new operations missing 400/422
  responses; already pinned in branch 3.
- **P-004** (error) on `sample-service.yaml` — already-pinned baseline
  cascade adjusted by the routing edits; recorded in fixture.
- **S-300** / `owasp:api1:2023-no-numeric-ids` does not fire on the
  `{id}` rename: schema stays `string/uuid` (S-300 needs `type: integer`).
- **S-204** / `no-$ref-siblings` and `oas3-schema` do not fire — the new
  operations and added requestBody use minimal valid OAS structures.
- **Baseline cascades unchanged**: S-211 (unused-component) on subscription
  files, S-313 / S-314 / S-316 hints, P-006 hint on Test_definitions.

### Cascade guardrails in the edits

- The new `Lookup` tag (edit 3) is added to the global `tags:` array so
  S-222 fires only via edit 7 (`NonExistent` undefined tag), not as a
  side-effect of multi-tag.
- The duplicate `operationId` (edit 5) reuses the exact string
  `listResources` so S-218 / `operation-operationId-valid-in-url` stays
  silent — duplicates only, no URL-unsafe characters introduced.
- The `trace:` operation (edit 8) provides minimal `summary` /
  `description` / `responses."200".description` to avoid pulling in the
  already-pinned S-006 / S-014 / S-215 description rules.
- The `/Widgets/{widgetId}` GET (edit 9) likewise carries `summary` /
  `description` / response description, and documents the `x-correlator`
  request parameter and `200` response header to keep S-039 / S-040
  (x-correlator documentation) silent — the undeclared `widgetId` is the
  single intended defect.
- Edit 1 trailing-slash on `/resources` and edit 4's `/resources/{id}`
  are distinct keys in OAS — they coexist cleanly.

### Rules excluded from this branch

The following routing-related rules were considered but excluded:

- **S-224** / `path-declarations-must-exist` — initially planned to
  co-pin alongside S-227 on `/Widgets/{widgetId}`, but Spectral's
  `path-declarations-must-exist` actually checks for empty parameter
  names (`/path/{}`) — not for missing parameter definitions. Missing
  declarations are S-227's territory only. Pinning S-224 would require
  introducing an empty `{}` parameter, which also fails `oas3-schema`
  validation; deferred.
- **S-218** / `operation-operationId-valid-in-url` — every URL-unsafe
  character that breaks S-218 also breaks S-007 camelCase, so the two
  rules are mutually exclusive without abusing the rule. Deferred.
- **S-226** / `path-not-include-query` — query-strings in path keys also
  cascade with S-008 path-casing rules. Deferred.
- **S-319** / `owasp:api7:2023-concerning-url-parameter` — info severity;
  requires introducing a query parameter (none exist in this template).
  Deferred to a future query-parameters-themed branch.
- **S-012** / `camara-reserved-words` and **S-017** /
  `camara-security-no-secrets-in-path-or-query-parameters` — both rule
  functions are dormant (logged via `console.log` instead of returning an
  `errors[]` array, see [tooling#192](https://github.com/camaraproject/tooling/issues/192)).
  Pinning either is pointless until the rule-side fix lands.

## Theme and scope

This is branch 6 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **routing** — path naming, HTTP method discipline,
operationId conventions, path parameter declaration, tags, and server URL
protocol. Branch 7 (subscriptions) is deferred pending Commonalities r4.2
event restructuring.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 → r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to
  `regression/r4.3-broken-spec-routing`, recapture the fixture,
  force-push. The `r4.1-*` branch is then deleted. HIGH risk — paths,
  operationIds, parameters, and server URLs are stable across
  Commonalities pre-releases, but the underlying OWASP rule set and
  any new path/parameter rules can shift; re-inspect edits 8, 9, 10
  after rebase.
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
    --branch-filter 'regression/r4.3-broken-spec-routing'
```

## How to recapture

After an intentional framework change:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.3-broken-spec-routing \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: routing, HTTP methods, paths, tags, servers"
```

Review `/tmp/expected.yaml`, commit to `.regression/regression-expected.yaml`,
push, and re-run without `--capture` to confirm PASS.
