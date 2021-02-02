---
layout: default
title: ONE Login Flow
parent: Core
grand_parent: Architecture
nav_order: 15
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# ONE Login Flow

## Overview

BMW ONE Login Flow uses OAuth 2.0 and OpenID Connect to provide authentication for users across a variety of BMW services. The Eadrax client will utilize an AppAuth Flutter plugin to facilitate logging a user in. Token refresh will also be facilitated by this plugin as well. The proposed architecture is meant to cover the changes required to migrate from the old login flow into the ONE Login Flow.

AppAuth is a client SDK for native apps to authenticate and authorize end-users using OAuth 2.0 and OpenID Connect.

## Proposed Client Architecture

<img src="{{site.baseurl}}/assets/images/architecture/one_login_flow/login_proposed_client_flow.png">

The Login Form will no longer be a form but rather a set of buttons, one for login, create account and reset password.

The Login Form Bloc will be simplified to react to each button press and in the case of login, it will call into the User Repository to initiate user authentication, much as it does today but without input field validation as it will be removed.

The User Repository Authenticate API will be modified to use the AppAuth plugin to faciliate login through an Authenticator component.

The Authenticator is a proposed component that will "wrap" the [BMWAppAuth](https://code.connected.bmw/mobile20/bmw-app-auth) and do the following:

- Use AppAuth plugin to manage user authentication for login
- Use AppAuth plugin to perform token refresh
- Support calling COAS with GCDM access token to get the unique identifier (GCID/USID) for the user.

By organizing the functionality into a separate Authenticator component, it can be used both by UserRepository and RefreshTokenInterceptor to perform their respective tasks

**Note** - On Logout the client makes a call to COAS to revoke the token.  This API call has no meaningful response code so its unclear if the operation succeeds or not.  The team may want to ask GCDM team if this is needed or not on logout and if One Login Flow has something comparable.

**Note** - Need to consider error handling scenarios for if USID/GCID fetch from COAS fails for some reason

**Possible Improvement** - Ask GCDM team if GCID can be incorporated into the response data from AppAuth login.  May not be possible if it breaks the AppAuth standard.

### Token Refresh Current

<img src="{{site.baseurl}}/assets/images/architecture/one_login_flow/refresh_current_flow.png">

The current token refresh flow is to have the RefreshTokenInteceptor react to 401 response codes and call the COAS to refresh the user's token while retrying the original request after the tokens have been refreshed.

### Token Refresh Proposed Changes

<img src="{{site.baseurl}}/assets/images/architecture/one_login_flow/refresh_proposed_flow.png">

The proposed changes to token refresh are the following:

- Inject the Authenticator component into RefreshTokenInterceptor. This component wraps the BMWAppAuth plugin
- Call into the Authenticator to refresh the token. The response back should be valid access and refresh tokens
- USID does not need to be re-fetched from COAS since it will not change during refresh.

The RefreshTokenInterceptor will largely remain the same outside of the above three points of change.

## Proposed Backend Architecture

<img src="{{site.baseurl}}/assets/images/architecture/one_login_flow/login_proposed_backend_flow.png">

The proposed changes to connected-oauth-service (COAS) are the following:
- Add new API to the oauth resource for getting the identifier related to the token. This new API will take the GCDM access token as a parameter and return back the identifier for the user (GCID or USID)
- The underlying service class will need a new API to support the new external API
- The current API for getting the identifier (named USID currently) via the Token API Library can be reused by just passing the GCDM access token to it

## BMWAppAuthPlugin

The [BMWAppAuth Plugin example](https://code.connected.bmw/mobile20/bmw-app-auth) demonstrates how to sign in with the ONE Login Flow.

The plugin exposes three main operations:
1. **Setup**
   A provider must be setup that contains endpoint information, client secret, scopes, etc. Multiple providers can be setup, each specified by a certain provider key given on setup:

	 ```dart
	 final summary = await bmwAppAuth.setupProvider(
   		provider: 'my-provider',
   		client: client,
   );
	 ```
2. **Authorize**
	 Once a provider is setup, you can request that a browser be presented for a given provider key to authorize against that provider. This prompts the user of the application to login and hands control back to the application.
	 The `scopes` parameter can be used to modify the requested permissions.
	 ```dart
	 final auth = 
	   await bmwAppAuth.authorize(provider: 'my-provider');
	 setState(() {
		_accessToken = auth["tokenResponse"]["accessToken"];
		_refreshToken = auth["tokenResponse"]["refreshToken"];
	 });
	 ```
3. **Refresh**
	 If the token has expired or you wish to see if the token is expired, you can invisibly attempt to get fresh tokens by calling refresh. Refresh will fail if the session has ended, in which case `authorize()` must be called again.
	 ```dart
	 final refresh = await bmwAppAuth.refresh(
	   provider: 'my-provider',
	   refreshToken: _refreshToken,
	 );
	 setState(() {
		_accessToken = refresh["tokenResponse"]["accessToken"];
		_refreshToken = refresh["tokenResponse"]["refreshToken"];
	 });
	 ```

#### BMW AppAuth Plugin Future

The BMW AppAuth plugin can be further developed to support more generalized login flows. Currently, it suffers from the following limitations:

- No support for discovery requests. OAuth can make finding provider/client information much easier via a discovery network call, which BMWAppAuthPlugin doesn't support. Instead, all provider information must be established before attempting to authorize or refresh.
- Request generation is specific to BMW's OAuth flow. Certain request details are constructed in the native layer via the Kotlin and Swift code and these decisions could be moved to the Dart layer, allowing for more authentication flows to be supported. This would make the native code act more as a conduit to the native AppAuth libraries and prevent having to change native code for OAuth flow changes. 