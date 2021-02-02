---
layout: default
title: Home
nav_order: 1
description: "Documentation for Connected 2.0"
permalink: /
---

# Welcome to Connected 2.0 Mobile Docs

{: .fs-9 }
![Connected Drive]({{site.baseurl}}/assets/images/connected_drive.jpg)
In this site, you will find all the technical documentation needed to be part of the Mobile 2.0 project.
{: .fs-6 .fw-300 }

---

## Team configuration

The first thing you need to know is how the different teams working on Mobile 2.0 and API development are organized.

<div class="mermaid">
  graph LR;
    Runtime --> Core;
    Core --> Feature-A;
    Core --> Feature-B;
</div>

### Runtime

The **Runtime** team is responsible for the infrastructure of the project and its different APIs. They will provide the necessary tools to the different Core and Domain/Feature teams to get their job done. The Runtime team will help you by building tools that will automate your deployments and your pipeline, among other things.

### Core

The **Core** team is responsible for the overall quality of the Mobile 2.0 project, coding practices, core stability and basic infrastructure. The Core team relies on Runtime to scale their infrastructure.

## Other links of interest

- [Open Source @ BMW](https://pages.code.connected.bmw/bmw-tech-open-source/documentation/)
- [Runtime Documentation](https://pages.code.connected.bmw/runtime/docs/)
- [Aftersales](https://code.connected.bmw/after-sales/)
- [Core Services](https://code.connected.bmw/core-services/)
- [Daytona](https://code.connected.bmw/daytona/)
- [Docker](https://code.connected.bmw/docker/)
- [Mobile 2.0](https://code.connected.bmw/mobile20/)
- [Payment Gateway](https://code.connected.bmw/payment-gateway/)
- [Personal Portal](https://code.connected.bmw/personalportal/)
- [Runtime](https://code.connected.bmw/runtime/)
- [Terraform Modules](https://code.connected.bmw/terraform-modules/)
