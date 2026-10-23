import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/web_notification.dart';

void main() {
  group('WebNotification Tests', () {
    test('instantiates and disposes timer', () {
      final futureTime = DateTime.now().add(const Duration(seconds: 10));
      final notification = WebNotification(
        timeout: futureTime,
        title: 'Title',
        msg: 'Message',
      );
      expect(notification.title, equals('Title'));
      expect(notification.msg, equals('Message'));
      notification.dispose();
    });
  });
}
