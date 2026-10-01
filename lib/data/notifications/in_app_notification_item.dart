import 'dart:async';
import 'package:flutter/material.dart';

class InAppNotificationItem {
  final String id;
  final String title;
  final String body;
  final Color? backgroundColor;
  final DateTime createdAt;
  Timer? _timer;

  InAppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.backgroundColor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void startTimer(VoidCallback onTimeout) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 15), onTimeout);
  }

  void dispose() {
    _timer?.cancel();
  }
}