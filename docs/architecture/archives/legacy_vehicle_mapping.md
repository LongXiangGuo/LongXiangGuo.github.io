---
layout: default
title: Legacy Vehicle Mapping (Mobile 1.0)
parent: Archives
nav_order: 1
grand_parent: Architecture
---

# Legacy Vehicle Mapping (Mobile 1.0)

{: .no_toc }

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

## Mobile 1.0 Vehicle Mapping Phases

<div class="mermaid">
  graph LR
    enterVin[Enter VIN] --> mapVehicle[Map Vehicle]
    mapVehicle[Map Vehicle] -.-> completeProfile[Complete Profile]
    mapVehicle[Map Vehicle] --> codeConfirmation[Code Confirmation]
    codeConfirmation[Code Confirmation] -.-> resendCode[Resend Code]
    resendCode[Resend Code] --> codeConfirmation[Code Confirmation]
    completeProfile[Complete Profile] --> codeConfirmation[Code Confirmation]
    codeConfirmation --> exit
</div>

### Enter VIN / Check Mappable

This phase is where the user would introduce the VIN that wants to associate to his/her account. There are two ways of doing this:

- Manual input, by typing the last 7 digits.
- If an A4A connection is active, it can be retrieved from the vehicle.

Once the VIN has been entered, it will be sent to the backend to see if the vehicle is "mappable"; this means, if it can be associated with the user's account. If yes, the user is taken to the **Map Vehicle** phase. The response given by the backend will determine if the _profile of the user is valid_, or if a _market change_ is needed for this vehicle.

If the vehicle is not mappable (old vehicles, or simply vehicles without mapping/LSC capabilities), then the backend will respond with an error.

### Map Vehicle

In this step, the user will see the vehicle image and model, so they can verify it is the correct vehicle. They will be also prompt to select a role (primary or secondary) if they are in the North America market. If the vehicle needs a market change, it can be adjusted here too (a market change might have been indicated in the previous _Enter VIN_ step).
Once this is done, a request to the backend will be made to link the account and the vehicle.

- If the **profile on Enter VIN was valid:** the user will be taken to the **Code Confirmation** screen.
- If the **profile on Enter VIN was invalid:** the user will be taken to the **Complete Profile** screen.

### Complete Profile

In this screen, the user will be asked to complete profile fields that are missed, such as phone number, address, first and last name...

Once the fields have been entered and successfully synced with the backend, the user will be taken to the **Code Confirmation** screen.

If address failed, it'll give an address suggestion (if possible). Basically, we display whatever error the backend gives us, which includes:

- There's already an active account with the same name and address ("Richard", "Ricky", "Dick", "Rich" would all be considered the same first name, by the way)
- Network error.

Essentially we'd be stuck on this screen until the user can correct the issue (unless it's a backend issue)

### Code Confirmation

This is the step where the user confirms that they have physical access to the vehicle requested, and therefore we can safely establish a relationship between the vehicle and the user in the backend. To demonstrate this, a message will be sent to the vehicle's ConnectedDrive message inbox with a code. This code has a certain expiration. If the code is entered in the app before the code expires, and successfully synced with the backend, then we can consider the vehicle mapping process completed.

### Resend Code

There's 2 scenarios where the code is invalidated. In these cases, the user will need to start over, or request a new code:

1. After 4 hours, the code will expire
2. If the user enters the code incorrectly 3 times, the code will be invalidated

After executing a **resend code** request, the user can once again attempt a **code confirmation** to proceed with mapping their vehicle.

### Other 1.0 Vehicle Mapping Processes

#### Delete Mapped Vehicle

In the Mobile 1.0 client or BMW portal, customers today can delete a vehicle from their account. We will still be supporting this functionality in the Mobile 2.0 client.

This "un-mapping" process uses the same backend url as add vehicle, but using a **DELETE** method instead of **POST**.

#### Market Move

In the Mobile 1.0 client or BMW portal, customers today are prompted to change a vehicle's market when adding it to their account, if the vehicle was provisioned for a different country than the user's account. We will still be supporting this functionality in the Mobile 2.0 client.

## Explorations from [1.0 Vehicle Mapping Backend Investigation](https://suus0002.w10:8080/browse/MOB-736)

