---
layout: default
title: How to Build and Distribute iOS for Mobile Connected
parent: Recipes
nav_order: 4
---

# How To Build and Distribute iOS for Mobile Connected

## Pre-requisites

1. Setup Xcode with the mobile provisioning profiles for doing the Integration and Production builds.

   1. To do this you must disable 'Automatically manage signing' by unchecking that box
      ![Disabled Auto Signing]({{site.baseurl}}/assets/images/build_ios_disable_auto_signing.png)
   2. Find the Release configurations for INT and PROD; NA, ROW and KR. Click on the Provisioning Profile picker and select Import. Mobile Provisioning Profiles can be downloaded to any directory, just remember where you store them so you can reference them in this step.
      ![Example iOS KR INT]({{site.baseurl}}/assets/images/build_ios_kr_int.png)
   3. Once Imported you are ready to move on to the next step
      ![Example iOS NA INT]({{site.baseurl}}/assets/images/build_ios_na_int.png)
      ![Example iOS ROW INT]({{site.baseurl}}/assets/images/build_ios_row_int.png)

2. Pull latest mobile-connected repo
3. Note the last build number from [Appcenter](https://appcenter.ms/orgs/Connected-2.0/applications?release_type=All)

## Building iOS

These steps assume that the Pre-Requisites have been completed.

1. Be at the root directory of the mobile-connected repo
2. Run `dart ./scripts/cli/cli.dart buildIos --buildName=x.y.z --buildNumber=n` where buildName is the Major.Minor.Patch version and buildNumber is the specific number for the build you're about to generate
3. Console output will show progress
4. Run `ls build`. You should see ipa directories for the INT and PROD flavors created
5. You are ready to move on to the Distribute iOS step

### Tips for Dealing With False Xcode Build Failures

When running the `Building iOS` steps, it is possible that the build will err out with potential linker related errors. These are false errors. The following can be done to "right the ship" with Xcode.

1. If you're running these steps, you should have Xcode open with Auto Signing disabled and provisioning profiles correctly setup
2. In Xcode pick one of the INT or PROD build flavors and do a deep clean. A deep clean can be down by holding `Command+Option+Shift+K`.
3. Then do a build with that INT or PROD build flavor. The build should complete successfully
4. Now re-run `dart ./scripts/cli/cli.dart buildIos --buildName=x.y.z --buildNumber=n`.
   1. IMPORTANT!! If some flavors have succssfully built, the script will detect this and move on to the ones that have not. You will need to run the dart step as follows: `dart ./scripts/cli/cli.dart buildIos --buildName=x.y.z --buildNumber=n --disableFlutterClean`.
   2. Failure to include `--disableFlutterClean` will result in all successful builds being wiped

## Distribute iOS

1. Be at the root directory of the mobile-connected repo
2. Run `dart ./scripts/cli/cli.dart distributeIos`
3. Check [Appcenter](https://appcenter.ms/orgs/Connected-2.0/applications?release_type=All) to validate that the INT and PROD builds were correctly distributed to Appcenter.
