import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/pages/tracks_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TracksPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders TracksPage title and tracks list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, TracksProvider>(
              create: (context) => TracksProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, tracks) => tracks!..updateCache(),
            ),
          ],
          child: MaterialApp(home: TracksPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Tracks'), findsOneWidget);
      expect(find.byType(TracksPage), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
