---
layout: default
title: Net Promoter Score (NPS) and Store Review
parent: User
nav_order: 5
grand_parent: Architecture
---

# Net Promoter Score (NPS) 

An NPS screen/prompt is showed to the user during the startup flow depending on some rules (discussed below) being satisfied. The user has the ability to provide a rating(0-10) and an optional comment. They can also choose to skip this prompt. 

## NPS Prompt Rules

* The app launch is 5, 10 or a multiple of 30.
* The user hasn't provided an NPS rating within the last 90 days. 

## NPS Submission

When the user has provided NPS, it uses its Analytics (Countly) dependency to send the NPS rating and comment to the backend analytics system.
The `recordNps()` API in the [countly_analytics_wrapper](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/countly_analytics_wrapper.dart) takes `rating` and `comment` as parameters and calls Countly's `recordEvent` API to record NPS as a custom event. The `eventName` for this custom event is a constant value `NPS` which is defined [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/utils/constants.dart) and the `eventSegmentation` contains the `rating` and `comment`.

Apart from the NPS event being recorded, NPS category is also added to the user profile in Countly. The user property `nps_category` is defined [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/data/analytics/lib/src/utils/constants.dart). This category is based on the rating provided by the user and is assigned as follows:
* `Promoter` for a rating >= 9
* `Neutral` for a rating >=7 and <=8
* `Detractor` for a rating <= 6

## Store Review Prompt Rules

* User gave an NPS rating >= 9 on the last NPS prompt
* It has been 10 launches since

## Store Review Prompt

The logic to determine whether the user should be prompted for store review or not is defined [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/repositories/app_review_repository/lib/src/app_review_repository.dart). The prompt itself is shown after the user reaches the [vehicle tab](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/vehicle_tab/vehicle_tab_widget.dart). We currently leverage the [app_review package](https://pub.dev/packages/app_review/) that shows the prompt for both iOS and Android.