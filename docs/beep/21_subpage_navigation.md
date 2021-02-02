---
layout: default
title: "BEEP-21: Subpage Navigation"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 21
---

# BEEP-21: In-Tab,Subpage Navigation

### Authors

- Tim Chabot

## Summary

This proposal describes an approach for supporting sub-page navigation within a specific tab while retaining the visibility and functionality of the bottom tab bar as specified by UX design.

## Motivation

An authenticated user of the Eadrax application will see three tabs at the bottom of the screen representing Vehicle, Map and Profile content. Design has specified that navigation to pages within these tabs should retain the visiblity of the bottom tab bar while also providing the ability to navigation back to the prior page.

Currently, this is not supported per this screen capture:

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/21/BEEP_21_MapTabSubpageFavorites.png" width="25%" height="25%">
</div>

What is being asked for is the following:

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/21/BEEP_21_VehicleTabMain.png" width="25%" height="25%">
</div>
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/21/BEEP_21_VehicleTabSubpageVehicleFinder.png" width="25%" height="25%">
</div>
<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/21/BEEP_21_ProfileTabSubpageAboutAndContact.png" width="25%" height="25%">
</div>

### Detailed description

Per Flutter documentation on [Navigators](https://api.flutter.dev/flutter/widgets/Navigator-class.html) and an example found on [Medium](https://medium.com/flutter/getting-to-the-bottom-of-navigation-in-flutter-b3e440b9386), each of the tabs require their own Navigator rather than relying on the Material App 'onGenerateRoute' defined in the shell for the whole application.

<div style="display: inline">
    <img src="{{site.baseurl}}/assets/images/beep/21/BEEP_21_TabNavigatorPattern.png" width="75%" height="75%">
</div>

I created a small [POC](https://code.connected.bmw/Tim/root_scaffold_nav_poc) to evaluate this behavior and prove it out. When relying only on the MaterialApp onGenerateRoute method that contained all possible routes for the app, the subpage navigation resulted in the tab bar disappearing, most likely due to Flutter treating the navigation of these subpages as independent from the tabbar. When defining a Navigator as the root of the tab content itself, the tab bar remained in view no matter how many levels down the navigation goes. The documentation describes that the tab's navigator is maintaing its own local naviagtion stack which provides the desired UX experience.

I then applied this to the mobile-connected codebase in the following [branch](https://code.connected.bmw/mobile20/mobile-connected/tree/poc_navigation). The Vehicle and Profile tabs were experimented with as they both followed the same pattern of defining their respective tab's routes, route names and a 'routing table' of sorts with the static onGenerateRoute method.

The basic approach (seen in code snippets below) is to create a StatelessWidget class with the following:

- Navigator widget with private navigator key, initialRoute of root '/', and tab routing table, which in the the case of Profile Tab is it's onGenerateRoute static method found in ProfileRoutes.
- WillPopScope widget wrapping the Navigator to properly handle back on both iOS and Android

The initial route must be '/' otherwise the Navigator will parse '/' as one navigation step and the rest of the route name as another per the onGenerateRoute routing table. In the case of ProfileRoutes.onGenerateRoute, the '/' route will result in the Profile module being loaded as it was before from BottomBarMenuPage.

```dart
// ProfileRoutes adjustment with root route being the module load step
class ProfileRoutes {
  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    switch (routeName) {
      case '/':
        return MaterialPageRoute<Widget>(
            builder: (context) => PlatformSdk.findModule(
                  ModuleEntryInfo(
                    routeName: '/profile',
                    arguments: BlocProvider.of<VehicleBloc>(context),
                  ),
                ));

----------------------

// Profile Navigator loads the set of routes that the tab will handle and loads root as the initial route
class ProfileNavigator extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: ProfileRoutes.onGenerateRoute,
      ),
    );
  }

  // Provides safe back navigation for Android
  Future<bool> _handleWillPop() async {
    final navigatorState = _navigatorKey.currentState;
    if (navigatorState == null) {
      return true;
    } else {
      final didPop = await navigatorState.maybePop();
      return !didPop;
    }
  }
}

----------------------

// Bottom Bar Menu Page calls the Navigator
if (state is BottomBarMenuProfileTabSuccess) {
    return ProfileNavigator();
}
```

## Conclusion

Given the findings from the two POCs, the proposal is to create a Navigator for each module that is the root of a tab (e.g. Vehicle, Destination and Profile) in the BottomBarMenuPage widget to provide the desired UX experience once the Destination Module adjusts to the routing pattern use in Vehicle and Profile modules.
