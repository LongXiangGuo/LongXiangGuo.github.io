---
layout: default
title: Flutter & Dart
parent: Coding Guidelines
nav_order: 4
---

# Flutter & Dart Coding Guidelines

{: .no_toc }

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Dart

Rather than maintaining our own custom guidelines, the Dart team has collected what they considered best practices under their [Effective Dart](https://www.dartlang.org/guides/language/effective-dart) document.

We have reviewed these guidelines carefully, and we believe it is a good practice to adhere to everything stated in those documents.

These documents are broken down into different categories:

- [Introducion](https://www.dartlang.org/guides/language/effective-dart)
- [Style](https://www.dartlang.org/guides/language/effective-dart/style)
- [Documentation](https://www.dartlang.org/guides/language/effective-dart/documentation)
- [Usage](https://www.dartlang.org/guides/language/effective-dart/usage)
- [Design](https://www.dartlang.org/guides/language/effective-dart/design)

## Flutter

## Overview

The following Flutter coding guidelines are meant to be used in conjuction with the [Flutter Coding Guidelines](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

## 1. Blocs

### 1A. Evaluate whether a Bloc is needed

If your UI component is not functional, meaning it does not respond to user interactions, then you probably don't need a Bloc.

### 1B. Use Past-Tense for Event Names

✅ Good

```dart
abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {}
```

❌ Bad

```dart
abstract class LoginEvent {}

class LoginButtonPress extends LoginEvent {}
```

### 1C. Avoid having to manually override `==` and `hashCode`

✅ Good

```dart
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);
}
```

❌ Bad

```dart
abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginButtonPressed &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;
}
```

### 1D. Avoid Bloated States

Each state should be represented individually and should only contain data that is absolutely necessary.
In the "Bad" example, notice how it is impossible to have a state with isLoading = true and isError = true however it is technically possible to model that state given the implementation. This is the type of scenario we want to avoid in addition to making our states as clear/easy to understand as possible. When designing states/events please do keep simplicity in mind.

✅ Good

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({@required this.error}) : super([error]);
}
```

❌ Bad

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final String error;

  LoginState({
    @required this.isLoading,
    @required this.error,
  }) : super([isLoading, error]);

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      error: '',
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isLoading: true,
      error: '',
    );
  }

  factory LoginState.failure(String error) {
    return LoginState(
      isLoading: false,
      error: error,
    );
  }
}
```

### 1E. Keep Blocs Platform-Independent

Do not import `Flutter` or `AngularDart` dependencies in a Bloc as it should be able to be reused across platforms.

### 1F. Use if/else if/else in `mapEventToState`

✅ Good

```dart
@override
Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
  if (event is Increment) {
    yield currentState + 1;
  } else if (event is Decrement) {
    yield currentState - 1;
  } else {
    yield currentState;
  }
}
```

❌ Bad

```dart
@override
Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
  if (event is Increment) {
    yield currentState + 1;
  }
  if (event is Decrement) {
    yield currentState - 1;
  }
}
```

### 1G. Always Dispose Blocs

✅ Good

```dart
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        bloc: _counterBloc,
        child: CounterPage(),
      ),
    );
  }

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}
```

❌ Bad

```dart
class MyApp extends StatelessWidget {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        bloc: _counterBloc,
        child: CounterPage(),
      ),
    );
  }
}
```

### 1H. Only use `BlocProvider` when multiple distant children need access to a Bloc

✅ Good

![Good BlocProvider Use]({{site.baseurl}}/assets/images/bloc_provider_good.png)

The widget in green uses `BlocProvider` to expose a bloc to both widget A and widget B. The widget in green is the right place to use `BlocProvider` because it is the closest common ancestor of A and B.

❌ Bad

![Bad BlocProvider Use]({{site.baseurl}}/assets/images/bloc_provider_bad_1.png)

We don't need a `BlocProvider` in this case because only one widget needs to access the bloc. In this case the bloc can be passed via constructor or created directly by A.

## 2. Widgets

### 2A. Prefer StatelessWidgets over StatefulWidgets

### 2B. Avoid Functional Widgets

✅ Good

```dart
class ClassWidget extends StatelessWidget {
  final Widget child;

  const ClassWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
```

Used like:

```dart
ClassWidget(
  child: Container(),
);
```

❌ Bad

```dart
Widget functionWidget({ Widget child}) {
  return Container(child: child);
}
```

Used like:

```dart
functionWidget(
  child: Container(),
);
```

### 2C. Expose Getters in State

✅ Good

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWidget(),
    );
  }
}
```

❌ Bad

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BodyWidget(),
    );
  }
}
```

### 2D. Avoid Injecting Properties into State

✅ Good

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWidget(),
    );
  }
}
```

❌ Bad

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState(title);
}

class _MyPageState extends State<MyPage> {
  final String title;

  _MyPageState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWidget(),
    );
  }
}
```

