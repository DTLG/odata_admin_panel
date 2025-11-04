import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class GenerateAccountsUseCase {
  final IAdminRepository repository;
  GenerateAccountsUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String schemaName,
    required String defaultPassword,
    required String agentNameColumn,
    required String agentPkColumn,
  }) {
    return repository.generateAccountsForSchema(
      schemaName: schemaName,
      defaultPassword: defaultPassword,
      agentNameColumn: agentNameColumn,
      agentPkColumn: agentPkColumn,
    );
  }
}
