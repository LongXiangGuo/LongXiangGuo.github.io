---
layout: default
title: Vehicle Finder
parent: Vehicle
nav_order: 9
grand_parent: Architecture
---

# Vehicle Finder (VF)

{: .no_toc }
The Vehicle Finder (VF) offers the user the ability to locate their vehicle with a single click from the Vehicle Tab. There are 2 variants to this feature: One for vehicles that support LSC (Last State Call) and one for vehicles that do not.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## UX

The current UX for flow can be found [here](https://atc.bmwgroup.net/confluence/pages/viewpage.action?spaceKey=NWAP&title=1.5.2+Vehicle+Finder+-+Current)

The current UX for error messaging can be found [here](https://atc.bmwgroup.net/confluence/pages/viewpage.action?spaceKey=NWAP&title=2.1+Map+Content+and+Interactions+-+Current#id-2.1MapContentandInteractions-Current-2.1.0-A-E2-Carlocationbutton-ErrorCasesYellowWIP)

## BFF

On the Non-LSC Vehicle Finder remote service is responsible to push the information to the app.
Therefore, the following values are possible: 
OK (Everything is ok and VF is working) 
TOO_FAR_AWAY (VF not possible because customer and vehicle are too far away)
VEHICLE_ACTIVE (VF not possible because vehicle is currently active)
DRIVER_DISABLED (VF not possible because it is deactivated by customer)
in case status ok the app receive the longitude, latitude, heading.

## Overview

The Vehicle Finder (VF) operates from "Vehicle Finder Tile" in the Vehicle Tab or from the "Locate Vehicle" button on the Destinations Tab. The business logic for this feature is housed in the Vehicle Finder bloc, in the Platform SDK core bloc's folder. The feature runs seamlessly in the background of the app from the moment it's started and carries out a series of check as it reacts to changes of state of the Vehicle bloc, to keep itself up to date with the latest data. This is all done without any interaction with the touchpoints and allows for a very fast response back to the user when using the feature.


## State Machine
The first thing the Vehicle Finder bloc (VFB) does is check whether the current selected vehicle has LSC support or not.

### LSC Vehicle Finder
The LSC variant operates in a simpler fashion thant the non-lsc: The VFB check is the feature is enabled in the car. If it's not a dialog is shown explaining the impediment and directing the user on how to turn the feature on. If it's enabled, it looks at the vehicle location coming from the vehicle state. If this location is not valid (no coordinates available), a generic error dialog is shown. If it's valid (has coordinates and optionally an address), the lastest information will be shown on the VF Tile and, on tap, the user is redirected to the Destinations Tab, where the map camera moves to the current vehicle location. A tray also pops up with the (optional) address and the timestamp from the last LSC update. The same behaviour happens when pressing the Locate Vehicle button and also when tapping the Vehicle Location marker in the map itself. If an address is not available both the VF tile and tray will show default messages while operating normally.

### Non-LSC Vehicle Finder
If LSC is not supported, the first thing the VFB try is to find a vehicle location saved in the device's cache. If available, the feature will behave much in the same fashion as the LSC VF with 2 small exceptions to the VF tray: The timestamp shown will be from when the cached vehicle location was saved. A "Refresh" button will also be present to allow the triggering of the remote service. If a cached vehicle location is not available, further checks are run. The VFB will check if the device's location services are on and if the mobile connected app has permissions to use those services. In case of a *false* response to any of these checks the user will be prompted with a specific error dialog when interacting with the feature, with instructions on how to allow the permissions of the device's settings. When all permissions needed are enabled, the app can activate the remote service to get the latest vehicle location. The remote service can only be triggered with explicit user interaction, either by pressing the "Refresh" button on the tray, or when the cached vehicle location is not available, from a dialog that pops up when interacting with the VF tile or LV button. When the user request a new vehicle location, a backend call is made to the VF remote service backend, through the Remote Commands BFF. The app will then wait for an answer from this remote service call, which can take about a minute. This call either returns a new vehicle location or an error message. There are several errors that can be returned (out of range, vehicle in motion, etc) and prompted to the user via a dialog popup. Some errors allow the feature to be directly retried. If a positive response is received, the VFB once again checks the validity of the location, and if everything is okay, saves it on the cache along with the current time.

The current code for the Vehicle Finder tile can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_finder/)
The current code for the Vehicle Finder bloc can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/blocs/vehicle_finder_bloc)
The current code for the Locate Vehicle button and Vehicle Location marker can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/destinations/lib/src/utils/vehicle_finder_utils.dart)
