import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF4FBF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF121816);
  static const Color muted = Color(0xFF637067);
  static const Color line = Color(0xFFDDE9E0);
  static const Color primary = Color(0xFF1E9E5B);
  static const Color primaryDark = Color(0xFF0C5435);
  static const Color primarySoft = Color(0xFFDBF6E6);
  static const Color blueSoft = Color(0xFFE4F2FF);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'PingFang SC',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 32,
          height: 1.18,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: TextStyle(
          color: muted,
          fontSize: 14,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line),
        ),
      ),
    );
  }
}
