---
layout: default
title: Architecture
nav_order: 6
has_children: true
---

# Architecture

## Client architecture

![3 tier]({{site.baseurl}}/assets/images/architecture/three_tier_arch.png)

### Data layer, pure Dart, small SDKs

- This layer is used to obtain simple, raw data, from different sources: network, database, GPS, bluetooth...
- There's no business decisions, or data composition, at this level.
- APIs should be as minimal as possible

### Domain layer (repositories), pure Dart

- This layer is used to composed and orchestrate the existing data sources
- Business decisions are made at this level, but do not represent "presentation" decisions
- There's a repository per feature: vehicle, user, vehicle-mapping ...

### UI Layer in Flutter

- Written with Dart and Flutter widgets
- Uses [Bloc](https://github.com/felangel/bloc) as a state management solution
- Avoid HTML contents in the app, prefer to render the data which should be displayed with Flutter widgets

#### State management for the UI

![bloc]({{site.baseurl}}/assets/images/architecture/bloc.png)

- [Bloc](https://github.com/felangel/bloc) turns UI events into UI states
- Blocs only receive repositories as dependencies
- Via the Bloc delegate, we can process logs, analytics...

## Connected API Architecture

Vision for the Connected Cloud (v2.0 of BMW Connected Microservice Architecture)

![Architecture]({{site.baseurl}}/assets/images/architecture/connected_api_architecture.png)

We follow the pattern [Backend for Frontends](https://samnewman.io/patterns/architectural/bff/)

- These microservices are totally stateless
- They simplify the processing of the client
- They are not multipurpose: these APIs are only designed to satisfy the mobile presentation
