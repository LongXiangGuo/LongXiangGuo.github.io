---
layout: default
title: Event Driven Architecture
parent: Core
grand_parent: Architecture
nav_order: 16
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Event Driven Architecture

The motiviation for this document is to understand the options for servicing a system architecture where the Open Mobility Cloud (OMC) can communicate events asynchronously to the Mobile 2.0 application.  These events are triggered by OMC, FG or other backend microservice events.  The mobile client then reacts to these events rather than polling the OMC for status and then reacting.  

Polling became a standard behavior of Mobile 1.0 which resulted in "chatty" API interactions with the OMC.  Numerous features would poll the OMC for data relevant to the feature.  As more features were added the API "chattiness" increased leading to performance issues with the OMC or FG services.  Much of what the mobile application typically does is react to events related to vehicle health, services for the vehicle, or services related to the user. Driving these behaviors through events makes sense so the mobile application can display new information to the user in an efficient way.

# Summary of Options

| Option              | Flutter Package Support               | OMC Supported   | Background App Support | User Permission Required? |
|:-------------------:|:-------------------------------------:|:---------------:|:----------------------:|:-------------------------:|
| Push Notifications  | Firebase Plugin (firebase_messaging)  | Yes             | Yes                    | No   |
| Web Sockets          | Websocket Plugin (web_socket_channel) | No              | No                     | No

## Recommendation => Push Notifications

# Push Notifications

## Overview

Push Notifications are covered in this [architecture document]({{site.baseurl}}/docs/architecture/core/push_notifications/).  At a high level, the mobile platform generates a device token and a cloud service uses this token to send push notifications to the mobile app.  Push notifications can be sent as Remote Notifications which are visible to the user and Silent Notifications which are not.  They will be received if the application is in foreground or background.

iOS generates a device token if one of two cases happens:
1. User has granted permission to accept Remote push notifications.  Mobile app will then recieve both Remote and Silent Push Notifications
2. User doesn't grant permission but application requests device token anyways.  Mobile app can receive Silent Push Notifications only.  Information can be found [here](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications)

Android generates a device token independent of user permission.  

The device token is forwarded to the OMC since it will be the initiator of push notifications based on different user or vehicle events.  The OMC stores this device token for the user and then uses it when a notification needs to be sent.  This is covered further in the referenced architecture document.  

## Event Driven Impact

As a communication channel for events, both Remote and Silent notifications can be used to communicate events to the application.  Silent notifications can be used for simply sending an event and related event data to the mobile application. Remote notifications can be used to visually inform the user of an event while also passing event data as well.  The mobile application will need to have a component that parses the different events and their event data such that it triggers state changes in different parts of the application.

## Flutter Integration

Flutter has a Push Notification package, [Firebase Messaging](https://pub.dev/packages/firebase_messaging), that abstracts the native platform details for getting a device token and receiving push notifications.  The team has an outstanding work item to evaluate sending push notifications to a Flutter app from the OMC, since there is some OMC infrastructure to add in order to do so.

## Drawbacks

In iOS, a drawback is the requirement of asking the user for permission as a gate for getting a device token Remote Notifications.  If they refuse, then the application can still get a device token, but it will only receive Silent notifications. Some text informing the user of the value of granting permission for notifications may help in "nudging" them toward acceptance but will require copy on a separate screen explaining why accepting this is a good thing.

## Todos

1. Validate registering for device token in iOS without user permission results in Silent push notifications being received
2. Firebase Messaging plugin may need to be modified to request a device token even if the user does not grant permission for the visual Remote Notifications.
3. Validate sending push notification from OMC by cloning existing infrastructure but tuning it to send FCM notification payload

## Summary 

Since Push Notifications provide a consistent back channel for both iOS and Android to send events to the mobile application asynchronously, whether foregrounded or backgrounded.  Pending a readout on the Todos listed, it is recommended that Mobile 2.0 proceed with Push Notifications.

# WebSockets

## Overview

A Web Socket is a TCP socket connection between a client and server, over the network, which allows full duplex communication.  This means data can be transmitted in both directions and at the same time. A TCP socket is an endpoint instance, defined by an IP address and a port.  WebSockets allow the client-side to open and persist a connection to the server. 

Reasons for using a web socket:
* have a communication channel that remains open between the client and the server for a longer period than a single request/response scheme
* have bi-directional data transmission.  The server can send data to the client without having been requested/polled by the client
* supports data streaming

This option was looked at as an alternative to Push Notifications given the gating factor of user permissions in iOS.  However, it will require writing a fair amount of event producing logic on the OMC which does not exist today along with writing the corresponding event consuming logic on the client side.

## Event Driven Impact

As a communication channel for events, the websocket can be used to communicate events to the mobile application.  The mobile application will need to have a component that parses the different events and their event data such that it triggers state changes in different parts of the application.  The mobile application can use the websocket to communicate back to the OMC to either communicate its own events or push data to the cloud through a dedicated connection.

The scaling of this connection with millions of users needs to be investigated further as there is no precedent in the OMC today for this type of connection


## Flutter Integration

Flutter has a [Web Socket package](https://pub.dev/packages/web_socket_channel), that abstracts the native platform details for setting up a Web Socket connection with a cloud service.  The team will need to spike on introducing a Web Socket connection to the OMC while also working out the details of authenticating the connection, managing it from app launch to background or exit and work with the Core Backend team to make sure scaling of these connections is correct.

## Drawbacks

One major drawback to Web Socket is that the connection is not kept live when the application is backgrounded.  Therefore, only when the app is foregrounded will the channel to the OMC be active and events received. 

Another drawback is that the OMC currently has no precedent of a client connecting via a Web Socket meaning the infrastructure to do so, which includes but is not limited to, authenticating the connection, scaling for millions of users, and handling communication from the client. 

## Todos

1. POC creating an authenticated Web Socket in the OMC and transmit data to the mobile application and vice versa
2. Validate the approach in '1' is scalable for the projected mobile user size
3. POC event handling on both client and server side, define event data format and handling on both sides
4. POC what new microservice is required to send events triggered by different OMC services to the mobile application

## Summary 

Due to the aforementioned drawbacks, along with the high amount of POC work that needs to be done to vet this as a viable option for Mobile 2.0, it is not recommended to use Web Sockets as the backchannel for the OMC to communicate event to the mobile application.
