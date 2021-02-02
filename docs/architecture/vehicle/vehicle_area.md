---
layout: default
title: Vehicle Area
parent: Vehicle
nav_order: 2
grand_parent: Architecture
---

# Vehicle Area

## Client

### User Flow

![vehicle area user flow]({{site.baseurl}}/assets/images/vehicle_area/user_flow.png)

#### As a non-authenticated user

The goal is to decouple the authentication process from any other process.

The user will authenticate, and once transitioning to the Vehicle page, the vehicle page can be signaled to retrieve the list of vehicles. 

1. Login.
2. Get vehicle list.
3. Set active vehicle locally to the first one on the list, if no active vehicle has been set before.
4. Now we are in the `authenticated` flow.

#### As an authenticated user

1. Show first information from cache.
2. Make network call to retrieve the latest up to date information.
3. Save results received in storage.
4. Update UI with the up to date information.

### Types of vehicles

There's three types of vehicles:

* Combustion vehicles (COMB)
* Hybrid vehicles (PHEV)
* Electric vehicles (BEV)

Additionally, you might not have a vehicle.

### UI Breakdown

![vehicle area ui breakdown]({{site.baseurl}}/assets/images/vehicle_area/ui_breakdown.png)

Widgets:

* User salutation
* Vehicle name + access to vehicle list
* Vehicle image
* UpdatedAtTimestamp
* Door status
* PrimaryInformation
  * It could be many things, depending on the type of vehicle
* SecondaryInformation
  * It could be many things, depending on the type of vehicle

# Overview

This document covers the proposed widget information for each [Vehicle Area widget](https://suus0001.w10:8090/display/~reichlin/Vehicle+Status+Combinations).  This widget information will be returned by the Vehicle Composite Service

# Vehicle Area Widget Information

| Icon     | Widget Name  | Copy         | Vehicle Type | Region | Widget Information |
| -------- | ------------ | ------------ | ------------ | ------ | ------------------ |
| ![Fuel Level]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Fuel/FuelLevel.png)     | FuelLevel    | Fuel Level   | Combustion   | Left   | value: number<br>units: FuelUnits |
| ![Fuel Percentage]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Fuel/FuelPercentage.png)     | FuelPercentage | Fuel Level | Combustion   | Left   | value: number |
| ![Conductive Not Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/conductive/ConductiveNotCharging.png)<br>![Conductive Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/conductive/ConductiveChargingStandby.png)<br>![Conductive Complete]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/conductive/ConductiveFullyCharged.png)<br>![Conductive Error]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/conductive/ConductiveChargingError.png)<br>![Inductive Not Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/inductive/InductiveNotCharging.png)<br>![Inductive Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/inductive/InductiveChargingStandby.png)<br>![Inductive Complete]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/inductive/InductiveFullyCharged.png)<br>![Inductive Error]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/inductive/InductiveChargingError.png)    | Charging State | Charging...<br>Fully Charged | Hybrid | Right | chargePercentage: number<br>state: ChargeState<br>type: ChargingType |
| ![Combustion Range]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/CombustionRange.png) | CombustionRange | Total Range | Combustion | Right | distance: Distance |
| ![REX Range]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/REXRange.png)     | REXRange | REX | Hybrid | Right | distance: Distance |
| ![Combined Range]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/CombinedRange.png)<br>![Combined Range Null]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/CombinedRangeNull.png)     | CombinedRange | Total | Hybrid | Right | distance: Distance |
| ![Electric Range]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/ElectricRange.png)<br>![Electric Range Null]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Range/ElectricRangeNull.png)     | ElectricRange | Electric Range | Electric | Right | distance: Distance |
| ![Electric Range And Status]({{site.baseurl}}/assets/images/vehicle_area_widget_information/RangeAndStatus/ElectricRangeAndPercentage.png)<br>![Electric Range Distance]({{site.baseurl}}/assets/images/vehicle_area_widget_information/RangeAndStatus/ElectricRangeDistance.png)<br>![Electric Range And Status Null]({{site.baseurl}}/assets/images/vehicle_area_widget_information/RangeAndStatus/ElectricRangeNull.png)     | ElectricRangeAndStatus | Electric Range | Electric | Left | chargePercentage: number<br>distance: Distance |

# What does NULL Mean?

* If the client is to ignore specific widget information, then that information object shall be null
* If the value of a specific widget information object is supposed to be "---" then the value property shall be null

# Vehicle Area Widget Information Types

## Distance

* value: number
* units: DistanceUnits

## FuelUnits

* 'LITERS'

## DistanceUnits

* 'KILOMETERS'

## ChargeState

* 'NOT_CHARGING'
* 'CHARGING'
* 'COMPLETE'
* 'ERROR'

## ChargingType

* CONDUCTIVE<br>![Conductive Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/conductive/ConductiveChargingStandby.png)
* INDUCTIVE<br>![Inductive Charging]({{site.baseurl}}/assets/images/vehicle_area_widget_information/Charge/inductive/InductiveChargingStandby.png)
