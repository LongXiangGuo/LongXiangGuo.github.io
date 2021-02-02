---
layout: default
title: System Flows
parent: Core
grand_parent: Architecture
nav_order: 18
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# General System Flow
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant Composite Service
    participant Core Service
    Mobile 2.0 Connected->>Gateway: POST/GET/PUT/DELETE /api/gateway/connected/{service}
    Gateway->>Composite Service: POST/GET/PUT/DELETE api path
    Composite Service->>Core Service: POST/GET/PUT/DELETE api path
    Core Service->>Composite Service: Core Response
    Composite Service->>Mobile 2.0 Connected: 200s for positive outcomes
    Composite Service->>Mobile 2.0 Connected: 400-500 error codes
</div>
---

## Tier 0 Services

### Login
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant COACS
    Note right of COACS: COACS = Connected <br/>OAuth Composite<br/> Service
    participant GCDM
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/oauth
    Gateway->>COACS: POST /api/v1/oauth/token
    COACS->>GCDM: GetGCDMToken 
    GCDM->>COACS: GCDM Response
    COACS->>GCDM: GetGatewayToken
    GCDM->>COACS: Gateway Response
    COACS->>Mobile 2.0 Connected: 200: access token, refresh token, expires in, token type, usid
    COACS->>Mobile 2.0 Connected: 400, 424, 432, 433, 434, 435, 436, 437, 440, 500 error codes
</div>
---

### Vehicle List
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VCS
    Note right of VCS: VCS = Vehicle <br/>Composite<br/> Service
    participant CDP
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/vehicle-composite-service
    Gateway->>VCS: GET /api/v1/presentation/vehicles
    VCS->>CDP: Get Mapping Status
    CDP->>VCS: Mapping Status Response
    VCS->>Mobile 2.0 Connected: 200 Vehicle List
    VCS->>Mobile 2.0 Connected: 400, 401, 404, 424, 500 error codes
</div>
---

### Vehicle Mapping

#### Add Primary
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant CDP
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: POST /api/v1/vehicles/{vin}/primary
    VMCS->>CDP: GET Preconditions
    CDP->>VMCS: Preconditions Response
    VMCS->>CDP: POST MapVehicle
    CDP->>VMCS: Map Vehicle Response
    VMCS->>Mobile 2.0 Connected: 201
    VMCS->>Mobile 2.0 Connected: 400, 403, 404, 424, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442
</div>
---

#### Add Secondary
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant CDP
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: POST /api/v1/vehicles/{vin}/primary
    VMCS->>CDP: GET Preconditions
    Note right of CDP: If vehicle market <br/> change and driver is <br/>secondary,<br/> then return <br/>Precondition<br/> failed = 412
    CDP->>Mobile 2.0 Connected: Preconditions Failed Response
    CDP->>VMCS: Preconditions Ok Response
    VMCS->>CDP: POST MapVehicle
    CDP->>VMCS: Map Vehicle Response
    VMCS->>Mobile 2.0 Connected: 201 
    VMCS->>Mobile 2.0 Connected: 400, 403, 404, 424,432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442
</div>
---

#### Vin Entry Page
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant Motorist
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: GET /api/v1/vehicles/vin-entry-page
    VMCS->>Motorist: GetUserProfile
    Motorist->>VMCS: User Profile Data
    VMCS->>Mobile 2.0 Connected: 200: isSecondaryDriverSupported, vinImage
    VMCS->>Mobile 2.0 Connected: 400, 403, 424 error codes
</div>
---

#### Validate Security Code Page
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant OMC
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: GET /api/v1/vehicles/{vin}/validate-security-code-page
    VMCS->>OMC: Get Vehicle State
    OMC->>VMCS: Vehicle State Data
    VMCS->>Mobile 2.0 Connected: 200: iDriveImage, isVehicleMgu
    VMCS->>Mobile 2.0 Connected: 400, 401, 404, 424, 500 error codes
</div>
---

#### Validate Vehicle Security Code
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant CDP
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: POST /api/v1/vehicles/{vin}/validate-security-code
    VMCS->>CDP: POST Confirm Token
    CDP->>VMCS: Vehicle Mapping Token Ok Response
    VMCS->>Mobile 2.0 Connected: 204
    VMCS->>Mobile 2.0 Connected: 400, 403, 404, 424, 432, 433, 434, 435, 436, 437 error codes
</div>
---

#### Resend Vehicle Security Code
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VMCS
    participant OMC
    Note right of VMCS: VMCS = Vehicle<br/>Mapping Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/vehicle-mapping-composite-service
    Gateway->>VMCS: POST /api/v1/vehicles/{vin}/resend-security-code
    VMCS->>CDP: POST Resend Token
    CDP->>VMCS: Vehicle Mapping Token Ok Response
    VMCS->>Mobile 2.0 Connected: 204
    VMCS->>Mobile 2.0 Connected: 400, 403, 404, 424, 432 error codes
