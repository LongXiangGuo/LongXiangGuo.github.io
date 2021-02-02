---
layout: default
title: Dependency Injection
parent: Core
grand_parent: Architecture
nav_order: 4
---

# Dependency Injection

![dependency injection]({{site.baseurl}}/assets/images/dependency_injection.png)

Dependency Injection (DI) is a design pattern which allows developers to decouple the usage of an object from its creation. We use DI in order to follow SOLID principles such as _inversion of dependencies_ and _single responsibility_.

Ultimately, the goal is to improve the reusability of the code while simultaneously increasing flexibility.

## Inherited Widgets

In Flutter, the `InheritedWidget` class is the base class for widgets that efficiently propagates information down the tree. We can extend `InheritedWidget` and expose whatever information we want so that our children can have access via the `BuildContext`.

As a result, Inherited Widgets are a good way to provide dependencies to sub-trees within a Flutter application.

### Providers

In Flutter, we use `Providers` as a way to expose a bloc to the widgets in a subtree.

Characteristics of providers are:

- Extend `InheritedWidget`
- Take dependencies in to construct the desired bloc
- Create an instance of the bloc
- Implement

  ```dart
  static Provider of(BuildContext context) => context.inheritFromWidgetOfExactType(Provider);
  ```

#### BlocProvider

The [bloc package](https://felangel.github.io/bloc/#/) contains a widget called `BlocProvider`. It is a helper widget that you will use to retrieve a bloc that was created previously by a parent widget. It only needs to be used if the scope of a bloc is shared in different nodes of your widget tree; this happens rarely, but authentication is one of those cases., for example.

## Login Example

In order to best illustrate how Inherited Widgets can be used as a DI pattern we will take a simple application which consists of a `LoginPage`.

### LoginPage

The LoginPage in our application will contain a `LoginForm` which is responsible for presenting the user with text input fields for their username and password as well as a button which will attempt to log the user in.

#### LoginBloc

Since we want to separate UI from business logic, the LoginForm will need to have a `LoginBloc` as a dependency. The LoginBloc will be a widget which is responsible for all of the business logic that is associated with logging a user in.

#### LoginBlocProvider

In order to give the LoginForm access to the LoginBloc we need to wrap the LoginForm with a LoginBlocProvider.

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginBlocProvider(
      startupConfiguration:
          StartupConfigurationProvider.of(context).configuration,
      httpClient: StartupConfigurationProvider.of(context).httpClient,
      child: LoginForm(),
    );
  }
}
```

Note that the `LoginBlocProvider` takes in a startupConfiguration and httpClient as dependencies.

#### LoginForm

The LoginForm can access the LoginBloc like:

```dart
LoginBloc _loginBloc = LoginBlocProvider.of(context).loginBloc;
```

The LoginForm will use the `StreamBuilder` Widget in order to rebuild the UI whenever a new `LoginUiState` is received.

```dart
@override
  Widget build(BuildContext context) {
    return StreamBuilder<LoginUiState>(
      initialData: loginBloc.initialData,
      stream: loginBloc.loginState,
      builder: (BuildContext context, AsyncSnapshot<LoginUiState> snapshot) {
        LoginUiState loginUiState = snapshot.data;
        return Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: Key('loginForm_username_textFormField'),
                decoration: InputDecoration(labelText: 'username'),
                keyboardType: TextInputType.emailAddress,
                controller: usernameController,
                enabled: loginUiState.isUsernameInputEnabled,
              ),
              TextFormField(
                key: Key('loginForm_password_textFormField'),
                decoration: InputDecoration(labelText: 'password'),
                controller: passwordController,
                obscureText: true,
                enabled: loginUiState.isPasswordInputEnabled,
              ),
              RaisedButton(
                key: Key('loginForm_login_raisedButton'),
                onPressed: loginUiState.isLoginButtonEnabled
                    ? _onLoginButtonPressed
                    : null,
                child: Text('Login'),
              ),
              Container(
                child: loginUiState.isLoadingIndicatorShown
                    ? CircularProgressIndicator()
                    : null,
              ),
              Text(
                loginUiState.errorMessage,
                key: Key('loginForm_feedback_error_text'),
              ),
              Text(
                loginUiState.successMessage,
                maxLines: 3,
                key: Key('loginForm_feedback_success_text'),
              ),
            ],
          ),
        );
      },
    );
  }

  _onLoginButtonPressed() {
    loginBloc.onLoginButtonPressed(
      username: usernameController.text,
      password: passwordController.text,
    );
  }

  _onLoginFormInputChanged() {
    loginBloc.onLoginFormInputChanged(
      username: usernameController.text,
      password: passwordController.text,
    );
  }
```

```dart
class LoginBloc {
  LoginUiState get initialData => LoginUiState.initial();

  Stream<LoginUiState> get loginState => _loginUiStateSubject.stream;

  void onLoginFormInputChanged({String username, String password}) {
    _loginUiEventSubject.sink.add(
      LoginFormInputChanged(
        username: username,
        password: password,
      ),
    );
  }

  void onLoginButtonPressed({String username, String password}) {
    _loginUiEventSubject.sink.add(
      LoginButtonPressed(
        username: username,
        password: password,
      ),
    );
  }

  final _loginUiEventSubject = PublishSubject<LoginUiEvent>();
  final _loginUiStateSubject = PublishSubject<LoginUiState>();
  ...
}
```

Note that even though the `LoginBloc` is using a `PublishSubject` or `BehaviorSubject` behind the scenes, it never exposes the subject to the LoginForm. Instead, the LoginBloc has a getter for the LoginUiState stream and public methods for adding LoginUiEvents to the LoginUiEvent sink.

### Summary

**Blocs**: contain all business logic and are responsible for transforming UI Events into UI States.

**Providers**: expose blocs to widgets in their subtree by extending `InheritedWidget`.