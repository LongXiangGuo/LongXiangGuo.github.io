---
layout: default
title: Map Plugin Architecture
parent: Journey Management
grand_parent: Architecture
nav_order: 2
---

# Architecture
The Flutter plugin architecture can be broken into three layers:
1. Native Platform Layer
2. Flutter Plugin Layer
3. Flutter Application Layer

The image below is meant to represent the primary components involved in the HERE maps PoC which helped give us a view into the structure and flow of the plugin architecture.

![description]({{site.baseurl}}/assets/images/architecture/here_map_plugin_architecture.png)

## Native Platform Layer
In general, the Native Plugin class contains a `FlutterPluginRegistrar` that is used to register `FlutterPlatformViewFactory` for creating a `FlutterPlatformView` and Method Channels for exposing interfaces between the Native and Flutter layers.

The `FlutterPlatformViewFactory` is responsible for creating a specific `FlutterPlatformView`

The `FlutterPlatformView` is responsible for creating the native view components and managing lifecycle and information around that native view.

## Flutter Plugin Layer

The Flutter Plugin Layer is responsible for providing the Widget, State and Method Channels for communicating with the Native Platform Plugin.  For a `FlutterPlatformView`, it will look at the defaultTargetPlatform and create either a `UIKitView` or an `AndroidView`.  The constructor for those take the following:
1. A callback for when the PlatformView is created
2. A set of gesture recognizers
3. A set of JSON-formatted arguments
4. A codec for serializing/deserializing the arguments

A controller class will utilize a method channel to invoke and handle calls from the Native Platform.  It will also implement any related plugin types as defined by the Flutter Plugin Barrel File.

## Flutter Application Layer
The Flutter Application Layer is where a Widget instantiates the Plugin, passes information to it and provides callbacks to the Flutter Plugin Layer for executing operations and manipulating components when appropriate.
