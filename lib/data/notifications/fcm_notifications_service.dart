import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';

class FcmNotificationsService {
  static const String sep = "|";
  static final String defaultTopic = "Announcements";
  static List<String> _topics = [defaultTopic];
  static late FirebaseMessaging messaging;
  static String? token;
  static String backendUrl = 'https://iccm-eu-notifications.tappe-info.de';

  // Called directly on start without a login.
  static Future<void> initializeFcmNotifications() async {
    try {
      messaging = FirebaseMessaging.instance;

      // 1. Check permissions (Necessary for PWA in the browser!)
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Generate anonymous Web-Push-Token
        // The VAPID-Key-Certificate is generated in the Firebase Console Web-Tab
        token = await messaging.getToken(
          //vapidKey: "YOUR_PUBLIC_WEB_PUSH_VAPID_KEY"
            vapidKey: "BGEz4g_2DgMpiDTsZo6i36iFJOM3nZvOKf_KR_EliLRzJWDmgc25hooKJBoGtlzj-0CaQbs9gVkeOuqEaoPsgTY"
        );

        if (token != null) {
          // 3. Subscribe to the saved topics through the Backend-Endpoint
          try {
            await PreferencesProvider.loadNotificationTopics();
            for (String topic in PreferencesProvider.notificationTopicsNotifier.value) {
              if (topic.isNotEmpty) {
                await subscribeToTopic(topic);
              }
            }
          } catch (e) {
            debugPrint('Error sending token to server during registration: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  static Future<bool> subscribeToTopic(String topic) async {
    if (token != null) {
      try {
        final url = Uri.parse('$backendUrl/subscribe');
        final http.Response res = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': token,
            'topic': topic,
          }),
        );
        if (res.statusCode == 200) {
          debugPrint('Subscribe response from server: ${res.statusCode}');
          return true;
        } else {
          debugPrint('Error subscribing to topic $topic: ${res.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Error subscribing to topic $topic: $e');
        return false;
      }
    } else {
      debugPrint('Error subscribing to topic $topic: No token available.');
      return false;
    }
  }

  static Future<bool> unsubscribeFromTopic(String topic) async {
    if (token != null) {
      if (topic == defaultTopic) {
        debugPrint('Error rejected unsubscription from default topic $topic.');
        return false;
      }
      try {
        final url = Uri.parse('$backendUrl/unsubscribe');
        final http.Response res = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': token,
            'topic': topic,
          }),
        );
        debugPrint('Unsubscribe response from server: ${res.statusCode}');
        return true;
      } catch (e) {
        debugPrint('Error unsubscribing from topic $topic: $e');
        return false;
      }
    } else {
      debugPrint('Error unsubscribing from topic $topic: No token available.');
      return false;
    }
  }

  List<String> getTopics([TracksProvider? tracksProvider])
  {
    _topics = [defaultTopic];
    if (tracksProvider != null) {
      for (var track in tracksProvider.items()) {
        if (track.name.isNotEmpty && !_topics.contains(track.name)) {
          _topics.add(track.name);
        }
      }
    }
    return _topics;
  }

  static Future<bool> sendMessage({
    required String topic,
    required String title,
    required String messageText,
    required String author,
    required String secret,
  }) async {
    try {
      final url = Uri.parse('$backendUrl/send');
      final http.Response res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
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