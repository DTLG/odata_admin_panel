import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/domain/entities/login_pin.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/map_state.dart';

class MapCubit extends Cubit<MapState> {
  final IAdminRepository _repository;

  MapCubit(this._repository) : super(MapInitial());

  // Перше завантаження: беремо список користувачів і піни за 7 днів
  Future<void> loadInitialData({
    String? initialAgentGuid,
    required String schemaName,
  }) async {
    emit(MapLoading());
    try {
      // 1. Отримуємо всіх користувачів для фільтру (пошук порожній рядок для всіх)
      final users = await _repository.searchUsers('');

      // 2. Отримуємо піни за початковими фільтрами
      final initialFilters = MapFilters.initial();
      final filters = initialAgentGuid != null
          ? initialFilters.copyWith(
              selectedUser: users.firstWhere(
                (u) => u.id == initialAgentGuid,
                orElse: () => users.first,
              ),
            )
          : initialFilters;

      final pins = await _fetchPins(filters, schemaName);

      emit(MapLoaded(pins: pins, allUsers: users, filters: filters));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  // Головний метод для оновлення по фільтру
  Future<void> applyFilters(MapFilters newFilters, String schemaName) async {
    final oldState = state;
    emit(MapLoading());

    try {
      final pins = await _fetchPins(newFilters, schemaName);

      // Повертаємо новий стан, але зберігаємо список користувачів
      if (oldState is MapLoaded) {
        emit(
          MapLoaded(
            pins: pins,
            allUsers: oldState.allUsers,
            filters: newFilters,
          ),
        );
      } else {
        // Якщо щось пішло не так, перезавантажуємо все
        await loadInitialData(schemaName: schemaName);
      }
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  // Приватний метод, що викликає репозиторій
  Future<List<LoginPin>> _fetchPins(
    MapFilters filters,
    String schemaName,
  ) async {
    return await _repository.getLoginPins(
      agentGuidFilter: filters.selectedUser?.id,
      dateFrom: filters.dateRange.start,
      dateTo: filters.dateRange.end,
      schemaName: schemaName,
    );
  }
}
