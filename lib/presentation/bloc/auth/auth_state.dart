part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool? isAuthenticated;
  final bool isAdmin;

  const AuthState._({required this.isAuthenticated, required this.isAdmin});

  const AuthState.unknown() : this._(isAuthenticated: null, isAdmin: false);
  const AuthState.unauthenticated()
    : this._(isAuthenticated: false, isAdmin: false);
  const AuthState.authenticated({required bool isAdmin})
    : this._(isAuthenticated: true, isAdmin: isAdmin);

  @override
  List<Object?> get props => [isAuthenticated, isAdmin];
}
