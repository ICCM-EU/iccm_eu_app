import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

class SpeakerDetailsPage extends StatelessWidget {
  final SpeakerData speaker;
  const SpeakerDetailsPage({
    super.key,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speaker Details"),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.close,
          //     color: Colors.grey[700],
          //   ),
          //   onPressed: () {
          //     Navigator.pop(context); // Close fullscreen page
          //   },
          // ),
        ],
      ),
      body:
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            //const PageTitle(title: 'Speaker Details'),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(speaker.imageUrl),
                  radius: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  speaker.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  speaker.jobRole,
                  style: const TextStyle(fontSize: 18),
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