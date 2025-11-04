import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odata_admin_panel/presentation/bloc/auth/auth_bloc.dart';
import 'package:odata_admin_panel/presentation/pages/1_login/login_page.dart';
import 'package:odata_admin_panel/presentation/pages/2_unauthorized/unauthorized_page.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/admin_dashboard_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated == null) {
          context.read<AuthBloc>().add(const AppStarted());
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.isAuthenticated == false) {
          return const LoginPage();
        }
        if (!state.isAdmin) {
          return const UnauthorizedPage();
        }
        return const AdminDashboardPage();
      },
    );
  }
}
