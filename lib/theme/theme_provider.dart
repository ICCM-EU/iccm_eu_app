import 'package:flutter/material.dart';

import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';
import 'package:iccm_eu_app/data/preferences_provider.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  ThemeData themeData = lightTheme;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme(); // Load theme on initialization
  }

  Future<void> saveTheme(bool isDark) async {
    _isDarkMode = isDark;
    themeData = _isDarkMode ? darkTheme : lightTheme;
    await PreferencesProvider.setDarkTheme(isDark);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await PreferencesProvider.isDarkTheme;
    themeData = _isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}