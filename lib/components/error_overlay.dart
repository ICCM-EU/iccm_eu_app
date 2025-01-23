import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controls/show_overlay_message.dart';
import '../data/appProviders/error_provider.dart';

class ErrorOverlay extends StatelessWidget {
  const ErrorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final errorSignal = Provider
          .of<ErrorProvider>(context)
          .errorSignal;

      if (errorSignal != null) {
        // Show overlay message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOverlayMessage(context, errorSignal.message);
        });
        // Clear the signal after displaying the message
        Provider.of<ErrorProvider>(context, listen: false).clearErrorSignal();
      }
    }

    return const SizedBox.shrink(); // Or a placeholder widget
  }
}