# `regression/r4.3-broken-spec-security-scheme`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset. This branch applies
surgical edits to the `components.securitySchemes` block and one `security` requirement of the
three sample API definitions so that the security scheme rules S-041, S-042 and S-043 fire.

## Purpose

This branch exists so the runner can verify **broken stays broken**: a rule change that silently
stops catching one of the intentional defects below shows up as a FAIL (missing finding).

The fixture records the **full** finding set this branch produces -- baseline findings inherited
from `main` **plus** the new findings triggered by the broken-spec edits. Do not compare against the
baseline fixture; the two branches are independent regression pins.

## What is broken on this branch

| # | File | Edit | Rule expected to fire |
|---|---|---|---|
| 1 | `sample-service.yaml` | `openId` scheme replaced by an inline `type: oauth2` scheme with a `clientCredentials` flow (the `$ref` to `CAMARA_common.yaml` is removed) | `S-042` / `camara-security-openid-scheme` (error): `openId` has type oauth2 |
| 2 | `sample-service.yaml` | GET `/resources/{resourceId}` gets an operation-level `security` requirement naming `openIdX`, which no scheme defines | `S-041` / `camara-security-requirement-defined` (error) |
| 3 | `sample-service-subscriptions.yaml` | `components.securitySchemes` removed entirely | `S-041` (error) once per `security` requirement that names `openId` (4 operations) or `notificationsBearerAuth` (1 callback); `S-042` (error): secured API without an `openId` scheme |
| 4 | `sample-implicit-events.yaml` | `openId` scheme replaced by an inline `type: openIdConnect` scheme with `openIdConnectUrl: http://example.com/openid` | `S-043` / `camara-security-openid-url` (warn): not HTTPS, no `/.well-known/openid-configuration` suffix |

Everything else is the unmodified r4.4 sample set from `main`. The `notificationsBearerAuth`
`$ref` in `sample-implicit-events.yaml` stays in place so the callback requirement there remains
defined; only the subscriptions file exercises the undefined-callback-scheme case.

Edit 1 also triggers `S-302` / `owasp:api2:2023-short-lived-access-tokens` (error), because an
`oauth2` scheme without a `refreshUrl` is read as issuing never-expiring tokens. This cascade is
inherent to the oauth2 shape and is expected and documented in the fixture. Both inline schemes
carry a `description` so `S-011` does not cascade.

This branch tests the three rules listed above plus the S-302 cascade, no more. Edit 1 keeps the
scope names of the original `security` block so no other rule is affected by the scheme swap.

## Theme and scope

This is branch 9 of the broken-spec set documented in
[`validation/docs/regression-testing.md`](https://github.com/camaraproject/tooling/blob/main/validation/docs/regression-testing.md).
The theme is **Security scheme** -- the shape of `components.securitySchemes` and the names used in
`security` requirements. The edits touch a small, stable block of each file, so this branch is a
LOW-risk rebase candidate.

## Lifecycle across Commonalities versions

- **Minor bump** (e.g. r4.3 -> r4.4): rebase this branch onto the updated ReleaseTest `main`,
  rename the prefix, recapture the fixture, force-push. The old branch is then deleted.
- **Major bump** (e.g. r4.x -> r5.1): keep the last `r4.x-*` branch as permanent regression
  coverage for the previous major, and create a fresh `r5.1-*` branch from `r5.1` main.

## Tooling ref this branch tracks

Same as the other regression branches: ReleaseTest's caller workflow uses
`camaraproject/tooling/.github/workflows/validation.yml@main` with `tooling_ref_override: main`.
Every push to tooling `main` is exercised against this branch before `v1-rc` is moved for the rest
of the organisation.

## How to run

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.3-broken-spec-security-scheme'
```

Expected: `PASS: 1/1 branches`.

## How to recapture

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --capture regression/r4.3-broken-spec-security-scheme \
    --out /tmp/expected.yaml \
    --capture-description "broken-spec: security scheme shape and undefined requirement names (S-041..S-043); r4.3 line"
```

Review `/tmp/expected.yaml`, commit it to `.regression/regression-expected.yaml` on this branch,
then re-run without `--capture` to verify PASS.
