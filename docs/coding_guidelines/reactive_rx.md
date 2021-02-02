---
layout: default
title: Reactive (Rx)
parent: Coding Guidelines
nav_order: 2
---

# Reactive (Rx) Coding Guidelines

* **DO ONLY** subscribe to streams in `business logic blocs`
* **DO** expose streams from business logic blocs in the UI/main scheduler
  * Only `business logic blocs` should call `observeOn(uiThread)
* **DO NOT** use `subscribeOn` in `business logic blocs`
* **DO NOT** return `Relays` on public APIs
* **DO NOT** use side effect operators for business logic
  * Only use `doOnXXX` for operations that do not change business logic
* **DO NOT** use stream errors for business logic
* **DO ALWAYS** specify error handlers for all subscriptions
* **DO NOT** use block operators when possible
* **DO NOT** subscribe to streams in constructors
* **DO** use reactive test libraries (e.g., `RxSwift`) in unit tests whenever appropriate, to ensure we're evaluating streams properly