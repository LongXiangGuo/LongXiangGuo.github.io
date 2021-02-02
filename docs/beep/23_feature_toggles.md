---
layout: default
title: "BEEP-23: Feature Toggles"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 23
---

# BEEP-23: Feature Toggles

### Authors

- Fábio Carneiro <fabio.carneiro@ctw.bmwgroup.com>
- Rui Costa <rui.ca.costa@ctw.bmwgroup.com>

## Summary

This is a proposal for how to handle feature toggles on the Eadrax project.

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

## Motivation

Currently, it isn't possible to toggle a feature based on any of the user contexts. This is a requirement multiple features have and that needed to be addressed.

## Detailed Description

This BEEP proposes a solution that doesn't rely on the Launchdarkly Mobile Client but instead uses a centralized service that handles all requests to obtain feature toggling flags.
Creation and update of flags should still be handled through [TF-LaunchDarkly](https://code.connected.bmw/runtime/tf-launchdarkly) repository.

### Overview

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/23/feature_toggles_comp_high.png" width="80%">
</div>

An analysis was done about the pros and cons we see about this implementation

##### Pros

- API contract is independent of LaunchDarkly, allowing us to change the service provider or use an internal solution in the future.
- BFFs can access LaunchDarkly Relay Proxy through a centralized service avoiding multiple implementations.
- The payload that the app receives is reduced significantly when compared to the one provided by LaunchDarkly.
- User contexts are cached by the Feature Toggles Service, avoiding rebuilding.
- Reduces the app bundle size and external dependencies.

##### Cons

- Internal resources usage increase, since the user is communicating with our internal service instead of LaunchDarkly directly.

### Mobile-Connected Implementation

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/23/feature_toggles_svc_sd.png" width="80%">
</div>

The APP will initialize with the mandatory feature set for the specific region, then after login, a request will be made to the `feature toggles service` to obtain which feature modules should be disabled (disabled features should be a smaller payload), after receiving the expected reply all modules except the disabled ones will be registered.
A small timeout will be set and the request will be made during the faceID /TouchID / Pin authentication screen. If the request to obtain the feature toggles fails the latest set of modules stored or the fallback one for that region will be loaded.

We see the app feature toggling being done mostly on a central point and a feature module level, this will allow us when composing our UI to not need to check if the feature module is registered or not, the `PlatformSDK findModule` will just return an empty container that won't break our UI composition.
About toggling inside a feature module we see it as data-driven from the BFF, as an example if we don't want the customers of a specific country to be able to add tariffs to a charging session, we can in our BFF ask the Feature Toggles Service to evaluate that specific flag and then provide data accordingly to the app that would drive the user experience.

### Feature Toggles Service

[API Documentation]({{site.baseurl}}/assets/docs/beep/23/feature_toggles_oas.html)

[OpenAPI Specification (OAS) v3]({{site.baseurl}}/assets/docs/beep/23/feature_toggles_oas.json)

[Git Repository](https://code.connected.bmw/mobile20/feature-toggles-service)

Two endpoints will be available. One to obtain all flags with the required query parameter `isActive` and one to obtain a flag with a specific key. The payload will be the minimum possible consisting of a `flagId` string and an `isActive` bool.
The user context will be built based on the headers provided by the mobile-connected app or other microservice requests.
Currently, the  user context is composed of:

- usid
- User locale
- Account Country
- Vin Market
- App Version
- Build number
- Brand
- Platform

##### User context

`usid` will be provided by the API Gateway as a header based on the user token.
`user locale` is based on the `accepted-language` and `device-country`.
`account country` and `vin market` will be obtained from the web API.
`brand`, `platform`, `app version`, and `build version` will be provided by the `x-user-agent` that comes from the app.

The service will communicate with LaunchDarkly using the [LaunchDarkly Relay Proxy](https://docs.launchdarkly.com/home/advanced/relay-proxy). At the moment the service will use the `btcldrelayproxywebapp`. This web app will be migrated to the service mesh in the future.

The user context will be cached using the `usid` as key. In this way, microservices that call the feature toggles service will already have the user's full context.
`Redis` will be used to cache the user context and flags.

##### How to consume the feature toggles service from a composite.

The feature toggle service will be deployed in the mesh. The URL will follow the mesh convention. The `http://feature-toggles-service.consul` URL can be used in the tf-cluster-apps to consume it. The headers `bmw-usid`, `accepted-language`, and `x-user-agent` are necessary to build a complete user context. These headers will be provided by the app request and can be forwarded to the feature toggle API.

The user context will be constructed based on the information that is provided to the API. All the information needed to get the correct flag value should be sent to the feature toggles API. If the services already have information about the `account country` and/or `vin market` send them as headers `bmw-account-country` and `bmw-vehicle-market` to the API.

- For .net Core applications, a NuGet package will be created and published in [Artifactory](https://artifacts.connected.bmw/)
- For NestJS an npm package will be created and inserted under the [bmw-npm](https://code.connected.bmw/library/bmw-npm) repository.

##### Monitoring

[Grafana](https://monitor.connected.bmw/) will be used for monitoring and alerts. The feature-toggles service will be deployed in the service mesh which means that will be under the readiness and liveness probes from the azure managed apps. Boards with response times, logs, HTTP status codes, availability, external dependencies (Redis, LaunchDarkly relay proxy, web API) among others will be available and used to trigger some alerts. These alerts will trigger events to send emails, notify team channels, and OpsGenie.
