part of 'user_management_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

enum UserUpdateStatus { initial, loading, success, failure }

class UserManagementState extends Equatable {
  final SearchStatus status;
  final UserUpdateStatus updateStatus;
  final List<User> users;
  final String message;
  final String currentSearchTerm;

  const UserManagementState({
    this.status = SearchStatus.initial,
    this.updateStatus = UserUpdateStatus.initial,
    this.users = const [],
    this.message = '',
    this.currentSearchTerm = '',
  });

  UserManagementState copyWith({
    SearchStatus? status,
    UserUpdateStatus? updateStatus,
    List<User>? users,
    String? message,
    String? currentSearchTerm,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      updateStatus: updateStatus ?? this.updateStatus,
      users: users ?? this.users,
      message:
          message ??
          (updateStatus == UserUpdateStatus.initial ? '' : this.message),
      currentSearchTerm: currentSearchTerm ?? this.currentSearchTerm,
    );
  }

  @override
  List<Object> get props => [
    status,
    updateStatus,
    users,
    message,
    currentSearchTerm,
  ];
}
