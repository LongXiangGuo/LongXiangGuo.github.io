---
layout: default
title: Third Party PSP
parent: Aftersales
nav_order: 10
grand_parent: Architecture
---

# Third Party PSP Support

**Author(s):** [99 Luftballons](mailto:99_Luftballons_Scrum_Team@list.bmw.com)
 **Feature Link:** [NWAP-6814](https://atc.bmwgroup.net/jira/browse/NWAP-6814)
 **Wires:** [PSP](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=634079546)

## Feature Overview

The goal of this feature is to provide support for letting a user know that saving a dealer as their Preferred Service Partner (PSP) would override their current third-party dealer.

## Composite Service

There will need to be a new endpoint added to the [Dealer Services Composite Service](https://code.connected.bmw/after-sales/dealer-services-composite-service) for consumption by the client.

The implementation of this new endpoint will simply be a matter of calling a new upversioned endpoint in Dealer Search, which will return a new response model that includes a `thirdParty` boolean flag.

### API Changes

#### Request

`GET /v1/vehicles/{vin}/psp`

|Param|location|type|description|
|:---|:---|:---|---:|
|vin|path|string|the user's VIN|
|USID|header|string|the user's USID|
|X-TokenID|header|string|the user's GCDM token|

#### Response

##### 200 - Ok

```json
{
  "dealerID": "12345_01",
  "businessName": "BMW of Chicago",
  "thirdParty": false
}
```

##### 404 - Not found

No body

##### 422 - Business Logic Error

```json
{
  "statusCode": 422,
  "logTransactionId": "string",
  "logErrorId": "string",
  "logMessage": "string",
  "requestUrl": "string",
  "requestTimestamp": 0
}
```

## Client Changes

The changes that will be required on the client will be twofold:

1. If a user has a third-party PSP (`thirdParty` property is true), don't indicate in the app that they have a PSP on the vehicle tab or dealer results.
1. If a user has a third party PSP and tries to save a Dealer as Preferred, show a dialog before saving that asks them to confirm that the save will override their old PSP.

Otherwise, nothing will change on the client.


## Design Checklist

**What risks does the team need to be concerned with before taking on this feature**

The work outlined here shouldn't present any risks, as this functionality is self-contained and only modifies existing functionality.

**What existing components are modified by this design?**

* [Dealer Services Composite Service](https://code.connected.bmw/after-sales/dealer-services-composite-service)
* PSP Repository
* Dealer Search Feature Module

**What new components are created by this design?**

* Alert Modal that asks user to confirm before saving over a 3rd party PSP

**Are any new technologies/frameworks being used?**

No

**What security issues does this design introduce and how are they resolved?**

No new security issues are introduced

**What privacy issues does this design introduce and how are they resolved?**

No new privacy issues are introduced

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

This change will allow for the M2 client to support knowing a user has a PSP that's not known to our systems, a third party PSP, and asks to confirm before saving.

**What performance issues may affect this feature and how are they resolved?**

This doesn't include new performance concerns since we're still fetching PSP data from Dealer Search service, just from a new endpoint.

**Will this feature add additional cloud hosting costs?**

No

**Will this service generate additional load/requests on any external dependent services?**

No

**What dependencies does this feature rely upon?**

This depends on the Dealer Search service for PSP data

**How will this feature be tested, monitored, and evaluated?**

The same as our other microservices, we will set up alerts for performance issues and create graphs to monitor the application.

**How will this feature be deployed?**

Using the standard pipelines.

**Does this feature have regional implications?**

No

**Has any new IP been generated from this design?**

No
