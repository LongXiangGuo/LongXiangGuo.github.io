---
layout: default
title: Push Notifications Architecture
parent: Push Notifications
grand_parent: Core
nav_order: 2
---

# Push Notifications Architecture

This documentation is based on the following [Notifications Design POC](https://code.connected.bmw/DaveKrawczyk/notifications).

### Notification Plugin

Notifications have the potential to cut across all domains of the app.  In some cases, notifications will cause a deep link (or route) into a specific screen of the app. In other cases they may communicate data to one or more repositories.  The process of receiving notifications and publishing the information they contain to interested components should be abstracted from those components into a Plugin and normalized into a clear API for Notification ingestion and publication.  The consumers of this API and subscribers to the outbound notifications will be responsible for implementing the behavior of what to do when a notification they are interested in has been received.

The Plugin handles the following details:
* initialization of the Firebase Messaging Plugin
* setup general Firebase Messaging Plugin notification callbacks
* retrieval of the device token
* permission prompting for iOS
* transformation of "raw" notification into a client notification
* pegging any analytics related to the notifications received


### Architecture

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/notification_bloc_architecture.png" width="100%">
</div>

### Usage

There is an example project included that links up to our Firebase console. This project demonstrates how to use the bloc interface of Notifications component. 

For example, in `/example/lib/remote_service_bloc/remote_service_notification_bloc.dart`:
```dart
// extend the abstract `PushNotificationBloc`, of which the resulting state will be specific to RemoteService
class RemoteServiceNotificationBloc extends PushNotificationBloc<RemoteServiceNotificationState> {

// When initializing the superclass, make sure to set the `NotificationType` that your module 
// needs to receive events for. 
RemoteServiceNotificationBloc(Notifications notifications) 
: super(
    type: NotificationType.remoteServiceUpdate,
    notifications: notifications
);

// The `mapEventToState` function will be triggered with a `PushNotificationReceivedEvent`
// when `Notifications` receives a remote notification of the type specified in the super init.
@override
Stream<RemoteServiceNotificationState> mapEventToState(PushNotificationEvent event) async* {
    if (event is PushNotificationReceivedEvent) {
        yield* _mapNotificationReceivedToState(event);
    }
}

// The `PushNotificationReceivedEvent.notification` can then be unpacked and transformed into a business object
// for the feature module to process. 
Stream<RemoteServiceNotificationState> _mapNotificationReceivedToState(PushNotificationReceivedEvent event) async *{
    if (event.notification["error"] != null) {
        yield UnlockFailedState();
    } else {
        yield UnlockSucceededState();
    }
}
```

### Application ID/Bundle ID Considerations

A spike will need to be done to determine if the existing Mobile 2.0 bundle identifiers for Android & iOS are finalized.  This is important especially for iOS as a Push Notification Certificate will need to be associated with the bundle identifiers for the different application configurations.

## OMC Integration

### Registering App with Azure Notficiation Hub
The OMC requires the app id and the device token in order to successfully send push notifications to the mobile application.  The Hasselcore team will need to be consulted for registering the iOS push notification certs and application ids.

### Device Token
The application will need to register itself as an agent with the OMC in order to receive push notifications from it.  This can be done in the following ways:
  * [Create Agent](https://btcmgapimdly.portal.azure-api.net/docs/services/agents-api/operations/V1MotoristByIdAgentsByAgentIdPut?)
  * [Update Agent](https://btcmgapimdly.portal.azure-api.net/docs/services/agents-api/operations/V1MotoristByIdAgentsByAgentIdPut?)
  * [Update Agent Field](https://btcmgapimdly.portal.azure-api.net/docs/services/agents-api/operations/V1MotoristByIdAgentsByAgentIdByAgentFieldPut?)

In each API, the "pushHandle" is the field that the device token should be set to.

In Mobile 1.0, the api used is /api/gateway/context-motorist/v1/motorist/{usid}/agents/{agentId} or in the case of updating a field, its the same path with "/{field}" appended.

### Notification Hub & FCM
The OMC uses Azure Notification Hub to send Push Notifications and it supports sending FCM notifications. The Firebase Messaging Plugin requires that the [FCM notification format](https://firebase.google.com/docs/cloud-messaging/concept-options) is followed.  While spiking on this topic a test was done with the NA DLY system using the Android notification logic since it most closely matches what the plugin is expecting.  Unfortunately, this test did not result in the sample Flutter app receiving it. When the same notification payload is replicated in a Google Cloud Function, it is received.  The potential work items below will need to be completed to prove out sending a FCM notification from the OMC via Notification Hub.

#### Potential Work Items
* The team will need to add an Agent Platform for Flutter to ApnsPushNotificationClient.cs (see below)
* Add Flutter logic to PushNotificationMapper (see below)
* Add Payload Models (see GcmPayload.cs)

#### Impacted OMC Classes
The classes linked below provide the base that will need to change in order to realize this. Once these changes are in place, the APIM for the Agent API can be used to generate notifications using this new logic.  The Update Agent and Send Push Notification to Agent APIs specifically will be used.  

The current notification logic for Android can be found here:
* [ApnsPushNotificationClient.cs](https://code.connected.bmw/core-services/agent-service/blob/develop/AgentService/Clients/APNS/ApnsPushNotificationClient.cs)
* [PushNotificationMapper.cs](https://code.connected.bmw/core-services/agent-service/blob/develop/AgentService/Mappers/PushNotificationMapper.cs)
* [GcmPayload.cs](https://code.connected.bmw/core-services/agent-service/blob/develop/AgentService/Clients/APNS/Models/GcmPayload.cs)

#### Firebase Push POC
The [Firebase Push POC](https://code.connected.bmw/Tim/mobile20-pocs/tree/master/firebase_push) uses Google Cloud Functions to facilitate sending test notifications and can be used as a point of reference when testing and validating standard and silent push notifications.

## Other Helpful Links
Firebase Console - you'll need to go to the main Firebase Console URL and login as [BTCMobile20 user](https://suus0001.w10:8090/display/MS2/Credentials)

[iOS - Configuring APNs](https://firebase.google.com/docs/cloud-messaging/ios/certs)
* Please follow directions outlined in the Firebase Messaging Plugin page for Creating The Authentication Key.  
* You will not need to run all steps
* You will need admin access to the BTC Apple Developer account to create the required credentials

[iOS - Upload Your APN Authentication Key](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_certificate)
* Please follow directions outlined in the Firebase Messaging Plugin Page

[iOS - Register For Device Token](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications)

iOS generates a device token if one of two cases happens:
1. User has granted permission to accept Remote push notifications.  Mobile app will then recieve both Remote and Silent Push Notifications
2. User doesn't grant permission but application requests device token anyways.  Mobile app can receive Silent Push Notifications only. 