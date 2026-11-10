Feature: CAMARA Sample Implicit Events API, v0.1.0-alpha.6 - Operation getResource

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * A resource created by operation createResource, and an access token for the API client that created it
  # * An access token for a different API client, without rights to access that resource
  #
  # References to OAS spec schemas refer to schemas specified in sample-implicit-events.yaml

  Background: Common getResource setup
    Given an environment at "apiRoot"
    And the resource "/sample-implicit-events/v0.1alpha6/resources/{resourceId}"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the path parameter "resourceId" is set by default to the identifier of an existing resource

  ############################ Happy Path Scenarios #############################################

  @sample_implicit_events_getResource_01_generic_success_scenario
  Scenario: Get an existing resource
    Given an existing resource created by operation "createResource"
    And the path parameter "resourceId" is set to the value of the identifier for that resource
    When the request "getResource" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Resource"
    And the response property "$.resourceId" has the same value as the path parameter "resourceId"

  # Some implementations may decide to not return the sinkCredential in the response (data minimization principle)
  @sample_implicit_events_getResource_02_sink_returned_without_secrets
  Scenario: Get a resource created with sink and sinkCredential
    Given an existing resource created by operation "createResource" with provided values for "sink" and "sinkCredential", with property "$.sinkCredential.credentialType" set to "ACCESSTOKEN"
    And the path parameter "resourceId" is set to the value of the identifier for that resource
    When the request "getResource" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/Resource"
    And the response property "$.sink" has the same value as the request body property "$.sink" of the "createResource" request
    And the response property "$.sinkCredential.credentialType", if present, is "ACCESSTOKEN"
    And the response property "$.sinkCredential.accessToken" does not exist

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_implicit_events_getResource_400.01_invalid_resource_id
  Scenario: Path parameter "resourceId" does not comply with the schema
    Given the path parameter "resourceId" does not comply with the schema at "#/components/schemas/ResourceId"
    When the request "getResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_implicit_events_getResource_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "getResource" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication and authorization error scenarios

  @sample_implicit_events_getResource_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "getResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_implicit_events_getResource_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "getResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_implicit_events_getResource_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "getResource" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_implicit_events_getResource_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "sample-implicit-events:resource:read"
    When the request "getResource" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  @sample_implicit_events_getResource_403.02_api_client_token_mismatch
  Scenario: Resource not created by the API client given in the access token
    # To test this, a token has to be obtained for a different client
    Given the header "Authorization" is set to a valid access token emitted to an API client which did not have rights to access the resource
    When the request "getResource" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Not found error scenarios

  @sample_implicit_events_getResource_404.01_not_found
  Scenario: Non-existing resourceId
    Given the path parameter "resourceId" is set to a random UUID
    When the request "getResource" is sent
    Then the response status code is 404
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
