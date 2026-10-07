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
    if (_listenersConfigured) return;
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground FCM message received: ${message.messageId}');
        handleIncomingRemoteMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM message opened app: ${message.messageId}');
        handleIncomingRemoteMessage(message);
      });

      _listenersConfigured = true;
    } catch (e) {
      debugPrint('Could not set up FirebaseMessaging listeners: $e');
    }
  }

  static Future<void> handleIncomingRemoteMessage(RemoteMessage message) async {
    _messageStreamController.add(message);

    final String title = message.notification?.title ?? message.data['title'] ?? 'Announcement';
    final String bodyText = message.notification?.body ?? message.data['messageText'] ?? message.data['body'] ?? '';
    final String author = message.data['author'] ?? '';

    String fullBody = bodyText;
    if (author.isNotEmpty && !fullBody.contains('($author)')) {
      fullBody = '$fullBody\n\n($author)';
    }

    if (title.isNotEmpty || fullBody.isNotEmpty) {
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
    if (!supportedPlatform) {
      debugPrint('FCM notifications not supported on this platform.');
      return;
    }
    _setupMessageListeners();
    try {
      final tokenRecoveredFromPrefs = await _ensureToken(userGesture: userGesture);

      if (token != null && token!.isNotEmpty) {
        if (tokenRecoveredFromPrefs) {
          debugPrint('FCM token recovered from preferences.');
          // Do not omit subscription as long as test mode simulates the behavior.
          // return;
        }

        // Subscribe to the saved topics through the Backend-Endpoint
        try {
          await PreferencesProvider.loadNotificationTopics(tracksProvider);
          for (String topic in PreferencesProvider.notificationTopicsNotifier.value) {
            if (topic.isNotEmpty) {
              await subscribeToTopic(topic, userGesture: userGesture);
            }
          }
          // ensure to unsubscribe from test topic when not listed in preferences
          final normalizedTestTopic = normalizeTopic(testTopic);
          if (!PreferencesProvider.notificationTopicsNotifier.value.contains(normalizedTestTopic)) {
            await unsubscribeFromTopic(normalizedTestTopic, userGesture: userGesture);
          }
        } catch (e) {
          debugPrint('Error sending token to server during registration: $e');
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
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
      debugPrint('Error reading window.firebaseConfig: $e');
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
      debugPrint('Error reading vapidKey from window.firebaseConfig: $e');
    }
    return null;
  }

  static Future<bool> _ensureToken({bool userGesture = false}) async {
    if (token != null && token!.isNotEmpty) {
      return false;
    }

    await PreferencesProvider.loadFcmToken();
    if (PreferencesProvider.fcmTokenNotifier.value.isNotEmpty) {
      token = PreferencesProvider.fcmTokenNotifier.value;
      return true;
    }

    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          final webOptions = _getWebFirebaseOptions();
          if (webOptions != null) {
            await Firebase.initializeApp(options: webOptions);
          } else {
            // Fallback default options
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
          await Firebase.initializeApp();
        }
      }

      messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined && userGesture) {
        settings = await messaging.requestPermission();
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final vapidKey = _getWebVapidKey() ??
            "BGEz4g_2DgMpiDTsZo6i36iFJOM3nZvOKf_KR_EliLRzJWDmgc25hooKJBoGtlzj-0CaQbs9gVkeOuqEaoPsgTY";
        String? fetchedToken = await messaging.getToken(
          vapidKey: vapidKey,
          serviceWorkerScriptPath: kIsWeb ? 'firebase-messaging-sw.js' : null,
        );
        if (fetchedToken != null && fetchedToken.isNotEmpty) {
          token = fetchedToken;
          await PreferencesProvider.setFcmToken(fetchedToken);
        }
      }
    } catch (e) {
      debugPrint('FCM token not available on this platform/device: $e');
    }

    return false;
  }

  static Future<bool> subscribeToTopic(String topic, {bool userGesture = false}) async {
    if (!supportedPlatform) {
      return false;
    }
    final normalizedTopic = normalizeTopic(topic);
    await _ensureToken(userGesture: userGesture);
    if (token == null || token!.isEmpty) {
      debugPrint('Cannot subscribe to topic $topic: No FCM token available on this platform/device.');
      return false;
    }
    try {
      final url = Uri.parse('$_cleanBackendUrl/subscribe');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'topic': normalizedTopic,
        }),
      );
      if (res.statusCode == 200) {
        debugPrint('Subscribe response from server for topic $topic ($normalizedTopic): ${res.statusCode}');
        return true;
      } else {
        debugPrint('Error subscribing to topic $topic ($normalizedTopic): ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error subscribing to topic $topic ($normalizedTopic): $e');
      return false;
    }
  }

  static Future<bool> unsubscribeFromTopic(String topic, {bool userGesture = false}) async {
    if (!supportedPlatform) {
      return false;
    }
    final normalizedTopic = normalizeTopic(topic);
    if (normalizedTopic == FcmNotificationsService.normalizedDefault) {
      debugPrint('Error rejected unsubscription from default topic $topic.');
      return false;
    }
    await _ensureToken(userGesture: userGesture);
    if (token == null || token!.isEmpty) {
      debugPrint('Cannot unsubscribe from topic $topic ($normalizedTopic): No FCM token available on this platform/device.');
      return false;
    }
    try {
      final url = Uri.parse('$_cleanBackendUrl/unsubscribe');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'topic': normalizedTopic,
        }),
      );
      if (res.statusCode == 200) {
        debugPrint('Unsubscribe response from server for topic $topic ($normalizedTopic): ${res.statusCode}');
        return true;
      } else {
        debugPrint('Error unsubscribing from topic $topic ($normalizedTopic): ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic ($normalizedTopic): $e');
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
    try {
      final url = Uri.parse('$_cleanBackendUrl/send');
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
        debugPrint('Send message response from server: ${res.statusCode}');
        return true;
      } else {
        debugPrint('Error sending message: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }
}