---
layout: default
title: Repository Architecture
parent: Core
grand_parent: Architecture
nav_order: 6
---

# Repository Architecture

In an attempt to modularize the code, simplify testing, and minimize code complexity a repository architecture has been proposed.

![Repository Architecture]({{site.baseurl}}/assets/images/repository_architecture.png)
_Fig 1. Repository Architecture Diagram_

## Directory Structure

_Due to the immaturity of the code base, the packages created during this refactor are to be part of the same github repository as the mobile-connected application._

```bash
├── connected_ui
│   ├── lib
│   └── test
├── lib
│   ├── app
│   ├── home
│   ├── login
│   └── main
├── localization
│   └── lib
├── startup_configuration
│   ├── lib
│   └── test
├── test
│   ├── unit_tests
│   └── widget_tests
├── test_driver
│   └── driver
└── user_repository
    ├── lib
    └── test
```

_Fig. 2 New Directory Structure_

Based on the above directory structure, the main changes were:

- separation of `StartupConfiguration` into it's own package
- separation of `UserRepository` into it's own package

### StartupConfiguration

StartupConfiguration largely stayed the same. The main changes to it were it is decoupled from `Omc` and `Gcdm` and currently only is resposible for providing shared startup configuration information (`Region` and `Environment`).

### UserRepository

The UserRepository was created in an attempt to separate the application into different domains. The current vision is that we will have the following domains:

- User
- Vehicle
- Journey/Trips

Currently the only functionality that exists in the UserRepository is authentication for a given set of credentials.

## Impact to the Project

The impact to the rest of the project can be broken up into two parts:

- implementation changes
- test changes

### Implementation Changes

The main change as illustrated by the architecture diagram (Fig. 1) is that **the ConnectedApp no longer has a direct dependency on the http module or FlutterSecureStorage and, instead, the UserRepository is injected via the RepositoryProvider**.

Furthermore, the LoginBloc which previously has a dependency on `Gcdm` and `Omc` now only has a dependency on the `UserRepository` and `Gcdm` and `Omc` are abstracted. In addition, the interaction with KeyChain/KeyStore is abstracted by the UserRepository via `loadToken`, `saveToken`, and `deleteToken`

### Test Changes

As a result of the implementation changes, the unit and widget tests have been greatly simplified and the integration tests can now be run in both sunny day and rainy day scenarios simply by mocking the `UserRepository`.
