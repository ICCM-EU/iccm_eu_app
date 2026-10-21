import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/platform/multiplatform.dart';
import 'package:iccm_eu_app/platform/platform.dart';

void main() {
  group('Multiplatform Export Tests', () {
    test('getPlatform resolves to native IO platform in VM test environment', () {
      final platform = getPlatform();
      expect(platform, isA<Platform>());
      expect(Platform.values, contains(platform));
    });
  });
}
