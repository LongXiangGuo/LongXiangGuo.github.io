---
layout: default
title: "BEEP-22: BMW NPM Library Versioning"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 22
---

# BEEP-22: BMW NPM Library Versioning

### Authors

- Kevin Jaris

## Summary

In the pursuit of npm happiness I propose we update the lerna configuration in the bmw-npm library to allow individual package versioning.

## Motivation

Currently every npm package in the bmw-npm library shares the same package version. When a developer makes a major, minor, or patch code change to a single npm package every other package automatically has its version bumped.

### Detailed description

Per lerna documentation we can initialize [independent mode](https://github.com/lerna/lerna#independent-mode) which allows maintainers to increment package versions independently of each other. This will also provide us with a change log per npm package.

Steps to complete this change

1. Upgrade lerna to latest version
2. Initialize lerna as independent mode in the project
3. Upgrade all package versions to 1.0.0
4. Use carrot notation for bmw npm dependencies example: "@bmw/http": "^1.0.0"
    - This will remove the necessary version bump changes unless a major release changes is made
5. Add shared packages to the root package.json https://github.com/lerna/lerna#common-devdependencies
    - This will protect us from having multiple versions of bmw packages in our projects bundles
6. Update the shared npm account bmwnpmcd to have a password that's not same as username
7. Add these credentials to vault
8. Write script to get and use these credentials in the pipeline when publishing
9. Add separate CODEOWNERS file to each package
10. Update README with very specific versioning guidelines to follow when making changes
11. Add PULL_REQUEST_TEMPLATE.md to the project
12. Create script to generate a new package and any the corresponding pipeline/config changes needed
13. Move @bmw-lit/vehicle package into the bmw-npm library and rename it to @bmw/lit-vehicle
    - bmw-lit project is the same configuration as bmw-npm except it only has one package(vehicle). With independent versioning we should consolidate and move this package in with the rest of the bmw npm packages.

## Conclusion

This change will give users of a package a better understanding of changes based on the semantic versioning. We won't have to constantly upgrade all bmw npm packages used in our projects. When we do have to make upgrades we will be able to determine which packages we use in our project have changes and upgrade them separately.
