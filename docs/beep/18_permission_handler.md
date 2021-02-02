---
layout: default
title: "BEEP-18: Permission Handler"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 18
---

# BEEP-18: Location Permission Handler

### Authors

- Henry Ni (Chicago)

## Summary

This BEEP proposes using the [permission_handler](https://pub.dev/packages/permission_handler) plugin instead of [location_permissions](https://pub.dev/packages/location_permissions) to handle requesting lcoation permissions.

## Motivation

Connected 2.0 uses [location_permissions v2.0.4+1](https://pub.dev/packages/location_permissions/versions) to handle location services requests, but it does not fully support cross-platform actions.

## Detailed Description

### Missing case for Android

iOS limits developers to one request for location permissions before the user needs to update app permissions directly in Settings.  Android does not limit the number of requests but offers users the option to request not being asked again on subsequent requests.  

<img src="/../../assets/images/android_do_not_ask_dialog.png" width="300" height="634"/>

In the location_permissions API, `shouldShowRequestPermissionRationale()` offers a way to check whether a permission has been requested already.

```dart
/// Request to see if you should show a rationale for requesting permission.
///
/// This method is only implemented on Android, calling this on iOS always
/// returns [false].
Future<bool> shouldShowRequestPermissionRationale(
    {LocationPermissionLevel permissionLevel =
        LocationPermissionLevel.location}) async {
if (!Platform.isAndroid) {
    return false;
}

final bool shouldShowRationale = await _methodChannel.invokeMethod(
    'shouldShowRequestPermissionRationale', permissionLevel.index);

return shouldShowRationale;
}
```
In Android, the proper way to ask for permissions is to check the permission's status first, then display the appropriate dialog box to let users respond. If a user denies an app's request then `shouldShowRequestPermissionRationale()` is the **only** way for developers check if it's okay to request permissions again.

Ideally, this method should return `true` when the location permission has never been requested and `false` when the user has checked "don't ask again" and denied the request; however, the method returns `false` in both scenarios.  This makes it impossible to detect if this interaction is the first time a user has been asked for location permissions, or if they've already denied our request and selected "do not ask again". This issue was raised on the [permission_handler GitHub repo](https://github.com/Baseflow/flutter-permission-handler/issues/96).

### Discontinued Support

Active development and maintenance for location_permissions appears to have stopped, and developers are actively switching to and maintaining permission_handler, which includes an enumerated value for cases where users selected "do not ask again." This enum is available is all versions of the package ^4.2.0.

## Final Thoughts

* Using permission_handler over location_permissions will cover all cross-platform cases for requesting and checking location permissions.

* The permission_handler library enjoys better support and is actively maintained -- the PR to add "don't ask again" support was merged on Jan 17 (v4.2.0, [#189](https://github.com/Baseflow/flutter-permission-handler/pull/189)) and as of March 2, the library is on v4.3.0.