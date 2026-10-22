import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/event_day_view_calendar.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventDayViewCalendar Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders EventDayViewCalendar widget', (WidgetTester tester) async {
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
          child: const MaterialApp(
            home: Scaffold(
              body: EventDayViewCalendar(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(EventDayViewCalendar), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
