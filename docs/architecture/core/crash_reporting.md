---
layout: default
title: Crash Reporting
parent: Core
grand_parent: Architecture
nav_order: 7
---

# Crash Reporting Tools

## What are we looking for

As a developer, I want to have tooling for detecting crashes and generating crash reports that is:

- **Invisible**: It should just work with minimal setup.
- **Real-Time**: It should update in real-time.
- **Comprehensive**: It should provide detailed crash reports that allow us to quickly figure out the root cause of the crash, when it was introduced, and what the scope of impact is on our users
- **Proactive**: It should support notifying development whenever crashes in production have occurred/exceeded a configured threshold so that development can react to crashes as soon as they occur instead of letting them bubble up in app store reviews.
- **Extensible**: It should support triggered custom events that we can leverage in select cases (ex: if we know a device should never be in a given state).
- **Queryable**: It should allow us to filter crashes based on environment, release, OS, brand, etc so that we can quickly see trends, scope of impact, etc...

---

We currently do not have a selected crash reporting tool for the product outside of what Apple and Google gives to all developers via their store front.