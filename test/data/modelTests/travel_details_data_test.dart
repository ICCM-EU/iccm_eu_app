import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/travel_details_data.dart';

void main() {
  group('TravelDetailsData Tests', () {
    test('fromItemData, json serialization and deserialization', () {
      final itemData = {
        'Photo': 'https://example.com/train.jpg',
        'Name': 'By Train',
        'Description': 'Take express train S1',
        'Emoji': '🚆',
      };

      final travelDetails = TravelDetailsData.fromItemData(itemData);
      expect(travelDetails.name, equals('By Train'));
      expect(travelDetails.details, equals('Take express train S1'));
      expect(travelDetails.emoji, equals('🚆'));

      final json = travelDetails.toJson();
      expect(json['name'], equals('By Train'));

      final reconstructed = TravelDetailsData.fromJson(json);
      expect(reconstructed.name, equals('By Train'));
      expect(reconstructed.details, equals('Take express train S1'));
      expect(reconstructed.emoji, equals('🚆'));
    });
  });
}
