import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/platform/platform.dart';

void main() {
  group('Platform Enum Tests', () {
    test('contains all expected platform values', () {
      expect(Platform.values, hasLength(6));
      expect(Platform.values, containsAll([
        Platform.android,
        Platform.ios,
        Platform.web,
        Platform.windows,
        Platform.linux,
        Platform.macos,
      ]));
    });

    test('resolves enum value by name correctly', () {
      expect(Platform.values.byName('android'), equals(Platform.android));
      expect(Platform.values.byName('ios'), equals(Platform.ios));
      expect(Platform.values.byName('web'), equals(Platform.web));
      expect(Platform.values.byName('windows'), equals(Platform.windows));
      expect(Platform.values.byName('linux'), equals(Platform.linux));
      expect(Platform.values.byName('macos'), equals(Platform.macos));
    });

    test('throws ArgumentError on invalid enum name lookup', () {
      expect(() => Platform.values.byName('unknown_platform'), throwsArgumentError);
    });
  });
}
