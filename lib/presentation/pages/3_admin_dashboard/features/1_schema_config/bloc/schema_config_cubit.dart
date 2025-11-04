import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:odata_admin_panel/domain/entities/schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/get_all_schemas.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/get_schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/update_schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/provision_schema_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'schema_config_state.dart';

class SchemaConfigCubit extends Cubit<SchemaConfigState> {
  final GetAllSchemas getAllSchemas;
  final GetSchemaConfig getSchemaConfig;
  final UpdateSchemaConfig updateSchemaConfig;
  final ProvisionSchemaConfig provisionSchemaConfig;

  SchemaConfigCubit({
    required this.getAllSchemas,
    required this.getSchemaConfig,
    required this.updateSchemaConfig,
    required this.provisionSchemaConfig,
  }) : super(const SchemaConfigState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final schemas = await getAllSchemas();
    emit(state.copyWith(loading: false, schemas: schemas));
  }

  Future<void> selectSchema(String schema) async {
    emit(
      state.copyWith(
        loading: true,
        selectedSchema: schema,
        missingConfig: false,
        config: null,
      ),
    );
    try {
      final config = await getSchemaConfig(schema);
      emit(state.copyWith(loading: false, config: config));
    } on PostgrestException catch (e) {
      // 42P01 = undefined_table (relation does not exist)
      final isMissingRelation =
          e.code == '42P01' ||
          (e.message.toLowerCase().contains('relation') &&
              e.message.toLowerCase().contains('does not exist'));
      if (isMissingRelation) {
        emit(state.copyWith(loading: false, missingConfig: true, config: null));
        return;
      }
      rethrow;
    }
  }

  Future<void> createDefaultConfig() async {
    final schema = state.selectedSchema;
    if (schema == null) return;
    emit(state.copyWith(loading: true));
    final defaultConfig = const SchemaConfig();
    // Ensure schema config storage exists
    try {
      await provisionSchemaConfig(schema);
    } catch (_) {
      // ignore provisioning errors and try update anyway
    }
    await updateSchemaConfig(schema, defaultConfig);
    // Try to load again after creation
    try {
      final config = await getSchemaConfig(schema);
      emit(
        state.copyWith(loading: false, config: config, missingConfig: false),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, missingConfig: false));
    }
  }

  void cancelMissing() {
    // Return to schema selection without config
    emit(
      state.copyWith(selectedSchema: null, config: null, missingConfig: false),
    );
  }

  Future<void> updateFlag(String flagKey, bool value) async {
    final config = state.config;
    final schema = state.selectedSchema;
    if (config == null || schema == null) return;

    SchemaConfig updated = config;
    switch (flagKey) {
      case 'showLabelPrint':
        updated = config.copyWith(showLabelPrint: value);
        break;
      case 'showNomenclature':
        updated = config.copyWith(showNomenclature: value);
        break;
      case 'showCustomerOrders':
        updated = config.copyWith(showCustomerOrders: value);
        break;
      case 'showInventoryCheck':
        updated = config.copyWith(showInventoryCheck: value);
        break;
      case 'showKontragenty':
        updated = config.copyWith(showKontragenty: value);
        break;
      case 'showRepairRequests':
        updated = config.copyWith(showRepairRequests: value);
        break;
      case 'showStorages':
        updated = config.copyWith(showStorages: value);
        break;
      case 'showMovement':
        updated = config.copyWith(showMovement: value);
        break;
      default:
        return;
    }
    emit(state.copyWith(config: updated));
    await updateSchemaConfig(schema, updated);
  }
}
