---
layout: default
title: Logging
parent: Core
grand_parent: Architecture
nav_order: 23
---

# Logging

The logging system in the app is relatively simple system but it is interconnected with many parts of the app and it makes it a bit difficult to describe in a structural way. In short, the purpose is to collect **technical** logs in our app so that we trace an event sequence if we need to understand what's been happening in the app at a particular moment of time. We do not write and save any technical logs when the app is compiled for App/Play Store distribution. It's only enabled when you debug the app locally or download a distribution from AppCenter.

## What do we log?

We separate all logged events into 3 groups: bloc events, custom events, & native events.

### Bloc events

Since we use [Bloc library](https://pub.dev/packages/flutter_bloc){:target="_blank"} for state management in the app we also have a main access point, one delegate endpoint for all blocs in the app - `BlocSupervisor.delegate`. Every time when there is a transitioning of a bloc state or error in a bloc we log it inside of [`ConnectedBlocDelegate`](https://code.connected.bmw/mobile20/mobile-connected/blob/master/shell/lib/src/shell.dart){:target="_blank"}.

### Custom events

This is the most used type of log event in the app. Pretty often you will see in the code something like:

```dart
try {
    // do something
} on Object catch (error) {
    logError(error);
}
```

This is an example of custom log in the app. Every time when a developer decides that this behavior of the app and following information are worth to be logged, he/she puts `logError()`, `logMessage()`, etc.

### Native events

We in our app use a significant amount of native plugins and communicate with them mostly through Method Channels. Some of them throw over a logging information but majority of them don't or do it partially. However, usually native plugins log the information in default "stdout" of each platform. In iOS it would be logs from NSLog().

We have special package for interception of those native logs - [native-logging-plugin-flutter](https://code.connected.bmw/library/native-logging-plugin-flutter){:target="_blank"}. Currently, we transfer native logs in our log system from following plugins:

- [AlexaInCar](https://code.connected.bmw/mobile20/alexaincar-flutter-plugin){:target="_blank"}
- [CarConnection](https://code.connected.bmw/library/carconnection-plugin-flutter){:target="_blank"}
- [DownloaderPlugin](https://code.connected.bmw/library/downloader-plugin-flutter){:target="_blank"}
- [Timber](https://github.com/JakeWharton/timber){:target="_blank"}

## Where do we log?

All our logs are been writing in one text file in the root of application directory for iOS or in the root of external storage directory for Android. An example of file name would be:

```
bmw-northAmerica-development-logs.txt
```

Here you can see the name of file depends on a flavor of the app.

## How do we log?

Generally speaking, for collecting logs we use [lumberdash](https://pub.dev/packages/lumberdash){:target="_blank"} package. The package describes a few type of log events and methods for them, accordingly:
- `logWarning()`
- `logFatal()`
- `logMessage()`
- `logError()`

The names of the functions are pretty self-explanatory. One moment worth to mention here is that each logged event is represented as a line in the log file (example):

```
2020-08-13T14:54:41.414523-5:00:00.000000 - [MESSAGE] VehicleFinderBloc, extras: {currentState: VehicleFinderInitial, event: VehicleFinderAdded, nextState: VehicleFinderInProgress}
```

Those lines go chronologically in the file because lumberdash writes them chronologically and lock the writing piece of code until the action is been done.

## What do we do with logs?

It would be strange if we collect our logs but wouldn't use them. In order to use them we need to send them on an email. This ability in the app exists only for app builds that aren't from Apple or Google stores. For sending logs you need to go to `Profile Tab -> About & Contact -> Debug -> Share Logs`. Here you also can delete current logs on the device. After tapping on Share Logs button you will be able to send then on email.

If log file size will be more then 10 mb the file will be splitted onto a few files each 10 mb or less.
You may see how a splitting mechanism works in [`FileSplitter`](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/lib/src/utils/file_splitter.dart){:target="_blank"} class.

## Initialization 

The app has special widget called [`Shell`](https://code.connected.bmw/mobile20/mobile-connected/blob/master/shell/lib/src/shell.dart){:target="_blank"}. Basically, it is the root widget of the app where a lot of services, blocs, etc been initialized at the first time. You may look at Shell as AppDelegate from iOS. Logging service is not an exception, it's also initialized in Shell.

[`LoggingConfiguration`](https://code.connected.bmw/mobile20/mobile-connected/blob/master/platform_sdk/lib/src/configuration/logging_configuration.dart){:target="_blank"} class is responsible for initialization of logging. It has two main functionality: get path to the log file (and create it if it's first launch) and setup lumberdash for proper working.