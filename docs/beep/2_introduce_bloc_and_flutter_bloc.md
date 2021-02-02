---
layout: default
title: "BEEP-2: Introduce Bloc and Flutter Bloc"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 2
---

# BEEP-2: Introduce Bloc and Flutter Bloc

### Authors

- Felix Angelov

## Summary

I am proposing to introduce the following packages as dependencies:

- [bloc](https://pub.dartlang.org/packages/bloc) - dart package that provides a `Bloc` implementation which abstracts reactive aspects of the pattern allowing developers to focus on the implementing the business logic.
- [flutter_bloc](https://pub.dartlang.org/packages/flutter_bloc) - flutter package that provides `Widgets` for streamlined integration with the `bloc` package

## Motivation

Based on the two bloc implementations in our current codebase it has become evident that there is a lot of boilerplate code that is repeated across the implementations and that the heavy use of RxDart increases the complexity of the code.

### Detailed description

Based on these two problem areas, I think the `bloc` and `flutter_bloc` packages will help to simplify the code and even offer added benefits such as a single place where we can track events (analytics/logging).

Ultimately, the goal is to keep the pros of our current bloc implementations (separation of concerns between presentation and business logic) and to make it as simple/developer friendly as possible so that we have consistency and highly readable/testable code throughout our codebase as it continues to grow.

### Code examples
In this section, we're going to cover the benefits of using bloc & flutter_bloc over pure RxDart. The context is a simple counter application, where a user can increment/decrement a number on-screen.

Currently, we have to manage two `Subjects` per Bloc and the implementation looks something like:
```dart
// counter_bloc.dart
class CounterBloc {
    final _counterUiEventSubject = PublishSubject<CounterUiEvent>();
    final _counterUiStateSubject = BehaviorSubject<int>();

    int get initialData => 0;

    Stream<int> get counterUiState => _counterUiStateSubject.stream;

    void onIncrementCounterPressed() {
        _counterUiEventSubject.sink.add(IncrementCounter);
    }

    void onDecrementCounterPressed() {
        _counterUiEventSubject.sink.add(DecrementCounter);
    }

    void _bindToCounterAction() {
        _counterUiEventSubject.listen((counterAction) {
            if (counterAction is IncrementCounter) {
                _counterUiStateSubject.sink.add(_counterUiStateSubject.value + 1 ?? initialData + 1);
            }

            if (counterAction is DecrementCounter) {
                _counterUiStateSubject.sink.add(_counterUiStateSubject.value - 1 ?? initialData - 1);
            }
        });
    }

    dispose() {
        _counterUiEventSubject.close();
        _counterUiStateSubject.close();
    }
}
```

If we want to hook the following bloc up to a flutter widget it would look like:
```dart
// counter_page.dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = CounterBlocProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: StreamBuildeer(
        initialData: counterBloc.initialData,
        stream: counterBloc.counterUiState,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          final int count = snapshot.data;

          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: counterBloc.onIncrementCounterPressed,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: counterBloc.onDecrementCounterPressed,
            ),
          ),
        ],
      ),
    );
  }
}
```

If we wanted to make it available to a subtree via the `BuildContext`, we would need to implement our own `CounterBlocProvider` like:
```dart
// counter_bloc_provider.dart
class CounterBlocProvider extends InheritedWidget {
  final CounterBloc counterBloc;

  CounterBlocProvider({
    Key key,
    @required this.counterBloc,
    @required Widget child,
  })  : assert(loginBloc != null),
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(CounterBlocProvider oldWidget) => false;

  static CounterBlocProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CounterBlocProvider).counterBloc;
}
```

All of this amounts to lots of repetitive boilerplate which clutters the codebase as well as the risk of developers not understanding how to use Streams/Sinks properly which can cause lots of problems if introduced into the code base.

With the `bloc` package, we can simplify the `CounterBloc` above to look like:

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition.toString()); // Transition { currentState: 0, event: Increment, nextState: 1 }
  }

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
    if (event is Decrement) {
      yield state - 1;
    }
  }
}
```

Developers no longer have to know how the streams/sinks are managed and don't have to learn how to use RxDart. Instead, the focus is just on how to convert incoming events into outgoing states.

Furthermore, `onTransition` allows us to add logging/analytics in just one spot that capture all of the events and how to change application's state.

In addition, `flutter_bloc` provides a `BlocBuilder` and `BlocProvider` that simplify the use and injection of blocs in the presentation layer.

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: counterBloc,
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.dispatch(Increment())
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.dispatch(Decrement())
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Final Thoughts
In summary, by introducing the `bloc` and `flutter_bloc` packages we will gain the following:
- Decreased complexity of code
- Lower barrier to entry due to abstraction of RxDart
- Improved Ease of Testing
- Improved Ease of Logging
- Rails that enforce consistency

The disadvantages of introducing the aforementioned packages are:
- Additional dependencies
- Sacrificing some power (in terms of RxDart)
- Changes to package must be done outside of work (for now).
- No tooling currently available for time travel