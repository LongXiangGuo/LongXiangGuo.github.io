---
layout: default
title: Email Scheduling Service
parent: Aftersales
nav_order: 6
grand_parent: Architecture

---

# Email Scheduling Service

[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)

*Template Version 0.0.1* 

**Author(s):** [Alex Kenney](mailto:alexander.kenney@bmwna.com)

**Feature Link:** [NWAP-1622: Email Scheduling Service](https://atc.bmwgroup.net/jira/browse/NWAP-1622)

**T-shirt Size Estimate:** *L*

[comment]: <> (Note: This template must be filled out completely with all sections answered.  The pre-grooming task will not be accepted as done without the proper sign off.  No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle.   The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

<img src="{{site.baseurl}}/assets/images/architecture/aftersales/email_scheduling/email_scheduling_service_ui_ux.png"/>
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/email_scheduling/email_scheduling_service_ui_ux.png)

## System Level Overview
[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

Email Booking is one of the booking engines supported by BMW and MINI dealers along with Native OAS (in-app appointment scheduling), Third Party (link out to external web pages), XTime (specific third party link out), and Call Dealer (provide a phone number for the user to call). The logic used to open any of these booking engine routes is being worked on in feature [NWAP-1621](https://atc.bmwgroup.net/jira/browse/NWAP-1621).

The Email Booking feature is a two page form that collects basic user information, up to three preferred dates and times, and relevant service required/requested and sends this information to the dealership via email. The dealer can then follow up with the user and confirm an appointment outside of the mobile client.

The initial implementation of this feature will be a 1:1 feature port from the Mobile 1 client. On the first page of the form we will collect a user's full name, preferred contact method and email address or phone number, and a description of the service a user is requesting be performed. When possible we will attempt to prepopulate the user's information stored in their connected profile on the form.

The second page provides the user with three picker inputs that supply a list of dates and times (time represented as morning, afternoon, and evening). It does not take into account any dealership availability. At least one date and time must be selected before the user can click submit and send the email.

An email is sent via our composite service to the Email Service in the OMC and upon success the user is then navigated to a confirmation page detailing the information sent to the dealership.

A detailed system wide overview of the feature can be found below.

<img src="{{site.baseurl}}/assets/images/architecture/aftersales/email_scheduling/email_scheduling_diagram.png">
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/email_scheduling/email_scheduling_diagram.png)

## Code Level Details
[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

We will be adding a feature module for email scheduling while NWAP-1621 is in progress. Once complete, we will migrate our feature module into the OAS module.

We will be adding methods to the OAS Repository, OAS Client, and creating two new endpoints in the OAS Composite Service (see below).

### OAS Composite Service Update

### GET /api/v1/email-scheduling/user-profile
##### Summary:
Preload User Information

##### Parameters

| Name | Located in | Description | Schema |
| ---- | ---------- | ----------- | ---- |
| x-usid | header |  | string |
| authorization | header |  | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Success | [EmailUserProfile](#email-user-profile) |
| 400 | Bad Request |  |
| 500 | Internal Server Error |  |


### POST /api/v1/email-scheduling/send-email

##### Summary:

Send an email to request an appointment

##### Parameters

| Name | Located in | Description | Schema |
| ---- | ---------- | ----------- | ---- |
| appointment | body | The user to create. | [Appointment](#appointment) |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Success |
| 400 | Bad Request |
| 404 | Not Found |
| 500 | Internal Server Error |

###### Email User Profile
```javascript
{
  "fullName": "string",
  "phoneNumber": "string",
  "emailAddress": "string"
}
```
###### Appointment
```javascript
{
  "dealer": {
    "id": "string",
    "name": "string",
    "emailAddress": [
      "string"
    ]
  },
  "customer": {
    "fullName": "string",
    "phoneNumber": "string",
    "email": "string"
  },
  "serviceRequest": {
    "additionalInfo": "string",
    "dueServices": [
      {
        "cbsDescription": "string",
        "dateDue": "string",
        "mileageDue": "string"
      }
    ],
    "requestedTimes": [
      "string"
    ]
  },
  "vehicle": {
    "vin": "string",
    "mileage": "string"
  }
}
```
## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature** 

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)
* Coordinating with Apollo on the base OAS feature
* Coordinating with other teams to add/update JOY-UI components

**What existing components are modified by this design?**  

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)
* OAS Repository and Client
* OAS Composite Service

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)
Email Scheduling Feature Module

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)
None

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)
None

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)
[Privacy Questionnaire](https://atc.bmwgroup.net/jira/browse/NWAP-3582)

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)
This will be part of Mobile 2.0 (Android and iOS)

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)
No new issues

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)
No

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)
No

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)
* Email Service (btcmessagingservice) in OMC
* OAS Composite Service
* Mobility Graph Motorist API
* VehicleBloc in Platform SDK
* Dealer Search API

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)
Unit, widget, and manual testing. Analytics TBD

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)
No feature toggles. Email Booking is a booking engine that dealers can opt into supporting on an individual basis.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])
No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)
No
