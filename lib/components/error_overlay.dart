import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controls/show_overlay_message.dart';
import '../data/appProviders/error_provider.dart';
import '../data/notifications/local_notification_service.dart';

class ErrorOverlay extends StatefulWidget {
  const ErrorOverlay({super.key});

  @override
  State<ErrorOverlay> createState() => _ErrorOverlayState();
}

class _ErrorOverlayState extends State<ErrorOverlay> {
  @override
  void initState() {
    super.initState();
    LocalNotificationService.onInAppNotification.addListener(_handleInAppNotification);
  }

  @override
  void dispose() {
    LocalNotificationService.onInAppNotification.removeListener(_handleInAppNotification);
    super.dispose();
  }

  void _handleInAppNotification() {
    final notification = LocalNotificationService.onInAppNotification.value;
    if (notification != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showOverlayMessage(context, '${notification.title}\n${notification.msg}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final errorSignal = Provider
          .of<ErrorProvider>(context)
          .errorSignal;

      if (errorSignal != null) {
        // Show overlay message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOverlayMessage(context, errorSignal.message, backgroundColor: Colors.red);
        });
        // Clear the signal after displaying the message
        Provider.of<ErrorProvider>(context, listen: false).clearErrorSignal();
      }
    }

    return const SizedBox.shrink();
  }
}