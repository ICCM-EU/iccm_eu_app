import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/model/error_signal.dart';

void main() {
  group('ErrorSignal Tests', () {
    test('holds error message string', () {
      final signal = ErrorSignal('Network disconnected');
      expect(signal.message, equals('Network disconnected'));
    });
  });
}
