import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:provider/provider.dart';

class EventDayViewCalendar extends StatefulWidget {
  const EventDayViewCalendar({super.key});

  @override
  EventDayViewCalendarState createState() => EventDayViewCalendarState();
}

class EventDayViewCalendarState extends State<EventDayViewCalendar> {

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
    return Column(
        children: [
          Expanded(
            child: Consumer<EventsProvider>(
              builder: (context, itemList, child) {
                // Add a check to prevent errors if the item list is initially empty.
                if (itemList.items().isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                DateTime currentDate = itemList.earliestEvent().start;
                currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
                List<EventData> cutoffList = itemList.cutoffAfterDays(days: 16);
                DateTime last = itemList.latestEvent(items: cutoffList).end;

                final dates = <DateTime>[currentDate];
                while (currentDate.isBefore(last)) { // Corrected loop condition
                  currentDate = currentDate.add(const Duration(days: 1));
                  dates.add(currentDate);
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
                        minimumTime: const TimeOfDay(hour: 7, minute: 0),
                        maximumTime: const TimeOfDay(hour: 23, minute: 0),
                        initialTime: initialTime,
                        dates: dates,
                        userZoomable: false,
                        // 1. Provide the raw list of events.
                        events: Provider.of<EventsProvider>(context, listen: false).items(),
                        // 2. Use the eventWidgetBuilder with the requested signature.
                        eventWidgetBuilder: (event, height, width) {
                          // The `event` is already the correct type here.
                          final item = event;
                          Color? backgroundColor = Colors.red;
                          Color? textColor = Colors.black;

                          // Logic to determine color based on Room or Track
                          if (builderValue) {
                            if (item.room != null) {
                              final roomsProvider = Provider.of<RoomsProvider>(context, listen: false);
                              final room = roomsProvider.getDataByName(item.room!);
                              if (room?.colors != null) {
                                backgroundColor = room?.colors?.primary;
                                textColor = room?.colors?.secondary;
                              }
                            }
                          } else {
                            if (item.track != null) {
                              final tracksProvider = Provider.of<TracksProvider>(context, listen: false);
                              final track = tracksProvider.getDataByName(item.track!);
                              if (track?.colors != null) {
                                backgroundColor = track?.colors?.primary;
                                textColor = track?.colors?.secondary;
                              }
                            }
                          }

                          // 3. Return the interactive and styled widget from the builder.
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsPage(item: item),
                                ),
                              );
                            },
                            // Since `position` is no longer provided, we use a simple Container
                            // and let the WeekView handle the positioning.
                            child: Container(
                              height: height,
                              width: width,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(4.0), // Optional: for rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  item.title,
                                  style: TextStyle(color: textColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          );
                        },
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