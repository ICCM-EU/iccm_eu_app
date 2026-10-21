import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/platform/multiplatform_web.dart';
import 'package:iccm_eu_app/platform/platform.dart';

void main() {
  group('MultiplatformWeb Tests', () {
    test('getPlatform returns Platform.web', () {
      expect(getPlatform(), equals(Platform.web));
    });
  });
}
