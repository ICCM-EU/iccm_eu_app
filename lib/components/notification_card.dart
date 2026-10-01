import 'package:flutter/material.dart';
import '../data/notifications/in_app_notification_item.dart';

class NotificationCard extends StatelessWidget {
  final InAppNotificationItem notification;
  final VoidCallback onClose;

  const NotificationCard({
    super.key,
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