import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/event_list.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventList Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders EventList with futureEvents true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProvider(create: (_) => FavoritesProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
              create: (context) => EventsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, events) => events!..updateCache(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EventList(futureEvents: true),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(EventList), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
