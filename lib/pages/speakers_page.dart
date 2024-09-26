import 'package:flutter/material.dart';
import 'package:iccm_eu_app/components/page_title.dart';

class SpeakersPage extends StatelessWidget {
  SpeakersPage({super.key});
  final List<Person> people = [
    Person(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    Person(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    // Add more people here
  ];

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
          child:ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(person.imageUrl),
                ),
                title: Text(person.name),
                subtitle: Text(person.jobRole),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Person {
  final String imageUrl;
  final String name;
  final String jobRole;

  Person({
    required this.imageUrl,
    required this.name,
    required this.jobRole,
  });
}