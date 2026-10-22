import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/notification_card.dart';
import 'package:iccm_eu_app/data/notifications/in_app_notification_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationCard Tests', () {
    testWidgets('renders NotificationCard with title, body, and close button', (WidgetTester tester) async {
      bool closed = false;
      final notification = InAppNotificationItem(
        id: 'card_1',
        title: 'Alert Title',
        body: 'Alert body text',
        backgroundColor: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notification,
              onClose: () {
                closed = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Alert Title'), findsOneWidget);
      expect(find.text('Alert body text'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closed, isTrue);
    });
  });
}
