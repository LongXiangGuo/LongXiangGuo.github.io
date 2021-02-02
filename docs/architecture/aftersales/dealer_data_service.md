---
layout: default
title: Dealer Data Service
parent: Aftersales
nav_order: 8
grand_parent: Architecture
---

_Template Version 0.0.1_

**Author(s):** _Kyle Bremer_  
**Feature Link:** _[BMWO-165801](https://suus0002.w10:8080/browse/BMWO-165801)_  
**T-shirt Size Estimate:** _S_

## System Level Overview

In the same vein as the [Booking Details Service](https://code.connected.bmw/arch/pregrooming/blob/master/_docs/v10.8/bookingDetailsService.md) architecture and [Preferred Service Partner Service](https://code.connected.bmw/arch/pregrooming/blob/master/_docs/v10.8/PreferredServicePartnerService.md) the `Dealer Data Service` looks to extend the ideology of modularizing `Dealer Search Service` into manageable and distinct services. The `Dealer Data Service` will solely be responsible for maintaining an up-to-date store of dealers in all markets `Dealer Search` currently supports and querying dealers based on a location or id. We will also take this opportunity to move storing dealers in a `Redis` cache to a `SQL` database.

## Code Level Details

This architecture will expose two new endpoints to be used solely by the forthcoming `Dealer Services` which will act as a façade to this service, `Booking Details Service`, and `Preferred Service Partner Service`.

### Background

The exisiting relationship between the `Dealer Search Cache Updater` and `Dealer Search Service` is shown below:

![](../../../../assets/images/architecture/aftersales/dealer_data_service/dealer_data_cache_updater_relationship.jpeg)

This current implementation exposes an anti-pattern of two microservices sharing a common data store.

#### Dealer Search Cache Updater

The `Dealer Search Cache Updater` is a microservice running on a timer that will fetch dealers for all markets currently supported by `Dealer Search`. We have to update two separate key-values stores; one for geospatial queries (key is each brand and the value is another key-value pair of `dealer_id`s and geolocations). The other is for retrieving a specific dealer by id (key is `{dealer_id}_{brand}`and value is the `dealer` object). This becomes an issue when we fail to fetch a countries dealers. The data will continue to exist in the cache of `dealer_id`s and their respective details since the non-fetched dealers are not removed or written, but will not exist when doing a geospatial query since it **IS** overwritten each time.

For RoW countries, an endpoint from `GCDM` is used and for NA countries an endpoint from `FG-AM-82` is used. The need for this service arose based on performance and reliability of the mentioned services.

#### Dealer Search

As mentioned above the `Dealer Search Service` consisted of three pieces: fetching the `preferred service partner`, fetching booking details, and fetching `dealer` data. On top of fetching these, `Dealer Search Service` would merge all of these together into one response to send back to the client. This 'micro'service is beginning to turn into a monolith and so modularizing the pieces will make maintainability easier and prevent scope creep.

### Data Design

The most difficult piece of this architecture will be designing a database that will allow us to compete with the speed of `Redis` while maintaining the data's integrity and filter-ability. A large push to moving to a relational database is highlighted briefly in the `Dealer Search Cache Updater` section. Instead of having two key-value stores we will have one database with 8 tables that collectively make up the `dealer object`. Geospatial queries can be executed through `PostGIS` and in the event a countries' data is not fetched from our dependencies, data is always available.

#### Schema

The schema should be simple to understand as all the tables together make up the `dealer` object. ![](../../../../assets/images/architecture/aftersales/dealer_data_service/dealer_data_schema.png) It should be noted that nothing new is being added to the `dealer` object other than an `id` that auto-increments on each of the tables which will have more performant joins across tables.

#### Benefits of using a relational database

We will be utilizing a `PostgreSQL` database with the [PostGIS](https://postgis.net/) extender to allow for geospatial queries using latitude and longitude. `PostgreSQL` will provide us the ability to setup foreign key relationships between tables to maintain referential integrity. The most obvious reason for moving to a relational database is the ease of filtering and querying data which has proven difficult using `Redis` and will additionally provide market data to other teams about dealers. We will also more easily be able to update entries instead of needing the data for all the dealers in the whole world to update the geospatial entries. If you're interested in our use cases, [here](https://gist.code.connected.bmw/KyleBremer/fe7bb34ea2002f24a65bd119e99d23cc) is a gist I wrote for a spike comparing `PostgreSQL` to `Redis` for this exact architecture.

#### Free Text Search

In addition to querying dealers by `geolocation` and `dealerId` we will offer users the ability to perform free text searches to more accurately find dealers. We will utilize `PostgreSQL`'s Full Text Search capabilities since the amount of dealer data we have is small. Since the dealer object is now spread across 8 seperate tables we will create a [materialized view](https://www.postgresql.org/docs/9.3/rules-materializedviews.html) which will give us the ids for the `dealers` table in addition to a column of type [`tsvector`](https://www.postgresql.org/docs/9.3/datatype-textsearch.html). `tsvector` is a sorted list of distinct of lexemes, which are words that have been normalized to merge different variants on the same word. The values in a `tsvector` are what are used to query against for our free text searches. Below highlights the materialized view:

```sql
CREATE MATERIALIZED VIEW searchable
AS
SELECT dealers.id AS dealers_id,
    to_tsvector(concat_ws(' ',dealers.brand, dealers.business_name, addresses.city, addresses.state, addresses.street_one)) AS tsv
FROM
    dealers
LEFT JOIN
    addresses ON dealers.id = addresses.dealers_id
;
```

An example of the output with the Perillo dealer:

```sql
select * FROM searchable;
```

| dealers_id | tsv                                                                               |
| ---------- | --------------------------------------------------------------------------------- |
| 1          | '1035':7 'bmw':1,3 'chicago':5 'clark':9 'il':6 'inc':4 'n':8 'perillo':2 'st':10 |
| 2          | '170':7 'automag':2 'bmw':1 'gmbh':3 'landsberg':5 'münchen':4 'str':6            |

Here, `tsv` contains the lexemes from the `dealers.brand, dealers.business_name, addresses.city, addresses.state, addresses.street_one` columns as keys and the values are positions used to indicate the source word's location in a document and can be used for proximity rankings and weighted results.

In order to query the dealers and have partial matches on words we need to use the following query:

```sql
    SELECT DISTINCT(dealers_id) FROM searchable WHERE tsv @@ to_tsquery('simple', 'Per:*');
```

The `@@` operator checks if the `tsvector` matches the `tsquery` using the `simple` configuration determines the parser, dictionary, and types of tokens used. It should be noted that this configuration selection may need to be something custom in order to recognize and stem words into lexemes from other languages, though, the use of words in other languages is minimal. What is being searched for is `Per` and the `:*` denotes partial matches. The view will need to be rebuilt when data is changed and will be done as a part of the update process.

An example of this running in Docker is available [here](https://code.connected.bmw/KyleBremer/postgres-fts-example).

### API Definition

#### Updating Dealers

The mechanism for updating dealers is rather simple and can be shown below:

![](../../../../assets/images/architecture/aftersales/dealer_data_service/dealer_data_service_caching.jpeg)

For each country and each brand: grab the dealers, map them to a `dealer` and save them in the database. This will batch updates by country. We will eventually deprecate the `Dealer Search Cache Updater`. For now, to minimize risk, we will continue to utilize the `Dealer Search Cache Updater` and update the newly created table. After sufficient time and testing, we will rely on the `Dealer Data Service` to update dealers.

We will eventually place a way to invalidate dealers within the table but will be an implementation detail and not discussed here.

An endpoint will be made available to manually run the updating of dealers. It will be limited in use to necessary one-off updates.

#### Querying Dealers

Querying dealers will consist of a single endpoint that will support searching for dealers based on `geolocation`, `dealerId`, and `query`. It should be noted that in `Dealer Search Service` searching by `geolocation` and `dealerId` are separate endpoints and searching by `query` is not supported at all. The decision to combine them is to prevent redundant logic of getting dealers. It should be reiterated that this endpoint will solely be used by the forthcoming `Dealer Services` façade service and will handle the separation of searching by `geolocation`, `dealerId`, and `query`.

<img src="../../../../assets/images/architecture/aftersales/dealer_data_service/dealer_data_proposed_architecture.jpeg" alt="drawing" height="880" width="540"/>

[Here](https://suus0001.w10:8090/display/KB/Dealer+Data+Service+Proposal) is a Confluence Page that has an example Swagger.

## Design Checklist

**What risks does the team need to be concerned with before taking on this feature**

Risks are minimal as there's no additional logic being added to this feature, just splitting from a larger microservice. What may delay development is the use of a new language and frameworks.

**What existing components are modified by this design?**

The `Dealer Search Cache Updater` service will be deprecated.

**What new components are created by this design?**

A new microservice searching for dealers and a `PostgreSQL` database to store the dealers.

**Are any new technologies/frameworks being used?**

Yes, `Go` will be used as the primary development language.

**What security issues does this design introduce and how are they resolved?**

Nothing besides there being another microservice and database deployed that need to be secured appropriately.

**What privacy issues does this design introduce and how are they resolved?**

This service does not store any private data.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

No new feature is added to a client. But, by making searching for dealers easier to manage, this will allow us to more easily support new clients. Also, it's necessary to store dealer data in a SQL table so we can query by other fields instead of lat/long in the future.

**What performance issues may affect this feature and how are they resolved?**

Performance issues for this service should be minimal as it not stateful and can easily scale horizontally. In the event our third parties experience failures `dealers` will that are currently in the database will served but may be stale if an update to dealers has occured during their outage.

**Will this feature add additional cloud hosting costs?**

Yes, for each environment an instance of the `Dealer Data Service` and an instance of `PostgreSQL` will be added.

**Will this service generate additional load/requests on any external dependent services?**

No, this will generate the same load as existing `Dealer Search Service`.

**What dependencies does this feature rely upon?**

We rely on FG-AM-82 for dealer data in NA and GCDM for dealer data in EMEA. These services are intact and currently being utilized in `Dealer Search Service`.

**How will this feature be tested, monitored, and evaluated?**

The same as any other microservice, we will setup alerts for high numbers of errors or long response times. Testing will include automated E2E tests written by our Test Engineers.

**How will this feature be deployed?**

Using the regular Github/Jenkins pipeline.

**Does this feature have regional implications?**

This could have regional implications as one region's endpoint could fail (NA vs RoW). Dealers will still exist within the tables, but may not be up-to-date. This is the current way it works and is not something introduced by this work.

**Has any new IP been generated from this design?**

No.
