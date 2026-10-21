import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/id_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('IdGenerator.generateItemId Tests', () {
    test('generates sequential item IDs when preferences start empty', () async {
      SharedPreferences.setMockInitialValues({});

      final id1 = await IdGenerator.generateItemId();
      final id2 = await IdGenerator.generateItemId();
      final id3 = await IdGenerator.generateItemId();

      expect(id1, equals(1));
      expect(id2, equals(2));
      expect(id3, equals(3));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('notification_ids'), equals(['1', '2', '3']));
    });

    test('skips existing IDs stored in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'notification_ids': ['1', '2', '4'],
      });

      final nextId = await IdGenerator.generateItemId();
      expect(nextId, greaterThan(0));

      final prefs = await SharedPreferences.getInstance();
      final storedIds = prefs.getStringList('notification_ids') ?? [];
      expect(storedIds, contains(nextId.toString()));
    });

    test('handles invalid string entries in SharedPreferences without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'notification_ids': ['invalid', 'abc', '10'],
      });

      final nextId = await IdGenerator.generateItemId();
      expect(nextId, isA<int>());
      expect(nextId, greaterThan(0));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('notification_ids'), isNotNull);
    });
  });
}
