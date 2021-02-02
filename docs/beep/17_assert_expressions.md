---
layout: default
title: "BEEP-17: Assert Expressions"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 17
---

# BEEP-17: Assert Expressions

### Authors

* Sérgio Ferreira

## Summary

I propose to change when we use assert expressions. 

## Motivation

The assert is not evaluated in release mode, therefore, it's a behavior only useful at development time. 
This means that it should only be used when we have static decisions. E.g. Widget A receives Widget B on the constructor.

Relying on assert expressions assumes that the client of the Widget has to check that the data is in a valid state beforehand or delegate this responsibility to another party.
The problem with this approach is that we'll always have to guarantee that those checks are in place whenever the given Widget is used. 

This could lead to:
 * Duplication of the logic to check that the data is valid. 
 * Exceptions on release mode.
 * Unwanted behavior. E.g. "null" presented to the user.

Since these problems only occurs when the data is corrupted and release mode, it will be hard to find this scenario during testing. 
Therefore I suggest we avoid the usage of assert expressions all together for data objects or dynamic values.

### Detailed description

The above scenario shows how we are using asserts and why this is a bad idea.

### Code examples
```dart

class MyWidget extends StatelessWidget {
  final int numberOfThings;
  
  MyWidget(this.numberOfThings) 
    : assert(numberOfThings != null && numberOfThings > 0);
    
  Widget build(BuildContext context) {
    return Container(
      child: Text(numberOfThings.toString()),
    );
  }
}

// Debug mode:
MyWidget(0);    // 'numberOfThings != null && numberOfThings > 0': is not true.
MyWidget(null); // 'numberOfThings != null && numberOfThings > 0': is not true.

// Release mode:
MyWidget(0);    // presents '0'
MyWidget(null); // presents 'null';

// both modes:
MyWidget(1);    // presents "1".

```

In this case we have to use this `MyWidget` under the assumption that the value `numberOfThings` is a constant that the developer will input. Otherwise, we'll have an unwanted behavior (0, null) presented.

A worse case is trying to do something that null doesn't implement like the `>` method. That would throw an exception like:
`The method '>' was called on null.`

```dart
if (numberOfThings > 2) { 
  //... 
}
```

### Proposal (example)

```dart

class MyWidget extends StatelessWidget {
  final int numberOfThings;
  
  MyWidget(this.numberOfThings);
    
  Widget build(BuildContext context) {
    if (!_isDataValid()) {
        // handle the case of invalid data
    }

    return Container(
      child: Text(numberOfThings.toString()),
    );
  }

  bool _isDataValid() =>
      numberOfThings != null && numberOfThings > 0;
  
}

// both modes:
MyWidget(1);    // presents "1".
MyWidget(0);    // handled by the `if (!_isDataValid())`.
MyWidget(null); // handled by the `if (!_isDataValid())`.

```

### Using the Widgets 

```dart

class MyApp extends StatelessWidget {
    Widget build(BuildContext context) {
        var numberOfThings = // get this from the server.

        // Handle the conditions of MyWidget outside the widget
        if (numberOfThings != null && numberOfThings > 0) {
            return MyWidget(numberOfThings);
        }

        return Container(
            child: Text("Something went wrong"),
        );
    }
}

```

```dart

class MyApp extends StatelessWidget {
    Widget build(BuildContext context) {
        var numberOfThings = // get this from the server.

        // Use Widget with confidence that it's going to present it or something else in case of error.
        return MyWidget(numberOfThings);
    }
}

```

### On the current solution

There a few examples of this in the current app, we can see them in the following files:
 * vehicle_list_item_card.dart (using assert)
   * The guarantee that this doesn't fail is handled by the method `fromVehicles(List<Vehicle> vehicles)` on vehicles.dart file.
     * That method also uses assert `assert(vehicles != null)`.
       * The guarantee that this doesn't fail is handled by `_$VehicleFromJson(Map<String, dynamic> json)` on vehicle.g.dart.


### Tests

Another side to using asserts are the tests. These run on debug mode which means that we will not be able to test the flow of corrupted data.
The only test we can make is that an AssertionError is thrown which is not true in release mode. 

I would recommend having tests as closer to the user as possible, assert expressions by their nature (debug mode) prevent this.

## Conclusion

Having this defensive approach will avoid the pitfall of having the app crashing. It gives us the opportunity to create tests for these scenarios instead of checking that an AssertionError was thrown.
A solution could be done in a broader way to handle any exceptions not captured, that would avoid the app from crashing. That solution however doesn't avoid the unintended behavior.
We should ask for UX guidance about this, to create a default defensive strategy. 
