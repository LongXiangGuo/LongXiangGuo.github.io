---
layout: default
title: "BEEP-1: Remove Redux"
parent: BEEP - BMW Evolution and Enhancement Process
nav_order: 1
---

# BEEP-1: Remove Redux

### Authors

* Felix Angelov

## Summary

I propose to remove Redux from the mobile-connected project and use the BLoC pattern as our main state management pattern throughout the application to remove complexity and simplify testing.

## Motivation

Currently, we have two patterns for state management: BLoC for local state and Redux for Global State.

The motivation for this mainly was to get benefits from Redux like Time-Travel debugging. After having introduced Redux alongside BLoC in our project I have noticed several problems which concern me:
- The complexity of testing has increased.
- The complexity of development has increased.
- The likelihood of race conditions occuring is elevated due to having to keep in sync two state management solutions.

Since we have already introduced a `Repository Layer` there is even less of a need to have a global state because the repositories can serve as the source of truth and are made available throughout the widget tree via a `RepositoryProvider` extending `InheritedWidget`.

By splitting up our application into separate domain-centric modules (`MotoristRepository`, `VehicleRepository`, `JourneyRepository`) we can decouple a lot of the dependencies that we had due to Redux and make development and testing occur in a layered approach (unit testing at the repository layer coupled with unit/widget/integration testing at the application layer).

In addition, by using BLoCs everywhere it is extremely easy to widget test because the tests are just a setup where we mock the initial state of the BLoC and then pump the widget under test to assert that the UI reacts to the state appropriately. With Redux, it's very involved to test the middleware and we even have several spots in our code that we have not tested because of how difficult it is to mock/pass state.

The BLoC only approach in many ways follows the same architecture that we would have had with RIBs. We will still have a global state, however, it is represented by the composition of local states in the widget tree. Furthermore, we have the opportunity to develop some pretty cool debugging (time travel) tools for BLoC that could prove very useful to the whole flutter community.

### Detailed description

Currently, we use a global redux store to keep track of the usid of the current user. We handle routing in the redux middleware however, we dispatch those event from a UI component which manages it's state via a BLoC.

This introduces undesired behavior like:
- once the UI component has successfully authenticated (retrieved a token) it is still present for a second while the Redux Middleware executes and triggers the navigation.
- the middleware sometimes doesn't update the redux store because if the navigation completes the reducer never recieves the action.

I propose to have an Authentication Bloc that manages the authentication state of the application and renders either a Splash Screen, Home Screen, or Login Screen based the authentication state of the application.

### Code examples
```dart
// main.dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';

void main() {
  final authenticationBloc = AuthenticationBloc();

  runApp(App(
    authenticationBloc: authenticationBloc,
  ));
}

class App extends StatelessWidget {
  final AuthenticationBloc authenticationBloc;

  App({Key key, @required this.authenticationBloc}) : super(key: key) {
    authenticationBloc.onAppStart();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: authenticationBloc,
      child: MaterialApp(
        home: _rootPage(),
      ),
    );
  }

  Widget _rootPage() {
    return BlocBuilder<AuthenticationEvent, AuthenticationState>(
      bloc: authenticationBloc,
      builder: (BuildContext context, AuthenticationState state) {
        List<Widget> _widgets = [];

        if (state.isAuthenticated) {
          _widgets.add(HomePage());
        } else {
          _widgets.add(LoginPage());
        }

        if (state.isInitializing) {
          _widgets.add(SplashPage());
        }

        if (state.isLoading) {
          _widgets.add(_loadingIndicator());
        }

        return Stack(
          children: _widgets,
        );
      },
    );
  }

  Widget _loadingIndicator() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
```
```dart
// authentication_bloc.dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  void onAppStart() {
    dispatch(AppStarted());
  }

  void onLogin({@required String token}) {
    dispatch(LoggedIn(token: token));
  }

  void onLogout() {
    dispatch(LoggedOut());
  }

  @override
  AuthenticationState get initialState => AuthenticationState.initializing();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationState state, AuthenticationEvent event) async* {
    if (event is AppStarted) {
      final bool hasToken = await _hasToken();

      if (hasToken) {
        yield AuthenticationState.authenticated();
      } else {
        yield AuthenticationState.unauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield state.copyWith(isLoading: true);

      await _persistToken(event.token);
      yield AuthenticationState.authenticated();
    }

    if (event is LoggedOut) {
      yield state.copyWith(isLoading: true);

      await _deleteToken();
      yield AuthenticationState.unauthenticated();
    }
  }

  Future<void> _deleteToken() async {
    /// delete from keystore/keychain
    return;
  }

  Future<void> _persistToken(String token) async {
    /// write to keystore/keychain
    return;
  }

  Future<bool> _hasToken() async {
    /// read from keystore/keychain
    return false;
  }
}
```

```dart
// authentication_event.dart
import 'package:meta/meta.dart';

abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  LoggedIn({@required this.token});
}

class LoggedOut extends AuthenticationEvent {}
```

```dart
// authentication_state.dart
import 'package:meta/meta.dart';

class AuthenticationState {
  final bool isInitializing;
  final bool isLoading;
  final bool isAuthenticated;

  const AuthenticationState({
    @required this.isInitializing,
    @required this.isLoading,
    @required this.isAuthenticated,
  });

  factory AuthenticationState.initializing() {
    return AuthenticationState(
      isInitializing: true,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthenticationState.authenticated() {
    return AuthenticationState(
      isInitializing: false,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthenticationState.unauthenticated() {
    return AuthenticationState(
      isInitializing: false,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthenticationState copyWith({
    bool isInitializing,
    bool isAuthenticated,
    bool isLoading,
  }) {
    return AuthenticationState(
      isInitializing: isInitializing ?? this.isInitializing,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() =>
      'AuthenticationState { isInitializing: $isInitializing, isLoading: $isLoading, isAuthenticated: $isAuthenticated }';
}
```