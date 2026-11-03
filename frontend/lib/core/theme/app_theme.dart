import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thème commun de l'application.
class AppTheme {
  const AppTheme._();

  static const String displayFont = 'Roboto';
  static const String bodyFont = 'Roboto';
  static const String monoFont = 'monospace';

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB703),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF17233A),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  static const List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];
}
