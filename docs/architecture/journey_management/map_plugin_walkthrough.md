---
layout: default
title: Map Plugin PoC Walkthrough
parent: Journey Management
grand_parent: Architecture
nav_order: 3
---

# Goal of Here Maps Plugin PoC

1. To integrate the HERE SDK into a Flutter Plugin
2. To understand how to wire up a Flutter Plugin using a `FlutterPlatformView`
3. To learn how the Google Maps Plugin accomplished this and if we can apply the pattern to our own
4. To pass information from the Flutter application layer down to the Native Layer to influence the Native view component
5. To visualize a HERE map view in a sample Flutter application with a map marker

# Creating the Flutter Map Plugin Project

`flutter create -t plugin -i swift -a kotlin 'plugin name'` (e.g. here-maps)

# Flutter Map Plugin Project Structure

- lib - contains the dart classes that make up the plugin content
- ios & android - contains the Swift & Kotlin native plugin classes
- example - Flutter sample app to show how the plugin is used in an application

# Here Map Plugin - iOS native implementation

- Start with the podspec. At the line `s.dependency 'Flutter'` add these two lines:
  - `s.dependency 'HEREMaps'` (or name of third party library to pull from pod install)
  - `s.static_framework = true`
- Now open the Runner project in Xcode and run it. This process will run a pod install on the third party library for you.

## Plugin Registrar

- Open ./ios/Classes/SwiftHereMapsPlugin.swift. This is the file that will setup the "bridge" from native to Flutter
- The registrar is what the native code will register itself with to expose either the interface or view to the Flutter Layer
  - In the example below, the registrar is passed into the `HereMapFactory` and then passed to the `HereMapController` so any other Method Channel's created can be added to it as well.
  - The `FlutterPlatformViewFactory` is created and registered with the plugin registrar
  - If desired, you can pass the registrar into a plugin initializer so you always have a reference to it in the event other plugin code needs to register method channels

```swift
public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "here_maps", binaryMessenger: registrar.messenger())
        let instance = SwiftHereMapsPlugin(channel: channel, registrar: registrar)
        let viewFactory = HereMapFactory(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(viewFactory, withId: "HereMapController")
    }
```

## Defining a Flutter Platform View Factory

The `FlutterPlatformViewFactory` must inherit from `NSObject` and `FlutterPlatformViewFactory` and it must implement the `create` and `createArgsCodec` public interfaces. The createArgsCodec interface must be defined as it is below, otherwise passing arguments from the Flutter Widget to the Plugin will not work.

```swift
public class HereMapFactory: NSObject, FlutterPlatformViewFactory {
    var pluginRegistrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.pluginRegistrar = registrar
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
        ) -> FlutterPlatformView {
        return HereMapController(
            rect: frame,
            viewId: viewId,
            arguments: args,
            registrar: self.pluginRegistrar
        )
    }
}
```

## Defining a Flutter Platform View

The `FlutterPlatformView` provides an interface for returning the view to the caller. In this case, the HERE `NMAView` will be returned. For the PoC, this class creates the map view, sets the center coordinates and zoom level. Some of this behavior is broken out into other classes and is something to consider when implementing this in the product. This was named as a controller for the PoC per the Google Maps example but also because this class is coordinating and manipulating the view rather than actually making content visible to the user.

```swift
public class HereMapController: NSObject, FlutterPlatformView {
    let mapViewFrame: CGRect
    let mapView: NMAMapView
    let viewId: Int64
    let channel: FlutterMethodChannel
    let pluginRegistrar: FlutterPluginRegistrar

    init(
        rect: CGRect,
        viewId: Int64,
        arguments: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        let channelName = "plugins.flutter.io/here_maps_\(viewId)"
        var centerCoords = NMAGeoCoordinates(latitude: 43.1979, longitude: -70.8737)
        var mapZoom:Float = 10.0

        mapViewFrame = rect
        self.mapView = NMAMapView(frame: mapViewFrame);
        self.viewId = viewId
        self.pluginRegistrar = registrar

        mapView.set(geoCenter: centerCoords, zoomLevel: mapZoom, animation: NMAMapAnimation.rocket)
        mapView.projectionType = .mercator
        mapView.copyrightLogoPosition = .bottomLeft

        super.init()

        self.channel.setMethodCallHandler(onMethodCall)
    }

    public func view() -> UIView {
        return mapView
    }

    func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Call method is: \(call.method)")
        if call.method == "map#waitForMap" {
            print("map#waitForMap")
            result(nil);
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}
```

You've now defined a basic native iOS implementation for creating a Here Map View for display in a widget!

# Here Map Plugin - Flutter Implementation

The Flutter implementation that interacts with the plugin native implementation is found in the plugin 'lib/' directory. The pattern from the Google Maps Plugin implementation is to have a plugin_name_flutter.dart barrel file (e.g. here_maps_flutter.dart) that imports all the Dart files found in the 'lib/src/' directory.

The 'lib/src' directory contains the Flutter components that makeup the Flutter/Dart side of the plugin. Following the Google Maps Plugin example, a `HereMap` Stateful Widget is implemented in here_map.dart. This widget is what will be created in the application that is using the HereMap Widget plugin.

## HereMap

The `HereMap` Stateful Widget is the interface that the Flutter application will instantiate when it creates the Map.

here_map.dart

