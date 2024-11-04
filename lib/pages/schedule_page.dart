import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:iccm_eu_app/components/date_functions.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/components/text_functions.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadIsDayView(); // Call the asynchronous function
  }

  Future<void> _loadIsDayView() async {
    _isDayView = await PreferencesProvider.isDayView;
    setState(() {}); // Trigger a rebuild after updating _isDayView
  }

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
                PreferencesProvider.setIsDayView(_isDayView);
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
  const DayViewCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement your day view calendar here
    return Column(
      children: [
        Expanded(
          child: Consumer<EventsProvider>( // Wrap with Consumer
            builder: (context, itemList, child) {
              final dates = <DateTime>[];
              DateTime current = itemList.earliestEvent.start;
              DateTime last = itemList.latestEvent.end;
              while (current.isBefore(last) ||
                  current.isAtSameMomentAs(last)) {
                dates.add(current);
                current = current.add(const Duration(days: 1));
              }
              DateTime initialTime = DateTime.now();
              if (initialTime.isBefore(itemList.earliestEvent.start)) {
                initialTime = itemList.earliestEvent.start;
              } else if (initialTime.isAfter(itemList.latestEvent.end)) {
                initialTime = itemList.latestEvent.end;
              }
              return WeekView(
                // dayBarStyleBuilder: Null,
                minimumTime: HourMinute(hour: 8, minute: 0),
                maximumTime: HourMinute(hour: 23, minute: 0),
                initialTime: initialTime,
                dates: dates,
                events: Provider.of<EventsProvider>(context).items().map((item) {
                  return EventData(
                    name: item.name,
                    details: item.details,
                    start: item.start,
                    end: item.end,
                    backgroundColor: item.backgroundColor, // Add other properties as needed
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
              return ListView.builder(
                itemCount: itemList.items().length,
                itemBuilder: (context, index) {
                  final item = itemList.items()[index];
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
                                format: 'EEE, dd.MM., hh:mm'),
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