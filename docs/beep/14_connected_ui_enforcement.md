---
layout: default
title: "BEEP-14: Connected UI Enforcement"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 14
---

# BEEP-14: Consistent UI Component Enforcement

### Author

- Tim Chabot <timothy.chabot@bmwna.com>

## Summary

The goal of this BEEP is to propose an approach for enforcing consistent use of UI components from a UI component SDK (e.g. joy_ui, connected_ui) in Eadrax feature modules.

## Motivation

Currently, in mobile-connected, there is liberal import of the flutter material and cupertino packages across 175 files, mostly material.dart. In many cases, this is unnecessary as an import of other base flutter packages can resolve the dependencies of these widgets.

Ideally, all UI components should come from a UI Component SDK, like connected_ui, such that application feature UI development and theming can be consistent and decoupled from Material and Cupertino components. Since there is direct use of Material components in mobile-connected, these instances should be replaced with abstracted components from the Eadrax UI Component SDK.

### Detailed Description

As mentioned in the prior section, there is an abundance of importing material.dart when it is not needed. The following base flutter packages would resolve dependencies for these cases:

- package:flutter/widgets.dart
- package:flutter/foundation.dart
- package:flutter/painting.dart
- package:flutter/rendering.dart
- package:flutter/services.dart
- package:meta/meta.dart

These base packages will be exported by the Platform SDK along with the UI component SDK. This will allow developers of feature modules to only have to import the platform_sdk package to resolve dependencies for UI components. For example, today, in mobile-connected the SplashPage widget is defined as:

```dart
import 'package:flutter/material.dart';
import 'package:connected_ui/connected_ui.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // From material.dart
        body: Center( // From material.dart but can be imported from flutter/widgets.dart
      child: Container( // From material.dart but can be imported from flutter/widgets.dart
        width: 100.0,
        child: M2BrandLogo(), // From connected_ui.dart
      ),
    ));
  }
}
```

Note that two components, Center and Container, are resolved via material.dart but should really be resolved from flutter/widgets.dart. In Eadrax, under the modularized application, this component would be written as:

```dart
import 'package:platform_sdk/platform_sdk.dart'; //flutter/widgets.dart AND joy_ui exported through platform sdk

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JoyScaffold( // From joy_ui SDK
        body: Center( // From flutter/widgets.dart
      child: Container( // From flutter/widgets.dart
        width: 100.0,
        child: JoyBrandLogo(), // From joy_ui SDK
      ),
    ));
  }
}
```

New Eadrax features should utilize the platform SDK package only. If an abstracted UI component is not available then one should be created and added to the UI component SDK for use in the feature module under development.

#### Material Components Used In Mobile-Connected Today

Currently, the following Material components are being directly referenced in the mobile-connected codebase (UI Component SDK analogs listed if they exist from connected_ui):

- AppBar (M2AppBar)
- Material
- MaterialApp
- Scaffold
- showDialog (M2Dialog? interface)
- MaterialTapTargetSize
- MaterialPageRoute
- InkWell
- FlexibleSpaceBar
- showSearch
- SearchDelegate (and search query)
- ThemeData
- Theme (M2ThemeBloc)
- ListView
- ListTileControlAffinity
- ListTile
- CheckboxListTile
- Divider (M2Divider)
- RaisedButton
- IconButton (M2IconButton)
- FlatButton
- CircularProgressIndicator
- TabBar
- DefaultTabController
- TabBarView
- TextField (M2TextField)
- Icons (ConnectedIcons)
- Colors (ColorPalette?)
- Padding (M2Padding)

Any UI components without an abstraction should have one provided by the UI component SDK

#### Proposal -- UI Component Enforcement

##### What To Enforce

1. Check that a feature module's pubspec.yaml contains only one dependency, other than the Flutter SDK and that is the Platform SDK.  For example:

```yaml
dependencies:
  flutter:
    sdk: flutter
  platform_sdk:
    path: ../platform_sdk
```

2. Lint material.dart or cupertino.dart are NOT being referenced in any feature module source file.  

```dart
import 'package:flutter/material.dart';
```

OR

```dart
import 'package:flutter/cupertino.dart';
```

##### How To Enforce

To enforce the above requirements, linting steps can be added to the Verfication stage of the pipeline to validate that they are being met.  

In practice, these linting steps can be achieved by writing Dart CLI commands. Bash could be used for finding the unwanted imports but Dart may be more efficient. A Dart CLI command can be written to check the pubspec.yaml for the single platform SDK dependency along with a command for finding any of the unwanted import files outlined above.  Prior examples of Dart CLI commands can be found in (scripts/cli) with the Jenkinsfile as the driver (see Analyzer step for an example) of these commands.