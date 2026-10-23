import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

void main() {
  group('TrackData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo': 'https://example.com/track.jpg',
        'Name': 'Mobile Development',
        'Description': 'Flutter and Android topics',
      };

      final track = TrackData.fromItemData(itemData);
      expect(track.name, equals('Mobile Development'));
      expect(track.details, equals('Flutter and Android topics'));

      final json = track.toJson();
      expect(json['name'], equals('Mobile Development'));

      final reconstructed = TrackData.fromJson(json);
      expect(reconstructed.name, equals('Mobile Development'));
      expect(reconstructed.details, equals('Flutter and Android topics'));
    });
  });
}
