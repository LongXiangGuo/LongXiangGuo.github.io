---
layout: default
title: Remote Software Upgrade
parent: Vehicle
nav_order: 5
grand_parent: Architecture
---

# Remote Software Upgrade (RSU)

{: .no_toc }
Remote Software Upgrade (RSU) allows users to download an upgrade for his car to his phone. Afterwards this upgrade is transferred to the head unit while driving. As soon as all packages have been uploaded and the vehicle has been secured the upgrade can be installed.

## Table of contents

{: .no_toc .text-delta }

1. TOC
   {:toc}

## UX

The current UX can be found here [Current RSU UX](https://atc.bmwgroup.net/confluence/x/kBXBI).

## Client Architecture

### Internal Dependencies

The client uses the following internally developed packages for RSU.

| Name                                                                                          | Platform | Maintaining Team | Description                                                                      |
| --------------------------------------------------------------------------------------------- | -------- | ---------------- | -------------------------------------------------------------------------------- |
| [CarConnection Plugin](https://code.connected.bmw/library/carconnection-plugin-flutter)       | Flutter  | ForcePushers     | The native communication plugin to the CarConnection SDK in iOS and Android.     |
| [Downloader Plugin](https://code.connected.bmw/library/downloader-plugin-flutter)             | Flutter  | ForcePushers     | Native implementation of background downloads for Flutter                        |
| [Protobuf Native Bridge](https://code.connected.bmw/library/protobuf-native-bridge-generator) | Flutter  | ForcePushers     | Strongly typed code generation for the communication between native and flutter. |
| [iOS CarConnection SDK](https://code.connected.bmw/library/carconnection-sdk)                 | iOS      | ForcePushers     | DeviceLink implementation and RSU helpers based on the MGU Connection Kit        |
| [iOS MGU ConnectionKit](https://code.connected.bmw/a4a/ios-connected-connectionkit)           | iOS      | CGI (external)   | The communication framework for iOS                                              |
| [Android CarConnection SDK](https://code.connected.bmw/library/carconnection-sdk-android)     | Android  | ForcePushers     | DeviceLink implementation and RSU helpers based on the Android Connected SDK     |
| [Android Connected SDK](https://code.connected.bmw/a4a/android-connected-mgu-sdk)             | Android  | CGI (external)   | The communication Framework for Android                                          |

### Overview

<div class="mermaid">
graph TD
    subgraph Native
        I["iOS CarConnection SDK"]
        J["Android CarConnection SDK"]
    end
    subgraph Flutter
        subgraph Plugins
            E["Downloader"]
            F["Car Connection"]-->I
            F-->J
        end
        subgraph Repository
            D["Remote Software Upgrade Repository"]-->E
            D-->F
        end
        subgraph Headless Service Bloc
            C["Remote Software Upgrade Service Bloc"]-->D
        end
        subgraph UI Blocs
            A["Remote Software Upgrade Bloc"]-->C
            B["Remote Software Upgrade Vehicle Tab Bloc"]-->C
        end
    end
</div>

### RSU State Machine

Note: While an upgrade is available the status of the back end is checked every 2 minutes.

<div class="mermaid">
stateDiagram
    [*] --> RSUInitial
    RSUInitial --> RSUNoUpgradeInitial : RSU Supported
    RSUNoUpgradeInitial --> RSUNoUpgradeInitial : Check for Upgrade (on app resumed, on pull-to-refresh)
    RSUNoUpgradeInitial --> WaitingForDownload : Upgrade Available
    WaitingForDownload --> Downloading : Allowed to Download
    Downloading --> DownloadPaused : User paused
    DownloadPaused --> Downloading : User resumed
    Downloading --> WaitingForDownload : Connectivity lost / User Canceled
    Downloading --> WaitingForUpload :  Download finished
    WaitingForUpload --> Uploading: Car Connected
    Uploading --> WaitingForUpload: Connectivity lost
    Uploading --> ReadyToInstall: Preparation finished
    ReadyToInstall --> Success : Upgrade Installed
    Success --> RSUNoUpgradeInitial : After 2 Weeks
    WaitingForDownload --> RSUNoUpgradeInitial : OnAbort
    Downloading --> RSUNoUpgradeInitial : OnAbort
    WaitingForUpload --> RSUNoUpgradeInitial : OnAbort
    ReadyToInstall --> RSUNoUpgradeInitial : OnAbort
</div>

## Backend Architecture

[Remote Software Upgrade Service Documentation](https://code.connected.bmw/core-services/remote-software-upgrade)
