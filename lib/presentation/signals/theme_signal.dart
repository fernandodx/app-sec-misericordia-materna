import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ThemeSignal {
  static const String _prefKey = 'app_theme_mode';

  final themeMode = signal<ThemeMode>(ThemeMode.system);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'light') {
        themeMode.value = ThemeMode.light;
      } else if (saved == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else {
        themeMode.value = ThemeMode.system;
      }
    } catch (_) {
      themeMode.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.light:
          await prefs.setString(_prefKey, 'light');
          break;
        case ThemeMode.dark:
          await prefs.setString(_prefKey, 'dark');
          break;
        case ThemeMode.system:
          await prefs.setString(_prefKey, 'system');
          break;
      }
    } catch (_) {}
  }

  bool isDarkMode(BuildContext context) {
    if (themeMode.value == ThemeMode.dark) return true;
    if (themeMode.value == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}

final themeSignal = ThemeSignal();
