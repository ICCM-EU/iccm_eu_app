import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/notification_permission_overlay.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationPermissionOverlay Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PreferencesProvider.notificationTopicsNotifier.value = [];
    });

    Future<void> pumpOverlay(WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                NotificationPermissionOverlay(),
              ],
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
    }

    testWidgets('Overlay is shown when inhibitNotifications is false and permission is not granted', (WidgetTester tester) async {
      await pumpOverlay(tester);

      expect(find.text('Receive Announcement Notifications?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Overlay is NOT shown when inhibitNotifications is true', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'inhibitNotifications': true});

      await pumpOverlay(tester);

      expect(find.text('Receive Announcement Notifications?'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Tapping No sets inhibitNotifications to true and hides overlay', (WidgetTester tester) async {
      await pumpOverlay(tester);

      expect(find.text('Receive Announcement Notifications?'), findsOneWidget);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('Receive Announcement Notifications?'), findsNothing);
      expect(await PreferencesProvider.inhibitNotifications, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Tapping Cancel leaves inhibitNotifications false and hides overlay', (WidgetTester tester) async {
      await pumpOverlay(tester);

      expect(find.text('Receive Announcement Notifications?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Receive Announcement Notifications?'), findsNothing);
      expect(await PreferencesProvider.inhibitNotifications, isFalse);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Tapping Yes hides overlay and subscribes to default topic with userGesture', (WidgetTester tester) async {
      await pumpOverlay(tester);

      expect(find.text('Receive Announcement Notifications?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('Receive Announcement Notifications?'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
