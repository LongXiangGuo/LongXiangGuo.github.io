---
layout: default
title: Eadrax Last Mile Architecture
parent: Journey Management
grand_parent: Architecture
nav_order: 1
---

## Last Mile Architecture

**Author(s):** Andreas Jauch & CTW Team Odyssey
**Feature Link:** <https://atc.bmwgroup.net/jira/browse/NWAP-274>
**T-shirt Size Estimate:** L

## System Level Overview

This is the architecture proposal for the Last Mile feature. The Last Mile feature was implemented in Mobile 1.0 in a limited fashion, due to the fact that it required a local connection to the car through A4A connection.

The goal is to provide a way for users to be guided to their final destination with walking path guidance after they park their vehicle, be it in our app or with an external map provider.

For this implementation, we'll have 4 big dependencies:

* Connected OAP app in the vehicle
* Onboard Navigation Sync Service
* Mobile 2.0 App
* Agent Service

Out of these dependencies, only the first 3 need to be changed in order to implement this feature.

### Current Architecture

There is no current architecture in place for the Last Mile feature on MGU head units.
On Mobile 1.0 there is a Last Mile feature that relies on the car's A4A connection to notify the user if it wants to proceed with the last mile navigation.

### Proposed Architecture Changes

<img src="{{site.baseurl}}/assets/images/architecture/mobile2_last_mile_proposed_arch.png">

The picture above shows the change proposals for all impacted serviçes. They are highlighted in green.
These should be compatible with the services currently using both the ONSS (Onboard Navigation Sync Service) and the Connected OAP.

The changes are the following:

1. Add the required functionality to the Connected OAP app to handle the last mile implementation.
    * The work needed to implement here relates to the logic behind contacting the ONSS when the conditions for Last Mile trigger apply.
    * The base condition for the last mile trigger to happen is that the PWF state on the car, changed from F to W;
    * The OAP would send this PWF change event, the current location and the guidance destination/state to the ONSS.
    * Finally, the OAP app will need to know when the ONSS sends a notification to the users phone, to then show a message on the vehicles Good Bye Screen, informing the user it will receive a notification for the last mile on his phone.*These translations can be implemented using OAP's translation mechanism.*
        * Note: the PWF state is a state machine in the car about how the car is used.
            * P: Everything is off, car locked. *This means we also can't show a notification in the car any more.*
            * W: Engine off, car unlocked, Head unit active. *This is the state where we should show the notification in the car and on the phone.*
            * F: Engine running.

1. For this feature, we also need to implement new endpoints on the ONSS so that the user can receive a last mile notification on the phone.
    * The work required for this service revolves around implementing the business logic related to when we should send this notification to the user's phone. These rules are for example if the car inside the Last Mile activation range or not.
    * We'll also need to implement the correct calls to the agent service in order to get the user agents needed to push a notification.
    * The ONSS will also need to handle the correct translations for the phone notifications and to do that we need the user language (which we can get from the agent service) and finally implement the translations file.

[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

## Code Level Details

[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)
As referenced before, the Onboard Navigation Sync Service will need to handle the notification translations for all the markets the mobile 2.0 app will be available to.
This will be done by leveraging the StringLocalizer feature from .NET Core in order to simplify the development of this feature.

The rest of the implementation should only rely on normal REST serviçes. So there shouldn't be any special design patterns or changes to existing serviçes outside of the ONSS and the OAP app.

Regarding the models being used, the ONSS will need with the agent serviçe and in order to do that we need to build up the models for communication.

As for the OAP app, a small investigation work will need to be done prior to implementation, in order to know what behavior the car has when it reaches a destination and how to listen to the necessary triggers from the car to make this feature work.

Having feature toggle for this feature is necessary.

## Design Checklist

[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature** 

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)
Since we're working with the OAP app, performance and load on the car might be an associated risk with the implementation of this feature.
The Mobile 2.0 app, at the time of writing, doesn't have a defined architecture for handling push notifications and that might impact the work being done.

**What existing components are modified by this design?**  

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

* Connected OAP
* Onboard Navigation Sync Service

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)
None.

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)
None.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)
None compared to existing calls to the existing services.

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)
We need to take care when handling the user location data and the destination information.
Some information should be used for analytics and improvement proposes, such as distance to destination on car park, but extra care will need to be given to this.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)
Mobile 1.0 client should not be impacted by this change and it won't need any update.

Mobile 2.0 client will need to have the last mile feature implemented. This is, the support for the last mile push notification and give a choice to the user if he wants to proceed with the walking path guidance, dismiss the notification or resume car guidance.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)
The OAP app will need to do extra calls to back end services and interact additional car systems.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)
The load on the Onboard Navigation Sync Service will increase, so a certain additional cost might happen.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)
None.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)
The major dependencies are:

* Connected OAP app in the vehicle
* Onboard Navigation Sync Service
* Mobile 2.0 App
* Agent Service

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)
The services and app's that will need to be changed to accommodate this feature already have logging and feature testing in place for their respective implementations. So any extra work will continue to use the same analytics and logging strategy.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)
The OAP app unfortunately doesn't have any support for feature toggles, but both the ONSS and the mobile app will feature toggle for the Last Mile implementation.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])
We will need to handle translations for the notifications, on the Onboard Navigation Sync Service.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)
None.
