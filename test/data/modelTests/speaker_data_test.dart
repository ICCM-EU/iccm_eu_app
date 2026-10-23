import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

void main() {
  group('SpeakerData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo': 'https://example.com/speaker.jpg',
        'Name': 'Jane Smith',
        'Bio': 'Software Engineer',
        'Company': 'Tech Org',
        'Weblink': 'https://janesmith.dev',
      };

      final speaker = SpeakerData.fromItemData(itemData);
      expect(speaker.name, equals('Jane Smith'));
      expect(speaker.details, equals('Software Engineer'));
      expect(speaker.company, equals('Tech Org'));

      final json = speaker.toJson();
      expect(json['name'], equals('Jane Smith'));

      final reconstructed = SpeakerData.fromJson(json);
      expect(reconstructed.name, equals('Jane Smith'));
      expect(reconstructed.details, equals('Software Engineer'));
    });
  });
}
