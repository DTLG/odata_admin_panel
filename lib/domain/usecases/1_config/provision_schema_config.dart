import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class ProvisionSchemaConfig {
  final IAdminRepository repo;
  const ProvisionSchemaConfig(this.repo);

  Future<String> call(String schemaName) {
    return repo.provisionSchemaConfig(schemaName);
  }
}
