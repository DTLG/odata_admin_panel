import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/search_users.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/change_user_password.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/change_user_login.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final SearchUsers _searchUsers;
  final ChangeUserPassword _changeUserPassword;
  final ChangeUserLogin _changeUserLogin;

  UserManagementBloc({
    required SearchUsers searchUsers,
    required ChangeUserPassword changeUserPassword,
    required ChangeUserLogin changeUserLogin,
  }) : _searchUsers = searchUsers,
       _changeUserPassword = changeUserPassword,
       _changeUserLogin = changeUserLogin,
       super(const UserManagementState()) {
    on<SearchTermChanged>(_onSearchTermChanged, transformer: droppable());
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
    on<LoginChangeRequested>(_onLoginChangeRequested);
  }

  Future<void> _onSearchTermChanged(
    SearchTermChanged event,
    Emitter<UserManagementState> emit,
  ) async {
    if (event.term.isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.initial,
          users: const [],
          currentSearchTerm: '',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        currentSearchTerm: event.term,
      ),
    );
    try {
      final users = await _searchUsers(event.term);
      emit(
        state.copyWith(
          status: SearchStatus.success,
          users: users,
          currentSearchTerm: event.term,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          message: e.toString(),
          currentSearchTerm: event.term,
        ),
      );
    }
  }

  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(updateStatus: UserUpdateStatus.loading));
    try {
      await _changeUserPassword(
        userId: event.userId,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          updateStatus: UserUpdateStatus.success,
          message: 'Пароль успішно змінено!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updateStatus: UserUpdateStatus.failure,
          message: e.toString(),
        ),
      );
    }
    emit(state.copyWith(updateStatus: UserUpdateStatus.initial));
  }

  Future<void> _onLoginChangeRequested(
    LoginChangeRequested event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(state.copyWith(updateStatus: UserUpdateStatus.loading));
    try {
      // Викликаємо API для зміни логіна
      await _changeUserLogin(userId: event.userId, newLogin: event.newLogin);

      // Емітуємо успіх
      emit(
        state.copyWith(
          updateStatus: UserUpdateStatus.success,
          message: 'Логін успішно змінено.',
        ),
      );

      // Оновлюємо список, отримуючи свіжі дані з сервера
      // (джерело правди - це завжди бекенд)
      if (state.currentSearchTerm.isNotEmpty) {
        emit(state.copyWith(status: SearchStatus.loading));
        try {
          final users = await _searchUsers(state.currentSearchTerm);
          emit(state.copyWith(status: SearchStatus.success, users: users));
        } catch (e) {
          emit(
            state.copyWith(status: SearchStatus.failure, message: e.toString()),
          );
        }
      }
    } catch (e) {
      final msg = e.toString().contains('duplicate key')
          ? 'Помилка: Цей логін вже зайнятий.'
          : e.toString();
      emit(
        state.copyWith(updateStatus: UserUpdateStatus.failure, message: msg),
      );
    }
    emit(state.copyWith(updateStatus: UserUpdateStatus.initial));
  }
}
