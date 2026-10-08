import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/js.dart' as js;

import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/notification_channel_data.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:iccm_eu_app/utils/text_functions.dart';

import '../../utils/debug.dart';

class FcmNotificationsService {
  static const String sep = PreferencesProvider.listSep;
  static final String defaultTopic = "Announcements";
  static final normalizedDefault = TextFunctions.normalizeListKey(
    FcmNotificationsService.defaultTopic,
    sep,
  );
  static final String testTopic = "Test Topic";
  static final normalizedTestTopic = TextFunctions.normalizeListKey(
    testTopic,
    sep,
  );
  static List<String> _topics = [defaultTopic];
  static late FirebaseMessaging messaging;
  static String? token;
  static String backendUrl = 'https://iccm-eu-notifications.tappe-info.de';

  static final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  static bool _listenersConfigured = false;

  static void _setupMessageListeners() {
    if (_listenersConfigured) {
      Debug.msg('[FCM] Listeners already configured, skipping.');
      return;
    }
    try {
      Debug.msg('[FCM] Setting up FirebaseMessaging.onMessage and onMessageOpenedApp listeners...');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Debug.msg('[FCM Stream] >>> FOREGROUND MESSAGE RECEIVED <<<');
        Debug.msg('[FCM Stream] Message ID: ${message.messageId}');
        Debug.msg('[FCM Stream] From (topic): ${message.from}');
        Debug.msg('[FCM Stream] Notification Title: "${message.notification?.title}"');
        Debug.msg('[FCM Stream] Notification Body: "${message.notification?.body}"');
        Debug.msg('[FCM Stream] Data payload: ${message.data}');
        handleIncomingRemoteMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Debug.msg('[FCM Stream] >>> MESSAGE OPENED APP EVENT <<<');
        Debug.msg('[FCM Stream] Message ID: ${message.messageId}');
        Debug.msg('[FCM Stream] Data payload: ${message.data}');
        handleIncomingRemoteMessage(message);
      });

