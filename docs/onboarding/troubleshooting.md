---
layout: default
title: Troubleshooting
parent: Onboarding
nav_order: 5
---

# Troubleshooting

## Building the Flutter App

### 'flutter packages get' it's failing

[pubspec]: https://code.connected.bmw/mobile20/mobile-connected/blob/master/pubspec.lock

If you see the following error (or similar) when trying to resolve the dependencies:

```shell
$ flutter packages get
Downloading package sky_engine...   0.6s
Downloading common tools...         1.8s
Downloading common tools...         1.9s
Downloading darwin-x64 tools...     5.8s

Because every version of flutter_test from sdk depends on args 1.5.2 and mobile_connected depends on args 1.5.0, flutter_test from sdk is forbidden.
So, because mobile_connected depends on flutter_test any from sdk, version solving failed.
Running "flutter pub get" in mobile-connected...
pub get failed (1; So, because mobile_connected depends on flutter_test any from sdk, version solving failed.)
```
You might want to change your flutter and dart version to match the same that is showing in [pubspec.lock][pubspec] file.

Try to look at the end of pubspec.lock file to see what is the current SDK version. It should be something like this:

```
sdks:
  dart: ">=2.5.0 <3.0.0"
  flutter: ">=1.9.1+hotfix.5 <2.0.0"
```

You can easily change your flutter and dart version by executing the following in your console:

```
$ flutter version 1.9.1+hotfix.5
Switching Flutter to version 1.9.1+hotfix.5
...

Flutter 1.9.1+hotfix.5 • channel unknown • unknown source
Framework • revision 1aedbb1835 (4 months ago) • 2019-10-17 08:37:27 -0700
Engine • revision b863200c37
Tools • Dart 2.7.0
```

After that, give another try to resolve the project's dependencies:

```shell
$ flutter packages get
```

### Why are there thousands of errors?

Try running `dart ./scripts/cli/cli.dart getPackages`

### `dart ./scripts/cli/cli.dart getPackages` isn't running

Try running this in your terminal, at the root directory of the flutter project:

```bash
flutter packages get
```

If that succeeds, try running `getPackages` again:

```dart
dart ./scripts/cli/cli.dart getPackages
```

### `dart ./scripts/cli/cli.dart getPackages` is running, but it's failing

Go into your main user folder, delete the pubcache folder at `/Users/<your-q-number>/.pubcache`

Try running `getPackages` again. If it isn't running any more, please see the above troubleshooting guide.

## Running the Flutter App

### Swift 3 @objc Inference Warning

If you try to run the app and see the following warning:

```bash
warning: The use of Swift 3 @objc inference in Swift 4 mode is deprecated. Please address deprecated @objc inference warnings, test your code with “Use of deprecated Swift 3 @objc inference” logging enabled, and then disable inference by changing the "Swift 3 @objc Inference" build setting to "Default" for the "Runner" target. (in target 'Runner' from project 'Runner')
```

Follow this steps to solve it:

* Open `ios/Runner.xcworkspace`
* Select Runner project and go to `Built Settings` tab
* Search for `Inference`
* Change it from `On` to `Default`
* Done. Try to run the project again.

[Reference](https://github.com/Baseflow/flutter-geolocator/issues/28)

### Multiple commands produce '/build/ios/Debug-iphonesimulator/Runner.app/Frameworks/Flutter.framework Error

If you try to run the app and see the following error:

```bash
Running pod install...                                              7.0s
Running Xcode build...                                          
Xcode build done.                                           10.6s
Failed to build iOS app
Error output from Xcode build:
↳
    ** BUILD FAILED **


Xcode's output:
↳
    error: Multiple commands produce '<path_to_your_project>/build/ios/Debug-bmwrestofworlddevelopment-iphonesimulator/Runner.app/Frameworks/Flutter.framework':
    1) Target 'Runner' has copy command from '<path_to_your_project>/ios/Flutter/Flutter.framework' to '<path_to_your_project>/build/ios/Debug-bmwrestofworlddevelopment-iphonesimulator/Runner.app/Frameworks/Flutter.framework'
    2) That command depends on command in Target 'Runner': script phase “[CP] Embed Pods Frameworks”
```

Add the following line in your Runner Podfile `ios/Podfile`:

```ruby
# Prevent Cocoapods from embedding a second Flutter framework and causing an error with the new Xcode build system.
install! 'cocoapods', :disable_input_output_paths => true
```

[Reference](https://github.com/flutter/flutter/issues/20685)

### Command PhaseScriptExecution failed with a nonzero exit code

If you try to run the app and see the following error:

```bash
Running Xcode build...                                          
Xcode build done.                                           26.4s
Failed to build iOS app
Error output from Xcode build:
↳
    ** BUILD FAILED **


Xcode's output:
↳
    $HOME/Library/Developer/Xcode/DerivedData/Runner-gmwylpgzjaxpqecvfwvkaroitwyo/Build/Intermediates.noindex/Runner.build/Debug-bmwrestofworlddevelopment-iphonesimulator/Runner.build/S
cript-58C8402B23272C8F00683F56.sh: line 3: <path_to_your_project>/ios/Pods/Fabric/run: No such file or directory
    Command PhaseScriptExecution failed with a nonzero exit code
    note: Using new build system
    note: Planning build
    note: Constructing build description

Could not build the application for the simulator.
```

We need to update our Fabric script configuration in order to build sucessully.

Follow this steps to solve it:

* Open `ios/Runner.xcworkspace`
* Select Runner project and go to `Built Phases` tab
* Open `Fabric Crashlytics` section
* check `Run script only when installing`
* Done. Try to run the project again.

[Reference](https://github.com/flutter/flutter/issues/23465)

## Running Integration Tests

### "Could not connect to lockdownd" when using Simulator

Example output:

```bash
ideviceinfo returned an error:
ERROR: Could not connect to lockdownd, error code -17
```

If you have a device plugged into your computer, **please try unplugging your phone**. This fixes this problem in most cases.

If that doesn't work, you may want to try this:

```bash
brew update
brew uninstall --ignore-dependencies libimobiledevice
brew uninstall --ignore-dependencies usbmuxd
brew install --HEAD usbmuxd
brew unlink usbmuxd & brew link usbmuxd
brew install --HEAD libimobiledevice
brew link --overwrite libimobiledevice
brew install ideviceinstaller
brew link --overwrite ideviceinstaller
```

### Receive "Driver tests failed: 254" error after compiling

1. First, try turning your machine off and on again
2. If that doesn't work, try uninstalling / re-installing your "Flutter" and "Dart" plugins
   * For Android Studios users, these plugins can prevent Integration Tests from running
3. If all else fails, delete your local repo (**back up any of your changes first!**) and re-clone the repo
   * This is due to some of the local, _.gitignore_'d files not being able to regenerate properly
   * Even trying `flutter clean` and re-building didn't work, anecdotally

If this occurs to you, and you find another solution easier than **#3**, please update this document.
