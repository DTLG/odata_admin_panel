import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:odata_admin_panel/domain/entities/login_pin.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';

class MapFilters extends Equatable {
  final DateTimeRange dateRange;
  final User? selectedUser; // null означає "Всі"

  const MapFilters({required this.dateRange, this.selectedUser});

  // Початкові фільтри (напр., останній тиждень)
  factory MapFilters.initial() {
    final now = DateTime.now();
    return MapFilters(
      dateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );
  }

  MapFilters copyWith({
    DateTimeRange? dateRange,
    User? selectedUser,
  }) {
    return MapFilters(
      dateRange: dateRange ?? this.dateRange,
      selectedUser: selectedUser ?? this.selectedUser,
    );
  }

  @override
  List<Object?> get props => [dateRange, selectedUser];
}

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object> get props => [message];
}

class MapLoaded extends MapState {
  final List<LoginPin> pins; // Піни для карти
  final List<User> allUsers; // Список користувачів для фільтру
  final MapFilters filters; // Поточні фільтри

  const MapLoaded({
    required this.pins,
    required this.allUsers,
    required this.filters,
  });

  @override
  List<Object> get props => [pins, allUsers, filters];
}

