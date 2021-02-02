---
layout: default
title: "BEEP-6: [Microservice] Decouple remote services from vehicle-composite-service"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 6
---

# BEEP-6: Decouple remote services from vehicle-composite-service

### Authors

- Jorge Coca (jorge.coca@bmwna.com)

## Summary

- Decouple remote services from existing vehicle-composite-service
- Create a new `remote-actions-composite-service` (or similar) to perform remote actions

## Motivation

Determining what goes into different microservices is hard, specially when different applications share the same topic/context. At BMW, this is the case for many applications that, one way or another, interact with a vehicle: they have the vehicle context in common, but once you see the functionality, they are totally independent. 

For our context, this is the case of vehicle information and remote services: they represent applications with the same context, but inside that context, they are separate verticals. Vehicle information and remote services could be independent applications, being decouple from each other, allowing us to simplify our apps and architecture without loosing any functionality.

### Technicalities

We would maintain two microservices:

- The existing `vehicle-composite-service` would strip out its existing remote actions functionality, and would only service _vehicle information_
- A new `remote-actions-composite-service` would handle all the different remote actions and history. The existing remote APIs in _vehicle-composite-service_ would be moved here.

This approach would have multiple benefits:

- Smaller, modular microservice applications
- Development simplicity
- Ability to include _event driven_ technologies only in one application, without affecting other functionality (for example, seems like remote actions will be using sockets/streaming APIs in Core, so that would allow us to safely experiment with that technology in a single microservice without affecting other functionality)
