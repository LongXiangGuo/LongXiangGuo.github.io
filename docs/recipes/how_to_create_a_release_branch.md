---
layout: default
title: How To Create A Release Branch
parent: Recipes
nav_order: 16
---

# How to create a release branch

## (1) Create the release branch

In the [mobile-connected](https://code.connected.bmw/mobile20/mobile-connected) repository
create the new release branch named like `release/202x.xx` and push it to the server.

Example shell code for the branch name `release/2020.11`:

```bash
git checkout master
git pull
git checkout -b release/2020.11
git push --set-upstream origin release/2020.11
```

## (2) Update the Jenkins job

In the [jenkins-jobs-edge](https://code.connected.bmw/runtime/jenkins-jobs-edge) repository
edit the file [jobs/mobile20.groovy](https://code.connected.bmw/runtime/jenkins-jobs-edge/blob/master/jobs/mobile20.groovy#L74)
and add a section with the new branch name.

In case you do not need the old release branch to be built any more, it is also possible to replace the old one
with your new configuration.

Example PR for the 2020.11 release: [PR-328](https://code.connected.bmw/runtime/jenkins-jobs-edge/pull/328)

![Jenkins Job]({{site.baseurl}}/assets/images/recipes/how_to_create_a_release_branch/jenkins_job.png)

## (3) Update TARGET_BRANCH_NAME in the new release branch

In the [mobile-connected](https://code.connected.bmw/mobile20/mobile-connected) repository
within the new release Branch, update the `TARGET_BRANCH_NAME` in `./scripts/pipeline/changes_evaluator.sh`
to match the new branch name created in (1).

This should be the first PR that is done in the new release branch.

Example PR for the 2020.11 release: [PR-6783](https://code.connected.bmw/mobile20/mobile-connected/pull/6783)

![Changes Evaluator]({{site.baseurl}}/assets/images/recipes/how_to_create_a_release_branch/changes_evaluator.png)

## (4) Create the release branch in JoyUI

In the [joy-ui](https://code.connected.bmw/mobile20/joy-ui/) repository
create a release branch with the same name as the one created in the mobile-connected repository
in step (1) and push it to the server.

Example shell code for the branch name `release/2020.11`:

```bash
git checkout master
git pull
git checkout -b release/2020.11
git push --set-upstream origin release/2020.11
```

## (5) Create a tag in JoyUI

In the [joy-ui](https://code.connected.bmw/mobile20/joy-ui/) repository on your new
release branch, add a tag which uses the release branch name as a prefix and push that
tag to origin. Do not use the same name as the release branch for this tag.

Example code for `release/2020.11.1`:

```bash
git checkout release/2020.11
git tag release/2020.11.1
git push --tags origin
```

Verify in your browser that the tag was pushed to the server on the
[joy-ui](https://code.connected.bmw/mobile20/joy-ui/) repository by checking the tags:

![JoyUI Tag]({{site.baseurl}}/assets/images/recipes/how_to_create_a_release_branch/joyui_tag.png)

## (6) Update platform_sdk pubspec to use the release branch version of joy-ui

In the [mobile-connected](https://code.connected.bmw/mobile20/mobile-connected) repository
within your new release branch, update the `pubspec.yaml` so that the tag created in (5)
version of joy-ui is used.

Example PR for the 2020.11 release: [PR-6784](https://code.connected.bmw/mobile20/mobile-connected/pull/6784)

![JoyUI Version in platform_sdk/pubspec.yaml]({{site.baseurl}}/assets/images/recipes/how_to_create_a_release_branch/platformsdk_pubspec.png)

## (7) Update the app version master branch

In the [mobile-connected](https://code.connected.bmw/mobile20/mobile-connected) repository
on the **master** branch, update set app version in `pubspec.yaml` to the next version. Check the
subpages of the [Releases Confluence page](https://atc.bmwgroup.net/confluence/x/GpQWN) to see
which version it is.
This will make sure that the app builds in AppCenter are grouped together correctly.

Example PR for the 2020.11 release: [PR-6785](https://code.connected.bmw/mobile20/mobile-connected/pull/6785)

![App Version in pubspec.yaml]({{site.baseurl}}/assets/images/recipes/how_to_create_a_release_branch/pubspec_app_version.png)

## (8) Send a message to the community in Teams

Send a message to the community in the [Teams Channel](https://teams.microsoft.com/l/channel/19%3ac789457b17e24d98a695cb0f6f327a7b%40thread.skype/Allgemein?groupId=ac9f3e4c-3a1b-4c4d-bc35-12eba2928619&tenantId=ce849bab-cc1c-465b-b62e-18f07c9ac198) to inform them about the new branch.

## (9) Send an email to the community

Send an email to the community to inform them about the new branch:

Template from the 2020.07 branch:

```text
To: DL-EADRAX-DEVTEAMS <EADRAX-DEVTEAMS@list.bmw.com>
CC: DL-EADRAX-PMOTEAM <EADRAX-PMOTEAM@list.bmw.com>; DL-EADRAX-PO <EADRAX-PO@list.bmw.com>

Hi all,

We just created the release branch: release/2020.07. So master is now ready for 9/20 work :)

Next Steps

Please check whether any changes that you merged in the last hour were already merged to master before we created the release branch.

If they are missing on the release branch:
- Create a new branch based on the release branch
- Cherry-pick your changes (git cherry-pick <commit-id>)
- Create a PR which targets the release branch

Last commits on master before we created the release branch:
- [3b018e5551, Miguel Teixeira] Force text scale factor (#4097)
- [8e5dd0e17f, Alexander Senkin] [NWAP-12532] Create SIDs for new error cases (#4067)
- [a536266e04, Fabian Rother] Nwap 12369 poi zoom fix (#4085)
- [fef6076f59, Noe Fernandez] Fix/nwap 11391 map pin sizes (#4071)
- [130598d409, Alexander Senkin] [NWAP-10548] Create redirect mno page (#4050)
- [e431f58754, Vishwanath Muddu] [NWAP-10815] Add analytics for dealer search (#3670)

Future PRs

If you have any bug fixes for the release branch:
- Create a new branch based on the release branch
- Commit your changes
- Create a PR for the release branch
Only after the PR is merged:
- Cherry-pick your changes from the release branch to master and resolve any conflicts
- Create a PR for master

Please check on a regular basis if you missed cherry-picking your release branch commits for master:
https://code.connected.bmw/mobile20/mobile-connected/compare/release/2020.07?expand=1


App Center Builds

App Center builds from the release branch have the prefix 'Eadrax DST' e.g. https://install.appcenter.ms/orgs/Eadrax/apps/Eadrax-DST-BMW-RoW-PROD
Please note, they are only available for some configurations.

Please reach out if you encounter any issues.
```
