import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NextEventNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      NextEventNotifier.stopTimer();
    });

    test('startTimer updates nextEventNotifier value and manages timer', () {
      final gsheets = GsheetsProvider();
      final eventsProvider = EventsProvider(gsheetsProvider: gsheets);

      NextEventNotifier.startTimer(eventsProvider);
      expect(NextEventNotifier.nextEventNotifier, isNotNull);

      NextEventNotifier.stopTimer();
    });
  });
}
