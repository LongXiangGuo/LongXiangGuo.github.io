---
layout: default
title: "BEEP-25: Default Map Position"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 25
---

# BEEP-25: Default Map Position

### Authors

- Ruisong Wang <Ruisong.Wang@bmw.com>

## Summary

This is a proposal to improve user experience when using map

## Motivation

China Team reports sometimes when open Destination Tab, the map camera is above North America.

## Detailed description

The default location is found hard coded in Destination Feature Module. As we know, location method may not always success. For example, when in the room, the GNSS signal will be gone, the only location method is LBS. If the network is also gone, it will fail. Another case is when user forbids location permission, the above issue can be reproduced 100%.

## Solution

In theory, it can not be guaranteed that we can always get user location successfully. The default map location is possible to be observed by our customer. One way is to make the default map location based on the region. Although other solution such as guess by ip address or phone number, it is not an easy solution.

## Code example
```dart
import 'package:platform_sdk/platform_sdk.dart';
import 'package:startup_configuration/startup_configuration.dart';

class DefaultMapLocationConfiguration {
  static DefaultMapLocationConfiguration _instance;
  static DefaultMapLocationConfiguration get instance => _instance;
  static void setupRegion(StartupConfiguration startupConfiguration) {
    _instance = DefaultMapLocationConfiguration._(startupConfiguration);
  }

  Region _region = Region.northAmerica;

  final Map<Region, Coordinates> _defaultCoordinatesMap = {
    Region.northAmerica: Coordinates(
      latitude: 41.882183,
      longitude: -87.642349,
    ),
    Region.china: Coordinates(
      latitude: 39.909036,
      longitude: 116.397459,
    ),
    Region.korea: Coordinates(
      latitude: 37.5512473,
      longitude: 126.988264,
    ),
    Region.restOfWorld: Coordinates(
      latitude: 48.137143,
      longitude: 11.575407,
    ),
  };

  Coordinates get defaultCoordinates => _defaultCoordinatesMap[_region];

  DefaultMapLocationConfiguration._(StartupConfiguration startupConfiguration) {
    _region = startupConfiguration.region;
  }
}
