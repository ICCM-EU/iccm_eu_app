import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/utils/countdown_functions.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';
import 'package:provider/provider.dart';

class AppBarCountdown extends StatefulWidget {
  const AppBarCountdown({super.key});

  @override
  State<AppBarCountdown> createState() => _AppBarCountdownState();
}

class _AppBarCountdownState extends State<AppBarCountdown> {
  Timer? _timer;
  late DateTime? _nextEventTime = DateTime.now();
  Duration _remainingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    int seconds = 1;
    if (_nextEventTime!.difference(DateTime.now()).inDays > 0) {
      seconds = 60;
    }

    // Set state already now, not only in 1 second.
    setState(() {
      if (_nextEventTime == null) {
        _remainingDuration = Duration.zero;
      } else {
        _remainingDuration = _nextEventTime!.difference(DateTime.now());
      }
    });

    _timer = Timer.periodic(Duration(seconds: seconds), (timer) {
      setState(() {
        if (_nextEventTime == null) {
          _remainingDuration = Duration.zero;
        } else {
          _remainingDuration = _nextEventTime!.difference(DateTime.now());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final EventsProvider eventsProvider = Provider.of<EventsProvider>(context);
    _nextEventTime = eventsProvider.nextStartTime();
    int colorIndex = CountdownFunctions.colors.length - 1;
    if (_nextEventTime != null) {
      colorIndex = min(CountdownFunctions.colors.length - 1,
          _remainingDuration.inMinutes);
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CountdownFunctions.colors[colorIndex]
            .primary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).secondaryHeaderColor,
          width: 2.0,
        ),
      ),
      child: Text(DateFunctions.formatDuration(_remainingDuration),
        style: TextStyle(
          color: CountdownFunctions
              .colors[colorIndex].secondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}