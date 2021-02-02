---
layout: default
title: Booking Details Service
parent: Aftersales
nav_order: 7
grand_parent: Architecture
---

_Template Version 0.0.1_

**Author(s):** [Nemanja Simeunovic](mailto:Nemanja.Simeunovic@partner.bmwgroup.com)

**Feature Link:** [BMWO-164526](https://suus0002.w10:8080/browse/BMWO-164526)

**T-shirt Size Estimate:** _M_

## System Level Overview

The high level goal of this work is to encapsulate the logic around fetching and parsing dealer booking information from the dealer search microservice into its own service while being backwards compatible with existing user clients hitting dealer search. We will also take this opportunity to rethink how the booking data is stored to mitigate some of the pain points around adding booking information and managing the existing data.

## Code Level Details

Put simply, this architecture refactors the current booking detail data model into distinct entities and allows CRUD-style resource management through different endpoints. Dealer Search will call this service for booking details instead of fetching and parsing dealer booking information directly.

### Background

Here are the groups of data that make up a single row of dealer booking info today:

- `dealer_id`, `brand` - represent a single dealer (dealer id is not sufficient since some dealerships service BMW and MINI and use the same dealer_id for both)
- `client platform`, `client version` - specifies a client platform and minimum version required for a booking detail entry
- booking engine information (`booking engine type`, `market`, `emails`, `language`, `external url` and `external id`) - data that makes up the booking information used by the client

What this results in is a lot of duplicated values, since at a minimum each dealer needs two rows of data for one booking engine. With the only difference between them being client platform and version.

For example, if we have one dealer (123) that supports `email` booking until iOS 10.0/Android 6.1.1 and `oas` afterwards, we will have two rows of data (iOS version and Android version) for each booking engine. In this case, 4 total rows of data.

| dealer_id | client  | version | booking_engine columns ... |
| --------- | ------- | ------- | -------------------------- |
| 123       | iOS     | 0       | email                      |
| 123       | Android | 0       | email                      |
| 123       | iOS     | 10.0    | oas                        |
| 123       | Android | 6.1.1   | oas                        |

The duplication is exacerbated due to a lot of dealers switching booking engines on iOS 10.0 and Android 6.1.1, which means those "iOS 10.0" and "Android 6.1.1" values are present in a lot of booking detail entries.

### Details

We plan to replace storing this data in one table with a total of 4 database tables: 3 entities and 1 join table. Here is their relationship:

![table-relationship](../../img/table-relationship.png)

Having these tables instead should allow us to reduce the overall volume of data we have stored. The process for fetching relevant booking details for a set of dealers will look like this:

1. Fetch `Dealer Brand` resources for each of the specified dealer ids and brand.
1. Fetch all the entries from the `Join Table` for those resources and join with the `Client Info` table.
1. Filter out all the linked `Client Info` entries belonging to different platforms.
1. For each distinct `Dealer Brand` item, find the closest `Client Info` to the user's client version that doesn't exceed it. This should result in each `Dealer Brand` having one `Booking Engine` remaining.
1. Fetch the remaining `Booking Engine` resources and return.

Below is the definition of each of the tables with an example row:

### Dealer Brand

| id  | dealer_id | brand  | market |
| --- | --------- | ------ | ------ |
| PK  | string    | string | string |
| d1  | 123_4     | BMW    | US     |

### Booking Engine

| id  | dealer_brand_id | booking_engine | market | language | emails                             | url                                  | external_id |
| --- | --------------- | -------------- | ------ | -------- | ---------------------------------- | ------------------------------------ | ----------- |
| PK  | FK to Dealers   | string         | string | string   | string                             | string                               | string      |
| b1  | d1              | oas            | B6_DE  | en_US    | email@domain.com;email2@domain.com | https://www.morenomotors.net/booking | 123         |

### Client Info

| id  | platform | version |
| --- | -------- | ------- |
| PK  | string   | string  |
| c1  | IOS      | 0       |

### Join Table

| id  | dealer_brand_id | client_info_id    | booking_engine_id         |
| --- | --------------- | ----------------- | ------------------------- |
| PK  | FK to dealers   | FK to client info | FK to booking engine info |
| j1  | d1              | c1                | b1                        |

### Swagger File

Download [here](https://suus0001.w10:8090/download/attachments/189957482/booking-details-svc-swagger.yml?version=1&modificationDate=1573663431341&api=v2)

Hosted [here](https://suus0001.w10:8090/display/~simeunovic/Booking+Details+Service+Draft+API+Proposal) for viewing

## Design Checklist

**What risks does the team need to be concerned with before taking on this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature. How does this affect the estimate. E.g. unknown or incomplete dependencies, preview software,etc.)

Since this service will be a new home for dealer booking detail data, and deploying it will require coordinating dealer search changes in addition to deploying the new service, the main risk would be any networking issues preventing communication between dealer search, the new service and the database layer.

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact. Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

[Dealer Search service](https://code.connected.bmw/after-sales/dealer-search-service) will fetch booking details from this service instead of hitting the azure storage layer directly.

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)

The Dealer Booking Details Service itself and a database instance.

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

No.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

Nothing besides there being another microservice and database deployed that need to be secured appropriately.

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

This service does not store any private data.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint: This means are you thinking cloud first?)

This doesn't add a new feature to a client. But, by making the booking data easier to manage, this will allow us to more easily support new clients that support dealer booking in a specific way.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally? What happens on the client if you have a broken or failed connection?)

This is not stateful and data is not updated during normal operation of the service (only when we want to add new dealers/update booking info), so the service and database should be able to scale very easily.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

Yes since there is a new microservice and database.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

No.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

None.

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected? What logs are generated?)

The same as any other microservice, we will set up alerts for high numbers of errors or long response times.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added? What criteria will trigger them?)

Using the regular github/jenkins pipeline.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No.
