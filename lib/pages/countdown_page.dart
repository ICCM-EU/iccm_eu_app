import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedRoom() async {
    String? currentFilter = await PreferencesProvider.timerRoomFilter;
    if (currentFilter.isEmpty) {
      _selectedRoom = null;
    } else {
      _selectedRoom = currentFilter;
    }
    setState(() {}); // Trigger a rebuild after updating
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
    return Scaffold(
      backgroundColor: Colors.black, // Set Scaffold background to black
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        backgroundColor: Colors.black, // Set AppBar background to black
        actions: [
          DropdownButton<String>(
            value: _selectedRoom,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRoom = newValue;
              });
              PreferencesProvider.setTimerRoomFilter(newValue ?? '');
            },
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                    'All Rooms',
                  style: TextStyle(
                    color: Colors.grey[700], // Use the custom color
                  ),
                ),
              ),
              ...roomsProvider.items().map((room) => DropdownMenuItem<String>(
                value: room.name.text.toString(),
                child: Text(
                  room.name.text.toString(),
                  style: TextStyle(
                    color: Colors.grey[700], // Use the custom color
                  ),
                ),
              )),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[700],
            ),
            onPressed: () {
              Navigator.pop(context); // Close fullscreen page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _currentEvents.length,
              itemBuilder: (context, index) {
                final event = _currentEvents[index];
                if (_selectedRoom != null &&
                    event.room?.text.toString() != _selectedRoom) {
                  // Skip events not matching the filter
                  return const SizedBox.shrink();
                }
                return ListTile(
                  title: Text(event.title),
                );
              },
            ),
          ),
          if (_nextEventTime != null)
            Center(
              child: Container(
                // 90% window width
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child:FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    formatDuration(_remainingDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = _upcomingEvents[index];
                if (_selectedRoom != null &&
                    event.room?.text.toString() != _selectedRoom) {
                  return const SizedBox.shrink(); // Skip events not matching the filter
                }
                return ListTile(
                  title: Text(event.title),
                  leading:
                    Text('${event.start.hour.toString().padLeft(2, '0')}:'
                      '${event.start.minute.toString().padLeft(2, '0')}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration? duration) {
    if (duration == null) {
      return '--:--:--';
    }
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days == 0) {
      return
        '${hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : ''}'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
    } else {
      return
        '${days > 0 ? '${days.toString().padLeft(2, '0')}d ' : ''}'
            '${hours > 0 ? '${hours.toString().padLeft(2, '0')}h ' : ''}'
            '${minutes > 0 ? '${minutes.toString().padLeft(2, '0')}m ' : ''}'
            '${hours == 0 ? '${seconds.toString().padLeft(2, '0')}s' : ''}';
    }
  }
}
