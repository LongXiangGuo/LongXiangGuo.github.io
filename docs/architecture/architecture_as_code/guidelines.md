---
layout: default
title: Guidelines
parent: Architecture as Code
grand_parent: Architecture
nav_order: 2
---

# Guidelines
In this chapter, the name convention defined for the BFF and core microservices under the Mobile 2.0 project is described, the way to define the API ID according to the guidelines, and how to document the information in the service repository.

* [Compass microservice ID name convention](#compass-microservice-id-name-convention)
* [API ID definition](#api-id-definition)
* [Update microservice meta information](#update-microservice-meta-information)

## Compass microservice ID name convention
In order to standardize the assignment of names for BFFs and core services rose on September 10, 2020, under [architecture circle the topic "Compass services name convention"](https://atc.bmwgroup.net/confluence/display/NWAP/Architecture+work+group).

The same was discussed and decided on September 16, 2020, with the following results.

Based on [microservice id attribution guidelines](https://atc.bmwgroup.net/confluence/display/CDARCH/AG+001+-+Microservice+IDs), including the limitation of 12 characters, the following standard has been agreed.

BFFs contain the prefix "mobile20" and core service the subproduct prefix.

Agreed pattern examples:
- BFF layer naming: **mobile20-PCT**;
- Core service layer naming: **eMob-PCT**.

Based on [microservice id attribution guidelines](https://atc.bmwgroup.net/confluence/display/CDARCH/AG+001+-+Microservice+IDs), the following formats are used to represent the Microservice ID:
- original: like defined in the Application List (e.g: eMob-PCT);
- uppercase: all uppercase with dashes (e.g: EMOB-PCT);
- lowercase: all lowercase with dashes (e.g: emob-pct);
- canonical: lowercase without dashes (e.g: emobpct).

The following table has the agreed prefix for each core service subproduct. 

| :-----------------------------:|
| Subproduct	| Prefix    |
| :-----------------------------:|
| eMobility	| eMob |
| 	|   |
| :----------------:| :--------: |


Please keep this table up to date with the prefix of the core service subproduct.

## API ID definition
According to the [BMW API guidelines](https://developer.bmw.com/connected-vehicle/develop/guides-and-tutorials/api-guides/#must-de-x-contain-bmw-api-meta-information), the API ID follows the format: &lt;vendor&gt;-&lt;platform&gt;-&lt;microservice id&gt;-&lt;api identifier&gt; (e.g. "bmw-omc-emobpct-privatechargingtariff").

Next describes each field:
- the vendor is typical "BMW";
- the platform in the Mobile 2.0 project is "OMC";
- the microservice ID must follow the Mobile 2.0 naming convention using the canonical format to be easier to read (e.g. "emobpct");
- the API identifier is typical a name of the API in the regex format "[a-z]+" (e.g. "privatechargingtariff").

## Update microservice meta information
The service repository and the Open API specification should include the meta information of the service.

As an example, the ["charging-data-privacy"](https://code.connected.bmw/emobility/charging-data-privacy/blob/master/src/1-Application/ChargingDataPrivacy.Application.WebApi/appsettings.json) service developed in .NET Core includes the meta-information in the settings file.