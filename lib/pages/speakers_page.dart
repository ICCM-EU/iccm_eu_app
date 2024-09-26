import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';
import 'package:iccm_eu_app/data/staticData/speakers_provider.dart';
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
                itemCount: speakers.people.length,
                itemBuilder: (context, index) {
                  final person = speakers.people[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(person.imageUrl),
                    ),
                    title: Text(person.name),
                    subtitle: Text(person.jobRole),
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
