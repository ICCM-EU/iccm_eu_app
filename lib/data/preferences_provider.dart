import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class PreferencesProvider {
  // ---------------------------------------------------------
  static const String _isDarkThemeKey = 'isDarkTheme';

  static Future<bool> get isDarkTheme async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkThemeKey) ?? false; // Default to false
  }

  static Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkThemeKey, value);
  }
}
