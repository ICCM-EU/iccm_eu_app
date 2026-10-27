import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Debug Tests', () {
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      originalDebugPrint = debugPrint;
      PreferencesProvider.debugLevelNotifier.value = DebugLevel.debug;
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
      PreferencesProvider.debugLevelNotifier.value = DebugLevel.warning;
    });

    test('prints message prefixed with [DEBUG] when debug level is enabled', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.msg(DebugLevel.debug, 'Server response 200 OK');
      expect(capturedMessage, equals('[DEBUG] Server response 200 OK'));
    });

    test('prints message prefixed with [ERROR], [WARNING], [INFO], [DEBUG] according to level helper methods', () {
      final captured = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };

      Debug.error('Critical error');
      Debug.warning('Low disk space');
      Debug.info('Cache loaded');
      Debug.debug('Verbose trace');

      expect(captured, equals([
        '[ERROR] Critical error',
        '[WARNING] Low disk space',
        '[INFO] Cache loaded',
        '[DEBUG] Verbose trace',
      ]));
    });

    test('filters out messages exceeding selected debug level threshold', () {
      final captured = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };

      PreferencesProvider.debugLevelNotifier.value = DebugLevel.warning;

      Debug.error('Fatal error');
      Debug.warning('Disk warning');
      Debug.info('Informational message');
      Debug.debug('Trace details');

      expect(captured, equals([
        '[ERROR] Fatal error',
        '[WARNING] Disk warning',
      ]));
    });

    test('handles empty message string', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.msg(DebugLevel.warning, '');
      expect(capturedMessage, equals('[WARNING] '));
    });

    test('handles multiline messages and special characters', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      const multiline = 'Line 1\nLine 2\nLine 3! @#\$%^&*()';
      Debug.msg(DebugLevel.error, multiline);
      expect(capturedMessage, equals('[ERROR] $multiline'));
    });
  });
}
