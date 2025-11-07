import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/core/theme/app_theme.dart';
import 'package:odata_admin_panel/data/datasources/admin_remote_datasource.dart';
import 'package:odata_admin_panel/data/repositories/admin_repository_impl.dart';
import 'package:odata_admin_panel/domain/repositories/i_admin_repository.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/get_all_schemas.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/get_schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/provision_schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/1_config/update_schema_config.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/change_user_password.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/change_user_login.dart';
import 'package:odata_admin_panel/domain/usecases/2_users/search_users.dart';
import 'package:odata_admin_panel/presentation/bloc/auth/auth_bloc.dart';
import 'package:odata_admin_panel/presentation/pages/0_auth_gate/auth_gate_page.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/1_schema_config/bloc/schema_config_cubit.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/bloc/user_management_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final remote = AdminRemoteDataSource(client);
    final repo = AdminRepositoryImpl(remote);

    return RepositoryProvider<IAdminRepository>.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(client)),
          BlocProvider(
            create: (_) => SchemaConfigCubit(
              provisionSchemaConfig: ProvisionSchemaConfig(repo),
              getAllSchemas: GetAllSchemas(repo),
              getSchemaConfig: GetSchemaConfig(repo),
              updateSchemaConfig: UpdateSchemaConfig(repo),
            ),
          ),
          BlocProvider(
            create: (_) => UserManagementBloc(
              changeUserLogin: ChangeUserLogin(repo),
              searchUsers: SearchUsers(repo),
              changeUserPassword: ChangeUserPassword(repo),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const AuthGatePage(),
        ),
      ),
    );
  }
}
