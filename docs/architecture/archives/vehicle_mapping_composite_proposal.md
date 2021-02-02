---
layout: default
title: Vehicle Mapping Composite Service Proposal
parent: Archives
nav_order: 2
grand_parent: Architecture
---

# Vehicle Mapping Composite Service Proposal

{: .no_toc }

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

## Proposal for a Vehicle Mapping Presentation Microservice

The proposal is to create a new microservice just dedicated to vehicle mapping.

This microservice will handle these API requests:

- **Add Vehicle**
- **Remove Vehicle**
- **Validate Security Code**

The largest difference will be providing a simpler interface for error cases than in the Mobile 1.0 client. For each API, we'll utilize appropriate response codes (e.g., instead of `400 - NOT_FOUND`, we will return a `404` and let the client decide what to do). Additionally, we will only use the long VIN to ensure that we won't encounter the short VIN collision as per the 1.0 client. This will drastically reduce complexity in the client, and streamline the amount of required user actions (e.g., on a short VIN collision, users have to enter the long VIN).

For typical **BAD REQUEST** responses, we'll provide a sanitized enumeration of errors. The benefits are two-fold:

1. Improved robustness & flexibility
   - We can respond to breaking changes in FG's APIs and adjust the Vehicle Mapping Microservice so the client will still work properly
   - API versioning will also grant us flexibility
2. Less complexity in the client
   - This will break the 1-to-1 dependency between the client's and FG's implementation
   - Utilizing these presentation APIs, we can drive the user-facing messages shown in the Mobile 2.0 client

## Brief Overview of Mobile 2.0 Vehicle Mapping Process

1. Check Mappable
   - **In Mobile 2.0, this will be handled in the backend as part of Add Vehicle**
   - See if the vehicle can be added to your account
2. (**Optional**) Market Move
   - **This is not an API, we are just required to ask users for consent before proceeding**
   - Users can move the vehicle from its original country to their country (common R.o.W. use-case)
   - This is only available if the vehicle was provisioned for another country than the user's account
   - It only works if the vehicle can be moved to the new country
     - Otherwise you'll receive the error `400 - BU_CHANGE_NOT_ALLOWED` in the **Map Vehicle** phase
3. Add Vehicle
   - Add a vehicle to your account
   - The vehicle mapping process will be in a "Pending" state until the next step
4. Validate Security Code
   - Users need to input the security code sent to their head unit
   - If successful, the mapping will be done here, although it will take minutes / hours for this to be reflected across FG's databases
   - Else:
     - After 4 hours, this code expires and the next step is necessary
     - After sending an incorrect code 3 times, the code also expires and the next step is necessary
5. (**Optional**) Reset Security Code
   - **In Mobile 2.0, this will be handled in the backend as part of Validate Security Code**
     - This scenario will cause a **400** response informing the user to check their vehicle for the new security code
   - Prompts FG to send a new security code to the vehicle
   - After this happens, the user can proceed back to the previous step

## System Diagram - Including _New_ Composite Vehicle Mapping Service

The new Composite Service for Vehicle Mapping will be a **Presentation API** for the Mobile 2.0 client. Like our other composite backends, it will support [standard backend mocking practices](../../core/mock_vs_live_api).

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
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
    Presentation ->>+ Core: Dispatch vehicle request {Long VIN, USID / GCID}
    Core ->>+ FG: Dispatch vehicle request {Long VIN, GCID}
    activate FG
    alt FG Request Fails
      Note over M2, FG: Sends failure back to client
    else FG Request Succeeds
      FG ->> Core: Response from FG
    end
    deactivate FG
    Core ->>- Presentation: Response from Core (Parses response from FG)
    Presentation ->>- GW: Presentation API Response (Parses response from Core)
    GW -x M2: Presentation API Response
    deactivate GW
</div>

Most requests will follow this format, as all of the proposed APIs require a VIN. However, some of the use-cases, errors, edge-cases, etc. will differ slightly.

## Vehicle Mapping API Proposals

### Add Vehicle API

It's crucial to our application for users to be able to add a vehicle to their account.

Regional differences:

- In NA, a user can select to be the main ("Primary") driver, or a "Secondary" driver of the vehicle
- In ROW there's no choice, a user must select "Primary"

Here's a brief overview of the mapping process:

#### Proposal for Add Vehicle API

