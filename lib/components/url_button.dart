import 'package:flutter/material.dart';
import 'package:iccm_eu_app/pages/share_page.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class UrlButton extends StatelessWidget {
  final String? url;
  final String title;
  final bool? withQrCode;

  const UrlButton({
    super.key,
    required this.url,
    required this.title,
    this.withQrCode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (url != null &&
        url!.startsWith('http')) {
      return Column(
        children: [
          const SizedBox(height: 16.0),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: Row( // Use Row to arrange ElevatedButton and IconButton
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Space between items
                children: [
                  Expanded( // Allow ElevatedButton to take available space
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                          style: BorderStyle.solid,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      onPressed: () => UrlFunctions.launch(url!),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Add spacing between ElevatedButton and IconButton
                  (withQrCode ?? false)
                      ? IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SharePage(url: url!),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}