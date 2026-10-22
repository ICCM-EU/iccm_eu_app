import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial themeMode defaults based on preferences', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.themeMode, isA<ThemeMode>());
    });

    test('saveTheme updates themeMode and notifies listeners', () async {
      final provider = ThemeProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      await provider.saveTheme(true);

      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(notified, isTrue);

      await provider.saveTheme(false);
      expect(provider.themeMode, equals(ThemeMode.light));
    });
  });
}
