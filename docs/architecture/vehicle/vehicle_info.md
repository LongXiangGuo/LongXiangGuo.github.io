---
layout: default
title: Vehicle Info
parent: Vehicle Area
nav_order: 3
grand_parent: Architecture
---

# Vehicle Area

## Client

#### As a non-authenticated user

This Feature can only be present with a authenticated user with a selected car

#### As an authenticated user

1. Show first information from cache.
2. Awaits for the latest up to date information.
3. Update UI with the up to date information.

### UI Breakdown

Widgets:

* Vehicle Info 
* Vehicle image
* Vehicle Settings Button

# Overview

This document covers the proposed widget information for each. This widget information will be retrieved by the local app information

# Vehicle Info Widget Information

| Widget Name  | Copy         | Vehicle Type | Widget Information |
| ------------ | ------------ | ------------ |------------------ |
| Vehicle Info | Vehicle Info & Settings | Any | model: year and model of the car<br>mileage: Distance<br>vin: number  |
| Vehicle Settings Button | VIEW | Any | Button that leads to the car settings page  |
| Vehicle Image | Vehicle Image | Any | Front view image of the currently selected car  |


# What does NULL Mean?

* If the client is to ignore specific widget information, then that information object shall be null
* If the value of a specific widget information object is supposed to be "--" then the value property shall be null

# Vehicle Info Widget Information Types

## Distance

* value: number
* units: DistanceUnits
