---
layout: default
title: Getting Started
parent: Onboarding
nav_order: 1
---

# Getting Started

In order to get started, you will need to install:

- A computer running `macOS`.
- [Android Studio, the latest stable version available](https://developer.android.com/studio/)
- [Xcode, the latest stable version available](https://developer.apple.com/xcode/)
- [Dart, latest version](https://dart.dev/get-dart)
- [Flutter, the version used in our CI/CD environment](https://flutter.io)
  - _Note_: Use the version of the Docker container used in the pipeline. You can see it [here in this link](https://code.connected.bmw/docker/bmw-flutter-android/blob/master/Dockerfile)
  - `cd` into your directory where you installed Flutter and run: `flutter channel *.*.*` (where `*.*.*` is the version number, e.g., `1.17.3`) and then `flutter upgrade`
  - If the previous step doesn't work, try this:
    - `cd` into your directory where you installed Flutter and run: `git checkout *.*.*` (where `*.*.*` is the version number, e.g., `1.17.3`) and then `flutter doctor`
- [Git](https://git-scm.com)
- [Homebrew](https://brew.sh)
- [LCOV](http://ltp.sourceforge.net/coverage/lcov.php)
- A terminal: [iTerm](https://www.iterm2.com) with [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) is recommended

## Getting your environment ready

### Setting Up Admin Rights On Your Machine (skip if you already have Admin rights)

By default you will most likely not have Administrator rights on your machine. These must be requested via [WUSS (Workplace User Self Service)](https://wuss.bmwgroup.net). Go to the link and follow the steps below:

1. Click on on `Show all` under the `Software` tab
2. Above the search bar, make sure your computer is selected (It will say "Search and install Software for Computer: LCHIxxxxxx"), if it's not selected go ahead and select your computer.
3. In the search bar, type in `admin`
4. Select `macOS: Lokale Adminrechte` and click on `install`
5. You will be prompted for a reason, **copy and paste exactly this**:

`Hi, I work for the BMW Technology group in Chicago as a software engineer. As part of the project requirements I need to install different software to develop code for the Mobile 2.0 project. Frequent non-standard software updates and security patches are required. Please grant local admin rights for my Mac so that I can proceed with my job requirements. Note: This is request for my Q-Account on Mac. Duration: 365 days`

### Setting up Flutter

Add the following to your `.zshrc` file (or `.bashrc` if you do not run ZSH)
Use the command `vim ~/.zshrc` :

```bash
# Android Configuration
export ANDROID_HOME=/Users/<your-q-number>/Library/Android/sdk
PATH=$PATH:$ANDROID_HOME/build-tools
PATH=$PATH:$ANDROID_HOME/platform-tools
PATH=$PATH:$ANDROID_HOME/tools
PATH=$PATH:$ANDROID_HOME/tools/bin/

# Flutter
export FLUTTER_HOME=/Users/<your-q-number>/development/flutter
PATH=$PATH:$FLUTTER_HOME/bin:$PATH

# Dart (as part of Flutter)
export DART_HOME=/Users/<your-q-number>/development/flutter/bin/cache/dart-sdk
PATH=$PATH:$DART_HOME/bin:$PATH
PATH=$PATH:/Users/<your-q-number>/.pub-cache/bin:$PATH

# VS Code
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
```

These commands will add the different Android tools, `dart` and `flutter` to your path, simplifying your development.

Now run `flutter doctor`, and make sure you obtain an output similar to this:

```bash
➜  mobile-docs git:(onboarding) ✗ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.5.4, on Mac OS X 10.13.6 17G65, locale en-US)
[✓] Android toolchain - develop for Android devices (Android SDK 28.0.3)
[✓] iOS toolchain - develop for iOS devices
[✓] Android Studio (version 3.3)
[✓] VS Code (version 1.30.2)
[!] Connected device
```

What you can infer from there is that we are running _Flutter_ from the **stable channel**; in your case, it should be pointing to the latest stable version.

#### Checking/Setting Your Flutter Version

- To verify your Flutter channel, type `flutter channel`
- To change your channel, type: `flutter channel stable` where `stable` can be replaced with `beta` `master` etc. For more information, check out [Flutter build release channels](https://github.com/flutter/flutter/wiki/Flutter-build-release-channels)

### Installing Node.JS and Setting up NPM

First, make sure to have [Node.JS](https://nodejs.org/en/download/) installed.

We use NPM to host some packages privately. You will need to set your npm registry to our private registry. In your terminal run the following command:

`npm set registry http://btcnpmregistry.centralus.cloudapp.azure.com`

### Configuring VS Code

We use [VS Code](https://code.visualstudio.com) as our primary IDE. While others might be used as well, such as Android Studio, we do not officially support it for Flutter development, since all of our tools are just for VS Code.

Make sure you install the Dart and Flutter extensions for VS Code:

- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

Some other extensions that might be useful are:

- [Rainbow Brackets](https://marketplace.visualstudio.com/items?itemName=2gua.rainbow-brackets)
- [vscode-icons](https://marketplace.visualstudio.com/items?itemName=robertohuertasm.vscode-icons)

In order to use [Bloc](https://felangel.github.io/bloc/#/), it is very handy to use this boileplate generator:

- [Bloc Code Generator](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc)

### Setting up Docker

[Local Docker Setup](https://pages.code.connected.bmw/runtime/docs/developer-guides/docker/)
