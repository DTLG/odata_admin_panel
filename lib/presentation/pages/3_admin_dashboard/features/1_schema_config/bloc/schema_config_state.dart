part of 'schema_config_cubit.dart';

class SchemaConfigState extends Equatable {
  final bool loading;
  final List<String> schemas;
  final String? selectedSchema;
  final SchemaConfig? config;
  final bool missingConfig;

  const SchemaConfigState({
    required this.loading,
    required this.schemas,
    required this.selectedSchema,
    required this.config,
    required this.missingConfig,
  });

  const SchemaConfigState.initial()
    : loading = false,
      schemas = const [],
      selectedSchema = null,
      config = null,
      missingConfig = false;

  SchemaConfigState copyWith({
    bool? loading,
    List<String>? schemas,
    String? selectedSchema,
    SchemaConfig? config,
    bool? missingConfig,
  }) => SchemaConfigState(
    loading: loading ?? this.loading,
    schemas: schemas ?? this.schemas,
    selectedSchema: selectedSchema ?? this.selectedSchema,
    config: config ?? this.config,
    missingConfig: missingConfig ?? this.missingConfig,
  );

  @override
  List<Object?> get props => [
    loading,
    schemas,
    selectedSchema,
    config,
    missingConfig,
  ];
}
