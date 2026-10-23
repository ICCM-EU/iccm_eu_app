import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';

void main() {
  group('Theme Configurations Tests', () {
    test('lightTheme is configured with Brightness.light and Material 3', () {
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
    });

    test('darkTheme is configured with Brightness.dark and Material 3', () {
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
    });
  });
}
