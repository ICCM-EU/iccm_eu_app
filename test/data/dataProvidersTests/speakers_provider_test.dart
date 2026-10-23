import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeakersProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Speakers', () {
      expect(SpeakersProvider.worksheetTitle, equals('Speakers'));
    });

    test('getDataByName returns null when speaker is not found', () {
      final gsheets = GsheetsProvider();
      final provider = SpeakersProvider(gsheetsProvider: gsheets);
      expect(provider.getDataByName('Nonexistent Speaker'), isNull);
    });
  });
}
