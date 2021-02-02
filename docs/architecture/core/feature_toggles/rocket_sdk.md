---
layout: default
title: Rocket SDK
parent: Feature Toggles
grand_parent: Core
nav_order: 21
---

{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

# Launch Darkly Wrapper SDK

The motivation for creating this wrapper SDK is to provide a simple and consistent abstraction for developers using the SDK so they can easily query the service for toggle values given a user's context.  In 2018 wrapper SDKs were written for Swift, Kotlin and .NET.  The API for this wrapper will follow some of the patterns established by the prior wrapper SDKs while applying some learnings since then.

The SDK will be part of the BMW NPM packages and be written in Typescript & NestJS.

## Launch Darkly Server Side SDK

When a server-side SDK client initializes it receives all of the current feature flags and targeting rules for a specific environment. This is the main difference between a server-side SDK and a client-side SDK. On server-side the evaluation occurs locally in memory, on client-side the evaluation occurs at LaunchDarkly.

The SDK then opens up a long lived connection, and receives updates via a server sent event whenever a change occurs.

# BMW Rocket Client 

The SDK will allow the caller to create an instance of the client called `BMWRocketClient`.  The client will hold a single instance of the Launch Darkly instance.  It is Launch Darkly's recommendation that the created `LDClient` instance be a singleton so that callers are not creating them per request.  

In the case of Mobile 2.0, the design is that each microservice have its own `BMWRocketClient` instance for evaluating toggles.

## Interface

```typescript
// Creates the BMWRocketClient with internal instance of LDClient
constructor(
    sdkKey: string,
    streamUri: string
);

// Pass toggle, user context and default value to LD and it returns the value of the toggle
checkEnabled(
    toggleName: string,
    user: RocketUser,
    defaultValue: boolean,
): Promise<boolean>;

// Calls LDClient.close which is required by the LD SDK
close(): void;
```
* The constructor takes configuration as input, in this case the SDKKey and the StreamUri.  
* The `SDKKey` identifies the LD Project and Environment.
* The `StreamUri` defines the URI of the service endpoint it should connect to -- in this case the Launch Darkly Relay Proxy which should be running in the respective service environment mesh.
* Note that there is no interface for multivariate toggles at this time.  The current policy is to not support this type of toggle due to its misuse as a configuration tool so this SDK will not support it until such time as proper use has been defined by BMW Engineering.

## Configuration

One key difference between this SDK and the prior Rocket SDKs is the existence of the mesh services for pulling environment information. The calling microservice that uses the BMWRocketClient will need to pull the `SDKKey` from *Vault* and the `StreamUri` for the respective Relay Proxy from *Consul*, per environment.  

Because of this, the `BMWRocketSDK` does not need to provide values for region and environment as the other SDKs do, nor expose an interface to 'build' the client since all the information is provided by the caller.

# RocketUser

The SDK defines an abstracted type for the user context that Launch Darkly requires.  The caller of the client is required to create this object for passing to the `checkEnabled` interface.  The user context is important as the values it holds are what Launch Darkly uses to evaluate the toggle for a user.

This type is then mapped to the `LDUser` type before being passed to the call to evaluate the toggle.  Some of the properties are strongly typed while others are left as strings to be filled in by the caller.

The existing Mobile 1.0 user context was mirrored here (and is up for revision if desired):
```typescript
export interface RocketUser {
    userId: string;
    brand: RocketBrand;
    hub: RocketHub;
    platform: RocketPlatform;
    version: string;
    cdProfileCountry: string;
    deviceCountry: string;
}
```

## RocketBrand

The type `RocketBrand` is an enumeration representing BMW and MINI:
```typescript
export enum RocketBrand {
    bmw = 'bmw',
    mini = 'mini'
}
```

## RocketHub

The type `RocketHub` is an enumeration representing the legal region the client belongs to:
```typescript
export enum RocketHub {
    na = 'na',
    row = 'row'
}
```

## RocketPlatform

The type `RocketPlatform` is an enumeration representing the the client platform:
```typescript
export enum RocketPlatform {
    ios = 'ios',
    android = 'android'
}
```

## Mapping to LDUser

The `RocketUser` type is mapped to the `LDUser` type which has the following structure:
```typescript
const context: LDUser = {
    key: user.userId,
    custom: {
        brand: user.brand,
        cdProfileCountry: user.cdProfileCountry,
        deviceCountry: user.deviceCountry,
        hub: user.hub,
        platform: user.platform,
        version: user.version
    }
};
```
# Enable Launch Darkly SDK Logging

If needed, you can add code to the `initializeLDClient` method of index.ts to turn on logging.  You'll need to incorporate the Winston logging package in the ld-rocket `package.json` file and run `npm install` to install it.  Once the logger is created, it will need to be added to the `options` object which is passed to the LD SDK.

Here is the code snippet to add logging:
```typescript
const logger = new Winston.Logger({
    level: 'debug',
    transports: [
        new (Winston.transports.Console)(),
    ]
});

options = Object.assign({}, options, { 'logger': logger});
```
# Reference Documentation

[Launch Darkly Node JS SDK](https://docs.launchdarkly.com/docs/node-sdk-reference)