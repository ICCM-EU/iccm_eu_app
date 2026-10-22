import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/pages/room_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoomDetailsPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders RoomDetailsPage with room name and details', (WidgetTester tester) async {
      final sampleRoom = RoomData(
        name: 'Main Hall',
        details: 'The primary auditorium for keynotes.',
        imageUrl: '',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PageIndexProvider()),
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
              create: (context) => EventsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, events) => events!..updateCache(),
            ),
          ],
          child: MaterialApp(home: RoomDetailsPage(item: sampleRoom)),
        ),
      );
      await tester.pump();

      expect(find.text('Room Details'), findsOneWidget);
      expect(find.text('Main Hall'), findsOneWidget);
      expect(find.text('The primary auditorium for keynotes.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
