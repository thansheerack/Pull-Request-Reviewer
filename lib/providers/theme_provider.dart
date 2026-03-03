import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Possible theme modes stored in preferences.
enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  AppThemeMode _mode = AppThemeMode.system;

  ThemeProvider() {
    _loadFromPrefs();
  }

  AppThemeMode get mode => _mode;

  bool get isDarkMode {
    if (_mode == AppThemeMode.dark) return true;
    if (_mode == AppThemeMode.light) return false;
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark;
  }

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs.getString('theme_mode');
    if (stored != null) {
      _mode = AppThemeMode.values.firstWhere(
        (e) => e.toString() == stored,
        orElse: () => AppThemeMode.system,
      );
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setString('theme_mode', _mode.toString());
  }

  void toggleTheme() {
    switch (_mode) {
      case AppThemeMode.light:
        _mode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        _mode = AppThemeMode.system;
        break;
      case AppThemeMode.system:
      default:
        _mode = AppThemeMode.light;
        break;
    }
    _saveToPrefs();
    notifyListeners();
  }

  void setMode(AppThemeMode mode) {
    _mode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.light,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }
}
