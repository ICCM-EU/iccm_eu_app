import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/pages/rooms_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoomsPage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders RoomsPage title and room list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, RoomsProvider>(
              create: (context) => RoomsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, rooms) => rooms!..updateCache(),
            ),
          ],
          child: MaterialApp(home: RoomsPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Rooms'), findsOneWidget);
      expect(find.byType(RoomsPage), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
