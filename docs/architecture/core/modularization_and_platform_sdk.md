---
layout: default
title: Modularization & Platform SDK
parent: Core
grand_parent: Architecture
nav_order: 20
---

# Modularization & Platform SDK

The goal of modularization is:

- Divide and break down the application into a set of smaller, self-executable projects, called `features` or `modules`, that can be integrated into the main `mobile` application
- Abstract (almost) all of the mundane tasks involved in feature development, such as branding, theming, networking, local storage... by providing a single, internal SDK, called `platform_sdk`, that will be maintained mainly by the Core team (but it is open for collaboration), and it will be composed of smaller, single-purpose libraries, such as the `router`, `omc_api_client`, `key_value_storage`, `bloc`, or `connected_ui`.
- Have a single way of integrating features and navigation.
- Provide a `feature-generator` that, with a single command, will provide a common skeleton to all feature developers. This scaffold will contain the basic setup for integration tests, unit tests, widget tests, automation, localization, sandbox integration...

<div class="mermaid">
  graph TD;
    AppShell --> Feature-Registry;
    Feature-Registry --> Feature-1;
    Feature-1 --> Platform-SDK;
    Feature-Registry --> Feature-2;
    Feature-2 --> Platform-SDK;
    Feature-Registry --> Feature-N;
    Feature-N --> Platform-SDK;
    Feature-Registry --> Platform-SDK;
    Platform-SDK --> Repository-1;
    Repository-1 --> Omc-Api-Client;
    Repository-1 --> Storage;
    Repository-1 --> GPS;
    Platform-SDK --> Repository-2;
    Repository-2 --> Omc-Api-Client;
</div>