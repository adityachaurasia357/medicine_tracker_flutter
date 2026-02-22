// lib/state/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // FIXED: Changed from ThemeMode.system to ThemeMode.light
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  String get themeName {
    // Simplified since we are prioritizing manual choice
    return _themeMode == ThemeMode.light ? "Light Mode" : "Dark Mode";
  }
}