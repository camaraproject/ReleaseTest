Feature: CAMARA Sample Service Subscriptions API, vwip - Operation createSampleServiceSubscription

  # Input to be provided by the implementation to the tester
  #
  # Implementation indications:
  # * apiRoot: API root of the server URL
  # * Whether subscriptions are created synchronously (201) or asynchronously (202)
  # * Whether the implementation supports initial events (config.initialEvent)
  # * Whether PRIVATE_KEY_JWT sink credentials are supported, and with which provisioning (out-of-band or in-band)
  #
  # Testing assets:
  # * A sink URL, identified as "callbackUrl", which receives event notifications, and an access token accepted by it
  # * A subscription detail valid for the event types defined in ApiEventType
  #
  # References to OAS spec schemas refer to schemas specified in sample-service-subscriptions.yaml

  Background: Common createSampleServiceSubscription setup
    Given an environment at "apiRoot"
    And the resource "/sample-service-subscriptions/vwip/subscriptions"
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" complies with the schema at "#/components/schemas/XCorrelator"
    And the request body is set by default to a request body compliant with the schema at "#/components/schemas/HTTPSubscriptionRequest"
    And the request body property "$.sink" is set by default to the "callbackUrl"
    And the request body property "$.protocol" is set by default to "HTTP"

  ############################ Happy Path Scenarios #############################################

  # Some implementations may only support asynchronous subscription creation
  @sample_service_subscriptions_createSampleServiceSubscription_01_sync_creation
  Scenario: Create subscription (sync creation)
    Given that subscriptions are created synchronously
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.types" has the same value as the request body property "$.types"
    And the response property "$.sink" has the same value as the request body property "$.sink"

  # Some implementations may only support synchronous subscription creation
  @sample_service_subscriptions_createSampleServiceSubscription_02_async_creation
  Scenario: Create subscription (async creation)
    Given that subscriptions are created asynchronously
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 202
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/SubscriptionAsync"

  @sample_service_subscriptions_createSampleServiceSubscription_03_subscription_started_event
  Scenario: Receive notification for subscription-started event on creation
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201 or 202
    And an event notification "subscription-started" is received at the "callbackUrl"
    And the event body complies with the OAS schema at "#/components/schemas/EventSubscriptionStarted"
    And the event body property "$.type" is "org.camaraproject.sample-service-subscriptions.v0.subscription-started"
    And the event body property "$.data.initiationReason" is "SUBSCRIPTION_CREATED"
    And the event body property "$.data.subscriptionId" has the same value as the response property "$.id"

  # Only applicable if the implementation supports initial events
  @sample_service_subscriptions_createSampleServiceSubscription_04_initial_event
  Scenario: Receive initial event notification on creation
    Given the API supports initial events to be sent
    And the request body property "$.config.initialEvent" is set to true
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201 or 202
    And an event notification of the subscribed type is received at the "callbackUrl"
    And the event body complies with the OAS schema at "#/components/schemas/ApiNotificationEvent"

  # Some implementations may decide to not return the sinkCredential in the response (data minimization principle)
  @sample_service_subscriptions_createSampleServiceSubscription_05_accesstoken_sink_credential
  Scenario: Create subscription with ACCESSTOKEN sinkCredential
    Given the request body property "$.sinkCredential.credentialType" is set to "ACCESSTOKEN"
    And the request body property "$.sinkCredential.accessTokenType" is set to "bearer"
    And the request body property "$.sinkCredential.accessToken" is set to a valid access token
    And the request body property "$.sinkCredential.accessTokenExpiresUtc" is set to a valid expiry date in the future
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.sinkCredential.credentialType", if present, is "ACCESSTOKEN"
    And the response property "$.sinkCredential.accessTokenExpiresUtc", if present, has the same value as the request body property "$.sinkCredential.accessTokenExpiresUtc"
    And the response property "$.sinkCredential.accessToken" does not exist

  # Only applicable if the implementation supports out-of-band provisioning of PRIVATE_KEY_JWT
  @sample_service_subscriptions_createSampleServiceSubscription_06_private_key_jwt_out_of_band
  Scenario: Create subscription with PRIVATE_KEY_JWT sinkCredential, out-of-band provisioning
    Given the PRIVATE_KEY_JWT mechanism is pre-configured for the API client
    And the request body property "$.sinkCredential.credentialType" is set to "PRIVATE_KEY_JWT"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"

  # Only applicable if the implementation supports in-band provisioning of PRIVATE_KEY_JWT
  @sample_service_subscriptions_createSampleServiceSubscription_07_private_key_jwt_in_band
  Scenario: Create subscription with PRIVATE_KEY_JWT sinkCredential, in-band provisioning
    Given the request body property "$.sinkCredential.credentialType" is set to "PRIVATE_KEY_JWT"
    And the request body property "$.sinkCredential.clientId" is set to a valid value
    And the request body property "$.sinkCredential.tokenUri" is set to a valid value
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 201
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response body complies with the OAS schema at "#/components/schemas/HTTPSubscriptionResponse"
    And the response property "$.sinkCredential.credentialType" is "PRIVATE_KEY_JWT"
    And the response property "$.sinkCredential.jwksUri" is set to a valid value

  @sample_service_subscriptions_createSampleServiceSubscription_08_subscription_ends_on_expiry
  Scenario: Receive notification for subscription-ended event on expiry
    Given an existing subscription with the property "$.config.subscriptionExpireTime" set to a value in the near future
    When the subscription expires
    Then an event notification "subscription-ended" is received at the "callbackUrl"
    And the event body complies with the OAS schema at "#/components/schemas/EventSubscriptionEnded"
    And the event body property "$.type" is "org.camaraproject.sample-service-subscriptions.v0.subscription-ended"
    And the event body property "$.data.terminationReason" is "SUBSCRIPTION_EXPIRED"

  @sample_service_subscriptions_createSampleServiceSubscription_09_subscription_ends_on_max_events
  Scenario: Receive notification for subscription-ended event on max events reached
    Given an existing subscription with the property "$.config.subscriptionMaxEvents" set to 1
    When an event of the subscribed type occurs
    Then an event notification of the subscribed type is received at the "callbackUrl"
    And an event notification "subscription-ended" is received at the "callbackUrl"
    And the event body complies with the OAS schema at "#/components/schemas/EventSubscriptionEnded"
    And the event body property "$.type" is "org.camaraproject.sample-service-subscriptions.v0.subscription-ended"
    And the event body property "$.data.terminationReason" is "MAX_EVENTS_REACHED"

  ############################ Error Scenarios #############################################

  # Syntax error scenarios

  @sample_service_subscriptions_createSampleServiceSubscription_400.01_schema_not_compliant
  Scenario: Request body does not comply with the schema
    Given the request body is included but is not compliant with the schema at "#/components/schemas/HTTPSubscriptionRequest"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.02_no_request_body
  Scenario: Missing request body
    Given the request body is not included
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.03_empty_request_body
  Scenario: Empty object as request body
    Given the request body is set to {}
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.04_empty_property
  Scenario: Error response for empty config in request body
    Given the request body property "$.config" is set to {}
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.05_missing_required_property
  Scenario Outline: Error response for missing required property in request body
    Given the request body property "<required_property>" is not included
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | required_property           |
      | $.sink                      |
      | $.protocol                  |
      | $.types                     |
      | $.config                    |
      | $.config.subscriptionDetail |

  @sample_service_subscriptions_createSampleServiceSubscription_400.06_invalid_x-correlator
  Scenario: Invalid x-correlator header
    Given the header "x-correlator" does not comply with the schema at "#/components/schemas/XCorrelator"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.09_request_body_strictness
  Scenario Outline: Undeclared property in request body
    Given the request body includes the property "<undeclared_property>" which is not declared in the schema at "#/components/schemas/HTTPSubscriptionRequest"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | undeclared_property                 |
      | $.undeclaredProperty                |
      | $.config.undeclaredProperty         |
      | $.sinkCredential.undeclaredProperty |

  @sample_service_subscriptions_createSampleServiceSubscription_400.11_expiry_time_in_past
  Scenario: Subscription expiry time in the past
    Given the request body property "$.config.subscriptionExpireTime" is set to a value in the past
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.12_invalid_event_type
  Scenario: Subscription creation with invalid event type
    Given the request body property "$.types" is set to an array with a value not defined in "#/components/schemas/ApiEventType"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Only "HTTP" is considered in the schema so a generic schema validator may fail and generate a 400 INVALID_ARGUMENT without further distinction,
  # and both could be accepted
  @sample_service_subscriptions_createSampleServiceSubscription_400.13_invalid_protocol
  Scenario: Subscription creation with invalid protocol
    Given the request body property "$.protocol" is set to a value other than "HTTP"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_PROTOCOL" or "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_400.07_invalid_sink_credential
  Scenario Outline: Subscription creation with invalid credential
    Given the request body property "$.sinkCredential.credentialType" is set to "<unsupported_credential_type>"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_CREDENTIAL"
    And the response property "$.message" contains a user friendly text

    Examples:
      | unsupported_credential_type |
      | PLAIN                       |
      | REFRESHTOKEN                |

  # Only "bearer" is considered in the schema so a generic schema validator may fail and generate a 400 INVALID_ARGUMENT without further distinction,
  # and both could be accepted
  @sample_service_subscriptions_createSampleServiceSubscription_400.08_invalid_token
  Scenario: Subscription creation with invalid token
    Given the request body property "$.sinkCredential.credentialType" is set to "ACCESSTOKEN"
    And the request body property "$.sinkCredential.accessTokenType" is set to a value other than "bearer"
    And the request body property "$.sinkCredential.accessToken" is set to a valid access token
    And the request body property "$.sinkCredential.accessTokenExpiresUtc" is set to a valid expiry date in the future
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_TOKEN" or "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # The sink pattern requires an HTTPS URL, so a generic schema validator may generate a 400 INVALID_ARGUMENT instead, and both could be accepted
  @sample_service_subscriptions_createSampleServiceSubscription_400.10_invalid_sink
  Scenario: Subscription creation with invalid sink
    Given the request body property "$.sink" is set to "invalid-url"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 400
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_SINK" or "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

  # Authentication and authorization error scenarios

  @sample_service_subscriptions_createSampleServiceSubscription_401.01_no_authorization_header
  Scenario: Error response for no header "Authorization"
    Given the header "Authorization" is not sent
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_401.02_expired_access_token
  Scenario: Error response for expired access token
    Given the header "Authorization" is set to an expired access token
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_401.03_invalid_access_token
  Scenario: Error response for invalid access token
    Given the header "Authorization" is set to an invalid access token
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 401
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 401
    And the response property "$.code" is "UNAUTHENTICATED"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_403.01_missing_access_token_scope
  Scenario: Missing access token scope for the requested event type
    Given the header "Authorization" is set to an access token that does not include the scope required for the event type in the request body property "$.types"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "PERMISSION_DENIED"
    And the response property "$.message" contains a user friendly text

  # Applies e.g. to a three-legged access token whose subject is not the one the subscription detail refers to
  @sample_service_subscriptions_createSampleServiceSubscription_403.03_subscription_mismatch
  Scenario: Access token inconsistent with the requested subscription
    Given the header "Authorization" is set to a valid access token which is not consistent with the request body property "$.config.subscriptionDetail"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 403
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 403
    And the response property "$.code" is "SUBSCRIPTION_MISMATCH"
    And the response property "$.message" contains a user friendly text

  # Conflict error scenarios

  # Applies when the implementation does not allow two identical subscriptions
  @sample_service_subscriptions_createSampleServiceSubscription_409.01_duplicated_subscription
  Scenario: Conflict due to an existing identical subscription
    Given an existing subscription with the same "types", "sink" and "config.subscriptionDetail" as the request body
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 409
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ALREADY_EXISTS"
    And the response property "$.message" contains a user friendly text

  @sample_service_subscriptions_createSampleServiceSubscription_409.02_request_aborted
  Scenario: Conflict due to a concurrent request for the same subscription
    Given an identical subscription request is being processed by another request and the service does not allow concurrent processing
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 409
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 409
    And the response property "$.code" is "ABORTED"
    And the response property "$.message" contains a user friendly text

  # Unprocessable entity error scenarios

  # Only applicable if the implementation supports PRIVATE_KEY_JWT but requires pre-shared configuration
  @sample_service_subscriptions_createSampleServiceSubscription_422.02_private_key_jwt_not_configured
  Scenario: PRIVATE_KEY_JWT sink credential used without pre-shared configuration
    Given the PRIVATE_KEY_JWT mechanism is not pre-configured for the API client
    And the request body property "$.sinkCredential.credentialType" is set to "PRIVATE_KEY_JWT"
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 422
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 422
    And the response property "$.code" is "PRIVATE_KEY_JWT_NOT_CONFIGURED"
    And the response property "$.message" contains a user friendly text

  # Rate limiting error scenarios

  # To test this scenario the environment has to be configured to reject requests reaching the threshold limit set
  @sample_service_subscriptions_createSampleServiceSubscription_429.01_too_many_requests
  Scenario: Request is rejected due to threshold policy
    Given the threshold of requests has been reached
    When the request "createSampleServiceSubscription" is sent
    Then the response status code is 429
    And the response header "Content-Type" is "application/json"
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response property "$.status" is 429
    And the response property "$.code" is "TOO_MANY_REQUESTS"
    And the response property "$.message" contains a user friendly text
