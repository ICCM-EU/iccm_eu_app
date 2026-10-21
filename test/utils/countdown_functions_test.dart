import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/countdown_functions.dart';

void main() {
  group('CountdownFunctions.colors Tests', () {
    test('contains expected number of color palettes', () {
      expect(CountdownFunctions.colors, isNotEmpty);
      expect(CountdownFunctions.colors.length, equals(6));
    });

    test('all palette entries have non-null primary and secondary colors', () {
      for (var palette in CountdownFunctions.colors) {
        expect(palette.primary, isNotNull);
        expect(palette.secondary, isNotNull);
      }
    });

    test('contains correct primary and secondary colors at specific indices', () {
      expect(CountdownFunctions.colors[0].primary, equals(Colors.red.shade900));
      expect(CountdownFunctions.colors[0].secondary, equals(Colors.white));

      expect(CountdownFunctions.colors[1].primary, equals(Colors.red.shade600));
      expect(CountdownFunctions.colors[1].secondary, equals(Colors.black));

      expect(CountdownFunctions.colors[2].primary, equals(Colors.deepOrange.shade300));
      expect(CountdownFunctions.colors[2].secondary, equals(Colors.black));

      expect(CountdownFunctions.colors[3].primary, equals(Colors.yellow.shade700));
      expect(CountdownFunctions.colors[3].secondary, equals(Colors.black));

      expect(CountdownFunctions.colors[4].primary, equals(Colors.green.shade900));
      expect(CountdownFunctions.colors[4].secondary, equals(Colors.white));

      expect(CountdownFunctions.colors[5].primary, equals(Colors.grey.shade900));
      expect(CountdownFunctions.colors[5].secondary, equals(Colors.white));
    });
  });
}
