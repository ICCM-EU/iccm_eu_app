import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/pages/events_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventsPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders EventsPage with title and day navigation actions in day view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProvider(create: (_) => ExpandContentProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
              create: (context) => EventsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, events) => events!..updateCache(),
            ),
            ChangeNotifierProxyProvider<GsheetsProvider, RoomsProvider>(
              create: (context) => RoomsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, rooms) => rooms!..updateCache(),
            ),
            ChangeNotifierProxyProvider<GsheetsProvider, TracksProvider>(
              create: (context) => TracksProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, tracks) => tracks!..updateCache(),
            ),
          ],
          child: const MaterialApp(home: EventsPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(EventsPage), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);

      // In Day View, Previous day and Next day buttons should be visible
      expect(find.byTooltip('Previous day'), findsOneWidget);
      expect(find.byTooltip('Next day'), findsOneWidget);

      // Toggle to List View
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // In List View, day navigation buttons should be hidden and filter button shown
      expect(find.byTooltip('Previous day'), findsNothing);
      expect(find.byTooltip('Next day'), findsNothing);
      expect(find.byTooltip('Filter only future events'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