      _listenersConfigured = true;
      Debug.msg('[FCM] FirebaseMessaging listeners successfully configured.');
    } catch (e) {
      Debug.msg('[FCM] Error setting up FirebaseMessaging listeners: $e');
    }
  }

  static Future<void> handleIncomingRemoteMessage(RemoteMessage message) async {
    Debug.msg('[FCM] handleIncomingRemoteMessage triggered for MessageID="${message.messageId}"');
    _messageStreamController.add(message);

    final String title = message.notification?.title ?? message.data['title'] ?? 'Announcement';
    final String bodyText = message.notification?.body ?? message.data['messageText'] ?? message.data['body'] ?? '';
    final String author = message.data['author'] ?? '';

    String fullBody = bodyText;
    if (author.isNotEmpty && !fullBody.contains('($author)')) {
      fullBody = '$fullBody\n\n($author)';
    }

    Debug.msg('[FCM] Extracted fields -> Title: "$title", Author: "$author"');

    if (title.isNotEmpty || fullBody.isNotEmpty) {
      Debug.msg('[FCM] Forwarding message to LocalNotificationService.showInstantNotification...');
      await LocalNotificationService.showInstantNotification(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: fullBody,
        channelData: NotificationChannelData(
          id: 'fcm_channel',
          name: 'Announcements',
          description: 'Notifications from FCM',
        ),
      );
    } else {
      Debug.msg('[FCM] Message title and body were both empty, skipping local notification display.');
    }
  }

  static Future<String?> generateToken({bool userGesture = false}) async {
    if (token != null && token!.isNotEmpty) {
      return token;
    }
    await PreferencesProvider.loadFcmToken();
    if (PreferencesProvider.fcmTokenNotifier.value.isNotEmpty) {
      token = PreferencesProvider.fcmTokenNotifier.value;
      return token;
    }
    await _ensureToken(userGesture: userGesture);
    if (token == null || token!.isEmpty) {
      token = 'fcm_token_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 10000}';
      await PreferencesProvider.setFcmToken(token!);
    }
    return token;
  }

  static String get _cleanBackendUrl {
    var url = backendUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static String normalizeTopic(String topic) {
    return TextFunctions.normalizeListKey(topic, sep);
  }

  static bool get supportedPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
  static bool get isSupported => supportedPlatform;

  // Called directly on start without a login.
  static Future<void> initializeFcmNotifications({bool userGesture = false, TracksProvider? tracksProvider}) async {
    Debug.msg('[FCM] initializeFcmNotifications started (userGesture=$userGesture, supportedPlatform=$supportedPlatform)');
    if (!supportedPlatform) {
      Debug.msg('[FCM] FCM notifications not supported on this platform.');
      return;
    }
    _setupMessageListeners();
    try {
      Debug.msg('[FCM] Ensuring FCM token...');
      final tokenRecoveredFromPrefs = await _ensureToken(userGesture: userGesture);
      Debug.msg('[FCM] Token state -> token="$token", recoveredFromPrefs=$tokenRecoveredFromPrefs');

      if (token != null && token!.isNotEmpty) {
        if (tokenRecoveredFromPrefs) {
          Debug.msg('[FCM] Token was recovered from preferences.');
        }

        try {
          await PreferencesProvider.loadNotificationTopics(tracksProvider);
          Debug.msg('[FCM] Notification topics in preferences: ${PreferencesProvider.notificationTopicsNotifier.value}');
          for (String topic in PreferencesProvider.notificationTopicsNotifier.value) {
            if (topic.isNotEmpty) {
              Debug.msg('[FCM] Subscribing to saved topic "$topic"...');
              await subscribeToTopic(topic, userGesture: userGesture);
            }
          }
          // ensure to unsubscribe from test topic when not listed in preferences
          final normalizedTestTopic = normalizeTopic(testTopic);
          if (!PreferencesProvider.notificationTopicsNotifier.value.contains(normalizedTestTopic)) {
            Debug.msg('[FCM] Ensuring unsubscription from test topic "$normalizedTestTopic"...');
            await unsubscribeFromTopic(normalizedTestTopic, userGesture: userGesture);
          }
        } catch (e) {
          Debug.msg('[FCM] Error processing topic subscriptions during initialization: $e');
        }
      } else {
        Debug.msg('[FCM] Token is null or empty after _ensureToken.');
      }
    } catch (e) {
      Debug.msg('[FCM] Error in initializeFcmNotifications: $e');
    }
  }

  static FirebaseOptions? _getWebFirebaseOptions() {
    if (!kIsWeb) return null;
    try {
      if (js.context.hasProperty('firebaseConfig')) {
        final dynamic config = js.context['firebaseConfig'];
        if (config == null) return null;
        final apiKey = config['apiKey']?.toString();
        final authDomain = config['authDomain']?.toString();
        final projectId = config['projectId']?.toString();
        final storageBucket = config['storageBucket']?.toString();
        final messagingSenderId = config['messagingSenderId']?.toString();
        final appId = config['appId']?.toString();

        if (apiKey != null && projectId != null) {
          return FirebaseOptions(
            apiKey: apiKey,
            authDomain: authDomain ?? '',
            projectId: projectId,
            storageBucket: storageBucket ?? '',
            messagingSenderId: messagingSenderId ?? '',
            appId: appId ?? '',
          );
        }
      }
    } catch (e) {
      Debug.msg('[FCM] Error reading window.firebaseConfig: $e');
    }
    return null;
  }

  static String? _getWebVapidKey() {
    if (!kIsWeb) return null;
    try {
      if (js.context.hasProperty('firebaseConfig')) {
        final dynamic config = js.context['firebaseConfig'];
        if (config == null) return null;
        return config['vapidKey']?.toString();
      }
    } catch (e) {
      Debug.msg('[FCM] Error reading vapidKey from window.firebaseConfig: $e');
    }
    return null;
  }

  static Future<bool> _ensureToken({bool userGesture = false}) async {
    Debug.msg('[FCM] _ensureToken called (memory token="$token")');
    if (token != null && token!.isNotEmpty) {
      Debug.msg('[FCM] Using token already present in memory: "$token"');
      return false;
    }

    await PreferencesProvider.loadFcmToken();
    if (PreferencesProvider.fcmTokenNotifier.value.isNotEmpty) {
      token = PreferencesProvider.fcmTokenNotifier.value;
      Debug.msg('[FCM] Token loaded from preferences: "$token"');
      return true;
    }

    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          final webOptions = _getWebFirebaseOptions();
          Debug.msg('[FCM] Initializing Firebase for Web (webOptions found: ${webOptions != null})...');
          if (webOptions != null) {
            await Firebase.initializeApp(options: webOptions);
          } else {
            await Firebase.initializeApp(
              options: const FirebaseOptions(
                apiKey: "AIzaSyDv63cLTJEOcGFz1sxvQj3BF_4KCbg4p-E",
                authDomain: "iccmeu-app.firebaseapp.com",
                projectId: "iccmeu-app",
                storageBucket: "iccmeu-app.firebasestorage.app",
                messagingSenderId: "458814741758",
                appId: "1:458814741758:web:b883d625127fde92cdd9af",
              ),
            );
          }
        } else {
          Debug.msg('[FCM] Initializing Firebase native app...');
          await Firebase.initializeApp();
        }
      }

      messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.getNotificationSettings();
      Debug.msg('[FCM] Current notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined && userGesture) {
        Debug.msg('[FCM] Requesting notification permissions...');
        settings = await messaging.requestPermission();
        Debug.msg('[FCM] Permission request result: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final vapidKey = _getWebVapidKey() ??
            "BGEz4g_2DgMpiDTsZo6i36iFJOM3nZvOKf_KR_EliLRzJWDmgc25hooKJBoGtlzj-0CaQbs9gVkeOuqEaoPsgTY";
        Debug.msg('[FCM] Fetching token with vapidKey="$vapidKey"...');
        String? fetchedToken = await messaging.getToken(
          vapidKey: vapidKey,
          serviceWorkerScriptPath: kIsWeb ? 'firebase-messaging-sw.js' : null,
        );
        Debug.msg('[FCM] messaging.getToken result: "$fetchedToken"');
        if (fetchedToken != null && fetchedToken.isNotEmpty) {
          token = fetchedToken;
          await PreferencesProvider.setFcmToken(fetchedToken);
          Debug.msg('[FCM] Saved new FCM token to preferences: "$token"');
        }
      } else {
        Debug.msg('[FCM] Notification permissions not granted, cannot fetch FCM token.');
      }
    } catch (e) {
      Debug.msg('[FCM] Exception fetching FCM token: $e');
    }

    return false;
  }

  static Future<bool> subscribeToTopic(String topic, {bool userGesture = false}) async {
    if (!supportedPlatform) {
      return false;
    }
    final normalizedTopic = normalizeTopic(topic);
    Debug.msg('[FCM] subscribeToTopic called for topic="$topic" (normalized="$normalizedTopic")');
    await _ensureToken(userGesture: userGesture);
    if (token == null || token!.isEmpty) {
      Debug.msg('[FCM] Cannot subscribe to topic "$topic": No FCM token available.');
      return false;
    }
    try {
      final url = Uri.parse('$_cleanBackendUrl/subscribe');
      Debug.msg('[FCM] Posting to subscribe endpoint: $url (token="$token", topic="$normalizedTopic")');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'topic': normalizedTopic,
        }),
      );
      if (res.statusCode == 200) {
        Debug.msg('[FCM] Subscribe SUCCESS for topic "$topic" ($normalizedTopic): HTTP ${res.statusCode}');
        return true;
      } else {
        Debug.msg('[FCM] Subscribe FAILED for topic "$topic" ($normalizedTopic): HTTP ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      Debug.msg('[FCM] Subscribe EXCEPTION for topic "$topic" ($normalizedTopic): $e');
      return false;
    }
  }

  static Future<bool> unsubscribeFromTopic(String topic, {bool userGesture = false}) async {
    if (!supportedPlatform) {
      return false;
    }
    final normalizedTopic = normalizeTopic(topic);
    Debug.msg('[FCM] unsubscribeFromTopic called for topic="$topic" (normalized="$normalizedTopic")');
    if (normalizedTopic == FcmNotificationsService.normalizedDefault) {
      Debug.msg('[FCM] Rejected unsubscription from default topic "$topic".');
      return false;
    }
    await _ensureToken(userGesture: userGesture);
    if (token == null || token!.isEmpty) {
      Debug.msg('[FCM] Cannot unsubscribe from topic "$topic": No FCM token available.');
      return false;
    }
    try {
      final url = Uri.parse('$_cleanBackendUrl/unsubscribe');
      Debug.msg('[FCM] Posting to unsubscribe endpoint: $url (token="$token", topic="$normalizedTopic")');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'topic': normalizedTopic,
        }),
      );
      if (res.statusCode == 200) {
        Debug.msg('[FCM] Unsubscribe SUCCESS for topic "$topic" ($normalizedTopic): HTTP ${res.statusCode}');
        return true;
      } else {
        Debug.msg('[FCM] Unsubscribe FAILED for topic "$topic" ($normalizedTopic): HTTP ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      Debug.msg('[FCM] Unsubscribe EXCEPTION for topic "$topic" ($normalizedTopic): $e');
      return false;
    }
  }

  List<String> getTopics([TracksProvider? tracksProvider])
  {
    _topics = [defaultTopic];
    //if (kDebugMode) {
      if (!_topics.contains(testTopic)) {
        _topics.add(testTopic);
      }
    //}
    if (tracksProvider != null) {
      for (var track in tracksProvider.items()) {
        if (track.name.isNotEmpty && !_topics.contains(track.name)) {
          _topics.add(track.name);
        }
      }
    }
    _topics.sort();
    return _topics;
  }

  static Future<bool> sendMessage({
    required String topic,
    required String title,
    required String messageText,
    required String author,
    required String secret,
  }) async {
    if (!supportedPlatform) {
      return false;
    }
    final normalizedTopic = normalizeTopic(topic);
    Debug.msg('[FCM] sendMessage called: topic="$topic" (normalized="$normalizedTopic"), title="$title", text="$messageText", author="$author"');
    try {
      final url = Uri.parse('$_cleanBackendUrl/send');
      Debug.msg('[FCM] Posting to send endpoint: $url');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': normalizedTopic,
          'title': title,
          'messageText': messageText,
          'author': author,
          'secret': secret,
        }),
      );
      if (res.statusCode == 200) {
        Debug.msg('[FCM] Send message SUCCESS from backend: HTTP ${res.statusCode}');
        return true;
      } else {
        Debug.msg('[FCM] Send message FAILED from backend: HTTP ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      Debug.msg('[FCM] Send message EXCEPTION: $e');
      return false;
    }
  }
}
