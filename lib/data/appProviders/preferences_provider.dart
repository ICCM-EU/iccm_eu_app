import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class PreferencesProvider {
  // ---------------------------------------------------------
  static const String _isDarkThemeKey = 'isDarkTheme';

  static Future<bool> get isDarkTheme async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkThemeKey) ?? true; // Default
  }

  static Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkThemeKey, value);
  }

  // ---------------------------------------------------------
  static const String _currentNavigationKey = 'currentNavigationKey';

  static Future<int> get currentNavigation async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentNavigationKey) ?? 0; // Default
  }

  static Future<void> setCurrentNavigation(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentNavigationKey, value);
  }

  // ---------------------------------------------------------
  static const String _timerRoomFilterKey = 'timerRoomFilter';

  static Future<String> get timerRoomFilter async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timerRoomFilterKey) ?? ''; // Default
  }

  static Future<void> setTimerRoomFilter(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timerRoomFilterKey, value);
  }

  // ---------------------------------------------------------
  static const String _calendarColorByRoomKey = 'calendarColorByRoom';
  static final ValueNotifier<bool> calendarColorByRoomNotifier = ValueNotifier(false);

  static Future<void> loadCalendarColorByRoom() async {
    final prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_calendarColorByRoomKey) ?? false; // Default
    calendarColorByRoomNotifier.value = value;
  }

  static Future<void> setCalendarColorByRoom(bool value) async {
    calendarColorByRoomNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarColorByRoomKey, value);
  }

  // ---------------------------------------------------------
  static const String _isDayViewKey = 'isDayView';

  static Future<bool> get isDayView async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDayViewKey) ?? true; // Default
  }

  static Future<void> setIsDayView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDayViewKey, value);
  }

  // ---------------------------------------------------------
  static const String _futureEventsKey = 'futureEvents';

  static Future<bool> get futureEvents async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_futureEventsKey) ?? false; // Default
  }

  static Future<void> setFutureEvents(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_futureEventsKey, value);
  }

  // ---------------------------------------------------------
  static const String _cachedChecksumKey = '_cachedChecksum';

  static Future<String> get cachedChecksum async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedChecksumKey) ?? ''; // Default
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
