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
}
