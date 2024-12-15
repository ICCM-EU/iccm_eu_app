import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';

class NextEventNotifier {
  static final ValueNotifier<DateTime?> nextEventNotifier = ValueNotifier(null);

  static Timer? _timer;

  static void startTimer(EventsProvider eventsProvider) {
    if (_timer != null) {
      return;
    }

    // Initial update
    nextEventNotifier.value = eventsProvider.nextStartTime();

    stopTimer(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      nextEventNotifier.value = eventsProvider.nextStartTime();
    });
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}