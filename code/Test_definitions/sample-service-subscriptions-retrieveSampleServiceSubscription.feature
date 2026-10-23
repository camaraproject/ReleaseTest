Feature: CAMARA Sample Service Subscriptions API, vwip - Operation retrieveSampleServiceSubscription

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * A subscription created by operation createSampleServiceSubscription, and an access token for the API client that created it
  #
  # References to OAS spec schemas refer to schemas specified in sample-service-subscriptions.yaml

  Background: Common retrieveSampleServiceSubscription setup
    Given an environment at "apiRoot"
    And the resource "/sample-service-subscriptions/vwip/subscriptions/{subscriptionId}"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the path parameter "subscriptionId" is set by default to the identifier of an existing subscription

  ############################ Happy Path Scenarios #############################################

  @sample_service_subscriptions_retrieveSampleServiceSubscription_01_generic_success_scenario
  Scenario: Get a subscription based on an existing subscription identifier
    Given the path parameter "subscriptionId" is set to the identifier of an existing subscription
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.id" has the same value as the path parameter "subscriptionId"

  # Some implementations may decide to not return the sinkCredential in the response (data minimization principle)
  @sample_service_subscriptions_retrieveSampleServiceSubscription_02_accesstoken_sink_credential_returned
  Scenario: Get a subscription created with ACCESSTOKEN sinkCredential
    Given the path parameter "subscriptionId" is set to the identifier of an existing subscription created with property "$.sinkCredential.credentialType" set to "ACCESSTOKEN"
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.sinkCredential.credentialType", if present, is "ACCESSTOKEN"
    And the response property "$.sinkCredential.accessToken" does not exist

  # Mainly applicable for in-band provisioning of PRIVATE_KEY_JWT
  @sample_service_subscriptions_retrieveSampleServiceSubscription_03_private_key_jwt_sink_credential_returned
  Scenario: Get a subscription created with PRIVATE_KEY_JWT sinkCredential
    Given the path parameter "subscriptionId" is set to the identifier of an existing subscription created with property "$.sinkCredential.credentialType" set to "PRIVATE_KEY_JWT"
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.sinkCredential.credentialType" is "PRIVATE_KEY_JWT"
    And the response property "$.sinkCredential.jwksUri" is set to a valid value

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_service_subscriptions_retrieveSampleServiceSubscription_400.01_invalid_subscription_id
  Scenario: Path parameter "subscriptionId" does not comply with the schema
    Given the path parameter "subscriptionId" does not comply with the schema at "#/components/schemas/SubscriptionId"
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscription_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication and authorization error scenarios

  @sample_service_subscriptions_retrieveSampleServiceSubscription_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscription_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscription_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscription_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "sample-service-subscriptions:read"
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Not found error scenarios

  @sample_service_subscriptions_retrieveSampleServiceSubscription_404.01_not_found
  Scenario: Subscription identifier unknown to the system
    Given the path parameter "subscriptionId" is set to a value not corresponding to any existing subscription
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 404
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
