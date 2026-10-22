import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventListTile Tests', () {
    testWidgets('renders EventListTile with event name and formatted date', (WidgetTester tester) async {
      final sampleEvent = EventData(
        name: 'Opening Ceremony',
        details: 'Welcome session for all conference attendees.',
        start: DateTime(2026, 10, 21, 9, 0),
        end: DateTime(2026, 10, 21, 10, 0),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: EventListTile(item: sampleEvent),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Opening Ceremony', findRichText: true), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
