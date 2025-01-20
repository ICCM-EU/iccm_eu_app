import 'dart:async';

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
    _timer.cancel();
  }
}