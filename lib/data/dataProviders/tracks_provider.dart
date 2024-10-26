import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';

class TracksProvider extends ProviderData<TrackData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Category";

  List<TrackData> get items => _items;
  final List<TrackData> _items = [];

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