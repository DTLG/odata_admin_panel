import 'package:flutter/material.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/1_schema_config/view/schema_config_view.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/features/2_user_management/view/user_management_view.dart';
import 'package:odata_admin_panel/presentation/pages/3_admin_dashboard/widgets/admin_navigation.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final views = [const SchemaConfigView(), const UserManagementView()];

    return Scaffold(
      body: Row(
        children: [
          AdminNavigation(
            index: index,
            onSelect: (i) => setState(() => index = i),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: views[index]),
        ],
      ),
    );
  }
}
