---
layout: default
title: "BEEP-7: Refactor OMC Client"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 7
---

# BEEP-7: Refactor OMC Client

### Authors

- Felix Angelov

## Summary

I am proposing to refactor the `omc_client` API as well as introduce specialized API clients for interfacing with each of the presentation microservices (`vehicle_mapping_api_client`, `vehicle_api_client`, `user_api_client`).

![omc client refactor]({{site.baseurl}}/assets/images/omc_client_refactor_diagram.svg)

## Motivation

The `omc_client` currently has a lot of responsibilities ranging from handling token refresh to serializing json models from the http response, to throwing exceptions for different statusCodes, to maintaining endpoints for each of the feature APIs.

### Detailed description

Based on the aforementioned problems, I propose to update the `omc_client` interface to be more generic and focused on handling token-refresh as well as the base url configuration.

The `omc_client` would then serve as a specialized `http_client` that can be used more generically and can be moved out into its own package (since it won't need to change much).

```dart
class OmcClient {
    final OmcClientConfiguration _omcClientConfiguration;
    final OmcRefreshTokenInterceptor _omcRefreshTokenInterceptor;
    final http.Client _httpClient;

    OmcClient({
        @required OmcClientConfiguration omcClientConfiguration,
        @required OmcRefreshTokenInterceptor omcRefreshTokenInterceptor,
        @required http.Client httpClient
    }) : assert(omcClientConfiguration != null),
        assert(omcRefreshTokenInterceptor != null),
        assert(httpClient != null),
        _omcClientConfiguration = omcClientConfiguration,
        _omcRefreshTokenInterceptor = omcRefreshTokenInterceptor,
        _httpClient = httpClient;

    Future<OmcResponse> get(String endpoint, Map<String, dynamic> body, Map<String, String> headers);
    Future<OmcResponse> post(String endpoint, Map<String, dynamic> body, Map<String, String> headers);
    Future<OmcResponse> put(String endpoint, Map<String, dynamic> body, Map<String, String> headers);
    Future<OmcResponse> delete(String endpoint, Map<String, dynamic> body, Map<String, String> headers);
}

class OmcResponse {
    final int statusCode;
    final Map<String, dynamic> body;
    final Map<String, String> headers;

    OmcResponse({
        @required this.statusCode,
        @required this.body,
        @required this.headers,
    });
}
```

This then will allow us to create specialized api clients to interface with each of the client presentation microservices like `VehicleMappingApiClient`.

```dart
class VehicleMappingApiClient {
    final OmcClient _omcClient;

    Future<OmcResponse> addVehicle() => _omcClient.post(
        endpoint: '/api/v1/vehicles/$vin/primary',
        body: {},
        headers: {},
    );

    // Expose all other public presentation APIs
}
```

We can then move the JSON serialization/interpretation of these `OmcResponse` models into the `Repository` layer instead of having that model duplicated in both places. This is because we should not have a lot of model transformation between the networking layer and the repository layer (thanks to the presentation APIs).

![directory structure]({{site.baseurl}}/assets/images/omc_client_file_structure.svg)

### Final Thoughts

In summary, by introducing the above changes we will gain the following:

- Improved reusability of the `omc_client`
- Reduced complexity for json model serialization/deserialization
- Increased modularity of the networking layer
- Improved developer experience
