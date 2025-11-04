import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/generate_accounts_usecase.dart';

enum GenerateStatus { initial, loading, success, failure }

class GenerateAccountsState extends Equatable {
  final GenerateStatus status;
  final String message;

  const GenerateAccountsState({
    this.status = GenerateStatus.initial,
    this.message = '',
  });

  GenerateAccountsState copyWith({GenerateStatus? status, String? message}) {
    return GenerateAccountsState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, message];
}

class GenerateAccountsCubit extends Cubit<GenerateAccountsState> {
  final GenerateAccountsUseCase _generateAccountsUseCase;

  GenerateAccountsCubit(this._generateAccountsUseCase)
    : super(const GenerateAccountsState());

  Future<void> generateAccounts({
    required String schemaName,
    required String defaultPassword,
  }) async {
    if (state.status == GenerateStatus.loading) return;
    emit(state.copyWith(status: GenerateStatus.loading, message: ''));
    try {
      final result = await _generateAccountsUseCase(
        schemaName: schemaName,
        defaultPassword: defaultPassword,
        agentNameColumn: 'name',
        agentPkColumn: 'guid',
      );
      final successCount = (result['successful_migrations'] as List).length;
      final failureCount = (result['failed_migrations'] as List).length;
      final message = 'Успішно: $successCount. Помилок: $failureCount.';
      emit(state.copyWith(status: GenerateStatus.success, message: message));
    } catch (e) {
      emit(
        state.copyWith(status: GenerateStatus.failure, message: e.toString()),
      );
    }
  }
}
