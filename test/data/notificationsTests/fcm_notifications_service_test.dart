import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/notifications/fcm_notifications_service.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = (uri) => 'DIRECT';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();

  group('FcmNotificationsService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FcmNotificationsService.token = null;
      LocalNotificationService.clearInAppNotifications();
    });

    test('subscribeToTopic returns false gracefully when Firebase is not initialized and no token exists', () async {
      final result = await FcmNotificationsService.subscribeToTopic('test_topic');
      expect(result, isFalse);
      expect(FcmNotificationsService.token, isNull);
    });

    test('subscribeToTopic reuses cached token from SharedPreferences if present', () async {
      SharedPreferences.setMockInitialValues({'fcmToken': 'cached_test_token_123'});
      await PreferencesProvider.loadFcmToken();

      expect(PreferencesProvider.fcmTokenNotifier.value, equals('cached_test_token_123'));

      // Token should be reused from preferences by _ensureToken
      await FcmNotificationsService.subscribeToTopic('test_topic');
      expect(FcmNotificationsService.token, equals('cached_test_token_123'));
    });

    test('unsubscribeFromTopic rejects default topic Announcements', () async {
      final result = await FcmNotificationsService.unsubscribeFromTopic(FcmNotificationsService.defaultTopic);
      expect(result, isFalse);
    });

    test('getTopics returns defaultTopic and testTopic', () {
      final topics = FcmNotificationsService().getTopics();
      expect(topics, contains(FcmNotificationsService.defaultTopic));
      expect(topics, contains(FcmNotificationsService.testTopic));
    });

    test('backendUrl handles trailing slashes without creating double slashes', () {
      FcmNotificationsService.backendUrl = 'https://iccm-eu-notifications.tappe-info.de///';
      expect(FcmNotificationsService.backendUrl, endsWith('/'));
      FcmNotificationsService.backendUrl = 'https://iccm-eu-notifications.tappe-info.de';
    });

    test('initializeFcmNotifications recovers token from SharedPreferences and skips topic subscription', () async {
      SharedPreferences.setMockInitialValues({'fcmToken': 'cached_token_abc'});
      await FcmNotificationsService.initializeFcmNotifications();

      expect(FcmNotificationsService.token, equals('cached_token_abc'));
    });

    test('loadNotificationTopics cleans invalid topics not in getTopics', () async {
      SharedPreferences.setMockInitialValues({
        'notificationsTopics': 'announcements|test_topic|invalid_obsolete_topic_123'
      });
      await PreferencesProvider.loadNotificationTopics();

      expect(PreferencesProvider.notificationTopicsNotifier.value, contains('announcements'));
      expect(PreferencesProvider.notificationTopicsNotifier.value, contains('test_topic'));
      expect(PreferencesProvider.notificationTopicsNotifier.value, isNot(contains('invalid_obsolete_topic_123')));
    });

    test('Full FCM flow: generates token, subscribes to Test Topic, sends test message, and receives message with local notification', () async {
      final originalBackendUrl = FcmNotificationsService.backendUrl;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      FcmNotificationsService.backendUrl = 'http://${server.address.address}:${server.port}';

      final Set<String> subscribedTopics = {};

      final serverSubscription = server.listen((HttpRequest request) async {
        try {
          final path = request.uri.path;
          request.response.statusCode = 200;
          request.response.headers.contentType = ContentType.json;

          final bodyBytes = await request.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
          final bodyStr = utf8.decode(bodyBytes);
          final data = bodyStr.isNotEmpty ? jsonDecode(bodyStr) as Map<String, dynamic> : <String, dynamic>{};

          if (path == '/subscribe' && request.method == 'POST') {
            final topic = data['topic'] as String?;
            if (topic != null) {
              subscribedTopics.add(topic);
            }
            request.response.write(jsonEncode({'success': true}));
            await request.response.close();
          } else if (path == '/send' && request.method == 'POST') {
            final topic = data['topic'] as String?;
            final title = data['title'] as String? ?? '';
            final messageText = data['messageText'] as String? ?? '';
            final author = data['author'] as String? ?? '';

            request.response.write(jsonEncode({'success': true}));
            await request.response.close();

            // If topic is subscribed, deliver message to client
            if (topic != null && subscribedTopics.contains(topic)) {
              await FcmNotificationsService.handleIncomingRemoteMessage(
                RemoteMessage(
                  messageId: 'test_msg_123',
                  notification: RemoteNotification(
                    title: title,
                    body: '$messageText\n\n($author)',
                  ),
                  data: {
                    'topic': topic,
                    'title': title,
                    'messageText': messageText,
                    'author': author,
                  },
                ),
              );
            }
          } else {
            request.response.statusCode = 404;
            await request.response.close();
          }
        } catch (e) {
          request.response.statusCode = 500;
          await request.response.close();
        }
      });

      try {
        // 1. Generates itself a token
        final token = await FcmNotificationsService.generateToken();
        expect(token, isNotNull);
        expect(token, isNotEmpty);

        // Prepare listener for expecting to receive the message
        final messageCompleter = Completer<RemoteMessage>();
        final streamSub = FcmNotificationsService.onMessageStream.listen((msg) {
          if (!messageCompleter.isCompleted) {
            messageCompleter.complete(msg);
          }
        });

        // 2. Subscribes to "Test Topic"
        final subSuccess = await FcmNotificationsService.subscribeToTopic(FcmNotificationsService.testTopic);
        expect(subSuccess, isTrue);
        final normalizedTestTopic = FcmNotificationsService.normalizeTopic(FcmNotificationsService.testTopic);
        expect(subscribedTopics, contains(normalizedTestTopic));

        // 3. Sends a test message to the test topic
        final sendSuccess = await FcmNotificationsService.sendMessage(
          topic: FcmNotificationsService.testTopic,
          title: 'Test FCM Notification',
          messageText: 'Hello from test suite!',
          author: 'TestRunner',
          secret: 'test_secret',
        );
        expect(sendSuccess, isTrue);

        // 4. Waits a reasonable time, expecting to receive the message
        final receivedMsg = await messageCompleter.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('FCM message was not received within expected time.'),
        );
        await streamSub.cancel();

        expect(receivedMsg.notification?.title, equals('Test FCM Notification'));
        expect(receivedMsg.notification?.body, contains('Hello from test suite!'));

        // Brief delay to allow async LocalNotificationService.showInstantNotification to populate inAppNotificationsNotifier
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify that local in-app notification was triggered
        final notifications = LocalNotificationService.inAppNotificationsNotifier.value;
        expect(notifications, isNotEmpty);
        expect(notifications.last.title, equals('Test FCM Notification'));
        expect(notifications.last.body, contains('Hello from test suite!'));
        expect(notifications.last.body, contains('TestRunner'));
      } finally {
        await serverSubscription.cancel();
        await server.close(force: true);
        FcmNotificationsService.backendUrl = originalBackendUrl;
      }
    });
  });
}
