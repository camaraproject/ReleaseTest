Feature: CAMARA Sample Service Subscriptions API, v0.1.0-alpha.6 - Operation retrieveSampleServiceSubscriptionList

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  #
  # Testing assets:
  # * An API client able to create subscriptions with operation createSampleServiceSubscription
  # * An API client without any subscription created
  #
  # References to OAS spec schemas refer to schemas specified in sample-service-subscriptions.yaml

  Background: Common retrieveSampleServiceSubscriptionList setup
    Given an environment at "apiRoot"
    And the resource "/sample-service-subscriptions/v0.1alpha6/subscriptions"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  ############################ Happy Path Scenarios #############################################

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_01_no_subscriptions
  Scenario: Get a list of subscriptions when no subscriptions are available
    Given an API client without subscriptions created
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionList"
    And the response property "$.subscriptions" is an empty array

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_02_existing_subscriptions
  Scenario: Get a list of subscriptions
    Given an API client with subscriptions created by operation "createSampleServiceSubscription"
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionList"
    And each item in the response property "$.subscriptions" complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_03_pagination_default_values
  Scenario: Subscription list pagination with default values for page and perPage
    Given an API client with more than 20 subscriptions created
    And the query parameters "page" and "perPage" are not included
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Link" contains a link to the next page with rel="next"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionList"
    And the response property "$.subscriptions" has 20 items
    And the response property "$.pagination.page" is 1
    And the response property "$.pagination.perPage" is 20

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_04_pagination_middle_page
  Scenario: Subscription list pagination fetching a middle page of the list
    Given an API client with more than 40 subscriptions created
    And the query parameter "page" is set to 2
    And the query parameter "perPage" is set to 20
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Link" contains a link to the previous page with rel="prev" and a link to the next page with rel="next"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionList"
    And the response property "$.subscriptions" has 20 items
    And the response property "$.pagination.page" is 2
    And the response property "$.pagination.perPage" is 20
    And the response property "$.pagination.totalCount", if present, is greater than 40

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_400.14_invalid_pagination_parameter
  Scenario Outline: Invalid value for a pagination query parameter
    Given the query parameter "<parameter>" is set to <invalid_value>
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | parameter | invalid_value                       |
      | page      | a value less than 1                 |
      | perPage   | a value outside the range [1-100]   |

  # Authentication and authorization error scenarios

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_retrieveSampleServiceSubscriptionList_403.01_missing_access_token_scope
  Scenario: Missing access token scope
    Given the header "Authorization" is set to an access token that does not include scope "sample-service-subscriptions:read"
    When the request "retrieveSampleServiceSubscriptionList" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text
