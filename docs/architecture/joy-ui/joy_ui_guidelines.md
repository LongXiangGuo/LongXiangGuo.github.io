---
layout: default
title: JOY UI Guidelines
parent: JOY UI
grand_parent: Architecture
nav_order: 2
---

# JOY UI Guidelines

> **Any issues not covered in these guidelines should be brought to the Architecture and Design Circles.**

---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Mobile-Connected Integration

* **master:** Use a commit id
* ***Release branches:** Use a tag specific to the release branch e.g. release/2020.11.1

---

## General Guidelines

* Design specs must be reviewed as early as possible to separate atomic from composed widgets.
* A specific backlog for all widget development work should be established.
* All user stories for widgets, whether implemented in Joy UI or in a feature module, should use a specific label: `ui-component`and `joy-ui-component`.
* Before implementing a new widget, and before deciding where to house the implementation, feature teams should search for the label, `ui-component`and `joy-ui-component`, to find out if work on the widget is already planned, in progress or complete.
* New widgets should first be implemented in the feature module where they will be used, unless it can be shown beforehand that multiple feature modules will use the same widget.
* If a feature team needs a widget that already exists in another team’s feature module, it should contact the team responsible for that module and organize the migration to Joy UI with them. Who/When/How the widget is migrated to Joy UI should be sorted between the teams that need the widget. Any refactoring work to the widget should also be sorted between teams that need the widget.

## Exceptional Guidelines

In very exceptional cases, there may be a need to modify a native Flutter or 3rd party widget. These are last resort options. If in doubt, contact the architecture or design circle.

### Flutter SDK Widgets

* House the extracted widget in the `flutter_native_widgets` folder in Joy UI.
* Be sure to also copy the corresponding test(s) files into Joy UI.
* While test coverage is ignored in these cases, make sure all known use cases are tested and any broken tests are fixed.
* Evaluate if the customizations done to the widget can be submitted, as an issue or PR, to the original Flutter package.
* Ensure that the customized widget is still needed when updating to a newer version of the Flutter SDK.

### 3rd-Party Widgets

* Ensure that the 3rd-party package is of high quality. Looking at its stats from pub.dev is a good starting point.
* If the changes needed to the 3rd-party widget are minimal, try contacting the maintainer(s) of the package, by opening an issue or a PR on their repo, to see if they accept the customizations.
* A review and approval of the License information is needed by the legal department before forking a 3rd-party package.
* If a separate repo needs to be created to house a 3rd-party package, it still must follow these guidelines. It must have the same code owners and the same Jenkins stages as JOY UI.
* While test coverage is ignored in these cases, make sure all known use cases are tested and any broken tests are fixed.
* Ensure that the customized widget is still needed when updating to a newer version of the 3rd-party package.

---

## Foundation

### Responsiveness and Scalability

* To grant the best user experience Joy UI needs to be responsive to different screen sizes, font sizes and scale factors. The current page which provides different scale factors for components can be found here [Responsiveness and Scalability](https://atc.bmwgroup.net/confluence/display/JOYDG/Responsiveness+and+Scalability).
* For TextScaling use the widget `MediaQuery`. Use the data property to add `data: MediaQuery.of(context).copyWith(textScaleFactor: yourOwnImpl)`. For fix scale factors there is a file called `scale_factor_constants.dart` in the JoyUI Repo.
