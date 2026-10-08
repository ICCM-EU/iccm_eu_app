import 'package:flutter/foundation.dart';

class Debug {
  static void msg(String message) {
    if (!kReleaseMode) { // Check if not in release mode
      // ignore: avoid_print
      print('[DEBUG] $message'); // Print the message with a [DEBUG] prefix
    }
  }
}