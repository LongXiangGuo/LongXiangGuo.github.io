---
layout: default
title: How To Build Mobile 2 for App Store
parent: Recipes
nav_order: 13
---

# How to build Mobile 2 for App Store

## Prerequisites

* Access to the following role in Vault: `mobile20-appstore`.

## Triggering the app store pipeline

The app store pipeline is configured to only create and upload a new build when triggered manually. It will be started automatically by branch and push events from GitHub but will fail immediately. This section walks you through the steps of triggering the app store pipeline manually.

1. Navigate to the [app store build job on Jenkins](https://jenkins.build.connected.bmw/job/mobile20-mobile-connected-distribute-appstore/) in your browser.

   ![Branch overview]({{site.baseurl}}/assets/images/architecture/recipes/build_for_store/jenkins_appstore.png)
2. The build job will automatically pick up all branches matching `release/*`. Select the desired branch from the list.
3. If you would just like to build the latest commit of the selected branch, click *Build now* in the left-hand menu. To select a specific commit, click on *Changes* and select the run that has been automatically triggered for the desired commit. Then click *Replay* and *Run*.

   ![App store build job on Jenkins]({{site.baseurl}}/assets/images/architecture/recipes/build_for_store/jenkins_build_now.png)
4. This will trigger the pipeline to run for the specified commit. Now depending on what you chose above Jenkins already shows you the page for this pipeline run or you need to select it from the list of runs on the left. Then click *Open Blue Ocean* in the left-hand menu.
5. After a little while, the pipeline should reach the *Configure build* step.

   ![Configure build]({{site.baseurl}}/assets/images/architecture/recipes/build_for_store/jenkins_enter_token.png)

   [Open vault in a new tab]([https://](https://secrets.connected.bmw/ui/vault/secrets)) and make sure you are signed in with the role *mobile20-appstore*. Copy your token by clicking the avatar icon in the top right and selecting *Copy token* from the menu.
   Switch back to the Jenkins pipeline, paste token in the input box and click *Proceed*.

   **Note:** There is a 60 seconds time out for entering a token. Should you not manage to enter a token within this period, the run will fail. Just replay it by clicking on the circular icon in the Blue Ocean menu bar.

6. The pipeline is now building the app store flavors of the apps and uploading them to Google Play and Apple TestFlight. Once upload is completed, the build can be made available to internal testers on Google Play and Apple TestFlight.

   **Note:** Apple takes a while to process a new upload. It will already be visible on the *Activities* tab but the build will not show up on the *TestFlight* tab until initial processing has completed which usually takes around 10 minutes.


## FAQ

### Where can I find the pipeline script?

The pipeline script is called `Jenksfile_appstore` and has been merged to all current release branches and [master](https://code.connected.bmw/mobile20/mobile-connected/blob/master/Jenkinsfile_appstore).

### How can I control which combinations are being build by the pipeline?

The pipeline script uses a `matrix` build step to build the different flavors (around line 114).

```Jenksfile
matrix {
      axes {
         axis {
            name 'PLATFORM'
            values 'ios', 'android'
         }
         axis {
            name 'BRAND'
            values 'BMW', 'MINI'
         }
         axis {
            name 'REGION'
            values 'ROW', 'KR' //, 'NA', 'CN'
         }
      }
      options {
         ...
      }
      stages {
         ...
      }
}
```

Mobile 2 builds are typically defined by three components: platform, brand, region (four if you also count the environment, but as the pipeline is only targeting app store builds, the environment is hard coded to `appstore`). For each component (*axis* in `matrix`-speak) we have a couple of possible values and want to build all combinations of all values of all components. The `axes` section in the above code-snippet defines exactly that: All possible values for each of our three components.

If you would like to exclude certain values for replaying a specific build, the easiest way is to just remove them from the list of values in the axis definition. To remove certain combinations only (e.g. build all iOS and Android apps for all brands and regions except MINI ROW) the `matrix` step also offers an [`excludes` keyword](https://www.jenkins.io/doc/book/pipeline/syntax/#matrix-excludes).

### How can I add/replace a signing certificate for iOS?

The iOS signing certificates are stored in a base64-encoded Keychain container in Vault at `secret/mobile20-appstore/ios/build_certs`.

**Note:** You need to be signed in to Vault CLI with role *mobile20-appstore* for the following steps to work.

1. Download the keychain to your local computer using `vault kv get -field=keychain_b64 secret/mobile20-appstore/ios/build_certs | base64 --decode > ios-appstore.keychain-db`
2. Import the keychain into the Keychain Access Utility and unlock the keychain (the password can also be found in Vault)
3. Add or replace the desired signing certificate or private key.

   **Note:** When adding a new private key, make sure to make it accessible to all applications.
4. Base64-encode the keychain using `base64 -i ios-appstore.keychain-db | pbcopy`. This will copy the encoded data into the clipboard.
5. Replace the existing data in field `keychain_b64` under `secret/mobile20-appstore/ios/build_certs` with the clipboard contents using the Vault web interface.

   **Note:** Be careful with using the `vault write` command as it is very easy to loose data this way. It cannot be used to update individual fields! Instead the existing data on the given path will be wiped and only the specified key/vault pairs will be written to the path. If unsure, just use the web interface to add or update data.

### How can I add/change a signing certificate for Android?

**Note:** As the upload keys can only be changed once per lifetime for an app published at Google Play, the keystore data should not be tampered with.

The Android signing certificates are stored in a base64-encoded JKS keystore in Vault at `secret/mobile20-appstore/android/signing_keys`. It already contains signing configurations for all regions and brands.

**Note:** The pipeline builds and uploads an App Bundle to Google Play. This means for ROW, NA and KR, the Keystore merely contains the upload keys. The signing configuration used for the APKs generated by the Google Play out of the bundle is managed in the Google Play Console.

### How can I change an API Key for the app store flavors of Mobile 2?

API Keys for the app store flavors are stored under `secret/mobile20-appstore/api_keys/` in Vault.

### How does the pipeline match the IPA file to a store entry on upload?

Matching for iOS happens via the *Apple ID* (not to be confused with Apple's SSO service) which is a numeric identifier for an app entry in AppStore Connect. It can be found in AppStore Connect under the *General information* section on the app entry's *App Info* sub-page. The pipeline performs a mapping from *Bundle Id* to *Apple ID* with the help of Vault at `secret/mobile20-appstore/ios/apple_id`.