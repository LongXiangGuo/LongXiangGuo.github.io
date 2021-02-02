---
layout: default
title: Permissions
parent: User
nav_order: 6
grand_parent: Architecture
---

# Permissions

The My BMW and MINI apps gather user permissions during the login flow and statuses of those permissions are shown on the permissions page in the Profile tab. To gather user permissions and their statuses we leverage a plugin called [permission_handler](https://pub.dev/packages/permission_handler). We have wrappers around the APIs of this plugin in the [device repository](https://code.connected.bmw/mobile20/mobile-connected/tree/master/platform_sdk/repositories/device_repository).

## Permissions during login

In the [login flow](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/connected/lib/src/connected.dart#L68) once the user has created a PIN, they are presented with a [page](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/connected/lib/src/accept_permissions/accept_permissions_page.dart) which details the permissions the app needs along with their description. On tapping the button at the bottom of this page the user is prompted for all the permissions listed. The logic for prompting for these permissions is defined in the [AcceptPermissionsBloc](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/connected/lib/src/accept_permissions/bloc/accept_permissions_bloc.dart).

## Profile -> Settings -> Permissions

Users have the ability to check the status of device permissions and toggle collection of analytics from the [permissions page](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/profile/lib/src/settings/permissions/permissions_page.dart) within settings.

The collection of data analytics is managed by Countly's consent management APIs which are used [here](https://code.connected.bmw/mobile20/
mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/countly_analytics_wrapper.dart#L315). Based on the status of the data analytics toggle network requests sent to Countly are either turned on or off.

The user can also see the status of all permissions that they were prompted for during the login flow on this page. Tapping on any of the permission item takes the user to the permissions section of the Settings app omn their device.