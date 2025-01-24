import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/full_screen_qr_code.dart';
import 'package:iccm_eu_app/components/url_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharePage extends StatelessWidget {
  final String url;

  const SharePage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share QR Code'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UrlText(url: url),
          SizedBox(height: 8),
          GestureDetector( // Wrap QrImage with GestureDetector
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenQrCode(
                        url: url,
                      ), // Pass the URL to FullScreenImage
                ),
              );
            },
            child: Center( // Center the QrImage
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}