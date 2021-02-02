---
layout: default
title: Login & Authentication
parent: User
nav_order: 1
grand_parent: Architecture
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Login & Authentication

Login is the mechanism provided by the client to authenticate a user, in a secure way, with the OMC and GCDM so that it can access information from our backends when needed. The user provides a username and password that was set when they created their account. The result of login are the following:

- GCDM Access Token - provides gateway access to OMC and CDBE services
- GCDM Refresh Token - used to refresh the access token when it expires
- Token Type - usually of type 'Bearer'
- USID - unique identifier for any user in the cloud

## Client Flow

The client can be broken into the following layers: UI, Bloc, Repository and Repository Dependencies. The following image outlines the components of this flow:

<img src="{{site.baseurl}}/assets/images/user/login/login_current_client_flow.png">

The components are as follows:

- Login Page - Transitional widget to display Login Form
- Login Form - Provides the username/password input fields along with links to create an account or reset password
- Token Authentication Bloc - Bloc that maintains the current authentication state of the user
- Login Form Bloc - Bloc that drives the behavior of the login form and manages input field validation and form submission events and states from the LoginForm
- User Repository - repository of APIs related to user functions. In this case it supports an 'authenticate' API for logging the user in
- Authenticate API client - API client that makes the network call to the connected-oauth-service for authenticating a user
- Storage - client component that stores the access token, refresh token, token type and usid after login

The user enters their username and password in the input fields, click the login button which kicks off the flow of the LoginFormBloc calling the UserRepository to authenticate the user, which stores the token and usid information and then reflecting the authentication state in the TokenAuthenticationBloc.

## Backend Flow

The connected-oauth-service (COAS) is the BFF/Composite Service the client communicates with to login and authenticate a user. The image below describes the components and flows:
<img src="{{site.baseurl}}/assets/images/user/login/login_current_backend_flow.png">
The components are as follows:

- APIM - APIM Gateway
- connected-oauth-service - BFF/composite focused on authentication operations
- Token API Library - NPM Library wrapper that exposes APIs for communicating with GCDM to authenticate a user and to the OMC Token Exchanger for extracting the USID from the GCDM tokens
- GCDM - Core service that authenticates the user and returns access, refresh tokens and gcid
- OMC Token Exchanger - Contains a token exchange service that takes the GCDM access token and returns the tokens with USID

The COAS exposes an API for authenticating a user and refreshing a user's token (if that token has expired). The Token API wrapper is utilized by the service to handle the details of requesting GCDM tokens and then using them to extract the USID from them from the OMC Token Exchanger.

Please note that the long term plan is to deprecate the USID in favor of the GCID that is embedded in the GCDM access token
