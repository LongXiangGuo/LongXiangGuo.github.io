---
layout: default
title: How to use git
parent: Onboarding
nav_order: 2
---

# How to use git

[Git](https://git-scm.com) is an open source distributed version control tool, that works efficiently with projects of any scale.

Our code is hosted in a self maintained instance of Github Enterprise: [code.connected.bmw](https://code.connected.bmw)

You will need to have a Github account, that should have been previously created for you. If this is not the case, please talk to your team lead, or with the Runtime team.

## Git @ BMW

Each company uses different Git strategies, that are most of the times tightly coupled to how the code is released to production. It is our ambition to release our Connected 2.0 clients as often as possible, and that's why we follow [trunk-based development](https://trunkbaseddevelopment.com).

## Terms to know before

- Repository - Where the code for a particular project is located
- Branch - A branch is like a 'timeline' for changes in your project/code. Branches can "branch" out of other branches as we will see bellow. Note: Timeline is refered to how changes are one after another not in the regular sense since changes that happen today can be put in front of changes that happen tomorrow.
- Master/Master Branch - The main branch (You should never push code directly to Master. You should always create your own branches to make changes to the codebase)
- Merge - Merging is when you combine the code/changes of two branches (Sometimes you will have Merge Conflicts which happen when changes in two different branches conflict with each other)
- Add - Preparing your changes to be saved
- Commit - Saving your changes. These commits make up the history in your branch. Note: Git allows you to 'rewrite' history but you almost never want to do that because it can often lead to a giant mess.

### Trunk-Based development

Our goal by following this Git strategy is:

- To avoid long-running branches
- To consider all code merged to _master_ "shippable (or turned off by using feature flags, or different backend configurations)
- To facilitate code reviews: the smaller the changes are in code, the better for everyone
- To use tags to control the different levels of our deployment process

Trunk-Based Development is a key enabler of Continuous Integration and by extension Continuous Delivery. When individuals on a team are committing their changes to the trunk multiple times a day it becomes easy to satisfy the core requirement of Continuous Integration that all team members commit to trunk at least once every 24 hours. This ensures the codebase is always releasable on demand and helps to make Continuous Delivery a reality.

### Adding your SSH keys

Before using Git, make sure you have added your SSH keys to your Github Enterprise profile. This guide explains how to do it: [Connecting to Github with SSH](https://help.github.com/articles/connecting-to-github-with-ssh/)

### Set up Two-Factor Authentication

Log in to your [GitHub](https://code.connected.bmw/settings/security) and enable Two-Factor Authentication.

_IMPORTANT: Don't forget to save your recovery codes_

### Most useful Git commands to be used in the terminal

- `git pull origin master`: used to fetch the latest changes in the _master_ branch.
- `git checkout -b your_branch_name`: used to create a branch with the name _your_branch_name_, where you will make code changes.
- `git add .`: this will stage all the code changes in the given directory, in this case "." (current directory)
- `git commit -m "[NWAP-XXX] Your commit message"`: this will commit the changes staged previously along with a log message describing the changes. It is a good practice to add the ticket number and the title to better understand the nature of the changes, and create a nice and clean Git history.
- `git push origin your_branch_name`: this command will push the code changes of the branch into your remote, (e.g. our code repository). From here, you will be able to open a Pull Request (PR)
- `git log`: to see the history of the project.
- `git rebase origin/master`: when your branch is not up to date with master, you can rebase in order to get the latest code changes, and resolve any possible merge conflicts. Call `git fetch` before to make sure your remote is updated. We provide also a [cheat sheet](#pro-tip-rebase-cheat-sheet).
- `git fetch --prune` clean up deleted branches that have been deleted on remote. This does not remove branches you have locally checked out.

### Sourcetree as a graphical Git client

[Sourcetree](https://www.sourcetreeapp.com/) is GUI client for Git. If you are not a big fan of the terminal, download the app and enjoy the benefits of a graphical Git interaction.

### How to open a Pull Request (PR)

Once you feel you are done with your code changes, it is time to open a Pull Request. A PR is the mechanism to let others know that you've pushed changes to a branch in a repository, so the changes can be discussed and reviewed, while running the all pipeline checks.

Other contributors can review your proposed changes, add review comments, contribute to the pull request discussion, and even add commits to the pull request.

After the reviewers and you are happy with the proposed changes, you can merge the pull request.

More information about Pull Requests can be found [here](https://help.github.com/articles/about-pull-requests/)

### Pro-Tips: Cheat-sheet <a name="pro-tip-rebase-cheat-sheet"></a>

#### Rebasing

![rebase schema]({{site.baseurl}}/assets/images/rebasing.svg)

- Stage (add) and commit and push all changes to the remote feature branch

  ```bash
  git add .
  git commit -m "<your-ticket-number>: some message"
  ```

- Fetch all changes (if any)

  ```bash
  git fetch
  ```


- Navigate to the project root directory (that contains the .git folder)

Note: `origin/master` below represents the branch you want to base you change on top of. In this case current version of master in the origin remote. You can also rebase onto local branches `git rebase myBranch` or any other remote branch `git rebase origin/release/myRelease`.

  ```bash
  git rebase origin/master
  ```

You may get conflicts at this point, if so, you will see something similar to the following:
CONFLICT (content): Merge conflict in (lib/home/home_page.dart for example)
NOTE: When resolving conflicts... pay SPECIAL attention to incoming vs. head changes!!

Fix the conflict(s)... (in VSCode for example, save files), then:

- Stage (add) all changes to the remote feature branch

  ```bash
  git add .
  ```

- Continue the rebase

  ```bash
  git rebase --continue
  ```

- If for some reason trying to rebase is a mess or you don't know what you are doing you can always use:

  ```bash
  git rebase --abort
  ```

As this point, you may see additional conflicts. If you do, repeat the 'fix conflicts', 'git add', and 'git rebase continue' steps until you have no more conflicts.

- Verify that all of your branch commits are above the latest **master**

  ```bash
  git log
  ```

- To finish up, force push the rewritten history

  ```bash
  git push -f
  ```

#### Reverting a single commit

- Find the commit SHA of the offending commit
  - If you're using SourceTree, you can right-click on the commit to copy the SHA into the clipboard
- Paste the commit SHA into the terminal

  ```bash
  git revert <commit-SHA>
  ```

#### Reverting an entire PR

- Find the commit SHA of the merge commit from the offending PR into **master**
  - If you're using SourceTree, you can right-click on the commit to copy the SHA into the clipboard
- Find which number you need to use for the '-m' parameter
  - This specifies which branch is the base parent within `1..n` branches for the **revert**
  - _Assuming you want to leave **master** alone and just remove the PR, use `-m 1`_
- Paste the commit SHA into the terminal

  ```bash
  git revert -m <parent-#> <commit-SHA>
  ```

For example, to remove an entire PR from master:

```bash
git revert -m 1 <commit-SHA>
```

#### Adding a Tag

Tags are useful when you want to add versions to your project

- Make sure you're in the master branch

```bash
git branch
```

- If not then switch to master

```bash
git checkout master
```

- Make sure you have the latest changes and versioning/tags from master

```bash
git pull origin master
git pull
```

- Check the current version

```bash
git log
```

- Add your new tag/version

```bash
git tag <version>
```

- Push the tag to master (Note: This is not the same as pushing code to master. This is simply pushing metadata)

```bash
git push <version>
```

**You can also create release tags on the Github website:**

1. Go to the **release** tab on your repository page
2. Click on **Create a new release** or **Draft a new release**
3. Fill out the form and click **Publish release**
4. Make sure to pull these new changes to your local project!
