---
layout: default
title: Profile Module Overview
parent: Profile Module
grand_parent: Architecture
nav_order: 1
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Overview

The profile module encapsulates information about application and the user. The module is structured to accomodate content that is local to the module and content that belongs to other feature modules. Feature module visibility is controlled by the runtime list of modules. If a module is missing from the list it will return an empty container from the PlatformSDK.findModule call which will not impact page layout. However, a better long term approach for this will be forthcoming as an API from the UserCompositeService will be augmented to describe the feature set that should be displayed on this page.
Here is a sample screenshot:

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/profile/profile_tab_screenshot.png" width="35%">
</div>

This document will describe the modules supported and the backend composite services that power them.

# Module Structure

The profile module consists of of a profile tab that houses the feature content.  This example is the structure for NA & ROW.  The CN profile tab will have different feature components but similar App Info components.

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/profile/profile_module_ui_structure.png" width="50%">
</div>

## ProfileBloc

The ProfileBloc depends on the UserRepository and is responsible for loading the ProfileTab. This repository calls the UserCompositeService API for getting the profile tab content found in the [swagger](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=user-composite-service) for the service. This module follows the high level architectural pattern of Blocs relying on repositories which use ApiClients to call their respective composite services in the cloud as shown here:

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/profile/profile_module_layers.png">
</div>

## Routes

The Profile module hosts widget classes that represent the content to be returned when navigating to a specific route. This route content is defined in profile_page_routes.dart.

The class ProfileRoute implements a static 'onGenerateRoute' method that takes RouteSettings as an argument and returns the MaterialPageRoute for the routeName that is specified in the settings. If external data or data that is no longer in context is required, then RouteSettings provides an arguments property that one can use to pass this information into the route so it can be utilized by the constructed widget for that route.

RouteConstants contains the constant names for all routes in the Profile Module.

## Navigator

The ProfileNavigator provides a root Navigator stack for the module where pushes and pops are managed from within the module. The Navigator leverages the ProfileRoute.onGenerateRoute static method to handle named pushes and pops as well as pushing feature module navigations onto the stack from "external" features like roadside assistance or bmw points as discussed in the next section. Hosting a module specific navigator also allows the bottom tabbar to remain visible when the user drills down into specific profile tab content.

# Module Content

## User Info & Settings

The ProfileBloc provides the full name of the user at the top of the tab. Settings provides Account information and Permissions.

### Account

Account allows the user to change their password, change their pin or logout. Both Reset Password and Change PIN are separate modules that manage the flow of carrying out those actions. The Logout button utilizes the TokenAuthenticationBloc to log the user out which returns them to the Login screen.

### Permissions

Permissions provides the user with the visibility into the permissions for different features

## Send Feedback

Send Feedback is a local feature to the profile module that has its own Bloc that depends on UserRepository and Analytics. It uses the UserRepository to query the UserCompositeService for the feedback options it should display to the user. The [swagger](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=user-composite-service) for the service shows the API returns the feedback options and types which are displayed to the user. 

When the user has provided feedback, it uses its Analytics (Countly) dependency to send the feedback to the backend analytics system.
The `recordUserFeedback()` API in the [countly_analytics_wrapper](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/countly_analytics_wrapper.dart) takes `feedbackType` and `comment` as parameters and calls Countly's `recordEvent` API to record feedback as a custom event. The `eventName` for this custom event is a constant value `Feedback` which is defined [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/utils/constants.dart) and the `eventSegmentation` contains the `feedbackType` and `comment`. The`feedbackType` value that is sent to the backend system is the value from the [enum](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/repositories/user_repository/lib/src/api/user/models/settings_permissions/send_feedback_option_item.dart) and not the translated text that is visible to the user.


## About & Contact

About & Contact is a local feature to the profile module that displays the app name, version and contact information based on the regional hub that the client is running under (e.g. NA, ROW, CN). It offers three additional options: Imprint, License Information and Debug (for all non-appstore builds).

The About & Contact content is provided by the AboutAndContactBloc. This Bloc depends on the UserRepository and the PackageInfo plugin. The UserRepository is used to fetch the contact information from the UserCompositeService per the service's [swagger](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=user-composite-service). PackageInfo plugin is used to construct the application version.

### Imprint

Imprint is a local feature to the profile module that provides legal contact information for the regional entity for the application (e.g. NA, ROW, CN) that users can contact. The content of the page comes from the ImprintBloc which depends on the LegalDocumentRepository. This repository provides an API for contacting the LegalDocumentCompositeService per the service's [swagger](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=legal-document-composite-service).

### License Information

The LicensePage is built using a Flutter plugin that has been integrated into the JoyUI framework.  It is a stateful widget that builds up the License content from the Dart LicenseRegistry.

### Debug 

Debug is a local feature to the profile module that provide debug information about the user, platform and application.  The content of the page comes from the DebugBloc which depends on UserRepository.  The repository makes no calls to the BMW cloud but rather returns information like USID and UserAgent for display on the page.

## Privacy & Terms

Privacy & Terms is a feature module comprised of Terms of Use, Privacy Policy and BMW (or MINI) ConnectedDrive Terms of Use. It also provides the user with the ability to delete all of their personal data from the client and BMW cloud.

The module is driven by the PrivacyAndTermsBloc which is a HydratedBloc for caching and has a dependency on the LegalDocumentsRepository. This repository calls LegalDocumentRepository to pull the content for the page from the LegalDocumentCompositeService per the service's [swagger](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=legal-document-composite-service). It displays the options returned as navigable list items. Clicking on any of the list items results in the content being loaded into a Flutter Webview.

### Delete All Application Data

The Delete All Application Data is driven by the DeleteAllApplicationDataBloc. This Bloc has a dependency on the UserRepository. This repository calls the API for deleting user data(api/account/delete) for a specific USID. This deletes the user's data and logs them out of the application.

## BMW Points

The architecture for BMW Points can be found [here]({{site.baseurl}}/docs/architecture/emobility/bmw_points/).

## Roadside Assistance

The architecture for Roadside Assistance can be found [here]({{site.baseurl}}/docs/architecture/aftersales/roadside_assistance_client/) for the client and [here]({{site.baseurl}}/docs/architecture/aftersales/roadside_assistance_composite/) for the composite service.