### 2E. Avoid making State Classes Public

✅ Good

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWidget(),
    );
  }
}
```

❌ Bad

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BodyWidget(),
    );
  }
}
```

### 2F. Avoid Private Variables in Private Classes

✅ Good

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final String body;

  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Text('$body'),
    );
  }
}
```

❌ Bad

```dart
class MyPage extends StatefulWidget {
  final String title;

  MyPage({Key key, @required this.title})
      : assert(title != null),
        super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final String _body;

  String get title => widget.title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Text('$_body'),
    );
  }
}
```

### 2G. One Public Class per File

Avoid having multiple public classes per file.

### 2H. Append Widget to Widget Classes

✅ Good

```dart
class CoolWidget extends StatelessWidget {
  final Widget child;

  const CoolWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
```

❌ Bad

```dart
class Cool extends StatelessWidget {
  final Widget child;

  const Cool({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
```

### 2I. Identify Page Widgets

If a widget is a container widget which represents a "Page" in the application the naming should be {Name}PageWidget.

✅ Good

```dart
class VehiclePageWidget extends StatelessWidget {
  final Widget child;

  const VehiclePageWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
```

❌ Bad

```dart
class VehicleWidget extends StatelessWidget {
  final Widget child;

  const VehicleWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
    );
  }
}
```

## 3. Tests

### 3A. Extract Common Setup into `setUp`

✅ Good

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });

    test('single Increment event updates state to 1', () {
      final List<int> expected = [0, 1];

      expectLater(
          counterBloc.state,
          emitsInOrder(expected),
      );

      counterBloc.dispatch(Increment());
  });

  test('single Decrement event updates state to -1', () {
      final List<int> expected = [0, -1];

      expectLater(
          counterBloc.state,
          emitsInOrder(expected),
      );

      counterBloc.dispatch(Decrement());
  });
});
```

❌ Bad

```dart
group('CounterBloc', () {
    test('initial state is 0', () {
      final CounterBloc counterBloc = CounterBloc();
      expect(counterBloc.initialState, 0);
    });

    test('single Increment event updates state to 1', () {
      final CounterBloc counterBloc = CounterBloc();
      final List<int> expected = [0, 1];

      expectLater(
        counterBloc.state,
        emitsInOrder(expected),
      );

      counterBloc.dispatch(Increment());
  });

  test('single Decrement event updates state to -1', () {
      final CounterBloc counterBloc = CounterBloc();
      final List<int> expected = [0, -1];

      expectLater(
        counterBloc.state,
        emitsInOrder(expected),
      );

      counterBloc.dispatch(Decrement());
  });
});
```

### 3B. Avoid using `pump()` and `pumpAndSettle()` unnecessarily

pump triggers a frame after a specified amount of time and is used when waiting for UI to update.
pumpAndSettle repeatedly calls pump with a specified duration until there are no longer any frames scheduled.

These methods slow down tests and should only be used when a test is dependent on UI updates or microtasks being completed.

### 3C. Simulate interactions (tap/drag/enterText) instead of calling methods directly

✅ Good

```dart
testWidgets('Tapping floating button opens \'AddNewTodo\' Page', (WidgetTester tester) async {
  await tester.pumpWidget(TodoList());
  
  await tester.tap(find.byType(FloatingActionButton));

  await tester.pumpAndSettle();

  expect(find.byType(AddNewTodoPage), findsOneWidget);
});
```

❌ Bad

```dart
testWidgets('Tapping floating button opens \'AddNewTodo\' Page', (WidgetTester tester) async {
  await tester.pumpWidget(TodoList());
  
  await tester.widget(find.byType(FloatingActionButton)).onTap();

  await tester.pumpAndSettle();

  expect(find.byType(AddNewTodoPage), findsOneWidget);
});
```

### 3D. Test user flow, avoid overuse of Mocks

The usage of real objects that we control will provide a better scenario in case of change. Use test-doubles to stub/mock behavior of objects we don't fully control. Use real objects when the control is our side, and it's not awkward to do so.

https://martinfowler.com/bliki/UnitTest.html

When we do only solitary tests the consequence is that we lose track when objects diverge in implementation. We could/should mock the repositories, not the bloc implementations. Furthermore, with solitary tests, we don't test user flows just what we believe the flows are, odds are that the flow is not what we believe.

✅ Good

```dart
testWidgets('Tapping + adds a new item', (WidgetTester tester) async {
  await tester.pumpWidget(TodoList(TodoListBloc()));
  
  await tapPlusButton();
  
  assertItemAdded();
});
```

❌ Bad

```dart
testWidgets('Adds a new item when idle and tapped +', (WidgetTester tester) async {
  when(mockTodoListBloc.isIdle).thenReturn(true);
  
  await tester.pumpWidget(TodoList(mockTodoListBloc));
  
  await tapPlusButton();
  
  assertItemAdded();
});
```

### 3E. Abstract ideas - extract actions or ideas into functions

Extracting ideas into methods/functions will help other developers understand what actions are taking place during testing. Also, doing so enables reuse, thus removing duplication.


✅ Good
```dart
  await tapAddItem();
```
❌ Bad
```dart
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
```

✅ Good
```dart
  await navigateToPageY();
```
❌ Bad
```dart
  await tester.tap(find.byType(PageYNavActionButton));
  await tester.pumpAndSettle();
```

✅ Good
```dart
  assertItemWasAdded();
```
❌ Bad
```dart
  expect(find.byType(TodoItemWidget), findsOneWidget);
```

### 3F. Extract mocked dependencies from test methods

Leaving setup methods within test methods creates a tight binding between implementation and the test methods. Produces duplication, which in turn makes it harder to maintain tests. 

✅ Good
```dart
  setupGetVehicles();
```
❌ Bad
```dart
  when(vehicleRepository.getVehicles()).thenReturn([Vehicle()]);
```

✅ Good
```dart
  final subjectUnderTest = makeTodoWidget();
```
❌ Bad
```dart
  final todoRepository = TodoRepositoryMock();
  final subjectUnderTest = TodoWidget(todoRepository);
```


## 4. Models

### 4A. Prefix Models with their Namespace

✅ Good

```dart
class OmcPerson {
  final String name;

  const OmcPerson(this.name);
}
```

❌ Bad

```dart
class Person {
  final String name;

  const Person(this.name);
}
```

## 5. Routing naming

Use kebab-case for naming convention which means dash between lowercase words

✅ Good

- **Use dash between words**

  ```dart
  const String alexaPage = '/alexa-page';
  const String tutorialPage = '/tutorial-page';
  const String alexaLanguagePage = '/alexa-language-page';
  ```

❌ Bad

- **Do not use underscore between words**

  ```dart
  const String alexaPage = '/alexa_page';
  const String tutorialPage = '/tutorial_page';
  const String alexaLanguagePage = '/alexa_language_page';
  ```

❌ Bad

- **Do not use serveral levels of routing name**
  This looks good but it will cause issues with backward navigation as Flutter navigator treats this parth as two navigation jumps.

  ```dart
    const String aboutAndContact = '/profile/about-and-contact';
    const String discoverBmwRoute = '/profile/discover-bmw';
    const String imprintRoute = '/profile/reset-password-cn';
  ```
