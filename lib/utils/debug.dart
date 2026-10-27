import 'package:flutter/foundation.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';

enum DebugLevel {
  silent,
  error,
  warning,
  info,
  debug,
}

class Debug {
  static void msg(DebugLevel level, String message) {
    if (level.index <= PreferencesProvider.debugLevelNotifier.value.index) {
      debugPrint('[${level.name.toUpperCase()}] $message');
    }
  }

  static void info(String message) => msg(DebugLevel.info, message);
  static void debug(String message) => msg(DebugLevel.debug, message);
  static void warning(String message) => msg(DebugLevel.warning, message);
  static void error(String message) => msg(DebugLevel.error, message);
}
