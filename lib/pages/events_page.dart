import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/components/app_bar_countdown.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/data/appProviders/fullscreen_provider.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
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
              Consumer<FullscreenProvider>(
                builder: (context, fullscreenProvider, child) {
                  return IconButton(
                    icon: Icon(
                        fullscreenProvider.isFullscreen ?
                        Icons.close_fullscreen :
                        Icons.open_in_full),
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                    onPressed: () {
                      fullscreenProvider.toggleFullscreen();
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
          body: _isDayView ? DayViewCalendar() : EventList(
              futureEvents: futureEvents),
        );
      },
    );
  }
}

class DayViewCalendar extends StatefulWidget {
  const DayViewCalendar({super.key});

  @override
  DayViewCalendarState createState() => DayViewCalendarState();
}

class DayViewCalendarState extends State<DayViewCalendar> {

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadCalendarColorByRoom();
    PreferencesProvider.loadUseTestData();
  }

  @override
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        Expanded(
          child: Consumer<EventsProvider>(
            builder: (context, itemList, child) {
              DateTime current = itemList.earliestEvent().start;
              // Normalize to start of day
              current = DateTime(current.year, current.month, current.day);
              List<EventData> cutoffList = itemList.cutoffAfterDays(days: 16);
              DateTime last = itemList.latestEvent(
                items: cutoffList,
              ).end;
              final dates = <DateTime>[current];
              while (current.isBefore(last) ||
                  current.isAtSameMomentAs(last)) {
                current = current.add(const Duration(days: 1));
                dates.add(current);
              }
              DateTime initialTime = DateTime.now();
              if (initialTime.isBefore(itemList.earliestEvent().start)) {
                initialTime = itemList.earliestEvent().start;
              } else if (initialTime.isAfter(itemList.latestEvent().end)) {
                initialTime = itemList.latestEvent().end;
              }
              return ValueListenableBuilder<bool>(
                valueListenable: PreferencesProvider.calendarColorByRoomNotifier,
                builder: (context, builderValue, child) {
                  return WeekView(
                    minimumTime: HourMinute(hour: 7, minute: 0),
                    maximumTime: HourMinute(hour: 23, minute: 0),
                    initialTime: initialTime,
                    dates: dates,
                    userZoomable: false,
                    events: Provider.of<EventsProvider>(context).items().map((
                        item) {
                      Color? backgroundColor = Colors.red;
                      Color? textColor = Colors.black;
                      if (builderValue) {
                        if (item.room != null) {
                          final roomsProvider = Provider.of<RoomsProvider>(
                              context, listen: false);
                          final room = roomsProvider.getDataByName(
                              item.room!);
                          if (room != null && room.colors != null) {
                            backgroundColor = room.colors?.primary;
                            textColor = room.colors?.secondary;
                          }
                        }
                      } else {
                        if (item.track != null) {
                          final tracksProvider = Provider.of<TracksProvider>(
                              context, listen: false);
                          final track = tracksProvider.getDataByName(
                              item.track!);
                          if (track != null && track.colors != null) {
                            backgroundColor = track.colors?.primary;
                            textColor = track.colors?.secondary;
                          }
                        }
                      }
                      return EventData(
                        name: item.name,
                        details: item.details,
                        start: item.start,
                        end: item.end,
                        backgroundColor: backgroundColor,
                        // Add other properties as needed
                        textStyle: TextStyle(
                          color: textColor,
                        ),
                        onTap: () {
                          final provider = Provider.of<EventsProvider>(
                              context, listen: false);
                          final eventDetails = provider.items().firstWhere((
                              e) => e == item);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsPage(item: eventDetails),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
              );
            },
          ),
        ),
      ]
    );
  }
}

class EventList extends StatefulWidget {
  bool get futureEvents => _futureEvents;
  final bool _futureEvents;

  const EventList({
    required bool futureEvents,
    super.key,
  }) : _futureEvents = futureEvents;

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventList> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadFutureEvents();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: ScrollController(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Use Expanded to allow ListView.builder to take available space
            Expanded(
              child: ValueListenableBuilder<bool>(
                  valueListenable: PreferencesProvider.futureEventsNotifier,
                  builder: (context, builderValue, child) {
                    return Consumer<
                        EventsProvider>(
                      builder: (context, itemList, child) {
                        List<EventData> items;
                        if (builderValue) {
                          items = itemList.filterPastEvents();
                        } else {
                          items = itemList.items();
                        }
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: NextEventNotifier.nextEventNotifier,
                          builder: (context, nextEventTime, _) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return EventListTile(item: items[index]);
                              },
                            );
                          },
                        );
                      },
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}