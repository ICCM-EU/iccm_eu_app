import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';

void main() {
  group('DateFunctions.formatDate Tests', () {
    test('formats DateTime with standard date patterns', () {
      final date = DateTime(2026, 10, 21, 14, 30, 45);
      expect(DateFunctions.formatDate(date: date, format: 'yyyy-MM-dd'), equals('2026-10-21'));
      expect(DateFunctions.formatDate(date: date, format: 'HH:mm:ss'), equals('14:30:45'));
      expect(DateFunctions.formatDate(date: date, format: 'yyyy/MM/dd HH:mm'), equals('2026/10/21 14:30'));
    });

    test('formats DateTime with custom day and month representations', () {
      final date = DateTime(2026, 10, 5, 8, 9, 3);
      expect(DateFunctions.formatDate(date: date, format: 'd/M/yy H:m:s'), equals('5/10/26 8:9:3'));
      expect(DateFunctions.formatDate(date: date, format: 'EEEE, MMMM d, yyyy'), equals('Monday, October 5, 2026'));
    });

    test('formats DateTime for leap years and month/year boundaries', () {
      final leapDate = DateTime(2024, 2, 29, 9, 5);
      expect(DateFunctions.formatDate(date: leapDate, format: 'yyyy-MM-dd HH:mm'), equals('2024-02-29 09:05'));

      final newYear = DateTime(2025, 1, 1, 0, 0, 0);
      expect(DateFunctions.formatDate(date: newYear, format: 'yyyy-MM-dd'), equals('2025-01-01'));
    });
  });

  group('DateFunctions.formatDuration Tests', () {
    test('returns fallback string --:--:-- when duration is null', () {
      expect(DateFunctions.formatDuration(null), equals('--:--:--'));
    });

    test('formats zero duration correctly as 00:00', () {
      expect(DateFunctions.formatDuration(Duration.zero), equals('00:00'));
    });

    test('formats durations under 1 hour (minutes and seconds) with zero padding', () {
      const duration = Duration(minutes: 5, seconds: 8);
      expect(DateFunctions.formatDuration(duration), equals('05:08'));
    });

    test('formats durations under 1 day with hours, minutes, and seconds', () {
      const duration = Duration(hours: 2, minutes: 5, seconds: 8);
      expect(DateFunctions.formatDuration(duration), equals('02:05:08'));
    });

    test('formats duration of exactly 1 hour without days', () {
      const duration = Duration(hours: 1);
      expect(DateFunctions.formatDuration(duration), equals('01:00:00'));
    });

    test('formats duration with days, hours, and minutes with proper padding', () {
      const duration = Duration(days: 1, hours: 2, minutes: 3, seconds: 4);
      expect(DateFunctions.formatDuration(duration), equals('01d 02h 03m '));
    });

    test('formats multi-day durations correctly', () {
      const duration = Duration(days: 12, hours: 14, minutes: 45);
      expect(DateFunctions.formatDuration(duration), equals('12d 14h 45m '));
    });
  });
}
