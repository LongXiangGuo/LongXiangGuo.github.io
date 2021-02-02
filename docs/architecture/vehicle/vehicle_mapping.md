---
layout: default
title: Vehicle Mapping
parent: Vehicle
nav_order: 1
grand_parent: Architecture
---

# Vehicle Mapping

{: .no_toc }

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

## Presentation API Swagger

Here's a link to [the latest Swagger for the Vehicle Mapping Composite Service](https://btcnadly.centralus.cloudapp.azure.com/svc/vehicle-mapping-composite-service/docs/)

## Confluence Architecture Docs

- [OMC/VURS/CDP/SVMS/IDS System Flow](https://atc.bmwgroup.net/confluence/pages/viewpage.action?spaceKey=MOBCLOUD&title=Vehicle+Mapping+Documentation)
- [Client/Backend System Flow](https://atc.bmwgroup.net/confluence/display/MOBCLOUD/Mapping+Flows+M2.0)

## What is vehicle mapping?

Vehicle Mapping is the process that a customer, or a dealer on behalf of a customer, will need to perform in order to associate a certain vehicle to his/her account. This association will be confirmed on BMW's backend, so if a user switches between different devices, or between mobile and web, when using the same account should be able to retrieve the vehicles mapped under the given account.

The vehicle mapping process can be executed from:

- The Connected Drive Portal (CDP)
- The Connected app in all its variants (Android and iOS, Mobile 1.0, Connected Classic...)

In order to map a vehicle, you will need to have access to:

- The email account or user name associated with the Connected Drive account
- A vehicle's VIN number
  - If it's a real vehicle, you'll need access to its head unit: [Vehicle Mapping 1.0](http://suus0001.w10:8090/display/ARC/Vehicle+Mapping)
  - If it's a virtual vehicle, you don't need anything besides the VIN

## What is _not_ vehicle mapping?

When connecting via A4A (either USB, Bluetooth or WiFi) to a vehicle that is not part of the user's vehicle list of mapped vehicles, then that vehicle will show up on the user's app. However, this is not considered vehicle mapping, since no association is done in the backend. While this behavior might change, it is not the case at the moment. These types of scenarios are called just "A4A vehicles".

This is how most of MINI vehicles work at the moment, and BMW's which aren't mappable.

## Mobile 2.0 Vehicle Mapping Phases

<div class="mermaid">
  graph LR
    login[Login] -.->|No Profile / Incomplete Profile| completeProfile[Complete Profile]
    completeProfile -->|Dismissed| login
    login --> homePage[Vehicle Tab]

    enterVin[Enter VIN] --> addVehicle[Add Vehicle]
    addVehicle -->|Handled in Backend| checkMappable[Check Mappable]
    checkMappable --> addVehicle
    addVehicle --> codeConfirmation[Code Confirmation]
    codeConfirmation -.->|Failure| addVehicle
    addVehicle -.->|When Code is Expired| resetCode[Reset Code]
    resetCode --> addVehicle
    codeConfirmation --> exit

</div>

### Decouple from the Complete profile screen

An incomplete profile has an impact on the entire performance and architecture of the app. In most of the cases, an incomplete profile means that we have no access to the ConnectedDrive country, affecting many other features, such as financial services, dealers...

What we want to do is to request the user to complete their profile earlier in the process; the sooner, the better, so immediately after login seems to be a good start. With this approach we can ensure a couple things:

- If there are new profile requirements, they can be captured upfront
- It simplifies the usage of the app, requires less assumptions and more accurate data
- The user can control their information more often

### A4A-only vehicles & vehicles that cannot be mapped

In an ideal world, all the A4A information should be sent to the backend. The backend is the single source of truth that determines that a vehicle has been "soft-mapped" (not a _true_ mapping). We could send the vehicle information and the USID to the backend, and let the backend decide how to surface the data in the clients.

This will allow us to treat all the vehicles with a common API, regardless of what data source originated the information.

This approach should be validated with the architecture tribe first, due to the amount of changes it would require.

## Brief Overview of Mobile 2.0 Vehicle Mapping Process

1. Check Mappable
   - **In Mobile 2.0, this will be handled in the backend as part of Add Vehicle**
   - See if the vehicle can be added to your account
2. (**Edge-Case**) Market Move
   - **This indicated via Check Mappable response, which prompts us to ask users for consent before proceeding**
   - Users can move the vehicle from its original country to their country (common R.o.W. use-case, or USA <-> Canada)
   - This is only available if the vehicle was provisioned for another country than the user's account
   - It only works if the vehicle can be moved to the new country
     - Otherwise you'll receive the error `400 - BU_CHANGE_NOT_ALLOWED` in the **Map Vehicle** phase
   - In the case of NA market move between USA and Canada, it must be mapped as primary
3. Add Vehicle
   - Add a vehicle to your account
   - The vehicle mapping process will be in a "Pending" state until the next step
   - **When Market Move is required**
     - If user cancels, we terminate the process before mapping
     - If user confirms, we call a separate endpoint that excludes "Check Mappable"
       - By definition, you can't receive Market Move indication without Check Mappable already having succeeded
4. Validate Security Code
   - Users need to input the security code sent to their head unit
   - If successful, the mapping will be done here, although it will take minutes / hours for this to be reflected across FG's databases
   - Else:
     - After 4 hours, this code expires and the next step is necessary
     - After sending an incorrect code 3 times, the code also expires and the next step is necessary
5. (**Optional**) Reset Security Code
   - Prompts FG to send a new security code to the vehicle
   - After this happens, the user can proceed back to the previous step

### System Diagram of Vehicle Mapping Composite Service

The new Composite Service for Vehicle Mapping is the **Presentation API** for vehicle mapping in the Mobile 2.0 mobile client. Like our other composite backends, it supports [standard backend mocking practices](../../core/mock_vs_live_api).

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant OMC
    participant FG
    M2 ->> GW: Vehicle request {Long VIN, OAuth Token}
    activate GW
    GW ->> GW: Validate OAuth Token
    opt Authentication Fails
      Note over M2, GW: Refresh Token Flow
    end
    GW ->>+ OMC: Extract USID / GCID from OAuth Token
    OMC ->>- GW: USID / GCID
    GW ->>+ Presentation: Dispatch vehicle request {Long VIN, USID / GCID}
    Presentation ->>+ CDP: Dispatch vehicle request {Long VIN, USID / GCID}
    CDP ->>+ FG: Dispatch vehicle request {Long VIN, GCID}
    activate FG
    alt FG Request Fails
      Note over M2, FG: Sends failure back to client
    else FG Request Succeeds
      FG ->> CDP: Response from FG
    end
    deactivate FG
    CDP ->>- Presentation: Response from CDP (Parses response from FG)
    Presentation ->>- GW: Presentation API Response (Parses response from CDP)
    GW -x M2: Presentation API Response
    deactivate GW
</div>

Most requests will follow this format, as all of the proposed APIs require a VIN. However, some of the use-cases, errors, edge-cases, etc. will differ slightly.

## Vehicle Mapping API Flows

### Add Vehicle Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant FG
    M2 ->> GW: POST /v2/vehicles/{vin} request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v2/vehicles/{vin} request {Long VIN, USID / GCID}
    Note over Presentation, FG: Check Mappable Flow
    alt Check Mappable Failure
      Note over M2, Presentation: Sends failure back to client - END
    else Check Mappable Success
      Note over Presentation: Continue
    end
    Presentation ->> CDP: Dispatch POST /mapVehicle request {Long VIN, USID / GCID}
    CDP ->> FG: Dispatch POST /me/mapping/v1/{vin} request {Long VIN, GCID}
    alt Failure (MissingUserProfile)
      FG ->> CDP: Response from FG (isValidUserProfile == false)
      CDP ->> Presentation: Response from CDP (isValidUserProfile == false)
      Presentation ->> GW: Presentation API Failure Response (400 - MissingUserProfile)
      GW -x M2: Presentation API Failure Response (400 - MissingUserProfile)
      M2 ->> M2: Prompts user to update CDP profile
      alt User Selects "Yes"
        M2 ->> GW: Update Profile
        Note over GW, FG: Update Profile Flow
        Note over GW, FG: User can re-start mapping process to continue
      else User Selects "No"
        Note over M2: User cancels - END
      end
    else Failure (Market Move Required)
      FG ->> CDP: Response from FG (200 - OK, marketChangeRequired == true)
      CDP ->> Presentation: Response from CDP (200 - OK, marketChangeRequired == true)
      Presentation ->> GW: Presentation API Failure Response (446 - MarketChangeRequired)
      GW -x M2: Presentation API Failure Response (446 - MarketChangeRequired)
      M2 ->> M2: Prompts user to consent to Market Move
      alt User Selects "Confirm"
        Note over M2: Calls separate Market Move endpoint
        M2 ->> GW: POST /v2/vehicles/{vin}/map request {Policy ID, Long VIN, OAuth Token}
        Note over GW: Oauth Flow
        Note over GW, FG: Map Vehicle Flow
      else User Selects "Cancel"
        Note over M2: User cancels - END
      end
    else Failure (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Mapping Request Succeeds
      FG ->> CDP: Response from FG (200 - OK, marketChangeRequired == false)
      CDP ->> Presentation: Response from CDP (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from CDP)
      GW -x M2: Presentation API Success Response
    end
</div>

### Remove Vehicle Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant FG
    M2 ->> GW: DELETE /v1/vehicles/{vin} request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch DELETE /v1/vehicles/{vin} request {Long VIN, USID / GCID}
    Presentation ->> CDP: Dispatch DELETE /mapVehicle request
    CDP ->> FG: Dispatch DELETE /me/mapping/v1/{vin} request
    alt Delete Vehicle Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Delete Vehicle Succeeds
      FG ->> CDP: Response from FG
      CDP ->> Presentation: Response from CDP (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from CDP)
      GW -x M2: Presentation API Success Response
    end
</div>

### Check Mappable Flow (Handled by Add Vehicle Internally)

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant FG
    M2 ->> GW: POST /v2/vehicles/{vin} request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v2/vehicles/{vin} request {Long VIN, USID / GCID}
    Presentation ->> CDP: Dispatch GET /v3/motorists/{usid}/vehicles/{vin}/mappable request
    CDP ->> FG: Dispatch GET /me/mapping/v1/{vin}/preconditions request
    alt Check Preconditions Fails (MarketChangeRequired)
      FG ->> CDP: Response from FG (200 - OK, marketChangeRequired == true)
      CDP ->> Presentation: Response from CDP (200 - OK, marketChangeRequired == true)
      Presentation ->> GW: Presentation API Failure Response (446 - MarketChangeRequired)
      GW -x M2: Presentation API Failure Response (446 - MarketChangeRequired)
      M2 ->> M2: Prompts user to change the vehicle's market
      alt User Selects "Confirm"
        Note over M2: Calls separate Market Move endpoint
        M2 ->> GW: POST /v2/vehicles/{vin}/map request {Policy ID, Long VIN, OAuth Token}
        Note over GW: Oauth Flow
        Note over GW, FG: Map Vehicle Flow
      else User Selects "Cancel"
        Note over M2: User cancels - END
      end
    else Failure (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Check Preconditions Succeeds
      FG ->> CDP: Response from FG
      CDP ->> Presentation: Response from CDP (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from CDP)
      GW -x M2: Presentation API Success Response
    end
</div>

### Validate Security Code Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant FG
    M2 ->> GW: POST /v1/vehicles/{vin}/validate-security-code request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v1/vehicles/{vin}/validate-security-code request {Long VIN, USID / GCID}
    Presentation ->> CDP: Dispatch POST /confirmToken request
    CDP ->> FG: Dispatch POST /me/mapping/v1/{vin}/token request
    alt Validate Security Code Fails (expired token / exceeds max retry count)
      Note over M2, FG: Informs user to Reset Security Code
    else Validate Security Code Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Validate Security Code Succeeds
      FG ->> CDP: Response from FG
      CDP ->> Presentation: Response from CDP (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from CDP)
      GW -x M2: Presentation API Success Response
    end
</div>

### Reset Security Code Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant CDP as Connected Drive Portal
    participant FG
    M2 ->> GW: POST /v1/vehicles/{brand}/{vin}/resend-security-code request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v1/vehicles/{brand}/{vin}/resend-security-code request {Long VIN, USID / GCID}
    Presentation ->> CDP: Dispatch POST /resendToken request
    CDP ->> FG: Dispatch POST /me/mapping/v1/{vin}/resend request
    alt Reset Token Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Reset Token Succeeds
      FG ->> CDP: Response from FG
      CDP ->> Presentation: Response from CDP (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from CDP)
      GW -x M2: Presentation API Success Response
      Note over M2: Informs user to check vehicle for new security token
    end
</div>

### Market Move

When users try mapping a vehicle from a different country than their account, they'll be prompted to give consent to do this. This is indicated as an error returned during the **Check Mappable** step.  We have created a separate endpoint, POST v2/vehicles/{vin}/map, which bypasses the Check Mappable step to save resources (by the time we've received an indication that market move is required, check mappable has already succeeded).

Per legal's requirements, we do have to prompt users.  Only primary mapping is allowed, so we should fail any **Secondary** mapping request that would require a market move (as this would change the vehicle's country without the primary driver's consent).

## Technology Choices

- Node: Given the team's experience, we believe using JS technologies is the best choice for this project
