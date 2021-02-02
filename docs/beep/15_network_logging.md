---
layout: default
title: "BEEP-15: Network Logging"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 15
---

# BEEP-15: Network Logging

### Author

- [Julia Ringler](julia.ringler@bmw.de)

## Summary

Ensure that all network requests and responses are logged by creating a NetworkLoggingInterceptor.

## Motivation

The content of our app is strongly determined by the backend. To enable an easy bug analysis based on app logs, we should ensure that all network requests and responses are logged.

At the moment this is done for the token refresh in the `RefreshTokenInterceptor` and each repository (e.g. `VehicleRepository`) implements its own logging.

### Detailed Description

- Create an interceptor NetworkLoggingInterceptor which logs the full request including headers (but without logging any sensitive data such as passwords) and the full response:

```dart
class NetworkLoggingInterceptor extends Interceptor {
  @override
  Future<OmcRequest> onRequest(OmcRequest request) async {
    //<log request>
    return request;
  }
  @override
  void onError(OmcError error) {
    // <log error>
  }
  @override
  Future<OmcResponse> onResponse(
      OmcResponse response, RequestFunction request) async {
    //<log request and response>
    return response;
  }
}
```

- Make sure that we are able to track which response matches to which request (e.g. correlation id)
- Remove the previous logging in the `RefreshTokenInterceptor`.
- Remove the previous logging in the repositories (e.g. `VehicleRepository`, `DestinationRepository`, … )