import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/components/toggle_is_dark_mode.dart';
import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ToggleIsDarkModeListTile Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'isDarkTheme': false});
    });

    testWidgets('renders Dark Mode toggle switch and updates ThemeProvider', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<ThemeProvider>(
                builder: (context, theme, child) => ToggleIsDarkModeListTile(context: context),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(themeProvider.themeMode, equals(ThemeMode.dark));
    });
  });
}
