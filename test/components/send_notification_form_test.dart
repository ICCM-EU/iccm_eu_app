import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/send_notification_form.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SendNotificationForm & PreferencesProvider Send Topic/Title Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PreferencesProvider.fcmSendTopicNotifier.value = FcmNotificationsService.defaultTopic;
      PreferencesProvider.fcmSendTitleNotifier.value = 'Conference Announcement';
    });

    test('PreferencesProvider loadSendTopic and loadSendTitle recover values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'fcmSendTopic': 'Test Topic',
        'fcmSendTitle': 'Special Announcement',
      });

      await PreferencesProvider.loadSendTopic();
      await PreferencesProvider.loadSendTitle();

      expect(PreferencesProvider.fcmSendTopicNotifier.value, equals('Test Topic'));
      expect(PreferencesProvider.fcmSendTitleNotifier.value, equals('Special Announcement'));
    });

    test('PreferencesProvider setSendTopic and setSendTitle update notifiers and SharedPreferences', () async {
      await PreferencesProvider.setSendTopic('Test Topic');
      await PreferencesProvider.setSendTitle('Updated Title');

      expect(PreferencesProvider.fcmSendTopicNotifier.value, equals('Test Topic'));
      expect(PreferencesProvider.fcmSendTitleNotifier.value, equals('Updated Title'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fcmSendTopic'), equals('Test Topic'));
      expect(prefs.getString('fcmSendTitle'), equals('Updated Title'));
    });

    testWidgets('SendNotificationForm uses preloaded topic and title from notifiers and updates preferences on change', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'fcmSendTopic': 'Test Topic',
        'fcmSendTitle': 'Preloaded Title',
      });

      await PreferencesProvider.loadSendTopic();
      await PreferencesProvider.loadSendTitle();

      final gsheetsProvider = GsheetsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<GsheetsProvider>.value(value: gsheetsProvider),
                ChangeNotifierProvider<TracksProvider>(
                  create: (_) => TracksProvider(gsheetsProvider: gsheetsProvider),
                ),
              ],
              child: const SendNotificationForm(
                nickname: 'TestUser',
                pwd: 'password123',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title controller has preloaded title
      final titleFinder = find.widgetWithText(TextField, 'Preloaded Title');
      expect(titleFinder, findsOneWidget);

      // Verify selected topic in dropdown is preloaded
      expect(find.text('Test Topic'), findsOneWidget);

      // Change title
      await tester.enterText(titleFinder, 'New Typed Title');
      await tester.pumpAndSettle();

      expect(PreferencesProvider.fcmSendTitleNotifier.value, equals('New Typed Title'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fcmSendTitle'), equals('New Typed Title'));
    });
  });
}
