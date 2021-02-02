---
layout: default
title: Recall Notifications
parent: Aftersales
nav_order: 2
grand_parent: Architecture
---

# Recall Notifications

[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)

*Template Version 0.0.1*

**Author(s):** *Brian Prusko*, *Henry Ni*, *Sadriddin Norkobilov*

**Feature team contact:** Kraftwerk_Scrum_Team@list.bmw.com

**Feature team location:** Chicago

**Feature link:** *https://suus0002.w10:8080/browse/BMWO-166988*

**Wires:** *https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=547066791*

**T-shirt Size Estimate:** *S*

[comment]: <> (Note: This template must be filled out completely with all sections answered.  The pre-grooming task will not be accepted as done without the proper sign off.  No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle.   The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

<img src="../../../../assets/images/architecture/aftersales/recall/recallNotifications.png">

## System Level Overview
[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

Recall notifications appear with Service Alerts on the Services tab in Vehicle Status.

The data for Vehicle Status comes from the Vehicle Composite Service (VCS).  To get the vehicle list, the VCS uses the **bmw-lit/vehicle** NPM package, but recall notifications are not part of the [LIT Vehicle model]( https://code.connected.bmw/library/bmw-lit-npm/blob/master/packages/vehicle/lib/models/lit-vehicle.model.ts#L39){:target="_blank"}, so we created an [NPM package](https://code.connected.bmw/library/bmw-npm/tree/master/packages/recall-api) that exposes a client to retrieve recalls.  The recall NPM package calls the same .NET Core [recall API](https://code.connected.bmw/after-sales/recall-services){:target="_blank"} as Mobile 1.

### Refreshing Recall Data

Recall notifications refresh with the rest of the vehicle data.  Currently, this data automatically refreshes every 3 minutes or immediately via pull-to-refresh.

### Push Notifications

For the July 2020 target delivery, we will send push notifications, but push notifications will not deep link anywhere in the app.

## Code Level Details
[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

### Vehicle Status

Vehicle Status has 3 tabs, and each tab has its own widget.  We added a **Recall List** widget to the [Services Tab Widget](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/pages/vehicle_status_page/tabs/services_tab_widget.dart){:target="_blank"}, and it accepts a list of recall notifications.

**[Recall Status Item Model](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/models/recall_status_item_model.dart){:target="_blank"}**

```
 {
    "brand": "string", // BMW or MINI
    "callDealerEnabled": bool, // Display Call Dealer button?
    "hotlineNumber": "string", // Dedicated customer service number for the recall campaign
    "description": "string",
    "market":"string",
    "openRecallWebsiteEnabled": bool, // Add market-specific recall website to text?
    "scheduleAppointmentEnabled": bool, // Display Schedule Appointment button?
    "subtitle": "string",
    "version":"string",
    "vin": "string",
  }
```

<br/>

**Details Page Widget**

The recall notifications detail screen is similar to the detail screens for Service Alerts and Check Control Messages, but recall notifications have a [separate template](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/pages/recall_details_page_widget.dart){:target="_blank"}, because:
- Market representatives can determine which call-to-action buttons to display when they send a recall notification.
- Recall notifications include an optional customer service number in the text that the customer can click to launch a phone call.

***Call To Action Buttons***

For NA and RoW, these buttons are toggled from the Recall API. For Korea, these buttons will be hidden directly in the client code until Dealer Search and Online Appointment Scheduling can support Korea.

_Schedule Appointment Button_

The details screens consumes the Schedule Service Launcher from the Online Appointment Scheduling teams in Chicago (Apollo and Lambda). The widget pulls the VIN from the Vehicle Bloc, but we will need to pass Dealer ID. For the 7/20 release, Preferred Dealer will not be available, so this button will route to Dealer Search.

_Call Dealer Button_

For the 7/20 release, Preferred Dealer will not be available, so this button will route to Dealer Search.

## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)

None

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

- **Recall Services (.NET)**
  - Created endpoint without a feature toggle to get recalls for a list of VINs.
  - Added support for [Mobile 2 user agents](https://code.connected.bmw/core-services/agent-service/blob/develop/AgentService/Models/AgentPlatform.cs){:target="_blank"} for push notifications
- **Vehicle Composite Service**
  - Return recalls for the list of vehicles returned by [**getVehicles** in Vehicle Service](https://code.connected.bmw/mobile20/vehicle-composite-service/blob/master/src/api/v1/vehicles/services/vehicle.service.ts){:target="_blank"}.
  - Added recalls to [Vehicle Status Issues](https://code.connected.bmw/mobile20/vehicle-composite-service/blob/master/src/api/v1/vehicles/models/vehicle-status-issues.model.ts) and [Vehicle Status](https://code.connected.bmw/mobile20/vehicle-composite-service/blob/master/src/api/v1/vehicles/models/vehicle-status.model.ts){:target="_blank"}.
- **Mobile Connected**
  - **Platform SDK**
    - **Vehicle Repository**
        - Added property for recalls to [Vehicle Status](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/repositories/vehicle_repository/lib/src/api/vehicle/models/status/vehicle_status.dart){:target="_blank"} model.
        - Added property for recalls to [Status Issues](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/repositories/vehicle_repository/lib/src/api/vehicle/models/status/status_issues.dart){:target="_blank"} model.
  - **Vehicle Status In Vehicle module**
    - Created Recall Status Item Model
    - Created Recall Details and Recall List widgets
    - Updated [Status Issue Model](https://code.connected.bmw/mobile20/mobile-connected/blob/master/feature_modules/vehicle/lib/src/features/vehicle_status/models/status_issues_model.dart){:target="_blank"} to include recalls.

**What new components are created by this design?**

NPM package for a client the Vehicle Composite Service can use to get recall notifications

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

No, we will be following the established tech stack for Mobile 2.0.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

No new issues

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

None

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)

This feature is for Mobile 2.0, which is built in Flutter, so it will cover iOS and Android clients.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)

No new issues

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

None

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

Possible increased load for the existing Recall .NET backend, because we will need to support Mobile 1 and Mobile 2.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

None

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)

We will leverage Mobile 2.0 toolchain for testing.  Test scenarios for recall will also be included in the Aftersales automated test suite, which leverages flutter_driver.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)

No feature toggles planned for this feature in Mobile 2.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
