import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Typographies de la maquette : Bangers (logo, titres, gros boutons),
/// Poppins (interface), Roboto Mono (chronomètre, scores, code de salon).
@immutable
class AppTheme {
  const AppTheme._();

  static const String displayFont = 'Bangers';
  static const String bodyFont = 'Poppins';
  static const String monoFont = 'RobotoMono';

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.yellow,
      primary: AppColors.yellow,
      secondary: AppColors.teal,
      tertiary: AppColors.purple,
      error: AppColors.coral,
      surface: AppColors.bgBottom,
      surfaceContainerHighest: AppColors.bgTop,
      onPrimary: AppColors.navyBlue,
      onSecondary: AppColors.navyBlue,
      onSurface: AppColors.offWhite,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0E1424),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFont,
        height: 0.9,
        fontSize: 84,
        color: AppColors.offWhite,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFont,
        height: 0.95,
        fontSize: 46,
        color: AppColors.offWhite,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFont,
        height: 1,
        fontSize: 40,
        color: AppColors.offWhite,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 34,
        height: 1.05,
        color: AppColors.offWhite,
      ),
      headlineSmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        color: AppColors.offWhite,
      ),
      titleLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.offWhite,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.offWhite,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        color: AppColors.offWhite,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFFB9C6DD),
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0x33FFFFFF)),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        mouseCursor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        mouseCursor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
        ),
      ),
    ),
  );

  /// Force l'orientation portrait (cahier §8, prompt §8).
  static List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];
}
