# `regression/r4.3-broken-spec-info-description-missing-canonical`

Broken-spec regression fixture for the CAMARA Validation Framework ruleset.
This branch removes the canonical info.description template file so the
framework's "canonical source unavailable" path is pinned.

## Purpose

Verify **broken stays broken** for the P-031 path introduced in
[tooling#308](https://github.com/camaraproject/tooling/pull/308): when
`code/common/info-description-templates.yaml` is absent, the mandatory
info.description checks (P-026..P-030) cannot run, and the framework must say
so explicitly rather than fall silent.

The fixture records the **full** finding set this branch produces — baseline
findings inherited from `main` **plus** the new findings triggered by removing
the canonical file. Do not compare against the baseline fixture; the two
branches are independent regression pins.

## What is broken on this branch

A single surgical edit: delete `code/common/info-description-templates.yaml`.
The file's hash entry is intentionally **left in place** in
`code/common/.sync-manifest.yaml` so the file reads as a managed file missing
from the working tree — the realistic "branch behind on the common sync" state
P-031 is meant to explain.

| # | Edit | Rules expected to fire |
|---|---|---|
| 1 | Delete `code/common/info-description-templates.yaml` (manifest entry retained) | `P-021` / `check-common-cache-sync` (warn, missing managed file) and `P-031` / `check-info-description-canonical-missing` (warn, per API with mandatory templates) |

### Why both rules

The two findings are paired by design (see P-031's metadata note):

- **P-021** (`check-common-cache-sync`, warn ≥r4.2) walks `.sync-manifest.yaml`
  and reports each managed file missing from `code/common/`. The deleted file
  is still listed in the manifest, so it surfaces as a missing-file finding at
  `code/common/info-description-templates.yaml`.
- **P-031** (`check-info-description-canonical-missing`, warn ≥r4.3) fires from
  the info.description check family once the canonical catalog cannot be read,
  explaining the coverage gap that would otherwise be silent.

### Expected absences

- **No P-026..P-030 findings.** Those rules validate `info.description`
  *against* the canonical catalog; with the catalog gone the check returns
  early after emitting P-031, so none of the mandatory-content rules fire.
  (On the baseline they do not fire either — the specs are canonical — so this
  is not a delta, but it is the behavior P-031 guards.)

### Cascade guardrails

- Only `code/common/` is touched. API specs, paths, schemas, and components
  are untouched, so no S-* / Spectral rules are perturbed.
- The manifest entry is retained deliberately; removing it as well would change
  P-021's reasoning from "missing managed file" to "untracked", a different
  path this branch is not meant to pin.

## Theme and scope

This is the r4.3 broken-spec branch dedicated to the **canonical-source
unavailable** path of the mandatory info.description rule family. It
complements `regression/r4.3-broken-spec-info-description-mandatory`, which
pins P-026..P-030 with the canonical file **present** but the spec content
broken. P-031 is gated `commonalities_release >= r4.3` at the rule-metadata
layer, so this coverage was impossible on the r4.2 line.

## Lifecycle across Commonalities versions

- **Minor bump** (r4.3 → r4.4): rebase onto the updated ReleaseTest `main`,
  rename to `regression/r4.4-broken-spec-info-description-missing-canonical`,
  recapture the fixture, force-push. **LOW risk** — the predicate ("canonical
  file deleted") is preserved by rebase; only the canonical file's manifest
  hash changes, which does not affect the missing-file finding.
- **Major bump** (r4.x → r5.x): keep the last `r4.x-*` branch as permanent
  coverage for the previous major, and create a fresh `r5.x-*` branch from
  `r5.x` main.

## Tooling ref this branch tracks

Same as the other r4.3 branches: ReleaseTest's caller workflow tracks `@main`
of `camaraproject/tooling`. Every push to `main` is exercised against this
regression branch before `@v1-rc` is moved for the rest of the org.

The `tooling_ref` field in `regression-expected.yaml` records the SHA the
validation orchestrator actually resolved at capture time, read from
`context.json` in the diagnostics artifact.

## How to run

From a directory containing `validation/scripts/regression_runner.py` (the
tooling worktree or the upstream reference copy):

```bash
python3 validation/scripts/regression_runner.py \
    --repo camaraproject/ReleaseTest \
    --branch-filter 'regression/r4.3-broken-spec-info-description-missing-canonical'
```
