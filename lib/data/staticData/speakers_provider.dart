import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/speaker_data.dart';

class SpeakersProvider with ChangeNotifier {
  List<SpeakerData> get speaker => _speaker;
  final List<SpeakerData> _speaker = [
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      jobRole: 'Software Engineer',
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: 'Jane Doe',
      jobRole: 'Product Designer',
    ),
    // Add more people here
  ];

  void addPerson(SpeakerData person) {
    _speaker.add(person);
    notifyListeners();
  }
}