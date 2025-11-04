import 'package:odata_admin_panel/data/datasources/admin_remote_datasource.dart';
import 'package:odata_admin_panel/data/models/schema_config_model.dart';
import 'package:odata_admin_panel/domain/entities/schema_config.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final AdminRemoteDataSource remote;
  const AdminRepositoryImpl(this.remote);

  @override
  Future<List<String>> getAllSchemas() => remote.getAllSchemas();

  @override
  Future<SchemaConfig> getSchemaConfig(String schema) async {
    final model = await remote.getSchemaConfig(schema);
    return model.toDomain();
  }

  @override
  Future<void> updateSchemaConfig(
    String schemaName,
    SchemaConfig config,
  ) async {
    await remote.updateSchemaConfig(
      schemaName: schemaName,
      model: SchemaConfigModel.fromDomain(config),
    );
  }

  @override
  Future<String> provisionSchemaConfig(String schemaName) async {
    return remote.provisionConfigTable(schemaName);
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final models = await remote.searchUsers(query);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> changeUserPassword({
    required String userId,
    required String newPassword,
  }) => remote.changeUserPassword(userId: userId, newPassword: newPassword);

  @override
  Future<void> changeUserLogin({
    required String userId,
    required String newLogin,
  }) => remote.changeUserLogin(userId: userId, newLogin: newLogin);

  @override
  Future<Map<String, dynamic>> generateAccountsForSchema({
    required String schemaName,
    required String defaultPassword,
    required String agentNameColumn,
    required String agentPkColumn,
  }) {
    return remote.generateAccountsForSchema(
      schemaName: schemaName,
      defaultPassword: defaultPassword,
      agentNameColumn: agentNameColumn,
      agentPkColumn: agentPkColumn,
    );
  }
}
