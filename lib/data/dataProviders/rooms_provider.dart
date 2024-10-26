import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';

class RoomsProvider extends ProviderData<RoomData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Venue";

  List<RoomData> get items => _items;
  final List<RoomData> _items = [];

  @override
  void add(RoomData item) {
    _items.add(item);
    notifyListeners();
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }
}