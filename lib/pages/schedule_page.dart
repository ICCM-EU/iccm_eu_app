import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isDayView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(_isDayView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isDayView = !_isDayView;
              });
            },
          ),
        ],
      ),
      body: _isDayView ? DayViewCalendar() : const EventList(),
    );
  }
}

class DayViewCalendar extends StatelessWidget {
  final List<FlutterWeekViewEvent> events = [];
  DayViewCalendar({super.key})
  {
    // FIXME: Need real dates
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    events.add(
      FlutterWeekViewEvent(
        title: 'An event 1',
        description: 'A description 1',
        start: date.subtract(Duration(hours: 1)),
        end: date.add(Duration(hours: 18, minutes: 30)),
      )
    );
    events.add(
      FlutterWeekViewEvent(
        title: 'An event 2',
        description: 'A description 2',
        start: date.add(Duration(hours: 19)),
        end: date.add(Duration(hours: 22)),
      )
    );
    events.add(
      FlutterWeekViewEvent(
        title: 'An event 3',
        description: 'A description 3',
        start: date.add(Duration(hours: 23, minutes: 30)),
        end: date.add(Duration(hours: 25, minutes: 30)),
      )
    );
    events.add(
      FlutterWeekViewEvent(
        title: 'An event 4',
        description: 'A description 4',
        start: date.add(Duration(hours: 20)),
        end: date.add(Duration(hours: 21)),
      )
    );
    events.add(
      FlutterWeekViewEvent(
        title: 'An event 5',
        description: 'A description 5',
        start: date.add(Duration(hours: 20)),
        end: date.add(Duration(hours: 21)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        const Text('Day View Calendar'),
        // DayView(
        //   date: DateTime(events.first.start.day),
        //   events: events,
        //   style: DayViewStyle.fromDate(
        //     date: DateTime.now(),
        //     currentTimeCircleColor: Colors.pink,
        //   ),
        // ),
        WeekView(
          dates: [
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 1)),
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: 1)),
          ],
          events: events,
        ),
      ]
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your event list here
    return const Center(child: Text('Event List'));
  }
}