</div>
---

### Create Account

#### Get Profile Form
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant UCS
    Note right of UCS: UCS = User<br/>Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/user-composite-service
    Gateway->>UCS: GET /api/v1/presentation/profile-form/create
    UCS->>Mobile 2.0 Connected: 200, Empty Form Data
    UCS->>Mobile 2.0 Connected: 404, 500 error codes
</div>
---

#### Create Account
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant UCS
    participant GCDM
    Note right of UCS: UCS = User<br/>Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/user-composite-service
    Gateway->>UCS: POST /api/v1/presentation/users/account
    UCS->>GCDM: POST Create Account
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 201
    UCS->>Mobile 2.0 Connected: 400, 409, 424, 500 error codes
</div>
---

#### Resend Confirmation Email
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant UCS
    participant GCDM
    Note right of UCS: UCS = User<br/>Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/user-composite-service
    Gateway->>UCS: POST /api/v1/presentation/users/resend-email-confirmation
    UCS->>GCDM: POST Resend Confirmation Email
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 204
    UCS->>Mobile 2.0 Connected: 424, 500 error codes
</div>
---

#### Reset Password Email
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant UCS
    participant GCDM
    Note right of UCS: UCS = User<br/>Composite<br/> Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/user-composite-service
    Gateway->>UCS: POST /api/v1/presentation/users/reset-password
    UCS->>GCDM: POST Reset Password
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 201
    UCS->>Mobile 2.0 Connected: 400, 500 error codes
</div>
---

## Tier 1 Services

### Remote Services

#### Remote Commands - General
This sequence is the same for all remote commands: door-lock, door-unlock, horn-blow, light-flash, send-poi
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VRCCS
    participant CDWebAPI
    Note right of VRCCS: VRCCS = Vehicle<br/>Remote<br/>Commands<br/>Composite<br/>Service
    Mobile 2.0 Connected->>Gateway: POST /api/gateway/connected/VRCCS
    Gateway->>VRCCS: POST /api/v1/presentation/remote-commands/{vin}/{remote-command}
    VRCCS->>CDWebAPI: POST Execute Remote Command
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 204
    UCS->>Mobile 2.0 Connected: 400, 424, 500 error codes
</div>
---

#### Remote History

##### Get History
This sequence is the same for all remote commands: door-lock, door-unlock, horn-blow, light-flash, send-poi
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VRCCS
    participant CDWebAPI
    Note right of VRCCS: VRCCS = Vehicle<br/>Remote<br/>Commands<br/>Composite<br/>Service
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/VRCCS
    Gateway->>VRCCS: GET /api/v1/presentation/remote-history/{vin}
    VRCCS->>CDWebAPI: GET Remote History
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 204
    UCS->>Mobile 2.0 Connected: 400, 401, 404, 500 error codes
</div>
---

##### Delete History
This sequence is the same for all remote commands: door-lock, door-unlock, horn-blow, light-flash, send-poi
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VRCCS
    participant CDWebAPI
    Note right of VRCCS: VRCCS = Vehicle<br/>Remote<br/>Commands<br/>Composite<br/>Service
    Mobile 2.0 Connected->>Gateway: DELETE /api/gateway/connected/VRCCS
    Gateway->>VRCCS: DELETE /api/v1/presentation/remote-history/{vin}
    VRCCS->>CDWebAPI: DELETE Remote History
    GCDM->>UCS: Ok or Error Response
    UCS->>Mobile 2.0 Connected: 200
    UCS->>Mobile 2.0 Connected: 400, 401, 404, 500 error codes
</div>
---

### Vehicle Data (including location)
<div class="mermaid">
sequenceDiagram
    participant Mobile 2.0 Connected
    participant Gateway
    participant VCS
    Note right of VCS: VCS = Vehicle <br/>Composite<br/> Service
    participant OMC Motorist
    participant OMC Vehicle
    participant CDP
    Mobile 2.0 Connected->>Gateway: GET /api/gateway/connected/vehicle-composite-service
    Gateway->>VCS: GET /api/v1/vehicles/{vin}
    VCS->>OMC Motorist: Get Active Vehicle
    OMC Motorist->>VCS: Ok or Error Response
    VCS->>OMC Vehicle: Get Vehicle State
    OMC Vehicle->>VCS: Ok or Error Response
    VCS->>CDP: Get Mapping Status
    CDP->>VCS: Ok or Error Response
    VCS->>Mobile 2.0 Connected: 200, 215, 216
    VCS->>Mobile 2.0 Connected: 400, 401, 404, 500 error codes
</div>
---
