---
layout: default
title: Analytics
parent: Core
grand_parent: Architecture
nav_order: 9
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Analytics

The goal of analytics is to collect data that describes a user's behavior within a BMW client touchpoint and any backing cloud microservices.  This document describes the architecture for collecting this information from both client and cloud with a focus on the Mobile 2.0 Application and the backing Presentation API Microservices.  The end result should be a timeline that can be built across client and cloud that describes the sequence of events a user executed while using the Connected application.  An example of this is represented in the following image:
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/arch_analytics_timeline.png" width="80%">
</div>


# Client Analytics

## Countly
[Countly](https://count.ly) is the analytics platform that we leverage to record client analytics for Eadrax. It provides support for plugins that are provided as a part of the Enterprise edition. If needed it also supports adding our own plugins that help us in understanding the data better.

Documentation for Countly's Flutter SDK can be found [here](https://support.count.ly/hc/en-us/articles/360037944212-Flutter).

A wrapper around Countly APIs that will be used for recording events in the mobile-connected project has been added to the platform SDK [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/countly_analytics_wrapper.dart). This wrapper exposes APIs that feature teams can use to record custom events as required.

### Initializing the Countly SDK
The countly SDK needs a server URL and app key to be initialized. The Runtime team has already setup server URLs and app keys per region and environment for mobile-connected. Currently these app keys and server urls are defined in the [analytics_lifecycle](https://code.connected.bmw/mobile20/mobile-connected/blob/master/shell/lib/src/analytics_lifecycle.dart).

The initialization of the SDK is being done in the [analytics_lifecycle](https://code.connected.bmw/mobile20/mobile-connected/blob/master/shell/lib/src/analytics_lifecycle.dart).

### Recording Bloc transitions
The Mobile 2.0 client utilizes the [BLoC](https://github.com/felangel/bloc) package for State Management in the application.  The BLoC provides the ability to track the event/state [transitions](https://felangel.github.io/bloc/#/coreconcepts?id=transitions) that occur due to user interactions with the UI.  These transitions can be recorded as user behavior within a screen and when mapped over time can produce a timeline of what the user was doing for a given session in the client. 

All BLoc transitions are being recorded as custom events from the `ConnectedBlocDelegate`. We should strive to get as much information as possible from these BLoc transitions and so it's important to try and adhere to the [naming convention](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/beep/9_bloc_naming/) defined for blocs, states and events.

The format in which the transitions are being recorded is `eventName: '${transition.event}-${transition.nextState}'`.

An example of a recorded bloc transition on the Countly dashboard:
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/analytics/event_bloc_transition.png" width="80%">
</div>

### Recording custom events
The `recordEvent` method from the CountlyAnalytics wrapper should be used to record custom events. It takes two parameters:
1. `eventName` - A `String` which is the name of the event being recorded.
2. `eventDetails` - A `Map<String, String>` which includes details about the event. This is not a required parameter. It's valid to have events with just an `eventName` and no `eventDetails`.

In Countly's terms, `eventDetails` are called eventSegmentation. On the dashboard, an `event` WITHOUT `eventDetails` will look just like the one shown in the image above. An `event` WITH `eventDetails` will look like the one below. The event here is recorded as: 
```json
{
  "eventName": "Feedback",
  "eventDetails": {
    "Type": "General Feedback",
    "Comment": "Great app"
  }
}
```

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/analytics/custom_event_with_details.png" width="80%">
</div>

## Session & Correlation IDs

The Mobile 2.0 client will need to generate a Session ID whenever the application is started.  This value will "frame" the events that are generated so they can be correlated with Presentation API events that will be also be recorded in the respective microservices.  This ID will be sent with every HTTP request.

The Mobile 2.0 client will also generate a Correlation ID upon every request to the OMC.  This ID will be used to correlate a request made by the client with the subsequent requests made by the backing microservice as a means of tracking activity from a microservice back through the OMC system.


## Dynatrace

[Dynatrace](https://www.dynatrace.com/) is an analytics platform that is used to monitor performance metrics in real time and detects and diagnoses problems automatically.

Documentation for Dynatrace's Flutter SDK can be found [here](https://pub.dev/documentation/dynatrace_flutter_plugin/latest/#usageMobileAgent).

A wrapper around Dynatrace APIs that will be used for recording actions in the mobile-connected project has been added to the platform SDK [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/dynatrace_analytics_wrapper.dart). This wrapper exposes APIs that feature teams can use to record custom actions as required.

Currently the Dynatrace functionality  needs to be activated by the according feature toggle. Also we only added configurations for the ROW, NA and KR setups for INT and PROD. Other environments won't add data to Dynatrace currently.

### Initializing the Dynatrace SDK
The Dynatrace SDK needs a configuration file for the Android and iOS setup. Also it needs an `appId` and a `beaconUrl` per brand, region and environment for mobile-connected. Currently these appIds and beaconUrls are defined in the [DynatraceConfiguration](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/models/dynatrace_configurations.dart).

The initialization of the SDK is being done in the [connected_app](https://code.connected.bmw/mobile20/mobile-connected/blob/master/lib/connected_app.dart) using the [DynatraceAnalytics](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/dynatrace_analytics_wrapper.dart) wrapper class.

### Creating manual actions

Dynatrace always automatically sends events for the App start. To add manual actions e.g. for remote actions, those actions need to be surronded by something like the following code as implemented in the [remote_service_bloc](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/blocs/remote_services_bloc/lib/src/bloc/remote_service_bloc.dart):
```dart
var action = _dynatraceAnalytics
          .enterDynatraceAction("${command.executionType()} started");
// EXECUTION OF THE ACTION YOU WANT TO TRACK HERE
_dynatraceAnalytics.leaveDynatraceAction(action);
```
from the DynatraceAnalytics wrapper.
These manual actions should be set in blocs where possible to keep the architecture consisten.

NOTE: Be careful to always leave the DynatraceRootAction again, otherwise nothing will be tracked. This could happen if you call your action inside a `try catch` block for example, as also show in [remote_service_bloc](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/blocs/remote_services_bloc/lib/src/bloc/remote_service_bloc.dart).

# Microservices

All microservices will adhere to the [Standard Logging Schema](https://pages.code.connected.bmw/runtime/docs/standards/logging-schema/) as defined by the Runtime team.  The specific tech platform (e.g NestJS or .NET Core) will provide a middleware SDK that implements this schema and communicates with a FluentD component as outlined in the image below:
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/runtime_analytics_1.png" width="60%">
</div>

For Mobile 2.0, the Presentation API Microservices will utilize the logger SDKs provided for NestJS and .NET Core, respectively.  These SDKs can be found here:

[NestJS SDK](https://suus0003.w10:7990/projects/NP/repos/bmw/browse/packages/nestjs) - Under lib, open logger.ts

[.NET Core](https://code.connected.bmw/library/btclogging)

## Logging Schema

The controller should log the Common, HTTP and, if needed, Error Groups.  It should log the Session ID and Correlation ID that is sent by the client as part of the data so it can be correlated to the client events that match.  Please read about these groups in the [Logging Schema Docs](https://pages.code.connected.bmw/runtime/docs/standards/logging-schema/).  As described in the schema documentation, analytics will be logged by using the appropriate group.  

The Microservice Controller will use a combination of Common, HTTP and Error Groups to capture the requests coming in.  It will log the Session ID & Correlation ID sent by the client so the events captured here can be referenced back to the client events to create a clear timeline for a session ID.  The correlation ID will be used to track requests that travel through the OMC to understand the interactions that this request triggers.

The Service layer will use the logger to capture information in developer logs for debug at a later time.  
