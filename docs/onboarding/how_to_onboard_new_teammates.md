---
layout: default
title: How to Onboard New Teammates
parent: Onboarding
nav_order: 6
---

# How to Onboard New Teammates

[Chris Tran]: mailto:Chris.P.Tran@bmwna.com
[Won Tchoi]: mailto:Won.Tchoi@bmwna.com
[Michelle Amanfo]: mailto:Michelle.Amanfo@partner.bmwgroup.com
[Pavel]: mailto:pavel.meliksetyan@bmw.com
[Access]: https://suus0002.w10:8080/secure/CreateIssue.jspa?pid=15900&issuetype=13600

## Brand-New Hires

### Steps to Complete Before Their Start Date (anyone can do this)

1. Email [Chris Tran][Chris Tran] to ensure he requests their **IDAS** accounts and handles granting their Internet Access
   - This may take a while, so be sure to request this at least one week in advance
   - Chris will send you their email and _Q-number_
   - **You cannot proceed to the following steps without receiving the email with their information from Chris**
2. Email [Chris][Chris Tran] to request Skype, MS 365, and MS Teams
   - This requires their email address
3. Email [Won Tchoi][Won Tchoi] and **cc;** [Michelle Amanfo][Michelle Amanfo] to get their GitHub Access and Azure access set-up
4. Fill in a [JIRA ACCESS][Access] ticket request
   - Ask for JIRA and BitBucket access
   - This requires their email address and Q-number
5. Email [Pavel][Pavel] with their name, email, Q-number, and start dates to ensure that they will have machines

[identity]: https://code.connected.bmw/runtime/tf-identity
[identity-usage]: https://code.connected.bmw/runtime/tf-identity#usage
[github config]: https://code.connected.bmw/runtime/github-config

## Members Coming from Another Team

### Steps to Complete Before Their Start Date (you'll need GHE push access)

Ask if they already have GHE and Azure access (the latter is required for GHE single-sign-on). If they already have GHE push access, they should be set!

If they don't have GHE push access, these steps must be completed:

1. Clone the repo [runtime/tf-identify][identity]
2. Check if they already have a GHE account
   - If they do, find their GHE username and speak with the Runtime team
   - If not:
      1. Add an entry for them in `main.tf` following the example in the repo [usage][identity-usage] section
      2. Their username should be their email address, before the `@`, without any `.`s. E.g.:
         - `jennifer.jesuraj@bmwna.com` -> `JenniferJesuraj`
         - `Rahul.BA.Bolia@bmwgroup.com` -> `RahulBABolia`
      3. Open a PR. There's a decent amount of folks that can sign off on this, thankfully!
3. Add them to the correct GHE team via [tf-github-teams](https://code.connected.bmw/runtime/tf-github-teams)
   - Unless you're starting a brand new team it should be as simple as adding them to the org/team that they are joining. Start with the files in the `teams` folders and go from there.
   - If you do need to create a new team overall then follow the directions in the [readme](https://code.connected.bmw/runtime/tf-github-teams/blob/master/README.md)

## First Week Onboarding

The onboarding topics covered in Week 1 are listed on the [Onboarding Home Page]({{site.baseurl}}/docs/onboarding/)
