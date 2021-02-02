---
layout: default
title: "BEEP-24: General Geolocation Plugin"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 24
---

# BEEP-24: General Geolocation Plugin

### Authors

- Ruisong Wang <Ruisong.Wang@bmw.com>

## Summary

This is a proposal for adapting geolocation plugin for Chinese coordinate system

## Motivation

1. China use GCJ-02 coordinate system, which is different from WGS-84. Flutter geolocation plugin returns WGS-84 only.
2. Flutter geolocation plugin under Android may use Google Service, which is blocked in China.
3. Although positioning via GNSS is hardware based, positioning via WiFi hotspot or mobile phone station requires LBS service provider to have the data of each AP's location around the user, Chinese LBS provider may have much more data.

## Detailed Description

Based on the above reason, China flavor has to use another geolocation plugin, such as Autonavi location plugin. This BEEP discusses and compares 2 solutions.

### Solution 1: Proxy pattern of current Flutter geolocation plugin

We could introduce a wrapper class - GeolocationWrapper, which will proxy to Autonavi geolocation and Flutter geolocation plugin based on the region information. When app initializing, set the region info into the wrapper class. If the region is China, call corresponding Autonavi geolocation method, otherwise, call the original one.

#### Impact
We noticed that Autonavi geolocation plugin depends on Autonavi Foundation framework on iOS, which is more than 10mb. We also discovered that the framework is a static library, which mean during linking stage, only function used will be involved, other than copying the whole framework. Furthermore, we've compared the final ipa bundle size increment, the result is about 1mb.

####Pros:
Straightforward and least code change.

####Cons:
Increase the final app package size about 1mb

### Solution 2: Similar to Atlas, define a GeneralGeolocator interface and set Providers

The GeneralGeolocator interface will contain 3 key methods

- getCurrentLocation
- getLastKnownLocation
- getPositionStream

####Pros:
1. Autonavi geolocation plugin will only set in China Flavor main function, other flavor will not use it at all.
2. It is easy to decouple and no static link which will not increase the package size of non-china flavor about 1Mb comparing to solution 1, but flutter code may increase more
3. Since China flavor has already use Autonavi map, which depends on Autonavi Foundation library, therefore, it will not increase the size too much when building for it.

####Cons:
1. We have to define a new GeneralGeolocator interface and change 3 methods used in the whole app.
2. It requires to implement the above interface with both Autonavi geolocator and Flutter geolocator plugin, complicated.


##Conclusion

Since 1mb is not too much, Solution 1 is preferred.