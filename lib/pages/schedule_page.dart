import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
      body: _isDayView ? const DayViewCalendar() : const EventList(),
    );
  }
}

class DayViewCalendar extends StatelessWidget {
  const DayViewCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        const Text('Day View Calendar'),
        SfCalendar(
          view: CalendarView.day,
          initialDisplayDate: DateTime.now(),
          // Add more properties for customization like appointments, time slots, etc.
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