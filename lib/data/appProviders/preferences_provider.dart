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

  // ---------------------------------------------------------
  static const String _isDayViewKey = 'isDayView';

  static Future<bool> get isDayView async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDayViewKey) ?? true; // Default to true
  }

  static Future<void> setIsDayView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDayViewKey, value);
  }

  // ---------------------------------------------------------
  static const String _cachedChecksumKey = '_cachedChecksum';

  static Future<String> get cachedChecksum async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedChecksumKey) ?? ''; // Default to empty
  }

  static Future<void> setCachedChecksum(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedChecksumKey, value);
  }

  // ---------------------------------------------------------
  static const String _cacheLastUpdatedKey = '_cacheLastUpdated';

  static Future<DateTime?> get cacheLastUpdated async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdatedMillis = prefs.getInt(_cacheLastUpdatedKey);
    if (lastUpdatedMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis);
    } else {
      return null;
    }
  }

  static Future<void> setLastUpdated(DateTime? lastUpdated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheLastUpdatedKey, lastUpdated!.millisecondsSinceEpoch);
  }
}
