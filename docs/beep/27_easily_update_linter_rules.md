---
layout: default
title: "BEEP-27 Easily update linter rules"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 27
---

# BEEP-27: Easily Update Linter rules

### Authors

- @JoEssin
- @KevinJaris

## Summary

Dart's language services point out errors in the code which show up in the code editor's "Problems" section. In addition, the Dart language services include a static analyzer and linter which points out code smells, todo comments, and style mistakes. These hints also show up in the "Problems" section of VSCode and other code editors. For the `mobile-connected` repository, there are almost 200 "Todo's" which show up as "Problems." This is not only misleading but a huge source of clutter when you are quickly trying to see current coding errors while actively programming.

## Motivation

Seeing Todo's show up as "problems" is problematic by definition, as Todo's represent work to be done later, not a "problem" or error which should prevent the build process. Typically, code editors only show "problems" as coding mistakes or glaring style mistakes which indicate that you cannot (or should not) build the project.

Rather than see them appear in the "problem" pane, developers have historically searched the code for "TODO" comments or used other tools to find them in the code. I believe that is the correct solution once again for our projects here.

### Detailed Description

![Todo's showing up as problems]({{site.baseurl}}/assets/images/beep_27_todo_linter_problems.png)

Dart's linter looks at a package's `analysis_options.yaml` file in the root directory of the package to determine what linter rules to apply when analyzing that package's code. By adding the following lines to an `analysis_options.yaml` file we can prevent the Todo's from showing up as problems:

```yaml
analyzer:
  errors:
    todo: ignore
```

It must be stated that there are a large number of `analysis_options.yaml` files spread throughout the `mobile-connected` repository. A quick `find . -name "analysis_options.yaml"` produces a staggering 140 files, one for every module (at least) inside the `platform_sdk` and `feature_modules` directories.

Unfortunately, in the current system, making even a small change to the linter rules requires every file to be updated. Further, you would have to make the change in other projects written in Dart since changing those 140 files would only fix the linter rules for the mobile-connected repository.

If you wish to improve the linter rules for BMW's Dart code, you will quickly experience the unfortunate side effect of needing to **change every `analysis_options.yaml` file in every repository**, which easily means needing to change *hundreds* of files and getting approval for *every repository*!

The problem is further compounded by the fact that the [generator-flutter-feature-module](https://code.connected.bmw/runtime/generator-flutter-feature-module), which generates feature modules to be placed inside the `mobile-connected` repository, automatically generates projects which have their own independent `analysis_options.yaml` file.

Naturally, there is a much better way to go about this. By placing our linter rules in their own package and referencing them in every `analysis_options.yaml` file, we can easily make changes to the linter rules which propagate automatically to existing packages. Additionally, we can release versioned updates (if necessary) that allow repositories using our BMW linter rules to opt-in to newer versions when their code owners have time to update them.

The following section describes the proposed steps for solving the linter rule problem:

#### Custom Dart Package
First, we should create a new dart package for storing our custom linter rules in a new repository based on the structure of other linter rule packages like [effective_dart](https://pub.dev/packages/effective_dart). We will refer to this package in what follows as `bmw_dart`.

Our package can, in turn, base itself off of other existing Dart packages, like `effective_dart` mentioned above (something we already do currently). In addition to borrowing those existing rules, we can provide our own overrides. If deemed necessary, we can even make different versions of our rules by including multiple versions of the `analysis_options.yaml` file ([for reference, look at the project structure](https://github.com/tenhobi/effective_dart/tree/master/lib) of `effective_dart`). This will allow packages utilizing our rules to opt-in to newer versions of our style changes as needed, rather than causing old code to appear riddled with style mistakes whenever the rules are updated.

#### Update the Generator
Secondly, we should update the [generator-flutter-feature-module](https://code.connected.bmw/runtime/generator-flutter-feature-module) which creates new feature modules for the connected app.

Currently, the generator contains a template `analysis_options.yaml` file which is copied for every feature module. The template `analysis_options.yaml` in the generator must be updated to import the contents of the `bmw_dart` rules so that future feature modules always have the latest linter rules.

#### Update All `analysis_options.yaml` Files Everywhere

The reader has probably realized by now that this change will require every `analysis_options.yaml` file already in existence to be updated to reference the `bmw_dart` rules. Unfortunately, there is no way around this. It is probably unrealistic to think that this would happen all at once. Instead, it would likely occur on a repository-by-repository basis as code owners updated their respective projects.

### Pros and Cons

The following is a summary of the benefits and drawbacks proposed by this BEEP:

Pros
- Linter rules can be easily changed in one place.
- Rule changes can be closely monitored by lead developers to prevent less-than-desirable rule changes from being approved or going unnoticed in other projects.
- All projects referencing no particular version of the rules will automatically receive the latest rules whenever packages are fetched (a frequent occurrence).
- Developer friction with tooling will be drastically reduced by making rule changes automatic (or opt-in if necessary) without requiring developers to update every `analysis_options.yaml` file in every project everywhere.
- Different versions of rules can be provided to prevent older code from cluttering up the "Problems" pane. When code owners have the time, they can update their code and remove the specific version of the linter rules package to opt-in to the latest rules.
- Assuming the `bmw_dart` rules package is setup correctly, future feature modules will automatically be generated to use the latest rules without any changes to the generator.

Cons
- Every `analysis_options.yaml` file everywhere must be updated one time.
- The feature module generator mentioned earlier must be updated to produce the correct `analysis_options.yaml` file.
