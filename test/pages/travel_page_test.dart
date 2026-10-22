import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:iccm_eu_app/pages/travel_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TravelPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders TravelPage with CustomScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, TravelProvider>(
              create: (context) => TravelProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, travel) => travel!..updateCache(),
            ),
            ChangeNotifierProxyProvider<GsheetsProvider, TravelDetailsProvider>(
              create: (context) => TravelDetailsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, details) => details!..updateCache(),
            ),
          ],
          child: const MaterialApp(home: TravelPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(TravelPage), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
