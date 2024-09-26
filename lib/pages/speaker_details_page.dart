import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/data/speaker_data.dart';

class SpeakerDetailsPage extends StatelessWidget {
  final SpeakerData speaker;
  const SpeakerDetailsPage({
    super.key,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return  ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          const PageTitle(title: 'Speaker Details'),
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
    );
  }
}