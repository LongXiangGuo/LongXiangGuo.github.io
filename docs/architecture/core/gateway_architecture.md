---
layout: default
title: Gateway Architecture
parent: Core
grand_parent: Architecture
nav_order: 12
---

# Mobile 2.0 Gateway Architecture

## Diagram

![mobile 2.0 gateway architecture]({{site.baseurl}}/assets/images/mobile20_gateway_architecture.png)

## Overview

Currently, as Mobile 2.0 is writing more presentation microservices we are continuously having to add new routes to the BTCAPI Gateway.

It is having an impact on our velocity as well as limiting our flexibility in terms of routing and policies.

As a result, we are proposing to create a Mobile 2.0 Gateway using Apigee and controlling the routing for all Mobile 2.0 presentation APIs from the new gateway.

## Rationale

This approach will allow Mobile 2.0 to operate more independently of the rest of the organization and minimize the impact on the production gateway for mobile 2.0 routing. It will also allow us to fully test Apigee as our gateway solution and help us flush out any issues we find before migrating the entire production gateway to Apigee.

Furthermore, since Apigee is our long-term solution we will be in a good position once everything has been migrated because our gateway can be reused/migrated to the new infrastructure with minimal effort.