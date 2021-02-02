---
layout: default
title: Preferred Service Partner Service
parent: Aftersales
nav_order: 9
grand_parent: Architecture
---

[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)

_Template Version 0.0.1_

**Author(s):** Vishwanath Muddu<br />
**Feature Link:** [Preferred Service Partner](https://suus0002.w10:8080/browse/BMWO-165793)<br />
**T-shirt Size Estimate:** _S_

[comment]: <> (Note: This template must be filled out completely with all sections answered. The pre-grooming task will not be accepted as done without the proper sign off. No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle. The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

## System Level Overview

[comment]: <> (This section should describe the overall system design of the feature. It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here. Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

In an effort to modularize the dealer search service that has evolved to a point where it is not only easy to manage but also to expand we have decomposed dealer search into its own individual services and Preferred Service Partner service is one of them. Preferred Service Partner Service is a convenient way to find a service partner of a user. This service is shadowed by the Dealer Services microservice that acts like a facade and is a convenient dealer locator which allows users of this service to find BMW and MINI Automotive dealers based on their geographic location. The Dealer Services microservice acts as an enabler for other services such as Online Appointment Service(OAS) and Integrated Personal Assistance(IPA) and many more to follow.

### System Architecture

The preferred service partner (**PSP**) is an object identifying a service partner (BMW service dealer for a **specific VIN**. The PSP is initially set by BMW or one of its affiliate dealers to the dealer that sold the vehicle, so every VIN created and sold via a BMW dealer would have a PSP set for that VIN. The PSP can be set, changed or deleted by a user if the user has the VIN mapped to his/her ConnectedDrive account. The PSP however, is NOT a user's property, it stays with the VIN even after it has been de-mapped or mapped to new accounts. The PSP can also be changed by a BMW dealer.

- Current System Design/Implementation
  - The existing implementations of the Dealer Search service can be found here: [OMC Preferred Dealer Integration with FG Home Dealer](https://suus0001.w10:8090/display/ARC/OMC+Preferred+Dealer+Integration+with+FG+Home+Dealer)
- Reason for Improvements
  - The Business logic for Preferred Service Partner is integrated in the Dealer Search Service and as we continue to support multiple platforms like IPA, we want to segregate PSP from Dealer Search Service in order to better support the feature by reducing the complexity of handling multiple features in a single micro-service and this will allow us to enhance our monitoring and analytics with minimal and less intrinsic queries

<div style="max-width:auto;height:auto;margin-left:35px">
  <img src="../../../../assets/images/architecture/aftersales/preferred-service-partner/psp-architecture.png">
</div>
<center style="margin-right:75px"> The above picture depicts the overall system design of the feature.</center>

### System Breakdown

###### DESCRIPTION

The following are the use cases for getting a Preferred Service Partner associated with a VIN

- When a user requests for a PSP, we check our OMC database for the specified VIN and return the result on success
- On the other hand, if the PSP isn't found then we forward the request to the CDP API and based on the response we either save the result and return back a PSP or return back a HTTP Not Found result status.

##### Preferred Service Partner Database Schema

##### Details

We plan to replace storing this data in one storage table with a total of 2 database tables: 2 entities.

<div style="width:75%;height:75%;margin-left:75px">
  <img src="../../../../assets/images/architecture/aftersales/preferred-service-partner/psp-database.png">
  <center>The above diagram depicts the relationship between the two entities</center>
</div>

Having these tables will improve the way we manage our data and eliminate duplicates. The process of fetching a preferred service partner for a given vin will look like the following:

- Query for `VIN` on the `dealer_vin` table to get the appropriate `dealer_id` and `business_name` associated

Below is the definition of each of the tables with an example row:

#### Dealer VIN

| id  | vin    | dealer_details_id | created_at |
| --- | ------ | ----------------- | ---------- |
| pk  | string | int               | timestamp  |
| v1  | BMW440 | d1                | 2019-12-02 |

#### Dealer Details

| id  | dealer_id | business_name | brand | is_active | created_at |
| --- | --------- | ------------- | ----- | --------- | ---------- |
| pk  | string    | string        | Enum  | boolean   | string     |
| d1  | 0540_1    | perillo_bmw   | BMW   | true      | 2019-12-02 |

#### Sequence Diagrams

<div style="width:75%;height:75%;margin-left:75px">
  <img src="../../../../assets/images/architecture/aftersales/preferred-service-partner/psp-get.png">
</div>
The above sequence diagram depicts the working flow of the Preferred Service Partner service for getting a Service Partner.

###### DESCRIPTION

The following are the use cases for which a preferred service partner can be set for a valid vin

- A user with a valid vin and a valid GCDM token can set a preferred service partner through the connected drive app, after some initial validation on the OMC level we forward the request that goes through the CDP API Gateway to a FG system and based on the response we either save the result on our OMC database and return the result or return an error message stating the obvious
- As there are multiple places by which a preferred service partner can be set for a valid vin, and as the preferred service partner listener being a self hosted service, it listens and subscribes to the events published by the PiSA topic and calls the preferred service partner microservice to save the updates in our OMC database

The following are the use cases for which a preferred service partner can be removed for a valid vin

- Currently, the connected app doesn't provide a feature to directly remove a preferred service partner associated with a vin
- A consumer of this service with a valid vin and a valid GCDM token can remove his preferred service partner by calling the delete preferred service partner endpoint, we forward this request that goes through the CDP API Gateway to a FG system and based on the response we either remove the preferred service partner for that vin from the database and return back an OK result code or return an error message

<div style="max-width:75%;height:75%;margin-left:75px">
  <img src="../../../../assets/images/architecture/aftersales/preferred-service-partner/psp-set-remove.png">
</div>
The above sequence diagram depicts the working flow of the Preferred Service Partner Service for multiple Http verbs.

###### DESCRIPTION

The following are the use cases for which a preferred service partner can be set for a valid vin and updated

- When a preferred service partner is either updated or set, an event is published by the PiSA topic to all the subscribers
- Preferred Service Partner Listener microservice listens to events published by the PiSA topic and makes a Http PUT request to the preferred service partner microservice to update the service partner for a valid VIN

<div style="width:75%;height:75%;margin-left:75px">
  <img src="../../../../assets/images/architecture/aftersales/preferred-service-partner/psp-sync.png">
</div>
The above sequence diagram depicts the working flow of the Preferred Service Partner Listener subscribing to events published by the PiSA topic.

## Code Level Details

[comment]: <> (This section should highlight any design details at the code level. E.g. Any design patterns that should be used. Changes to existing designs. Details about data models and types.)

- Dealer Search Services (already in place)
  - Will gain support to proxy all preferred service partner calls to Preferred Service Partner Service (new micro-service) Migrate to use BtcBuild for CI/CD and GitHub Enterprise for source version control
  - will gain support to be client agnostic
- Preferred Service Partner Service (new micro-service)
  - All the business logic pertaining to preferred service partner will be moved from Dealer Search Service and will be handled in this service
  - Adding a persistence layer for storing preferred service partner for all mapped vins and dealers (new RDBMS instance)
  - Follows the new runtime tools to create, deploy and manage resources
- Preferred Service Partner Listener(already in place)
  - Listens to a Java Message Service(JMS) Message Queue for events published by the PiSA topic

## Design Checklist

[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature. How does this affect the estimate. E.g. unknown or incomplete dependencies, preview software,etc.)

- New Programming language might affect the pace of development as the team is not well versed with the language and framework.

**What existing components are modified by this design?**

None.

[comment]: <> (Enumerate/link to all components this solution will impact. Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

##### Preferred Service Partner API specification

[Preferred Service Partner service API specification](https://suus0001.w10:8090/display/~muddu/Preferred+Service+Partner+service+API+specification#)

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)

New PSP service the doc describes.

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)

- New programming language - go

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)

No new security issues.

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)

No new privacy issues.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint: This means are you thinking cloud first?)

No.

**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally? What happens on the client if you have a broken or failed connection?)

- It can auto scale horizontally and vertically if there's any performance degradation issues due to increased load.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)

Yes, since there is a new microservice and a new database.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)

