# `regression/r4.3-broken-spec-info-description-mandatory`

Broken-spec regression fixture for the CAMARA Validation Framework
ruleset. This branch applies surgical edits across two API specs that are
designed to trigger the five mandatory `info.description` content rules
introduced in r4.3 (P-026..P-030).

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces —
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

Five rules in this family check `info.description` against
`code/common/info-description-templates.yaml` (synced from Commonalities).
P-030 (folded-scalar) collapses all line-anchored markers within the same
file's `info.description`, which silences P-026..P-029 on that file —
therefore P-030 cannot share a spec with the P-026..P-029 demonstrations.

The check is API-scoped (one invocation per `release-plan.yaml` API
entry), so edits on `sample-service.yaml` do not interact with edits on
`sample-implicit-events.yaml`.

### `code/API_definitions/sample-service.yaml` (description style `|`)

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | Delete the `request-body-strictness` BEGIN/END block | `P-026` / `check-info-description-mandatory-missing` (hint at `alpha`) |
| 2 | In `additional-error-responses` paragraph 1: insert "CAMARA" into "The list of error codes" | `P-027` / `check-info-description-mandatory-drift` (hint at `alpha`) |
| 3 | Append a second `authorization-and-authentication` BEGIN/END pair with placeholder body | `P-028` / `check-info-description-mandatory-duplicate` (error) |
| 4 | Append a `wrong-template-name` BEGIN/END pair with placeholder body | `P-029` / `check-info-description-mandatory-unknown-template-name` (warn) |

### `code/API_definitions/sample-implicit-events.yaml` (description style `>`)

| # | Edit | Rule expected to fire |
|---|---|---|
| 5 | Change `description: \|` to `description: >` on `info.description` | `P-030` / `check-info-description-folded-scalar` (warn) |

### Expected cascades

- **P-030 converts the four present templates on `sample-implicit-events.yaml`
  into drift findings.** Folded scalar style joins consecutive non-blank
  source lines with a space, so each BEGIN marker fuses with the heading
  line directly below it (`# Authorization and authentication` etc.) and
  each END marker fuses with the final paragraph above it. The marker
  regex `_MARKER_RE` uses `.search()`, so the markers are still detected
  even when content trails / leads on the same line — but the body that
  `_extract_markers` returns loses the heading and the final paragraph
  (both are now part of the marker lines, which are excluded from body
  capture). The paragraph-normalised diff then trips P-027 on all four
  wrapped templates in the file (`identifying-device-from-access-token`,
  `authorization-and-authentication`, `additional-error-responses`,
  `request-body-strictness`) → 4 P-027 findings.
- **No cascaded P-026 missing findings on `sample-implicit-events.yaml`.**
  All three universal templates are still detected as present (just
  drifted), so the missing-template check does not fire.
- **P-027 only fires once for `additional-error-responses` on
  `sample-service.yaml`.** The first occurrence of
  `authorization-and-authentication` is unchanged from canonical, so the
  drift check (which only inspects `occurrences[0]`) reports no drift
  for that template even though edit 3 adds a non-canonical second
  occurrence.

### Design-doc note

The design doc claims P-030 "silences" the other four rules. The
implementation does not silence — it converts "missing" into "drift" on
every present template (see cascade above). The signal is preserved
(broken markers still produce findings) but the rule attribution shifts.
This is the actual observed behavior the regression fixture pins; flag
for design-doc §5.1 amendment.

### Cascade guardrails in the edits

- The duplicate and unknown-template bodies are minimal placeholder text
  (no headings, no Markdown formatting) to avoid surfacing as Markdown
  rendering issues in published API documentation.
- Edits 1, 3, 4 stay inside `info.description`; the rest of
  `sample-service.yaml` (paths, schemas, components) is untouched, so no
  S-* / Spectral rules are perturbed.
- Edit 5 changes only the scalar indicator (`|` → `>`); the spec stays
  syntactically valid OAS 3.0.x and Spectral processes it normally.

## Theme and scope

This is the first broken-spec branch on the **r4.3** line dedicated to
the mandatory `info.description` rule family (P-026..P-030). The rules
themselves are gated `commonalities_release >= r4.3` at the rule-metadata
layer, so this coverage was impossible on the r4.2 line.

Tracking: [ReleaseManagement#484](https://github.com/camaraproject/ReleaseManagement/issues/484).

## Lifecycle across Commonalities versions

- **Minor bump** (r4.3 → r4.4): rebase this branch onto the updated
  ReleaseTest `main`, rename to `regression/r4.4-broken-spec-info-description-mandatory`,
  recapture the fixture, force-push. **MEDIUM risk** — any new mandatory
  template added in r4.4 will cascade into edit 5's P-026 count on
  `sample-implicit-events.yaml` (one extra per new universal template).
  Re-inspect edits 1-4 against the updated canonical text — drift on the
  unchanged first paragraph of `additional-error-responses` is the
  fixture's signal that paragraph normalisation still works.
- **Major bump** (r4.x → r5.x): keep the last `r4.x-*` branch as
  permanent regression coverage for the previous major, and create a
  fresh `r5.x-*` branch from `r5.x` main.

## Tooling ref this branch tracks

Same as the other r4.3 branches: ReleaseTest's caller workflow tracks
`@main` of `camaraproject/tooling`. Every push to `main` is exercised
against this regression branch before `@v1-rc` is moved for the rest of
the org.

The `tooling_ref` field in `regression-expected.yaml` records the SHA the
validation orchestrator actually resolved at capture time, read from
`context.json` in the diagnostics artifact.

## How to run

From a directory containing `validation/scripts/regression_runner.py`
(the tooling worktree or the upstream reference copy):

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.3-broken-spec-info-description-mandatory'
```
