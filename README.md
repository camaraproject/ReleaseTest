<a href="https://github.com/camaraproject/ReleaseTest/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# ReleaseTest

> [!CAUTION]
> This repository is used for testing the [CAMARA release management tooling](https://github.com/camaraproject/tooling) — both for manual end-to-end tests and as the target for automated regression canaries. It is not an actual API repository. After any manual tests, leave the repository in a `planned` state with an open Release Issue so the next canary run passes its pre-check.

## Scope

Test repository for end-to-end validation of the automated release workflow, and target for the Validation Regression and Release Automation Regression canaries running from [camaraproject/tooling](https://github.com/camaraproject/tooling). Carries the Commonalities sample API templates under `code/API_definitions/` as test fixtures, which exercise the full release lifecycle:

* Sync Release Issue from `release-plan.yaml`
* Create snapshot and release-review branch
* Generate CHANGELOG and README updates
* Publish release with branch protection enforced
* Post-release sync PR back to main

<!-- CAMARA:RELEASE-INFO:START -->
<!-- The following section is automatically maintained by the CAMARA project-administration tooling: https://github.com/camaraproject/project-administration -->

## Release Information

> [!NOTE]
> This repository has only pre-release versions available yet. Pre-releases are for testing and may change before public release.

* The latest pre-release is [r1.2](https://github.com/camaraproject/ReleaseTest/releases/tag/r1.2) (alpha), with the following API versions:
  * **sample-service 0.1.0-alpha.2**
  [[YAML]](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-service.yaml)  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service.yaml&nocors)  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service.yaml)
  * **sample-service-subscriptions 0.1.0-alpha.2**
  [[YAML]](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-service-subscriptions.yaml)  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service-subscriptions.yaml&nocors)  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service-subscriptions.yaml)
  * **sample-implicit-events 0.1.0-alpha.2**
  [[YAML]](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-implicit-events.yaml)  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-implicit-events.yaml&nocors)  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-implicit-events.yaml)

* For changes see [CHANGELOG](https://github.com/camaraproject/ReleaseTest/tree/main/CHANGELOG)

_The above section is automatically synchronized by CAMARA project-administration._
<!-- CAMARA:RELEASE-INFO:END -->

## Regression canary target

This repository is the target for the **Validation Regression** and **Release Automation Regression** canaries in [camaraproject/tooling](https://github.com/camaraproject/tooling), which fire on every push to the `validation-framework` branch.

State to preserve:

* **`regression/r4.1-*` branches are permanent** — each carries a `.regression/regression-expected.yaml` fixture. Do not rename or delete.
* **After any manual tests, leave the repository in a valid `planned` state with an open Release Issue** — otherwise the next RA canary run fails its pre-check.

Side-effect: each `/discard-snapshot` (canary or manual) leaves a `release-review/*-preserved` branch behind. These are harmless historical artifacts and are not swept automatically.

## Contributing

This repository is maintained by the CAMARA release management tooling team. It is not open for API contributions.