import 'package:iccm_eu_app/utils/debug.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class UrlFunctions {
  static Future<void> launch(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )
    ) {
      throw Exception('Could not launch $url');
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

  ///////////////////////////////////////////////
  // Website icon parsing
  ///////////////////////////////////////////////

  static Future<String?> getFaviconUrl(String websiteUrl) async {
    try {
      // 1. Fetch the website's HTML
      final response = await http.get(Uri.parse(websiteUrl));

      if (response.statusCode == 200) {
        // 2. Parse the HTML
        final document = parser.parse(response.body);

        // 3. Find the favicon link
        final faviconLink = _findFaviconLink(document);

        if (faviconLink != null) {
          // 4. Extract the favicon URL
          final faviconUrl = _extractFaviconUrl(websiteUrl, faviconLink);
          return faviconUrl;
        } else {
          // 5. Try default favicon location
          final defaultFaviconUrl = _getDefaultFaviconUrl(websiteUrl);
          return defaultFaviconUrl;
        }
      } else {
        Debug.msg('Failed to load website: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Debug.msg('Error getting favicon: $e');
      return null;
    }
  }

  // Helper function to find the favicon link in the HTML
  static dom.Element? _findFaviconLink(dom.Document document) {
    // Look for <link> tags with rel="icon" or rel="shortcut icon"
    final links = document.querySelectorAll('link');
    for (final link in links) {
      final rel = link.attributes['rel']?.toLowerCase();
      if (rel == 'icon' || rel == 'shortcut icon') {
        return link;
      }
    }
    return null;
  }

  // Helper function to extract the favicon URL from the link tag
  static String _extractFaviconUrl(String websiteUrl, dom.Element link) {
    final href = link.attributes['href'];
    if (href == null) {
      return '';
    }
    // Handle relative URLs
    if (href.startsWith('http')) {
      return href;
    } else if (href.startsWith('/')) {
      return Uri.parse(websiteUrl).origin + href;
    } else {
      return '${Uri.parse(websiteUrl).origin}/$href';
    }
  }

  // Helper function to get the default favicon URL
  static String _getDefaultFaviconUrl(String websiteUrl) {
    return '${Uri.parse(websiteUrl).origin}/favicon.ico';
  }
}