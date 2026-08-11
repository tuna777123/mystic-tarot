import 'package:flutter/material.dart';

class MysticColors {
  static const ink = Color(0xFF080711);
  static const night = Color(0xFF151128);
  static const elevated = Color(0xFF1B1630);
  static const violet = Color(0xFF7657D6);
  static const lavender = Color(0xFFCAB8FF);
  static const gold = Color(0xFFE8C77A);
  static const goldSoft = Color(0xFFF4DFA8);
  static const mist = Color(0xFFF5F0FF);
  static const muted = Color(0xFFA9A2BC);
}

ThemeData buildMysticTheme() {
  final seedScheme = ColorScheme.fromSeed(
    seedColor: MysticColors.violet,
    brightness: Brightness.dark,
    surface: MysticColors.night,
  );
  final scheme = seedScheme.copyWith(
    primary: MysticColors.gold,
    onPrimary: MysticColors.ink,
    secondary: MysticColors.lavender,
    onSecondary: MysticColors.ink,
    surface: MysticColors.night,
    onSurface: MysticColors.mist,
    outline: MysticColors.lavender.withValues(alpha: .22),
  );
  final actionShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(17),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: MysticColors.ink,
    canvasColor: MysticColors.ink,
    fontFamily: 'Georgia',
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 38,
        height: 1.06,
        fontWeight: FontWeight.w500,
        letterSpacing: -.45,
        color: MysticColors.mist,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.12,
        fontWeight: FontWeight.w600,
        letterSpacing: -.25,
        color: MysticColors.mist,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.18,
        fontWeight: FontWeight.w600,
        color: MysticColors.mist,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
        height: 1.52,
        color: MysticColors.mist,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        height: 1.44,
        color: MysticColors.muted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Arial',
        fontWeight: FontWeight.w800,
        letterSpacing: .15,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: MysticColors.ink,
        backgroundColor: MysticColors.gold,
        disabledForegroundColor: MysticColors.muted,
        disabledBackgroundColor: Colors.white.withValues(alpha: .08),
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: .1,
        ),
        shape: actionShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MysticColors.mist,
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: MysticColors.lavender.withValues(alpha: .3)),
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w800,
        ),
        shape: actionShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MysticColors.lavender,
        textStyle: const TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 70,
      elevation: 0,
      backgroundColor: const Color(0xFF100D1E),
      indicatorColor: MysticColors.violet.withValues(alpha: .32),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? MysticColors.goldSoft : MysticColors.muted,
          size: selected ? 24 : 23,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Arial',
          color: selected ? MysticColors.mist : MysticColors.muted,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: .045),
      selectedColor: MysticColors.violet.withValues(alpha: .42),
      disabledColor: Colors.white.withValues(alpha: .025),
      checkmarkColor: MysticColors.gold,
      side: BorderSide(color: MysticColors.lavender.withValues(alpha: .16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: const TextStyle(
        fontFamily: 'Arial',
        color: MysticColors.mist,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF171321),
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0xC0080711),
      elevation: 24,
      showDragHandle: false,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF211A31),
      contentTextStyle: const TextStyle(
        fontFamily: 'Arial',
        color: MysticColors.mist,
        fontWeight: FontWeight.w700,
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
      fillColor: Colors.white.withValues(alpha: .05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: MysticColors.muted),
      labelStyle: const TextStyle(color: MysticColors.lavender),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: MysticColors.gold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: scheme.error.withValues(alpha: .75),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.error, width: 1.4),
      ),
    ),
  );
}
