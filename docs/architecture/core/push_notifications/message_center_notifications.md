---
layout: default
title: Message Center Notifications Architecture
parent: Push Notifications
grand_parent: Core
nav_order: 3
---

# Message Center Notifications Architecture

## Overview
Message Center Notifications provide a mechanism for features to persist communications and alerts within the application. 

If a user has 4 unread `Notification` objects tied to their account, they will see 3 things: 
- Their app's badge icon will reflect this unread count
<center>
    <div style="display: inline">
        <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/message_center_badge.jpeg">
    </div>
</center>
-  Their Notification Center Header will reflect this unread count
<center>
    <div style="display: inline">
        <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/message_center_4new.jpeg" >
    </div> 
</center>

-  Tapping the Notification Center Header will bring them into the message center, and the 4 messages will be visible to them there. 
<center>
    <div style="display: inline">
        <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/message_center.PNG" width="40%" >
    </div>
</center>

## Client 
In the client, the retrieval of these messages happens within the `NotificationsRepository`, triggered by the `NotificationHeaderBloc`. This is **purely a GET request, not tying to the receipt of a Push Notification**. 

Here is an in depth look at the design, developed by the CN Development Team: 
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/notification_header_CN_diagram.png" width="100%">
</div>

## Backend
For feature to surface a `Notification` within the Message Center, they will need to make a `POST` request to `/notifications` endpoint of the core OMC [notification-service](https://code.connected.bmw/core-services/notification-service). 

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/architecture/push_notifications/message_center_create.png" width="100%">
</div>

- **Recipe here:** [Create a Notification in Message Center]({{site.baseurl}}/docs/recipes/create_message_center_notification)

