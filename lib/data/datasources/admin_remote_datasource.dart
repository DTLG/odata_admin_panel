import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:odata_admin_panel/data/models/app_config_model.dart';
import 'package:odata_admin_panel/data/models/schema_config_model.dart';
import 'package:odata_admin_panel/data/models/user_model.dart';

// Вам потрібно буде імпортувати ваші моделі
// import 'package:odata_admin_panel/data/models/schema_config_model.dart';
// import 'package:odata_admin_panel/data/models/user_model.dart';

// (!!!) Примітка: Я залишаю ваші 'UserModel' та 'SchemaConfigModel',
// але виправляю логіку викликів RPC та парсингу.
// Вам потрібно буде переконатися, що 'SchemaConfigModel.fromJson/toJson'
// обробляють *тільки* поля конфігу (без id).

class AdminRemoteDataSource {
  final SupabaseClient client;
  const AdminRemoteDataSource(this.client);

  Future<List<String>> getAllSchemas() async {
    final response = await client.rpc('admin_get_all_schemas');
    final data = (response as List?)?.cast<dynamic>() ?? <dynamic>[];

    // (!!!) ВИПРАВЛЕННЯ 1: Неправильний парсинг
    // RPC повертає List<Map<String, dynamic>>, напр. [{'schema_name': 'org_a'}]
    // Нам потрібно витягнути 'schema_name'.
    return data.map((e) => e['schema_name'] as String).toList();
  }

  Future<SchemaConfigModel> getSchemaConfig(String schema) async {
    final response = await client.rpc(
      'admin_get_schema_config',
      params: {
        'p_schema_name': schema,
      }, // <-- Це було виправлено вами, молодець!
    );
    return SchemaConfigModel.fromJson(
      (response as Map).cast<String, dynamic>(),
    );
  }

  // Створює службову таблицю/запис конфігу для схеми (provision)
  Future<String> provisionConfigTable(String schemaName) async {
    final response = await client.rpc(
      'admin_provision_schema_config',
      params: {'p_schema_name': schemaName},
    );
    return response as String;
  }

  // (!!!) ВИПРАВЛЕННЯ 2: Неправильна сигнатура виклику
  // SQL-функція очікує 'p_schema_name' та 'p_config_data'
  Future<void> updateSchemaConfig({
    required String schemaName,
    required SchemaConfigModel model,
  }) async {
    final result = await client.rpc(
      'admin_update_schema_config',
      params: {'p_schema_name': schemaName, 'p_config_data': model.toJson()},
    );
    print('updateSchemaConfig result: $result');
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final response = await client.rpc(
      'admin_search_users',
      // (!!!) ВИПРАВЛЕННЯ 3: Неправильна назва параметра
      params: {'p_search_term': query}, // Було 'q'
    );
    final list = (response as List?)?.cast<Map>() ?? <Map>[];
    return list
        .map((m) => UserModel.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> changeUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    await client.rpc(
      'admin_change_user_password',
      // (!!!) ВИПРАВЛЕННЯ 4: Неправильні назви параметрів
      params: {
        'p_user_id': userId, // Було 'user_id'
        'p_new_password': newPassword, // Було 'new_password'
      },
    );
  }

  Future<void> changeUserLogin({
    required String userId,
    required String newLogin,
  }) async {
    await client.rpc(
      'admin_change_user_login',
      params: {
        'p_user_id': userId,
        'p_new_login': newLogin,
        'p_email_domain': '@mail.com',
      },
    );
  }

  // Генерація акаунтів агентів для обраної схеми
  Future<Map<String, dynamic>> generateAccountsForSchema({
    required String schemaName,
    required String defaultPassword,
    required String agentNameColumn,
    required String agentPkColumn,
  }) async {
    final response = await client.rpc(
      'admin_bulk_generate_auth_for_schema',
      params: {
        'p_schema_name': schemaName,
        'p_default_password': defaultPassword,
        'p_email_domain': '@mail.com',
        'p_agent_name_column': agentNameColumn,
        'p_agent_pk_column': agentPkColumn,
      },
    );
    return (response as Map).cast<String, dynamic>();
  }

  // Персональні конфіги користувачів
  Future<AppConfigModel> adminGetPersonalConfig(String userId) async {
    final response = await client.rpc(
      'admin_get_personal_config',
      params: {'p_user_id': userId},
    );
    if (response == null) {
      // Якщо конфігу немає, повертаємо порожню модель
      return const AppConfigModel();
    }
    return AppConfigModel.fromJson((response as Map).cast<String, dynamic>());
  }

  Future<void> adminUpdatePersonalConfig(
    String userId,
    Map<String, dynamic> config,
  ) async {
    await client.rpc(
      'admin_update_personal_config',
      params: {'p_user_id': userId, 'p_config_data': config},
    );
  }
}
