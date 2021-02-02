---
layout: default
title: "BEEP-5: Flutter Modularization"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 5
---

# BEEP-5: Mobile-Connected Flutter Modularization

**Disclaimer:** After further discussion, the team has decided to focus on vertical separation instead horizontal due to the obstacles discussed below.

### Authors

- Felix Angelov

## Proposal

- Separate features into standalone projects
- Test features independently of the core
- Designate plugin-points where features can be turned on/off from the core application

## Process

- Use Vehicle Mapping as a P.O.C
- Created a separate package for `vehicle_mapping`
- Created a runner for `vehicle_mapping` so that it can be run independently of the core application

## Obstacles

- The `omc_client` layer is tightly coupled with features and in its current state makes it impossible to develop a separate `feature_api_client` with an `omc_client` base without making modifications to the actual `omc_client` package.
  - In order to address this, I propose:
    - `omc_client` be a standalone http client wrapper which exposes public APIs for `get`, `post`, `put`, `delete`
    - handles token refresh
    - handles determining the base_url
    - handles providing common headers
    - each presentation microservice has it's own api client (`vehicle_composite_api_client`) which has a dependency on an `omc_client` instance.
  - In addition, we will need to invest in automation/infrastructure to ensure that a single `omc_client` instance is being used globally and no other http client dependencies exist in feature applications.
- The localization layer is tightly coupled with features and is configured at the `core application`. In it's current state it is also not possible to develop separate feature strings files without making modifications to the `core` client code.
  - In order to address this, I propose:
    - The localizations be separated into a separate project so that new feature strings can be added, generated, and pulled into the core project without having to update core project code.
- Navigation will become a challenge to manage since using named routes will require implicit trust between the feature and the core and we will likely need some sort of "contract testing" to make sure that a feature module's defined routes actually exist in the core application. This will be be critical for things like featureA wants to navigate to featureB and/or featureA wants to navigate to some core screen.
