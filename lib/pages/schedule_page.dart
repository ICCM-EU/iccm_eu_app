import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/components/date_functions.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/components/text_functions.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:provider/provider.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late bool _isDayView = true;
  late bool _futureEvents = true;

  @override
  void initState() {
    super.initState();
    // Call the asynchronous functions
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
  void initState() {
    super.initState();
    Provider.of<EventsProvider>(context, listen: false).loadCache;
    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
    );
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
              return WeekView(
                // dayBarStyleBuilder: Null,
                minimumTime: HourMinute(hour: 7, minute: 0),
                maximumTime: HourMinute(hour: 23, minute: 0),
                initialTime: initialTime,
                dates: dates,
                events: Provider.of<EventsProvider>(context).items().map((item) {
                  Color? backgroundColor = Colors.red;
                  Color? textColor = Colors.black;
                  if (item.track != null) {
                    final tracksProvider = Provider.of<TracksProvider>(
                        context, listen: false);
                    final track = tracksProvider.trackDataByName(item.track!
                        .text.toString());
                    if (track != null && track.colors != null) {
                      backgroundColor = track.colors?.primary;
                      textColor = track.colors?.secondary;
                    }
                  }
                  return EventData(
                    name: item.name,
                    details: item.details,
                    start: item.start,
                    end: item.end,
                    backgroundColor: backgroundColor, // Add other properties as needed
                    textStyle: TextStyle(
                        color: textColor,
                    ),
                    onTap: () {
                      final provider = Provider.of<EventsProvider>(context, listen: false);
                      final eventDetails = provider.items().firstWhere((e) => e == item);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(item: eventDetails),
                        ),
                      );
                    },
                  );
                }).toList(),
                userZoomable: true,
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
  late bool _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = widget.futureEvents;
    Provider.of<EventsProvider>(context, listen: false).loadCache;
    Provider.of<GsheetsProvider>(context, listen: false).fetchData(
      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
    );
  }

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
                  final item = items[index];
                  return ListTile(
                    leading: item.imageUrl!.startsWith("http") ?
                      CachedNetworkImage(
                        imageUrl: item.imageUrl ?? '',
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 50,
                        ),
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ) :
                      const SizedBox(
                        height: 100,
                        width: 100,
                      ),
                    title: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: item.name.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      softWrap: false,
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: DateFunctions().formatDate(
                                date: item.start,
                                format: 'EEE, dd.MM., HH:mm'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\n',
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          TextSpan(
                            text: '\n',
                            style: const TextStyle(
                              fontSize: 4,
                            ),
                          ),
                          TextSpan(
                            text: TextFunctions.cutTextToWords(
                                text: item.details.text,
                                length: 30),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Theme(
                            data: Theme.of(context),
                            child: EventDetailsPage(item: item),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}