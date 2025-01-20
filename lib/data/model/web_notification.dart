import 'dart:async';

import 'dart:html';
import 'dart:js_util';

import 'package:flutter/foundation.dart';

class WebNotification {
  final DateTime timeout;
  final String title;
  final String msg;
  late Timer _timer;

  WebNotification({
    required this.timeout,
    required this.title,
    required this.msg,
  }) {
    DateTime now = DateTime.now();
    if (timeout.isAfter(now)) {
      _timer = Timer(timeout.difference(now), _displayMessage);
    }
  }

  //@override
  void dispose() {
    _timer.cancel();
    //super.dispose();
  }

  void _displayMessage() {
    if (kIsWeb) {
      callMethod(
          window,
          "showNotification",
          [
            title,
            msg
          ]);
    //} else {
    //  flutterLocalNotificationsPlugin.show(id,"Title","custom message",notification);
    }
    _timer.cancel();
  }
}