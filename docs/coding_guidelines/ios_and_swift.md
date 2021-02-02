---
layout: default
title: iOS & Swift
parent: Coding Guidelines
nav_order: 6
---

# iOS & Swift Coding Guidelines

* **DO** use upper-camelcase for class names
* **DO** use lower-camelcase for variables / parameters
* **DO** treat acronyms as words / **DO NOT** use acronyms in all-caps
  * Examples:
    * **Bad:**
      * `GCDMHTTPResponse`
    * **Good:**
      * `GcdmHttpResponse`
* **DO** use standard brace style with multi-line line-breaks
* **DO** add line-breaks when method chaining
* **DO** use 4 spaces for line-wraps
* **DO NOT** use semicolons
* **DO NOT** use `self.` unless absolutely necessary
* **DO** capture `[weak self]` in **ALL** escaping closures
  * There's some exceptions, like GCD, where it will not cause a memory leak
    * **However**, when when using GCD - if it's asynchronous, you'll still want a weak reference to `self` in case the object disappears