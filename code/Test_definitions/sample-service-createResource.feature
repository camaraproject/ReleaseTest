Feature: CAMARA Sample Service API, v0.1.0-alpha.4 - Operation: createResource

  # Input to be provided by the implementation to the tests
  # References to OAS spec schemas refer to schemas specified in /code/API_definitions/sample-service.yaml
  # Implementation indications:
  # * api_root: API root of the server URL
  #
  # Testing assets:
  # * A valid access token with scope sample-service:resource:write

  Background: Common Sample Service createResource setup
    Given an environment at "apiRoot"
    And the resource "/sample-service/v0.1alpha4/resources"
    And the header "Authorization" is set to a valid access token
    And the header "Content-Type" is set to "application/json"

  # Success scenarios

  @SampleService_createResource_201.01_success
  Scenario: Create resource successfully
    Given the request body is set to a valid CreateResource request
    When the HTTPS "POST" request is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.resourceId" exists
    And the response property "$.name" exists

  # Error scenarios

  @SampleService_createResource_400.01_invalid_request
  Scenario: Error response for invalid request body
    Given the request body is set to an invalid CreateResource request
    When the HTTPS "POST" request is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" exists
