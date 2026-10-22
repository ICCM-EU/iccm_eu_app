import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';

void main() {
  group('ExpandContentProvider Tests', () {
    test('initial isExpanded state is false', () {
      final provider = ExpandContentProvider();
      expect(provider.isExpanded, isFalse);
    });

    test('toggleExpanded toggles isExpanded and notifies listeners', () {
      final provider = ExpandContentProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.toggleExpanded();
      expect(provider.isExpanded, isTrue);
      expect(notified, isTrue);

      provider.toggleExpanded();
      expect(provider.isExpanded, isFalse);
    });

    test('setIsExpanded sets isExpanded to explicit boolean', () {
      final provider = ExpandContentProvider();

      provider.setIsExpanded(true);
      expect(provider.isExpanded, isTrue);

      provider.setIsExpanded(false);
      expect(provider.isExpanded, isFalse);
    });
  });
}
