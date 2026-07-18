import 'package:flutter/material.dart';

class MysticColors {
  static const ink = Color(0xFF090816);
  static const night = Color(0xFF151128);
  static const violet = Color(0xFF7657D6);
  static const lavender = Color(0xFFCAB8FF);
  static const gold = Color(0xFFE8C77A);
  static const mist = Color(0xFFF2ECFF);
  static const muted = Color(0xFFA49DB8);
}

ThemeData buildMysticTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MysticColors.violet,
    brightness: Brightness.dark,
    surface: MysticColors.night,
  );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: MysticColors.ink,
    fontFamily: 'Georgia',
    useMaterial3: true,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 38, height: 1.08, fontWeight: FontWeight.w500, color: MysticColors.mist),
      headlineMedium: TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w600, color: MysticColors.mist),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: MysticColors.mist),
      bodyLarge: TextStyle(fontFamily: 'Arial', fontSize: 16, height: 1.55, color: MysticColors.mist),
      bodyMedium: TextStyle(fontFamily: 'Arial', fontSize: 14, height: 1.45, color: MysticColors.muted),
      labelLarge: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w700, letterSpacing: .2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withValues(alpha: .1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withValues(alpha: .1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: MysticColors.lavender)),
    ),
  );
}
