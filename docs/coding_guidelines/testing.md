---
layout: default
title: Testing
parent: Coding Guidelines
nav_order: 3
---

# Testing Goals

Here's our goals for testing in Mobile 2.0:

* **To avoid any kind of manual regression and testing**
  * There's only one way to achieve this: *having a world-class testing infrastructure that everyone can rely on*
* **To have 100% unit test code-coverage**
  * We shouldn't just cover every line, but every logical branch (e.g., switch-case, if-else, etc.)

## Testing Requirements

As a developer, it is expected from you to write tests to validate that your code works now, and will still work when other people add to the code (e.g., in PR's).

**Every time you add code, you are required to write:**

* `Unit tests`
  * They are great for testing single methods and classes in isolation
  * External dependencies are generally `mocked`, and avoid reading/writing from disk and network
  * They are usually simple to write and maintain, fast to execute, but unfortunately, due to their isolated nature, do not provide enough confidence to assert our app works as expected in general
  * Related BEEPs:
    * [BEEP 10 - Bloc Tests](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/beep/10_bloc_test/)
* `Widget/Component tests`
  * They are ideal for testing local components individually, but not as part of a whole
  * The goal of these tests to verify that a widget's UI looks and interacts as expected
  * Related BEEPs:
    * [BEEP 16 - Widget Tests](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/beep/16_widget_tests/)
* `Integration tests`
  * They are used to test the complete app, and the integration points with other projects (cloud, A4A, wearables...)
  * The goal of these tests is to verify that an app functions correctly as a whole, that the widget composition is correct, and that the app is performant

## The Role of Continuous Integration / Continuous Deployment (CI/CD)

Our CI/CD pipeline will take care of the automation steps, such as running tests during PRs, publishing builds, lint checks.  However...

* **Run the tests locally first**
* Only when it works on your local environment, you should then submit your code to review

The CI/CD pipeline will also be responsible for validating that our code-coverage never drops, below 100%, during PR's to help us achieve our goals.
