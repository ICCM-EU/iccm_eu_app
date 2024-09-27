import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';

class SpeakersProvider with ChangeNotifier {
  List<SpeakerData> get items => _speakers;
  final List<SpeakerData> _speakers = [
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'John Doe',
      ),
      details: const TextSpan(
        text: 'Software Engineer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Jane Doe',
      ),
      details: const TextSpan(
        text: 'Product Designer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'John Doe',
      ),
      details: const TextSpan(
        text: 'Software Engineer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Jane Doe',
      ),
      details: const TextSpan(
        text: 'Product Designer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'John Doe',
      ),
      details: const TextSpan(
        text: 'Software Engineer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Jane Doe',
      ),
      details: const TextSpan(
        text: 'Product Designer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'John Doe and a person with a very long name here which would possibly break across the lines',
      ),
      details: const TextSpan(
        text: 'Software Engineer who is engaged with a lot of development projects and would be willing to help',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Jane Doe',
      ),
      details: const TextSpan(
        text: 'Product Designer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'John Doe',
      ),
      details: const TextSpan(
        text: 'Software Engineer',
      ),
    ),
    SpeakerData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Jane Doe',
      ),
      details: const TextSpan(
        text: 'Product Designer',
      ),
    ),
    // Add more people here
  ];

  void add(SpeakerData item) {
    _speakers.add(item);
    notifyListeners();
  }

  void clear() {
    _speakers.clear();
    notifyListeners();
  }
}