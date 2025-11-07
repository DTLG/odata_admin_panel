import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/entities/app_config.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

part 'personal_config_state.dart';

class PersonalConfigCubit extends Cubit<PersonalConfigState> {
  final IAdminRepository _repository;
  final String _userId;

  PersonalConfigCubit(this._repository, this._userId)
    : super(PersonalConfigState(config: AppConfig.empty()));

  Future<void> loadConfig() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Завантажуємо особистий конфіг
      final personalConfig = await _repository.adminGetPersonalConfig(_userId);

      emit(state.copyWith(isLoading: false, config: personalConfig));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Викликається, коли адмін змінює Dropdown
  void configChanged(AppConfig newConfig) {
    emit(state.copyWith(config: newConfig));
  }

  Future<void> saveConfig() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.adminUpdatePersonalConfig(
        _userId,
        state.config.toJson(),
      );
      emit(state.copyWith(isLoading: false, message: "Збережено!"));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }
}
