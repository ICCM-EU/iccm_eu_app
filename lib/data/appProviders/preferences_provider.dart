import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class PreferencesProvider {
  // ---------------------------------------------------------
  static const String _isDarkThemeKey = 'isDarkTheme';

  static Future<ThemeMode> get isDarkTheme async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool(_isDarkThemeKey);
    if (darkMode == null) {
      // var brightness = SchedulerBinding.instance.platformDispatcher
      //     .platformBrightness;
      // result = brightness == Brightness.dark;
      return ThemeMode.system;
    }
    return darkMode ? ThemeMode.dark: ThemeMode.light;
  }

  static Future<void> setDarkTheme(bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_isDarkThemeKey);
    } else {
      await prefs.setBool(_isDarkThemeKey, value);
    }
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
  static const String _useTestDataKey = 'useTestData';
  static final ValueNotifier<bool> useTestDataNotifier = ValueNotifier(false);

  static Future<void> loadUseTestData() async {
    bool value = false;
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      value = prefs.getBool(_useTestDataKey) ?? false; // Default
    }
    useTestDataNotifier.value = value;
  }

  static Future<void> setUseTestData(bool value) async {
    if (kDebugMode) {
      useTestDataNotifier.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useTestDataKey, value);
    } else {
      useTestDataNotifier.value = false;
    }
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
  static final ValueNotifier<bool> futureEventsNotifier = ValueNotifier(false);

  static Future<void> loadFutureEvents() async {
    final prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_futureEventsKey) ?? false; // Default
    futureEventsNotifier.value = value;
  }

  static Future<void> setFutureEvents(bool value) async {
    futureEventsNotifier.value = value;
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
