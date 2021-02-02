---
layout: default
title: Notifications
parent: Core
nav_order: 14
has_children: true
---

# Notifications



## Types
### Push Notifications
A Push Notification is an OS level notification that is received from the backend. For a full overview of this, refer to the [Push Notifications]({{site.baseurl}}/docs/architecture/core/push_notifications/push_notifications) documentation. 

### Local Push Notification
To provide a possibility to trigger Push Notification from the app itself we introduced Local Push Notifications. For an introduction see [Local Push Notification]({{site.baseurl}}/docs/../../../../../recipes/how_to_add_local_push_notification.md)

### Message Center Notifications
This commonly referred to as a "Notification". These are a separate entity from Push Notifications, and will show up in the application within the Message Center. For an overview, refer to [Message Center Notifications]({{site.baseurl}}/docs/architecture/core/push_notifications/message_center_notifications).

## Helpful Links
* [**To set up push notifications in a new environment**]({{site.baseurl}}/docs/recipes/how_to_setup_a_new_firebase_push_notification_environment).
* [**Deep Link Setup**]({{site.baseurl}}/docs/recipes/how_to_setup_deep_link_from_push_notification).
* [**Create Message Center Notification**]({{site.baseurl}}/docs/recipes/create_message_center_notification).

