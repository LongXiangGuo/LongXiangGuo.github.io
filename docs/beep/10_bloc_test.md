---
layout: default
title: "BEEP-10: Bloc Test"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 10
---

# BEEP-10: Bloc Test

### Authors

- Felix Angelov

## Summary

The goal of this BEEP is to propose a convention for testing Blocs in order to ensure consistency in our codebase while also keeping the code easy to read/understand.

## Motivation

Currently, there is no standard way to unit test a bloc. Generally, we follow the approach:

- create the bloc instance
- prepare the mocks
- expectLater that the bloc will emit the expected states
- add one or more events

This process has several limitations:

1. false positives can easily occur (e.g. `expectLater(bloc, emitsInOrder([]))` will always pass and doesn't mean that the bloc did not emit any states)
2. some test failures result in timeouts which results in the developer wasting time (30s) and also leaves the developer lacking any information about why the test failed.
3. tests are not strictly enforcing that no further states are emitted. If a bloc emits the expected state + some additional states, the test will still pass because of how `emitsInOrder` works.
4. Adding multiple events and chaining expectations results in the code becoming messy and also error-prone. Tests might pass because expectations are skipped again resulting in a false positive.
5. There is no standardization/consistency in the way blocs are tested.

### Detailed description

I want to propose a specific kind of test called `blocTest` which should be used in place of the default `test` when unit testing blocs.

`blocTest` will enforce a three step testing approach:

1. Build - prepare and return the bloc under test
2. Act - add one or more events (optional)
3. Expect - assert that the bloc emitted only the expected states in the exact order without relying on timeouts.

```dart
blocTest(
  'CounterBloc emits [0, 1] when CounterEvent.increment is added',
  build: () => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: [0, 1],
);
```

`act` can be omitted in order to test the bloc's initial state.

```dart
blocTest(
  'CounterBloc emits [0] when nothing is added',
  build: () => CounterBloc(),
  expect: [0],
);
```

Test failures will be immediately reported with a detailed `TestFailure` object.

```dart
blocTest(
  'CounterBloc emits [0] when CounterEvent.increment is added',
  build: () => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: [0],
);
```

```sh
ERROR: Expected: [0]
  Actual: [0, 1]
   Which: longer than expected at location [1]
```

```dart
blocTest(
  'CounterBloc emits [0, 1] when no events are added',
  build: () => CounterBloc(),
  expect: [0, 1],
);
```

```sh
ERROR: Expected: [0, 1]
  Actual: [0]
   Which: shorter than expected at location [1]
```
