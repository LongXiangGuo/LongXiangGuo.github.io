---
layout: default
title: "BEEP-8: Vehicle State Refactor"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 8
---

# BEEP-8: Refactor Vehicle State

### Authors

- Felix Angelov

## Summary

I am proposing to refactor the Vehicle APIs to decouple presentation from the raw data in order to allow us to have a single source of truth for vehicle state throughout the mobile 2.0 client.

## Motivation

The goal of this BEEP is to have shared vehicle state throughout the mobile 2.0 client so that changes in the vehicle state in one part of the app are immediately reflected in other parts of the app.

### Detailed description

### Get Vehicles API

`GET /vehicles`

```json
[
  {
    "vin": "WXG0982344910",
    "model": "320d",
    "capabilities": {
      "ventilation": "ENABLED",
      "heating": "NOT_SUPPORTED",
      "cooling": "NOT_SUPPORTED",
      "lightFlash": "ENABLED",
      "honkHorn": "DISABLED",
      "climateTimer": "START_TIMER",
      "remote360": "NOT_SUPPORTED",
      "carCloud": "ENABLED",
      "vehicleFinder": "UNKNOWN",
      "sendPoi": "NOT_SUPPORTED",
      "doorLock": "UNKNOWN",
      "doorUnlock": "UNKNOWN",
      "remoteSoftwareUpgrade": "ENABLED",
      "climateNow": "ENABLED",
      "remoteEngineStart": "ENABLED",
      "chargingControl": "TWO_TIMES_TIMER",
      "lastDestinations": "ENABLED",
      "ipa": "ENABLED",
      "chargeNow": "ENABLED",
      "smartSolution": "ENABLED",
      "rangeMap": "RANGE_CIRCLE"
    }
  }
]
```

### Get Vehicle API

`GET /vehicles/{vin}`

```json
{
  "vin": "WXG0982344910",
  "model": "320d",
  "headUnit": "MGU",
  "brand": "BMW",
  "driveTrain": "CONV",
  "capabilities": {
    "ventilation": "ENABLED",
    "heating": "NOT_SUPPORTED",
    "cooling": "NOT_SUPPORTED",
    "lightFlash": "ENABLED",
    "honkHorn": "DISABLED",
    "climateTimer": "START_TIMER",
    "remote360": "NOT_SUPPORTED",
    "carCloud": "ENABLED",
    "vehicleFinder": "UNKNOWN",
    "sendPoi": "NOT_SUPPORTED",
    "doorLock": "UNKNOWN",
    "doorUnlock": "UNKNOWN",
    "remoteSoftwareUpgrade": "ENABLED",
    "climateNow": "ENABLED",
    "remoteEngineStart": "ENABLED",
    "chargingControl": "TWO_TIMES_TIMER",
    "lastDestinations": "ENABLED",
    "ipa": "ENABLED",
    "chargeNow": "ENABLED",
    "smartSolution": "ENABLED",
    "rangeMap": "RANGE_CIRCLE"
  },
  "properties": {
    "lastUpdated": "2019-07-17T12:42:20Z",
    "mileage": {
      "value": 13000.0,
      "units": "KILOMETERS"
    },
    "fuel": {
      "remainingFuel": {
        "value": 30.0,
        "units": "LITERS"
      },
      "maxFuel": {
        "value": 300.0,
        "units": "LITERS"
      },
      "remainingRangeFuel": {
        "value": 300.0,
        "units": "KILOMETERS"
      },
      "maxRangeFuel": {
        "value": 500.0,
        "units": "KILOMETERS"
      }
    },
    "charging": {
      "chargingStatus": "CHARGING",
      "chargingLevel": {
        "highVoltagePercent": 3.3,
        "lowVoltagePercent": 5.5
      },
      "chargingConnectionType": "CONDUCTIVE",
      "chargingTimeRemaining": {
        "value": 1027.5,
        "units": "MINUTES"
      },
      "remainingRangeElectric": {
        "value": 35.0,
        "units": "KILOMETERS"
      },
      "maxRangeElectric": {
        "value": 100.0,
        "units": "KILOMETERS"
      }
    },
    "doors": {
      "securityState": "PARTIALLY_LOCKED",
      "hood": "CLOSED",
      "driverFront": "CLOSED",
      "driverRear": "CLOSED",
      "passengerFront": "CLOSED",
      "passengerRear": "OPEN",
      "trunk": "CLOSED"
    },
    "roof": {
      "sunroof": "INTERMEDIATE_TILT",
      "convertibleRoof": "OPEN"
    },
    "windows": {
      "driverFront": "CLOSED",
      "driverRear": "CLOSED",
      "passengerFront": "CLOSED",
      "passengerRear": "CLOSED",
      "rear": "NOT_SUPPORTED"
    },
    "position": {
      "latitude": 47.5598,
      "longitude": -83.4556,
      "heading": 25.0,
      "altitude": 900.0
    },
    "service": {
      "maintenanceItems": [
        {
          "name": "OIL",
          "state": "OK",
          "mileage": {
            "value": 48000.0,
            "units": "KILOMETERS"
          },
          "dueDate": "2019-03-17T12:42:20Z",
          "description": "Next service due when the stated distance has been covered or by the specified date."
        }
      ],
      "checkControlMessages": [
        {
          "id": 1,
          "mileage": {
            "value": 23.0,
            "units": "KILOMETERS"
          },
          "name": "Tire pressure",
          "description": "Tire pressure is low"
        }
      ]
    }
  }
}
```

With this approach, the Mobile 2.0 Client can make a single call for a vehicle (if no vin is provided, we default to the first in the list).

#### Vehicle Bloc

We can have a `VehicleBloc` which has `Loading`, `Loaded`, and `Error` states one level above the `Vehicle`, `Destination`, and `Profile` tab widgets so that features which require vehicle data only need to declare a dependency on the `VehicleBloc`.

We can also have our dart `Vehicle` expose getters for things like `isSendPoiEnabled`, `isVehicleFinderSupported`, etc... (like `@bmw-lit/vehicle`).

#### Bloc Composition

At the feature development layer, I propose we use a composition approach for the blocs. For example, if in the `DestinationTab` we have a dependency on the vehicle, rather than having nested `BlocBuilders` in the UI we can still maintain a single `DestinationBloc` which has a dependency on the `VehicleBloc`. This would allow the `DestinationBloc` to update its state in response to changes in the `VehicleBloc` while simultaneously keeping the UI layer simple (single `BlocBuilder`).

<div class="mermaid">
  graph TB
    VehicleBloc -- vehicle model --> VehicleTabBloc
    VehicleTabBloc -- vehicle tab model --> VehicleTab
    VehicleBloc -- vehicle model --> DestinationTabBloc
    DestinationBloc -- destination model --> DestinationTabBloc
    DestinationTabBloc -- destination tab model --> DestinationTab
</div>

### Final Thoughts

The proposed changes would allow us to:

- Have a unified vehicle state throughout the entire app
- Enforce unidirectional data flow for vehicle data and synchronized updates
- Reduce load on the backend (composite services don't all need to request the same data from vehicle shadow)
- Simplify development because as a developer, I would have access to the user's vehicle from all three tabs and don't need to create an entirely new microservice or modify an existing microservice whenever I need access to vehicle data.
