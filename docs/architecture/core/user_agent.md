---
layout: default
title: User Agent
parent: Core
grand_parent: Architecture
nav_order: 16
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# User Agent Investigation

To understand what our existing User Agent looks like I used the package `flutter_user_agent` to print out the user agent for iOS and Android.  This was done primarily with the simulators so I'd need to run sideloaded builds to get the true device user agent. 

## Mobile 1.0 User Agent

### iOS

This format was taken from the OMC Agent Service and is the format sent from the client.
**iOS(12.1);bmw;10.2.0.1510;Development**

### Android

This format was taken from the OMC Agent Service and is the format sent from the client.
**Android(9); bmw; 6.3.0.5874; integration**

## Launch Darkly Implications

### Mobile 1.0

The Launch Darkly User Context is built up from:
* Brand (bmw, mini)
* "Hub" (e.g. NA, ROW, China)
* Connected Drive Country Code
* Device Locale
* Platform (e.g iOS or Android)
* Version
* DownstreamTester (?)

### Mobile 2.0

Assuming the Launch Darkly User Context is largely the same, the client will need to add the following to the User Agent:
* Brand (bmw, mini)
* Client Version

Proposing not sending the following properties in the User Agent for the following reasons:
* "Hub" (e.g. NA, ROW, China) - should be derived from the service mesh the microservice is running in
*  Connected Drive Country Code - the microservice should be able to retrieve this from a core backend (GCDM or OMC)
*  Device Locale - advocating to remove this since we are guaranteeing users will supply their country in the Connected Drive Country Code
* Downstream tester property should be avoided in favor of having a user segment defined in LD with the USIDs of testers that would like a given feature enabled for them.

## Mobile 2.0 Proposed User Agent Format

Proposed format is to follow the existing format but eliminate the build type since that can be derived by the microservice's service mesh.  Any future additions to the user agent will be appended and will NOT break the base format described here:

```
<platform>(baseOS); brand; clientVersion; 

where:
platform is iOS or Android
baseOS is a version number of format x.x.x(build number)
brand is bmw or mini
clientVersion is a version number of format x.x.x(build number)

Example:
iOS(12.1.0);bmw;1.1.1(256); 
Android(9.0.0);bmw;1.1.1(439);
```

# Online Resources
[Flutter User Agent Plugin](https://pub.dev/packages/flutter_user_agent)