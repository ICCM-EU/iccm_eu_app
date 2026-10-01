import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/appProviders/error_provider.dart';
import '../data/notifications/local_notification_service.dart';
import 'notification_card.dart';

class ErrorOverlay extends StatefulWidget {
  const ErrorOverlay({super.key});

  @override
  State<ErrorOverlay> createState() => _ErrorOverlayState();
}

class _ErrorOverlayState extends State<ErrorOverlay> {
  @override
  void initState() {
    super.initState();
    LocalNotificationService.inAppNotificationsNotifier.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    LocalNotificationService.inAppNotificationsNotifier.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final errorProvider = Provider.of<ErrorProvider>(context);
      final errorSignal = errorProvider.errorSignal;

      if (errorSignal != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          LocalNotificationService.addInAppNotification(
            title: 'Error',
            body: errorSignal.message,
            backgroundColor: Colors.red,
          );
          errorProvider.clearErrorSignal();
        });
      }
    }

    final notifications = LocalNotificationService.inAppNotificationsNotifier.value;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: notifications.map((notification) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: NotificationCard(
                      notification: notification,
                      onClose: () {
                        LocalNotificationService.removeInAppNotification(notification.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
