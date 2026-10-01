import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  test('GsheetsProvider fetches data from Google Apps Script', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GsheetsProvider();
    await provider.fetchData(force: true);
    final eventData = provider.getEventData();
    expect(eventData, isNotNull);
    expect(eventData!.isNotEmpty, isTrue);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
