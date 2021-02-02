---
layout: default
title: Eadrax Share Extension Architecture
parent: Journey Management
grand_parent: Architecture
nav_order: 1
---

## Share Extension Architecture

*Template Version 0.0.1*

* **Author(s):** CTW Team Odyssey
* **Feature Link:** https://atc.bmwgroup.net/jira/browse/NWAP-3803
* **T-shirt Size Estimate:** M

## System Level Overview

The goal of this proposal is to make the Share Destination from another app compatible across all the new features being implemented in the Eadrax app, and to have a  way to send to the car the destination that was share from another provider (ex: Google Maps or Apple Maps), and have this destination reflected on the vehicle in a fast, reliably and seamless manner.

There are only 4 major dependencies with this change:

* The Destination Composite Service
* The Send to Car service
* The LOS Service
* The Commute Service

Mobile 1.0 should not be affected with the changes being proposed.

### Mobile 1.0 Architecture

<img src="{{site.baseurl}}/assets/images/architecture/share_extension_current_arch.png">

As you can see in the current architecture the Vehicle Inbox Service is used to perform the logic behind the share functionality. This service only serves the share extension feature.
The Vehicle Inbox Service calls the Commute Service to do the geocoding.

in this context, Geocoding is the process of taking a pair of coordinates and retrieving a detailed location with street name, house number, country, etc..

### Mobile 2.0 Architecture

<img src="{{site.baseurl}}/assets/images/architecture/mobile2_share_extension_proposed_arch.png">

The picture above shows the proposal for all impacted services. The changes are highlighted in green.

1. The app receives the destination from another application or map provider and calls the Destination Composite Service.
1. The Destination Composite Service transforms the received data to match the contract with the send to car service, this means that the composite only tries to get information from the string in the shared content/link. 
1. The Send to Car service calls external api's to resolve any provided external links (to try to get more detailed info about the shared POI and the coordinates). Then, after resolving the external links, we do some logic (explained bellow) to try and resolve missing information from the POI using the commute and the LOS api. After all this is done we return a POI detail model back to the destination composite and it returns the details to the app.
1. The App shows the details screen about the shared point of interest.

We also should provide a option on the Send To Car Service endpoint to enable the service to immediately send the found POI to the vehicle if no errors ocurred.


[comment]: <> (This section should describe the overall system design of the feature.  It should identify the various components that make up the solution[microservices, frameworks, external services] and how they interact. Any interfaces and data models should be identified here.  Expectations for this section include: Components Diagrams, links to Swagger IDLs, Class Diagrams, Interaction Diagrams etc.)

## Code Level Details

<img src="{{site.baseurl}}/assets/images/architecture/share_extension_flow.png">

In this sequence diagram we can get an overall view of how this feature will work.
Here we can see the process we take to resolve a shared POI to a LOS POI format.

The composite should try to “format” the string data that comes from the app and fill the model data that's required for the call to send to car service while also passing any links provided from the shared data.
The data that comes from the different apps are all in string format but varies wildly some may come in csv format, others come in a big link and some come with only simple street name.

With this logic always try to get a matching POI to show to the user, in case we don't get any matching POI we guide the user to make a sharedName based search on the app.

The model returned by the Send to Car on this endpoint should match the same model used to present POI details ( that come from the search composite).

### Client Details

The shared and platform specific code is located in a package with the name of *shared_data* inside *platformSdk*. This library unify the incoming external flow and expose to the rest of the application the data.

*BottomBarMenuBloc* is the only receptor of this shared data library because it is the place where we want to start to control the logic (changing the tab and so on). Here we are sure that the user is logged in and the security PIN was correct.

#### Android Details

It is necessary to declare the intent filter with the desired action. The action to show the our application in the share menu is *android.intent.action.SEND*. We handle this incoming data in the kotlin code located in *shared_data* library.

#### iOS Details

It is necessary to create a native plugin, named *Share Extension*. It is located along with the application Flutter Runner, inside the top *ios* folder. This pure swift plugin has responsability of obtaining the data from the external application, processing it and building an internal URL with it to launch our application.

It does not show any specific view in this process, it simply interrupts the user and sends it to our application. Because of this, iOS displays a shortcut in the top-left to return to the previous application.

The iOS URL internal Scheme:
**(bundleID).Share-Extension.Destination://#(base64UrlEncodedData)**

For example:
**com.bmw.connected.mobile20.na.dly.Share-Extension.Destination://#aHR0cHM6Ly9nb28uZ2wvbWFwcy9RYnZ3WXk0NDk3TXNvOXJEQQ**

