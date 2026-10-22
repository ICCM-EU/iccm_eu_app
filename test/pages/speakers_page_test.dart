import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/pages/speakers_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeakersPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders SpeakersPage title and speakers list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, SpeakersProvider>(
              create: (context) => SpeakersProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, speakers) => speakers!..updateCache(),
            ),
          ],
          child: MaterialApp(home: SpeakersPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Speakers'), findsOneWidget);
      expect(find.byType(SpeakersPage), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
