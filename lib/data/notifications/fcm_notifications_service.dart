import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';

class FcmNotificationsService {
  static const String sep = "|";
  static final String defaultTopic = "Announcements";
  static List<String> _topics = [defaultTopic];

  // Called directly on start without a login.
  static Future<void> initializeFcmNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Check permissions (Necessary for PWA in the browser!)
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Generate anonymous Web-Push-Token
        // The VAPID-Key-Certificate is generated in the Firebase Console Web-Tab
        String? token = await messaging.getToken(
          //vapidKey: "YOUR_PUBLIC_WEB_PUSH_VAPID_KEY"
            vapidKey: "BGEz4g_2DgMpiDTsZo6i36iFJOM3nZvOKf_KR_EliLRzJWDmgc25hooKJBoGtlzj-0CaQbs9gVkeOuqEaoPsgTY"
        );

        if (token != null) {
          // 3. Send token to your Server-Endpoint
          final url = Uri.parse('https://iccm-eu-notifications.tappe-info.de');
          await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
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
}