import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlText extends StatelessWidget {
  final String? url;

  const UrlText({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url != null &&
        url!.startsWith('http')) {
      return SelectableText(
        url!,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(url!))) {
            await launchUrl(Uri.parse(url!));
          }
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}