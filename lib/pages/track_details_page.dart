import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

class TrackDetailsPage extends StatelessWidget {
  final TrackData item;
  const TrackDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Details"),
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
                CircleAvatar(
                  backgroundImage: NetworkImage(item.imageUrl),
                  radius: 50,
                ),
                const SizedBox(height: 16),
                RichText(
                  text: item.name,
                  // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: item.details,
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