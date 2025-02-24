import 'package:iccm_eu_app/platform/platform.dart';
import 'dart:io' as io;

Platform getPlatform() {
  if (io.Platform.isAndroid) {
    return Platform.android;
  }
  if (io.Platform.isIOS) {
    return Platform.ios;
  }
  if (io.Platform.isWindows) {
    return Platform.windows;
  }
  if (io.Platform.isLinux) {
    return Platform.linux;
  }
  if (io.Platform.isMacOS) {
    return Platform.macos;
  }

  throw UnimplementedError('Unsupported');
}