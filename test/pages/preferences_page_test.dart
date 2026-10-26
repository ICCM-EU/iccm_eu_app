import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/full_screen_qr_code.dart';
import 'package:iccm_eu_app/components/qr_scanner.dart';
import 'package:iccm_eu_app/components/toggle_button.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:iccm_eu_app/pages/preferences_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GsheetsProvider()),
        ChangeNotifierProxyProvider<GsheetsProvider, TracksProvider>(
          create: (context) => TracksProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheets, tracks) => tracks!..updateCache(),
        ),
        ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
          create: (context) => EventsProvider(
            gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
          ),
          update: (context, gsheets, events) => events!..updateCache(),
        ),
      ],
      child: const MaterialApp(home: PreferencesPage()),
    );
  }

  group('PreferencesPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PreferencesProvider.setNotificationsNickname('');
      PreferencesProvider.setFcmAdminPwd('');
    });

    testWidgets('renders PreferencesPage with Theme and Calendar options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(PreferencesPage), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows FCM Admin Password field when nickname is set', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Initially nickname is empty, password field not shown
      expect(find.widgetWithText(TextField, 'FCM Admin Password'), findsNothing);

      // Enter nickname
      final nicknameFinder = find.widgetWithText(TextField, 'Notification Nickname');
      await tester.ensureVisible(nicknameFinder);
      await tester.enterText(
        nicknameFinder,
        'AdminUser',
      );
      await tester.pumpAndSettle();

      // Now FCM Admin Password field is shown
      expect(find.widgetWithText(TextField, 'FCM Admin Password'), findsOneWidget);

      // Scan QR button is visible when field is shown (password is empty)
      expect(find.byKey(const Key('scan_fcm_pwd_qr_button')), findsOneWidget);

      // Share QR button is NOT visible when password is empty
      expect(find.byKey(const Key('share_fcm_pwd_qr_button')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows share QR button when password is non-empty and opens FullScreenQrCode without text', (WidgetTester tester) async {
      PreferencesProvider.setNotificationsNickname('AdminUser');
      PreferencesProvider.setFcmAdminPwd('my_secret_pwd_123');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Both share and scan buttons should be visible
      expect(find.byKey(const Key('share_fcm_pwd_qr_button')), findsOneWidget);
      expect(find.byKey(const Key('scan_fcm_pwd_qr_button')), findsOneWidget);

      // Scroll to share button and tap
      final shareButtonFinder = find.byKey(const Key('share_fcm_pwd_qr_button'));
      await tester.ensureVisible(shareButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(shareButtonFinder);
      await tester.pumpAndSettle();

      // Should open FullScreenQrCode
      expect(find.byType(FullScreenQrCode), findsOneWidget);
      expect(find.text('FCM Admin Password'), findsOneWidget);

      // Human-readable password text should NOT be shown
      expect(find.text('my_secret_pwd_123'), findsNothing);

      // Close full screen QR code
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(PreferencesPage), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('taps scan QR button and opens QrScannerPage', (WidgetTester tester) async {
      PreferencesProvider.setNotificationsNickname('AdminUser');
      PreferencesProvider.setFcmAdminPwd('');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final scanButtonFinder = find.byKey(const Key('scan_fcm_pwd_qr_button'));
      expect(scanButtonFinder, findsOneWidget);

      // Scroll to scan button and tap
      await tester.ensureVisible(scanButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(scanButtonFinder);
      await tester.pumpAndSettle();

      // QrScanner is pushed
      expect(find.byType(QrScanner), findsOneWidget);

      // Simulate QR scanner returning a value
      tester.state<NavigatorState>(find.byType(Navigator)).pop('scanned_pwd_789');
      await tester.pumpAndSettle();

      // Verify password was updated in PreferencesProvider and TextField
      expect(PreferencesProvider.fcmAdminPwdNotifier.value, 'scanned_pwd_789');
      expect(find.byKey(const Key('share_fcm_pwd_qr_button')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Topic Subscription Button Inactive & Fallback Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PreferencesProvider.notificationTopicsNotifier.value = [];
      FcmNotificationsService.subscribeToTopicHandler = null;
      FcmNotificationsService.unsubscribeFromTopicHandler = null;
    });

    tearDown(() {
      FcmNotificationsService.subscribeToTopicHandler = null;
      FcmNotificationsService.unsubscribeFromTopicHandler = null;
    });

    testWidgets('topic selection button becomes inactive while waiting for backend reply and reactivates with new status on success', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        Completer<bool>? completer;
        FcmNotificationsService.subscribeToTopicHandler = (topic, {required userGesture}) {
          completer = Completer<bool>();
          return completer!.future;
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final tileFinder = find.widgetWithText(ToggleButtonListTile, 'Announcements');
        expect(tileFinder, findsOneWidget);

        ToggleButtonListTile tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull);
        expect(tile.value, isFalse);

        // Tap to subscribe
        await tester.tap(tileFinder);
        await tester.pump(); // Render frame while backend call is pending

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNull); // Button is inactive while waiting for reply

        // Attempt second tap while inactive
        await tester.tap(tileFinder);
        await tester.pump();

        // Complete backend call with SUCCESS
        completer!.complete(true);
        await tester.pumpAndSettle();

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull); // Button is reactivated
        expect(tile.value, isTrue); // Activated status updated to true
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('topic selection button falls back to original status and reactivates if server call fails', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        Completer<bool>? completer;
        FcmNotificationsService.subscribeToTopicHandler = (topic, {required userGesture}) {
          completer = Completer<bool>();
          return completer!.future;
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final tileFinder = find.widgetWithText(ToggleButtonListTile, 'Announcements');
        expect(tileFinder, findsOneWidget);

        ToggleButtonListTile tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull);
        expect(tile.value, isFalse);

        // Tap switch to subscribe
        await tester.tap(tileFinder);
        await tester.pump(); // Render frame while backend call is pending

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNull); // Inactive while waiting for reply

        // Complete backend call with FAILURE (server not available)
        completer!.complete(false);
        await tester.pumpAndSettle();

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull); // Returns to activated status
        expect(tile.value, isFalse); // Falls back to original status (unsubscribed / false)
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('topic selection button becomes inactive when unsubscribing and falls back to original status if server fails', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        SharedPreferences.setMockInitialValues({
          'notificationsTopics': 'announcements',
        });
        Completer<bool>? completer;
        FcmNotificationsService.unsubscribeFromTopicHandler = (topic, {required userGesture}) {
          completer = Completer<bool>();
          return completer!.future;
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final tileFinder = find.widgetWithText(ToggleButtonListTile, 'Announcements');
        expect(tileFinder, findsOneWidget);

        ToggleButtonListTile tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull);
        expect(tile.value, isTrue);

        // Tap switch to unsubscribe
        await tester.tap(tileFinder);
        await tester.pump(); // Frame while backend call is pending

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNull); // Inactive while waiting for reply

        // Complete backend call with FAILURE (server not available)
        completer!.complete(false);
        await tester.pumpAndSettle();

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull); // Returns to activated status
        expect(tile.value, isTrue); // Falls back to original status (subscribed / true)
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('topic selection button becomes inactive when unsubscribing and updates to OFF on success', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        SharedPreferences.setMockInitialValues({
          'notificationsTopics': 'announcements',
        });
        Completer<bool>? completer;
        FcmNotificationsService.unsubscribeFromTopicHandler = (topic, {required userGesture}) {
          completer = Completer<bool>();
          return completer!.future;
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final tileFinder = find.widgetWithText(ToggleButtonListTile, 'Announcements');
        expect(tileFinder, findsOneWidget);

        ToggleButtonListTile tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull);
        expect(tile.value, isTrue);

        // Tap switch to unsubscribe
        await tester.tap(tileFinder);
        await tester.pump(); // Frame while backend call is pending

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNull); // Inactive while waiting for reply

        // Complete backend call with SUCCESS
        completer!.complete(true);
        await tester.pumpAndSettle();

        tile = tester.widget<ToggleButtonListTile>(tileFinder);
        expect(tile.onChanged, isNotNull); // Returns to activated status
        expect(tile.value, isFalse); // Status updated to unsubscribed / false
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
