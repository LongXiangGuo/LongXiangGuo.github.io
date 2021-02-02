---
layout: default
title: Android & Kotlin
parent: Coding Guidelines
nav_order: 5
---

# Android and Kotlin

* **DO NOT** inject the `Context` anywhere; instead, use `Resources` or equivalents...
* **DO NOT** use PowerMock

## Kotlin

* **DO** take advantage of extension functions
* **DO NOT** use force unwrap `!!` to acess optionals
* **DO** user properties where appropaite
* **DO NOT** use `companion objects` when possible
  * Only a few cases, such as `Fragment` instantiation
* **DO** use [Android Extensions](https://kotlinlang.org/docs/tutorials/android-plugin.html) for view binding when possible

## Coding style

### Kotlin

#### Spacing

Spacing is very important. Everyone knows about the [Tabs vs. Spaces Battle](https://softwareengineering.stackexchange.com/questions/57/tabs-versus-spaces-what-is-the-proper-indentation-character-for-everything-in-e). Our goal is to find consistency, and improving readability. Therefore, our rules are:

* Indentation is using **spaces, not tabs**
* Indentation for blocks uses **4 spaces**

```kotlin
fun myAwesomeMethod() {
    for (i in 0..9) {
        Log.i(TAG, "index=" + i)
    }
}
```

#### Nomenclature

Package names should be **all lowercase**, and multiple words concatenated together with `_`:

`package com.connected.awesome_feature`

##### Classes and interfaces

Written in **UpperCamelCase**: `class RadialSlider`, `interface VehicleInformation`.

##### Methods

Written in **lowerCamelCase**: `fun getActiveVehicle(): Vehicle`

##### Fields

Generally, written in **lowerCamelCase**. Fields **should not** be named with [Hungarian Notation](https://en.wikipedia.org/wiki/Hungarian_notation). 

```kotlin
class MyClass {
    var publicField: Int = 0
    val person = Person()
    private var privateField: Int? = null
}
```

Constant values marked with `const` should be **all uppercase**:

```kotlin
companion object {
    const val THE_ANSWER = 42
}
```

#### Declarations

##### Visible modifiers

Only include visibily modifiers if they are not public:

```kotlin
val wideOpenProperty = 1
private val myPrivateProperty = "private"
```

##### Classes

###### Data Type Objects

Preferred `data` classes for simple data holding objects:

```kotlin
// BAD:
class Person(val name: String) {
    override fun toString(): String {
        return "Person(name=$name)"
    }
}

// GOOD:
data class Person(val name: String)
```

###### Enum & Sealed Classes

Enum classes should display each field in a different line:

```kotlin
enum class Direction {
    NORTH,
    SOUTH,
    WEST,
    EAST
}
```

In Kotlin, we also have the ability to use [Sealed Classes](https://kotlinlang.org/docs/reference/sealed-classes.html)

As we do with `enums`, each field should be in each line, and no indentation:

```kotlin
sealed class Expr
data class Const(val number: Double) : Expr()
data class Sum(val e1: Expr, val e2: Expr) : Expr()
object NotANumber : Expr()
```

##### Semicolons

Semicolons ~~are dead to us~~ should be avoided whenever possible in Kotlin.

##### Getters & Setters

Unlike in Java, direct access to fields in Kotlin is preferred.

If custom getters and setters are required, they should be declared following [Kotlin's convention](https://kotlinlang.org/docs/reference/properties.html)

#### Brace Style

Only trailing closing braces are awarded with their own line:

```kotlin
// BAD:
class MyClass
{
    fun doSomthing()
    {
        Log.d("This", "is bad")
    }
}

// GOOD:
class MyClass {

    fun doSomething() {
        Log.d("This", "is great")
    }
}
```

#### Conditional statements

##### if-else

**Ternary operators** do not exist in Kotlin. When you use `if-else` for assigning a value, you can skip the curly braces:

```kotlin
val max = if (a > b) a else b
```

When there are **more than one** statement after `if-else`, they are always required to be enclosed with braces.

When using `if-else` for conditional operations apart from assignments, always use curly braces:

```kotlin
// BAD:
if (someTest)
    doSomething()
if (someTest) doSomething()

// GOOD:
if (someTest) {
    doSomething()
}
```

##### when statements

Unlike `switch` statements in Java, `when` do not fall through. Separate cases using commas if they should be handled togeher.

```kotlin
when (anInput) {
    1, 2 -> doSomethingForCaseOneOrTwo()
    3 -> doSomethingForCaseThree()
    else -> println("No case satisfied")
}
```

##### Types

Always use Kotlin's native types when possible.

##### Type inference

Type inference should be preferred where possible to explicitely declared types:

```kotlin
// BAD:
val something: MyType = MyType()
val meaningOfLife: Int = 42

// GOOD:
val something = MyType()
val meaningOfLife = 42
```

##### Companion objects

**Companion objects** are, in a certain way, the replacement of the `static` concept in JVM world. However, Kotlin did not introduce `static` for a reason: it is easy to mark something
as static, but then make mistakes, like for example, given then same input we don't always return the same output. That breaks totally the definition of static.

However, static fields and methods have some advantages, specially when using creational patterns.

In Kotlin, we can leverage many of those to internal Factories, default values in constructors or Extension functions (for Activities, you can use private extensions of Context).

This will remove the necessity of using companion objects, except for one case: instantiang Fragments.

When instantiang Fragments it is expected to use companion objects, since it is still the cleaner way to do it:

```kotlin
class DestinationDetailsFragment : PlaceDetailsFragment() {

    companion object {

        private val ARGS_DESTINATION_DETAILS = "argsDestinationDetails"

        @JvmStatic
        fun newInstance(destination: Destination): DestinationDetailsFragment {
            val args = Bundle()
            val fragment = DestinationDetailsFragment()
            args.putParcelable(ARGS_DESTINATION_DETAILS, Parcels.wrap(destination))
            fragment.arguments = args
            return fragment
        }
    }
...
```

#### Optionals

Declare variables and function return types as optional with `?` where a `null` value is acceptable.

When naming optional variables and parameters, avoid naming them like `optionalString` or `maybeView`, since their optional-ness is already explicit in the type declaration.

When accessing an optional value, use the optional chaining if the value is only accessed once or if there are many optionals in the chain:

`editText?.setText("foo")`

Use `.let` when performing operations on an optional value when the reference is mutable and can be set to `null` by another thread:

```kotlin
textContainer?.let { textContainer ->
    // do many things here with textContainer
}
```

For optional binding, shadow the original name when appropiate rather than using new names:

```kotlin
// BAD:
var optionalSubview: UIView?
var volume: Double?

if let unwrappedSubview = optionalSubview {
    if let realVolume = volume {
        // do something with unwrappedSubview and realVolume
    }
}

// GOOD:
var subview: UIView?
var volume: Double?

// later on...
if let subview = subview, let volume = volume {
    // do something with unwrapped subview and volume
}
```

And never, **never, NEVER!** force unwrap with `!!`. If an object type is optional, it can be `null` at any given time, so force unwrapping will throw an NPE, defeating the whole idea of being null-safe that Kotlin promotes.

#### Usage of `it`

The keyword `it` can be used in Kotlin as an implicit name for a single parameter in a function.

However, if you have a nested function, **do not** use `it`, since it won't be understandable anymore what `it` is.

```kotlin
// BAD:

val listOfStrings = listOf("a", "b", "c")
listOfStrings.find {
    it.none {
        it.isUpperCase()
    }
}

// GOOD:
val listOfStrings = listOf("a", "b", "c")
listOfStrings.find { string ->
    string.none { character ->
        character.isUpperCase()
    }
}
```

### XML

#### Use self closing tags

When an XML element does not have any children, **use** self closing tags:

```xml
<!-- GOOD: -->
<TextView
    android:id="@+id/my_label"
    android:layout_width="match_parent"
    android:layout_height="match_parent"/>

<!-- BAD: -->
<TextView android:id="@+id/text_view_profile"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content" >
</TextView>
```

#### Attributes ordering

Only namespaces can be in the same line as the Android component name.

The ordering should be:

1. Component name + namespace if needed
2. Android resource ID
3. Style
4. Mandatory fields (layout_width, layout_height...)
5. Rest of the fields

Example:

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/my_linear_layout"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="@dimen/default_padding">

    <TextView 
        android:id="@+id/my_text_view"
        style="@style/Heading1"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="@string/super_awesome_text" />

    <ImageView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/super_awesome_image" />
</LinearLayout>
```

#### Resources naming

Resource IDs and names are written in **lowercase_underscore**, also known as [Snake Case](https://en.wikipedia.org/wiki/Snake_case)

IDs should be suffixed with the name of the element they identified. For example:

| Element   | Identifier            |
| ----------|-----------------------|
| TextView  | my_awesome_text_view  |
| ImageView | my_awesome_image_view |
| Button    | my_awesome_button     |
| Menu      | my_awesome_menu       |