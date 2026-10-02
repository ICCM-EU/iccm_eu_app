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
      final result = await FcmNotificationsService.subscribeToTopic('test_topic');
      expect(FcmNotificationsService.token, equals('cached_test_token_123'));
      expect(result, isTrue);
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
  });
}
