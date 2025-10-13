import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/app_bar_countdown.dart';
import 'package:iccm_eu_app/components/event_list.dart';
import 'package:iccm_eu_app/components/event_day_view_calendar.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:provider/provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late bool _isDayView = true;

  @override
  void initState() {
    super.initState();
    _loadIsDayView();
    _loadEventListFilter();
  }

  Future<void> _loadIsDayView() async {
    bool value = await PreferencesProvider.isDayView;
    setState(() {
      _isDayView = value;
    });
  }

  Future<void> _loadEventListFilter() async {
    await PreferencesProvider.loadFutureEvents();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PreferencesProvider.futureEventsNotifier,
      builder: (context, futureEvents, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Events'),
                Flexible( // Center the remaining space
                  child: SizedBox.shrink(),
                ),
                AppBarCountdown(),
                Flexible(
                  child: SizedBox.shrink(),
                )
              ],
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Theme
                .of(context)
                .appBarTheme
                .backgroundColor,
            foregroundColor: Theme
                .of(context)
                .appBarTheme
                .foregroundColor,
            actions: [
              _isDayView ? const SizedBox.shrink() :
              IconButton(
                icon: Icon(
                    futureEvents ? Icons.filter_alt : Icons.filter_alt_off),
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface,
                onPressed: () {
                  futureEvents = !futureEvents;
                  PreferencesProvider.setFutureEvents(futureEvents);
                },
                tooltip: 'Filter only future events',
              ),
              Consumer<ExpandContentProvider>(
                builder: (context, fullscreenProvider, child) {
                  return IconButton(
                    icon: Icon(
                        fullscreenProvider.isExpanded ?
                        Icons.close_fullscreen :
                        Icons.open_in_full),
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                    onPressed: () {
                      fullscreenProvider.toggleExpanded();
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(_isDayView ? Icons.list : Icons.calendar_today),
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface,
                onPressed: () {
                  setState(() {
                    _isDayView = !_isDayView;
                    PreferencesProvider.setIsDayView(_isDayView);
                  });
                },
              ),
            ],
          ),
          body: _isDayView ? EventDayViewCalendar() : EventList(
              futureEvents: futureEvents),
        );
      },
    );
  }
}
