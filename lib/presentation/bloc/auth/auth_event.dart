part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoggedIn extends AuthEvent {
  const LoggedIn();
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}

class UserRequestedLogout extends AuthEvent {
  const UserRequestedLogout();
}
