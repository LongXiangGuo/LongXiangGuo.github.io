---
layout: default
title: Roadside Assistance Client
parent: Aftersales
nav_order: 3
grand_parent: Architecture
---

[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)

*Template Version 0.0.1*

**Author(s):** [Brian Prusko](mailto:brian.prusko@partner.bmwgroup.com), [Henry Ni](mailto:henry.ni@partner.bmwgroup.com), [Sadriddin Norkobilov](mailto:sadriddin.norkobilov@partner.bmwgroup.com)

**Feature Link:** [Scaffolding for RSA Mobile 2](https://atc.bmwgroup.net/jira/browse/NWAP-2560)

**Wires:** [https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=540989968](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=540989968)

**T-shirt Size Estimate:** *L*

[comment]: <> (Note: This template must be filled out completely with all sections answered.  The pre-grooming task will not be accepted as done without the proper sign off.  No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle.   The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

## System Level Overview
[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)


- Roadside Assistance is not available in every market, and each market has a different configuration, which can change over time.
- Roadside Assistance has two entry points (Vehicle tab and Profile tab).
- Roadside Assistance has 3 possible service levels:
  - **Level 1:** allows customers to make phone call
  - **Level 2:** allows customers to make phone call and opt in to sharing location and Vehicle data.  We are not responsible for gathering or sending the Vehicle data.  We simply pass a boolean that tells BMW's call center (CCC) whether they can pull Vehicle data.
  - **Level 3 (Available beginning with app version 1.1.0 (9/20 release)):** allows for functionality of Level 2 + service vehicle tracking. Consistent with the Mobile 1 experience, when the customer is on the tracking page, we poll the RSA Composite Service every 5 seconds for updated tracking information. If the customer is on the tracking page and puts the app in the background or otherwiser navigates away from the tracking page, we stop polling.

---

##### Overall Flow

- A combination of vehicle brand and market determine the market configuration, and we'll obtain market from the user profile.
- The market configuration determines which level of roadside assistance is available to the customer.
- We need a VIN in to create cases with CCC and third-party vendors.

<div style="max-width:75%;height:75%">
  <img src="../../../../assets/images/architecture/aftersales/roadsideAssistance/client/rsa-general-flow.png">
</div>

&nbsp;
&nbsp;

##### Level 1
<div style="max-width:75%;height:75%;">
  <img src="../../../../assets/images/architecture/aftersales/roadsideAssistance/client/rsa-level-one.png">
</div>

&nbsp;
&nbsp;

##### Level 2
<div>
  <img src="../../../../assets/images/architecture/aftersales/roadsideAssistance/client/rsa-level-two.png">
</div>

&nbsp;
&nbsp;

##### Level 3
<div>
  <img src="../../../../assets/images/architecture/aftersales/roadsideAssistance/client/rsa-level-three.png">
</div>

## Code Level Details
[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

##### New components:

- Roadside Assistance feature module
- Roadside Assistance repository


## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)

None

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

None

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)

- Roadside Assistance feature module
- Roadside Assistance repository

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

[comment]: <> (Hint:  This means are you thinking cloud first?)

Given that this is for the Flutter client, it will support Android and iOS.

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

Device Repository in Platform SDK

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)

Unit tests and widget tests. Composite service logs will be collected in Kibana, and we will set up alerting and monitoring in Grafana. Additionally, we have all the existing monitoring for the RSA API.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)

No feature toggles will be added.  Roadside Assistance will be displayed conditionally based on market configurations returned by our composite service.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
