import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';

class NotificationPermissionOverlay extends StatefulWidget {
  const NotificationPermissionOverlay({super.key});

  @override
  State<NotificationPermissionOverlay> createState() =>
      _NotificationPermissionOverlayState();
}

class _NotificationPermissionOverlayState
    extends State<NotificationPermissionOverlay> {
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionAndPrompt();
    });
  }

  Future<void> _checkPermissionAndPrompt() async {
    if (!FcmNotificationsService.supportedPlatform) {
      return;
    }
    final bool inhibit = await PreferencesProvider.inhibitNotifications;
    if (inhibit) {
      return;
    }
    await PreferencesProvider.loadNotificationTopics();
    final bool granted = await FcmNotificationsService.isPermissionGranted();
    final bool hasNoTopics =
        PreferencesProvider.notificationTopicsNotifier.value.isEmpty;

    if (!granted || hasNoTopics) {
      if (mounted) {
        setState(() {
          _showOverlay = true;
        });
      }
    }
  }

  Future<void> _onYes() async {
    setState(() {
      _showOverlay = false;
    });
    await PreferencesProvider.addNotificationTopic(
      FcmNotificationsService.defaultTopic,
      userGesture: true,
    );
  }

  Future<void> _onNo() async {
    setState(() {
      _showOverlay = false;
    });
    await PreferencesProvider.setInhibitNotifications(true);
  }

  void _onCancel() {
    setState(() {
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surfaceContainerHigh;
    final fgColor = theme.colorScheme.onSurface;

    return Positioned(
      bottom: 60,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Receive Announcement Notifications?',
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _onYes,
                      child: const Text('Yes'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _onNo,
                      child: const Text('No'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
