---
layout: default
title: Crash Reporting
parent: Archives
nav_order: 4
grand_parent: Architecture
---

# Crash Reporting

This was the original research that was done by the Korea implementation team. Given that we can't really use cloud tools like this in BMW these were dropped from being implemented. 

## Sentry ([https://sentry.io](https://sentry.io))

### Features

- Stacktrace: enhanced stack traces with source code
- Breadcrumbs: show events that lead to the errors
- Custom Context: supports multiple environments with filtering/querying
- Releases: Changes associated with release version + JIRA like task management
- Integrations: Wide array of integration available with Github, JIRA, Bitbucket ...
- Different Pricing plans (we'd likely need the Enterprise plan).
- Officially Supported for Flutter

## Crashlytics ([https://get.fabric.io/](https://get.fabric.io/))

- Stacktrace: enhanced stack traces with source code
- Breadcrumbs: show events that lead to the errors
- Comprehensive Reports
- Free
- No official Google Support for Flutter Integration

## Preliminary Recommendation

- It seems like Sentry is the better option at the moment since support for Crashlytics in Flutter is limited (only one package created by the community with limited functionality).
- In addition, Sentry seems to offer more in terms of integration with third party services for alerting, notifications, etc...