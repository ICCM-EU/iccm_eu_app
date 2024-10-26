import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';

class EventsProvider extends ProviderData<EventData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Sessions";

  List<EventData> get items => _items;
  final List<EventData> _items = [];

  @override
  void add(EventData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
