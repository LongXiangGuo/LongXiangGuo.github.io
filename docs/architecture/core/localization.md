---
layout: default
title: Localization
parent: Core
grand_parent: Architecture
nav_order: 8
---

# Localization

This localization architectural document will be a living, constantly changing document while we research the best ways to achieve the following goals:

* How do we minimize developer time with strings?
* How do we support branded strings?
* How do we support parameters in strings?
* How do we support singular vs plural strings?
* Can we auto-generate code directly from the localized strings files?

## Naming Conventions for Strings

Our strings are located in the localizations_sdk. After adding your new strings in the localizations_sdk please check the README in localizations_sdk for integration instructions.

Strings can be added to `CommonStrings` if they are reused more often or to the localization file of your feature e.g. `LoginStrings`.
Please choose a descriptive name for new strings and follow the rule below. Please also check the sections below for possible edge cases.

```dart
[screen]?[element][bmw|mini]?
```

**Examples:**

* CommonStrings.ok
* CommonStrings.cancel
* DestinationsStrings.destinationsTabTitle
* LoginStrings.usernameLabelBmw
* LoginStrings.usernameLabelMini
* LoginStrings.createAccountButton
* LoginStrings.createAccountDialogTitle
* LoginStrings.createAccountDialogDesc
* LoginStrings.createAccountDialogOkButton

At the moment the identifier of a string (e.g. createAccountButton) has to be unique in our whole project, not just for one localization file. So try to be specific.

### Name Property

The name property in intl can be set to either the method / property name or a combination of class + method / property name. Prefer to use class name + method / property name. This will provide more context to the translation team, prevent naming conflicts and allows an easier mapping to the features.

```dart
String get ok {
  return Intl.message(
    'OK',
    name: 'CommonStrings_ok', // prefer 'CommonStrings_ok' instead of just 'ok'
    desc: 'OK Action',
  );
}
```

### Branded Strings

The class `BrandedStrings` in our repository provides some helpful methods such as the brand and the localized appName.

* If the whole string is different for BMW and MINI: Create strings with bmw and mini suffixes. To allow an easier use you can also make the bmw and mini strings private and only expose one version:

```dart
  String get sendFeedback {
    switch (brand) {
      case Brand.bmw:
        return _sendFeedbackBmw;
      case Brand.mini:
        return _sendFeedbackMini;
    }
    logError(Exception('Unsupported brand: $brand'));
    return '';
  }

  String get _sendFeedbackBmw {
    return Intl.message('Send Feedback to BMW', ...);
  }
  String get _sendFeedbackMini {
    return Intl.message('Send your Feedback', ...);
  }
```

* If only the brand should be replaced: Create two definitions with the private definition having the brand as a parameter:

```dart
 String get sendFeedback {
  return _sendFeedbackBranded(brandLocalized);
}

String _sendFeedbackBranded(String brand) {
  return Intl.message(
    'Send Feedback to $brand',
    name: 'ProfileStrings_sendFeedbackBranded',
    args: [brand],
    desc: 'Title of the send feedback page',
  );
}
```

### Semantics Strings

In order to be ADA compliant it is sometimes necessary to provide additional semantics or screen reader hints, e.g. as semanticsLabel property. 
To add a new string for semantics, please follow the rules above. In addition, add the suffix "Semantics" to name and create a new class for SemanticsStrings in the localization file of the feature.

**Example:**
* profileImageSemantics

```dart
// profile_tab_strings.dart

class ProfileTabSemanticsStrings {

  String get profileImageSemantics {
    return Intl.message(
      'Profile Image',
      name: 'profileImageSemantics',
      desc: 'Screen reader hint for profile image',
    );
  }
}

class ProfileTabStrings {

  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Title of profile page',
    );
  }
}
```

### Other Differentiations

Translations might also depend on the current vehicle configuration or the market. Then include one of the identifiers below. If a string is only relevant for one configuration, omit the identifier, e.g. if the feature is ATM2 only, you do not need to include the ATM2 identifier.

* Vehicle Configuration: `[atm1|atm2]`
* Market or countries: `[na|row|cn|DE|AU]`
* Head unit: `[ID5|ID6|ID7|ID8]`
* PU steps (Head unit Software Versions): `[0720|1120|...]`

### Parameters and Plural

Intl supports the following plurals (`Intl.plural`), genders (`Intl.gender`) and parameters by default (args parameter). For more examples see [intl README](https://github.com/dart-lang/intl).

```dart
String lastUpdatedAt(String timeOfDay) => Intl.message(
  'Last Updated: $timeOfDay',
  name: 'lastUpdatedAt',
  desc: 'Used to indicate the last time an item was updated',
  args: [timeOfDay],
  examples: const {"timeOfDay": "3:00 AM"},
);
```

```dart
String chargingHistorySessionIssues(int issueCount) => Intl.plural(
  issueCount,
  zero: '',
  one: '$issueCount issue',
  other: '$issueCount issues',
  name: 'chargingHistorySessionIssues',
  args: [issueCount],
  desc: 'Used on a charging session list tile or description when there is an issue',
);
```

## Integrating Translated Strings

Please check the page ["How to add translations"](../../../recipes/how_to_add_translations).
