# `regression/r4.1-broken-spec-yaml-fundamentals`

Broken-spec regression fixture for the CAMARA Validation Framework r4.1
ruleset. This branch applies a set of surgical edits to
`code/API_definitions/sample-service.yaml` that are designed to trigger
YAML-level formatting rules and two basic Spectral structure rules.

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
| 1 | `openapi` version changed from `3.0.3` to `3.0.4` | `S-005` / `camara-oas-version` (error) |
| 2 | Space inserted before colon on `title` | `Y-003` / `colons` (error) |
| 3 | Inline comment `#regression` added without starting space | `Y-005` / `comments` (error) |
| 4 | `x-regression-truthy: yes` added (unquoted truthy value) | `Y-013` / `truthy` (error) |
| 5 | `x-regression-brackets: [ "a", "b" ]` added (spaces inside brackets) | `Y-002` / `brackets` (error, x2) |
| 6 | `x-regression-commas: ["a","b","c"]` added (missing spaces after commas) | `Y-004` / `commas` (error, x2) |
| 7 | Trailing spaces added to `description: Resource created` | `Y-012` / `trailing-spaces` (error) |
| 8 | Comment at wrong indentation between schema definitions | `Y-006` / `comments-indentation` (error) |
| 9 | Double space after hyphen in CreateResource `required` list | `Y-008` / `hyphens` (error) |
| 10 | Duplicate `description` key at end of CreateResource mapping | `Y-010` / `key-duplicates` (error) |
| 11 | Three blank lines between CreateResource and Resource schemas | `Y-007` / `empty-lines` (error) |
| 12 | Over-indented `required` list items in Resource (10 spaces, expected 8) | `Y-009` / `indentation` (error) |
| 13 | `x-regression-braces: { key: "value" }` added (spaces inside braces) | `Y-001` / `braces` (error, x2) |
| 14 | `InvalidTypeSchema` added with only `description` (no `type`, no combiner) | `S-016` / `camara-schema-type-check` (error) |
| 15 | Trailing newline removed at end of file | `Y-011` / `new-line-at-end-of-file` (error) |

Edit 14 also triggers `S-211` / `oas3-unused-component` (hint) because the
new schema is not referenced anywhere. This cascade is expected and
documented in the fixture.

This branch tests the 15 rules listed above plus the S-211 cascade, no more.

## Theme and scope

This is branch 2 of a planned set of 7 broken-spec branches covering the
r4.1 rule set by logical concern area. The set is tracked upstream under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

This branch's theme is **YAML fundamentals** -- yamllint formatting and
syntax rules (Y-001 through Y-013) plus OpenAPI version (`S-005`) and
schema type declaration (`S-016`). The targeted edits are additive
formatting violations and schema additions, stable across Commonalities
minor bumps, so this branch is a LOW-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.1 -> r4.2): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to `regression/r4.2-broken-spec-yaml-fundamentals`,
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
    --branch-filter 'regression/r4.1-broken-spec-yaml-fundamentals'
```
