---
layout: default
title: Garage
parent: Vehicle
nav_order: 13
grand_parent: Architecture
---

# Garage

-   [Overview](#overview)
-   [User Flow](#user-flow)
    -   [Select Vehicle](#select-vehicle)
    -   [Add Vehicle](#add-vehicle)
    -   [Remove Vehicle](#remove-vehicle)
-   [Where is the code?](#where-is-the-code)
    -   [Widgets](#widgets)
    -   [BLoC](#bloc)
    -   [Models](#models)
    -   [Dependencies](#dependencies)

## Overview

The garage contains the list of mapped vehicles. BMW App will show the users mapped BMW cars and the MINI App will show the mapped MINI cars. The garage can be accessed after the user has mapped their first vehicle through the initial add vehicle button on the vehicle tab. The entry point to the garage will appear on the top right corner of the vehicle tab. There are three actions that the garage currently allows users to do. Select Vehicle, Add Vehicle and Remove Vehicle.

## User Flow

### Select Vehicle

The user can change their vehicle by clicking directly on a vehicle card that they want to promote to be their active vehicle. The newly selected vehicle will be brought to the top of the list. In the BMW App the selected card color will match the color of the car. In the MINI app the selected car color will be a teal color.

### Add Vehicle

The add vehicle button is always at the bottom of the list of vehicle cards. This button will take you to the vehicle mapping flow.
[Vehicle Mapping](https://pages.code.connected.bmw/mobile20/mobile-docs/docs/architecture/vehicle/vehicle_mapping/)

### Remove Vehicle

The remove vehicle button is accessed by swiping left on each vehicle card. When the delete button is pressed the user will be prompted with a dialog to make sure the user wants to remove that mapped vehicle. After the vehicle is removed the user should see the car disappear from the garage the next time a get vehicles call is made. This call happens every 3 minutes.

## Where is the code

### Widgets
[The vehicle list widget directory](https://code.connected.bmw/mobile20/mobile-connected/tree/master/feature_modules/vehicle/lib/src/vehicle_list)

### Blocs
[Delete Vehicle Bloc directory](https://code.connected.bmw/mobile20/mobile-connected/tree/master/feature_modules/vehicle/lib/src/vehicle_list/bloc)

### Models
[Currently supported vehicle properties displayed on the vehicle card](https://code.connected.bmw/mobile20/mobile-connected/tree/master/feature_modules/vehicle/lib/src/vehicle_list/models)

### Dependencies
[flutter_slidable](https://pub.dev/packages/flutter_slidable)