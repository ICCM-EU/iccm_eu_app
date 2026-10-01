import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                    child: _NotificationCard(
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

class _NotificationCard extends StatelessWidget {
  final InAppNotificationItem notification;
  final VoidCallback onClose;

  const _NotificationCard({
    required this.notification,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = notification.backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = notification.backgroundColor != null
        ? Colors.white
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                Icons.notifications_active,
                color: fgColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (notification.title.isNotEmpty)
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: fgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  if (notification.title.isNotEmpty && notification.body.isNotEmpty)
                    const SizedBox(height: 4),
                  if (notification.body.isNotEmpty)
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  color: fgColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}