---
layout: default
title: PIN & Biometric Authentication
parent: User
nav_order: 2
grand_parent: Architecture
---

# PIN and Biometrics authentication

Authentication via PIN (Personal Identification Number) or Biometrics (Fingerprint/Face recognition) adds an extra security layer for the user. 

It is used to validate that a user is "who they truly say they are" at any point in time, regardless of the username/password introduced at login, it is used to perform some critical actions, such as remote unlock, and it is also used to authenticate on many other devices seamlessly, such as Amazon Alexa.

## Libraries needed

In our Flutter project, we will use:

* [local_auth](https://pub.dartlang.org/packages/local_auth) to control all the biometric sensors
* [flutter_secure_storage](https://pub.dartlang.org/packages/flutter_secure_storage) to save the PIN locally

## PIN Rules

* PIN numbers are 4 digit numbers
* Only digits(numbers) are allowed

## User flows

![pin and biometrics]({{site.baseurl}}/assets/images/pin_and_biometrics.png)

The idea is to create a `PinWithBiometrics` widget (or similar), where the only public APIs represent the stages listed in the picture. It will look similar to:

* CREATE: `PinWithBiometrics.create()`
* EDIT/RESET: `PinWithBiometrics.reset()`
* VALIDATE-FULLSCREEN: `PinWithBiometrics.validate(resultCallback)`
* VALIDATE-CUSTOM-UI: `PinWithBiometrics.customUiValidation(icon, text, resultCallback)`

### When and where PIN/Biometrics needs to be displayed

* **After successful login:** present the `CREATE` stage
* **After being authenticated and opening the app:** present the `VALIDATE.FULLSCREEN` stage
* **From the profile:** here the user will have the option of changing their PIN, and biometric settings: `EDIT/RESET`
* **From any other part of the app where PIN is necessary:** use `VALIDATE.CUSTOM_UI`