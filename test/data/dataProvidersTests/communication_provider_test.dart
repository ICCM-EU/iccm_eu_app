import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommunicationProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Communication', () {
      expect(CommunicationProvider.worksheetTitle, equals('Communication'));
    });

    test('initial items list is empty', () {
      final gsheets = GsheetsProvider();
      final provider = CommunicationProvider(gsheetsProvider: gsheets);
      expect(provider.items(), isEmpty);
    });
  });
}
