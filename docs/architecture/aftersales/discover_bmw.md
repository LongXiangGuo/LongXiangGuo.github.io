---
layout: default
title: Discover BMW
parent: Aftersales
nav_order: 7
grand_parent: Architecture
---

# Discover BMW

[comment]: <> (Comments like this will show up throughout the template that provide further details and follow up questions but do not need to be seen in the final documentation. Feel free to remove them after you have answered the question/followed the instructions or leave them in and they will be automatically hidden)


**Author(s):** Gemini

**Feature team contact:** Gemini_Scrum_Team@list.bmw.com

**Feature team location:** Chicago

**Feature link:** [3.6 Discover BMW - Current](https://atc.bmwgroup.net/confluence/display/NWAP/3.6+Discover+BMW+-+Current)

**Wires:** [DESIGN : UX / UI](https://atc.bmwgroup.net/confluence/display/NWAP/3.6+Discover+BMW+-+Current#id-3.6DiscoverBMW-Current-DESIGN:UX/UI)


[comment]: <> (Note: This template must be filled out completely with all sections answered.  The pre-grooming task will not be accepted as done without the proper sign off.  No feature, no matter how small or obvious can bypass the pre-grooming review.)

[comment]: <> (The goal of this template is to help teams get a sense of project scope and minimize risk to completing the feature during the planned release cycle.   The template should identify the main architectural components, domains and external dependencies associated with this feature. This is not a comprehensive design document, detailed design should be done by the development team responsible for the feature.)

[comment]: <> (Instructions:)
[comment]: <> (- Three reviewers are required. You may add more if necessary)
[comment]: <> (- Reviewers should be a mix of team members and external domain experts as required)
[comment]: <> (- Creation of the template and review should be rapid [< 1 week duration from start to review completion])

Discover BMW shows news on the Profile tab in My BMW app.

<img src="../../../../assets/images/architecture/aftersales/discover_bmw/ux.png">

## System Level Overview

<img src="../../../../assets/images/architecture/aftersales/discover_bmw/high_level.png">

The data for Discover BMW comes from Drupal CMS. To get the news data, mobile client makes a request to Discover BMW composite service, which then uses [BMWUserProfileApiClient](https://code.connected.bmw/library/bmw-npm/blob/master/packages/user-profile-api/README.md){:target="_blank"} to get home market. With the home market as a parameter, Discover BMW composite service makes a request to Drupal Gateway API to fetch news. If a locale isn't provided, we use the default language to filter news for a particular home market.

## Upload BMW News

News content is uploaded by end users through Drupal CMS [Drupal](https://suus0001.w10:8090/display/ARC/Drupal+CMS)


## Code Level Details

### GET /api/v1/news

##### Summary: Get news

##### Parameters

| Name | Located in | Schema | Required |
| ---- | ---------- | ----------- | ---- |
| x-usid | header | string | true |
| authorization | header | string | true |
| x-user-agent | header | string | true |
| accept-language | header | string | false |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Success | [NewsModel](https://code.connected.bmw/after-sales/discover-bmw-composite-service/blob/master/src/api/v1/news/models/news.model.ts) |
| 400 | Bad Request |  |
| 401 | Unauthorized |  |
| 500 | Internal Server Error |  |


**[News Data Model](https://code.connected.bmw/after-sales/discover-bmw-composite-service/blob/master/src/api/v1/news/models/news.model.ts){:target="_blank"}**

```
 {
    "headline": "Show your passion with BMW Motorsport Collection.",
    "content": "With the BMW Motorsport Collection, BMW has created Lifestyle products that perfectly underscore the feel of racing.   Whether on the track or off it, you’ll always stand from in the crowd.",
    "image": "https://btcdrupalgatewaydly.azureedge.net/assets/news/images/sites_default_files_shared_files_2018-02_Motorsports_20Connected_20Image.jpg",
    "startDate": "2018-02-27T00:00:00Z",
    "endDate": "2028-02-27T23:59:59Z",
    "rank": 9,
    "buttons": [
      {
        "label": "Find a Dealer",
        "action": "native",
        "data": "DealerSearch",
        "icon": "findDealer.png"
      },
      {
        "label": "Learn More",
        "action": "www",
        "data": "https://www.shopbmwusa.com/LIFESTYLE/BMW-COLLECTIONS/BMW-MOTORSPORT",
        "icon": "goToUrl.png"
      }
    ],
    "id": "F9A7D36C8CA6E4C4895F200CF51C79A7",
    "createDate": "2018-02-28T00:06:32Z",
    "category": "false",
    "seasonalCampaign": false
  }
```

<br/>

***News Carousel Widget***

News carousel is the entry point of Discover BMW news, users can scroll to view news headlines and images. For any article published within the last 4 weeks that hasn't viewed by the user yet, it shows a new tag on the carousel.

***News Details Page Widget***

Once the user clicks on the news carousel, it opens a news details page that shows the content and actionable buttons:
- Find Dealer Button
  - It uses existing functionality created by Dealer Search team in Chicago and redirects to the dealer search tab.
- Learn More Button
  - It opens the url provided in the news data.

## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)

None

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)

Drupal CMS

**What new components are created by this design?**

- **Discover BMW Composite Service**
  - Serve as a BFF layer between client and Drupal
- **Joy UI Framework**
  - News carousel component
  - News tile component
- **Mobile Connected**
  - **Platform SDK**
    - **Discover BMW Repository**
        - Added API client to make request to Discover BMW composite service
  - **Discover BMW feature module**
    - Created Discover BMW data Model and widgets
    - Created Discover BMW BLOC and states

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

Possible increased load for the existing Drupal backend, because it needs to provide content for both Mobile 1 and Mobile 2.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)

None

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)

We will leverage Mobile 2.0 toolchain for testing.  User click events and network sucesses/failures will be logged.

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)

No feature toggles planned for this feature in Mobile 2.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])

It currently supports NA and ROW, we will be adding more regions next.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)

No
