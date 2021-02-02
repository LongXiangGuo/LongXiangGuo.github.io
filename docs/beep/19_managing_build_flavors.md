---
layout: default
title: "BEEP-19: Build Flavor Management"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 19
---

# BEEP-19: Improve Build Flavor Management

### Authors

- Tim Chabot

## Summary

This proposal describes an alternative approach to managing the various build flavors of Eadrax. It accounts for brand, regional hub, backend system and platform.

## Motivation

The Eadrax mobile-connected codebase is currently distributing builds by brand, regional hub (NA, ROW, CN, KR), backend system and platform (iOS, Android). There will be a build created for every possible permutation. Doing the math the total number of builds work out to the following:

|     Brand     |     Platform     |    Regional Hub     | Cloud Environment  | Total Build Permutations |
| :-----------: | :--------------: | :-----------------: | :----------------: | :----------------------: |
| 2 (BMW, MINI) | 2 (iOS, Android) | 4 (NA, ROW, CN, KR) | 3 (DEV, INT, PROD) |            48            |

The above assumes DLY will not be distributed to Appcenter.

Given the total number of build permutations, the build pipeline may not adequately scale to support the number of permutations. This is factoring in the planned build mesh iOS resources and having 4 international development sites contributing in a trunk-based development model.

This BEEP proposes an alternative approach that will reduce the number of permutations the pipeline needs to support while also providing a smoother experience when testing across different permutations.

### Detailed description

The proposed approach is broken into two steps:

#### Step 1 - Compress build flavors locally thru hardcoded endpoints

1. Reduce lib/main files down to main_brand_hub.dart (e.g. main_bmw_north_america.dart) and main_brand_hub_appstore.dart.
2. Introduce configuration selector module. This module will be the first page in the app startup flow and will contain hardcoded values for the Gateway endpoints. Currently this information is hardcoded into the client in the following location: platform_sdk->data->networking->omc_api_client->lib->src->config->omc_configuration.dart. Once a selection is made, the app will pass the hardcoded service endpoint to the omc_client so it is equipped to execute login and other cloud requests for the selected environment. This module will exist for the main_brand_hub.dart files and not main_brand_hub_appstore.dart

- The regional hub and OMC cloud environment (e.g NA_DEV or ROW_INT) should be passed down to the network layer so logging can indicate which hub and environment is in play. This information should be a "header" for the logging messages being recorded so its clear to the consumer of the logs.

1. Builds of the brand and hub flavors will be done on every commit to master while AppStore build flavors will be based on a tagged commit to be released
2. Create Bundle IDs and App IDs for reduced set of build flavors. Modify Jenkinsfile build & distribute stages for the brand/hub flavors, for iOS and Android, BMW and MINI. See breakdown of total builds below
3. For Brand/Hub builds, the profile screen will provide both Logout and Change Configuration buttons so a user can logout/login with a different account within the same environment OR Change Configuration which takes them back to the Configuration selector module
4. For Appstore builds the service endpoint will be hardcoded for security purposes. The App Startup Flow will be unaffected

#### Step 2 - Pull Gateway endpoints from cloud microservice

1. Expose an APIKey authenticated API that allows the client to query what its Gateway endpoint is given the regional hub and cloud environment
2. Create a small configurator microservice that services this API and hosts the endpoint data from #1
3. Authenticate the API with an APIKey as the user will be unauthenticated when changing from one configuration to another
4. Modify Configuration selector module to request the endpoints from this microservice. If the gateway endpoint needs to change or a test needs to be run on a regional gateway (e.g. Russia?) it can be done through this microservice. Retain the hardcoded values in case this exchange fails

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/BEEP_Reduce_Build_Permutations.png" width="80%">
</div>

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/BEEP_Reduce_Build_Permutations_System_Architecture.png" width="80%">
</div>

In this approach, the brand_hub builds compress regional hub and cloud environment permutations down to 12. AppStore retains the regional hub permutations due to legal reasons and are hardcoded to the PROD cloud environment bringing the total number to 16.

### Open Questions

- Should KR be folded into ROW?
- Any onboard vehicle issues with this approach? (No A4A so no code signing limitations?)

## Conclusion

This approach simplifies the number of builds the pipeline will distribute and the number of bundle ids and app ids created to support the Eadrax build flavors. It also provides a better experience for developers and testers in that they can switch environments from within the same application without having to download multiple apps. The implementation of this approach should be fairly straightforward with it being a single API call to fetch the service endpoint for the selected configuration. The Runtime Infrastructure will expedite deploying this service across the different meshes so that its universally available to the mobile application.
