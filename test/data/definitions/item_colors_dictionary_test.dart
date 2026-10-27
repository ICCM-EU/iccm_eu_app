import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/definitions/item_colors_dictionary.dart';

void main() {
  group('ItemColorsDictionary Tests', () {
    test('contains modern non-null color palette entries', () {
      final dictionary = ItemColorsDictionary();
      expect(dictionary.colors, isNotEmpty);

      // Verify standard required keys are present
      expect(dictionary.colors.containsKey('red'), isTrue);
      expect(dictionary.colors.containsKey('blue'), isTrue);
      expect(dictionary.colors.containsKey('green'), isTrue);
      expect(dictionary.colors.containsKey('yellow'), isTrue);
      expect(dictionary.colors.containsKey('orange'), isTrue);
      expect(dictionary.colors.containsKey('purple'), isTrue);
      expect(dictionary.colors.containsKey('grey'), isTrue);
      expect(dictionary.colors.containsKey('whine'), isTrue);
      expect(dictionary.colors.containsKey('wine'), isTrue);
      expect(dictionary.colors.containsKey('teal'), isTrue);

      // Verify each entry has non-null primary and secondary colors with contrast
      for (final entry in dictionary.colors.entries) {
        final colors = entry.value;
        expect(colors.primary, isNotNull, reason: 'Key ${entry.key} primary color is null');
        expect(colors.secondary, isNotNull, reason: 'Key ${entry.key} secondary color is null');
        expect(colors.primary, isNot(equals(colors.secondary)),
            reason: 'Key ${entry.key} primary and secondary colors should not be identical');
      }
    });
  });
}
