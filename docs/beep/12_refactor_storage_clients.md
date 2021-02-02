---
layout: default
title: "BEEP-12: Refactor Storage Clients"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 12
---

# BEEP-12: Refactor Storage Clients

### Authors

- Felix Angelov <felix.angelov@bmwna.com>

## Summary

The current mobile-connected client has multiple `storage` clients which all wrap `flutter_secure_storage`. This forces repositories to have a dependency on Flutter which is not desirable. Instead, if we had a generic `Storage` interface which a `ConnectedSecureStorage` implementation we would be able to decouple the repostories from Flutter and have a single reusable `Storage` client instead of multiple.

## Motivation

As we started building the `Platform SDK` as part of the modularization phase, it became clear that repositories should not have a dependency on Flutter and the current storage client setup is not scalable (multiple storage clients for each use-case).

### Detailed description

- Create a generic storage abstraction as a standalone package

```dart
import 'package:meta/meta.dart';

/// A platform-agnostic storage abstraction
/// which can be implemented for multiple storage clients.
abstract class Storage {
  /// Returns value stored for the provided [key].
  Future<String> read({@required String key});

  /// Stores the provided [key], [value] pair.
  Future<void> write({@required String key, @required String value});

  /// Removes the [key], [value] pair.
  Future<void> delete({@required String key});

  /// Removes all [key], [value] pairs.
  Future<void> deleteAll();
}
```

- Create a `ConnectedSecureStorage` implementation of `Storage`.

```dart
import 'package:storage/storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A Flutter secure storage client which uses `flutter_secure_storage`
/// and implements the generic `storage` interface.
class ConnectedSecureStorage implements Storage {
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

  @override
  Future<void> delete({String key}) => _flutterSecureStorage.delete(key: key);

  @override
  Future<void> deleteAll() => _flutterSecureStorage.deleteAll();

  @override
  Future<String> read({String key}) => _flutterSecureStorage.read(key: key);

  @override
  Future<void> write({String key, String value}) => _flutterSecureStorage.write(
        key: key,
        value: value,
      );
}
```

- Refactor all repositories to have a dependency on the abstract `storage` to decouple them from Flutter.

- Remove specific storage clients (`store_review_storage`, `token_storage`, `user_storage`, `vehicle_storage`). The repository can handle maintaining the keys for each of the storage entries.
