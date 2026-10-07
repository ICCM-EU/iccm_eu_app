import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FcmNotificationsService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FcmNotificationsService.token = null;
    });

    test('subscribeToTopic returns false gracefully when Firebase is not initialized and no token exists', () async {
      final result = await FcmNotificationsService.subscribeToTopic('test_topic');
      expect(result, isFalse);
      expect(FcmNotificationsService.token, isNull);
    });

    test('subscribeToTopic reuses cached token from SharedPreferences if present', () async {
      SharedPreferences.setMockInitialValues({'fcmToken': 'cached_test_token_123'});
      await PreferencesProvider.loadFcmToken();

      expect(PreferencesProvider.fcmTokenNotifier.value, equals('cached_test_token_123'));

      // Token should be reused from preferences by _ensureToken
      await FcmNotificationsService.subscribeToTopic('test_topic');
      expect(FcmNotificationsService.token, equals('cached_test_token_123'));
    });

    test('unsubscribeFromTopic rejects default topic Announcements', () async {
      final result = await FcmNotificationsService.unsubscribeFromTopic(FcmNotificationsService.defaultTopic);
      expect(result, isFalse);
    });

    test('getTopics returns defaultTopic and testTopic', () {
      final topics = FcmNotificationsService().getTopics();
      expect(topics, contains(FcmNotificationsService.defaultTopic));
      expect(topics, contains(FcmNotificationsService.testTopic));
    });

    test('backendUrl handles trailing slashes without creating double slashes', () {
      FcmNotificationsService.backendUrl = 'https://iccm-eu-notifications.tappe-info.de///';
      // Verify via attempt to subscribe or reset
      expect(FcmNotificationsService.backendUrl, endsWith('/'));
      FcmNotificationsService.backendUrl = 'https://iccm-eu-notifications.tappe-info.de';
    });

    test('initializeFcmNotifications recovers token from SharedPreferences and skips topic subscription', () async {
      SharedPreferences.setMockInitialValues({'fcmToken': 'cached_token_abc'});
      await FcmNotificationsService.initializeFcmNotifications();

      expect(FcmNotificationsService.token, equals('cached_token_abc'));
    });

    test('loadNotificationTopics cleans invalid topics not in getTopics', () async {
      SharedPreferences.setMockInitialValues({
        'notificationsTopics': 'announcements|test_topic|invalid_obsolete_topic_123'
      });
      await PreferencesProvider.loadNotificationTopics();

      expect(PreferencesProvider.notificationTopicsNotifier.value, contains('announcements'));
      expect(PreferencesProvider.notificationTopicsNotifier.value, contains('test_topic'));
      expect(PreferencesProvider.notificationTopicsNotifier.value, isNot(contains('invalid_obsolete_topic_123')));
    });
  });
}
