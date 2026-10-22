import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('darkTheme preference getter and setter', () async {
      await PreferencesProvider.setDarkTheme(true);
      expect(await PreferencesProvider.isDarkTheme, equals(ThemeMode.dark));

      await PreferencesProvider.setDarkTheme(false);
      expect(await PreferencesProvider.isDarkTheme, equals(ThemeMode.light));

      await PreferencesProvider.setDarkTheme(null);
      expect(await PreferencesProvider.isDarkTheme, equals(ThemeMode.dark));
    });

    test('currentNavigation preference getter and setter', () async {
      expect(await PreferencesProvider.currentNavigation, equals(0));

      await PreferencesProvider.setCurrentNavigation(4);
      expect(await PreferencesProvider.currentNavigation, equals(4));
    });

    test('timerRoomFilter preference getter and setter', () async {
      expect(await PreferencesProvider.timerRoomFilter, equals(''));

      await PreferencesProvider.setTimerRoomFilter('Main Hall');
      expect(await PreferencesProvider.timerRoomFilter, equals('Main Hall'));
    });

    test('calendarColorByRoom preference loading and setter', () async {
      await PreferencesProvider.setCalendarColorByRoom(true);
      expect(PreferencesProvider.calendarColorByRoomNotifier.value, isTrue);

      await PreferencesProvider.loadCalendarColorByRoom();
      expect(PreferencesProvider.calendarColorByRoomNotifier.value, isTrue);
    });

    test('inhibitNotifications preference getter and setter', () async {
      expect(await PreferencesProvider.inhibitNotifications, isFalse);

      await PreferencesProvider.setInhibitNotifications(true);
      expect(await PreferencesProvider.inhibitNotifications, isTrue);
    });

    test('notificationsNickname loading and setter', () async {
      await PreferencesProvider.setNotificationsNickname('JohnDoe');
      expect(PreferencesProvider.notificationsNicknameNotifier.value, equals('JohnDoe'));

      await PreferencesProvider.loadNotificationsNickname();
      expect(PreferencesProvider.notificationsNicknameNotifier.value, equals('JohnDoe'));
    });

    test('fcmAdminPwd loading and setter', () async {
      await PreferencesProvider.setFcmAdminPwd('secret123');
      expect(PreferencesProvider.fcmAdminPwdNotifier.value, equals('secret123'));

      await PreferencesProvider.loadFcmAdminPwd();
      expect(PreferencesProvider.fcmAdminPwdNotifier.value, equals('secret123'));
    });

    test('fcmToken loading and setter', () async {
      await PreferencesProvider.setFcmToken('token_abc_123');
      expect(PreferencesProvider.fcmTokenNotifier.value, equals('token_abc_123'));

      await PreferencesProvider.loadFcmToken();
      expect(PreferencesProvider.fcmTokenNotifier.value, equals('token_abc_123'));
    });

    test('fcmSendTopic loading and setter', () async {
      await PreferencesProvider.setSendTopic('Announcements');
      expect(PreferencesProvider.fcmSendTopicNotifier.value, equals('Announcements'));

      await PreferencesProvider.loadSendTopic();
      expect(PreferencesProvider.fcmSendTopicNotifier.value, equals('Announcements'));
    });

    test('fcmSendTitle loading and setter', () async {
      await PreferencesProvider.setSendTitle('Special Notice');
      expect(PreferencesProvider.fcmSendTitleNotifier.value, equals('Special Notice'));

      await PreferencesProvider.loadSendTitle();
      expect(PreferencesProvider.fcmSendTitleNotifier.value, equals('Special Notice'));
    });

    test('isDayView getter and setter', () async {
      expect(await PreferencesProvider.isDayView, isTrue);

      await PreferencesProvider.setIsDayView(false);
      expect(await PreferencesProvider.isDayView, isFalse);
    });

    test('futureEvents loading and setter', () async {
      await PreferencesProvider.setFutureEvents(true);
      expect(PreferencesProvider.futureEventsNotifier.value, isTrue);

      await PreferencesProvider.loadFutureEvents();
      expect(PreferencesProvider.futureEventsNotifier.value, isTrue);
    });

    test('cachedChecksum and cacheLastUpdated getter and setter', () async {
      expect(await PreferencesProvider.cachedChecksum, equals(''));
      expect(await PreferencesProvider.cacheLastUpdated, isNull);

      const checksum = 'sha256_hash_value';
      final timestamp = DateTime(2026, 10, 21, 12, 0);

      await PreferencesProvider.setCachedChecksum(checksum);
      await PreferencesProvider.setLastUpdated(timestamp);

      expect(await PreferencesProvider.cachedChecksum, equals(checksum));
      expect(await PreferencesProvider.cacheLastUpdated, equals(timestamp));
    });
  });
}
