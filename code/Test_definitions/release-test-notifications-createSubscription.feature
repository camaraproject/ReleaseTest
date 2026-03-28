Feature: CAMARA Release Test Notifications API, vwip - Operation: createSubscription

  # Input to be provided by the implementation to the tests
  # References to OAS spec schemas refer to schemas specified in
  # /code/API_definitions/release-test-notifications.yaml

  Background: Common createSubscription setup
    Given an environment at "apiRoot"
    And the resource "/release-test-notifications/vwip/subscriptions"
    And the header "Authorization" is set to a valid access token
    And the header "Content-Type" is set to "application/json"

  # Success scenarios

  @ReleaseTest_Notifications_createSubscription_201.01_success
  Scenario: Create subscription successfully
    Given the request body is set to a valid subscription request
    When the HTTPS "POST" request is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response property "$.id" exists
    And the response property "$.webhook.notificationUrl" exists

  # Error scenarios

  @ReleaseTest_Notifications_createSubscription_400.01_missing_webhook
  Scenario: Error response for missing webhook field
    Given the request body property "$.webhook" is not included
    When the HTTPS "POST" request is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" exists

  @ReleaseTest_Notifications_createSubscription_401.01_no_authorization
  Scenario: Error response for missing authorization header
    Given the header "Authorization" is not set
    When the HTTPS "POST" request is sent
    Then the response status code is 401
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" exists

  Scenario: Error response for invalid event type
    Given the request body property "$.eventTypes[0]" is set to "INVALID_EVENT"
    When the HTTPS "POST" request is sent
    Then the response status code is 400
    And the response property "$.code" is "INVALID_ARGUMENT"


  @ReleaseTest_Notifications_createSubscription_201.01_success
  Scenario: Create subscription with all fields
    Given the request body is set to a valid subscription request with all optional fields
    When the HTTPS "POST" request is sent
    Then the response status code is 201
    And the response property "$.id" exists
    And the response property "$.startsAt" exists
    And the response property "$.expiresAt" exists
