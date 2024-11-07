import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/dataProviders/error_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:provider/provider.dart';

class EventDetailsPage extends StatefulWidget {
  final EventData item;
  const EventDetailsPage({
    super.key,
    required this.item,
  });

  @override
  EventDetailsPageState createState() => EventDetailsPageState();
}

class EventDetailsPageState extends State<EventDetailsPage> {
  late Timer _timer;

  void _fetchData({bool force = false}) {
    Provider.of<GsheetsProvider>(context, listen: true).fetchData(
      errorProvider: Provider.of<ErrorProvider>(context, listen: false),
      force: force,
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchData(); // Call fetchData every 5 minutes
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<EventsProvider>(context, listen: true).loadCache;
    _fetchData(); // Call fetchData initially
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EventData item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        actions: const [
        ],
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.imageUrl!.startsWith("http"))
                  CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 50,
                    ),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                else
                  const SizedBox.shrink(), // Display a placeholder widget
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                      text: item.title,
                  ),
                  // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                (item.room != null) ?
                  RichText(
                    text: item.room ?? const TextSpan(text: ''),
                    // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ) :
                    const SizedBox.shrink(),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: item.description,
                  ),
                  // style: const TextStyle(fontSize: 18),
                ),
                // Add more details here as needed
              ],
            ),
          ]
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}