- Presentation API signature
  - `POST {vehicle-mapping-service.baseUrl}/v1/vehicles/{vin}`
- Request body

  - NA

    ```json
    {
      "subscriberStatus": "Primary" / "Secondary"
    }
    ```

  - ROW (only "Primary" is supported)

    ```json
    {
      "subscriberStatus": "Primary"
    }
    ```

- Dependencies
  - `POST {vehicleService.baseUrl}/mapVehicle`

#### Add Vehicle Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
    participant FG
    M2 ->> GW: POST /v1/vehicles/{vin} request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v1/vehicles/{vin} request {Long VIN, USID / GCID}
    Note over Presentation, FG: Check Mappable Flow
    alt Check Mappable Failure
      Note over M2, Presentation: Sends failure back to client - END
    else Check Mappable Success
      Note over Presentation: Continue
    end
    Presentation ->> Core: Dispatch POST /mapVehicle request {Long VIN, USID / GCID}
    Core ->> FG: Dispatch POST /me/mapping/v1/{vin} request {Long VIN, GCID}
    alt Failure (MissingUserProfile)
      FG ->> Core: Response from FG (isValidUserProfile == false)
      Core ->> Presentation: Response from Core (isValidUserProfile == false)
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
    else Failure (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Mapping Request Succeeds
      FG ->> Core: Response from FG (isMarketChange == false)
      Core ->> Presentation: Response from Core (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from Core)
      GW -x M2: Presentation API Success Response
    end
</div>

#### Proposed Add Vehicle Errors

- User action required, actionable errors:

| Composite Service Error | From - FG / Vehicle Service Error(s) |               Description                |
| :---------------------: | :----------------------------------: | :--------------------------------------: |
| MissingUserProfile      | _isValidUserProfile == false_        | _User needs to update their CDP profile_ |

- User action required, actionable errors, but **not yet supported** (documenting for posterity's sake):

| Composite Service Error | From - FG / Vehicle Service Error(s) |                    Description                     |
| :---------------------: | :----------------------------------: | :------------------------------------------------: |
| DongleMappingRequired   | _mappingType == MappingType.dongle_  | _User needs to go through the Dongle mapping flow_ |

- User can't recover - non-actionable errors (400 unless otherwise-specified):

|  Composite Service Error  |                From - FG / Vehicle Service Error(s)                 |                                                     Description                                                      |
| :-----------------------: | :-----------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: |
| MissingCDSubscription     | NOTMYINFO, NOTMYINFOPDF, NOTMYINFO_COMPLIANT                        | "You need a ConnectedDrive subscription for this vehicle to add it to your account. Please contact Customer Support" |
| MappingInProgress         | MAPPING_DISABLED                                                    | "This vehicle is already being added to your account"                                                                |
| AnotherMappingInProgress  | ANOTHER_RELATIONSHIP_ORDER_IN_PROGRESS                              | "You cannot add more than one vehicle at a time, please try again later"                                             |
| IncorrectBrand            | VEHICLE_NOT_BMW                                                     | (_Branded message_) "You cannot add a MINI in BMW Connected"                                                         |
| IncorrectMarket           | BU_CHANGE_NOT_ALLOWED                                               | "This vehicle isn't provisioned for your country"                                                                    |
| InvalidCustomer           | CUSTOMER_DOES_NOT_EXIST                                             | "We couldn't find information for your account"                                                                      |
| DeactivatedCDSubscription | WAIVED                                                              | "You cannot add this vehicle because its mobile connection has been deactivated"                                     |
| AlreadyMapped             | EXISTS                                                              | "This vehicle is already added to this account"                                                                      |
| SecondaryUserNotAllowed   | NOT_ALLOWED_TO_CREATE_SECONDARY_USER                                | "You can't add a secondary user to this vehicle"                                                                     |
| CantAddFleetVehicle       | FLEET_VEHICLE                                                       | "You can't add a fleet vehicle to this account"                                                                      |
| SecondaryMarketChange     | _secondary mapping should fail when market change is required_      | "In order to map this vehicle to your account, please select \"Primary\" driver"                                     |
| DownForMaintenance        | BACKEND_SYSTEM_DOWN_NO_USER_ACTION, BACKEND_SYSTEM_DOWN_USER_ACTION | "Due to maintenance, the CDP website is down. Please try again later"                                                |
| 403 - Forbidden           | 403                                                                 | "You don't have permission to add this vehicle"                                                                      |
| 404 - Not Found           | 404, NOTFOUND                                                       | "We were not able to find information about this vehicle"                                                            |
| Default                   | 500, 503, _missing parameters, profile validation failed, default_  | "An error occurred, please try again later or contact Customer Support"                                              |
| (more Default)            | SAVING_LICENSE_PLATE_FAILED, NO_ADDRESS_AVAILABLE                   | (same)                                                                                                               |

### Remove Vehicle API

Since users can add vehicles to their account, we also provide them the option to remove the vehicle from their account.

#### Proposal for Remove Vehicle API

- Presentation API signature

  - `DELETE {vehicle-mapping-service.baseUrl}/v1/vehicles/{vin}`

- Dependencies
  - `DELETE {vehicleService.baseUrl}/mapVehicle`

#### Remove Vehicle Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
    participant FG
    M2 ->> GW: DELETE /v1/vehicles/{vin} request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch DELETE /v1/vehicles/{vin} request {Long VIN, USID / GCID}
    Presentation ->> Core: Dispatch DELETE /mapVehicle request
    Core ->> FG: Dispatch DELETE /me/mapping/v1/{vin} request
    alt Delete Vehicle Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Delete Vehicle Succeeds
      FG ->> Core: Response from FG
      Core ->> Presentation: Response from Core (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from Core)
      GW -x M2: Presentation API Success Response
    end
</div>

#### Proposed Remove Vehicle Errors

- User action required, actionable errors:

  - **N/A**

- User can't recover - non-actionable errors (400 unless otherwise-specified):

| Composite Service Error |                From - FG / Vehicle Service Error(s)                 |                                 Description                                 |
| :---------------------: | :-----------------------------------------------------------------: | :-------------------------------------------------------------------------: |
| AnotherDeleteInProgress | ANOTHER_RELATIONSHIP_ORDER_IN_PROGRESS                              | "You cannot delete more than one vehicle at a time, please try again later" |
| InvalidVehicle          | RELATIONSHIP_NOT_EXISTS_FOR_VIN_GCID                                | "This vehicle is not mapped to your account"                                |
| DownForMaintenance      | BACKEND_SYSTEM_DOWN_NO_USER_ACTION, BACKEND_SYSTEM_DOWN_USER_ACTION | "Due to maintenance, the CDP website is down. Please try again later"       |
| 403 - Forbidden         | 403                                                                 | "You don't have permission to delete this vehicle"                          |
| 404 - Not Found         | 404, NOTFOUND                                                       | "We were not able to find information about this vehicle"                   |
| Default                 | 500, 503, _default_                                                 | "An error occurred, please try again later or contact Customer Support"     |

### Check Mappable API (Handled Internally in the Backend)

Users need to be able to check if they can add a vehicle to their account.

#### Proposal for Check Mappable API

- Presentation API signature
  - **This happens behind the scenes during Add Vehicle**
- Dependencies
  - `GET {vehicleService.baseUrl}/v3/motorists/{usid}/vehicles/{longVin}/mappable`

#### Check Mappable Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
    participant FG
    M2 ->> GW: GET /v1/vehicles/{vin}/mappable request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch GET /v1/vehicles/{vin}/mappable request {Long VIN, USID / GCID}
    Presentation ->> Core: Dispatch GET /v3/motorists/{usid}/vehicles/{vin}/mappable request
    Core ->> FG: Dispatch GET /me/mapping/v1/{vin}/preconditions request
    alt Check Preconditions Fails (MarketChangeRequired)
      FG ->> Core: Response from FG (isMarketChange == true)
      Core ->> Presentation: Response from Core (isMarketChange == true)
      Presentation ->> GW: Presentation API Failure Response (400 - MarketChangeRequired)
      GW -x M2: Presentation API Failure Response (400 - MarketChangeRequired)
      M2 ->> M2: Prompts user to change the vehicle's market
      alt User Selects "Yes"
        Note over GW, FG: User moves onto "Map Vehicle" step
      else User Selects "No"
        Note over M2: User cancels - END
      end
    else Failure (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Check Preconditions Succeeds
      FG ->> Core: Response from FG
      Core ->> Presentation: Response from Core (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from Core)
      GW -x M2: Presentation API Success Response
    end
</div>

#### Proposed Check Mappable Errors (Returned during Add Vehicle)

- User action required, actionable errors:

| Composite Service Error | From - FG / Vehicle Service Error(s) |                       Description                        |
| :---------------------: | :----------------------------------: | :------------------------------------------------------: |
| MarketChangeRequired    | _isMarketChange == true_             | _User needs to consent to a market move for the vehicle_ |

- User can't recover - non-actionable errors (400 unless otherwise-specified):

|  Composite Service Error  |                From - FG / Vehicle Service Error(s)                 |                                                                        Description                                                                        |
| :-----------------------: | :-----------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------: |
| VinNotMappable            | PRECONDITION_FAILURE, POLICY_FAILURE                                | "This vehicle cannot be added to an account"                                                                                                              |
| MissingCDSubscription     | NOTMYINFO, NOTMYINFOPDF, NOTMYINFO_COMPLIANT                        | "You need a ConnectedDrive subscription for this vehicle to add it to your account"                                                                       |
| IncorrectBrand            | VEHICLE_NOT_BMW                                                     | (_Branded message_) "You cannot add a MINI in BMW Connected"                                                                                              |
| DeactivatedCDSubscription | WAIVED                                                              | "You cannot add this vehicle because its mobile connection has been deactivated"                                                                          |
| CantAddFleetVehicle       | FLEET_VEHICLE                                                       | "You can't add a fleet vehicle to this account"                                                                                                           |
| DownForMaintenance        | BACKEND_SYSTEM_DOWN_NO_USER_ACTION, BACKEND_SYSTEM_DOWN_USER_ACTION | "Due to maintenance, the CDP website is down. Please try again later"                                                                                     |
| 403 - Forbidden           | 403                                                                 | "You don't have permission to add this vehicle". According to FG, this may also mean the same as **BU_CHANGE_NOT_ALLOWED** during **Add Vehicle Mapping** |
| 404 - Not Found           | 404, NOTFOUND                                                       | "We were not able to find information about this vehicle"                                                                                                 |
| Default                   | 500, 503, _missing parameters, profile validation failed, default_  | "An error occurred, please try again later or contact Customer Support"                                                                                   |

### Validate Security Code API

#### Proposal for Validate Security Code API

- Presentation API signature
  - `POST {vehicle-mapping-service.baseUrl}/v1/vehicles/{vin}/validate-security-code`
- Request Body

  ```json
  {
    "securityCode": "string"
  }
  ```

- Dependencies
  - `POST {vehicleService.baseUrl}/confirmToken`

#### Validate Security Code Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
    participant FG
    M2 ->> GW: POST /v1/vehicles/{vin}/validate-security-code request {Long VIN, OAuth Token}
    Note over GW: Oauth Flow
    GW ->> Presentation: Dispatch POST /v1/vehicles/{vin}/validate-security-code request {Long VIN, USID / GCID}
    Presentation ->> Core: Dispatch POST /confirmToken request
    Core ->> FG: Dispatch POST /me/mapping/v1/{vin}/token request
    alt Validate Security Code Fails (expired token / exceeds max retry count)
      Note over M2, FG: Reset Security Code Flow
    else Validate Security Code Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Validate Security Code Succeeds
      FG ->> Core: Response from FG
      Core ->> Presentation: Response from Core (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from Core)
      GW -x M2: Presentation API Success Response
    end
</div>

#### Proposed Validate Security Code Errors

- User action required, actionable errors:

  - **N/A**

- User can't recover - non-actionable errors (400 unless otherwise-specified):

| Composite Service Error  |                  From - FG / Vehicle Service Error(s)                  |                                 Description                                 |
| :----------------------: | :--------------------------------------------------------------------: | :-------------------------------------------------------------------------: |
| IncorrectToken           | SECURITYTOKEN_NOT_MATCHING                                             | "The entered token was incorrect, please try again"                         |
| InvalidCustomer          | CUSTOMER_DOES_NOT_EXIST                                                | "We couldn't find information for your account"                             |
| InvalidVehicle           | VEHICLE_DOES_NOT_EXIST                                                 | "We couldn't find information for this vehicle"                             |
| AnotherMappingInProgress | ANOTHER_RELATIONSHIP_ORDER_IN_PROGRESS                                 | "You cannot add more than one vehicle at a time, please try again later"    |
| MappingInProgress        | MAPPING_DISABLED                                                       | "This vehicle is already being added to your account"                       |
| ExpiredToken             | SECURITY_TOKEN_EXPIRED, SECURITY_TOKEN_INCORRECT_KNOWN_TOKEN_EXPIRED   | "Your security token has expired, please tap "Reset Token" again"           |
| ExceededMaxRetries       | MAX_RETRY_COUNT_EXCEEDED                                               | "You've input a wrong token too many times, please tap "Reset Token" again" |
| DownForMaintenance       | BACKEND_SYSTEM_DOWN_NO_USER_ACTION, BACKEND_SYSTEM_DOWN_USER_ACTION    | "Due to maintenance, the CDP website is down. Please try again later"       |
| Unknown                  | MAPPING_STATUS_UNKNOWN                                                 | "An unknown error has occurred, please try again later"                     |
| 403 - Forbidden          | 403                                                                    | "You don't have permission to add this vehicle"                             |
| 404 - Not Found          | 404, NOTFOUND                                                          | "This vehicle doesn't appear to be in your account"                         |
| InvalidVehicle           | RELATIONSHIP_NOT_EXISTS_FOR_VIN_GCID, RELATIONSHIP_CANNOT_BE_CONFIRMED | "This vehicle cannot be added to an account"                                |
| Default                  | 500, 503, _default_                                                    | "An error occurred, please try again later or contact Customer Support"     |

### Reset Security Code API (Handled Internally in the Backend)

During Validate Security Code, if the security code is expired (ExpiredToken, ExceededMaxRetries) we should just handle this internally and inform the user to check their vehicle for a new security code. This will streamline the user experience and reduce client complexity.

There's a slight difference in the proposed name for this API. When it's called FG will send a security code to the vehicle, and it will always be a new code for security reasons. "_Resend_ code" is a misnomer since the code is different; "_Reset_ code" is a much more accurate depiction of the intent of this functionality.

#### Proposal for Reset Security Code API

- Presentation API signature
  - **This happens behind the scenes during Validate Security Code**
- Dependencies
  - `POST {vehicleService.baseUrl}/resendToken`

#### Reset Security Code Flow

<div class="mermaid">
  sequenceDiagram
    participant M2 as Mobile 2.0 Client
    participant GW as Gateway
    participant Presentation as Presentation API
    participant Core as Core Vehicle Service
    participant FG
    Note over M2, GW: Validate Security Token - Fails with ExpiredToken / ExceededMaxRetries
    Presentation ->> Core: Dispatch POST /resendToken request
    Core ->> FG: Dispatch POST /me/mapping/v1/{vin}/resend request
    alt Reset Token Fails (non-actionable error)
      Note over M2, FG: Sends failure back to client
    else Reset Token Succeeds
      FG ->> Core: Response from FG
      Core ->> Presentation: Response from Core (Parses response from FG)
      Presentation ->> GW: Presentation API Response (Parses response from Core)
      GW -x M2: Presentation API Success Response
      Note over M2: Informs user to check vehicle for new security token
    end
</div>

#### Proposed Reset Security Code Errors (Called by Validate Security Code)

- User action required, actionable errors:

  - **N/A**

- User can't recover - non-actionable errors (400 unless otherwise-specified):

| Composite Service Error |     From - FG / Vehicle Service Error(s)      |                               Description                               |
| :---------------------: | :-------------------------------------------: | :---------------------------------------------------------------------: |
| 403 - Forbidden         | 403                                           | "You don't have permission to add this vehicle"                         |
| 404 - Not Found         | NOTFOUND, 404                                 | "This vehicle doesn't appear to be in your account"                     |
| Default                 | 500, 503, 200 - Failure (oh, the humanity...) | "An error occurred, please try again later or contact Customer Support" |

### Market Move (No API Needed)

When users try mapping a vehicle from a different country than their account, they'll be prompted to give consent to do this. This is indicated as an error returned during the **Check Mappable** step.

Per legal's requirements, we don't have to prompt users on a **Primary** mapping, and we should fail any **Secondary** mapping request that would require a market move (as this would change the vehicle's country without the primary driver's consent).

## Technology Choices

- Node: Given the team's experience, we believe using JS technologies is the best choice for this project
