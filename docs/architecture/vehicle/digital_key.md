---
layout: default
title: Digital Key
parent: Vehicle
grand_parent: Architecture
nav_order: 12
---

# Digital Key (Smart Access 1.5)

-   [About Digital Key](#about-digital-key)
-   [Requirements](#requirements)
-   [SmAcc MicroService](#smacc-microservice)
-   [BFF](#bff)
-   [Mobile2 09/20 Release (Coming Soon Tile)](#mobile2-09-20)
-   [Mobile2 11/20 Release (Real Implementation)](#mobile2-11-20)

## About Digital Key

The BMW Digital Key is a replacement for your physical key. The DigitalKey feature allows users
to securely map their phone to their car. After pairing the user is able to unlock it using their
iPhone (Android is not supported at the moment) and start the engine.

### Links

-   Customer documentation [bmw.com/digitalkey](https://bmw.com/digitalkey)
-   [UX](https://atc.bmwgroup.net/confluence/x/3IMlI)

## Requirements

In order to create a DigitalKey the following is required:

-   vehicle
    -   SA “Teleservices” (SA 6AE) (not customer facing but rather included with MGU "Live Cockpit"
        (SA 6U1 / SA 6U2 / SA 6U3) (for F40 & F44 only with Live Cockpit Professional SA 6U3))
    -   SA "Comfort Access" (SA 322)
-   phone
    -   iPhone XR, XS or later (also iPhone SE 2020 is supported)
    -   iOS 13.6 or later

## SmAcc Microservice

Information from the BMW Backend is provided by the SmAcc Microservice at FG. Swagger and API for
that microservice can be found
[here](https://atc.bmwgroup.net/confluence/x/7eC1GQ).
While in mobile1 the app directly talked to the microservice (for details refer
[here](https://atc.bmwgroup.net/confluence/x/m0XZKw)),
in mobile2 this information is accessed via a [BFF](#bff).

## BFF

At the moment the BFF is only proxying the calls to the SmAcc Mircoservice.

-   BFF SourceCode: (https://code.connected.bmw/mobile20/digital-key-composite-service)
-   BFF Monitoring: (https://monitor.connected.bmw/d/nKBCQrHGk/digital-key-composite-service)

Documentation on the BFF can be found in the [README](https://code.connected.bmw/mobile20/digital-key-composite-service) file.

## Mobile2 (09-20)

In the Mobile2 09/20 release the feature is not included yet, but an advertising "coming soon" might be shown
depending on the selected vehicle. This release did not contain any further logic for creating DigitalKeys.

### Business Logic: "Coming Soon"

-   When the user's phone is on an unsupported platform (Android) the "coming soon" label is never shown.
-   Whenever a vehicle is selected and we do not have information in our cache if this vehicle supports SmAcc,
    we request this information from the BFF and store it in our cache for this VIN.
    If the result is that SmAcc is supported by this vehicle, then we show the "coming soon" label.
-   Whenever a vehicle is selected, we check in our local cache if we already know if this vehicle supports SmAcc.
    If this is the case, we show the "coming soon" tile.
-   As long as we do not have the information in our cache if the selected vehicle is supported, the
    "coming soon" tile is not shown.

## Mobile2 (11-20)

The mobile2 11/20 release adds the real implementation and brings the full owner pairing flow.

### VehicleTab

#### VehicleTab - EntryButton appearance

On the vehicle tab, the EntryButton to the feature flow might be added to the carousel.
The DigitalKey does not rely on RemoteServices being activated by the user, this means that the
following rules apply for both vehicle pages:
(a) Vehicle page with RemoteServices enabled
(b) Vehicle page with RemoteServices not enabled
The rules for showing or not showing the EntryButton are:

-   When the user's phone is on an unsupported platform (Android) the "coming soon" label is never shown.
-   Whenever a vehicle is selected and we do not have information in our cache if this vehicle supports SmAcc,
    we request this information from the BFF and store it in our cache for this VIN.
    If the result is that SmAcc is supported by this vehicle, then we show the "coming soon" label.
-   Whenever a vehicle is selected, we check in our local cache if we already know if this vehicle supports SmAcc.
    If this is the case, we show the "Coming soon" tile.
-   As long as we do not have the information in our cache if the selected vehicle is supported, the
    "coming soon" tile is not shown.

#### VehicleTab - EntryButton tapped

Depending on the information we have of an existing car key the EntryButton behaves differently:

-   When we have the information cached that an owner key exists for the current vehicle on this phone, we verify
    this information by asking the wallet if this is still the case. When the wallet verifies that the key is still
    on this phone, the tap routes directly to the Overview page.
-   In all other cases (like no information or key created but not on this phone) we need fresh data from the
    backend and thus navigate to the WelcomePage

### WelcomePage

#### WelcomePage - Page shown actions

-   When the WelcomePage is shown we fetch the PairingStatus from the BFF:
    If the fetch is successful the result is stored in the cache, otherwise we remember that this fetch failed.
-   When an owner key exists for this vehicle, we also check if this key is stored in the current device.
    This information is also stored in the cache.
-   When the WelcomePage is shown we fetch the PairingPassword from the BFF:
    Whenever this fetch is successful the password is stored in the cache and the passwordUsageCounter is set to 0.

#### WelcomePage - ContinueButton appearance

-   When the page is shown, the ContinueButton on the Welcome page is disabled
-   When the PairingInformation network request is done (regardless of the outcome of it) the button is enabled

#### WelcomePage - ContinueButton tapped

Depending on the information we have from the recent keyStatus request and the user's phone, the action of
the ContinueButton differs:

-   When the pairingStatus network request failed, tapping leads to a "Backend Error" page
-   When the pairingStatus request was successful:
    -   If we know that an ownerKey exists for this vehicle and we are not in a "Move-to-this-Device-Flow", open the _OverviewPage_
    -   Else-If user's phone is not supported, tapping leads to a "Phone not supported" error message.
    -   Else-If user's phone iOS version is too old or Apple API tells us that DigitalKey creation
        is not supported (e.g. because the user does not have an iCloud account), tapping leads
        to a "Phone Software Update required" error message.
    -   Else-If user is not the primary subscriber (primary user of the ConnectedDrive account),
        tapping leads to a "not primary subscriber" error message
    -   Else-If the cache tells us that vehiclePreparation is not done, i.e. vehicle is not prepared,
        we show an error message that hints the user that a general error exists and they should retry later.
    -   Else-If we have no PairingPassword in the cache or the passwordUsageCounter is >= 3 than we show
        an error message that the user should retry later as pairing is not possible without a pairing password.
    -   Else route to _GrabYourTwoKeysPage_

### GrabYourTwoKeysPage

-   Continue button is always activated
-   Tapping the continue button leads to the _ReadyToPairPage_

### ReadyToPairPage

-   Checkbox is unchecked initially
-   Continue button is always enabled
-   Depending on the state of the checkbox, tapping on the Continue Button does the following
    -   Checkbox unchecked: Visually highlight that the user has to check the checkbox
    -   Checkbox checked: Start the pairing by calling the Apple API to initiate pairing with
        the PairingPassword currently stored in the cache and increase the passwordUsedCounter
        in the cache by 1.

### Callback from Apple startPairing() API

-   Success (PKPass and no error): Store the DigitalKeyID in the cache, route to the _Tutorial1Page_
-   Error (No PKPass and error):
    -   Try to refresh the pairing password, i.e. initiate an async network request to fetch the
        pairing password from the BFF. Whenever this is successful store the new pairingPassword
        in the cache and reset the passwordUsedCounter to 0.
    -   Route to _PairingErrorPage_
-   Still TBD: What should happen when we get a PKPass and an error (e.g. because DigitalKey
    was created but sharing with watch failed). For now: Whenever we get a PKPass this is
    handled as a success for us (even if it includes an error)

### PairingErrorPage

-   When the user closes the page, leave the digital key flow and go back to the vehicle page
-   When the user presses retry:
    -   If the current passwordUsedCounter is less than 3, start the pairing by calling the
        Apple API to initiate pairing with the PairingPassword currently stored in the cache
        and increase the passwordUsedCounter in the cache by 1.
    -   Else show an ErrorMessage like GenericError but without the possibility to press retry.
        All actions on this error page will terminate the pairing flow and lead the user back
        to the vehicle page.

### Tutorial1Page

-   Continue Button is always enabled, tapping it routes to _Tutorial2Page_

### Tutorial2Page

-   Continue Button is always activated, tapping it routes to _OverviewPage_

### OverviewPage

-   When the page ist loaded it stores the current state of the key in order to detect key deletion
    while the app was in background.
-   Whenever the app loses focus (e.g. when the Home button is pressed or user switches to wallet) and then
    regains focus, it verifies if the previous keyState was a local one (active-tracked or active-untracked)
    and in these cases verifies that this key still exists in the wallet.
    If this is not the case, then it was deleted and an error message telling the user that the key was deleted
    is shown. Confirming this message will terminate the SmAcc-Flow and put the user back to the vehicle page.
-   **Untracked keys**: When the DigitalKey is on this device but is not tracked at the moment, the card looks
    a bit different and highlights that this key can't unlock the door nor start the engine.
-   **Card action**: When the key exists on the current device, the card has a button that allows the user to
    open the wallet app with the current DigitalKey (_Edit in Wallet_), so tapping the button opens the Wallet
    App. Otherwise the button allows the user to move the key to this device, tapping the button
    opens the _MoveKeyWarningPage_.
-   **Tutorial**: User can see the tutorial pages again. Tapping on the button opens _Tutorial1Page_.
-   **More Information Link**: The user can click on the link https://bmw.com/digitalkey to get further information.

### MoveKeyWarningPage

-   Informs the user that proceeding with the following steps will enable him to create a digital Key
    for this phone, but this will disable the currently existing digital key.
-   When the user cancels, this brings them back to the _OverviewPage_.
-   When the user confirms, the BusinessLogic (BLOC) will know that we are now in the "Move-to-this-Device"-Flow and the _WelcomePage_ is shown, where a new OwnerPairing can be started.
