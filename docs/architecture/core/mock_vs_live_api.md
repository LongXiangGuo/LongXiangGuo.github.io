---
layout: default
title: Mock vs Live API
parent: Core
grand_parent: Architecture
nav_order: 11
---

# Mock vs Live Microservice Architecture

## Diagram

![mock live architecture]({{site.baseurl}}/assets/images/mock_live_architecture.png)

## Overview

Every new microservice (made from template) should be equipped to handle an `"X-Cluster-Use-Mock"` header which can have a value of `true` or `false`.

Based on the presence/absence of the header as well as the value of the header, the microservice will use real/mock provider to retrieve the data.

Before responding to the request, the microservice will include a response header: `"X-Cluster-Mocked"` which can have a value of `true` or `false` and indicates whether or not the response data is real or mock.

Standard Header Documentation can be found [here](https://suus0001.w10:8090/display/RUN/Standard+Headers).

## Rationale

This approach has several benefits:

- We don't have to maintain two separate microservices for real/mock endpoints
- We don't have to maintain two separate route configurations in the gateway for real/mock microservices
- The controllers/models/modules can all be reused and the only thing that will differ is the service/provider
- If at any point we want to switch to an environment_variable based approach the transition is straightforward.
