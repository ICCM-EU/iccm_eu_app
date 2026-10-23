import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventsProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('worksheetTitle returns Sessions', () {
      expect(EventsProvider.worksheetTitle, equals('Sessions'));
    });

    test('showTestDataOption returns bool', () {
      expect(EventsProvider.showTestDataOption(), isA<bool>());
    });

    test('earliestEvent and latestEvent fallback when items are empty', () {
      final gsheets = GsheetsProvider();
      final provider = EventsProvider(gsheetsProvider: gsheets);

      final earliest = provider.earliestEvent();
      expect(earliest.name, equals('---'));

      final latest = provider.latestEvent();
      expect(latest.name, equals('---'));
    });

    test('event filtering methods return empty lists when items are empty', () {
      final gsheets = GsheetsProvider();
      final provider = EventsProvider(gsheetsProvider: gsheets);

      expect(provider.cutoffAfterDays(days: 10), isEmpty);
      expect(provider.filterPastEvents(), isEmpty);
      expect(provider.eventsByRoom(name: 'Room A'), isEmpty);
      expect(provider.eventsByTrack(name: 'Track A'), isEmpty);
      expect(provider.eventsBySpeaker(name: 'Speaker A'), isEmpty);
      expect(provider.currentEvents(), isEmpty);
      expect(provider.nextEvents(), isEmpty);
      expect(provider.nextStartTime(), isNull);
    });
  });
}
