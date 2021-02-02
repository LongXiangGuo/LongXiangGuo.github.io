---
layout: default
title: Splash Screen
parent: Core
grand_parent: Architecture
nav_order: 22
---

# Splash Screen

This page describes more of a current state of the animated splash screen rather then finished documentation of it. The purpose of this page is to describe what work has been done, what's need to be done next, and potential caveats. For more details about the screen you may go to [NWAP-14763](https://atc.bmwgroup.net/jira/browse/NWAP-14763) task in Jira.

Draft PR of the screen you can see [here](https://code.connected.bmw/mobile20/joy-ui/pull/635).

## Structure

In the finished version of splash screen there are has to be 2 versions of splash screen:
- BMW (partially completed)
- MINI (not completed)

They are different from each other. From UI design and technical perspective.

### BMW

BMW splash screen is called `JoyBMWSplashScreen`. Currently it looks like that:

<img src="{{site.baseurl}}/assets/images/architecture/bmw_splash_screen.gif">


The screen contains 3 basic animations (AnimatedControllers):
- color's gradient animation
- opacity animation of background
- opacity animation of BMW logo

Chronological sequence of these animations is described here:

```dart
void startAnimation() {
  backgroundOpacityController.forward().then((_) {
    setState(() {
      startBackgroundColor = endBackgroundColor;
    });
    logoOpacityController.forward().then((_) {
      gradientController.forward().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
            logoOpacityController.reverse();
            backgroundOpacityController.reverse();
        },
      );
    });
  });
}
```

*NOTE: you should probably consider to use [Staggered animations](https://flutter.dev/docs/development/ui/animations/staggered-animations) from Flutter. It suits more to the task but it might be more difficult to implement.*

### MINI

Design of MINI splash screen drastically differentiate from BMW. If you look at [NWAP-14763](https://atc.bmwgroup.net/jira/browse/NWAP-14763) you will see how it should look like. However, from technical perspective, this screen has to be more easy to implement and here is why.

Basically, the design contains only one fairly difficult animation - actual animation of MINI logo. However, the design team has created this animation in Adobe After Effects and they even exported the animation into Lottie animation. Since it's a Lottie animation we can easily put this animation in our app. All other design components of the screen simply don't exist. It's just white splash screen. Lottie's animation file you can find [here](https://atc.bmwgroup.net/jira/secure/attachment/2040602/200901_MINI_LogoAnimation_LottieExport.zip). The file is password protected and you will need to ask for password.

## Issues

We have one "unresolved" issue with animated splash screen. If you open current app from the stores or from AppCenter you will see between moment of tapping on the icon and appearance of splash screen a white, blank splash screen. If we look at iOS only (it applies for Android, too) this white splash screen is native LaunchScreen, the screen before Main.StoryBoard.

If you look closely at design of animations you will see that there aren't any white "gaps" between tap on app icon and actual splash screen. It's smooth transition. Plus, the design for BMW is unlike MINI's splash screen design.

Unfortunately, we can't easily implement it in our app. Here is why.

Technically speaking, we can do whatever we want with native splash screens (LaunchScreen in iOS and SplashScreen in Android). We can change background colors, put some UI elements and so on. We can also make different native splash screens for different apps, if we consider BMW and MINI apps as natively different.

The key point is that separation between BMW and MINI apps goes in Flutter/Dart code. When we build our app, let's say for iOS, our host platform (iOS) knows nothing about what type of app (BMW or MINI) we're launching. Because of that, we can't easily distinguish MINI and BMW for our native splash screens and because of that we will always have one native splash screen design for both apps. Currently, it's just a white screen.

### Potential Solutions:

#### Use "custom variable" for Launch screen.

We, in our app, use a few "build variable" in .xcconfig files. It looks like:

```
FLUTTER_TARGET = lib/main/main_bmw_china_appstore.dart
FLUTTER_BUNDLE_ID = de.bmw.connected.mobile20.cn
FLUTTER_APP_ICON_SET_NAME = bmwappstore
FLUTTER_APP_NAME = My BMW
```

We can introduce one more variable - `LAUNCH_SCREEN`, put it in Info.Plist for `Launch screen interface file base name` key and create two LaunchScreen.storyboard for BMW and MINI accordingly. This approach seems pretty simple and elegant, plus it can work for Android, too.

#### Relay on app flavors and use the same approach as for icons

Since we have a flavors of the app and those flavors are represented natively, too, in theory, we can use them for using a different LaunchScreen.StoryBoard files for different flavors, accordingly. As an example, we can look on how we differentiate icons of app for different flavors in iOS.

<img src="{{site.baseurl}}/assets/images/architecture/xcode_app_icons.png">

If you look at image above you'll see the app has different icon sets for each flavor. All those icon sets get the name of the set from Asset Catalog Compiler option of Build Settings. More generally, all those options are generated from Build Configurations of the app, and more precisely, generated under one Project, for one Target - Runner. I'm highlighting this moment because it is easy to create different LaunchScreens for different targets. In this case you will have separate Info.Plist for each Target. We have only one Target - Runner and it's bound to Flutter building engine itself, so I'm not sure if we're able to create multiple targets in our app but it could be under consideration.