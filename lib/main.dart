import 'package:flutter/material.dart';
import 'package:odata_admin_panel/main_app.dart';
import 'package:odata_admin_panel/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const AdminApp());
}
