import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/pages/event_details_page.dart';
import 'package:provider/provider.dart';

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
  final List<FlutterWeekViewEvent> events = EventsProvider().items;
  DayViewCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        // const Text('Day View Calendar'),
        // DayView(
        //   date: DateTime(events.first.start.day),
        //   events: events,
        //   style: DayViewStyle.fromDate(
        //     date: DateTime.now(),
        //     currentTimeCircleColor: Colors.pink,
        //   ),
        // ),
        Expanded(
          child: Consumer<EventsProvider>( // Wrap with Consumer
            builder: (context, itemList, child) {
              return WeekView(
                // dayBarStyleBuilder: Null,
                minimumTime: HourMinute(hour: 8, minute: 0),
                maximumTime: HourMinute(hour: 23, minute: 0),
                dates: [
                  DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day).subtract(Duration(days: 1)
                  ),
                  DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day
                  ),
                  DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day).add(Duration(days: 1)
                  ),
                ],
                events: Provider.of<EventsProvider>(context).items.map((event) {
                  return FlutterWeekViewEvent(
                    title: event.title,
                    description: event.description,
                    start: event.start,
                    end: event.end,
                    backgroundColor: event.backgroundColor, // Add other properties as needed
                    onTap: () {
                      final provider = Provider.of<EventsProvider>(context, listen: false);
                      final eventDetails = provider.items.firstWhere((e) => e == event);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(item: eventDetails),
                        ),
                      );
                    },
                  );
                }).toList(),
                //itemList.items,
                inScrollableWidget: true,
                userZoomable: true,
              );
            },
          ),
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