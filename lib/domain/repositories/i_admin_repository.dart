import 'package:odata_admin_panel/domain/entities/app_config.dart';
import 'package:odata_admin_panel/domain/entities/schema_config.dart';
import 'package:odata_admin_panel/domain/entities/user.dart';

abstract class IAdminRepository {
  Future<List<String>> getAllSchemas();
  Future<SchemaConfig> getSchemaConfig(String schema);
  Future<void> updateSchemaConfig(String schemaName, SchemaConfig config);
  Future<String> provisionSchemaConfig(String schemaName);

  Future<List<User>> searchUsers(String query);
  Future<void> changeUserPassword({
    required String userId,
    required String newPassword,
  });

  Future<void> changeUserLogin({
    required String userId,
    required String newLogin,
  });

  Future<Map<String, dynamic>> generateAccountsForSchema({
    required String schemaName,
    required String defaultPassword,
    required String agentNameColumn,
    required String agentPkColumn,
  });

  // Персональні конфіги користувачів
  Future<AppConfig> adminGetPersonalConfig(String userId);
  Future<void> adminUpdatePersonalConfig(
    String userId,
    Map<String, dynamic> config,
  );
}
