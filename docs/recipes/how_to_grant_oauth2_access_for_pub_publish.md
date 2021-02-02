---
layout: default
title: "How to Grant OAuth2 Access for Pub Publish"
parent: Recipes
nav_order: 8
---

# How to Grant OAuth2 Access for Pub Publish

### Authors

- Xinfeng Ma

## Summary

Document the recommendation on how to grant oauth2 access for Dart publish package command `pub publish` so that it can be done through CI/CD pipeline.

## Motivation

`pub publish` command requires you to grant it oauth2 access, which requires:

- a Google account
- oauth2 scheme

Based on [OAuth2.0](https://developers.google.com/identity/protocols/OAuth2), all application scenarios need user login and consent, which means the manual step is a must in order to get access token for publishing package. The only exception is `Service accounts`, however it cannot be used for this case because user information(email) needs to be retrieved for publishing package, so the spike becomes whether there is a semi-automatic approach to grant oauth2 access so that it can be used in CI/CD pipeline.

### Detailed Description

The fact that command `pub publish` looks for file `FLUTTER_HOME/.pub-cache/credentials.json` for authentication information provides us a feasible solution as described below:

1. Create a dedicated google developer account for CI/CD.
2. Get the initial content of `credentials.json` by publishing a Dart package:

   - running the following command:

   ```sh
   flutter packages pub publish --server 'http://pubdev.centralus.cloudapp.azure.com:4000/'
   ```

   - console output is something like:

   ```sh
   Publishing firebase_push_notification 0.0.4 to http://pubdev.centralus.cloudapp.azure.com:4000/:
   |-- .gitignore
   |-- .metadata
   |-- CHANGELOG.md
   |-- LICENSE
   |-- README.md
   |-- lib
   |   |-- firebase_push_notification.dart
   |   '-- src
   |       |-- firebase_push_notification_listener_bloc.dart
   |       |-- firebase_push_notification_listener_event.dart
   |       '-- firebase_push_notification_listener_state.dart
   '-- pubspec.yaml
   Pub needs your authorization to upload packages on your behalf.
   In a web browser, go to https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&response_type=code&client_id=818368855108-8grd2eg9tj9f38os6f1urbcvsq399u8n.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A52636&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email
   Then click "Allow access".

   Waiting for your authorization...
   ```

   - copy the above url and open it in a web browser.
   - login with the dedicated CI/CD account
   - the following should be shown on console output:

   ```sh
   Authorization received, processing...
   Successfully authorized.
   Uploading...
   Successfully uploaded package.
   ```

3. Locate file `FLUTTER_HOME/.pub-cache/credentials.json` and its content should be something like:

```json
{
  "accessToken": "ya29.Il-vBzWTqGR8UbD8Qj290vpKP2hSF5MQYXB1ypFabigWpHiI7WK0Fk-OtJCGF5YEu-Wx8s792d1lvJR3VvduAnx_3yhPGRIiV6PrJP-rsJ2CRH53Qp4WTxUPJM6ANDLOiQ",
  "refreshToken": "1//04DpvP4M4lFm2CgYIARAAGAQSNwF-L9IrL-O13Hvm91nQJ-JmCj4ggKYfaXuJ_nxRMSVfnNCdNj1NIJrVLvxiuqPL8c6oCQWuRPQ",
  "tokenEndpoint": "https://accounts.google.com/o/oauth2/token",
  "scopes": ["openid", "https://www.googleapis.com/auth/userinfo.email"],
  "expiration": 1572904973239
}
```

4. Store all above information at vault.
5. In Jenkinsfile, add a step to check if file `FLUTTER_HOME/.pub-cache/credentials.json` exists. If it doesn't exist, create the file with the values stored at the vault.
6. After publishing, file `FLUTTER_HOME/.pub-cache/credentials.json` should be updated at least with the latest `access_token` and `expiration`. Values at the vault should be updated accordingly.

### Notes

- In file `FLUTTER_HOME/.pub-cache/credentials.json`, value in property `expiration` is epoch timestamp in milliseconds.
- access_token expires after an hour.
- Command `pub publish` will refresh access_token automatically when it is expired.
- Based on [Refresh Token](https://developers.google.com/identity/protocols/OpenIDConnect#refresh-tokens), it expires only when the number of refresh token that are issued exceeds the limits, in which case older refresh tokens stop working.
