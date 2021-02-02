---
layout: default
title: OAS Native Schedule Service
parent: Aftersales
grand_parent: Architecture
nav_order: 7
---

# OAS Native Schedule Service

<img src="https://atc.bmwgroup.net/confluence/download/attachments/605782467/2.0%20Overview%20-%20Service%20Scheduling%20User%20Flow%20-%20Native.png?version=9&modificationDate=1586259708129&api=v2"/>
[Expand Image](https://atc.bmwgroup.net/confluence/download/attachments/605782467/2.0%20Overview%20-%20Service%20Scheduling%20User%20Flow%20-%20Native.png?version=9&modificationDate=1586259708129&api=v2)

## Feature Overview

[comment]: <> (This section should describe the overall system design of the feature. It should identify the various components that make up the solution [microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here. Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

The `OAS Native Schedule Service` feature will reside within the `Schedule Service` feature module.  The entrypoints on this feature module will determine when & how to present the native schedule or email schedule flow. 

---

## Feature Module
<img src="{{site.baseurl}}/assets/images/architecture/aftersales/oas_service_scheduling/native_scheduling_ui_flow_diagram.png">
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/oas_service_scheduling/native_scheduling_ui_flow_diagram.png)

The `OAS Native Schedule Service` feature will be a 1:1 port from the web application built for Mobile 1.0.

There are two flows within this feature. The first allows the user to create a new appointment by selecting one or more services, selecting an available time with optional mobility option, and submitting an appointment. The second allows the user to view an existing, future appointment, add the appointment to their calendar, send the dealer's address to their car, and cancel the appointment with the dealer.


---

## Entry Points

Currently, the only entry point for `OAS Native Schedule Service` will be the `Schedule Service Launcher` feature module. If a dealer's booking engine type is OAS, the launcher will open the Schedule Service feature module and pass in the `"oas-new"` or `"oas-view"` booking engine enum as a parameter.

---

## OAS Composite Service

<a name="oas-composite-index"></a>
Index

- [Preload Data](#oas-preload-data)
- [Get Appointments](#oas-get-appointments)
- [Get Timeslots](#oas-get-timeslots)
- [Submit Appointment](#oas-submit-appointment)
- [Cancel Appointment](#oas-cancel-appointment)

### General Notes

- All Oas Scheduling related endpoints will live at `/api/v1/oas-scheduling`
- All Oas Scheduling endpoints will return `"errors"` and `"warnings"` at top-level response body.  These will be array of enums indicating to the client what could have gone wrong while processing the request.
- `Errors` indicate something went wrong which would prevent the user from continuing the scheduling flow.  i.e. No user email found.
- `Warnings` indicate there was partial response returned from our dependences or a non-blocking dependency has returned a non-200 repsonse.  i.e. User profile information not found.  The user can continue the scheduling flow with warnings however maybe the client would like to present some messaging in these cases.
- All date timestamps follow [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601) in the format of YYYY-MM-DDTHH:mm:ssz i.e. 2020-04-14T16:29:34z

### Services & Repairs Page

<details>
  <summary>
    > Click here for designs
  </summary>
  <img src="https://atc.bmwgroup.net/confluence/download/attachments/605782467/1.1%20Selected%20Services%20-%20Service%20Booking_Native.png?version=5&modificationDate=1586261002649&api=v2"/>
</details>

<a name="oas-preload-data"></a>

#### HTTP Request

```
  GET /api/v1/oas-scheduling/preload-data
```

##### Headers & Query Params

| Param Name | Request Param | Required | Description |
| :--- | :---: | :---: | :--- |
| Authorization: {gcdmToken} | Header | ✓ | A valid gcdm token |
| x-usid: {usid} | Header | ✓ | Usid of the user associated with the gcdmm token |
| dealerId | Query Param | ✓ | Dealer Search Id of the dealership |
| vin | Query Param | ✓ | VIN of the vehicle user is attempting to schedule service with |
| brand | Query Param | ✓ | Brand of the user's vehicle |

#### HTTP Response

##### Status codes

| Status Code | Description |
| --- | --- |
| 200 | Composite service was able to return all required preload data and returned a valid response. |
| 202 | Composite service was able to return *at least one* piece of the preload data.  However client should check the errors and warnings props for more details. |
| 400 | Bad Request.  Invalid headers or query params.  A required header or query param might be missing or not following specification.

##### Body

```javascript
{
  "userProfile":  {
    "name": string,
    "address": {
      "streetNumber": string,
      "streetName": string,
      "city": string,
      "postalCode": string
    },
    "phone": string,
    "email": string
  },
  "dealer": {
    "name": string,
    "phone": string,  // service dept phone number
    "address": string,  // service dept address
    "latLng": LatLng model
  },
  "services": {
    "serviceList": [{ oas-service model }],
    "mobilityOptions": OAS Mobility options model [],
    "dealerFeatures": OAS Dealer Features model []
  },
  "errors": [],
  "warnings": []
}
```

##### Errors / Warnings

| Enum | Error/Warning | Description |
| USER_PROFILE_FAILURE | Warning | Call to fetch user's profile returned non-200 response. |
| USER_ACCOUNT_FAILURE | Error | Call to fetch user's email returned non-200 response. |
| DEALER_LOOKUP_FAILURE | Error | Call to Dealer Services API returned non-200 response. |
| OAS_SERVICES_FAILURE | Error | Call to OAS GET Service returned status code 500. |
| OAS_SERVICES_PRECONDITION_FAILURE | Error | Call to OAS GET Services returned status code 412.  Usually means internal dependency failed. |
| OAS_SERVICES_VENDOR_API_FAILURE | Error | Call to OAS GET Services returned status code 503.

[back to index](#oas-composite-index)

---

### Select Date and Time Page

<details>
  <summary>
    > Click here for designs
  </summary>
  <img src="https://atc.bmwgroup.net/confluence/download/attachments/605782467/1.3%20Date%20Time%20Selection%20-%20Service%20Booking_Native.png?version=7&modificationDate=1586261020212&api=v2"/>
</details>

<a name="oas-get-timeslots"></a>

#### HTTP Request

```
  GET /api/v1/oas-scheduling/timeslots
```

##### Headers & Query Params

| Param Name | Request Param | Required | Description |
| :--- | :---: | :---: | :--- |
| Authorization: {gcdmToken} | Header | ✓ | A valid gcdm token |
| x-usid: {usid} | Header | ✓ | Usid of the user associated with the gcdmm token |
| dealerId | Query Param | ✓ | Dealer Search Id of the dealership |
| vin | Query Param | ✓ | VIN of the vehicle user is attempting to schedule service with |
| brand | Query Param | ✓ | Brand of the user's vehicle |
| mobilityOptions | Query Param | ✓ | Comma separated list of mobility option ids returned from `Preload-data` request above. |
| start | Query Param | ✘ | Date timestamp of the moment user is requesting appointment times from the dealership |
| end | Query Param | ✘ | Date timestamp of the last moment user is requesting appointment times from the dealership.  Should be some point in time after the start date timestamp. |
| hasCustomerMessage | Query Param | ✘ | Boolean flag indicating if user has entered additional comments in the `additional-info` text area.  Some dealerships may allocate more time if a user has special requests and they factor this into their appointment availability. |

#### HTTP Response

##### Status Codes

| Status Code | Description |
| --- | --- |
| 202 | OAS has enqueued the timeslots request. |
| 200 | OAS has completed the timeslots request and returned a valid timeslot response. |
| 412 | OAS encountered an internal dependency failure when attempting to fetch timeslots. i.e. OMC/FG dependency failure |
| 503 | OAS encountered a vendor api (external) dependency failure when attempting to fetch timeslots. i.e. xTime api is down. |

##### Body

```javascript
{
  "timeslotOptions": [{
    "mobilityOption": string,
    "timeslots": [{
      "date": string,
      "times": [{
        "start": string,
        "end": string
      }]
    }]
  }],
  "errors": [],
  "warnings": []
}
```

##### Errors / Warnings

| Enum | Error/Warning | Description |
| OAS_TIMESLOTS_FAILURE | Error | Call to OAS GET Timeslots returned status code 500. |
| OAS_TIMESLOTS_PRECONDITION_FAILURE | Error | Call to OAS GET Timeslots returned status code 412.  Usually means internal dependency failed. |
| OAS_TIMESLOTS_VENDOR_API_FAILURE | Error | Call to OAS GET TIMESLOTS returned status code 503.

[back to index](#oas-composite-index)

---

### Review and Schedule Screen

<details>
  <summary>
    > Click here for designs
  </summary>
  <img src="https://atc.bmwgroup.net/confluence/download/attachments/605782467/1.5%20Review%20Book%20Information%20-%20Service%20Booking_Native.png?version=5&modificationDate=1586261039658&api=v2"/>
</details>

<a name="oas-submit-appointment"></a>

#### Submit Appointment HTTP Request

```
  POST /api/v1/oas-scheduling/appointment
```

##### Headers & Query Params

| Param Name | Request Param | Required | Description |
| :--- | :---: | :---: | :--- |
| Authorization: {gcdmToken} | Header | ✓ | A valid gcdm token |
| x-usid: {usid} | Header | ✓ | Usid of the user associated with the gcdmm token |
| dealerId | Query Param | ✓ | Dealer Search Id of the dealership |
| brand | Query Param | ✓ | Brand of the user's vehicle |

##### Request Body

```javascript
application/json
{
  "firstName": "string",
  "lastName": "string",
  "start": "2020-04-15T18:09:36.892Z",
  "email": "string",
  "phone": "string",
  "addressStreet": "string",
  "addressHouseNumber": "string",
  "cityName": "string",
  "postalCode": "string",
  "vin": "string",
  "licensePlateNumber": "string",
  "serviceKeys": [
    "string"
  ],
  "mobilityOptionId": "string",
  "message": "string",
  "locale": "string"
}
```

#### Submit Appointment HTTP Response

##### Status Codes

| Status Code | Description |
| --- | --- |
| 200 | OAS has completed the submit appointment request |
| 412 | OAS encountered an internal dependency failure when attempting to submit appointment. i.e. OMC/FG dependency failure |
| 503 | OAS encountered a vendor api (external) dependency failure when attempting to submit appointment. i.e. xTime api is down. |
| 500 | OAS encountered an unknown error while trying to submit appointment |

[back to index](#oas-composite-index)

---

### Appointment Details Screen

<details>
  <summary>
    > Click here for designs
  </summary>
  <img src="https://atc.bmwgroup.net/confluence/download/attachments/605782467/2.4%20Confirmation%20Page_Updated%20Dealer%20Preference%20-%20Service%20Booking_Native.png?version=3&modificationDate=1586260411024&api=v2"/>
</details>

<a name="oas-composite-cancel"></a>

#### Cancel Appointment HTTP Request

```
  DELETE /api/v1/oas-scheduling/appointment
```

##### Headers & Query Params

| Param Name | Request Param | Required | Description |
| :--- | :---: | :---: | :--- |
| Authorization: {gcdmToken} | Header | ✓ | A valid gcdm token |
| x-usid: {usid} | Header | ✓ | Usid of the user associated with the gcdmm token |
| dealerId | Query Param | ✓ | Dealer Search Id of the dealership |
| brand | Query Param | ✓ | Brand of the user's vehicle |
| appointmentId | Query Param | ✓ | Id of the appointment to cancel |

#### Cancel Appointment HTTP Response

##### Status Codes

| Status Code | Description |
| --- | --- |
| 200 | OAS has completed the cancel appointment request |
| 412 | OAS encountered an internal dependency failure when attempting to cancel appointment. i.e. OMC/FG dependency failure |
| 503 | OAS encountered a vendor api (external) dependency failure when attempting to cancel appointment. i.e. xTime api is down. |
| 500 | OAS encountered an unknown error while trying to cancel appointment |

<a name="oas-get-appointments"></a>

#### Get Appointments HTTP Request

```
  GET /api/v1/oas-scheduling/appointment
```

##### Headers & Query Params

| Param Name | Request Param | Required | Description |
| :--- | :---: | :---: | :--- |
| Authorization: {gcdmToken} | Header | ✓ | A valid gcdm token |
| x-usid: {usid} | Header | ✓ | Usid of the user associated with the gcdmm token |
| dealerId | Query Param | ✓ | Dealer Search Id of the dealership |
| brand | Query Param | ✓ | Brand of the user's vehicle |
| VIN | Query Param | ✓ | VIN of the user's active vehicle |

#### Get Appointments HTTP Response

##### Status Codes

| Status Code | Description |
| --- | --- |
| 200 | OAS has completed the get appointment request |
| 412 | OAS encountered an internal dependency failure when attempting to get appointment. i.e. OMC/FG dependency failure |
| 503 | OAS encountered a vendor api (external) dependency failure when attempting to get appointment. i.e. xTime api is down. |
| 500 | OAS encountered an unknown error while trying to get appointment |

[back to index](#oas-composite-index)

---

## Design Checklist

[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature. How does this affect the estimate. E.g. unknown or incomplete dependencies, preview software,etc.)

We will be working on this feature between two teams which will require a high level of coordination. Additionally, much of the work will coincide with the 7/20 downstream testing cycle which could cause delays for this 9/20 feature. Finally, this feature depends on a new week and month view calendar being added to Joy UI. Past experience implementing this component within the Angular Framework leads us to believe this will be a difficult widget to create and integrate with.

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact. Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

* OAS Composite Service
* Email Scheduling feature within Schedule Service feature module

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)

* Joy UI Calendar (Month and Week)
* Native Scheduling feature within Schedule Service feature module

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

None

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

None

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

[Privacy Assessment](https://atc.bmwgroup.net/jira/browse/NWAP-3574)

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint: This means are you thinking cloud first?)

Given that this is for the Flutter client, it will support Android and iOS.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally? What happens on the client if you have a broken or failed connection?)

As with our Mobile 1.0 implementation of native scheduling, the request to receive timeslots can take a long time, upwards of 30 seconds. To avoid timeouts, we will use the same polling technique employed with Mobile 1.0.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

No

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

No

**What dependencies does this feature rely upon?**

* Dealer Search API
* Vehicle Bloc
* OAS API (and 3rd Party Vendors)
* Schedule Service Launcher Feature Module
* Mobility Graph Motorist API
* GCDM Customer API

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected? What logs are generated?)

On the front end we will use unit testing, widget testing, and manual testing.

On the backend we will be able to reuse our existing monitoring on the OAS API to determine third party stability.

We will implement the necessary analytics to determine where user's are exiting the flow or having problems.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added? What criteria will trigger them?)

This feature will be deployed with the 9/20 Mobile 2.0 release. It will be toggled using dealer search. This flow is only accessible if a dealer has the `oas` booking engine in dealer search.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
