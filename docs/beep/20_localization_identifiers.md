---
layout: default
title: "BEEP-20: Localization Identifiers"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 20
---

# BEEP-20: Localization Identifiers

### Author

- Julia Ringler

> **Note**
>
> This change is not possible at the moment, since the resolution of the strings in the app itself fails and would require further changes in the intl-libraries.

## Summary

This BEEP proposes to change the name of a localized string to include the filename. This will provide more context to the translation team as well as prevent naming conflicts.

Current Definition:

```dart
class ScanAndChargeStrings {
  String get tileTitle {
    return Intl.message(
      'Scan & Charge',
      name: 'tileTitle',
      desc: 'Scan and charge tile title',
    );
  }
  ...
}
```

Proposed Change:

```dart
class ScanAndChargeStrings {
  String get tileTitle {
    return Intl.message(
      'Scan & Charge',
      name: 'ScanAndChargeStrings_tileTitle',
      desc: 'Scan and charge tile title',
    );
  }
  ...
}
```

## Current State

In our code we have more context information than the translators. Furthermore, since every string is added to the global list, naming conflicts are more likely: `tileTitle` might be unique for the feature Scan & Charge but not over the whole project.

String Definition:

```dart
class ScanAndChargeStrings {
  String get tileTitle {
    return Intl.message(
      'Scan & Charge',
      name: 'tileTitle',
      desc: 'Scan and charge tile title',
    );
  }
  ...
}
```

Development View:

```dart
localization.scanAndCharge.tileTitle
```

Translation View:

```json
  "tileTitle": "Scan & Charge",
  "@tileTitle": {
    "description": "Scan and charge tile title",
    "type": "text",
    "placeholders": {}
  },
```

## Considerations

There are several possibilities to improve our naming.

The translation validation and export (intl_translation:extract_to_arb script) restricts the naming: The name parameter of a Intl.message must match the `methodName` or `ClassName_methodName` (see [intl Readme - Messages](https://pub.dev/packages/intl#-readme-tab-)). So, for the definition above the exported name can be either `tileTitle` or `ScanAndChargeStrings_tileTitle`.

We could also update the method name of the string to include more information e.g. `ScanAndChargeStrings.scanAndChargeTileTitle`. But this would then create unnecessary duplication in our code when we use the string in code: `localization.scanAndCharge.scanAndChargeTileTitle`.

There is also an [open PR](https://github.com/dart-lang/intl_translation/pull/75/commits/4285e0872326a2f134b36ac34b230bc5f0f8d018) in the intl_translation package with which we can omit the name property in our string definitions and it is generated with the syntax `ClassName_methodName`.

## Proposed State

The name property is generated for the export and uses `ClassName_methodName`.

String Definition:

```dart
class ScanAndChargeStrings {
  String get tileTitle {
    return Intl.message(
      'Scan & Charge',
      desc: 'Scan and charge tile title',
    );
  }
  ...
}
```

Development View does not change.

Translation View:

```json
  "ScanAndChargeStrings_tileTitle": "Scan & Charge",
  "@ScanAndChargeStrings_tileTitle": {
    "description": "Scan and charge tile title",
    "type": "text",
    "placeholders": {}
  },
```

## Necessary Changes

1. Fork intl_translation repo and add [this commit](https://github.com/dart-lang/intl_translation/pull/75/commits/4285e0872326a2f134b36ac34b230bc5f0f8d018).
1. Update reference to intl_translation in `pubspec.yaml`
1. Update scripts for generating our translations and our documentation: `check_for_pending_translations.sh` and add the new parameter `--force-generate-name`
1. Update the `intl_validator:find_duplicates` script (see below for more details)
1. Adapt all strings to the new conventions by removing the name property. This could also be done incrementally.

### Update find_duplicates Script

To prevent naming conflicts we run the custom script `intl_validator:find_duplicates` ([Script Source](https://code.connected.bmw/mobile20/intl-validator/blob/master/lib/src/duplicate_finder.dart)). This script analyses whether we have the same method name twice in our string files and throws an error if we do.

Since we generate the name parameter we have to modify the logic.
If the name property is specified: We still use the name property. If it is not specified, we generate the name based on the rule above.

In a next step, we can also extend the script to fail when the name property was set and thus won't be generated.

```dart
  class MessageFinderVisitor extends GeneralizingAstVisitor {
  final File file;

  MessageFinderVisitor(this.file);

  Map<String, File> stringNames = Map();

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    var nodeName;
    try {
      var arguments =
          ((node.body as ExpressionFunctionBody).expression as MethodInvocation)
              .argumentList
              .arguments;
      var nameArgument = arguments.firstWhere((arg) {
        return arg is NamedExpression && arg.name.label.name == 'name';
      });
      if (nameArgument != null) {
        nodeName = ((nameArgument as NamedExpression).expression
                as SimpleStringLiteral)
            .value;
      } else {
        print('WARN: Named argument found for ${node.name.name} in $file');
      }
    } catch (_) {}

    if (nodeName == null) {
      var parentName = '';
      if (node.parent is ClassDeclaration) {
        parentName = '${(node.parent as ClassDeclaration).name.name}';
      } else {
        throw Exception('No parent name found for $node in $file');
      }
      nodeName = '${parentName}_${node.name.name}';
    }

    stringNames[nodeName] = file;
    return super.visitMethodDeclaration(node);
  }
}
```
