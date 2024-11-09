import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  static Future<void> url(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )
    ) {
      throw Exception('Could not launch $url');
    }
  }
}