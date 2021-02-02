---
layout: default
title: Send destination to car
parent: Journey Management
grand_parent: Architecture
nav_order: 4
---

## Send destination to car

* **Author(s):** CTW Team Odyssey
* **Feature Link:** https://atc.bmwgroup.net/jira/browse/NWAP-68

## System Level Overview

The purpose of this feature is to send a destination to the car and have this destination reflected on the vehicle in a fast, reliably and seamless manner.
This way the user can view the destination on his vehicle and, if he so chooses, start the guidance to that destination independently of the vehicle the user might have (MGU or Legacy).

There are only 5 major dependencies with this feature:

* The Destination Composite Service - [Swagger](https://btceuprd-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=destination-composite-service)
* The Send to Car service - [Swagger](https://btceuprd-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=send-to-car-service)
* The Trip Service - [Swagger](https://btceuprd-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=trip-service)
* The Vehicle Service - [Swagger](https://btceuprd-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=vehicle-service)
* The Message Service

You can see all Send to Car flow in [here](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=534538765).

### Architecture

<img src="{{site.baseurl}}/assets/images/architecture/mobile2_architecture.png">

The picture above shows all impacted services.

As you can see in the picture the `Mobile 2.0 App` sends a destination to the `Destination Composite Service` and then the composite calls `Send to Car Service`.

The `Send To Car Service` receives the destination and then calls the `Vehicle Service` to know the brand and the type of the vehicle's head unit.
After that, the `Trip Service` is called to create a trip, and if the car has a legacy head unit then a call is made to the Message Service to send the location to that vehicle.

[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

## Code Level Details

<img src="{{site.baseurl}}/assets/images/architecture/sendToCarFlow.png">

In this sequence diagram we can get an overall view of how this feature works.
Here we can see the process we take to send a destination to the vehicle.

The composite receives the destination from the app and fills the model data that is required for the call to the send to car service.

The send to car service tries to get information about the vehicle head unit, calling the Vehicle Service. If the destination was marked has having missing location data, will try to complete this data making a request for that location on LOS.

Then the send to car service comunicates with the Trip Service to create a new trip, with the received destination, and deletes all the outdated trips for that user.

If the trip was created successfully and the car has a legacy head unit, the trip is sent to the Message Service who is responsible for sending a message with the trip to the car.

If all this happened successfully, the Send To Car Service returns the trip to Destination Composite Service and this in turn to the app.

### Client Details

This feature is encapsulated inside an specific widget, named `SendToVehicleArea`. This widget manages all the possible flows and states of this feature. It has a Bloc class that contains the business logic, named `SendToVehicleBloc`. This Bloc is the one that manages the communication described before (through the `DestinationsRepository` and `DestinationsApiClient`).
The widget and Bloc code lives inside the `Destinations feature module`, that is the one that contains all the logic related with the Destinations Tab.

## Monitoring

For this functionality we do the monitoring through the `Grafana Dashboard` and also identify errors, which eventually occur, with the help of `Kibana`.

* Grafana Dashboard for [Send to Car Service](https://monitor.connected.bmw/d/BPbgSR8Wk/send-to-car-service?orgId=1&refresh=1h)~
* Dashboar for [Alerts - Send to Car Service](https://monitor.connected.bmw/d/Tme26IMGk/alerts-send-to-car-service?orgId=1)
* Grafana Dashboard for [Destination Composite Service](https://monitor.connected.bmw/d/_l0PzqRGz/destination-composite-service?orgId=1&refresh=1d)
* Search for errors on [Kinana](https://btceuint-dev.westeurope.cloudapp.azure.com/kibana/app/kibana#/discover?_g=()&_a=(columns:!(_source),index:'6ef4ba40-e0b7-11e9-a59e-c344a222ac4a',interval:auto,query:(language:lucene,query:''),sort:!('@timestamp',desc)))
