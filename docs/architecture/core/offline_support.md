---
layout: default
title: Offline Support
parent: Core
grand_parent: Architecture
nav_order: 10
---

# Offline support

Offline support refers to the ability of an application to be able to load content on the screen without being online. This content comes from a caching layer, where the content was previously saved when the network connection was available.

## Things to know

* Not everything in an application needs support for "offline mode". Please keep this in mind. Supporting offline mode is complex, since synchronization is always a hard task. Consider providing offline support if:
  * The content still makes sense if is not updated in real time
  * You do not need a network connection to make sense of the data
* In order to support offline mode efficiently, it is critical to show the user the timestamp of the information shown. It is fine to show "old data", but the users need to know that what they are seeing is actually "old". Displaying a timestamp will accomplish that.

## How to implement offline mode

Given the architecture of the Connected application, offline support should be implemented in the "data layer" of the project; that is, the **repository layer**. The repository layer represents the abstraction between the network layer and the storage layer. The repository is in charge of coordinating the data flow between your storage mechanism, the network/sensors and the application requirements.

It is very important that, in order to provide proper offline support, **your storage mechanism becomes the only single source of truth**. In other words, all the information gets saved in the storage layer before being displayed on a screen.

<div class="mermaid">
  graph LR;
    repository-->storage;
    repository-->network;
</div>

A good offline API is the one that, with one single method call, can give you updates of the object. `Rx` APIs are very handy in these case. However, `Rx` is in many cases a complex tool to use, and easily misused; it is very important to keep data flows unidirectional. One of the benefits of using Dart is that it comes already with nice async APIs, so you should consider:

* Not using async APIs if the value is immediately available
* Exposing `Future` in public APIs if only one value is being emitted asynchronously.
* Exposing `Stream` in public APIs if more than one value will be emitted.

A repository with offline support should never exposed models from the network, or storage models.

### What storage mechanism should be used

In most of the cases, you will need to use a database, probably SQLite or any of its variations depending on the platform (such as [sqflite](https://pub.dartlang.org/packages/sqflite)) for Flutter). Please consider using a database only if you need to save models.

If you, however, need to just store key/value pairs, please consider using the proper tools for that, such as `secure_storage`, `SharedPreferences` for Android or `User Defaults` for iOS.

**NEVER NEVER** store string models in a key/value storage tool. It is not the right tool, it is very inefficient, you will have to (de)serialize the objects manually, and this practice is not approved by the Core team.