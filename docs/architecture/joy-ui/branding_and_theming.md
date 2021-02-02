---
layout: default
title: Branding, Theming & Icons
parent: JOY UI
grand_parent: Architecture
nav_order: 1
---

# Branding, Theming & Icons

The goal of this is to make **one** code base with **one** set of components (widgets) which can be used to deliver the MY BMW and MINI apps for iOS and Android.

For this reason we have the [Joy UI library](https://code.connected.bmw/mobile20/joy-ui/) which handles differences between platforms and brands.

## Developing for Joy UI

The purpose of Joy UI is to provide themed widgets but also colors and icons which are reused in our codebase.

- Provide widgets which can be easily configured when used
- Do not add any translations to JOY UI.

---

## Joy_Widgets Library

Consists of a collection of widgets that all extend `PlatformAdaptiveWidget` as well as all relevant theming resources.

### Structure

```bash
└── lib
    └── src
        ├── themes
        │   └── colors
        └── widgets
            └── button
```

The `themes` directory consists of all theme data (mini, bmw, etc...).

The `colors` directory consists of the color palettes associated with the themes. It takes advantage of the concept of `ColorSwatches` whenever there are different tints or shades of an individual color in order to have a way of specifying a color that is consistent with the material standards ([documentation](https://material.io/design/color/the-color-system.html#color-usage-palettes)).

The `widgets` directory consists of all the widgets that are provided by the library. Each widget has it's own subdirectory (for example, `widgets/button`). Within in subdirectory there are three files

- `widgets/button/button.dart`
- `widgets/button/button_cupertino.dart`
- `widgets/button/button_material.dart`

The initial widget.dart file contains a class that extends `PlatformAdaptiveView` and implements the constructor.

The cupertino and material widget files contain classes that extend `StatelessWidget` and implement the `build` method.

### Usage

#### Themes

Initializing themes is done by brand and region, coming from `startupConfiguration`.

```dart
// shell.dart
create: (_) => JoyThemeBloc(
        brand: _startupConfiguration.brand,
        isChina: _startupConfiguration.region == Region.china,
      ),
```

```dart
// joy_theme_bloc.dart
JoyTheme _getTheme() {
    if (_theme != null) return _theme;
    if (_brand == Brand.mini) return JoyTheme.miniLight;
    if (_isChina) return JoyTheme.bmwChinaLight;
    return JoyTheme.bmwLight;
  }
```

This keeps `ConnectedApp` agnostic of the theme so as a developer working on a widget or screen, one does not have to worry about theming any aspect of the UI.

#### Widgets

Using widgets from the library is done by just importing the widget library, from Platform SDK and instantiating the desired widget.

```dart
// home.dart
import 'package:flutter/material.dart';
import 'package:platform_sdk/platform_sdk.dart';

class ConnectedHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Home'),
      ),
      body: JoyButton(
          onPressed: () {
            print('hello world');
          },
          child: JoyText.label('JOY Button')),
    );
  }
}
```

The widget will adhere to the injected theme and it will adhere to the ```TargetPlatform```.

## Icons vs. Assets

We have two different resource types when it comes to images

**Icons** - All vector based and imported into the app as a font file, `.ttf`. These come directly from ED and therefore modifications are lengthy.

**Assets** - Essentially any other image asset. They should adhere to being scale aware as well and we do have scale based folders to support that.

### Updating Icons

Given that Icons are a font we have to do some magic to get them to be easily useable. We do have scripting in place to help the update process here. When your designer has confirmed that the needed changes have been merged into the [design/icon](https://code.connected.bmw/design/icons) repo then you can run `./scripts/update_icons.sh` from the root project folder. This will pull the [design/icon](https://code.connected.bmw/design/icons) repo, grab the needed files and copy them into the correct spots in joy-ui, then finally run the icon generator. You then just need to review the changes and commit them.


### Making widgets accessible through Semantics
[Screen readers](https://flutter.dev/docs/development/accessibility-and-localization/accessibility#screen-readers) detect and read out [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html) widgets in the widget tree. [SemanticsProperties](https://api.flutter.dev/flutter/semantics/SemanticsProperties-class.html) are used to configure what is actually read by a screen reader.

Every accessible JoyUI widget should have only one instance of type [SemanticsProperties](https://api.flutter.dev/flutter/semantics/SemanticsProperties-class.html) which can be changed depending on the widget's type or state. To achieve this use the `JoySemanticsProperties` extension. 

**No String literals or other hard-coded values, which can be internationalized, should be added to the widget. Avoid using labels and use the appropriate properties from [SemanticsProperties](https://api.flutter.dev/flutter/semantics/SemanticsProperties-class.html) wherever possible.**

## How to add Semantics

Every JoyUI widget should define it's default semantic properties as a top level constant and add a property of type [SemanticsProperties](https://api.flutter.dev/flutter/semantics/SemanticsProperties-class.html) to it's class.

```dart
const SemanticsProperties _defaultSemanticsProperties = SemanticsProperties(
  button: true,
  ...
);

class JoyButtonTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  ...
  final SemanticsProperties _semanticsProperties;

  ...
}
```

When the default semantics properties aren't enough (f.e. the state of the widget changes or the widget is loading ect.) add `SemanticsProperties additionalSemantics` when the specific widget type is built (f.e. inside a named constructor) and merge them with the default ones.

```dart
JoyButtonTile.loading({
    Key key,
    double height,
    SemanticsProperties additionalSemantics,
    ...
})  : assert(width != null),
      ...
      _semanticsProperties =
           _defaultSemanticsProperties.mergeUninitializedWith(
          additionalSemantics,
      ),
      ...
```

In the `Widget build(BuildContext context)` method of the JoyUI widget, wrap the code in a [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html) widget and pass your semantics properties to it.

```dart
@override
Widget build(BuildContext context) {
  ...
  return Semantics.fromProperties(
      properties: _semanticsProperties,
      child: ...
  );
```