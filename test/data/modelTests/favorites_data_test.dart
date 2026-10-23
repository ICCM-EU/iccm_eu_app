import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/favorites_data.dart';

void main() {
  group('FavoritesData Tests', () {
    test('constructor and json serialization/deserialization', () {
      final now = DateTime(2026, 10, 21, 10, 0);
      final favorite = FavoritesData(
        name: 'Opening Keynote',
        start: now,
        details: 'Introductory talk',
      );

      expect(favorite.name, equals('Opening Keynote'));
      expect(favorite.details, equals('Introductory talk'));
      expect(favorite.start, equals(now));

      final json = favorite.toJson();
      expect(json['name'], equals('Opening Keynote'));
      expect(json['details'], equals('Introductory talk'));

      final reconstructed = FavoritesData.fromJson(json);
      expect(reconstructed.name, equals('Opening Keynote'));
      expect(reconstructed.details, equals('Introductory talk'));
      expect(reconstructed.start, equals(now));
    });
  });
}
