import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:iccm_eu_app/pages/track_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackDetailsPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders TrackDetailsPage with track name and details', (WidgetTester tester) async {
      final sampleTrack = TrackData(
        name: 'DevOps Track',
        details: 'Sessions focusing on CI/CD and deployment automation.',
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
          child: MaterialApp(home: TrackDetailsPage(item: sampleTrack)),
        ),
      );
      await tester.pump();

      expect(find.text('Track Details'), findsOneWidget);
      expect(find.text('DevOps Track'), findsOneWidget);
      expect(find.text('Sessions focusing on CI/CD and deployment automation.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
