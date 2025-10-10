import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:iccm_eu_app/data/model/notification_channel_data.dart';
import 'package:iccm_eu_app/data/model/web_notification.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// based on https://medium.com/@saminchandeepa/a-comprehensive-guide-to-implement-notifications-in-flutter-32155df65c40

class LocalNotificationService {
  // create an instance of the flutter local notification plugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  static final Map<int, WebNotification> _webNotifications = {};

  // initialize the notification service
  static Future<void> init({
    required NotificationChannelData channelData,
  }) async {
    // Initialize the timezones
    tz_data.initializeTimeZones();
    final String timeZoneName = FlutterTimezone.getLocalTimezone().toString();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // initialize the android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // initialize the ios settings
    const DarwinInitializationSettings initializationSettingsIos =
    DarwinInitializationSettings();

    // combine the android and ios settings
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );

    // initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse:
      // onDidReceiveBackgroundNotificationResponse,
      // onDidReceiveNotificationResponse:
      // onDidReceiveBackgroundNotificationResponse,
    );

    // request permission to show notifications on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final status = await Permission.notification.status;
    if (status != PermissionStatus.granted) {
      Debug.msg('WARN: Notification permission not granted');
    } else {
      Debug.msg('OK: Notification permission granted');
    }

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelData.id,
      channelData.name,
      description: channelData.description,
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required NotificationChannelData channelData,
  }) async {
    // define the notification details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelData.id,
        channelData.name,
        channelDescription: channelData.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    //show the notification
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannelData channelData,
    int? id,
  }) async {
    if (kIsWeb) {
      _webNotifications[id ?? 0] = WebNotification(
          title: title,
          msg: body,
          timeout: scheduledDate,
      );
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelData.id,
        channelData.name,
        channelDescription: channelData.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Debug.msg('ACTUAL SCHEDULE TIME: ${tz.TZDateTime.from(scheduledDate, tz.local)}');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id ?? 0,
      TextFunctions.cutTextToWords(
        text: title,
        wordCount: 80,
      ),
      TextFunctions.cutTextToWords(
        text: body,
        wordCount: 80,
      ),
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    required NotificationChannelData channelData,
  }) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
    BigPictureStyleInformation(
      DrawableResourceAndroidBitmap(imageUrl),
      largeIcon: DrawableResourceAndroidBitmap(imageUrl),
      contentTitle: title,
      summaryText: body,
      htmlFormatContent: true,
      htmlFormatContentTitle: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelData.id,
        channelData.name,
        channelDescription: channelData.description,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: [DarwinNotificationAttachment(imageUrl)],
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> showInstantNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String payload,
    required NotificationChannelData channelData,
  }) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelData.id,
        channelData.name,
        channelDescription: channelData.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future cancelAllNotifications() async {
    _webNotifications.clear();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future cancelNotification(
      int id,
      String? tag,
  ) async {
    _webNotifications.remove(id);
    await flutterLocalNotificationsPlugin.cancel(
      id,
      tag: tag,
    );
  }

  // static Future<void> onDidReceiveBackgroundNotificationResponse(
  //     NotificationResponse notificationResponse) async {
  // }

  static DateTime scheduleAhead ({
    required DateTime time,
    Duration? before,
  }) {
    before ??= Duration(minutes: 3);
    return time.subtract(before);
  }
}