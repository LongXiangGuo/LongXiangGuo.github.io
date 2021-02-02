---
layout: default
title: Vehicle State Refresh Mechanisms
parent: Vehicle
nav_order: 6
grand_parent: Architecture
---

# Vehicle State Refresh Mechanisms: Pull-To-Refresh (PTR) & Automated Timer Refresh (ATR)

{: .no_toc }
The Pull-To-Refresh (PTR) and the Automated Timer Refresh (ATR) mechanisms are used to update the vehicle state of the current vehicle. The ATR runs continuously on a set timer and the PTR allows the user to manually request an update.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## Notice

Be aware that these features are not responsible for retrieving, validating or displaying any data. Both the PTR and the ATR only trigger a request for an update.

## Pull-To-Refresh (PTR)

### UX

The current UX can be found [here](https://atc.bmwgroup.net/confluence/display/NWAP/1.0+Vehicle+Page+Layout+-+Current#id-1.0VehiclePageLayout-Current-PulltoRefresh)

### Overview

The Pull-To-Refresh (PTR) mechanism uses the "Joy Pull To Refresh" widget, which is a wrapper around the "Refresh Indicator" widget provided by Flutter. This mechanism is triggered by the user swiping down at the top of the "Vehicle Tab". This triggers an animation and a callback to add the "Vehicles Started" event to the "Vehicles Bloc", triggering a new polling of data. This also resets the ATR, starting its countdown again from 3 minutes. The PTR only works in the "Vehicle Tab" at the moment. If there is an error getting new data, a snackbar appears displaying an error message (WIP).

The current code can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/vehicle_tab/confirmed_vehicle_tab_widget.dart)

## Automated Timer Refresh (ATR)

### UX

The current UX can be found [here](https://atc.bmwgroup.net/confluence/display/NWAP/1.3+Vehicle+Status+Widget+-+Current#id-1.3VehicleStatusWidget-Current-WidgetStates)

### Overview

The Automated Timer Refresh (ATR) mechanism uses a simple timer mechanism to update the vehicle state every 3 minutes, unless it is reset by the PTR. A custom timer duration can be set for testing or demo purposes. The code for this timer is located in the "Platform SDK" packages inside mobile-connected. The timer is setup once in the constructor of the "Vehicles Bloc" and runs until that bloc is disposed of. When the timer reaches 0, it triggers a callback to add the "Vehicles Started" event to the "Vehicles Bloc", triggering a new polling of data. This also resets the ATR, starting its countdown again from 3 minutes. The one exception in this loop is when the app goes to background (paused). At this point, the timer is canceled, and when the app returns to the foreground (resumed), it is reset. Note that in this scenario, the timer runs again from the start and, at the same time, a request for new data is triggered. While the updating mechanism is in progress, the timestamp field displays that state to the user (WIP). If there is an error getting new data, a snackbar appears displaying an error message (WIP).

The current code can be found [here](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/lib/src/timers/automated_refresh_vehicles_timer/automated_refresh_vehicles_timer.dart)

## Future Improvements

The current implementation of both the PTR and the ATR use the "Vehicles Started" event on the "Vehicles Bloc". This is temporary as this bloc retrieves all the data for all vehicles in the user's account, which is both not necessary for the scope of the feature, and it's also an overload on the backend and on the user's data usage. This will be refactored as soon as possible to make use of a new "Vehicle State Bloc" the Atoms team will implement. The idea for this refactoring is to just get the current state of the current vehicle.

The use of the "Vehicles Bloc" also limits the feedback the user receives about the status of the update process. While the updating is in progress the timestamp field displays that information to the user. If there is an error getting new data, a snackbar appears displaying an error message. These functionalities are not fully implemented yet, but will be done once the "Vehicle State Bloc" is ready.

The duration of the PTR animation is hardcoded at the moment but this will make use of the "Vehicle State Bloc" states to run for the correct amount of time.

There's an open discussion on expanding the PTR mechanism to other tabs and pages inside the app. Work on this will start once there is business definition of where and not to have this functionality. Refactoring to allow this to happen will most likely mean moving the "Joy Pull To Refresh" widget higher in the widget tree towards the root of the app, making it available in multiple places.

There is also a discussion about adding a limit to the amount of times a user can trigger the PTR in a row. Work on this will start once there is business definition for the rules to apply.
