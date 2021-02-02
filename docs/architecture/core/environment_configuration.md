---
layout: default
title: Environment Configuration
parent: Core
grand_parent: Architecture
nav_order: 2
---

# Environment Configuration Design

The goal of this is to be able to have an application that supports multiple build configurations that correspond to different backend environments.

## Environment Structure

```bash
├── lib
│   ├── main
│   └── connected_app_runner.dart
│   └── host_system_detector.dart
```

### Startup Configuration
[Startup Configuration]('https://code.connected.bmw/mobile20/startup-configuration') is a dart package.

Contains `ConnectedStartupConfiguration` which extends `StartupConfiguration` and is created based on `Brand`, `Region`, `Environment`, `Mode`, and `HostSystem`.

```dart
enum Brand { bmw, mini }
enum Region { northAmerica, restOfWorld, china }
enum Environment { daily, development, integration, production }
enum Mode { mock, real }
enum HostSystem { ios, android }
```

`ConnectedStartupConfiguration` is used to simply create objects with properties that depend on the chosen build invariant. A [factory constructor](https://sites.google.com/site/dartlangexamples/learn/class/constructors/factory-constructor) is used here because we don't want to always create new instances of this class.

### Host System Detector

Contains `getHostSystem()` which simply detects the platform that the build is being run on and returns the enum type.

### Connected App Runner

The connected app runner takes the `ConnectedStartupConfiguration` and uses the configuration to setup [Lumberdash](https://github.com/bmw-tech/lumberdash), OMC Client, Http Client, Repositories, Theme, etc.

### Main

Contains `main.dart` files for each build variant

#### Daily

- `main_bmw_china_daily.dart`
- `main_mini_china_daily.dart`
- `main_bmw_northAmerica_daily.dart`
- `main_mini_northAmerica_daily.dart`
- `main_bmw_restOfWorld_daily.dart`
- `main_mini_restOfWorld_daily.dart`

#### Development

- `main_bmw_china_development.dart`
- `main_mini_china_development.dart`
- `main_bmw_northAmerica_development.dart`
- `main_mini_northAmerica_development.dart`
- `main_bmw_restOfWorld_development.dart`
- `main_mini_restOfWorld_development.dart`

### Integration

- `main_bmw_china_integration.dart`
- `main_mini_china_integration.dart`
- `main_bmw_northAmerica_integration.dart`
- `main_mini_northAmerica_integration.dart`
- `main_bmw_restOfWorld_integration.dart`
- `main_mini_restOfWorld_integration.dart`

### Production

- `main_bmw_china_production.dart`
- `main_mini_china_production.dart`
- `main_bmw_northAmerica_production.dart`
- `main_mini_northAmerica_production.dart`
- `main_bmw_restOfWorld_production.dart`
- `main_mini_restOfWorld_production.dart`

### Mock
- `main_bmw_china_daily_mock.dart`
- `main_mini_china_daily_mock.dart`
- `main_bmw_northAmerica_daily_mock.dart`
- `main_mini_northAmerica_daily_mock.dart`
- `main_bmw_restOfWorld_daily_mock.dart`
- `main_mini_restOfWorld_daily_mock.dart`


### Example Main

```dart
// main_bmw_china_daily.dart
import 'package:startup_configuration/startup_configuration.dart';
import 'package:mobile_connected/connected_app_runner.dart';
import 'package:mobile_connected/host_system_detector.dart';

void main() {
  run(
    ConnectedStartupConfiguration.bmwChinaDaily(getHostSystem()),
  );
}
```