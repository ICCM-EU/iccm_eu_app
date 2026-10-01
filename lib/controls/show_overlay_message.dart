import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';

void showOverlayMessage(BuildContext context, String message, {Color? backgroundColor}) {
  LocalNotificationService.addInAppNotification(
    title: '',
    body: message,
    backgroundColor: backgroundColor,
  );
}