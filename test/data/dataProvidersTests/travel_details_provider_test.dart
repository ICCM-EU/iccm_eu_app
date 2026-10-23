import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TravelDetailsProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Travel-Directions', () {
      expect(TravelDetailsProvider.worksheetTitle, equals('Travel-Directions'));
    });

    test('initial items list is empty', () {
      final gsheets = GsheetsProvider();
      final provider = TravelDetailsProvider(gsheetsProvider: gsheets);
      expect(provider.items(), isEmpty);
    });
  });
}
