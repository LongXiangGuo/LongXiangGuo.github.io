---
layout: default
title: "BEEP-4: Infrastructure to Increase Development Velocity"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 4
---

# BEEP-4: Mobile-Connected Infrastructure to Increase Development Velocity

### Authors

- Felix Angelov

## Proposal

I am proposing the following changes to improve development velocity on `mobile-connected`:

Short Term:
- Acquire More MacOS Nodes [MOB-694](https://suus0002.w10:8080/browse/MOB-694)
- Separate Integration Tests into Stages [MOB-692](https://suus0002.w10:8080/browse/MOB-692)
  - This would allow for integration tests to be run in parallel (assuming we have enough macos nodes) and would reduce the time to run integration tests to be the length of the slowest single integration test (~5-7mins).
- Separate Client Modules into different Github Repositories with each running their own test suite
  - This is currently blocked by [MOB-557](https://suus0002.w10:8080/browse/MOB-557) but once unblocked will allow the time spent on running unit tests for mobile-connected to be a small fraction of the current time.
- Investigate [mergify](https://mergify.io) to auto merge PRs when they are ready. [MOB-693](https://suus0002.w10:8080/browse/MOB-693)

Long Term:
- Investigate separating mobile-connected into separate repos by feature/module (vehicle-mapping, login, create-account, etc...) with them all having access to a core module (owned by the mobile 2.0 team). [MOB-695](https://suus0002.w10:8080/browse/MOB-695)

## Motivation

Lots of time is wasted around the PR review process as well as the CI/CD pipeline & build process. We should seriously invest time upfront so that we can have a solid foundation to both move quickly and to scale to more developers.