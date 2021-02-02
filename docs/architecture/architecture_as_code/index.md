---
layout: default
title: Architecture as Code
parent: Architecture
nav_order: 24
has_children: true
---

# Architecture as Code


Disclaimer
{: .label .label-yellow }
---
> This page is inspired by the documentation of the Compass tool, however, it does not dispense the reading of the official documentation ([Compass](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=571962673) and [User Guide](https://atc.bmwgroup.net/bitbucket/projects/CDARCH/repos/arch_as_code/browse/doc/userguide/architectureSpecification.adoc)).

> The examples described in this page are based on a real system, but the most recent changes are not guaranteed.

---

* [Overview](#overview)
* [Compass Tool](#compass-tool)
* [Process](#process)
* [Architecture Specifications](#architecture-specifications)
* [References](#references)

## Overview
This walkthrough guides Mobile 2.0 developers on how to document the services developed under this project, using BMW's documentation tool for this purpose: Compass tool.

In order to facilitate the monitoring of this document, some general foundations for the use of the Compass tool are mentioned and summarized.

## Compass Tool
Compass (Connected Company Architecture Specification System) is the architecture documentation tool of the Connected Company Offboard Platform.

It is based on the concept of documenting architecture as code.

The architecture model is described in a domain-specific language implemented in Typescript.

The architecture model is maintained in a collaborative model by the DevOps teams following the principles:

- the architecture model is owned by everybody;
- we work collaboratively on the whole model.

On top of that, Compass provides an architecture visualization, reporting, automatic quality checks, and architecture validation.

## Process
The contribution process is based on [Bitbucket repository](https://atc.bmwgroup.net/bitbucket/projects/CDARCH) and the following steps describe it.

![compass process flow]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_process_flow.png)

This document is focused on step 4. "Make changes" according to the guidelines and best practices.

## Architecture Specifications
The architecture model is structured in a hierarchical way with the following concepts: Domain, Product, Subproduct, and System.

![compass architecture specifications]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_architecture_specifications.png)

The following table describes the general architecture concepts based on Mobile 2.0 examples.

| :-----------------------------:|
| Concept	| Example in Context Mobile 2.0    |Graphical representation Compass    |
| :-----------------------------:|
| Domain	| Connected App  & Conversation Service | ![compass graphical sample domain]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_graphical_sample_domain.png)|
| Product	| OMC | ![compass graphical sample product]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_graphical_sample_product.png)|
| Subproduct	| After Sales / eMobility / among others | ![compass graphical sample subproduct]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_graphical_sample_subproduct.png)|
| System	| omcChargingHistoryComposite / among others | ![compass graphical sample system]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_graphical_sample_system.png)|
| :-----------------------------:|

The following images describe the hierarchical structure of the architecture model.

| :-----------------------------:|
| Code representation Compass    |Example of the code representation Compass |
| :-----------------------------:|
| ![compass folders]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_folders.png)|![compass folders sample]({{site.baseurl}}/assets/images/architecture/architecture_as_code/compass_folders_sample.png)|
| :-----------------------------:|

The architecture is specified in the scope of a System.

A System in Compass represents a conceptional container for all elements (services, databases, file systems, queues, network shares, among others) that together provide one or more services for other systems.

## References
[Compass official documentation](https://atc.bmwgroup.net/confluence/pages/viewpage.action?pageId=571962673)

[Microservice IDs](https://atc.bmwgroup.net/confluence/display/CDARCH/AG+001+-+Microservice+IDs)

[Architecture work group](https://atc.bmwgroup.net/confluence/display/NWAP/Architecture+work+group)

[Compass repository](https://atc.bmwgroup.net/bitbucket/projects/CDARCH)

[Architecture as code](https://compass.bmwgroup.net/archascode/#/)

[Application List](https://compass.bmwgroup.net/archascode/#/report/applicationlist)

[BMW Guidelines - Meta information](https://developer.bmw.com/connected-vehicle/develop/guides-and-tutorials/api-guides/#must-de-x-contain-bmw-api-meta-information)