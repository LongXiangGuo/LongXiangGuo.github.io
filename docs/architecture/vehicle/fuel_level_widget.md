---
layout: default
title: Fuel Level Widget
parent: Vehicle
nav_order: 8
grand_parent: Architecture
---

# Fuel Level Widget (FLW)

{: .no_toc }
The purpose of the Fuel Level Widget is to show the user the mirrored status from the vehicle.
The Fuel Level feature includes Combustion, Electric, Hybrid and REX vehicles showing specific information for each one. BMW and MINI each have their own seperate design.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## BFF Model

The logic of the information of FLW comes from a BFF Service. The BFF implements all the logic regarding what text, values and icons are shown. The FLW is only responsible to display the informaion required by the characteristics of the car in the Application. The FLW receives a list of BFF models and depending on the type of drivetrain, one model is received or, in the case of Hybrid and REX, a list of three models are received.

More documentation [here](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=529080442)

## UX / UI

Depending on the type of the ATM model and the different drivetrains, the FLW is displayed with different information regarding fuel level and range. For electrical and hybrid vehicles, charging indication is shown by having different icons by charging state.

### Combustion ATM 1

FLW shows estimated fuel capacity and range. That's indicated by the '~' before fuel capacity.

![BMW Combustion ATM 1]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_combustion_atm1.png)

![MINI Combustion ATM 1]({{site.baseurl}}/assets/images/architecture/vehicle/mini_combustion_atm1.png)

### Combustion ATM 2

For ATM2 the current capacity of fuel of the car is known so the FLW shows accurate fuel capacity and range.

![BMW Combustion ATM 2]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_combustion_atm2.png)

### Battery Electric Vehicle (BEV)

For BEV vehicles range and electricity percentage are shown.

![BMW BEV]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_electric.png)

![MINI BEV]({{site.baseurl}}/assets/images/architecture/vehicle/mini_electric.png)

### PHEV

For these vehicles, since we have a combined range, swiping the FLW will show different information:

State 1: Combined Range

State 2: Electric Level

State 3: Fuel Level

![BMW PHEV - Combined Range State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_hybrid_1.png)

![BMW PHEV - Electric Level State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_hybrid_2.png)

![BMW PHEV - Fuel Level State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_hybrid_3.png)

![MINI PHEV - Combined Range State]({{site.baseurl}}/assets/images/architecture/vehicle/mini_hybrid_1.png)

![MINI PHEV - Electric Level State]({{site.baseurl}}/assets/images/architecture/vehicle/mini_hybrid_2.png)

![MINI PHEV - Fuel Level State]({{site.baseurl}}/assets/images/architecture/vehicle/mini_hybrid_3.png)

### REX

Range Extended vehicles have a combined range so swiping the FLW will also show different information:

State 1: Electric Level

State 2: Combined Range

State 3: Extended Range

![BMW REX - Electric Level State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_rex_1.png)

![BMW REX - Combined Range State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_rex_2.png)

![BMW REX - Extended Range State]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_rex_3.png)

## Charging information

### Charging

For BEV, Hybrid and REX vehicles, the icon and text is shown to indicate the charging state of the vehicle.

![BMW Charging]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_charging.png)

### Charging Fallback

![BMW Charging Fallback]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_charging_fallback.png)

![MINI Charging Fallback]({{site.baseurl}}/assets/images/architecture/vehicle/mini_charging_fallback.png)

### Not Charging/With error

![MINI Charging Error]({{site.baseurl}}/assets/images/architecture/vehicle/mini_charging_error.png)

### Fully Charged

![BMW Fully Charged]({{site.baseurl}}/assets/images/architecture/vehicle/bmw_fully_charged.png)

![MINI Fully Charged]({{site.baseurl}}/assets/images/architecture/vehicle/mini_fully_charged.png)
