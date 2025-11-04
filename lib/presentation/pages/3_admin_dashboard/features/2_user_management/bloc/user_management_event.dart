part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  @override
  List<Object> get props => const [];
}

class SearchTermChanged extends UserManagementEvent {
  final String term;
  const SearchTermChanged(this.term);
  @override
  List<Object> get props => [term];
}

class PasswordChangeRequested extends UserManagementEvent {
  final String userId;
  final String newPassword;
  const PasswordChangeRequested({
    required this.userId,
    required this.newPassword,
  });
  @override
  List<Object> get props => [userId, newPassword];
}

class LoginChangeRequested extends UserManagementEvent {
  final String userId;
  final String newLogin;
  const LoginChangeRequested({required this.userId, required this.newLogin});
  @override
  List<Object> get props => [userId, newLogin];
}
