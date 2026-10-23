import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/home_data.dart';

void main() {
  group('HomeData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo 1': 'https://example.com/photo.jpg',
        'Title': 'Welcome to ICCM',
        'Description': 'Main conference page',
        'Now Page Link': 'https://example.com/now',
        'Survey Link': 'https://example.com/survey',
        'BOF Page Link': 'https://example.com/bof',
        'App Share Link': 'https://example.com/share',
        'App Dev Link': 'https://example.com/dev',
      };

      final homeData = HomeData.fromItemData(itemData);
      expect(homeData.name, equals('Welcome to ICCM'));
      expect(homeData.details, equals('Main conference page'));

      final json = homeData.toJson();
      expect(json['name'], equals('Welcome to ICCM'));

      final reconstructed = HomeData.fromJson(json);
      expect(reconstructed.name, equals('Welcome to ICCM'));
      expect(reconstructed.details, equals('Main conference page'));
    });
  });
}
