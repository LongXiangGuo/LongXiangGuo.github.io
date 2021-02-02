---
layout: default
title: Roadside Assistance Composite Service
parent: Aftersales
nav_order: 4
grand_parent: Architecture
---
[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)

*Template Version 0.0.1* 

**Author(s):** [Egor Zmeev](mailto:egor.zmeev@bmwna.com)   
**Feature Link:** [RSA Mobile 2.0](https://suus0002.w10:8080/browse/BMWO-164507)  
**T-shirt Size Estimate:** *L* 

[comment]: <> (Note: This template must be filled out completely with all sections answered.  The pre-grooming task will not be accepted as done without the proper sign off.  No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle.   The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

## System Level Overview
[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

&nbsp;

##### OpenAPI 3.0 spec of Roadside Assistance composite service: [ATC confluence](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=540989968#id-1.10RoadsideAssistance[Current]-BackEnd)

&nbsp;

---
##### Get active inquiries for a vehicle ("GET /inquiry/active?vin={vin}")

<div class="mermaid">
sequenceDiagram
    client->>RSA composite: GET /inquiry/active?vin={vin}
    RSA composite->>RSA backend: /api/v1/inquiries?vin={vin}
    RSA backend-->>RSA composite: inquiries for VIN
    RSA composite->>client: active inquiry for VIN
</div>

&nbsp;
&nbsp;

---
##### Get market configuration ("GET /capabilities/{brand}")

<div class="mermaid">
sequenceDiagram
    client->>RSA composite: GET /capabilities/{brand}
    RSA composite->>User Profile Service: /v2/user/{usid}/profile
    User Profile Service-->>RSA composite: home market
    RSA composite->>RSA backend: /api/v3/assistance/{brand}/{countryCode}
    RSA backend-->>RSA composite: phone number + level of RSA assistance for market
    RSA composite->>client: market configuration
</div>

&nbsp;
&nbsp;

---
##### Create inquiry ("POST /inquiry")
<div class="mermaid">
sequenceDiagram
    client->>RSA composite: POST /inquiry
    RSA composite->>RSA backend: /api/v1/inquiries
    RSA backend-->>RSA composite: inquiry DTO with id
    RSA composite->>client: inquiry DTO with id
</div>

&nbsp;
&nbsp;

---
##### Get Inquiry by Inquiry ID ("GET /inquiry/{id}")

<div class="mermaid">
sequenceDiagram
    client->>RSA composite: GET /inquiry/{id}
    RSA composite->>RSA backend: /inquiry/{id}
    RSA backend-->>RSA composite: inquiry w/ tracking data if available
    RSA composite->>Commute API: /api/route
    Commute API-->>RSA composite: route for service vehicle
    RSA composite->>client: inquiry w/ tracking data if available
</div>

&nbsp;
&nbsp;

---

##### Customer workflow tied to API calls:
<div style="max-width:75%;height:75%;margin-left:75px">
    <img src="../../../../assets/images/architecture/aftersales/roadsideAssistance/composite/rsa-customer-flow.png">
</div>

&nbsp;
&nbsp;

---

## Code Level Details
[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

##### New components:

Following the concepts established by Mobile 2.0 project, we will create the following new components:
- *roadside-assistance-composite-service*: NestJS based application which is supposed to provide a facade for Roadside
Assistance and User Profile APIs. 
- *roadside-assistance-api-client*: separate NPM package for communication with Roadside Assistance API.
- *roadside_assistance* feature module: Flutter feature module which will contain RSA activities and expose multiple entry points. Entry point may be thought of as a widget which consists of a button and BLoC which is responsible for determining RSA enablement in given context (user, vin, market).

##### How we can get USID: 
All requests to the composite service are supposed to be routed through API gateway under "connected" route. It's important
to notice that the configuration for "connected" route on API gateway is such that "x-usid" header (containing current user USID) is added to every request following that route. Due to the fact that "x-usid" header added to request by API gateway,
on composite service side we can always expect to have "x-usid" header and use it to get USID of a user associated with request.

## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature** 

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)

None

**What existing components are modified by this design?**  

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

None, we will be creating new components which will utilize existing APIs 

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)
Two new components:
- *roadside-assistance-composite-service*
- *roadside-assistance-api-client*

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

No, we will be following established tech stack for the Mobile 2.0 project.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

No new issues

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

No new issues

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)

Components proposed in this design are supposed to be utilized by Mobile 2.0 project which covers all required mobile platforms

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)

No new issues

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

Yes, we will need to deploy *roadside-assistance-composite-service* into the service mesh.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

No, the number of requests to external services is supposed to stay the same.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

Commute API to generate the service vehicle route.

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)

We will leverage the Mobile 2.0 toolchain for testing.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)

No feature toggles planned for this feature

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
