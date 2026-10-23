import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoomsProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Venue', () {
      expect(RoomsProvider.worksheetTitle, equals('Venue'));
    });

    test('getDataByName returns null when room is not found', () {
      final gsheets = GsheetsProvider();
      final provider = RoomsProvider(gsheetsProvider: gsheets);
      expect(provider.getDataByName('Nonexistent Room'), isNull);
    });
  });
}
