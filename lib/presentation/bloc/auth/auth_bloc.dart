import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient client;
  AuthBloc(this.client) : super(const AuthState.unknown()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);

    // Слухаємо 'onAuthStateChange' для автоматичного оновлення стану
    client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(LoggedIn());
      } else {
        add(LoggedOut());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // onAuthStateChange обробить це автоматично, але ми
    // також можемо перевірити при першому запуску.
    final user = client.auth.currentUser;
    if (user == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    // (!!!) ГОЛОВНЕ ВИПРАВЛЕННЯ
    // 1. Дивимося в 'appMetadata' (сейф), а не 'userMetadata' (шафка).
    // 2. Шукаємо ключ 'role' і перевіряємо, чи його значення 'admin'.
    final isAdmin = (user.appMetadata['role'] as String?) == 'admin';

    emit(AuthState.authenticated(isAdmin: isAdmin));
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    // Цей метод викликається слухачем onAuthStateChange
    final user = client.auth.currentUser;
    if (user == null) {
      // Це не має статись, але про всяк випадок
      emit(const AuthState.unauthenticated());
      return;
    }

    // (!!!) ГОЛОВНЕ ВИПРАВЛЕННЯ
    final isAdmin = (user.appMetadata?['role'] as String?) == 'admin';

    emit(AuthState.authenticated(isAdmin: isAdmin));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    // 'onAuthStateChange' вже спрацював, але ми можемо
    // додатково викликати signOut, якщо 'LoggedOut' прийшов від UI.
    await client.auth.signOut();
    emit(const AuthState.unauthenticated());
  }
}
