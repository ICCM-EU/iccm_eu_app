import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/notification_channel_data.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LocalNotificationService.clearInAppNotifications();
    });

    test('addInAppNotification and removeInAppNotification update notifier list', () {
      expect(LocalNotificationService.inAppNotificationsNotifier.value, isEmpty);

      LocalNotificationService.addInAppNotification(
        title: 'Alert',
        body: 'Alert Message',
        backgroundColor: Colors.red,
      );

      final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
      expect(notifications, hasLength(1));
      expect(notifications.first.title, equals('Alert'));
      expect(notifications.first.body, equals('Alert Message'));

      final id = notifications.first.id;
      LocalNotificationService.removeInAppNotification(id);
      expect(LocalNotificationService.inAppNotificationsNotifier.value, isEmpty);
    });

    test('clearInAppNotifications clears all active items', () {
      LocalNotificationService.addInAppNotification(title: 'T1', body: 'B1');
      LocalNotificationService.addInAppNotification(title: 'T2', body: 'B2');
      expect(LocalNotificationService.inAppNotificationsNotifier.value, hasLength(2));

      LocalNotificationService.clearInAppNotifications();
      expect(LocalNotificationService.inAppNotificationsNotifier.value, isEmpty);
    });

    test('scheduleAhead subtracts default 3 minutes from event time', () {
      final eventTime = DateTime(2026, 10, 21, 10, 0);
      final scheduledTime = LocalNotificationService.scheduleAhead(time: eventTime);

      expect(scheduledTime, equals(DateTime(2026, 10, 21, 9, 57)));
    });

    test('showInstantNotification adds in-app notification', () async {
      final channel = NotificationChannelData(
        id: 'test_channel',
        name: 'Test Channel',
        description: 'Testing channel',
      );

      await LocalNotificationService.showInstantNotification(
        id: 1,
        title: 'Instant Title',
        body: 'Instant Body',
        channelData: channel,
      );

      final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
      expect(notifications, isNotEmpty);
      expect(notifications.last.title, equals('Instant Title'));
      expect(notifications.last.body, equals('Instant Body'));
    });

    test('cancelNotification and cancelAllNotifications run without exception', () async {
      await LocalNotificationService.cancelNotification(1, null);
      await LocalNotificationService.cancelAllNotifications();
    });

    test('scheduleNotification with past date does not trigger notification', () async {
      final channel = NotificationChannelData(
        id: 'test_channel',
        name: 'Test Channel',
        description: 'Testing channel',
      );

      await LocalNotificationService.scheduleNotification(
        id: 99,
        title: 'Past Title',
        body: 'Past Body',
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
        channelData: channel,
      );

      final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
      expect(notifications, isEmpty);
    });

    test('scheduleNotification with far future date (>24.8 days) caps timer and does not trigger immediately', () async {
      final channel = NotificationChannelData(
        id: 'test_channel',
        name: 'Test Channel',
        description: 'Testing channel',
      );

      // Schedule 90 days in the future (far exceeding max 32-bit signed int JS timeout of 2,147,483,647 ms)
      await LocalNotificationService.scheduleNotification(
        id: 100,
        title: 'Future Title',
        body: 'Future Body',
        scheduledDate: DateTime.now().add(const Duration(days: 90)),
        channelData: channel,
      );

      final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
      expect(notifications, isEmpty);

      await LocalNotificationService.cancelNotification(100, null);
    });
  });
}
