Feature: CAMARA Sample Service Subscriptions API, v0.1.0-alpha.6 - Operation deleteSampleServiceSubscription

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Whether subscriptions are deleted synchronously (204) or asynchronously (202)
  #
  # Testing assets:
  # * A subscription created by operation createSampleServiceSubscription, with sink "callbackUrl", and an access token for the API client that created it
  #
  # References to OAS spec schemas refer to schemas specified in sample-service-subscriptions.yaml

  Background: Common deleteSampleServiceSubscription setup
    Given an environment at "apiRoot"
    And the resource "/sample-service-subscriptions/v0.1alpha6/subscriptions/{subscriptionId}"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the path parameter "subscriptionId" is set by default to the identifier of an existing subscription

  ############################ Happy Path Scenarios #############################################

  @sample_service_subscriptions_deleteSampleServiceSubscription_01_sync_deletion
  Scenario: Delete a subscription (sync deletion)
    Given that subscriptions are deleted synchronously
    And the path parameter "subscriptionId" is set to the identifier of an existing subscription
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 204
    And the response header "x-correlator" has same value as the request header "x-correlator"

  @sample_service_subscriptions_deleteSampleServiceSubscription_02_async_deletion
  Scenario: Delete a subscription (async deletion)
    Given that subscriptions are deleted asynchronously
    And the path parameter "subscriptionId" is set to the identifier of an existing subscription
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 202
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionAsync"

  @sample_service_subscriptions_deleteSampleServiceSubscription_03_subscription_ended_event
  Scenario: Receive notification for subscription-ended event on deletion
    Given the path parameter "subscriptionId" is set to the identifier of an existing subscription
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 202 or 204
    And an event notification "subscription-ended" is received at the "callbackUrl"
    And the event body complies with the OAS schema at "#/components/schemas/EventSubscriptionEnded"
    And the event body property "$.type" is "org.camaraproject.sample-service-subscriptions.v0.subscription-ended"
    And the event body property "$.data.terminationReason" is "SUBSCRIPTION_DELETED"
    And the event body property "$.data.subscriptionId" has the same value as the path parameter "subscriptionId"

  @sample_service_subscriptions_deleteSampleServiceSubscription_04_deleted_subscription_cannot_be_read
  Scenario: A deleted subscription can no longer be read
    Given a subscription deleted by the request "deleteSampleServiceSubscription"
    And the path parameter "subscriptionId" is set to the identifier of that subscription
    When the request "retrieveSampleServiceSubscription" is sent
    Then the response status code is 404
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_service_subscriptions_deleteSampleServiceSubscription_400.01_invalid_subscription_id
  Scenario: Path parameter "subscriptionId" does not comply with the schema
    Given the path parameter "subscriptionId" does not comply with the schema at "#/components/schemas/SubscriptionId"
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_deleteSampleServiceSubscription_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication and authorization error scenarios

  @sample_service_subscriptions_deleteSampleServiceSubscription_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_deleteSampleServiceSubscription_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_deleteSampleServiceSubscription_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_deleteSampleServiceSubscription_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "sample-service-subscriptions:delete"
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Not found error scenarios

  @sample_service_subscriptions_deleteSampleServiceSubscription_404.01_not_found
  Scenario: Subscription identifier unknown to the system
    Given the path parameter "subscriptionId" is set to a value not corresponding to any existing subscription
    When the request "deleteSampleServiceSubscription" is sent
    Then the response status code is 404
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 404
    And the response property "$.code" is "NOT_FOUND"
    And the response property "$.message" contains a user friendly text
