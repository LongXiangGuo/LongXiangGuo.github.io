---
layout: default
title: "BEEP-16: Widget Tests"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 16
---

# BEEP-16: Widget tests

### Authors

* Sérgio Ferreira

## Summary

I propose to change testing by testing the behavior of widgets instead of verifying that a given Key exists on a widget. 

## Motivation

At this point we are using a pattern of testing that doesn't provide the proper coverage. Verifying that a key is present is not proof of correctness unless that key was set on a widget created within the test method.

This type of test expectation brings two main problems:
- Creates coupling between implementation and test. 
  - When the key changes we have to change the test expectation, even when the expectation has nothing to do with the key itself. (see example below)
- Doesn't provide proof of correctness, leads to false positives:
  - As long as any Widget with the given key is present the expectation is verified.
  - It misleads the developer in thinking eveything is tested because that key is present instead of verifying behavior. e.g. a given Widget now is presented with so and so content.
    - Because of this I've realised that we are missing quite a significant amount of tests.

### Detailed description

> Sorry to use real test code here, it's easier to use a real case instead of some weird example from the top of my head.

The test below claims that when the state is SendToVehicleSuccess then the Success SnackBar is shown. This is not verifiable by the test itself.
The only thing we know by this test is that when the state is SendToVehicleSuccess there's a key named 'sendToVehicle_success_snackBar'


### Code examples
```dart

    testWidgets('when state is SendToVehicleSuccess success snackbar is shown',
        (tester) async {
      when(sendToVehicleBloc.state).thenReturn(
        SendToVehicleInitial(),
      );
      whenListen(
          sendToVehicleBloc,
          Stream<SendToVehicleState>.fromIterable([
            SendToVehicleInitial(),
            SendToVehicleSuccess(),
          ]));

      await tester.pumpWidget(widgetUnderTest);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('sendToVehicle_success_snackBar')), findsOneWidget);
    });

```

### Proposal
```dart
    final successMessage = 'whatever the title would be in a success case';
    
    testWidgets('when state is SendToVehicleSuccess success snackbar is shown',
        (tester) async {
      // ... same as above
      
      
      // find the SnackBar types presented
      var snackBarFinder = find.byType(SnackBar);
      
      // proof that a SnackBar is present
      expect(snackBarFinder, findsOneWidget);
      // prof that the SnackBar is the success one
      expect(tester.widget<SnackBar>(snackBarFinder).title, successMessage);
    });

    // Not part of the same test but still a missing test in this case is to test the negative:

    testWidgets('when state is SendToVehicleInitial no SnackBar is shown',
        (tester) async {      
        
      when(sendToVehicleBloc.state).thenReturn(
        SendToVehicleInitial(),
      );
      whenListen(
          sendToVehicleBloc,
          Stream<SendToVehicleState>.fromIterable([
            SendToVehicleInitial(),
          ]));
      
      
      // find the SnackBar types presented
      var snackBarFinder = find.byType(SnackBar);
      
      // prof that a SnackBar is not present
      expect(snackBarFinder, findsNothing);
    });

    testWidgets('when state is SendToVehicleFailure the success snackbar is not shown',
        (tester) async {      
        
      when(sendToVehicleBloc.state).thenReturn(
        SendToVehicleInitial(),
      );
      whenListen(
          sendToVehicleBloc,
          Stream<SendToVehicleState>.fromIterable([
            SendToVehicleInitial(),
            SendToVehicleFailure(),
          ]));
      
      
      // find the SnackBar types presented
      var snackBarFinder = find.byType(SnackBar);
      
      // prof that a SnackBar is present
      expect(snackBarFinder, findsOneWidget);
      // prof that the SnackBar is the success one
      expect(tester.widget<SnackBar>(snackBarFinder).title, isNot(equals(successMessage)));
    });

```

## Conclusion

The tests we make must verify behavior, be as close as the expectation from the user stand point not the current implementation.
If by any chance we need to find a Widget by key I would argue that the Key should be a static field on the Widget that holds it.
That way we won't break the tests if there's a need to change the arbitrary value of that key.


