import 'package:flutter/material.dart';

import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme(); // Load theme on initialization
  }

  Future<void> saveTheme(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await PreferencesProvider.setDarkTheme(isDark);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    themeMode = await PreferencesProvider.isDarkTheme;
    notifyListeners();
  }
}