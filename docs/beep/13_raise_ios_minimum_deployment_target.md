---
layout: default
title: "BEEP-13: iOS Minimum Deployment Target"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 13
---

# BEEP-13: iOS Minimum Deployment Target

### Authors

- Florian Wagner <florian.w.wagner@bmw.de>

## Summary

The current mobile-connected client uses the Flutter default minimum deployment target of iOS 8.0, which was released in 2014. This BEEP proposes to raise the minimum deployment target to iOS 12 for the 7/20 release and establish the general rule to only support the two latest iOS releases.

## Motivation

Apple bundles all its system frameworks with OS releases only. It does not utilize a "Standard Library" that can be updated idependently of the OS, like Google does with Android. This means Apple's system frameworks on iOS are only available from the OS release they had been introduce. In the past years, Apple has introduced a number of frameworks that provide object-oriented Swift-style APIs and replace the previous C APIs. Using the C APIs produces code that is harder to read due to the neccessary bridging of types. The missing support for ARC requires extra care to not create a memory leak. Being able to use the platform provided frameworks also reduced the number of external dependencies need. With teams in Munich adding more features that require native code, we are more and more affected by this.

### Example

1) The Alexa feature needs to determine in native code if the phone currently has a functional network connection. iOS provides a C API called ```SCNetworkReachability``` for this. Due to the cumbersome use of C APIs mentioned above, Alamofire was used as this provides a similar functionality in a helper class and was already used in Mobile 1 for network requests anyway.
We no longer have Alamofire at our disposal for this in the framework prohect, as we do not need to include it for HTTP requests (Authenticated requests to the OMC will be handed off to the Flutter core component, all other request will just use ```URLSession```). As we want to avoid bloating the app with our library having many dependencies, we want to keep the number of additional 3rd party libraries at the absolute minimum. With iOS12, Apple has introduced the ```Network``` Framework which provies a very covenient API to monitor device connectivity (```NWPathMonitor```), which allows to solve this problem with just a couple of lines of code.
2) With iOS 13, Apple has introduced the ```Combine``` framework, which provides an Rx-style implementation of the observer pattern. With this, we could drop the dependency on RxSwift in native code migrated from Mobile 1 or required for a certain feature. This would safe around 20MB on the app bundle size for a release build.

## User impact

### Device support

The oldest devices supported by iOS 12 are the iPhone 5s, iPad Air (1st gen) and iPad mini (2ng gen) which had all been introduced in 2013.

### Adoption rate

The adoption rate of new iOS releases has historically always been quick. Introduced mid September 2018, iOS 12 had reached 50% by October 10[^1] and 70% on December 4[^2] of the same year. It topped out around 93% when iOS13 was released[^4]. As of now, the numbers for iOS 13 are fairly similar[^3] with the number of devies running either iOS 12 or 13 at around 95%[^4].

### Potential number of affected users

The numbers above show that there are around 5% of users that cannot or have not yet updated to the latest iOS release. Taking into account that devices sold since 2013 are eligable to update to at least iOS 12, it is safe to assume that the number of affected users that _cannot_ update is even lower among the BMW/MINI customer demographic.
As a side note, the current mobile-connected Android runner requires at least Android 6.0 (SDK 23), with 5.1 still having a market share of around 7%[^5].


[^1]: https://www.cultofmac.com/582470/ios12-passes-50-mark/
[^2]: https://www.cultofmac.com/594530/ios-12-adoption-70-percent-iphone-ipad/
[^3]: https://developer.apple.com/support/app-store/
[^4]: https://9to5mac.com/2019/09/26/ios-13-adoption-tops-20-across-iphone-and-ipad-devices-one-week-after-release/
[^5]: https://gs.statcounter.com/android-version-market-share/mobile-tablet/worldwide
