---
layout: default
title: Dealer Services Composite Service
parent: Aftersales
nav_order: 8
grand_parent: Architecture
---

_Template Version 0.0.1_

**Author(s):** [99 Luftballons](mailto:99_Luftballons_Scrum_Team@list.bmw.com)  
**Feature Link:** [Dealer Services](https://atc.bmwgroup.net/jira/browse/NWAP-2726)  
**Wires:** [PSP](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=634079546) [Dealer Search](https://atc.bmwgroup.net/confluence/display/NWAP/1.8.2+Dealer+Search+-+Current)
**T-shirt Size Estimate:** _S_

## System Level Overview

This composite service is simply proxying requests to the existing `dealer search service` being used primarily in Mobile 1.0.

[Here](https://suus0001.w10:8090/display/KB/Dealer+Search+Services+Composite+Service) is a swagger implementation
&nbsp;

---

##### Sequence diagram for "GET /v1/{vin}/psp":

<div class="mermaid">
sequenceDiagram
client->>DSCS: GET /v1/{VIN}/psp
DSCS->>Dealer Search backend: GET /v2/vehicles/{vin}/servicepartner
Dealer Search backend-->>DSCS
DSCS->>client: psp for VIN
</div>

&nbsp;

---

##### Sequence diagram for "POST /v1/{vin}/psp":

<div class="mermaid">
sequenceDiagram
    client->>DSCS: POST /v1/{VIN}/psp
    DSCS->>Dealer Search backend: POST /v1/vehicles/{vin}/servicepartner
    Dealer Search backend-->>DSCS
    DSCS->>client: status of PSP creation
</div>

## Code Level Details

##### New components:

The `dealer-services-composite-service` is a .NET composite service used to proxy requests to `Dealer Search Service` and normalize data.

##### How we get USID:

All requests to the composite service are routed through API gateway under the `connected` route. This route adds the `x-usid` header, containing current user's USID, is added to every request following that route.

## Design Checklist

**What risks does the team need to be concerned with before taking on this feature**

None

**What existing components are modified by this design?**

None

**What new components are created by this design?**

A new composite service: `dealer-services-composite-service`

**Are any new technologies/frameworks being used?**

No

**What security issues does this design introduce and how are they resolved?**

No new issues

**What privacy issues does this design introduce and how are they resolved?**

No new issues

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

Yes, this feature will be utilized by Mobile 2.0 which covers all required mobile platforms

**What performance issues may affect this feature and how are they resolved?**

No new issues

**Will this feature add additional cloud hosting costs?**

Yes, we will need to deploy `dealer-services-composite-service` into the service mesh.

**Will this service generate additional load/requests on any external dependent services?**

No

**What dependencies does this feature rely upon?**

None

**How will this feature be tested, monitored, and evaluated?**

We will leverage the Mobile 2.0 toolchain for testing.

**How will this feature be deployed?**

No feature toggles planned for this feature.

**Does this feature have regional implications?**

No

**Has any new IP been generated from this design?**

No
