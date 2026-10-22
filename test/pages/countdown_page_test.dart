import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/pages/countdown_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CountdownPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders CountdownPage with dropdown and timer view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProvider(create: (_) => ExpandContentProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, RoomsProvider>(
              create: (context) => RoomsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, rooms) => rooms!..updateCache(),
            ),
            ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
              create: (context) => EventsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, events) => events!..updateCache(),
            ),
          ],
          child: const MaterialApp(home: CountdownPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(CountdownPage), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
