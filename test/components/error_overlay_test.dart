import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/error_overlay.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorOverlay Tests', () {
    testWidgets('renders ErrorOverlay when notification exists', (WidgetTester tester) async {
      LocalNotificationService.clearInAppNotifications();
      LocalNotificationService.addInAppNotification(
        title: 'Network Error',
        body: 'Failed to sync with server',
        backgroundColor: Colors.red,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ErrorProvider(),
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  ErrorOverlay(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Failed to sync with server'), findsOneWidget);

      LocalNotificationService.clearInAppNotifications();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
