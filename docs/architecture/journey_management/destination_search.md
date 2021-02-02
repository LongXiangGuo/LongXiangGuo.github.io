---
layout: default
title: Destination Search
parent: Journey Management
grand_parent: Architecture
nav_order: 1
---

# Destination Search

## Existing implementation

#### iOS

BMWMapkit framework has 4 search providers:

- Apple
- AutoNavi (China)
- Here
- Japan

iOS Client currently makes a call to BMK, which determines the map provider to do a free-text search, passing along coordinates. However, this is being changed to implement One Consistent Search.

## Phase 1: Free text poi search via the Commute API

- Commute Server has a [free text search API](https://suus0001.w10:8090/display/documentation/Commute+Server+API#CommuteServerAPI-FreeTextSearchAPI) that we will use for point of interest search. 
- This API will be replaced when `One Consistent Search` is available.

<div class="mermaid">
  graph LR
    commuteAPI --> destination-search-composite
    vehicleAPI --> destination-search-composite
    destination-search-composite --> flutter
    style commuteAPI fill:#f9f,stroke:#333,stroke-width:2px
    style vehicleAPI fill:#f9f,stroke:#333,stroke-width:2px
</div>

## Phase 2: One Consistent Search (OCS)

- [Swagger](https://btcpersonalsearchserviceappdly.azurewebsites.net/swagger/index.html)
- Currently being implemented by 99 Luftballoons
  - [Architecture Doc](https://suus0001.w10:8090/display/ARC/Free+Text+Search+Architecture)
  - Being implemented in 3 phases, currently in phase I. They are creating a new .NET Core microservice that will talk directly with HERE API
- Basic API that talks to LOS (Local Search) system in FG which handles using the correct search provider based on country code (from device) and locale
  - Two endpoints: Search & Dealer Details

##### Request

```
https://btcpersonalsearchserviceappdly.azurewebsites.net/v1/pois?Query=perillo&Latitude=41.881832&Longitude=-87.623177&Brand=BMW&Locale=en_us&Market=us
```

```
{
    query: string,
    latitude: number,
    longitude: number,
    brand: string,
    locale: string,
    market: string
    maxresults?: integer,
    radius?: number,
    distanceunit?: string
}
```

##### Response

```json
[
  {
    "name": "Perillo BMW, Inc",
    "phoneNumber": "(312) 981-0000",
    "address": {
      "administrativeArea": "",
      "city": "Chicago",
      "country": "United States",
      "countryCode": "US",
      "formattedAddress": "1035 N Clark St, Chicago, IL 60610",
      "houseNumber": "1035",
      "postalCode": "60610",
      "street": "N Clark St",
      "state": "Illinois",
      "suiteNumber": ""
    },
    "geolocation": {
      "latitude": 41.881832,
      "longitude": -87.623177
    },
    "poiSource": [
      {
        "type": "dealer",
        "value": "46786_01"
      },
      {
        "type": "generic",
        "value": "fake_generic_id"
      }
    ]
  }
]
```

##### Proposed approach

- Implement a Presentation API and have it use the same interface contract that the OCS microservice uses. This will allow us to have it mocked while OCS is being implemented. It will implement the data models defined in OCS architecture. After we mock out the OCS data schema, we can have the Presentation API use the initial search provider and have the Presentation API adapt the response data to the schema matching OCS.

- Full control of API, which can just return mock data in the correct format for now. If we implement our client to utilize the same model as what the new OCS microservice is using, then once they are complete with theirs, we can switch over to use it without extensive development work.

  - We can then have our Presentation API define what (if any) additional info we want to pass to the client

- Since OCS is being implemented in 3 phases, with Phase I currently under development, we will first create the Presentation API and have it go to the Commute Server (CS) for our initial launch in South Korea.
  - In the Presentation API, we will create models to adhere to OCS
  - We will initially set up the Presentation API to go to the Commute Server in order to support search in Korea.
    - This may require the Presentation API to massage the data to still keep the model we send to the client consistent for when we switch off of going to the Commute Server and switch over to using the OCS

##### Proposed Presentation API Model

_Note:_ `Address` and `Coordinates` imported from @bmw/presentation-models

```javascript
[
  {
    name: string,
    phoneNumber: string,
    address: Address,
    geolocation: Coordinates,
    poiSource: [
      {
        type: "dealer",
        value: "46786_01"
      },
      {
        type: "generic",
        value: "fake_generic_id"
      }
    ]
  }
];
```
