import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FullScreenQrCode extends StatelessWidget {
  final String url;

  const FullScreenQrCode({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen QR Code'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[700],
            ),
            onPressed: () {
              Navigator.pop(context); // Close fullscreen page
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: 300.0, // Adjust size for fullscreen
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}