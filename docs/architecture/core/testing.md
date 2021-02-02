---
layout: default
title: Testing Practices
parent: Core
grand_parent: Architecture
nav_order: 3
---

# Testing Practices

* [Testing Flutter Apps](#testing-flutter-apps)
* [Unit Testing](#unit-testing)
* [Widget Testing](#widget-testing)
* [Integration Testing](#integration-testing)

## Testing Flutter Apps

Please feel free read the documentation provided by the _Flutter_ team for more information about each type of test.

* [Testing Flutter Apps](https://flutter.io/testing/)

## Unit Testing

* [Unit Testing](https://flutter.io/testing/#unit-testing)

### Unit Test Naming Conventions and Structure Guidelines

All unit tests should be located under `test/unit_tests/`.

Unit test files should be suffixed/appended by `_test.dart`. For example, if you have a `login_bloc.dart` file located in the `lib/login/bloc/` folder, then you should have `test/unit_tests/login/bloc/login_bloc_test.dart`.

The folder structure should mimic the structure defined in the `lib/` folder.

For example, given the following `lib/` structure:

![lib folder structure]({{site.baseurl}}/assets/images/lib_unit_test_structure.png)

You would have the following `test/` structure:

![test folder structure]({{site.baseurl}}/assets/images/test_unit_test_structure.png)

## Widget Testing

* [Widget Testing](https://flutter.io/testing/#widget-testing)

### Widget Test Naming Conventions and Structure Guidelines

All widget tests should be located under `test/widget_tests/`.

Widget test files should be suffixed/appended by `_test.dart`. For example, if you have a `login_form.dart` file located in the `lib/login/` folder, then you should have `test/widget_tests/login/login_form_test.dart`.

The folder structure should mimic the structure defined in the `lib/` folder.

For example, given the following `lib/` structure:

![lib folder structure]({{site.baseurl}}/assets/images/lib_widget_test_structure.png)

You would have the following `test/` structure:

![test folder structure]({{site.baseurl}}/assets/images/test_widget_test_structure.png)

#### Widget Test Key Identifier Naming Conventions

Widget tests, for example, often ensure that child widgets exist and/or produce the expected output and/or expected action results. These child widgets are commonly _found_ by a _Key_ identifier. For instance, our `LoginForm` has a _username_ `TextFormField` that is identified as `loginForm_username_textFormField` as follows:

```Dart
TextFormField(
    key: Key('loginForm_username_textFormField'),
    ...
)
```

The widget test _**Key**_ identifiers **should** adhere to the following naming convention (using a combination of Snake Case and Camel Case conventions):

`<parentWidget/featureName>_<childWidgetName>_<childWidgetType>`

## Integration Testing

* [Integration Testing](https://flutter.io/testing/#integration-testing)

All integration tests should be located under `test_driver/`. The `test_driver/` folder should _ONLY_ contain `.dart` files and no sub-folders.

Each _feature_ or _module_ of the app that is to be integration tested shall have two (2) test files. The first of the two files shall have an equivalent name to the _feature_ or _module_ and the second test file shall have the same name suffixed/appended by `_test.dart`.

For example, given the following `lib/` structure:

![lib folder structure]({{site.baseurl}}/assets/images/lib_int_test_structure.png)

The _login feature_ is highlighted in blue, therefore the `test_driver/` should be structured as follows:

![test_driver folder structure]({{site.baseurl}}/assets/images/test_int_test_structure.png)

Why do we have two test files for integration tests? Using our example from above:

* `login.dart` enables the _Flutter Driver_ extension which allows our app to be run (driven) programmatically. `login.dart` then starts our app.
* `login_test.dart` is the actual _integration_ test suite. After our app has been started (is being driven), the tests written in this file can perform tasks within widgets just as if a human were performing these actions and we can assert the results we expect.