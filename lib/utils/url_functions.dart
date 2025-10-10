import 'package:url_launcher/url_launcher.dart';

class UrlFunctions {
  static Future<void> launch(String url, bool inApp) async {
    if (inApp) {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.inAppWebView,
      )
      ) {
        throw Exception('Could not launch $url');
      }
    } else {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )
      ) {
        throw Exception('Could not launch $url');
      }
    }
  }

  static String proxy(String? url) {
    url ??= '';
    // if (kIsWeb &&
    //     url.isNotEmpty &&
    //     ! url.startsWith('https://firebasestorage.googleapis.com')
    // ) {
    //   url = 'https://corsproxy.io/?${Uri.encodeFull(url)}';
    // }
    return url;
  }
}