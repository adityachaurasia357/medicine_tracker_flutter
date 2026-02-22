// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Light Palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color cardWhite = Colors.white;
  static const Color textBlack = Color(0xFF1A1A1A);

  // Dark Palette
  static const Color backgroundDark = Color(0xFF12141C); // Deep Charcoal
  static const Color cardDark = Color(0xFF1C1F2A); // Lighter Surface
  static const Color textWhite = Color(0xFFF5F7FA);

  // Status Colors
  static const Color successGreen = Color(0xFFE8F5E9);
  static const Color successGreenDark = Color(0xFF1B3320);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        surface: cardWhite,
        onSurface: textBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textBlack),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        surface: cardDark,
        onSurface: textWhite,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textWhite),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}