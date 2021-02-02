---
layout: default
title: DriveRecorder
parent: Vehicle
nav_order: 6
grand_parent: Architecture
---

# DriveRecorder

DriveRecorder announces a service to the DriveRecorder OAP on the car. This service allows users to download videos from the car to the gallery of the phone.

## Client Architecture

### Internal Dependencies

The client uses the following internally developed packages for DriveRecorder.

| Name                                                                                          | Platform | Maintaining Team | Description                                                                      |
| --------------------------------------------------------------------------------------------- | -------- | ---------------- | -------------------------------------------------------------------------------- |
| [CarConnection Plugin](https://code.connected.bmw/library/carconnection-plugin-flutter)       | Flutter  | ForcePushers     | The native communication plugin to the CarConnection SDK in iOS and Android.     |
| [JoyRecorder Plugin](https://code.connected.bmw/mobile20/joyrecorder-flutter-plugin)             | Flutter  | theGradles     |  A plugin for saving video files in the gallery           |
| [Protobuf Native Bridge](https://code.connected.bmw/library/protobuf-native-bridge-generator) | Flutter  | ForcePushers     | Strongly typed code generation for the communication between native and flutter. |
| [iOS CarConnection SDK](https://code.connected.bmw/library/carconnection-sdk)                 | iOS      | ForcePushers     | DeviceLink implementation and RSU helpers based on the MGU Connection Kit        |
| [iOS MGU ConnectionKit](https://code.connected.bmw/a4a/ios-connected-connectionkit)           | iOS      | theGradles  | The communication framework for iOS                                              |
| [Android CarConnection SDK](https://code.connected.bmw/library/carconnection-sdk-android)     | Android  | ForcePushers     | DeviceLink implementation and RSU helpers based on the Android Connected SDK     |
| [Android Connected SDK](https://code.connected.bmw/a4a/android-connected-mgu-sdk)             | Android  | theGradles   | The communication Framework for Android                                          |

### Overview

<div class="mermaid">
graph TD
    subgraph Native
        F["iOS CarConnection SDK"]
        G["Android CarConnection SDK"]
    end
    subgraph Flutter
        subgraph Plugins
            D["JoyRecorder"]
            E["Car Connection"]-->F
            E-->G
        end
        subgraph Repository
            C["DriveRecorder Repository"]-->D
            C-->E
        end
        subgraph Headless Service Bloc
            B["DriveRecorder Bloc"]-->C
            A["CarConnectionBloc"]-->B
        end
    end
</div>

### DriveRecorder State Machine

<div class="mermaid">
stateDiagram
    [*] --> DriveRecorderInitial
    DriveRecorderInitial --> DriveRecorderServiceAnnounceSuccess : User logged in / connected with car

    DriveRecorderServiceAnnounceSuccess --> DriveRecorderFailure : Service got rejected 
    DriveRecorderServiceAnnounceSuccess --> DriveRecorderInitial : User logged out / diconnected from car


</div>