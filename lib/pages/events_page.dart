import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/components/event_list_tile.dart';
import 'package:iccm_eu_app/components/page_title.dart';
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
  late bool _futureEvents = true;

  @override
  void initState() {
    super.initState();
    _loadIsDayView();
    _loadEventListFilter();
  }

  Future<void> _loadIsDayView() async {
    _isDayView = await PreferencesProvider.isDayView;
    setState(() {}); // Trigger a rebuild after updating _isDayView
  }

  Future<void> _loadEventListFilter() async {
    _futureEvents = await PreferencesProvider.futureEvents;
    setState(() {}); // Trigger a rebuild after updating _isDayView
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          _isDayView ? const SizedBox.shrink() :
          IconButton(
            icon: Icon(_futureEvents ? Icons.filter_alt : Icons.filter_alt_off),
            onPressed: () {
              setState(() {
                _futureEvents = !_futureEvents;
                PreferencesProvider.setFutureEvents(_futureEvents);
              });
            },
            tooltip: 'Filter only future events',
          ),
          IconButton(
            icon: Icon(_isDayView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isDayView = !_isDayView;
                PreferencesProvider.setIsDayView(_isDayView);
              });
            },
          ),
        ],
      ),
      body: _isDayView ? DayViewCalendar() : EventList(futureEvents: _futureEvents),
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
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        Expanded(
          child: Consumer<EventsProvider>(
            builder: (context, itemList, child) {
              DateTime current = itemList.earliestEvent().start;
              // Normalize to start of day
              current.subtract(Duration(
                hours: current.hour,
                minutes: current.minute,
                seconds: current.second,
              ));
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
                    events: Provider.of<EventsProvider>(context).items().map((
                        item) {
                      Color? backgroundColor = Colors.red;
                      Color? textColor = Colors.black;
                      if (builderValue) {
                        if (item.room != null) {
                          final roomsProvider = Provider.of<RoomsProvider>(
                              context, listen: false);
                          final room = roomsProvider.getDataByName(
                              item.room!.text.toString());
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
                              item.track!.text.toString());
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
                    userZoomable: true,
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
  late bool _futureEvents = false;

  @override
  void didUpdateWidget(EventList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureEvents != widget.futureEvents) {
      _futureEvents = widget.futureEvents; // Update local variable if futureEvents changed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView(
            shrinkWrap: true, // Important to prevent unbounded height issues
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for static list
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: const <Widget>[
              PageTitle(title: 'Events'),
            ]
        ),
        Expanded( // Use Expanded to allow ListView.builder to take available space
          child: Consumer<EventsProvider>( // Wrap ListView.builder with Consumer
            builder: (context, itemList, child) {
              List<EventData> items;
              if (_futureEvents) {
                items = itemList.filterPastEvents();
              } else {
                items = itemList.items();
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return EventListTile(item: items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}