There would be additional load on the connected drive portal (CDP) API gateway in an event when we do not find a service partner is our database.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

This Service relies on multiple services, which are the following:

- It heavily relies on the PSP Listener which is a Java Messaging Service(JMS) that subscribes to events published by the PiSA Topic and updates our database as needed to reflect changes in the service partner systems
- It relies on the CDP API Gateway to look for a preferred service partner for a give VIN in an event where we'd get a not found from the database for resiliency
- We call the CDP API Gateway to set and remove a preferred service partner for a valid VIN
- Relies on the vehicle-user-vin-relationship api to validate user-vin relationship

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected? What logs are generated?)

- Event Traces, Requests and Dependencies will be logged in Kibana for Analytics
- Monitoring includes, having a health check test, service-gateway validation test and other charts on the dashboard which includes understanding trends of the service for instance., peak service usage, number of requests per hour, etc
- We have all the standard alert rules in place for like # of 400s, 401s, 403s, 404s and 753s which will be created when we create the resource through the runtime tooling
- We also cover some custom alerting rules in the lines of number of requests for a particular endpoint, to get further insights of the service
- No personal information would be logged as part of this microservice otherwise all standard logging will be implemented to collect data in order to report various patterns and trends

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added? What criteria will trigger them?)

Using standard github/jenkins pipeline.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

No.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No.
