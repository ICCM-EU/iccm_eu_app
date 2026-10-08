import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

import '../../utils/debug.dart';
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
    ValueNotifier([FcmNotificationsService.normalizedDefault]);

  static Set<String> _getValidNormalizedTopics([TracksProvider? tracksProvider]) {
    final topics = FcmNotificationsService().getTopics(tracksProvider);
    return topics.map((t) => TextFunctions.normalizeListKey(t, listSep)).toSet();
  }

  static Future<void> loadNotificationTopics([TracksProvider? tracksProvider]) async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_notificationTopics) ??
        FcmNotificationsService.normalizedDefault;
    // Ensure the values read are in the normalized format
    final normalizedTopics = value
        .split(listSep)
        .where((t) => t.isNotEmpty)
        .toList();

    // Add the default topic if not in the list
    if (!normalizedTopics.contains(FcmNotificationsService.normalizedDefault)) {
      normalizedTopics.add(FcmNotificationsService.normalizedDefault);
    }

    // Clean topics which are neither defaultTopic, testTopic nor in getTopics
    final validTopics = _getValidNormalizedTopics(tracksProvider);
    final cleanedTopics = normalizedTopics
        .where((t) => validTopics.contains(t))
        .toList();

    cleanedTopics.sort();
    notificationTopicsNotifier.value = cleanedTopics;
    await prefs.setString(_notificationTopics, cleanedTopics.join(listSep));
  }

  static Future<void> addNotificationTopic(String value, [TracksProvider? tracksProvider]) async {
    String normalizedTopic = TextFunctions.normalizeListKey(value, listSep);
    final validTopics = _getValidNormalizedTopics(tracksProvider);

    if (!validTopics.contains(normalizedTopic)) {
      Debug.msg('Cannot add topic $value ($normalizedTopic): Not in valid topics.');
      return;
    }

    final list = List<String>.from(notificationTopicsNotifier.value);
    if (!list.contains(normalizedTopic)) {
      if (await FcmNotificationsService.subscribeToTopic(value, userGesture: true)) {
        list.add(normalizedTopic);
        final cleanedList = list.where((t) => validTopics.contains(t)).toList();
        cleanedList.sort();
        notificationTopicsNotifier.value = cleanedList;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notificationTopics,
            cleanedList.join(listSep));
      }
    }
  }

  static Future<void> removeNotificationTopic(String value, [TracksProvider? tracksProvider]) async {
    String normalizedTopic = TextFunctions.normalizeListKey(value, listSep);
    final String defaultKey = FcmNotificationsService.normalizedDefault;
    if (normalizedTopic == defaultKey) {
      return;
    }
    final validTopics = _getValidNormalizedTopics(tracksProvider);
    final list = List<String>.from(notificationTopicsNotifier.value);
    if (list.contains(normalizedTopic)) {
      if (await FcmNotificationsService.unsubscribeFromTopic(value, userGesture: true)) {
        list.remove(normalizedTopic);
      }
    }
    final cleanedList = list.where((t) => validTopics.contains(t)).toList();
    cleanedList.sort();
    notificationTopicsNotifier.value = cleanedList;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTopics,
        cleanedList.join(listSep));
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
  static const String _fcmSendTopic = 'fcmSendTopic';
  static final ValueNotifier<String> fcmSendTopicNotifier =
    ValueNotifier(FcmNotificationsService.defaultTopic);

  static Future<void> loadSendTopic() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_fcmSendTopic) ?? FcmNotificationsService.defaultTopic;
    if (value.isEmpty) {
      value = FcmNotificationsService.defaultTopic;
    }
    fcmSendTopicNotifier.value = value;
  }

  static Future<void> setSendTopic(String value) async {
    fcmSendTopicNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmSendTopic, value);
  }

  // ---------------------------------------------------------
  static const String _fcmSendTitle = 'fcmSendTitle';
  static final ValueNotifier<String> fcmSendTitleNotifier =
  ValueNotifier("Conference Announcement");

  static Future<void> loadSendTitle() async {
    String value = "";
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getString(_fcmSendTitle) ?? "Conference Announcement";
    if (value.isEmpty) {
      value = "Conference Announcement";
    }
    fcmSendTitleNotifier.value = value;
  }

  static Future<void> setSendTitle(String value) async {
    fcmSendTitleNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmSendTitle, value);
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
