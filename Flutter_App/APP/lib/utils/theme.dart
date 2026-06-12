import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0D0F0E);
  static const Color surface = Color(0xFF151817);
  static const Color card = Color(0xFF151817);
  static const Color accent = Color(0xFF8BC34A);
  static const Color accentDim = Color(0xFF6D8B37);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF7A827A);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: surface,
      background: background,
      onPrimary: Colors.black,
      onSurface: Colors.white,
      onBackground: textSecondary,
      onSecondary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      foregroundColor: textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentDim,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: const CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
    ),
    iconTheme: const IconThemeData(color: accent),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white10),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 16,
        offset: Offset(0, 10),
      ),
    ],
  );
}