For future reference, please check out the [CDP Swagger Docs](https://tst-b2vii.muc:9650/cdp/rest/swagger-ui/index.html)

By the way, all of the FG error statuses you see below are given on a 200... This is the infamous **FG 200 Failures**. They are converted to a **400** in the Core Vehicle Service.

## Vehicle Mapping Edge-Cases in Mobile 1.0

### 1.0 Map Vehicle Errors

In Mobile 1.0, **Map Vehicle** can return any of the following error messages. These 400 errors are directly from GCDM, served back via the Mobile 1.0 Vehicle Service backend:

- EXISTS
- FAILURE // error is also mapped to HTTP 500 message
- NOTMYINFO
- NOTMYINFOPDF // error is mapped to the same error message as NOTMYINFO
- NOTMYINFO_COMPLIANT
- ANOTHER_RELATIONSHIP_ORDER_IN_PROGRESS
- CUSTOMER_DOES_NOT_EXIST
- BU_CHANGE_NOT_ALLOWED
- MAPPING_DISABLED
- WAIVED
- FLEET_VEHICLE
- NOT_ALLOWED_TO_CREATE_SECONDARY
- BACKEND_SYSTEM_DOWN_NO_USER_ACTION
- BACKEND_SYSTEM_DOWN_USER_ACTION // error is also mapped to HTTP 500 message
- SAVING_LICENSE_PLATE_FAILED
- NO_ADDRESS_AVAILABLE

Errors Custom to Vehicle Service:

- VEHICLE_NOT_BMW // error is also mapped to missing VIN message
- ERROR_INVALID_SHORT_VIN
- ERROR_MAP_VEHICLE_MAPPING_FAILURE
- ERROR_MAP_VEHICLE_MISSING_PARAMETERS
- ERROR_MAP_VEHICLE_PROFILE_VALIDATION_FAILURE
- ERROR_MAP_VEHICLE_MISSING_ATTRIBUTE
- NOTFOUND // 404 response from backend

As you can tell, this is a ton of error cases. Sometimes the client will need custom UX around these failures - e.g., EXISTS means it's already mapped to your account, and clicking 'OK' we may want to dismiss all Vehicle Mapping screens.

Even on a 200 response, there are GCDM's infamous **200 errors** we need to contend with. For instance, **Map Vehicle** also has these error scenarios even with a successful response:

- **isValidUserProfile == false**
  - This means the user still needs to update their profile
- **isMarketChange == true**
  - This means the vehicle and user's account are provisioned for different countries
  - In order to proceed, there's custom handling required to change a vehicle's market
- **mappingType**
  - If the mapping type is **dongle**, we'd proceed with dongle-mapping

### 1.0 Delete Vehicle Errors

Same as 1.0 Map Vehicle Errors besides it doesn't have its Vehicle Service errors. However, there is a new error code from FG:

- CUSTOMER_DOES_NOT_EXIST // customer information could not be found

Delete Vehicle also does not these calls-to-action from Map Vehicle:

- Market Move
- Update User Profile
- Dongle Mapping Type

### 1.0 Check Mappable Errors

Same as 1.0 Map Vehicle Errors besides the custom Vehicle Service errors:

- ERROR_PRECONDITION_FAILURE_USER // VIN isn't mappable
- ERROR_POLICY_FAILURE_USER // VIN isn't mappable

Check Mappable also does not these calls-to-action from Map Vehicle:

- Market Move
- Update User Profile
- Dongle Mapping Type

### 1.0 Confirm Token Errors

Errors from GCDM:

- SECURITYTOKEN_NOT_MATCHING
- MAX_RETRY_COUNT_EXCEEDED
- SECURITY_TOKEN_EXPIRED
- SECURITY_TOKEN_INCORRECT_KNOWN_TOKEN_EXPIRED // same as SECURITY_TOKEN_EXPIRED
- RELATIONSHIP_NOT_EXISTS_FOR_VIN_GCID // default error message
- RELATIONSHIP_CANNOT_BE_CONFIRMED // default error message

Errors from Vehicle Service:

- MAPPING_STATUS_UNKNOWN // An unknown error has occurred, please try again later

### 1.0 Resend Token Errors

The only errors are 400 (wrong parameters), 403, 404, 500, 503, and 200 - Failure
