import 'package:flutter/material.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

class UrlButton extends StatelessWidget {
  final String? url;
  final String title;

  const UrlButton({
    super.key,
    required this.url,
    required this.title,
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
              widthFactor: 0.9, // 90% of parent width
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
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          )
          ,
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}