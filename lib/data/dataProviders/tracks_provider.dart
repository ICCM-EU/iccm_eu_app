import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

class TracksProvider extends ProviderData<TrackData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Category";

  List<TrackData> get items => _items;
  final List<TrackData> _items = [];

  TracksProvider() {
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Call fetchData after the widget tree is built
    //   sheetsProvider.fetchData(context);
    // });
  }

  @override
  void add(TrackData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }}