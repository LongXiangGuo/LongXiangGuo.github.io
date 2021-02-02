---
layout: default
title: How To Setup A New Firebase Push Notification Environment
parent: Recipes
nav_order: 15
---

# How To Setup A New Firebase Push Notification Environment
## Create the project
1. Retrieve the firebase credentials from `secret/mobile20/firebase_console`
2. log on to console.firebase.com 
3. Click on "Add Project"
![Add Project]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/add_project.png)
4. Enter the name of the project
   - The convention we've followed is `eadrax-[brand]-[region]-[environment]`
   - Example: **eadrax-bmw-na-dev**
5. Enable google-analytics usage for firebase messaging


## Add iOS 
1. Click on the project's settings gear icon:
![Settings Gear]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/settings_gear.png)

2. In the "Your Apps" section, click iOS
![Your Apps]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/your_apps.png)

3. On the **Register App** section, you'll need to enter the bundle ID information for the flavor.
   - This should be retrieved from the corresponding `.xcconfig` file in the project. 
![Bundle Id]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/ios_bundle_id.png)

4. Nickname your app using `[BRAND] [REGION] [ENVIRONMENT]`
   - Example: **BMW NA DEV**
5. Click **Register App**
6. Download the config file
![Download Config]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/download_config_ios.png)

7. Replace/create the corresponding plist in the project at `/ios/Runner/[environment]`
![Plist]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/plist.png)

8. Follow the directions on [Non Standard docs]({{site.baseurl}}/docs/nonstandard_docs/) for retrieving the push auth token from vault.
9. In the new firebase project's settings section, select **Cloud Messaging**
10. Click on **Upload** within the **iOS App Configuration** section
![Auth key]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/upload_auth_key.png)

11. Upload your auth key and copy the values into the dialog
![Auth key 2]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/upload_auth_key_2.png)


## Add Android
1. Click on the project's settings gear icon:
![Settings gear]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/settings_gear.png)

2. In the "Your Apps" section, click Android
![Your apps]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/your_apps.png)

3. On the **Register App** section, you'll need to enter the package ID information for the flavor.
   - This should be retrieved from the `android/app/build.gradle` file in the project. 
![Package Id]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/android_package_id.png)

4. Nickname your app using `[BRAND] [REGION] [ENVIRONMENT]`
   - Example: **BMW NA DEV**

5. Click on **Register App**
6. Download the config file
![Download Config]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/download_config_android.png)


7. Replace/create the corresponding json in the project at `/android/app/src[environment]`
![Json]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/json.png)


## Sending a test push
1. Launch the app and inspect the console logs for `FCM Token: xxxxxxxx`
2. Copy that token to the clipboard
3. In firebase, click on the **Cloud Messaging** section
![Cloud Messaging]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/cloud_messaging.png)

4. Click on **Send your first message**
![First Message]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/first_message.png)

5. Fill out notification details (Title and text required)
![Test Details]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/test_notification.png)

6. Target your test device by clicking **Send Test Message**
![Device Select]({{site.baseurl}}/assets/images/architecture/push_notifications/setup/test_device_selection.png)

7. Click **Test** and hope that it shows up on the device!
