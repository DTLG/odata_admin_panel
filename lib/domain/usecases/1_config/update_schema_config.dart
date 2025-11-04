import 'package:odata_admin_panel/domain/entities/schema_config.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class UpdateSchemaConfig {
  final IAdminRepository repository;
  const UpdateSchemaConfig(this.repository);

  Future<void> call(String schemaName, SchemaConfig config) =>
      repository.updateSchemaConfig(schemaName, config);
}
