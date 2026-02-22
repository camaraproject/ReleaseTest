<a href="https://github.com/camaraproject/ReleaseTest/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/ReleaseTest/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/ReleaseTest?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# ReleaseTest

> [!CAUTION]
> This repository is exclusively used for testing the [CAMARA release automation](https://github.com/camaraproject/tooling/tree/release-automation/release_automation) workflow ([tooling#72](https://github.com/camaraproject/tooling/issues/72)). It is not an actual API repository. Issues, releases, and branches may be created and deleted at any time without notice.

## Scope

Test repository for end-to-end validation of the automated release workflow. Contains a minimal API stub to exercise the full release lifecycle:

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

* The latest pre-release is [r1.1](https://github.com/camaraproject/ReleaseTest/releases/tag/r1.1) (pre-release), with the following API versions:
  * **release-test 0.1.0-alpha.1**
  [[YAML]](https://github.com/camaraproject/ReleaseTest/blob/r1.1/code/API_definitions/release-test.yaml)  [[ReDoc]](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/release-test.yaml&nocors)  [[Swagger]](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/release-test.yaml)

* For changes see [CHANGELOG](https://github.com/camaraproject/ReleaseTest/tree/main/CHANGELOG)

_The above section is automatically synchronized by CAMARA project-administration._
<!-- CAMARA:RELEASE-INFO:END -->

## Contributing

This repository is maintained by the CAMARA release management tooling team. It is not open for API contributions.