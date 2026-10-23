import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/favorites_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('adds and removes event from favorites', () async {
      final provider = FavoritesProvider();
      final start1 = DateTime(2026, 10, 21, 10, 0);
      final start2 = DateTime(2026, 10, 21, 11, 0);

      final event1 = EventData(
        name: 'Keynote 1',
        details: 'Keynote 1 details',
        start: start1,
        end: start1.add(const Duration(hours: 1)),
      );
      final event2 = EventData(
        name: 'Keynote 2',
        details: 'Keynote 2 details',
        start: start2,
        end: start2.add(const Duration(hours: 1)),
      );

      expect(provider.isInFavorites(name: 'Keynote 1', start: start1), isFalse);

      provider.addEvent(
        name: 'Keynote 1',
        start: start1,
        details: 'Keynote 1 details',
        currentEvents: [event1, event2],
      );
      provider.addEvent(
        name: 'Keynote 2',
        start: start2,
        details: 'Keynote 2 details',
        currentEvents: [event1, event2],
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isInFavorites(name: 'Keynote 1', start: start1), isTrue);
      expect(provider.isInFavorites(name: 'Keynote 2', start: start2), isTrue);

      provider.rmEvent(
        name: 'Keynote 1',
        start: start1,
        currentEvents: [event1, event2],
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isInFavorites(name: 'Keynote 1', start: start1), isFalse);
      expect(provider.isInFavorites(name: 'Keynote 2', start: start2), isTrue);
    });
  });
}
