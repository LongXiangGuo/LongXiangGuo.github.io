---
layout: default
title: "How to implement native communication with protobuf"
parent: Recipes
nav_order: 12
---

# How to implement native communication with protobuf

## Motivation

Sending and receiving data between Flutter and native code (Android and iOS) is done via Method- and EventChannels. No strongly typed data contract between the different sides exists, which allows errors to creep in, e.g. with spelling or data types, that are only caught during runtime.

[protobuf-native-bridge-generator](https://code.connected.bmw/library/protobuf-native-bridge-generator) offers a strongly-typed alternative that allows generating code for Dart, Android (Kotlin) and iOS (Swift) which handles the communication between the different layers.

## Description

### Proto file

To generate the communication layer you need to write a `*.proto` file with the definition of your services:

```protobuf
syntax = "proto3";
// Required for defining the method direction & custom channel name
import "FlutterRPC/FlutterRPC.proto";
option java_multiple_files = true;
option java_package = "com.example.yourpackagename";

service DoSomethingService {

    // Custom Channel name (optional)
    option (channel_name) = "com.DoSomethingService.Channel";

    // A message which contains some text and is used as a method parameter and return type.
    message ProtoMessage {
      string text = 1;
    }

    // A message directed to the platform with an argument.
    rpc DoSomethingOnPlatform (ProtoMessage) returns (RPCVoid) {
      option (method_direction) = METHOD_DIRECTION_PLATFORM;
    }

    // A message directed to Flutter without an argument which returns a result message.
    rpc DoSomethingOnFlutter (RPCVoid) returns (ProtoMessage) {
      option (method_direction) = METHOD_DIRECTION_FLUTTER;
    }

    // A message directed to either the platform or to Flutter without an argument.
    rpc DoSomethingOnBoth (RPCVoid) returns (RPCVoid) {
      option (method_direction) = METHOD_DIRECTION_BOTH;
    }
}
```

As you can see, you can specify data objects for method parameters and return types and also define the communication direction (to platform, to flutter, both).

### Generating code

After defining the proto file, generate the platform specific files that you can then use in your code. If you have Docker installed on your computer, the easiest way is to use the `bmw-flutterrpc` image:

```bash
# replace 'your_protofile' and 'your_package' with your project's values

docker pull btcdocker.azurecr.io/bmw-flutterrpc:latest
docker run -v $(pwd)/your_protofile.proto:/tmp/protofile.proto -v $(pwd)/generated:/tmp/generated -it --rm btcdocker.azurecr.io/bmw-flutterrpc /bin/bash -c "cd FlutterRPC; sed -i -e 's/change_me/your_package/g' FlutterRPC.proto; flutterRPC FlutterRPC.proto; cd ..; flutterRPC your_protofile.proto"
```

This will generate files for all platforms in a `generated` directory in your current working directory.

[Alternatively you can setup all required packages yourself and call protobuf directly.](https://code.connected.bmw/library/protobuf-native-bridge-generator#setup-on-osx) This will allow you to generate files platform by platform and specify the target directory.

### Implementing abstract classes

The generated files will include abstract classes or interfaces with the suffix `BridgeBase` (Dart), `Delegate` (Swift) or `Listener` (Android) that you need to implement with `TODOs` as markers. Here is one example for Dart with the proto file used earlier:

```dart
class DoSomethingServiceBridge extends DoSomethingServiceBridgeBase {
  @override
  Future<ProtoMessage> onDoSomethingOnFlutter() async {
    // TODO: Implement to something on flutter
    print('onDoSomethingOnFlutter');
    return ProtoMessage()
      ..text = 'My Message'
  }

  @override
  Future<void> onDoSomethingOnBoth() async {
    // TODO: Implement do something on both
    print('onDoSomethingOnBoth');
  }

  // Calling methods to the platform
  void exampleDoSomething() async {
    var message = ProtoMessage()
      ..text = 'My Message'
    await doSomethingOnPlatform(message);
    await doSomethingOnBoth();
  }
```

Finally, move the generated files to their platform's corresponding folder and call them in your code.

```bash
rm -r ./path_to_your_plugin/ios/Classes/generated/* && mv ./generated/iOS/* ./path_to_your_plugin/ios/Classes/generated
rm -r ./path_to_your_plugin/lib/src/generated && mv ./generated/Flutter ./path_to_your_plugin/lib/src/generated
rm -r ./path_to_your_plugin/android/src/generated/main/* && mv ./generated/Android/* ./path_to_your_plugin/android/src/generated/main/
```

## More information

For more extensive documentation and example code, check out [protobuf-native-bridge-generator](https://code.connected.bmw/library/protobuf-native-bridge-generator).
