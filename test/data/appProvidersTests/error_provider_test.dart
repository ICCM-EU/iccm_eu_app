import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/model/error_signal.dart';

void main() {
  group('ErrorProvider Tests', () {
    test('initial errorSignal is null', () {
      final provider = ErrorProvider();
      expect(provider.errorSignal, isNull);
    });

    test('setErrorSignal updates errorSignal and notifies listeners', () {
      final provider = ErrorProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      final signal = ErrorSignal('Something went wrong');
      provider.setErrorSignal(signal);

      expect(provider.errorSignal, equals(signal));
      expect(provider.errorSignal?.message, equals('Something went wrong'));
      expect(notified, isTrue);
    });

    test('clearErrorSignal sets errorSignal to null', () {
      final provider = ErrorProvider();
      provider.setErrorSignal(ErrorSignal('Error'));
      expect(provider.errorSignal, isNotNull);

      provider.clearErrorSignal();
      expect(provider.errorSignal, isNull);
    });
  });
}
