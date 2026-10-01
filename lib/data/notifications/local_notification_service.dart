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

  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  static bool get isInitialized => _isInitialized;

  // initialize the notification service
  static Future<void> init({
    NotificationChannelData? channelData,
  }) async {
    if (_isInitialized) {
      if (channelData != null) {
        await _createChannel(channelData);
      }
      return;
    }
    if (_initFuture != null) {
      await _initFuture;
      if (channelData != null) {
        await _createChannel(channelData);
      }
      return;
    }

    _initFuture = _doInit(channelData);
    await _initFuture;
  }

  static Future<void> _doInit([NotificationChannelData? channelData]) async {
    try {
      // Initialize the timezones
      tz_data.initializeTimeZones();
      try {
        TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = timezone.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        Debug.msg('Fallback timezone to UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      Debug.msg('Timezone initialization skipped/failed: $e');
    }

    try {
      // initialize the android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // initialize the ios settings
      const DarwinInitializationSettings initializationSettingsIos =
      DarwinInitializationSettings();

      // initialize the macos settings
      const DarwinInitializationSettings initializationSettingsMacos =
      DarwinInitializationSettings();

      // initialize the linux settings
      const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open app');

      // combine the platform settings
      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIos,
        macOS: initializationSettingsMacos,
        linux: initializationSettingsLinux,
      );

      // initialize the plugin
      bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        // onDidReceiveBackgroundNotificationResponse:
        // onDidReceiveBackgroundNotificationResponse,
        // onDidReceiveNotificationResponse:
        // onDidReceiveBackgroundNotificationResponse,
      );

      _isInitialized = initialized ?? true;
      Debug.msg('LocalNotificationService plugin initialized: $_isInitialized (result: $initialized)');

      if (channelData != null) {
        await _createChannel(channelData);
      }
    } catch (e) {
      Debug.msg('LocalNotificationService plugin setup skipped/failed: $e');
      _isInitialized = false;
    }
  }

  static Future<void> _createChannel(NotificationChannelData channelData) async {
    if (!_isInitialized) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
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
    } catch (e) {
      Debug.msg('Failed to create notification channel: $e');
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized && _initFuture == null) {
      await init();
    } else if (!_isInitialized && _initFuture != null) {
      await _initFuture;
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required NotificationChannelData channelData,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping showInstantNotification');
      return;
    }

    try {
      // define the notification details
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelData.id,
          channelData.name,
          channelDescription: channelData.description,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      //show the notification
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      Debug.msg('Failed to show instant notification: $e');
    }
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

    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping scheduleNotification');
      return;
    }

    try {
      NotificationDetails notificationDetails = NotificationDetails(
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

      // Debug.msg('ACTUAL SCHEDULE TIME: ${tz.TZDateTime.from(scheduledDate, tz.local)}');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id ?? 0,
        title: TextFunctions.cutTextToWords(
          text: title,
          wordCount: 80,
        ),
        body: TextFunctions.cutTextToWords(
          text: body,
          wordCount: 80,
        ),
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: notificationDetails,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      Debug.msg('Failed to schedule notification: $e');
    }
  }

  static Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    required NotificationChannelData channelData,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping showBigPictureNotification');
      return;
    }

    try {
      final BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
        DrawableResourceAndroidBitmap(imageUrl),
        largeIcon: DrawableResourceAndroidBitmap(imageUrl),
        contentTitle: title,
        summaryText: body,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
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
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      Debug.msg('Failed to show big picture notification: $e');
    }
  }

  static Future<void> showInstantNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String payload,
    required NotificationChannelData channelData,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping showInstantNotificationWithPayload');
      return;
    }

    try {
      NotificationDetails notificationDetails = NotificationDetails(
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
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      Debug.msg('Failed to show instant notification with payload: $e');
    }
  }

  static Future cancelAllNotifications() async {
    _webNotifications.clear();

    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping cancelAllNotifications');
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      Debug.msg('Failed to cancel all notifications: $e');
    }
  }

  static Future cancelNotification(
      int id,
      String? tag,
  ) async {
    _webNotifications.remove(id);

    await _ensureInitialized();
    if (!_isInitialized) {
      Debug.msg('LocalNotificationService not initialized, skipping cancelNotification');
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.cancel(
        id: id,
        tag: tag,
      );
    } catch (e) {
      Debug.msg('Failed to cancel notification: $e');
    }
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