import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/app_bar_countdown.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppBarCountdown Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders AppBarCountdown widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GsheetsProvider()),
            ChangeNotifierProxyProvider<GsheetsProvider, EventsProvider>(
              create: (context) => EventsProvider(
                gsheetsProvider: Provider.of<GsheetsProvider>(context, listen: false),
              ),
              update: (context, gsheets, events) => events!..updateCache(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: AppBarCountdown(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppBarCountdown), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
