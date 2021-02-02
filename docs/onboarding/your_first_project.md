---
layout: default
title: Your first project
parent: Onboarding
nav_order: 4
---

# Your first project

Now that you have added your first commit to the project, it is time to shoot for the stars! 🌟

Our Flutter application uses [Bloc](https://github.com/felangel/bloc) as a state management solution: with this pattern, we can have a standard, predictable API to drive our UI. This library has been built in-house and open sourced, and the community seems to like it a lot. We definitely like it a lot.

Our Flutter application relies on composite services to host a feature's business logic by applying the Backend-for-Frontends microservice pattern. This pattern has proven to reduce client complexity and application updates by centralizing the feature domain logic on the backend rather than the client through good API design.

We believe that this [Weather App tutorial](https://bloclibrary.dev/#/flutterweathertutorial) is perfect to help understand how Bloc works, how our Mobile 2.0 application is architected, and how Dart operates as a language.  It also provides an opportunity to build out a [simple NestJS Composite Service]({{site.baseurl}}/docs/onboarding/your_first_composite_service/) for your client to communicate with for feature data.

## Expectations & Requirements

It is the expectation of the Core team that you can follow this tutorial and complete it within 2 days. 

Following the steps of the tutorial, you will be creating a Flutter weather app using BLoC.  You will also create a composite service based by following the [Your First Composite Service Tutorial]({{site.baseurl}}/docs/onboarding/your_first_composite_service/) that outlines providing an API for fetching the weather based on the name of a city.  

Due to this you will NOT need to follow the REST API section in the [BLoC Tutorial](https://bloclibrary.dev/#/flutterweathertutorial?id=rest-api) but rather the Your First Composite Service doc.


### Expectations - Flutter App

Flutter app will have unit, widget and e2e tests and follow the structures defined in the BLoC tutorial (e.g create models, data provider, repository, etc)

### Expectations - Composite Service

- Composite service will have unit and e2e tests
- APIs will be defined in the controller
- Business logic will be defined in the service class
- Common utility methods will be defined in a utility class
- Provide ancillary data like moon phases, humidity level, and sunrise and sunset in the GET weather response and adapt your client code accordingly

Bonus:
- Use Hydrated Bloc in the weather app for storing and retrieving addresses that were entered (e.g. browsing history)
- Add ability to toggle between different cities
  
If you run into any problems, we are here to help you and assist you. Feel free to stop by our pod or, if you are not in Chicago/remote, send us an email to `mobile2.0@list.bmw.com`.
