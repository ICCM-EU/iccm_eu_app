import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/platform/multiplatform_io.dart';
import 'package:iccm_eu_app/platform/platform.dart';

void main() {
  group('MultiplatformIO Tests', () {
    test('getPlatform returns expected host IO platform enum', () {
      final platform = getPlatform();
      expect(platform, isNotNull);

      if (io.Platform.isAndroid) {
        expect(platform, equals(Platform.android));
      } else if (io.Platform.isIOS) {
        expect(platform, equals(Platform.ios));
      } else if (io.Platform.isWindows) {
        expect(platform, equals(Platform.windows));
      } else if (io.Platform.isLinux) {
        expect(platform, equals(Platform.linux));
      } else if (io.Platform.isMacOS) {
        expect(platform, equals(Platform.macos));
      }
    });

    test('getPlatform returns non-web platform value', () {
      final platform = getPlatform();
      expect(platform, isNot(equals(Platform.web)));
    });
  });
}
