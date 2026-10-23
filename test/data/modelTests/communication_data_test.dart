import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/communication_data.dart';

void main() {
  group('CommunicationData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Leading': '🌐',
        'Title': 'Website',
        'URL': 'https://iccm-europe.org',
      };

      final data = CommunicationData.fromItemData(itemData);
      expect(data.leading, equals('🌐'));
      expect(data.title, equals('Website'));
      expect(data.url, equals('https://iccm-europe.org'));

      final json = data.toJson();
      expect(json['title'], equals('Website'));

      final reconstructed = CommunicationData.fromJson(json);
      expect(reconstructed.leading, equals('🌐'));
      expect(reconstructed.title, equals('Website'));
      expect(reconstructed.url, equals('https://iccm-europe.org'));
    });
  });
}
