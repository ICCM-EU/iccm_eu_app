import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/url_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FullScreenQrCode extends StatelessWidget {
  final String url;
  final String title;
  final bool showText;

  const FullScreenQrCode({
    super.key,
    required this.url,
    this.title = 'Full Screen QR Code',
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey.shade700,
            ),
            onPressed: () {
              Navigator.pop(context); // Close fullscreen page
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showText) UrlText(url: url),
          if (showText) const SizedBox(height: 8),
          Center(
            child: SizedBox(
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 300.0, // Adjust size for fullscreen
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}