import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/travel_data.dart';

void main() {
  group('TravelData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo 1': 'https://example.com/venue.jpg',
        'Title': 'Venue Location',
        'Location': 'Main Street 100',
        'Website': 'https://example.com/venue',
        'Google Maps': 'https://maps.example.com',
      };

      final travel = TravelData.fromItemData(itemData);
      expect(travel.name, equals('Venue Location'));
      expect(travel.details, equals('Main Street 100'));
      expect(travel.locationUrl, equals('https://example.com/venue'));
      expect(travel.mapsUrl, equals('https://maps.example.com'));

      final json = travel.toJson();
      expect(json['name'], equals('Venue Location'));

      final reconstructed = TravelData.fromJson(json);
      expect(reconstructed.name, equals('Venue Location'));
      expect(reconstructed.details, equals('Main Street 100'));
    });
  });
}
