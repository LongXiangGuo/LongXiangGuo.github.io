---
layout: default
title: REST APIs
nav_order: 5
has_children: false
---

# REST APIs @ Connected 2.0

Connected 2.0 follows an API architecture approach mostly known as [Backends for Frontends](https://docs.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends), but it might receive other names as well, such as *Presentation Layer/API*, *Composition Layer/API* or *Aggregation Layer/API*.

These services represent the outer layer of your microservice architecture, powering final clients/touchpoints, such as mobile applications, assistants, smartwatches or websites, *and never other microservices*. **It has dependencies on your feature and/or your core microservcice layer**.

Each touchpoint is encouraged to have its own presentation layer in the cloud, so we can move all the complexity out of the final touchpoint, achieving a better developer and user experience, and increasing our levels of productivity.

It is also important to mention that our company API guidelines are documented here: [API Guidelines](http://developer.bmw.com/connected-vehicle/develop/guides-and-tutorials/api-guides/)

## OpenAPI documentation

All the documentation that meets the [Runtime Standard Endpoints](https://suus0001.w10:8090/display/RUN/Standard+Endpoints) should appeard here:

* [Connected REST APIs documentation](https://btcnadly-dev.centralus.cloudapp.azure.com/swagger/?urls.primaryName=ctns-marketing-api)
