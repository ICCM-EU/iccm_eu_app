import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

import '../../utils/text_functions.dart';
import '../notifications/fcm_notifications_service.dart';

class PreferencesProvider {
  static const String listSep = "|";

  // ---------------------------------------------------------
  static const String _isDarkThemeKey = 'isDarkTheme';

  static Future<ThemeMode> get isDarkTheme async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool(_isDarkThemeKey);
    return (darkMode ?? true) ? ThemeMode.dark: ThemeMode.light;
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
  static final ValueNotifier<bool> calendarColorByRoomNotifier =
    ValueNotifier(false);

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
  static final ValueNotifier<bool> useTestDataNotifier =
    ValueNotifier(false);

  static Future<void> loadUseTestData() async {
    bool value = false;
    if (EventsProvider.showTestDataOption()) {
      final prefs = await SharedPreferences.getInstance();
      value = prefs.getBool(_useTestDataKey) ?? false; // Default
    }
    useTestDataNotifier.value = value;
  }

  static Future<void> setUseTestData(bool value) async {
    if (EventsProvider.showTestDataOption()) {
      useTestDataNotifier.value = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useTestDataKey, value);
    } else {
      useTestDataNotifier.value = false;
    }
  }

    // ---------------------------------------------------------
  static const String _notificationTopics = 'notificationsTopics';
  static final ValueNotifier<List<String>> notificationTopicsNotifier =
    ValueNotifier(FcmNotificationsService.defaultTopic.split(','));

  static Future<void> loadNotificationTopics() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_notificationTopics) ??
        FcmNotificationsService.defaultTopic;
    notificationTopicsNotifier.value = value.split(listSep);
    if (!notificationTopicsNotifier.value.contains(FcmNotificationsService.defaultTopic)) {
      notificationTopicsNotifier.value.add(FcmNotificationsService.defaultTopic);
    }
    notificationTopicsNotifier.value.sort();
  }

  static Future<void> addNotificationTopic(String value) async {
    value = TextFunctions.normalizeListKey(value, listSep);
    final list = List<String>.from(notificationTopicsNotifier.value);
    if (!list.contains(value)) {
      if (await FcmNotificationsService.subscribeToTopic(value, userGesture: true)) {
        list.add(value);
        list.sort();
        notificationTopicsNotifier.value = list;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notificationTopics,
            notificationTopicsNotifier.value.join(listSep));
      }
    }
  }

  static Future<void> removeNotificationTopic(String value) async {
    value = TextFunctions.normalizeListKey(value, listSep);
    final String defaultKey = TextFunctions.normalizeListKey(
      FcmNotificationsService.defaultTopic,
      listSep,
    );
    if (value == defaultKey) {
      return;
    }
    final list = List<String>.from(notificationTopicsNotifier.value);
    if (list.contains(value)) {
      if (await FcmNotificationsService.unsubscribeFromTopic(value, userGesture: true)) {
        list.remove(value);
        notificationTopicsNotifier.value = list;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notificationTopics,
            notificationTopicsNotifier.value.join(listSep));
      }
    }
  }

  // ---------------------------------------------------------
  static const String _notificationsNickname = 'notificationsNickname';
  static final ValueNotifier<String> notificationsNicknameNotifier =
    ValueNotifier("");

  static Future<void> loadNotificationsNickname() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_notificationsNickname) ?? "";
    notificationsNicknameNotifier.value = value;
  }

  static Future<void> setNotificationsNickname(String value) async {
    notificationsNicknameNotifier.value = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsNickname, value);
  }

  // ---------------------------------------------------------
  static const String _fcmAdminPwd = 'fcmAdminPwd';
  static final ValueNotifier<String> fcmAdminPwdNotifier =
    ValueNotifier("");

  static Future<void> loadFcmAdminPwd() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_fcmAdminPwd) ?? "";
    fcmAdminPwdNotifier.value = value;
  }

  static Future<void> setFcmAdminPwd(String value) async {
    fcmAdminPwdNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmAdminPwd, value);
  }

  // ---------------------------------------------------------
  static const String _fcmToken = 'fcmToken';
  static final ValueNotifier<String> fcmTokenNotifier =
    ValueNotifier("");

  static Future<void> loadFcmToken() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_fcmToken) ?? "";
    fcmTokenNotifier.value = value;
  }

  static Future<void> setFcmToken(String value) async {
    fcmTokenNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmToken, value);
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
  static final ValueNotifier<bool> futureEventsNotifier =
    ValueNotifier(false);

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
