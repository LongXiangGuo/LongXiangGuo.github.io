---
layout: default
title: Applying Feature Toggles
parent: Feature Toggles
grand_parent: Core
nav_order: 20
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Mobile 2.0 - Applying Feature Toggles 

# Why Feature Toggles

Feature toggles are a technique for enabling or disabling a feature within a software system without adding or removing code.  The service used should be able to support making toggle changes dynamically while providing a simple way of expressing the rules governing those toggles.

The following article is a good summation of the "why" with some of the "how": [Feature Toggles by MartinFowler.com](https://martinfowler.com/articles/feature-toggles.html)

Feature Toggles provide the following benefits:

* Enable delivery of new functionality to users rapidly and safely
* Promote Continuous Delivery to DST (Downstream Test) & Release Circle 
* Empower the business with control over feature release
* Allow targeting of features to specific markets, brands or platforms
* Promote experimentation through controlled rollout to a cohort of users

# How Should Feature Toggles Be Applied?

The following reflect the team's opinion of how feature toggles will be applied in the Mobile 2.0 product:
1. All toggles will be implemented in the Mobile 2.0 Presentation Microservices
   * Allow data to drive the mobile presentation
   * Toggle whether data is present (or not) where it's created -- in the Presentation Microservice
2. Apply feature toggle at the Presenation API service level
    * Do this if the desire is to turn on or off a "sub-feature" supported by an API
    * Example - Remote Tab API - turn off Remote Service Charging Profile or Remote 360 but allow other Remote Services to be displayed to the user

# User Context

Feature toggle rules are based on a set of user criteria which creates toggle context for that user.  The context values shall be lowercased for simplicity.

| Context Value        | Proposed Values                                  |
|:--------------------:|:------------------------------------------------:|
| region               | na, cn, row                                      |
| brand                | bmw, mini                                        |
| platform             | ios, android                                     |
| clientVersion        | e.g 1.0.1086 -- follows semantic versioning format |
| connectedDriveMarket | e.g. us, de, gb -- user's 2-letter connected drive country code  |
| deviceMarket         | e.g. us, de, gb -- user's 2-letter device country code |

# On/Off Criteria

* Experiments
* Markets (trial with toggles and with microservice configuration to determine best approach)

The team discussed these several criteria items and determined the most relevant for to the presentation microservices are using toggles for experiments (e.g WIP or alpha/beta feedback) and trialing it with market-based features.

# Feature Toggle Service

Each microservice will use the Rocket NodeJS SDK which can be found in the [BMW NPM Package](https://suus0003.w10:7990/projects/NP/repos/bmw/browse) to implement feature toggles.

The Vehicle Composite Service was the first microservice to implement an approach.  The FeatureToggleService supports a `getToggleValues` API that takes an array of toggle names and returns a corresponding list of toggle values.  

```typescript
@Injectable()
export class FeatureToggleService implements FeatureToggleService {
  constructor(private rocketClient: MockRocketClient) {}

  async getToggleValues(toggleArr: string[]): Promise<Toggles> {
    const arr: boolean[] = [];
    for (const i of toggleArr) {
      const x = await this.checkToggle(i);
      arr.push(x);
    }
    const toggleValues = arr;
    const toggles = _.zipObject(toggleArr, toggleValues);
    return Promise.resolve(toggles);
  }

  private checkToggle(toggleName: string): Promise<boolean> {
    return this.rocketClient.checkEnabled(toggleName, null, false);
  }
}
```

The toggle values can then be passed into a mapping function that builds up the dataset the API will return.  

```typescript
async getRemoteTab(token: string, vin: string): Promise<RemoteTab> {
    const vehicle: LitVehicle = await this.vehicleClient.getVehicle(
      null,
      token,
      {
        vin,
      },
    );

    const toggles = await this.featureToggleService.getToggleValues([
      RemoteServiceType.Remote360,
      RemoteServiceType.ClimatizeNow,
      RemoteServiceType.ClimatizeLater,
    ]);

    return mapVehicleToRemoteTab(vehicle, toggles);
  }
```

In this case, for those remote services that are not enabled, no data will be generated for them.
```typescript
  if (
    toggles[RemoteServiceType.ClimatizeNow] &&
    vehicle.isPreconditionSupported()
  ) {
    remoteServicesList.push({
      type: RemoteServiceType.ClimatizeNow,
      isEnabled: vehicle.isPreconditionEnabled(),
      isPinAuthenticationRequired: isPinAuthenticationRequired(
        RemoteServiceType.ClimatizeNow,
      ),
    });
  }
```

**FUTURE WORK** - transistion the logic behind the FeatureToggleService in the above example to a Rocket SDK interface like this:

```typescript
devToggle(name, defaultValue, onCallback, offCallback, expirationDate)
```
This proposed work is captured in this [Jira Story](https://suus0002.w10:8080/browse/MOB-1318)

# Other Use Cases

1. Profile Tab Content
  * Features that the tab exposes can be driven from a Profile presentation API
2. Search Options
  * The search options displayed to the user can be driven from a search provider presentation API
3. Brand specific features
  * MINI Findmate and Rain Warning features can be driven by the brand of mobile application making the request

# Summary

Since the Presentation APIs communicate what the mobile application should present, its proposed that we follow the pattern of each presentation microservice toggling the feature at the API controller or service level such that the data returned drives what is presented to the user.
