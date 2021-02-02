---
layout: default
title: BMW Points
parent: E-Mobility
grand_parent: Architecture
nav_order: 1
---

# BMW Points

## Overview

BMW Points is a loyalty program for the PHEV users, where they earn points when driving in electric mode, and then can spend their points in rewards, e.g. BMWCharging vouchers

## UI/UX
### Logic Flows
#### Onboarding

![bmw points onboarding]({{site.baseurl}}/assets/images/architecture/emobility/bmw_points/onboarding.png)

#### Main WireFlow

![bmw points main wireflow]({{site.baseurl}}/assets/images/architecture/emobility/bmw_points/bmw_points_main_wireflow.png)

#### Error Cases

![bmw points error cases]({{site.baseurl}}/assets/images/architecture/emobility/bmw_points/error_cases.png)

#### Opt-out/Opt-In

![bmw points opt out/in]({{site.baseurl}}/assets/images/architecture/emobility/bmw_points/opt_out_opt_in.png)

## Architecture

### App

<div class="mermaid">
  sequenceDiagram
  User->>Profile Page: Changed Tab;
  Profile Page->>BMW Points Page: Entry Point;
  BMW Points Page->>BMW points repository: opt in;
  BMW points repository->>BMW points BFF: opt in;
  BMW points BFF->>iMiles Engine: opt in;
  iMiles Engine-->>BMW points BFF: opted in;
  BMW points BFF-->>BMW points repository: opted in;
  BMW points repository-->>BMW Points Page: opted in;
  BMW Points Page->>BMW points repository: get Wallet;
  BMW points repository->>BMW points BFF: get Wallet;
  BMW points BFF->>iMiles Engine: get Wallet;
  iMiles Engine-->>BMW points BFF: return Wallet;
  BMW points BFF-->>BMW points repository: return Wallet;
  BMW points repository-->>BMW Points Page: return Wallet;
  BMW Points Page-->>Profile Page: show wallet status;
  BMW Points Page->>BMW points repository: get Available Rewards;
  BMW points repository->>BMW points BFF: get Available Rewards;
  BMW points BFF->>iMiles Engine: get Available Rewards;
  iMiles Engine-->>BMW points BFF: return Available Rewards;
  BMW points BFF-->>BMW points repository: return Available Rewards;
  BMW points repository-->>BMW Points Page: return Available Rewards;
  BMW Points Page->>BMW points repository: get BMW Charging Contracts;
  BMW points repository->>BMW points BFF: get BMW Charging Contracts;
  BMW points BFF->>ChargeNow Enabler: get BMW Charging Contracts;
  ChargeNow Enabler-->>BMW points BFF: return BMW Charging Contracts;
  BMW points BFF-->>BMW points repository: return BMW Charging Contracts;
  BMW points repository-->>BMW Points Page: return BMW Charging Contracts;
  BMW Points Page->>BMW points repository: redeem reward;
  BMW points repository->>BMW points BFF: redeem reward;
  BMW points BFF->>iMiles Engine: redeem reward;
  iMiles Engine->>ChargeNow Enabler: redeem reward;
  ChargeNow Enabler->>iMiles Engine: reward redeemed;
  iMiles Engine-->>BMW points BFF: wallet updated;
  BMW points BFF-->>BMW points repository: wallet updated;
  BMW points repository-->>BMW Points Page: wallet updated;
  BMW Points Page->>BMW points repository: opt out;
  BMW points repository->>BMW points BFF: opt out;
  BMW points BFF->>iMiles Engine: opt out;
  iMiles Engine-->>BMW points BFF: opted out;
  BMW points BFF-->>BMW points repository: opted out;
</div>

### BFF

![bmw points architecture]({{site.baseurl}}/assets/images/architecture/emobility/bmw_points/bmw_points_architecture.png)

#### API Contract

[OpenAPI Specification](https://btceudly-dev.westeurope.cloudapp.azure.com/swagger/?urls.primaryName=imiles-service)
