import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/expand_content_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/utils/countdown_functions.dart';
import 'package:iccm_eu_app/utils/date_functions.dart';

import 'package:provider/provider.dart';

import '../data/model/event_data.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  CountdownPageState createState() => CountdownPageState();
}

class CountdownPageState extends State<CountdownPage> {
  String? _selectedRoom; // Store the selected room for filtering
  Timer? _timer;
  late List<EventData> _currentEvents = [];
  late List<EventData> _upcomingEvents = [];
  late DateTime? _nextEventTime = DateTime.now();
  Duration _remainingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSelectedRoom();
    _startTimer();
    Provider.of<ExpandContentProvider>(context, listen: false).
      setIsExpanded(true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedRoom() async {
    String? currentFilter = await PreferencesProvider.timerRoomFilter;
    if (currentFilter.isEmpty) {
      currentFilter = null;
    }
    setState(() {
      _selectedRoom = currentFilter;
    }); // Trigger a rebuild after updating
  }

  void _startTimer() {
    int seconds = 1;
    if (_nextEventTime!.difference(DateTime.now()).inDays > 0) {
      seconds = 60;
    }
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
    final RoomsProvider roomsProvider = Provider.of<RoomsProvider>(context);
    final EventsProvider eventsProvider = Provider.of<EventsProvider>(context);
    _currentEvents = eventsProvider.currentEvents(room: _selectedRoom);
    _upcomingEvents = eventsProvider.nextEvents(room: _selectedRoom);
    _nextEventTime = eventsProvider.nextStartTime(room: _selectedRoom);
    int colorIndex = CountdownFunctions.colors.length - 1;
    if (_nextEventTime != null) {
      colorIndex = min(CountdownFunctions.colors.length - 1,
          _remainingDuration.inMinutes);
    }
    List<String> roomNames = roomsProvider.items().map(
            (item) => item.name).toList();
    if (!roomNames.contains(_selectedRoom)) {
      _selectedRoom = null;
    }
    const TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    return Consumer<ExpandContentProvider>(
      builder: (context, expandContentProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black, // Set Scaffold background to black
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove default back button
            backgroundColor: Colors.black, // Set AppBar background to black
            actions: [
              DropdownButton<String>(
                value: _selectedRoom,
                onChanged: (String? newValue) {
                  PreferencesProvider.setTimerRoomFilter(newValue ?? '');
                  setState(() {
                    _selectedRoom = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'All Rooms',
                      style: TextStyle(
                        color: Colors.grey.shade700, // Use the custom color
                      ),
                    ),
                  ),
                  ...roomsProvider.items().map((room) =>
                      DropdownMenuItem<String>(
                        value: room.name,
                        child: Text(
                          room.name,
                          style: TextStyle(
                            color: Colors.grey.shade700, // Use the custom color
                          ),
                        ),
                      )),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade700,
                ),
                onPressed: () {
                  expandContentProvider.setIsExpanded(false);
                  Navigator.pop(context); // Close fullscreen page
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1, // Adjust flex as needed
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9, // 90% width
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.2, // 30% height
                    child: ListView.builder(
                      itemCount: _currentEvents.length,
                      itemBuilder: (context, index) {
                        final event = _currentEvents[index];
                        if (_selectedRoom != null &&
                            event.room != _selectedRoom) {
                          // Skip events not matching the filter
                          return const SizedBox.shrink();
                        }
                        return ListTile(
                          title: Text(event.title,
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge
                                ?.merge(whiteTextStyle),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // ----------------------------------------------------
                Expanded(
                  flex: 1, // Adjust flex as needed
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.6,
                    child: Container(
                      // 90% window width
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.9,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CountdownFunctions.colors[colorIndex]
                            .primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: OrientationBuilder(
                          builder: (context, orientation) {
                            return Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                // fit: orientation == Orientation.portrait ?
                                //     BoxFit.fitWidth :
                                //     BoxFit.fitHeight,
                                child:
                                (_nextEventTime != null) ?
                                Text(
                                  DateFunctions.formatDuration(
                                      _remainingDuration),
                                  style: TextStyle(
                                    color: CountdownFunctions
                                        .colors[colorIndex].secondary,
                                  ),
                                )
                                    : Text(''),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
                // ----------------------------------------------------
                Expanded(
                  flex: 1, // Adjust flex as needed
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.9, // 90% width
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.2, // 30% height
                    child: ListView.builder(
                      itemCount: _upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = _upcomingEvents[index];
                        if (_selectedRoom != null &&
                            event.room != _selectedRoom) {
                          return const SizedBox
                              .shrink(); // Skip events not matching the filter
                        }
                        return ListTile(
                          title: Text(event.title,
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge
                                ?.merge(whiteTextStyle),
                          ),
                          leading: Text(
                            '${event.start.hour.toString().padLeft(2, '0')}:'
                                '${event.start.minute.toString().padLeft(
                                2, '0')}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge
                                ?.merge(whiteTextStyle),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
