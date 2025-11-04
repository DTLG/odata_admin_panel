import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static ThemeData dark() => ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
    useMaterial3: true,
  );
}
