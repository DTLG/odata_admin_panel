import 'package:odata_admin_panel/domain/entities/schema_config.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class GetSchemaConfig {
  final IAdminRepository repository;
  const GetSchemaConfig(this.repository);

  Future<SchemaConfig> call(String schema) =>
      repository.getSchemaConfig(schema);
}
