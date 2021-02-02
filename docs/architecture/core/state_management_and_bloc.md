---
layout: default
title: State Management and Bloc
parent: Core
grand_parent: Architecture
nav_order: 5
---

# State Management and Bloc

More information here: [Bloc Documentation](https://felangel.github.io/bloc)

![local data flow]({{site.baseurl}}/assets/images/local_data_flow.png)

**UI Widgets**: use the `StreamBuilder` Widget in order to **react to new UI States from the bloc's stream** and **push UI Events into the bloc's sink** (indirectly).

## UI Events

In the Login scenario we only have two `LoginUiEvents`:

- LoginButtonPressed
- LoginFormInputChanged

```dart
abstract class LoginUiEvent {}

class LoginButtonPressed extends LoginUiEvent {
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

  @override
  String toString() =>
      '{ type: LoginButtonPressed, username: $username, password: $password }';
}

class LoginFormInputChanged extends LoginUiEvent {
  final String username;
  final String password;

  LoginFormInputChanged({
    @required this.username,
    @required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginFormInputChanged &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode;

  @override
  String toString() =>
      '{ type: LoginFormInputChanged, username: $username, password: $password }';
}
```

## UI States

In the Login scenario we have several `LoginUiStates`:

- initial
- loading
- formValid
- formInvalid
- success
- error

*Note that UI States **clearly** represent the state of the UI in order to eliminate any logic in the build method of the presentation widget.*

```dart
class LoginUiState {
  final bool isLoadingIndicatorShown;
  final bool isLoginButtonEnabled;
  final bool isUsernameInputEnabled;
  final bool isPasswordInputEnabled;
  final String errorMessage;
  final String successMessage;

  const LoginUiState({
    @required this.isLoadingIndicatorShown,
    @required this.isLoginButtonEnabled,
    @required this.isUsernameInputEnabled,
    @required this.isPasswordInputEnabled,
    @required this.errorMessage,
    @required this.successMessage,
  });

  factory LoginUiState.formValid() {
    return LoginUiState(
      isLoadingIndicatorShown: false,
      isLoginButtonEnabled: true,
      isUsernameInputEnabled: true,
      isPasswordInputEnabled: true,
      errorMessage: '',
      successMessage: '',
    );
  }

  factory LoginUiState.formInvalid() {
    return LoginUiState(
      isLoadingIndicatorShown: false,
      isLoginButtonEnabled: false,
      isUsernameInputEnabled: true,
      isPasswordInputEnabled: true,
      errorMessage: '',
      successMessage: '',
    );
  }

  factory LoginUiState.loading() {
    return LoginUiState(
      isLoadingIndicatorShown: true,
      isLoginButtonEnabled: false,
      isUsernameInputEnabled: false,
      isPasswordInputEnabled: false,
      errorMessage: '',
      successMessage: '',
    );
  }

  factory LoginUiState.initial() {
    return LoginUiState(
      isLoadingIndicatorShown: false,
      isLoginButtonEnabled: false,
      isUsernameInputEnabled: true,
      isPasswordInputEnabled: true,
      errorMessage: '',
      successMessage: '',
    );
  }

  factory LoginUiState.success(
    String successMessage,
  ) {
    return LoginUiState(
      isLoadingIndicatorShown: false,
      isLoginButtonEnabled: true,
      isUsernameInputEnabled: true,
      isPasswordInputEnabled: true,
      errorMessage: '',
      successMessage: successMessage,
    );
  }

  factory LoginUiState.error(
    String errorMessage,
  ) {
    return LoginUiState(
      isLoadingIndicatorShown: false,
      isLoginButtonEnabled: true,
      isUsernameInputEnabled: true,
      isPasswordInputEnabled: true,
      errorMessage: errorMessage,
      successMessage: '',
    );
  }

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is LoginUiState &&
          runtimeType == other.runtimeType &&
          isLoadingIndicatorShown == other.isLoadingIndicatorShown &&
          isLoginButtonEnabled == other.isLoginButtonEnabled &&
          isUsernameInputEnabled == other.isUsernameInputEnabled &&
          isPasswordInputEnabled == other.isPasswordInputEnabled &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage;

  @override
  int get hashCode =>
      isLoadingIndicatorShown.hashCode ^
      isLoginButtonEnabled.hashCode ^
      isUsernameInputEnabled.hashCode ^
      isPasswordInputEnabled.hashCode ^
      errorMessage.hashCode ^
      successMessage.hashCode;

  @override
  String toString() =>
      '{isLoadingIndicatorShown: $isLoadingIndicatorShown, isLoginButtonEnabled: $isLoginButtonEnabled, isUsernameInputEnabled: $isUsernameInputEnabled, isPasswordInputEnabled: $isPasswordInputEnabled, errorMessage: $errorMessage, successMessage: $successMessage }';
}
```