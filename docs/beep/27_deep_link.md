---
layout: default
title: "BEEP-27: Deep link"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 27
---

# BEEP-27: Deep link

### Authors

* Yunpeng Kong <yunpeng.kong@partner.bmw.com>

## Summary

This is the deep link architecture design both for notification and universal link
## Notification UX

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/27/push_notification_ux.png" width="100%">
</div>

## Use cases

Given the user taps the notification, it will present a detail page modally

Given the user taps the notification, it will navigate to a subpage



## Type of Routing 

### 1. Route to a template UI

In order to route to a full screen template UI, the payload must provide its data. To fulfil this requirement, the payload is defined as follows:

```json
{
	"type": "common",
	"id": "unique identifier",
	"action": "bmw://connected/fullscreen",
	"detailPage": {
		"title": "pickup success",
		"content": "pickup three hours, total 100$",
		"actions": [{
			"title": "detail",
			"action": "bmw://connected/{mainTab}/{feature-route-name}?{queryKey}={qureyValue}",		
		}]
	}
} 
```

### 2. Route to an existing subpage

In order to route to an existing subpage, the action uri must include the mainTab and the subpage routing names.

```json
{
	"type": "common",
	"id": "unique identifier",
	"action": "bmw://connected/{mainTab}/{feature-route-name}?{queryKey}={qureyValue}",
}

```

Examples of mainTab Uri:

```json
bmw://connected/vehicle
bmw://connected/map
bmw://connected/profile
bmw://connected/social
bmw://connected/service
```



## Overall archtechture design

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/27/deeplink_overall.png" width="100%">
</div>


## First iteration Detail

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/27/deep_link.png" width="100%">
</div>

## POC link

- [POC link](https://code.connected.bmw/LongxiangGuo/notification_demo)
