# `regression/r4.3-broken-spec-bundler-collision`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset. This branch applies a
small set of surgical edits to `code/API_definitions/sample-service.yaml` that are designed to
trigger bundler-level defects: a component-renaming collision and an unresolved `$ref`.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a rule change that silently
stops catching one of the intentional defects below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces — baseline findings inherited
from `main` **plus** the new findings triggered by the broken-spec edits. Do not compare against
the baseline fixture; the two branches are independent regression pins.

**Status: recaptured post-merge.** This fixture was first captured before tooling#412 (P-040)
merged to `main`, deliberately without a `check-component-renaming-conflict` finding, then
recaptured after the merge. The diff between the two captures was exactly the predicted one new
`P-040` finding (`warnings: 5 → 6`) and nothing else — confirming the check activates cleanly with
no side effects beyond what's already documented below.

## What is broken on this branch

All edits live in `code/API_definitions/sample-service.yaml`. The file is otherwise the unmodified
request-response sample from `main`.

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | New local `ErrorInfo` schema added under `components.schemas`, deliberately drifted from `CAMARA_common.yaml`'s `ErrorInfo` (missing `format`/`minimum`/`maximum`/`maxLength`) | `check-component-renaming-conflict` / `P-040` (warn at this API's `wip` status; error only at `public`) |
| 2 | `ResourceNotFound404`'s `allOf` redirected from the common `ErrorInfo` (`../common/CAMARA_common.yaml#/components/schemas/ErrorInfo`) to the new local one (`#/components/schemas/ErrorInfo`) | same finding as #1 — this is what makes the local name collide with the common `ErrorInfo` already pulled in transitively via the `Generic4xx` responses used throughout this file |
| 3 | New unused response `TestInvalidRefProbe` added, referencing a nonexistent component (`./sample-implicit-events.yaml#/components/schemas/DoesNotExist`) | the framework's unresolved-`$ref` finding |

Neither the component-renaming-conflict check nor unresolved-ref detection had any regression
coverage before this branch, confirmed by checking every other `regression/*` branch's fixture.
This branch closes that gap for both, since they're both bundler-level concerns rather than
spec-content rules.

Redocly reports the collision at its own resolved location — the `Generic400` response inside
`CAMARA_common.yaml` — rather than at either of this file's own edits, because that's where its
bundling walk happens to encounter the second reference to the now-colliding name. The check's own
reported finding is anchored to this file at line 1 instead, since Redocly's own location is
inconsistent across occurrences.

`TestInvalidRefProbe` is not wired to any endpoint — components are walked and bundled regardless
of whether anything under `paths:` references them.

### Side effects captured alongside the intended defects

The new local `ErrorInfo` (edit 1) is deliberately drifted from the common one by omitting
constraints, which also trips three constraint rules on its own properties: `S-310` (missing
`format` on `status`), `S-311` (missing `minimum`/`maximum` on `status`), `S-312` (missing
`maxLength` on `code` and `message`, hence `count: 2`). `TestInvalidRefProbe` also trips `S-211`
(potentially unused component) since it isn't wired to any endpoint. These are expected and
captured in the fixture alongside the two intended findings — not part of what this branch tests,
but real consequences of the edits that "broken stays broken" needs to keep pinned too.

## Theme and scope

This branch is not part of the r4.1 logical-concern-area set tracked under
[ReleaseManagement#483](https://github.com/camaraproject/ReleaseManagement/issues/483). It exists
specifically to cover the bundler component-renaming-conflict check added in
[tooling#412](https://github.com/camaraproject/tooling/pull/412), which needed new regression
coverage before merge since bundler-level defects had none.

## Tooling ref this branch tracks

Same as the baseline branch: ReleaseTest's caller workflow pins `tooling_ref_override: main` —
`main` HEAD, the project's only long-lived branch. See
[validation/docs/regression-testing.md](https://github.com/camaraproject/tooling/blob/main/validation/docs/regression-testing.md#how-tooling_ref-is-recorded)
for why the fixture's own `tooling_ref` field is typically omitted for ReleaseTest captures.

## How to run

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.3-broken-spec-bundler-collision'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.3-broken-spec-bundler-collision \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: bundler component-renaming collision + unresolved ref on sample-service.yaml"
```

Review `/tmp/expected.yaml`, commit it to `.regression/regression-expected.yaml` on this branch,
then re-run without `--capture` to verify PASS.
