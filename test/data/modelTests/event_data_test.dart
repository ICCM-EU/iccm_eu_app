import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';

void main() {
  group('EventData Tests', () {
    test('constructor and json serialization/deserialization', () {
      final start = DateTime(2026, 10, 21, 9, 0);
      final end = DateTime(2026, 10, 21, 10, 0);

      final event = EventData(
        name: 'Opening Keynote',
        details: 'Keynote presentation',
        start: start,
        end: end,
        room: 'Auditorium A',
        track: 'General',
        speaker: 'John Doe',
        forceNotify: true,
        id: 42,
      );

      expect(event.name, equals('Opening Keynote'));
      expect(event.details, equals('Keynote presentation'));
      expect(event.room, equals('Auditorium A'));
      expect(event.id, equals(42));

      final json = event.toJson();
      expect(json['name'], equals('Opening Keynote'));
      expect(json['id'], equals('42'));

      final reconstructed = EventData.fromJson(json);
      expect(reconstructed.name, equals('Opening Keynote'));
      expect(reconstructed.details, equals('Keynote presentation'));
      expect(reconstructed.room, equals('Auditorium A'));
      expect(reconstructed.id, equals(42));
    });
  });
}
