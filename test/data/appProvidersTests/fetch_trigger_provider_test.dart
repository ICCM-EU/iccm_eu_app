import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/fetch_trigger_provider.dart';

void main() {
  group('FetchTriggerProvider Tests', () {
    test('triggerFetch notifies listeners', () {
      final provider = FetchTriggerProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.triggerFetch();

      expect(notified, isTrue);
    });
  });
}
