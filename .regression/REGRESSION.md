# `regression/r4.1-broken-spec-routing`

Broken-spec regression fixture for the CAMARA Validation Framework r4.1
ruleset. This branch applies a small set of surgical edits to
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
| 9 | A new path `/Widgets/{widgetId}` added with a single GET operation (`operationId: getWidget`, `tags: [Resources]`, summary + description, `200` response) and **no `parameters:` block** declaring `widgetId`. The path key is PascalCase, breaking kebab-case. | `S-008` / `camara-parameter-casing-convention` (error) + `S-224` / `path-declarations-must-exist` (warn) + `S-227` / `path-params` (error) |
| 10 | A second entry appended to `servers:` with `url: http://insecure.example.com/sample-service`. The plain `http://` URL violates the OWASP HTTPS-only rule. | `S-306` / `owasp:api8:2023-no-server-http` (error) |

This branch tests the 12 rules listed above (S-002, S-003, S-007, S-008,
S-010, S-217, S-220, S-222, S-224, S-225, S-227, S-306).

### Expected cascades

- **S-227** also fires on GET `/resources/{id}` and DELETE
  `/resources/{id}` for the duration of the fixture if Spectral's resolver
  evaluates the inline parameter `name` before applying the component
  rename — the captured fixture is the source of truth either way. The
  primary S-227 pin remains `/Widgets/{widgetId}`.
- **S-014** / `camara-routes-description` and **S-006** /
  `camara-operation-summary` are already pinned by branch 4 (descriptions);
  the new `trace:` and `getWidget` operations include both fields, so no
  additional cascades expected from those rules. If the captured fixture
  does include them (e.g., a stricter rule resolution), document the
  count delta as a baseline-shift cascade.
- **S-204** / `no-$ref-siblings` and `oas3-schema` should not fire — the
  new operations and added requestBody use minimal valid OAS structures.
- **S-300** / `owasp:api1:2023-no-numeric-ids` does not fire on the
  `{id}` rename: schema stays `string/uuid` (S-300 needs `type: integer`).

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
  `description` / response description — the missing `parameters:`
  declaration is the single intended defect.
- Edit 1 trailing-slash on `/resources` and edit 4's `/resources/{id}`
  are distinct keys in OAS — they coexist cleanly.

### Rules excluded from this branch

The following routing-related rules were considered but excluded:

- **S-008 parameter-name casing gap** — the rule's name and Linting-rules.md
  heading suggest it validates parameter naming, but the implementation
  only validates path-key kebab-case. Design Guide §5.7.4 requires
  parameter names in lowerCamelCase, which is not currently checked. This
  branch pins the implemented behavior (path-key casing); the
  parameter-name casing gap is filed as a separate rule-side improvement.
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
  `regression/r4.2-broken-spec-routing`, recapture the fixture,
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
    --branch-filter 'regression/r4.1-broken-spec-routing'
```

## How to recapture

After an intentional framework change:

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.1-broken-spec-routing \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: routing, HTTP methods, paths, tags, servers"
```

Review `/tmp/expected.yaml`, commit to `.regression/regression-expected.yaml`,
push, and re-run without `--capture` to confirm PASS.
