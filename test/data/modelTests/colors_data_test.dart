import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/colors_data.dart';

void main() {
  group('ColorsData Tests', () {
    test('instantiates with primary and secondary colors', () {
      final colors = ColorsData(primary: Colors.blue, secondary: Colors.yellow);
      expect(colors.primary, equals(Colors.blue));
      expect(colors.secondary, equals(Colors.yellow));
    });
  });
}
