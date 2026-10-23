Feature: CAMARA Sample Service API, vwip - Operation createResource

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * List of device identifier types which are not supported, among: phoneNumber, ipv4Address, ipv6Address, networkAccessIdentifier
  # * Whether the service is only applicable to some of the devices commercialized by the operator
  #
  # Testing assets:
  # * A device object applicable for the service, and an access token identifying it
  # * A device object for which the service is not applicable, if any
  #
  # References to OAS spec schemas refer to schemas specified in sample-service.yaml

  Background: Common createResource setup
    Given an environment at "apiRoot"
    And the resource "/sample-service/vwip/resources"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/CreateResource"

  ############################ Happy Path Scenarios #############################################

  @sample_service_createResource_01_success_device_in_request_body
  Scenario: Create a resource for a device provided in the request body
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is set to a valid testing device supported by the service
    And the request body property "$.name" is set to a valid name
    When the request "createResource" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Resource"
    And the response property "$.name" has the same value as the request body property "$.name"
    And the response property "$.device" contains a single device identifier that was included in the request

  @sample_service_createResource_02_success_device_from_access_token
  Scenario: Create a resource for the device identified by the access token
    Given the header "Authorization" is set to a valid access token identifying a device supported by the service
    And the request body property "$.device" is not included
    And the request body property "$.name" is set to a valid name
    When the request "createResource" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Resource"
    And the response property "$.name" has the same value as the request body property "$.name"
    And the response property "$.device" does not exist

  @sample_service_createResource_03_created_resource_can_be_read
  Scenario: The created resource can be read with getResource
    Given a resource created by the request "createResource" with a valid request body
    And the path parameter "resourceId" is set to the value of the response property "$.resourceId" of that request
    When the request "getResource" is sent
    Then the response status code is 200
    And the response body complies with the OAS schema at "#/components/schemas/Resource"
    And the response property "$.resourceId" has the same value as the path parameter "resourceId"
    And the response property "$.name" has the same value as the request body property "$.name" of the "createResource" request

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_service_createResource_400.01_schema_not_compliant
  Scenario Outline: Request body property does not comply with the schema
    Given the request body property "<property>" is set to <invalid_value>
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | property | invalid_value                       |
      | $.name   | a string longer than 128 characters |
      | $.name   | a number                            |
      | $.device | a string                            |

  @sample_service_createResource_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_400.03_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_400.05_missing_required_property
  Scenario: Required property "name" not included in the request body
    Given the request body property "$.name" is not included
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_400.09_request_body_strictness
  Scenario Outline: Undeclared property in request body
    Given the request body includes the property "<undeclared_property>" which is not declared in the schema at "#/components/schemas/CreateResource"
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | undeclared_property           |
      | $.undeclaredProperty          |
      | $.device.undeclaredProperty   |

  # Device error scenarios, adapted from Commonalities artifact C01-device-errors

  @sample_service_createResource_C01.01_device_empty
  Scenario: The device value is an empty object
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is set to: {}
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_C01.02_device_identifiers_not_schema_compliant
  Scenario Outline: Some device identifier value does not comply with the schema
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "<device_identifier>" does not comply with the OAS schema at "<oas_spec_schema>"
    When the request "createResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | device_identifier                | oas_spec_schema                              |
      | $.device.phoneNumber             | #/components/schemas/PhoneNumber             |
      | $.device.ipv4Address             | #/components/schemas/DeviceIpv4Address       |
      | $.device.ipv6Address             | #/components/schemas/DeviceIpv6Address       |
      | $.device.networkAccessIdentifier | #/components/schemas/NetworkAccessIdentifier |

  # This scenario may happen e.g. with 2-legged access tokens, which do not identify a single device
  @sample_service_createResource_C01.03_device_not_found
  Scenario: Some identifier cannot be matched to a device
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is compliant with the schema but does not identify a valid device
    When the request "createResource" is sent
    Then the response status code is 404
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "IDENTIFIER_NOT_FOUND"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_C01.04_unnecessary_device
  Scenario: Device not to be included when it can be deduced from the access token
    Given the header "Authorization" is set to a valid access token identifying a device
    And the request body property "$.device" is set to a valid device
    When the request "createResource" is sent
    Then the response status code is 422
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "UNNECESSARY_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_C01.05_missing_device
  Scenario: Device not included and cannot be deduced from the access token
    Given the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" is not included
    When the request "createResource" is sent
    Then the response status code is 422
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "MISSING_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_C01.06_unsupported_device
  Scenario: None of the provided device identifiers is supported by the implementation
    Given that some types of device identifiers are not supported by the implementation
    And the header "Authorization" is set to a valid access token which does not identify a single device
    And the request body property "$.device" only includes device identifiers not supported by the implementation
    When the request "createResource" is sent
    Then the response status code is 422
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "UNSUPPORTED_IDENTIFIER"
    And the response property "$.message" contains a user friendly text

  # When the service is only offered to certain types of devices or subscriptions, e.g. IoT, B2C, etc.
  @sample_service_createResource_C01.07_device_not_supported
  Scenario: Service not available for the device
    Given that the service is not available for all devices commercialized by the operator
    And a valid device, identified by the token or provided in the request body, for which the service is not applicable
    When the request "createResource" is sent
    Then the response status code is 422
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "SERVICE_NOT_APPLICABLE"
    And the response property "$.message" contains a user friendly text

  # Authentication and authorization error scenarios

  @sample_service_createResource_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "createResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "createResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "createResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_createResource_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "sample-service:resource:write"
    When the request "createResource" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Conflict error scenarios

  # Applies when the implementation does not allow two resources with the same name
  @sample_service_createResource_409.01_duplicated_resource
  Scenario: Conflict due to an existing resource with the same name
    Given a resource already exists with the same "name" as the one in the request body
    When the request "createResource" is sent
    Then the response status code is 409
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
    And the response property "$.message" contains a user friendly text

  # Rate limiting error scenarios

  # To test this scenario the environment has to be configured to reject requests reaching the threshold limit set
  @sample_service_createResource_429.01_too_many_requests
  Scenario: Request is rejected due to threshold policy
    Given the threshold of requests has been reached
    When the request "createResource" is sent
    Then the response status code is 429
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 429
    And the response property "$.code" is "TOO_MANY_REQUESTS"
    And the response property "$.message" contains a user friendly text
