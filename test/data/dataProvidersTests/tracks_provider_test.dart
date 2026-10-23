import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TracksProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Category', () {
      expect(TracksProvider.worksheetTitle, equals('Category'));
    });

    test('getDataByName returns null when track is not found', () {
      final gsheets = GsheetsProvider();
      final provider = TracksProvider(gsheetsProvider: gsheets);
      expect(provider.getDataByName('Nonexistent Track'), isNull);
    });
  });
}
