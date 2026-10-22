import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/controls/show_overlay_message.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showOverlayMessage Tests', () {
    testWidgets('adds in-app notification to LocalNotificationService', (WidgetTester tester) async {
      LocalNotificationService.clearInAppNotifications();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showOverlayMessage(context, 'Test overlay message', backgroundColor: Colors.green);
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Show'));
      await tester.pump();

      final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
      expect(notifications, isNotEmpty);
      expect(notifications.first.body, equals('Test overlay message'));
      expect(notifications.first.backgroundColor, equals(Colors.green));

      LocalNotificationService.clearInAppNotifications();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
