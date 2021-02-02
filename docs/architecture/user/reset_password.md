---
layout: default
title: Reset Password
parent: User
nav_order: 1
grand_parent: Architecture
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Reset Password

## Overview

Reset Password is a fairly straightforward feature module that does the following:
- Present the user with a screen that allows them to input their email address
- Validate that what the user input for email adheres to the basic email format (e.g. me@service.com)
- Communicate this email address to the backend BFF (user-composite-service) which sends it along to GCDM for sending the actual email to the provided address

The feature utilizes the user-composite-service BFF to massage the locale and brand information into country, language and client identifier such that the POST request to GCDM knows how to qualify the request by those fields so the content sent in the email and resulting landing page for resetting the password is in the correct language for the provided brand.

## Client Architecture
The Reset Password feature module is made up of the following components:

<img src="{{site.baseurl}}/assets/images/user/reset_password/reset_password_client_arch.png">

The Reset Password Form:
- prompts the user to input an email address  
- activates the submit button when the email address matches the regex pattern confirming a valid format

The Reset Password Bloc:
- Holds the regex definition for valid email.  This is different from create account which gets its form elements and regex pattern from the user-composite-service
- Validates email address matches regex defined in the Bloc
- Passes validated email to UserRepository on form submit 

The User Repository utilizes the UserApiClient to POST the information to the user-composite-service's reset-password endpoint.

## Backend Architecture
<img src="{{site.baseurl}}/assets/images/user/reset_password/reset_password_backend_arch.png">

The user-composite-service:
- reset-password endpoint passes the email address, along with locale (from Accept Header) and Brand(from UserAgent Header) to the underlying service class
- The underlying service class normalizes the locale and  calls the Customers API Library resetPassword interface

The Customers API Library:
- re-orders the locale into country-language and transforms the brand into a client identifier then posts these three pieces of information to GCDM
- GCDM systems send the brand specific email in the correct language to the user
