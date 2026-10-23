import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';

void main() {
  group('RoomData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo 1': 'https://example.com/room.jpg',
        'Name': 'Auditorium A',
        'Description': 'Main hall',
        'Photo 2': 'https://example.com/map.jpg',
      };

      final room = RoomData.fromItemData(itemData);
      expect(room.name, equals('Auditorium A'));
      expect(room.details, equals('Main hall'));

      final json = room.toJson();
      expect(json['name'], equals('Auditorium A'));

      final reconstructed = RoomData.fromJson(json);
      expect(reconstructed.name, equals('Auditorium A'));
      expect(reconstructed.details, equals('Main hall'));
    });
  });
}
