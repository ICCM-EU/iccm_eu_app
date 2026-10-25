import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/debug.dart';

void main() {
  group('Debug.msg Tests', () {
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      originalDebugPrint = debugPrint;
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('prints message prefixed with [DEBUG]', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.msg('Server response 200 OK');
      expect(capturedMessage, equals('[DEBUG] Server response 200 OK'));
    });

    test('handles empty message string', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.msg('');
      expect(capturedMessage, equals('[DEBUG] '));
    });

    test('handles multiline messages and special characters', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      const multiline = 'Line 1\nLine 2\nLine 3! @#\$%^&*()';
      Debug.msg(multiline);
      expect(capturedMessage, equals('[DEBUG] $multiline'));
    });
  });

  group('Debug.debug Tests', () {
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      originalDebugPrint = debugPrint;
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('prints message prefixed with [DEBUG]', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.debug('Acquired fresh token');
      expect(capturedMessage, equals('[DEBUG] Acquired fresh token'));
    });
  });

  group('Debug.info Tests', () {
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      originalDebugPrint = debugPrint;
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('prints message prefixed with [INFO] in debug mode', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.info('Informational message');
      if (kDebugMode) {
        expect(capturedMessage, equals('[INFO] Informational message'));
      } else {
        expect(capturedMessage, isNull);
      }
    });

    test('handles empty message string for info', () {
      String? capturedMessage;
      debugPrint = (String? message, {int? wrapWidth}) {
        capturedMessage = message;
      };

      Debug.info('');
      if (kDebugMode) {
        expect(capturedMessage, equals('[INFO] '));
      } else {
        expect(capturedMessage, isNull);
      }
    });
  });
}
