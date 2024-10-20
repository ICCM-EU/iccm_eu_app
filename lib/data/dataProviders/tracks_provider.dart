import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

class TracksProvider extends ProviderData<TrackData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Tracks";

  List<TrackData> get items => _tracks;
  final List<TrackData> _tracks = [
    TrackData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Technology',
      ),
      details: const TextSpan(
        text: 'A track dedicated to technology topics with a focus '
          'on managing teams in the context of complex projects',
      ),
    ),
    TrackData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Management',
      ),
      details: const TextSpan(
        text: 'A track dedicated to management topics with a focus '
          'on managing teams in the context of complex projects',
      ),
    ),
  ];

  @override
  void add(TrackData item) {
    _tracks.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _tracks.clear();
    notifyListeners();
  }}