part of 'personal_config_cubit.dart';

class PersonalConfigState extends Equatable {
  final bool isLoading;
  final AppConfig config;
  final String message;

  const PersonalConfigState({
    this.isLoading = false,
    required this.config,
    this.message = '',
  });

  PersonalConfigState copyWith({
    bool? isLoading,
    AppConfig? config,
    String? message,
  }) {
    return PersonalConfigState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isLoading, config, message];
}
