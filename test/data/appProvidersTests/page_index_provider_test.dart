import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/page_index_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PageIndexProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('updateSelectedIndex sets index and notifies listeners', () {
      final provider = PageIndexProvider();
      bool notified = false;
      provider.addListener(() => notified = true);

      provider.updateSelectedIndex(3);

      expect(provider.selectedIndex, equals(3));
      expect(notified, isTrue);
    });

    test('incrementSelectedIndex increments index within valid range', () {
      final provider = PageIndexProvider();
      provider.updateSelectedIndex(1);

      provider.incrementSelectedIndex();
      expect(provider.selectedIndex, equals(2));
    });

    test('decrementSelectedIndex decrements index within valid range', () {
      final provider = PageIndexProvider();
      provider.updateSelectedIndex(2);

      provider.decrementSelectedIndex();
      expect(provider.selectedIndex, equals(1));
    });
  });
}
