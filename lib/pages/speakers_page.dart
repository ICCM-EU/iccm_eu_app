import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/data/staticData/speakers_provider.dart';
import 'package:iccm_eu_app/pages/speaker_details_page.dart';
import 'package:provider/provider.dart';

class SpeakersPage extends StatelessWidget {
  const SpeakersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView(
          shrinkWrap: true, // Important to prevent unbounded height issues
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for static list
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: const <Widget>[
            PageTitle(title: 'Speakers'),
          ]
        ),
        Expanded( // Use Expanded to allow ListView.builder to take available space
          child: Consumer<SpeakersProvider>( // Wrap ListView.builder with Consumer
            builder: (context, speakers, child) {
              return ListView.builder(
                itemCount: speakers.speaker.length,
                itemBuilder: (context, index) {
                  final speaker = speakers.speaker[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(speaker.imageUrl),
                    ),
                    title: Text(speaker.name),
                    subtitle: Text(speaker.jobRole),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Theme(
                            data: Theme.of(context),
                            child: SpeakerDetailsPage(speaker: speaker),
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
