import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:provider/provider.dart';

class TracksProvider extends ProviderData<TrackData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Tracks";

  List<TrackData> get items => _tracks;
  final List<TrackData> _tracks = [];
  final GsheetsProvider sheetsProvider;
  final BuildContext context;

  factory TracksProvider(BuildContext context) {
    final sheetsProvider = Provider.of<GsheetsProvider>(context, listen: false);
    return TracksProvider._(
      sheetsProvider: sheetsProvider,
      context: context,
    );
  }

  TracksProvider._({
    required this.sheetsProvider,
    required this.context,
  }) {
    add(
      TrackData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Technology',
        ),
        details: const TextSpan(
          text: 'A track dedicated to technology topics with a focus '
              'on managing teams in the context of complex projects',
        ),
      )
    );
    add(
      TrackData(
        imageUrl: 'https://via.placeholder.com/150',
        name: const TextSpan(
          text: 'Management',
        ),
        details: const TextSpan(
          text: 'A track dedicated to management topics with a focus '
              'on managing teams in the context of complex projects',
        ),
      )
    );

    sheetsProvider.fetchData(context);
  }

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