import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
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

    test('event filtering methods with populated items list', () {
      final gsheets = GsheetsProvider();
      final provider = EventsProvider(gsheetsProvider: gsheets);

      final now = DateTime.now();
      final pastEvent = EventData(
        name: 'Past Keynote',
        details: 'Past details',
        start: now.subtract(const Duration(hours: 3)),
        end: now.subtract(const Duration(hours: 2)),
        room: 'Auditorium A',
        track: 'General',
        speaker: 'Alice',
      );
      final currentEvent = EventData(
        name: 'Live Session',
        details: 'Current details',
        start: now.subtract(const Duration(minutes: 15)),
        end: now.add(const Duration(minutes: 45)),
        room: 'Auditorium A',
        track: 'Mobile',
        speaker: 'Bob',
        parallelSessions: 'Parallel 1',
      );
      final parallelEvent = EventData(
        name: 'Parallel Session',
        details: 'Parallel details',
        start: now.subtract(const Duration(minutes: 15)),
        end: now.add(const Duration(minutes: 45)),
        room: 'Room B',
        track: 'Cloud',
        speaker: 'Charlie',
        parallelSessions: 'Parallel 1',
      );
      final futureEvent = EventData(
        name: 'Future Workshop',
        details: 'Future details',
        start: now.add(const Duration(hours: 2)),
        end: now.add(const Duration(hours: 4)),
        room: 'Room C',
        track: 'Mobile',
        speaker: 'Alice',
      );

      final items = [pastEvent, currentEvent, parallelEvent, futureEvent];

      expect(provider.earliestEvent(items: items), equals(pastEvent));
      expect(provider.latestEvent(items: items), equals(futureEvent));

      final roomA = provider.eventsByRoom(items: items, name: 'Auditorium A');
      expect(roomA, hasLength(2));
      expect(roomA, contains(pastEvent));
      expect(roomA, contains(currentEvent));

      final mobileTrack = provider.eventsByTrack(items: items, name: 'Mobile');
      expect(mobileTrack, hasLength(2));
      expect(mobileTrack, contains(currentEvent));
      expect(mobileTrack, contains(futureEvent));

      final aliceEvents = provider.eventsBySpeaker(items: items, name: 'Alice');
      expect(aliceEvents, hasLength(2));

      final parallelList = provider.eventsByParallel(
        current: currentEvent,
        items: items,
        parallel: 'Parallel 1',
      );
      expect(parallelList, hasLength(1));
      expect(parallelList.first, equals(parallelEvent));

      final futureFiltered = provider.filterPastEvents(items: items, withCurrent: true);
      expect(futureFiltered, contains(currentEvent));
      expect(futureFiltered, contains(parallelEvent));
      expect(futureFiltered, contains(futureEvent));
      expect(futureFiltered, isNot(contains(pastEvent)));
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
