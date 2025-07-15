import 'package:flutter/material.dart';

/// Provides application-wide theme data for a modern, minimal, dark design.
class AppTheme {
  static const Color primary = Color(0xFFD21947);
  static const Color secondary = Color(0xFFE8F2E8);
  static const Color accent = Color(0xFF05FFEE);
  static const Color background = Color(0xFF181C23);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: background,
      onPrimary: Colors.white,
      onSecondary: primary,
      // background/onBackground are deprecated, use surface/onSurface
      // background: background,
      // onBackground: Colors.white,
      tertiary: accent,
      onSurface: Colors.white,
    ),
    cardTheme: const CardTheme(
      surfaceTintColor: background,
      color: Color(0xFF232634),
      elevation: 5,
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.black,
      elevation: 6,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF222634),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      labelStyle: TextStyle(color: accent),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF191B20),
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: accent,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: accent),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: accent, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
      labelLarge: TextStyle(color: accent, fontSize: 16),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
  );
}
