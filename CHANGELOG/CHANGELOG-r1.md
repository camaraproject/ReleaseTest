# Changelog ReleaseTest

<!-- TOC:START -->
## Table of Contents
- [r1.2](#r12)
- [r1.1](#r11)
<!-- TOC:END -->

**Please be aware that the project will have frequent updates to the main branch. There are no compatibility guarantees associated with code in any branch, including main, until it has been released. For example, changes may be reverted before a release is published. For the best results, use the latest published release.**

The below sections record the changes for each API version in each release as follows:

* for an alpha release, the delta with respect to the previous release
* for the first release-candidate, all changes since the last public release
* for subsequent release-candidate(s), only the delta to the previous release-candidate
* for a public release, the consolidated changes since the previous public release

# r1.2

## Release Notes

This pre-release contains the definition and documentation of
* sample-service 0.1.0-alpha.2
* sample-service-subscriptions 0.1.0-alpha.2
* sample-implicit-events 0.1.0-alpha.2

The API definition(s) are based on
* Commonalities 0.7.0-rc.1
* Identity and Consent Management 0.5.0

## sample-service 0.1.0-alpha.2

**sample-service 0.1.0-alpha.2 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-service.yaml)

### Added

* _To be filled during release review_

### Changed

* _To be filled during release review_

### Fixed

* _To be filled during release review_

### Removed

* _To be filled during release review_

## sample-service-subscriptions 0.1.0-alpha.2

**sample-service-subscriptions 0.1.0-alpha.2 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service-subscriptions.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-service-subscriptions.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-service-subscriptions.yaml)

### Added

* _To be filled during release review_

### Changed

* _To be filled during release review_

### Fixed

* _To be filled during release review_

### Removed

* _To be filled during release review_

## sample-implicit-events 0.1.0-alpha.2

**sample-implicit-events 0.1.0-alpha.2 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-implicit-events.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.2/code/API_definitions/sample-implicit-events.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.2/code/API_definitions/sample-implicit-events.yaml)

### Added

* _To be filled during release review_

### Changed

* _To be filled during release review_

### Fixed

* _To be filled during release review_

### Removed

* _To be filled during release review_

**Full Changelog**: https://github.com/camaraproject/ReleaseTest/compare/r1.1...r1.2

# r1.1

## Release Notes

This pre-release contains the definition and documentation of
* sample-service 0.1.0-alpha.1
* sample-service-subscriptions 0.1.0-alpha.1
* sample-implicit-events 0.1.0-alpha.1

The API definition(s) are based on
* Commonalities 0.7.0-rc.1 + work in progress towards rc.2
* Identity and Consent Management 0.5.0-rc.1

## sample-service 0.1.0-alpha.1

**sample-service 0.1.0-alpha.1 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-service.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-service.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.1/code/API_definitions/sample-service.yaml)

### Added

* Initial API definition based on the Commonalities `sample-service.yaml` template (work in progress between r4.1 and r4.2, tracked in [Commonalities#606](https://github.com/camaraproject/Commonalities/pull/606))
* Resource management endpoints under `/resources`:
  * `createResource` — `POST /resources`
  * `listResources` — `GET /resources`
  * `getResource` — `GET /resources/{resourceId}`
  * `deleteResource` — `DELETE /resources/{resourceId}`
* CAMARA-aligned error model and security scheme (`openId` with standard scopes)

### Changed

* None — first release

### Fixed

* None — first release

### Removed

* None — first release

## sample-service-subscriptions 0.1.0-alpha.1

**sample-service-subscriptions 0.1.0-alpha.1 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-service-subscriptions.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-service-subscriptions.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.1/code/API_definitions/sample-service-subscriptions.yaml)

### Added

* Initial API definition based on the Commonalities `sample-service-subscriptions.yaml` (explicit subscription) template (work in progress between r4.1 and r4.2, tracked in [Commonalities#606](https://github.com/camaraproject/Commonalities/pull/606))
* Event subscription management endpoints under `/subscriptions`:
  * `createSampleServiceSubscription` — `POST /subscriptions`
  * `retrieveSampleServiceSubscriptionList` — `GET /subscriptions`
  * `retrieveSampleServiceSubscription` — `GET /subscriptions/{subscriptionId}`
  * `deleteSampleServiceSubscription` — `DELETE /subscriptions/{subscriptionId}`
* CloudEvents-based event delivery using the shared `CAMARA_event_common.yaml` schema

### Changed

* None — first release

### Fixed

* None — first release

### Removed

* None — first release

## sample-implicit-events 0.1.0-alpha.1

**sample-implicit-events 0.1.0-alpha.1 is ...**

- API definition **with inline documentation**:
  - [View it on ReDoc](https://redocly.github.io/redoc/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-implicit-events.yaml&nocors)
  - [View it on Swagger Editor](https://camaraproject.github.io/swagger-ui/?url=https://raw.githubusercontent.com/camaraproject/ReleaseTest/r1.1/code/API_definitions/sample-implicit-events.yaml)
  - OpenAPI [YAML spec file](https://github.com/camaraproject/ReleaseTest/blob/r1.1/code/API_definitions/sample-implicit-events.yaml)

### Added

* Initial API definition based on the Commonalities `sample-implicit-events.yaml` (implicit subscription) template (work in progress between r4.1 and r4.2, drafted in [Commonalities#612](https://github.com/camaraproject/Commonalities/pull/612) as a follow-up to #606 / [Commonalities#608](https://github.com/camaraproject/Commonalities/issues/608))
* Resource management endpoints under `/resources` with implicit event delivery (no explicit subscription management):
  * `createResource` — `POST /resources`
  * `listResources` — `GET /resources`
  * `getResource` — `GET /resources/{resourceId}`
  * `deleteResource` — `DELETE /resources/{resourceId}`
* CloudEvents-based notifications driven by resource lifecycle, using the shared `CAMARA_event_common.yaml` schema

### Changed

* None — first release

### Fixed

* None — first release

### Removed

* None — first release

**Full Changelog**: https://github.com/camaraproject/ReleaseTest/commits/r1.1

