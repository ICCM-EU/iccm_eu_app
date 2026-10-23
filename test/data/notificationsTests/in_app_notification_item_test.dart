import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/notifications/in_app_notification_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InAppNotificationItem Tests', () {
    test('initialization sets fields correctly', () {
      final now = DateTime.now();
      final item = InAppNotificationItem(
        id: 'test_id_1',
        title: 'Test Title',
        body: 'Test Body',
        backgroundColor: Colors.blue,
        createdAt: now,
      );

      expect(item.id, equals('test_id_1'));
      expect(item.title, equals('Test Title'));
      expect(item.body, equals('Test Body'));
      expect(item.backgroundColor, equals(Colors.blue));
      expect(item.createdAt, equals(now));
    });

    test('startTimer and dispose manage timer safely', () {
      bool timedOut = false;
      final item = InAppNotificationItem(
        id: 'test_id_2',
        title: 'Title',
        body: 'Body',
      );

      item.startTimer(() {
        timedOut = true;
      });

      item.dispose();
      expect(timedOut, isFalse);
    });
  });
}
