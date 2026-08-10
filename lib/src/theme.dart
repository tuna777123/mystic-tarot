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
  final premiumShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: MysticColors.ink,
    fontFamily: 'Georgia',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 38,
        height: 1.08,
        fontWeight: FontWeight.w500,
        color: MysticColors.mist,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: MysticColors.mist,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MysticColors.mist,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        height: 1.55,
        color: MysticColors.mist,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        height: 1.45,
        color: MysticColors.muted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Arial',
        fontWeight: FontWeight.w700,
        letterSpacing: .2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: MysticColors.ink,
        backgroundColor: MysticColors.gold,
        disabledForegroundColor: MysticColors.muted,
        disabledBackgroundColor: Colors.white.withValues(alpha: .08),
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: .15,
        ),
        shape: premiumShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MysticColors.mist,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        side: BorderSide(
          color: MysticColors.lavender.withValues(alpha: .28),
        ),
        shape: premiumShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MysticColors.lavender,
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF171321),
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0xB3090816),
      elevation: 20,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF211A31),
      contentTextStyle: const TextStyle(
        fontFamily: 'Arial',
        color: MysticColors.mist,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      elevation: 12,
    ),
    dividerTheme: DividerThemeData(
      color: MysticColors.lavender.withValues(alpha: .12),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .055),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: .1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: .1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: MysticColors.gold, width: 1.4),
      ),
    ),
  );
}
