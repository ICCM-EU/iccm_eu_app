import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TravelProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Travel', () {
      expect(TravelProvider.worksheetTitle, equals('Travel'));
    });

    test('initial items list is empty', () {
      final gsheets = GsheetsProvider();
      final provider = TravelProvider(gsheetsProvider: gsheets);
      expect(provider.items(), isEmpty);
    });
  });
}
