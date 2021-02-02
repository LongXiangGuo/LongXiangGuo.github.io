---
layout: default
title: Your first composite service
parent: Onboarding
nav_order: 7
---

# Onboarding Composite Service Tutorial

## Project Generation

You will be creating a NestJS based composite service.  To generate a NestJS project please follow the directions outlined in the [generator-btcnestjs README](https://code.connected.bmw/runtime/generator-nestjs)

## Building the GET Weather API

The following sections give some high level detail and tips for progressing this composite service.  

As a reference, please feel free to clone and have a look at the [vehicle-composite-service](https://code.connected.bmw/mobile20/vehicle-composite-service) for concrete examples of how to implement aspects of the sections below.

Please follow the provided [swagger]({{site.baseurl}}/assets/js/onboarding/first-composite-service.json) when referenced in the sections below.  You can load this JSON in [Swagger Editor](https://swagger.io/tools/swagger-editor/) to visualize it

### Renaming classes

After generating the project, you will need to walk the project structure and rename the example classes provided by the generator to weather module, controller, service and models, respectively.

### Controller

Using the provided swagger as a guide, adjust the swagger annotations to match what is specified along with renaming the getter.  Its important to note that the logic in the controller should be kept to a minimum and it should rely on the service class API to do the bulk of the "heavy lifting" as it transforms the response from metaweather's to your composite's weather model class.

### Services

Your composite service will be composing its response from two API calls to the [metaweather api](https://www.metaweather.com/api/):
1. `/api/location/search/?query=<city>` - follow the API documentation and get the 'woeid' to pass to the second API call.
2. `/api/location/(woeid)/` - returns the weather data for the city represented by the 'woeid'

Your composite's weather service class will define an API that the controller will call that takes a city name and returns back your weather model that the controller will then pass back in the response.

### Models

You will need to define a weather model that matches the provided swagger.  You will also need to create intermediate models for parsing the metaweather response data.  You will take the metaweather response data and load specific properties of it into your Weather model for communication back to the client.  Once the base weather model is implemented and working with the Flutter Weather Application, you can then add more weather properties to the response as specified in the [Your First Project Page]({{site.baseurl}}/docs/onboarding/your_first_project.md) that can then be reflected in the client UI.

### Utilities

This up to you, the developer, but if you find there are smaller operations that are repeated as you call into metaweather and transform your data, try to capture those operations in a utility class.