```dart
typedef void MapCreatedCallback(HereMapController controller);

class HereMap extends StatefulWidget {
  const HereMap({
    Key key,
    @required this.initialCameraPosition,
    this.onMapCreated,
    this.gestureRecognizers,
  }) : assert(initialCameraPosition != null),
       super(key: key);

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final CameraPosition initialCameraPosition;

  final MapCreatedCallback onMapCreated;

  @override
  State createState() => _HereMapState();
}
```

## HereMapState

The `HereMapState` uses the defaultTargetPlatform to determine the `FlutterPlatformView` to create. The view type that was registered with the `FlutterPluginRegistrar` as part of the native implementation phase determines the `FlutterPlatformViewFactory` to call. Since there is only one `FlutterPlatformViewFactory`, then the `HereMapController` will be instantiated and called in order to create the Here `NMAView` as the `FlutterPlatformView`. The 'creationParams' Map object is the structure for passing JSON data between the Flutter and Native layers. In the PoC case, the initial camera position data is being passed which consists of the center position and zoom level.

The Build method looks at the defaultTargetPlatform and creates a `UIKitView` for iOS and `AndroidView` for Android. The `onPlatformViewCreated` callback function is called once the `UIKitView` is created and its at this point the `FlutterPlatformView` is created and the view returned to the `UIKitView`. The gesture recognizers that have been defined and passed in as well as the arguments to pass to the `FlutterPlatformView` and the codec for deserializing them.

here_map.dart

```dart
class _HereMapState extends State<HereMap> {
  final Completer<HereMapController> _controller =
    Completer<HereMapController>();

  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic> {
      'initialCameraPosition': widget.initialCameraPosition?._toMap(),
    };

    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'HereMapController',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  Future<void> onPlatformViewCreated(int id) async {
    final HereMapController controller = await HereMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );

    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated(controller);
    }
  }
}
```

## HereMapController

The `HereMapController` is a controller for a single `HereMap` instance. It holds a reference to the `HereMapState` and owns a method channel for responding to user input like gesture-oriented actions. The logic of the method channel will callback to methods either implemented by `HereMapState` or that were passed into the `HereMap` Widget by the application.

```dart
class HereMapController {
  HereMapController._(
    this.channel,
    CameraPosition initialCameraPosition,
    this._hereMapState,
  ) : assert(channel != null) {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<HereMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _HereMapState hereMapState,
  ) async {
    assert(id != null);
    final MethodChannel channel = MethodChannel('plugins.flutter.io/here_maps_$id');
    await channel.invokeMethod('map#waitForMap');
    return HereMapController._(
      channel,
      initialCameraPosition,
      hereMapState,
    );
  }

  final MethodChannel channel;

  final _HereMapState _hereMapState;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch(call.method) {
      default:
        throw MissingPluginException();
    }

  }
}
```

# Here Map Plugin -- Instantiated by a Flutter Application

The Here Map Plugin is instantiated by a Flutter Application by calling the interface defined by the plugins `HereMap` Widget. The application imports the plugin's barrel file and then calls the constructor, passing in any required arguments.

The `onMapCreated` callback is passed into the HereMap widget and is called in `onPlatformViewCreated`

```dart
import 'package:here_maps/here_maps_flutter.dart';

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: HereMap(
            key: Key('here map'),
            initialCameraPosition: _kInitialPosition,
            onMapCreated: onMapCreated,
          ),
        ),
      ),
    );
  }

  void onMapCreated(HereMapController controller) {
    setState(() {
      _isMapCreated = true;
    });
  }
```

# Open Questions

- Can the state that is managed by the Stateful Widgets of the plugin leverage Bloc instead?
- Need to clearly define the base of the Map Plugin (e.g. camera, markers, gestures? Map types or compass as well)
- Need to clearly define interfaces for the base plugin components and method channels to support user interactivity
- Noticed in iOS that all of the native plugin code needs to go into the Plugin.swift file. Additional swift files to break up the code do not seem to get picked up by the example project.
- Didn't get to Android so its unclear if there are any gotchas there that I might've missed.

# Summary

The PoC addressed all the goals as outlined at the top of the page:

1. We integrated a HERE SDK into a Flutter Plugin
2. We learned how to wire up a Flutter Plugin using a Flutter Platform View
3. We learned how the Google Maps Plugin pattern was applied and were able to use it as well!
4. We passed information from the Flutter application layer down to the Native Layer to influence the HERE Map View
5. We visualize a HERE map view in a sample Flutter application with a map marker

| -                                                                                     | -                                                                                     |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| ![description]({{site.baseurl}}/assets/images/architecture/here_map_plugin_view1.png) | ![description]({{site.baseurl}}/assets/images/architecture/here_map_plugin_view2.png) |

Hopefully this content gives you, the reader, a general idea of how to setup a Flutter plugin with a mapping SDK for iOS (HERE) and how to quickly get a prototype of a MapView in an app up and running. Admittedlly much of this was based off of the Google Maps example and there is work still to be done to wire up gestures and other basics to make the map more interactive.

# Online Resources

- [Medium article about defining Native UIs in Flutter](https://medium.com/@phoomparin/how-to-use-native-uis-in-flutter-with-swift-platform-view-8b4dc7f833d8)
- [Medium article about Google maps in Flutter](https://medium.com/flutter-io/google-maps-and-flutter-cfb330f9a245)
- [Flutter plugins GitHub Repo](https://github.com/flutter/plugins) - look for google_maps_flutter. This was used as a reference.
- [POC Here Maps Plugin repo](https://code.connected.bmw/Felix/here-maps)
