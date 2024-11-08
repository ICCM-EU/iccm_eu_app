import 'package:cached_network_image/cached_network_image.dart';
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