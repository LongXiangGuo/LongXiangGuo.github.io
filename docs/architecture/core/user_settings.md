---
layout: default
title: User Settings
parent: Core
grand_parent: Architecture
nav_order: 21
---

# User Settings

User settings allows users to customize the app to fit their needs. To support this, a global SettingsRepository is introduced. Via the SettingsRepository you can get the current value for a setting and also update it. Features that need to be customizable can easily add their custom settings to the SettingsRepository.
Initially the SettingsRepository will only support local settings storage but it is easily extendable to support backend stored settings.

The app will have a settings page where the user can get an overview of all their settings and change their values. Each feature can also directly query the SettingsRepository for the current value of a setting.

## UX

The current UX for the settings page can be found here [Current Settings UX](https://atc.bmwgroup.net/confluence/display/NWAP/3.1.0+Settings+Layout+-+Current). But this does currently not contain any info about settings that you can configure. The vision for the settings page can be found here [Vision Settings UX](https://atc.bmwgroup.net/confluence/display/NWAP/3.1.0+Settings+Layout+-+Vision)

## Client Architecture

### Overview

The user settings is accessible via the PlatformSDK as a singleton repository so that you easily can access it from anywhere in the app. It is not bound to a BuildContext since non-UI related logic might need access to it.
Code that needs a settings value can access it via the `PlatformSdk.settingsRepository` and query this for the relevant settings data.

The SettingsRepository initially only supports local data storage but can easily be extended to support some SettingsApiClient that could fetch/store data via a BFF.

<div class="mermaid">
graph TD
    subgraph Platform SDK
        A["Settings Repository"]
        A-->B
        A-->C
        B["Local Storage"]
        C["Settings Api Client"]
    end
    subgraph Settings Feature Module
        E["Settings Bloc"]-->A
    end
    subgraph Headless Container
        F["Clean Up Service"]-->A
    end
    subgraph Some Feature Module
        G["Some Feature Logic"]-->A
    end
</div>

<div class="mermaid">
classDiagram
    class SettingsRepository{
        RsuSettings getRsuSettings
        OtherSettings getOtherSettings
        Storage _localStorage
        SettingsApiClient _apiClient
    updateRsuSettings(...)
        updateOtherSettings(...)
        removePersistedSettings()
    }
    class RsuSettings{
        bool automaticDownloadEnabled
        bool wifiOnly
    }
    class OtherSettings{
        bool otherFlag
        String otherText
        int otherCount
    }
</div>

Example of usage:

```dart
final rsuSettings = await PlatformSdk.settingsRepository.getRsuSettings();
if (rsuSettings.automaticDownloadEnabled) {
    // Do some logic with auto-download here
}
```

## Backend Architecture

Will be added when needed.
