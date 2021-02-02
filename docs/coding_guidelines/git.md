---
layout: default
title: Git
parent: Coding Guidelines
nav_order: 1
---

# Git Coding Guidelines

[Git](https://git-scm.com) is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

For **Mobile 2.0**, the `core` team enforces the use of `Pull Requests` (PR) as a mechanism to review the code before it can be added to the `master` branch. The goal behind it is to allow a **productive and constructive** discussion around code quality and practices not captured in a pipeline, allow others to ask questions and give feedback, and maintain a high quality standard in our codebase.

## Commit Messages and Pull Requests

When opening a PR: Please fill out the pull request form. Also add the ticket number to the pull request title to provide more information to the reviewers e.g. `[NWAP-123] Travel back to the future`.

### Commit Messages

- First line should have ticket in square brackets and a summary in imperative mood
  - If there is no ticket (which should be an exception!) use the [NO-TICKET] prefix
  - Second line should be empty
- All following lines should have the sub-tasks in past tense

```
[NWAP-123] Change flux-capacitor level

* Changed flux-capacitor level
* Increased version number to next prime number
```

```
[NO-TICKET] Super-small, very, very tiny changes to flux-capacitor level

* Changed flux-capacitor level
```

## Review

## Git Strategy

![branching strategy]({{site.baseurl}}/assets/images/mobile20_branching_strategy.png)

We follow `Trunk-Based Development`, a source control branching model, where developers collaborate on code in a single branch (often called `trunk` or `master`) resist any pressure to create other long-lived development branches by employing many other `documented` techniques, like [feature toggles](http://suus0001.w10:8090/display/ARC/Feature+Toggles). They therefore avoid merge hell and don't break the build, so we can live happily ever after.

[Trunk-Based Development](https://trunkbaseddevelopment.com) is a key enabler of continuous integration and continuous delivery. When individuals on a team are committing their changes to `master` multiple times a day it becomes easy to **satisfy the core requirement of Continuous Integration that all team members commit to `master` at least once every 24 hours**. This ensures **the codebase is always releasable on-demand** and helps to make Continuous Delivery a reality.

### The workflow

**Every piece of work is started in a branch**, whether it is a bug or a feature. **The smaller** the amount of work is, **the better**. Once you are done with your changes, open a PR, so others can give you feedback. If during the PR, other folks ask you to modify the code submitted, you can add more commits to the same branch, and it will update the PR. If at any time you have _merge conflicts_, you can fix them locally, and then push again your changes to update the PR.

#### Branch overview

- **master** contains all the code that has been reviewed and approved. Releases to the different stores are annotated with `git` annotations.
- **feature**, **bugfix**, etc. represents work in progress branches. Once the work has been completed on one of these branches, a PR must be opened. Once the PR has been reviewed and merged, this branch **must be** deleted from the repository.
- **release** represents a short lived branch intendend to provide the last iterations before a release. Commits added to this branch are **taken from master**, not the other way around. In addition, there should never be more than a single release branch at any given point in time.

## Recommended Git Commands

If you run `git` from the terminal, these commands will be recommended to use (use others only if you consider yourself a `git` expert):

- `git checkout -b your_branch`: create a new branch called _your_branch_.
- `git checkout your_branch`: change the current branch to _your_branch_.
- `git add path_to_add`: it stages the changes in _path_to_add_. Most of the times, `path_to_add` will be `.`, since you might want to stage all the changes under that directory.
- `git commit -m "MOB-xxx: Your commit message here"`: it creates a new entry on the `git` history identified with the _message given_.
- `git push origin your_branch`: it pushes the local changes to _your_branch_.
- `git pull origin your_branch`: it downloads the changes of the `your_branch` from a shared repository
- `git push -f origin your_branch`: it rewrites the history of the shared repository with your local changes. **USE ONLY** when working with feature/bugfix brnaches.
- `git rebase other_branch`: Rebasing is the process of moving or combining a sequence of commits to a new base commit. Rebasing is most useful and easily visualized in the context of a feature branching workflow. . More information about rebasing here: [Git Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)

![rebase rebasing]({{site.baseurl}}/assets/images/rebasing.svg)
