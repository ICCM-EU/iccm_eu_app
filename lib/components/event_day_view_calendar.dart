import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:provider/provider.dart';

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class EventDayViewCalendar extends StatefulWidget {
  final VoidCallback? onDateChanged;

  const EventDayViewCalendar({
    super.key,
    this.onDateChanged,
  });

  @override
  EventDayViewCalendarState createState() => EventDayViewCalendarState();
}

class EventDayViewCalendarState extends State<EventDayViewCalendar> {
  DateTime? _selectedDate;
  List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (canGoPrevious) {
          previousDay();
          return true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (canGoNext) {
          nextDay();
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _loadPreferences() async {
    PreferencesProvider.loadCalendarColorByRoom();
    PreferencesProvider.loadUseTestData();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _findDateIndex(DateTime target) {
    for (int i = 0; i < _dates.length; i++) {
      if (_isSameDay(_dates[i], target)) {
        return i;
      }
    }
    return -1;
  }

  bool get canGoPrevious {
    if (_dates.isEmpty || _selectedDate == null) return false;
    int index = _findDateIndex(_selectedDate!);
    return index > 0;
  }

  bool get canGoNext {
    if (_dates.isEmpty || _selectedDate == null) return false;
    int index = _findDateIndex(_selectedDate!);
    return index != -1 && index < _dates.length - 1;
  }

  void previousDay() {
    if (_dates.isEmpty || _selectedDate == null) return;
    int index = _findDateIndex(_selectedDate!);
    if (index > 0) {
      setState(() {
        _selectedDate = _dates[index - 1];
      });
      widget.onDateChanged?.call();
    }
  }

  void nextDay() {
    if (_dates.isEmpty || _selectedDate == null) return;
    int index = _findDateIndex(_selectedDate!);
    if (index != -1 && index < _dates.length - 1) {
      setState(() {
        _selectedDate = _dates[index + 1];
      });
      widget.onDateChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

                bool datesChanged = _dates.length != dates.length;
                _dates = dates;

                DateTime now = DateTime.now();
                if (_selectedDate == null) {
                  DateTime initialTime = now;
                  if (initialTime.isBefore(itemList.earliestEvent().start)) {
                    initialTime = itemList.earliestEvent().start;
                  } else if (initialTime.isAfter(itemList.latestEvent().end)) {
                    initialTime = itemList.latestEvent().end;
                  }
                  _selectedDate = DateTime(initialTime.year, initialTime.month, initialTime.day);
                  datesChanged = true;
                }

                if (datesChanged && widget.onDateChanged != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      widget.onDateChanged!();
                    }
                  });
                }

                DateTime targetInitialTime = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  now.hour,
                  now.minute,
                );

                return ValueListenableBuilder<bool>(
                    valueListenable: PreferencesProvider.calendarColorByRoomNotifier,
                    builder: (context, builderValue, child) {
                      return ScrollConfiguration(
                        behavior: MouseDragScrollBehavior(),
                        child: WeekView(
                          key: ValueKey(_selectedDate),
                          minimumTime: const TimeOfDay(hour: 7, minute: 0),
                          maximumTime: const TimeOfDay(hour: 23, minute: 0),
                          initialTime: targetInitialTime,
                          dates: dates,
                          userZoomable: false,
                            style: WeekViewStyle(
                              dayViewSeparatorColor: theme.colorScheme.tertiary.withAlpha(100),
                            ),
                            dayViewStyleBuilder: (date) => DayViewStyle(
                              backgroundColor: theme.colorScheme.surface,
                              backgroundRulesColor: theme.colorScheme.secondary.withAlpha(40),
                              currentTimeRuleColor: theme.colorScheme.primary,
                              currentTimeCircleColor: theme.colorScheme.primary,
                            ),
                            dayBarStyleBuilder: (date) => DayBarStyle(
                              color: theme.colorScheme.tertiary.withAlpha(60),
                              textStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                            hourColumnStyle: HourColumnStyle(
                              color: theme.colorScheme.surface,
                              textStyle: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // 1. Provide the raw list of events.
                            events: Provider.of<EventsProvider>(context, listen: false).items(),
                            // 2. Use the eventWidgetBuilder with the requested signature.
                            eventWidgetBuilder: (event, height, width) {
                              // The `event` is already the correct type here.
                              final item = event;
                              Color backgroundColor = theme.colorScheme.primaryContainer;
                              Color textColor = theme.colorScheme.onPrimaryContainer;

                              // Logic to determine color based on Room or Track
                              if (builderValue) {
                                if (item.room != null) {
                                  final roomsProvider = Provider.of<RoomsProvider>(context, listen: false);
                                  final room = roomsProvider.getDataByName(item.room!);
                                  if (room?.colors != null) {
                                    backgroundColor = room!.colors!.primary;
                                    textColor = room.colors!.secondary;
                                  }
                                }
                              } else {
                                if (item.track != null) {
                                  final tracksProvider = Provider.of<TracksProvider>(context, listen: false);
                                  final track = tracksProvider.getDataByName(item.track!);
                                  if (track?.colors != null) {
                                    backgroundColor = track!.colors!.primary;
                                    textColor = track.colors!.secondary;
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
                                child: Container(
                                  height: height,
                                  width: width,
                                  margin: const EdgeInsets.all(1.0),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: textColor.withAlpha(40),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(12),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: 4.0,
                                          color: textColor.withAlpha(180),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: height < 30 ? 1.0 : 4.0,
                                            ),
                                            child: ClipRect(
                                              child: SingleChildScrollView(
                                                physics: const NeverScrollableScrollPhysics(),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: height < 30 ? 10.0 : 12.0,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: height > 55 ? 2 : 1,
                                                    ),
                                                    if (height > 55 && (item.room != null || item.track != null)) ...[
                                                      const SizedBox(height: 2.0),
                                                      Text(
                                                        builderValue ? (item.room ?? '') : (item.track ?? ''),
                                                        style: TextStyle(
                                                          color: textColor.withAlpha(200),
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 10.0,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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