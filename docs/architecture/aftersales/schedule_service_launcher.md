---
layout: default
title: Schedule Service Launcher
parent: Aftersales
grand_parent: Architecture
nav_order: 5
---

# Schedule Service Launcher

<img src="{{site.baseurl}}/assets/images/architecture/aftersales/schedule_service/schedule_service_ui_ux.png"/>
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/schedule_service/schedule_service_ui_ux.png)

## Feature Overview

[comment]: <> (This section should describe the overall system design of the feature. It should identify the various components that make up the solution [microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here. Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

The ScheduleServiceLauncher feature module will serve as an entry point for a user wishing to schedule service for their active vehicle and at a particular BMW service location. This product is referred to as Online Appointment Service (OAS).
Online appointment service is available in nearly all BMW markets via different booking engines. We offer this functionality through the following booking engines:

| Booking Engine                   | Description                                                                                                                                                                                                                                                                                                                                                                    |
| :------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| OAS (Online Appointment Service) | Book an appointment with a dealership using any one of our api integrated vendors. This is by far the most seamless and optimal experience for our users. Users can schedule an appointment with a dealership without having to ever leave the Connected App. Our backend provides a seamless integration layer with the dealer managment system (DMS) used by the dealership. |
| Thirdparty                       | Some dealers maybe using DMS vendors not (yet) integrated with our backend but do have an online web app where their customers may schedule an appointment with said dealership. Here we're linking our users out to a web app through their native web browser to continue with scheduling their appointment.                                                                 |
|                                  | **xTime SSO** is a special case for dealers in the US market. Here users are linked out to their browser with a special URL generated from our backend which allows passing along masked user data using a SSO token.                                                                                                                                                          |
| Email                            | Allows booking an appointment with a dealership via the Connected App but behind the scenes we're simply sending an email to the dealership.                                                                                                                                                                                                                                   |
| Call                             | (No booking engine essentially) Here we handle any dealerships where we can't determine which booking engine to use. We allow the user to simply call the dealership.                                                                                                                                                                                                          |

The logic for determining booking engines already exists in the Dealer Search backend. We will be building a composite service which will be responsible for calling Dealer Search and depending on the booking engine, either fetch additional information or respond with enough information for the client to use the booking engine.

---

## Feature Module

ScheduleService feature module will be the entrypoint for all schedule service entry points in the UI. Any entrypoint wishing to allow the user schedule service with a dealer MUST use this feature module. The required input params to be passed into the entry point of ScheduleService feature module is:

| Param                           |           Data Type           | Description                                                          |
| ------------------------------- | :---------------------------: | -------------------------------------------------------------------- |
| dealerId\*                      |            string             | ID of the dealer the user wants to book services with                |
| scheduleServiceEntrypointType\* | ScheduleServiceEntrypointType | The type of widget to render, options are available in an enum enum  |
| scheduleServiceLabel            |            string             | An optional override for the string displayed for "Schedule Service" |
| viewAppointmentLabel            |            string             | An optional override for the string displayed for "View Appointment" |

Additionally, it is required that the entrypoint widget is provided a `JoyThemeBloc`, which is used to retrieve the Brand, and a `VehicleBloc`, which is used to retrieve the active VIN.

---

## Entry Points

Entry points into this feature module will exist on the Vehicle tab, Dealer Destination tabs, and Service details feature module. Each of the modules will be able to use the Schedule Service module by instantiating the entrypoint widget using PlatformSDK findModule. For ex:

```dart
  return PlatformSdk.findModule(
    ModuleEntryInfo(
      routeName: '/schedule_service',
      arguments: {
        dealerId: 'dealer-id',
        scheduleServiceEntrypointType: ScheduleServiceEntrypointType.button
      },
    ),
  );
```

This would return a widget with an initial/empty state and adds a new event `ScheduleServiceEntrypointFetched` to our schedule service bloc. From there, a child widget would render the correct view based on the `scheduleServiceEntrypointType` and handle any callbacks or events when the entrypoint widget is pressed.

---

## OAS Composite Service System Flow

OASC Repository is a data provider for the OAS composite service. Using `dealerId, VIN, brand, & clientVersion` the composite service will be able to retrieve the correct booking engine and any additional info that maybe required.

<div class="mermaid">
  sequenceDiagram
      OASC_Repository->>OASC: What is the booking engine for dealerId: X
      OASC->>Dealer_Search: Give me dealer information for dealerId: X
      Dealer_Search-->>OASC: Here it is, dealer x
      OASC->>OAS: Does VIN: Y and dealerId: X have already booked appointments
      Note over OASC,OAS: Only if booking engine is 'OAS'
      OAS-->>OASC: Yes, here are the appts OR No, empty array
      OASC-->>OASC_Repository: Here's the booking engine and any additional data required
</div>
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/schedule_service/sequence-diagram.png)

#### GET /booking-engine responses

For the scope of this feature we only need to implement the GET booking engine endpoint.

```
GET /api/v1/dealers/{dealerId}/booking-engine?&vin={vin}&brand={brand}&client-version={clientVersion}
```

This endpoint is responsible for returning a booking engine for a particular dealer and any required information to use that booking engine such as a `URL` if booking engine was `Thirdparty` for example.

##### Booking Engine Response model

```
{
type: 'oas' | 'email' | 'thirdParty' | 'call'
phone: string | null,
email: string | null,
url: string | null,
appointments: OASAppts[] | null
}
```

> Note: Until we add support for OAS Flow in Connected X client, we're going to default OAS dealers to Call dealer booking engine.  This means in Connected X for 07/20 launch users will only be able to book with an OAS dealer by calling the dealership.  This will not affect Connected App client.

---

## System Overview

### System Flow

**Note: The names in this chart are representative of what the responsibility of each component is, however the naming might not exactly match what is in the current codebase.**

<script>
mermaid.flowchartConfig = {
    width: 50%
}
</script>
<div class="mermaid">
  graph TD
    ParentWidget[Parent Widget] -- dealerId, scheduleServiceEntrypointType --> Schedule_Service_EntryPoint
    Schedule_Service_EntryPoint-- Fetched -->Schedule_Service_Bloc[Entry Point Bloc]
    Schedule_Service_Manager-- Pressed -->Schedule_Service_Bloc
    Schedule_Service_Bloc-- GET Booking-Engine -->OASC
    Schedule_Service_EntryPoint[Entry Point]-- scheduleServiceEntrypointType -->Schedule_Service_Manager[Manager]
    Schedule_Service_Bloc-- State --> Schedule_Service_Manager 
    Schedule_Service_Manager-.->LaunchUrl(Launch Phone or URL)
    subgraph Bloc Listener
    LaunchUrl---ShowError
    ShowError(Show Error Snackbar)---ShowModal
    ShowModal("(Future) Show Modal")---Redirect
    Redirect("(Future) Redirect")
    end
    Schedule_Service_Manager-- onPressed -->Schedule_Service_Primary_Button
    Schedule_Service_Manager-- onPressed -->Schedule_Service_Tile
    Schedule_Service_Manager-- onPressed -->Schedule_Service_List_Item
    Schedule_Service_Primary_Button[Button] --> JoyButton
    Schedule_Service_Tile[Tile] --> JoyButtonTile
    Schedule_Service_List_Item[List Item]--> JoyListItem

</div>
[Expand Image]({{site.baseurl}}/assets/images/architecture/aftersales/schedule_service/high-level-overview.png)

### New components

- OAS Composite Service (OASC)
- OASC Repository
- ServiceService Feature Module

### Code Level Details

[comment]: <> (This section should highlight any design details at the code level. E.g. Any design patterns that should be used. Changes to existing designs. Details about data models and types.)

Description of all the components described in the above System Flow diagram.

| Component           | Role                                                                                                                                                                                                                                                                                                                   |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Parent Widget       | This represents whatever widget is using the schedule service entrypoint. It is necessary for this widget to be provided a `JoyThemeBloc` and a `VehicleBloc`.                                                                                                                                                         |
| Entry Point         | The entry point widget initializes the schedule service entrypoint bloc and fires the initial fetch event.                                                                                                                                                                                                             |
| Entry Point Bloc    | The entry point bloc reacts to two events: Fetched (which is called when initially loading the entry point) and Pressed (which is fired when the entrypoint is pressed). The bloc returns the appropriate state to the widgets based on the API call to the OAS repository and the booking engine type for the dealer. |
| OASC Respository    | Repository in the `Platform-SDK` to retrieve the booking engine details from OASC. This will allow the ScheduleServiceBloc to know which booking engine handler to invoke to get the `onPress` callbacks and `label` of the button to be built.                                                                        |
| Manager             | The manager widget has a bloc listener that performs the correct action (launching a URL, navigation, etc.) based on the state returned by the bloc. It also renders the appropriate sub widget based on the `scheduleServiceEntrypointType` parameter.                                                                |
| Launch Phone or URL | The manager launches a third party URL or the phone application for calling a dealer                                                                                                                                                                                                                                   |
| Show Error Snackbar | The manager shows the error message snackbar whenever an entry point in a failed state is pressed                                                                                                                                                                                                                      |
| Redirect            | **_Future Implementation_** The manager navigates the user to another screen based on the booking engine type                                                                                                                                                                                                          |
| Show Modal          | **_Future Implementation_** The manager shows a confirmation modal                                                                                                                                                                                                                                                     |
| Button              | Widget which renders a button styled to match [this](https://atc.bmwgroup.net/jira/secure/attachment/1344803/image-2020-02-26-15-11-49-610.png), JOY Button                                                                                                                                                            |
| Tile                | Widget which renders a button styled to match [this](https://atc.bmwgroup.net/jira/secure/attachment/1344801/image-2020-02-26-14-56-11-141.png), JOY Button Tile                                                                                                                                                       |
| List Item           | Widget which renders a button styled to match [this](https://atc.bmwgroup.net/jira/secure/attachment/1344716/1344716_image-2020-02-26-15-28-06-769.png), JOY List Item                                                                                                                                                 |

---

## Design Checklist

[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature. How does this affect the estimate. E.g. unknown or incomplete dependencies, preview software,etc.)

Coordinating with the teams that own the various JOY UI component's we're relying on.

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact. Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

- Our composite service will be handling all changes required for the Mobile 2.0 client. Therefore there should be no changes to any external dependencies.

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)

- Schedule Service feature module
- OAS repository
- OAS composite service

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

No, we will be using the existing tech stack.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

No new issues

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

No new issues

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint: This means are you thinking cloud first?)

Given that this is for the Flutter client, it will support Android and iOS.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally? What happens on the client if you have a broken or failed connection?)

No new issues

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

No new costs. We'll be leveraging the service mesh for our composite service.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

No significant load increase.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

Possibly the composite services for the OAS backend

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected? What logs are generated?)

Unit test and widget tests

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added? What criteria will trigger them?)

No feature toggles will be added. Schedule Service will be displayed conditionally based on market configurations returned by our composite service.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
