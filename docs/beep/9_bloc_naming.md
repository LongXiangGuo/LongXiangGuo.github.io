---
layout: default
title: "BEEP-9: Bloc Naming Convention"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 9
---

# BEEP-9: Bloc Naming Convention

### Authors

- Felix Angelov

## Summary

The goal of this BEEP is to propose a convention for naming Bloc Events and States in order to ensure consistency in our codebase while also keeping the code easy to read/understand.

## Motivation

Currently, there is no standard for how to name Events and States and often times the names conflict with each other and/or are confusing/unclear.

### Detailed description

#### Events

**Definition**: Events are the input to a Bloc. They are commonly dispatched in response to user interactions such as button presses or lifecycle events like page loads.

**Naming Convention**

- **Events should be in the past tense** because events have already occurred.
- Initial Load events should follow the convention: `BlocSubject` + `Started`.

**Event Anatomy**: `BlocSubject` + `Noun` (optional) + `Verb`

##### Examples

`InitializePin` -> `PinStarted`

`PinHasBeenCreated` -> `PinCreated`

`PinHasBeenValidated` -> `PinValidated`

`FavoritesPageSelected` -> `FavoritesStarted`

`FavoriteDestinationsRetryPressed` -> `FavoritesLoadRetried`

#### States

**Definition**: States are the output of a Bloc and represent a part of your application's state. UI components can be notified of states and redraw portions of themselves based on the current state.

**Naming Convention**

- **States should be nouns** because a state is just a snapshot at a particular point in time.
- Initial states should follow the convention: `BlocSubject` + `Initial`.

**State Anatomy**: `BlocSubject` + `Noun (action)` + `State (Initial | Success | Failure | InProgress)`

##### Examples

`DetermineIfPinExists` -> `PinInitial`

`PinCreated` -> `PinCreateSuccess`

`PinValidated` -> `PinValidateSuccess`

`PinUnauthenticated` -> `PinValidateFailure`

`FavoritesLoading` -> `FavoritesLoadInProgress`

`FavoritesLoaded` -> `FavoritesLoadSuccess`

`FavoritesError` -> `FavoritesLoadFailure`
