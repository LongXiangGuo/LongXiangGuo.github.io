---
layout: default
title: Connected Drive Subscription Expired
parent: Vehicle
nav_order: 10
grand_parent: Architecture
---

# Connected Drive Subscription Expired Widget (CDSEW)

{: .no_toc }
This widget warns the user when the Connected Drive subscription is expired and therefore no remote services are available.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## BFF Model

The behavior of the CDSEW is given by a BFF service that exposes the vehicle capabilities in a bool named
isRemoteServicesBookingRequired. If this variable is set to true, then the full functionality will not be
available on the app, by hiding the Remote Services and Vehicle Data from the user. Instead, a warning is 
shown in order to let the user know that a subscription is required to activate the full feature.
The link button URL is provided by StoreWeblinksBloc that contains the localized connectedDriveStoreUrl.

More documentation [here](https://https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=542114143)

## UX / UI

CDSEW is showed according to the brand Theme and is composed by a title, a body text informing the subscription 
required and, depending on the brand, a link button for quick drive store access.
For BMW brand a link to the Drive Store is provided. Since MINI doesn't currently have a Drive Store 
only the title and the body are shown.
