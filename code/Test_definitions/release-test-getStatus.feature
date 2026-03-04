Feature: CAMARA Release Test API, vwip - Operation: getStatus

  # Input to be provided by the implementation to the tests
  # References to OAS spec schemas refer to schemas specified in /code/API_definitions/release-test.yaml
  # Implementation indications:
  # * api_root: API root of the server URL
  #
  # Testing assets:
  # * A valid access token with scope release-test:status

  Background: Common Release Test getStatus setup
    Given an environment at "apiRoot"
    And the resource "/release-test/vwip/status"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"

  # Success scenarios

  @ReleaseTest_getStatus_200.01_success
  Scenario: Get service status successfully
    When the HTTPS "GET" request is sent
    Then the response status code is 200
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" exists
    And the response property "$.status" is one of ["available"]

  # Error scenarios

  @ReleaseTest_getStatus_401.01_no_authorization
  Scenario: Error response for missing authorization header
    Given the header "Authorization" is not set
    When the HTTPS "GET" request is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" exists