In this example, the base 64 data is a Google's link:
"*aHR0cHM6Ly9nb28uZ2wvbWFwcy9RYnZ3WXk0NDk3TXNvOXJEQQ*" -> *https://goo.gl/maps/QbvwYy4497Mso9rDA*

In order to enable this navigation from our plugin to our app with this URL scheme, it is necessary to add the corresponding configuration in the *Info.plist* file. It will be a **CFBundleURLSchemes** entry with **$(FLUTTER_BUNDLE_ID).Share-Extension.Destination** as a value. We handle this incoming data in the swift code located in *shared_data* library.

### FAQ

**What happens when, after conducting a search on LOS, we get multiple results?**

When only the coordinates are shared we use closest result as the "correct" one.
When only the address is shared we try to find an exact match, if that isn't possible we return an error saying that we couldn't match the specified place.
When Coordinates and address is shared we search for the address on LOS using the coordinates as search center and take the closest result. If that result is really close to the shared coordinates we use it, if not, proceed to the coordinates only case.

This might change in the future, since this is only the first implementation. With more usage analytics we can then modify this logic.

**If we search on LOS for a location and it is not found, why guide the user to search those terms again on the app?**

This is done because the backend logic to search for the terms is quite limited in its flexibility and it might not find an exact match for the shared location and fail while the shared location might exist in LOS. Since the customer can refine the query a little, and also we drag him into our app and maybe entice him to keep using it.

**What if the shared location doesn't come from any of the supported apps?**

In this case, the mobile 2.0 app should show an alternative search flow, enabling the user to query the shared text inside our app.

[comment]: <> (This section should highlight any design details at the code level.  E.g. Any design patterns that should be used.  Changes to existing designs.  Details about data models and types.)

## Design Checklist
[comment]: <> (Each of the following questions needs to be answered in order for this design to be considered complete.)

**What risks does the team need to be concerned with before taking on this this feature**

[comment]: <> (Enumerate any risks that might affect completion of this feature.  How does this affect the estimate.  E.g. unknown or incomplete dependencies, preview software,etc.)
LOS don't retrieve the information needed.

**What existing components are modified by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.  Will this require a code refactor to avoid piling up technical debt on top of an already fragile system?)
* Destination Composite Service
* Send To Car Service

**What new components are created by this design?**

[comment]: <> (Enumerate/link to all components this solution will impact.)
None.

**Are any new technologies/frameworks being used?**

[comment]: <> (Are they approved for production use under the Tech Radar? Are there Open Source libraries being used? Do they meet our Open Source Policy?)
None.

**What security issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss security issues here. Has Carve reviewed this design? Is there a threat model?)
None compared to existing design.

**What privacy issues does this design introduce and how are they resolved?**

[comment]: <> (Discuss how privacy is protected here. Has the privacy assessment questionnaire been answered? Link to it here.)
None compared to existing design.

**Does this design add a new feature to a client? How will this feature support be extended to other clients (iOS/Android/Alexa/Head Unit, etc.)**

[comment]: <> (Hint:  This means are you thinking cloud first?)
Mobile 1.0 client should not be impacted by this change and it won't need any update.


**What performance issues may affect this feature and how are they resolved?**

[comment]: <> (Is this feature stateful? Can it scale horizontally?  What happens on the client if you have a broken or failed connection?)
The performance in the affected microservices won't change. The scaling of these serviçes will be just like how it works in this moment.

**Will this feature add additional cloud hosting costs?**

[comment]: <> (Projections on costs and how they will be managed should be described here)
Cloud hosting costs are not projected to increase.

**Will this service generate additional load/requests on any external dependent services?**

[comment]: <> (Do we have interface contracts in place, has the service been informed of the upcoming new load, will this add additional costs?)
None.

**What dependencies does this feature rely upon?**

[comment]: <> (Does this require a service from another US-2 team? Are there FG or EE deliverables this feature relies on? Are there agreements in place? Are there 3rd party systems we are using? If so, are there IFC in place? What does the network traffic structure looks like? How will the peak traffic be simulated for load run? does it cost or have rate limits and how will be minimize the impact?)
The main dependencies are going to be the LOS service hosted in FG, just like it is today.

**How will this feature be tested, monitored, and evaluated?**

[comment]: <> (What analytics will be collected?  What logs are generated?)
Not yet defined

**How will this feature be deployed?**

[comment]: <> (What feature toggles will be added?  What criteria will trigger them?)
The services will be updated and a normal update process will occur with them.
No toggles necessary for this.

**Does this feature have regional implications?**

[comment]: <> (How will this work and what needs to be done to support all regions [EMEA, USA, China, Korea, Japan, etc.])
No changes from current architecture.

**Has any new IP been generated from this design?**

[comment]: <> (Should we consider a patent application?)
None.
