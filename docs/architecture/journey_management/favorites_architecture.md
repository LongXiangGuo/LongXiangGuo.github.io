---
layout: default
title: Eadrax Favorites Architecture
parent: Journey Management
grand_parent: Architecture
nav_order: 1
---

## Favorites Architecture

* **Author(s):** CTW Team Odyssey
* **Feature Link:** https://atc.bmwgroup.net/jira/browse/NWAP-186
* **T-shirt Size Estimate:** M

## System Level Overview

The goal of this feature is to make the Favorites compatible across all the new features being implemented in the Eadrax app and to have a unified way to create, update and delete any type of favorite, be it home and work or a normal favorite, and have the changes to favorites be reflected on the vehicle in a fast, reliable and seamless manner.

There are only 3 major dependencies with this change:

* The `Destination Composite Service` - [Swagger](https://btceuint-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=destination-composite-service)
* The `Personal Data Service (PDS)` - [Swagger](https://suus0003.w10:7990/projects/BAC/repos/personaldataservice/browse/PersonalDataService/Swagger/pdsswagger.yaml)
* The `PERSEUS Service`

You can see all `Favorites` flow in [here](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=568507331).

### Architecture

<img src="{{site.baseurl}}/assets/images/architecture/mobile2_favorites_arch.png">

The picture above shows all impacted services.

The picture above shows the change proposals for all impacted serviçes. They are highlighted in green.
These should be compatible with the services currently using PDS because they are all additive.

The changes are the following:

1. Bring PERSEUS V3 API support to PDS. The developers behind PERSEUS API are recommending services to update to V3 for better responsiveness and stability when saving and reading favorites form PERSEUS.

1. Update PDS to support CRUD operations to the Home and Work favorites. This is to allow the mobile client not only make changes on normal favorites but also on the Home and/or Work favorites. These changes should be reflected in the vehicle every time the user makes any changes.

1. Introduce the following new attributes to be able to reference to POI details when displaying the favorite details and to reference the car POI category Id System:
    * References to the IDs used in BMW’s POI System (LOS).
    * Entry Points of POI's.
    * Car POI Category type.
    * Full Address Model Used by LOS and Send to Car Services.

[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

## Code Level Details

The following diagram shows the steps to be able to add, edit and delete a favorite.

<img src="{{site.baseurl}}/assets/images/architecture/Favorite Sequence Diagram.png">

Here's what PDS currently returns when you do a GET request:

```JSON
{
    "favorites": [
        {
            "id": 1582114722156,
            "name": "Simple Favorite",
            "poiName": "Simple Favorite Poi Name",
            "address": "Test street A1, 2970-300 Lisbon, Portugal",
            "date": "2020-02-19T12:18:42",
            "location": {
                "latitude": 38.722252,
                "longitude": -9.139337,
                "height": 0.0
            }
        }
    ]
}
```
You can see that we get a list of favorites. In this case only one is displayed because the user only has one normal favorite.
We can also see that if we were to only use what this data provides, we would not be able to relate this favorite with any POI System (in this case LOS).

With the suggested changes we would end up with something like this:

```JSON
{
    "favorites": [
        {
            "id": 1582114722156,
            "name": "Simple Favorite",
            "poiName": "Simple Favorite Poi Name",
            "providerId": 0,
            "providerPoiId": "*string identifying this exact POI for the provided provider*",
            "vehicleCategoryId": 1234, //integer identifying the vehicle category on LOS, this is categoryId from PERSEUS,
            "address": "Test street A1, 2970-300 Lisbon, Portugal",
            "fullAddress": {
                "street": "*string related to key 14 in PERSEUS*",
                "houseNumber": "*string related to key 16*",
                "postalCode": "*string related to key 17*",
                "city": "*string related to key 13*",
                "country": "*string related to key 11*",
                "countryCode": "*string related to key 19*",
                "region": "*string related to key 12*",
                "regionCode": "*string related to key 20*",
                "settlement": "*string related to key 33*",
            },
            "date": "2020-02-19T12:18:42",
            "location": {
                "latitude": 38.722252,
                "longitude": -9.139337,
                "height": 0.0
            },
            "entryPoints": [
                {
                    "latitude": 38.76173,
                    "longitude": -9.15948
                }
            ]
        }
    ]
}
```

With the new fields we'll be able to correlate this exact favorite with the LOS system and be in sync with the rest of the mobile client.
This will also enable users to more effectively use their favorites with the send to car feature.
The addition of the vehicleCategoryId will help the BFF or the App to correctly assign the category icon on the vehicle.
With the new fullAddress parameter we'll be able to better relate the exact POI and expose more information to the Car and in the user's favorites list.
The CategoryId from PERSEUS is like this:
```JSON
"categoryId": "11040:2080"
```
In here only the first number ( the one before the " : " ) should be used.

To further simplify the models and how they relate with the data coming from PERSEUS, here is a table describing how each field relates to the response object returned from PERSEUS:

**Relation between PDS Fields and PERSEUS Fields**

| PDS Field | PERSEUS Field | Obs. |
| --- | --- | --- |
| id | id | The object Id returned from PERSEUS |
| name | name |  |
| date | date |  |
| poiName | location.address.poiName and<br>location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 1 AND textDescriptorList[N].Id == N |
| providerId | location.address.providerId |  |
| providerPoiId | location.address.providerKey |  |
|  | location.address.poiId | On PERSEUS the POI id contains a item id and a source id (itemId:sourceId).<br>The source id signals from where the element comes from (0=nds, 1=personalPoi, 2=kml, 3=liveLayer).<br>When creating or updating a favorite we should always write (0:0) on this field |
| vehicleCategoryId | location.categoryId | In here again, PERSEUS will return (categoryId:sourceId) and what we want is only the categoryId.<br>When creating of updating this field we should write (vehicleCategoryId:0) |
| address | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 178 |
| fullAddress.street | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 14 |
| fullAddress.houseNumber | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 16 |
| fullAddress.postalCode | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 17 |
| fullAddress.city | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 13 |
| fullAddress.country | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 11 |
| fullAddress.countryCode | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 19 |
| fullAddress.region | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 12 |
| fullAddress.regionCode | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 20 |
| fullAddress.settlement | location.address.description.<br>textDescriptorList[N].value.text | Where the textDescriptorList[N].key == 33 |
| location.latitude | location.address.location.latitude |  |
| location.longitude | location.address.location.longitude |  |
| location.height | location.address.location.height |  |
| entryPoints.latitude | location.address.alternatives[N].position.latitude |  |
| entryPoints.longitude | location.address.alternatives[N].position.longitude |  |
|  | location.address.internalData | Lastly, this element doesn't match any of the new fields on pds but it's important to remember to set this as null when updating or creating a favorite.<br>It relates to the map on the car and it needs to be reset after editing or creating. |

As for the entry points, I believe it deserves its own showing due to the complexity.

```JSON
"alternatives": [
    {
        "bitmap": false,
        "boundingBox": {
            "bottomRight": {
                "height": -1000000,
                "latitude": -666,
                "longitude": -666
            },
            "topLeft": {
                "height": -1000000,
                "latitude": -666,
                "longitude": -666
            }
        },
        "id": 0,
        "objectIdentifier": "454E5452414E4345504F494E54",
        "position": {
            "height": 0,
            "latitude": 48.136282486,
            "longitude": 11.574676037
        }
    }
]

```
This is a snip from the alternatives for reference.
The id represents the entrance number in the list ( 0...n ).

### To take note when working with PERSEUS and Favorites

It's important to remember that the objectIdentifier field should always be updated/created with the "magic value".
This "magic value" ("454E5452414E4345504F494E54") is a key that tells the vehicle that this is a entry point.

Some historical context: Some time ago the field "providerKey" was called providerKey everywhere, in the car and in the back-end. But back then people always mixed up the fields “providerId” and “providerKey” and it led to errors exchanging them quite often.
Therefore newer systems now call this field “providerPOIId” to avoid the similarity to “providerId”.
The DI Controller still uses the old naming.

Therefore the following relationship holds: providerKey == providerPOIId

[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

## Client Details

- Destination Screen
-- Add favorite button next to search bar which should be controlled by destination composite service.

- Favorite Screen
-- The presentation data will come from the destination composite services GetFavorites(). It should support "Edit/Delete" functions which are also supported by destination composite API deleteFavorite()/editFavorite()

- Destination Detail Screen
-- The favorite button needs to be added, which is also controlled by destination composite service. This screen will support addFavorite/deleteFavorite.

### Cache Details

The cache was implemented using the HydratedBloc library that persists the state of our FavoritesBloc automatically. This cache is updated each time that the user enters in the favorites screen.

The search service doesn’t provide the information about whether a POI is favourited or not. That’s why the cache is also available in the destinations tab initial screen (the map). Through this, the user gets instant feedback about whether a POI was favorited or not. The POI-favorite match criteria depends on the address and coordinates of the location.

There is also a refresh cache event that is triggered the first time that the destinations tab is initialised. This is because we want to ensure that this cache is updated when the user didn’t navigate to the favorites screen yet. The cache update criteria depends on the lifetime of the cache, it shouldn’t be bigger than 5 minutes.

## Monitoring

Currently we are monitoring the Favorites through the `Destination Composite Service` grafana dashboard [here](https://monitor.connected.bmw/d/_l0PzqRGz/destination-composite-service?orgId=1&refresh=1d).

To identify errors, which eventually occur, we need to acess [Azure Portal](https://portal.azure.com/#@btcmyc.com/resource/subscriptions/0196745a-1af0-48df-9559-603e99c5d246/resourceGroups/btcpdsrgeudev/providers/Microsoft.Insights/components/btcpdsaieudev/logs).

## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)
PERSEUS might not always have all the required fields to fill these new parameters.

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)
* Personal Data Service
* Destination Composite Service

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)
None.

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)
None.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)
None compared to existing design.

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)
None compared to existing design.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)
Mobile 1.0 client should not be impacted by this change and it won't need any update.

Mobile 2.0 client will use the proposed new data to implement Home/Work favorites and use the ability to correlate the favorite with LOS, to bring more data when viewing it's details.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)
The performance in the affected microservices won't change. The scaling of these serviçes will be just like how it works in this moment.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)
Cloud hosting costs are not projected to increase.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)
None.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)
The main dependencies are going to be the PERSEUS service hosted in FG, just like it is today.

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)
At the moment, PDS still uses the azure monitoring ecosystem. This is due to the fact that this service still hasn't been transferred to the mesh.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)
The services will be updated and a normal update process will occur with them.
No toggles necessary for this.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])
No changes from current architecture.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)
None.
