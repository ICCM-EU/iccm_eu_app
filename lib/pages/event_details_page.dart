import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';

class EventDetailsPage extends StatelessWidget {
  final EventData item;
  const EventDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        actions: const [
          // IconButton(
          //   icon: Icon(
          //     Icons.filter_alt,
          //     color: Colors.grey[700],
          //   ),
          //   onPressed: () {
          //
          //   },
          // ),
        ],
      ),
      body:
      ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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