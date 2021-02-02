---
layout: default
title: Create Account
parent: User
nav_order: 4
grand_parent: Architecture
---

{: .no_toc }

## Table of Contents

{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Create Account

## Overview

Create Account is a feature module that does the following:
- Present the user with a screen that allows them to input their personal information required to create an account
- Validate that all data input adheres to validation rules defined in the backend (user-composite-service)
- Communicate this account information to the backend BFF (user-composite-service) which sends it along to GCDM for creating the account and sending an email for the user to activate their account.
- Provide the user an ability to resend the confirmation email in the event they don't receive it

The feature utilizes the user-composite-service BFF to communicate this information to the GCDM core services for account creation and communication of account activation.  The user-composite service will extract the brand information from the User Agent header such that the country, language (provided in the account information) and client identifier (derived from the extracted brand) can be sent in the POST request to GCDM.  The GCDM services will use this information to send the account activation email with the correct language and branding as well as the resulting landing page that the user will be taken to when they activate their account.

## Client Architecture

The Create Account feature module is made up of the following components:

<img src="{{site.baseurl}}/assets/images/user/create_account/create_account_client_arch.png">

The Profile Form:
- prompts the user to input their personal information
- indicates if the form loaded successfully or not
- provides the user the ability to submit their account information
- is composed of several widgets that reflect the input fields and drop downs required to complete the profile form
- is driven by the Profile Form Bloc and Resend Confirmation Email Bloc

The Profile Form Bloc:
- tracks if the profile form successfully loaded or not.  This is important as the fields and rules behind those fields are kept in the backend so a network error could cause the form to not load
- drives the state of the widgets that represent the input fields and drop downs that makeup the profile form through state properties. For example, the UsernameSelection widget shows or hides the red error text indicating the email format is invalid based on the Profile Form Bloc emitting a state that has a username property with a sub-property, 'isUsernameValid' indicating if that field is in a valid state or not 
- Executes RegEx Validation where applicable
- Executes general form field validation
- Submits validated account information to UserRepository

The Resend Confirmation Email Bloc:
- Handles the tap event of resend confirmation email button which calls into UserRepository to communicate to the backend for resending the confirmation email

The User Repository utilizes the UserApiClient to:
- Get the Profile Form structure from the user-composite-service
- POST the validated account information to the user-composite-service for forwarding to the GCDM service that will handle account create and send the account activation email
- POST the email address to resend the confirmation email to the user-composite-service for forwarding to GCDM service

## Backend Architecture

<img src="{{site.baseurl}}/assets/images/user/create_account/create_account_backend_arch.png">

The user-composite-service:
- Returns all form fields and regex if applicable for profile form
- Receives validated create account information and extracts brand from User Agent
- Passes account information and brand to the Customers API Library
- Passes email address to Customers API Library for pass thru to GCDM

The Customers API Library:
- Build country-language URL parameter from account information
- Set client identifier (mybmwapp, myminiapp) based on brand
- Post account information to GCDM service for account create
- Post email address to GCDM service for resend confirmation email
  
## Prior Documentation

### What is Create Account?

**Create Account** is the process that a customer, or a dealer on behalf of a customer, will create a user's account. This account will be confirmed on BMW's backend, so if a user switches between different devices (or between mobile and web) it will still be the exact same account. The same customer information and vehicles associated with the account should be available.

The create account process can be executed from:

* The Connected Drive Portal (CDP)
* All variants of the Connected mobile application (Mobile 2.0, Mobile 1.0, Connected Classic)

### Client Create Account API Flow

<div class="mermaid">
  graph LR
    loginScreen[Login Screen]
    createAccount[Create Account]
    resendEmail[Resend Email]
    app[App]

    loginScreen -.->|new user| createAccount
    createAccount --> loginScreen

    loginScreen -.->|didn't receive validation email| resendEmail
    resendEmail --> loginScreen

    loginScreen -->|successful login| app
    app -->|logout| loginScreen
</div>

### Create Account Feature Flow

![create account feature flow]({{site.baseurl}}/assets/images/user/create_account/create_account_flow.png)

### Proposal for Mobile 2.0 Create Account API & Error-Handling

Please see the official [User Composite Service Swagger](https://btcnadly.centralus.cloudapp.azure.com/svc/user-composite-service/docs/#/Users/post_api_v1_presentation_users_account).

The errors returned on a **400** response are a simplification of the error-handling in the 1.0 client. This will help to keep the client lean and drastically reduce feature complexity.

## Research From the [MOB-789 Investigation](https://suus0002.w10:8080/browse/MOB-789)

### Mobile 1.0 Client Error-Handling

Although the errors are split up, they're all shared. There's a monolithic error map that the client uses for login, reset password, resend email, and create account. This is an attempt to logically separate the errors.

The 2xxx errors are custom codes inside the Mobile 1.0 client.  We can ignore them.

#### Create Account Errors

Error            | Status Code(s) | Description
----------------:|:--------------:|:-----------
AccountNotUnique | 1002           | Account already in use
PasswordInvalid  | 1007           | This password doesn't match requirements
AccountInvalid   | 1008           | Email address is not in the correct format

#### Login Errors

Error                  | Status Code(s) | Description
----------------------:|:--------------:|:-----------
AuthenticationFailed   | 1001           | Incorrect username/password combination
AccountInvalidPassword | 1003           | Your account is locked, please reset your password
AccountLocked          | 1004           |
ValidationFailed       | 1005, 2000     | Validation failed
OldPassword            | 1006           | This password was previously used
AccountNotActivated    | 1012           |
RefreshInProgress      | 2004           | Error, an authentication is currently in progress

#### Shared Errors

It appears that these are shared between login, reset password, resend email, and create account

Error           | Status Code(s)   | Description
---------------:|:----------------:|:-----------
UnknownError    | 1000, 2001, 3840 | An unexpected error has occurred, please close the app and try again.
AccountNotFound | 1011             |
ProxyError      | 407              | Can't connect to service because of a proxy authentication error
InternalError   | 500              | An error occurred while authenticating. Please try again

#### Unknown Errors

Not sure, it seems like this could be used for email validation or saving a pin.

Error                 | Status Code(s) | Description
---------------------:|:--------------:|:-----------
InvalidReference      | 1009           | Verification code is wrong
TokenExpired          | 1010           | Verification code is expired
InvalidKey            | 1013           |
TokenMissingOrExpired | 1014-404       |
EmptyToken            | 2002           | Error in authentication key returned
InvalidClientToken    | 2003           | Error with local credentials

### GCDM API References

#### V4 Customer API

If you wish to see the source documentation, [please visit here](http://gcdm.muc/GCDM/Releases/2019_1/WSK/overview-summary.html).

[BusinessPartner]: http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v4/model/customer/Customer.html#getBusinessPartner()
[UserAccount]: (http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v4/model/customer/Customer.html#getUserAccount())
[CustomerModel]: http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v4/model/customer/Customer.html
[ValidationAppException]: http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v3/exceptions/app/ValidationAppException.html
[DataQualityAppException]: http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v3/exceptions/app/DataQualityAppException.html
[NotFoundAppException]: http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/v3/exceptions/app/NotFoundAppException.html

##### Create Account API

**POST** v4/bmwconnected/customers

* Consumes "application/json"
* Produces "application/json"

Source documentation for Customer API [can be found here](http://gcdm.muc/GCDM/Releases/2019_1/WSK/com/bmw/gcdm/controller/business/v4/facade/CustomerApi.html).

This API creates a new customer in GCDM. Covers these cases:

* Creation of business partner and account: [BusinessPartner] without GCID/UCID is given and [UserAccount] is given
* Creation of business partner (without account or account linking): [BusinessPartner] without GCID is given and [UserAccount] is NOT given
* Creation of business partner with linking to an existing account: [BusinessPartner] WITH GCID is given and [UserAccount] is NOT given
* Creation of account (without business partner): [BusinessPartner] is NOT given and [UserAccount] is given

The case executed by this method depends on the input elements [BusinessPartner] and [UserAccount]. Even if no account is created, a GCID is assigned to the created the business partner.

A customer optionally has a user account (see cases above) containing their login credentials.

When a new account is created, a double-opt process is started that the customer must complete in order to activate the account. For this, a token/mTAN is delivered to the user account's mail or mobile channel, whichever attribute is set. This token is required to use with activateMail or activateMobile when autoGeneratePassword is false. Otherwise, the token has to be used with setPassword along with a password that the customer choses.

Note that all substructures of the business partner where the delete attribute is set are removed from the structure. No [ValidationAppException] is thrown in this case.

* **Parameters:**
  * Name                 | Data Type                 | Param Type      | Description
    :-------------------:|:-------------------------:|:---------------:|:----------:
    n/a                  | [Customer][CustomerModel] | HTTP Body       |
    autoGeneratePassword | boolean                   | Query Parameter | Only applies if Customer.getUserAccount() is not null. If set to true, a password will be automatically generated. Defaults to false. If set to true, the password attribute of the user account MUST be empty. If set the false, the password attribute of the user account MUST be filled. As the generated password will not be disclosed, the customer is required to set a new password upon account action.
    validateOnly         | boolean                   | Query Parameter | If true will only validate, no changes, returns HTTP status code 204 if successful. The validation performed with the validateOnly flag is not exactly identical with the validation performed during customer registration (without validateOnly). Additionally a captcha will not be required at all, if validateOnly is true.
* **Returns:**
  * [Customer][CustomerModel]
* **Throws:**
  * [ValidationAppException]
    * **HTTP Code**: 400 Bad Request
    * **Error Code**: 1014-300
    * Notes:
      * If the provided business partner data could not be successfully validated
      * Furthermore, a ValidationAppException with reason id CAPTCHA_REQUIRED is thrown when the denial of service control rules for the respective business context require the user to solve a captcha
      * A ValidationAppException with reason id INVALID_CAPTCHA is thrown if a captcha response is required to be passed in customer.captcha but was not delivered or was delivered but is wrong
    * Example:

      ```json
      {
        "errorCode" : "1014-300",
        "reasons" : [
          {
            "property" : "customer.userAccount.password",
            "value" : "SomeDefaultPassword",
            "constraint" : "NOT_EMPTY",
            "text": "A password is not expected for account create"
          }
        ]
      }
      ```

  * [DataQualityAppException]
    * **HTTP Code**: 400 Bad Request
    * **Error Code**: 1014-403
    * Notes:
      * If the provided business partner data's quality was insufficient
  * [NotFoundAppException]
    * **HTTP Code**: 404 Not Found
    * **Error Code**: 1014-200
    * Notes:
      * If business partner should be updated but no account and no business partner is found
      * Also possible if policy consents should be added but there is no business partner, account or existing policy consents for the GCID

###### Validation Failures

Here's all the possible validation failure reasons:

Name                | Description
:------------------:|:-----------:|
CAPTCHA_REQUIRED    | "captcha" is required in the "customer" object
INVALID_CAPTCHA     | Provided value for recaptcha input is wrong
EMPTY               | A provided value is empty where a non-empty value is expected
NOT_EMPTY           | A provided value is not empty where an empty value is expected
ILLEGAL_CHARACTERS  | A provided value contains illegal characters
INVALID_FORMAT      | A value is provided in a different format than expected (e.g., phone number, dates)
INVALID_KEY         | A provided value contains an invalid key (unknown enum value)
INVALID_REFERENCE   | A provided value does not contain a valid reference
MALICIOUS_CONTENT   | Symantec AntiVirusTM Scan Engine: malicious content detected
NOT_UNIQUE          | A provided value violates a UNIQUE constraint in the system
PASSWORD_COMPLEXITY | A provided value does not comply with the password policy
PASSWORD_HISTORY    | A provided value has been used as a password before
TOO_LARGE           | A provided number is greater than expected (i.e. provided > expected)
TOO_SMALL           | A provided number is less than expected (i.e. provided < expected)
TOO_LONG            | A provided string is too long (string length)
TOO_SHORT           | A provided string is too short (string length)