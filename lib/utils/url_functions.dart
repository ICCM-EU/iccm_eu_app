import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlFunctions {
  static Future<void> launch(String url, bool inApp) async {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      throw Exception('Invalid URL scheme for launching: $url');
    }
    final uri = Uri.parse(trimmed);
    final mode = inApp ? LaunchMode.inAppWebView : LaunchMode.externalApplication;
    if (!await launchUrl(
      uri,
      mode: mode,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  static String proxy(String? url) {
    url ??= '';
    if (kIsWeb &&
        kDebugMode &&
        url.isNotEmpty &&
        !url.startsWith('https://firebasestorage.googleapis.com') &&
        !url.startsWith('https://script.google.com') &&
        !url.startsWith('https://scriptusercontent.com')
    ) {
      url = 'https://corsproxy.io/?${Uri.encodeFull(url)}';
    }
    return url;
  }
}
