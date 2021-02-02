---
layout: default
title: Coding Guidelines
nav_order: 3
has_children: true
---

# Coding Guidelines

* **DO NOT** submit code that contains compiler warnings
* **DO** follow the **S.O.L.I.D. code design principles**
* **DO** document all public API's
* **DO NOT** write static helper methods
* **DO** write unit tests for all execution paths
* **We need 100% code-coverage**
  * We shouldn't just cover every line, but every logical branch (e.g., switch-case, if-else, etc.)
* **DO NOT** force-unwrap an Optional value
  * You can use optional-chaining, or validate that the content isn't null
* **DO** remove any dead-code that you see
* Any commented-out or unused code is fair game
* There's no point thinking "Well, *maybe* we'll use this function in the future".  We have commit history for a reason ;)
* **DO NOT** specify class type whenever possible
  * Rely on type-inference if the language supports this.  Example:
    * **Bad:**
      * `let theUltimateAnswer: Int = 42`
    * **Good:**
      * `let theUltimateAnswer = 42`
* **DO NOT** use more than 5 parameters in a constructor whenever possible
* **DO NOT** ignore exceptions
  * Otherwise, you are leaving land-mines for someone else to trip over someday
* **DO NOT** generically catch errors
* **DO NOT** exceed the code line limit (**150 characters**)
* **DO NOT** exceed the file length limit (**400 lines**)
  * Consider breaking up classes and files into smaller pieces, **we don't want huge, monolithic classes**
* **DO NOT** use `Pair` or generic tuple wrapper in a method signature
  * A nice alternative would be to create a model class, data class, or struct

## Nomenclature

* **DO** name objects and methods descriptively
  * "Clarity over Brevity", we aren't coding on [CRT Monitors](https://en.wikipedia.org/wiki/File:20020811203148_-_NOI_2002.jpg)
  * Examples:

| **Bad:** | **Good:** |
| --- | --- |
| `user.veh.excSrv()` | `user.vehicle.executeService()` |

* **DO** choose good parameter names that serve as documentation
* **DO** include all necessary words
  * **DO NOT** include useless words, like type / class information
  * Examples: 

| **Bad:** | **Good:** |
| --- | --- |
| `var string1 = "Good one!"` | `var successMessage = ...` |
| `var string2 = "Ya don' goofed"` | `var failureMessage = ...` |

* **DO** have booleans read like an assertion
  * Use a question format, such as "is/was/has...?"
  * Examples: 

| **Bad:** | **Good:** |
| --- | --- |
| `var done = false` | `var isDone = false` |

* **DO NOT** use negation in a boolean definition
  * *This puts extra cognitive load on future developers*
  * Examples: 

| **Bad:** | **Good:** |
| --- | --- |
| `var isNotDone = true`, `if isNotDone...` | `var isDone = false`, `if !isDone...` |

* **DO** use precedent for names
  * If there is common naming convention in a file or module, please follow the conventions
    * This will help keep the codebase as coherent as possible
* **DO NOT** use abbreviations
  * **"Clarity over Brevity"**
    * Acronyms are okay though
      * `class BmwPhevInfo { ...` is better than `class BayerischeMotorenWerkePluginHybridElectricVehicleInfo { ...`
  * Examples:

| **Bad:** | **Good:** |
| --- | --- |
| `var usrIdx = 1` | `var userIndex = 1` |