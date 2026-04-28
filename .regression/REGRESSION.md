# `regression/r4.2-broken-spec-subscriptions`

Broken-spec regression fixture for the CAMARA Validation Framework
subscription/CloudEvent rules. This branch applies a small set of surgical
edits to `code/API_definitions/sample-service-subscriptions.yaml` that are
designed to trigger a specific group of subscription-scoped rules.

All regression branches are on the **r4.2 line**. ReleaseTest `main`
advanced to `commonalities_release: r4.2` on 2026-04-24 (PR#120), which
activated the r4.2-gated rules `P-015` and `P-020`.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a
rule change that silently stops catching one of the intentional defects
below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces —
baseline findings inherited from `main` **plus** the new findings triggered
by the broken-spec edits. Do not compare against the baseline fixture; the
two branches are independent regression pins.

## What is broken on this branch

All edits live in `code/API_definitions/sample-service-subscriptions.yaml`.
The file is otherwise the unmodified explicit-subscription template from
`main`.

| # | Edit | Rule expected to fire |
|---|---|---|
| 1 | Callback `requestBody.content` key changed from `application/cloudevents+json` to `application/json` | `S-035` / `camara-notification-content-type` (warn) |
| 2 | `SubscriptionRequest.sink.pattern` changed from `^https:\/\/.+$` to `^http:\/\/.+$` (and the inline `example` updated to match the new pattern, to avoid an `oas3-valid-schema-example` cascade) | `S-034` / `camara-subscription-sink-https` (warn) |
| 3 | `ApiEventType.enum[0]` and the matching discriminator mapping key changed from `org.camaraproject...event-type1` to `org.example...event-type1` (lockstep) | `P-015` / `check-event-type-format` (error) |
| 4 | `sinkCredential` property added to the `Subscription` 2xx response schema (via `$ref` to `CAMARA_event_common.yaml#/components/schemas/SinkCredential`) | `P-016` / `check-sinkcredential-not-in-response` (error) |
| 5 | New inline `components.schemas.CloudEvent` schema added with `properties.specversion.enum: ["2.0"]` (one schema, two rules) | `P-020` / `check-cloudevent-via-ref` (warn); `S-032` / `camara-cloudevent-specversion` (hint) |
| 6 | New inline `components.schemas.Protocol` schema added with `enum: [MQTT]` | `S-033` / `camara-subscription-protocol-http` (hint) |

7 rules total. `type: object` and a `description` were added to the new
`CloudEvent` schema (and `description` to the new `Protocol` schema) to
avoid `S-016` / `camara-schema-type-check` and `S-011` /
`camara-properties-descriptions` cascades.

## Expected cascade

- `S-211` / `oas3-unused-component` (hint) on this file: count rises from
  the baseline 7 to **9** on this branch — the two new unreferenced
  schemas `CloudEvent` and `Protocol` each add one entry. Same path,
  same level, higher count; a single fixture entry covers all 9.

## Rule not covered on this branch

- **P-014** / `check-subscription-filename` (warn) — fires only when the
  explicit-subscription `api_name` does **not** end with `-subscriptions`.
  Triggering it on this branch would require a release-plan.yaml
  api_name change plus a spec-file rename, conflicting with the file's
  natural identity as the explicit-subscription template. P-014 coverage
  is deferred to a future regression branch (or to a unit test) and is
  intentionally absent from `tested_rules` for now.

## Theme and scope

This branch's theme is **subscriptions / CloudEvent / notifications**. It
is the first branch of the r4.2 broken-spec line and the eighth overall
broken-spec regression branch. The set is tracked upstream under
[ReleaseManagement#484](https://github.com/camaraproject/ReleaseManagement/issues/484)
and documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/validation-framework/validation/docs/regression-testing.md).

Rebase risk: **HIGH**. The explicit-subscription template was restructured
in Commonalities r4.2 ([PR#612](https://github.com/camaraproject/Commonalities/pull/612)),
and further evolution of the subscription/CloudEvent surface is expected
through r4.x. Future Commonalities cuts that touch the subscription
template will likely require re-deriving this branch from the latest
`sample-service-subscriptions.yaml` and recapturing the fixture, rather
than a clean rebase.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.2 → r4.3): rebase this branch onto the updated
  ReleaseTest `main`, rename the prefix to
  `regression/r4.3-broken-spec-subscriptions`, recapture the fixture,
  force-push. The `r4.2-*` branch is then deleted.
- **Major bump** (e.g. r4.x → r5.1): keep the last `r4.x-*` branch as
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
    --branch-filter 'regression/r4.2-broken-spec-subscriptions'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.2-broken-spec-subscriptions \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: subscription/CloudEvent edits on sample-service-subscriptions.yaml"
```

Review `/tmp/expected.yaml`, commit it to
`.regression/regression-expected.yaml` on this branch, then re-run without
`--capture` to verify PASS.
