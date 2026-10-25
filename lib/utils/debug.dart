import 'package:flutter/foundation.dart';

class Debug {
  /// Outputs a DEBUG message prefixed with [DEBUG].
  /// Intended for major status successes (e.g. acquiring a token, loading fresh data)
  /// and error cases that require debugging. These are NOT suppressed in production mode.
  static void msg(String message) {
    debugPrint('[DEBUG] $message');
  }

  /// Alias for [msg].
  static void debug(String message) => msg(message);

  /// Outputs an INFO message prefixed with [INFO].
  /// Intended for routine informational messages. These ARE suppressed in production mode (`kReleaseMode`).
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }
}

