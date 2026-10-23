import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Home', () {
      expect(HomeProvider.worksheetTitle, equals('Home'));
    });

    test('initial items list is empty', () {
      final gsheets = GsheetsProvider();
      final provider = HomeProvider(gsheetsProvider: gsheets);
      expect(provider.items(), isEmpty);
    });
  });
}
