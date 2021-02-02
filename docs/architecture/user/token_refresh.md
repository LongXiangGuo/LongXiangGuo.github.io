---
layout: default
title: Token Refresh
parent: User
nav_order: 3
grand_parent: Architecture
---

# Token Refresh

Token refresh is the mechanism used by the OMC and GCDM to guarantee that a client is authenticated, in a secure way, at any moment when it needs to access information from our backends.

In any network call exchanged with our backends, there are two pieces of information that facilitate and secure this exchange of information:

* An authorization token, granted per application and environment. This is assigned to control that the product has been granted access to BMW backends.
* An OAUTH token, granted per user, with an expiration date. Each customer will have a different token. This token has an expiration date. When exchanging information with BMW backends, this token needs to be present; the backend will confirm that token is valid, expired, or invalid.
  * A **valid** state will return back the information requested.
  * An **expired** token indicates that the token was valid once before, but now it is no longer valid. The client should retry to request a new valid token.
  * An **invalid** token indicates that the given token was never issued, and the user shall not proceed.

## Token Refresh - Scenarios

### Successful Refresh

This is the most common scenario. At any point in time, the backend might return a `401`, meaning that the existing token needs to be renewed. We will then re-authenticate with the proper endpoint to expedite a new valid token, and retry the network call with the new token.

<div class="mermaid">
  sequenceDiagram
  User-->>FlutterClient: Perform Action;
  FlutterClient-->>OmcBackend: request 1;
  OmcBackend->>FlutterClient: 401 - token expired;
  FlutterClient-->>OmcBackend: /token_refresh;
  OmcBackend->>FlutterClient: 200 OK with new token;
  FlutterClient-->>OmcBackend: request 1 with new token;
  OmcBackend->>FlutterClient: 200 OK;
  FlutterClient-->>User: info received for requested action;
</div>

### Token refresh not authorized

This is the `most` critical scenario, since it will logout the user when it happens, **and should also clear ALL the information cached and stored**. When the user receives a `401`, and ONLY A 401 RESPONSE, at any point in time, the `omc_client` will attempt to refresh the token; however, if the refresh token endpoint returns again a `401`, that means that the existing refresh attempt is not valid and the current session represents a security issue. In this case, we **MUST** log the user out and clear all local caching/storage.

<div class="mermaid">
  sequenceDiagram
  User-->>FlutterClient: Perform Action;
  FlutterClient-->>OmcBackend: request 1;
  OmcBackend->>FlutterClient: 401 - token expired;
  FlutterClient-->>OmcBackend: /token_refresh;
  OmcBackend->>FlutterClient: 401 Token not granted;
  FlutterClient-->>User: Logout;
</div>

### Token refresh endpoint is down/timeout

This case covers all the scenarios in which asking the backend token to refresh a token fails (lack of connection, timeout, server down, the apocalypse...). If this is the case, it should just be treated as an error, and therefore the user should be inform. However, **the user should not be logged out**, since the backend is not informing that the token is invalid.

<div class="mermaid">
  sequenceDiagram
  User-->>FlutterClient: Perform Action;
  FlutterClient-->>OmcBackend: request 1;
  OmcBackend->>FlutterClient: 401 - token expired;
  FlutterClient-->>OmcBackend: /token_refresh;
  OmcBackend->>FlutterClient: Any HTTP Code different than 401 or 200;
  FlutterClient-->>User: treat response as "error", but do not logout;
</div>

## Expanding the OMC client

The goal is to let the `omc_client` package handle all HTTP configurations and communications with the OMC. 

The `omc_client` will:

* Provide a way to register *non-authenticated* calls; that is, those that don't require a user to be authenticated.
* Provide a way to register *authenticated* calls. These calls will handle tokens internally, and will signal the host when a refresh was invalid, so the host can logout the user.
* Will store tokens in a secure layer, and these tokens will be cleared out once the user is not logged in anymore.