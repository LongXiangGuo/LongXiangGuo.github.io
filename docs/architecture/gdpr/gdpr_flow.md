---
layout: default
title: GDPR Flow
parent: GDPR
grand_parent: Architecture
nav_order: 1
---

# Legal Documents & GDPR (General Data Protection Regulation)

## New presentation layer: legal-document-composite-service

Two endpoints:

- `GET /terms-and-conditions` (plus query parameters, like phone locale...)

  - It would return `200` if new terms and conditions need to be accepted, with a JSON body that would include the necessary model to render the terms and conditions page.
  - It would return `204 No Content` if no acceptance is needed

- `POST /terms-and-conditions`
  - It would accept a JSON body that would include the accepted checks by the user, plus other necessary information needed by underlying APIs.

<div class="mermaid">
  graph LR
    flutter --> id2(terms-and-conditions-composite-service)
    id2 --> core-GDPR
    style id2 fill:#ccf,stroke:#f66,stroke-width:2px,stroke-dasharray: 5, 5
</div>

## Client flow

Unfortunately, there's not much optimization that we can do in this flow due to legal reasons.

## Widget tech design

- 1st level: written in Flutter (list of documents and checks)
  - On Accept tap, either `POST /terms-and-conditions` or save/cache conditions for later (after login)
- 2nd level: open a URL (within a Flutter Webview, not an external browser) with the contents of the document

![client structure]({{site.baseurl}}/assets/images/gdpr/gdpr_client.png)

### For authenticated users

<div class="mermaid">
  graph TB
    start-app --> C["GET /terms-and-conditions"]
    subgraph new-terms-and-conditions-widget
    C -- 200 --> show_form
    C -- 204 --> exit
    show_form --> P["POST /terms-and-conditions"]
    end
    exit --> home
    P -- 200 --> home
</div>

### For non-authenticated users

<div class="mermaid">
  graph TB
    start-app --> id1(new-terms-and-conditions-widget)
    logout --> id1
    id1 -- cache accepted conditions to sync after login --> login
    login --> C["GET /terms-and-conditions (check is acceptance required and phone country == GCDM country"]
    C -- 200 --> id2(new-terms-and-conditions-widget-with-country-check)
    C -- 204 --> home
    id2 --> P["POST /terms-and-conditions"]
    P -- 200 --> home
    style id1 fill:#FFFF99,stroke:#333,stroke-width:3px
    style id2 fill:#FFFF99,stroke:#333,stroke-width:3px
</div>
