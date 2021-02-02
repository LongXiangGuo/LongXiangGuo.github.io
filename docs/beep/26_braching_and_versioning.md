---
layout: default
title: "BEEP-26 Branching and versioning"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 26
---

# BEEP-26: Branching and versioning

### Authors

- Robert Magnusson <Robert.Magnusson@bmw.de>
- Emran Bajrami <Emran.Bajrami@bmw.de>

## Summary

This is a proposal for the branching and versioning strategy of the Mobile2 client.

## Motivation
The current trunk-based branching strategy defined in [How to use git](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/onboarding/how_to_use_git/) only works well under the assumption that features can be controlled by fine-grained Feature Toggles. Because in its current state the myBMW app does not support Feature Toggles, it is required to define a branching strategy which is going to work with our current setup.

With trunk-based development, all features which are developed are merged into one branch (`master` in our case). Since not all developed features are release-ready, we need to have them turned off dynamically or during the build process. In order to enable working on parallel features which don't have the same release date, we want to introduce a branching strategy which supports this.

The branching strategy proposed in this BEEP is the already well known strategy called [`git-flow`](https://nvie.com/posts/a-successful-git-branching-model/).

## Branching for 7/20 release
In order to adopt `git-flow`, it is required to create a release branch when features are ready to go to the downstream testing. In order to do that, from the current main branch (`master`), a new release branch (e.g. `release/1.0`) is going to be created. At the same time `develop` branch is going to be created. Afterwards all new features are going to be merged to the `develop` branch. To conform to git-flow conventions master is renamed to develop.

Based on the feedback from the downstream testing team, new bugfix branches can be created which are going to be merged in parallel to the `developer` and to the active release branch. After releasing the app to the App Store/Play Store, changes are merged back to the `master` and `develop` branches (with tag created on the release).

## Versioning
We propose that release branches are named based on the month and year when the release was created. For example, the first release branch is named `release/2020.07`.

The reason behind the proposed versioning is that the version name is not bound to the marketing release names. For example, we are not sure if the first release of Eadrax is going to be 1.0 or 2.0 so we can create a release branch independently of its final release version. Also, the proposed versioning follows the BMW release naming standard widely used in release discussions.
