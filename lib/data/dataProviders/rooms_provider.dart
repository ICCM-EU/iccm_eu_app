import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';

class RoomsProvider extends ProviderData<RoomData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Rooms";

  List<RoomData> get items => _items;
  final List<RoomData> _items = [
    RoomData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'AJAX',
      ),
      details: const TextSpan(
        text: 'Largest workshop room for the whole crowd.',
      ),
    ),
    RoomData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Basic',
      ),
      details: const TextSpan(
        text: 'Second workshop room',
      ),
    ),
    RoomData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Delphi',
      ),
      details: const TextSpan(
        text: 'Third and smallest workshop room.\n\nLeft and then right',
      ),
    ),
    RoomData(
      imageUrl: 'https://via.placeholder.com/150',
      name: const TextSpan(
        text: 'Espresso',
      ),
      details: const TextSpan(
        text: 'Room for coffee breaks.',
      ),
    ),
  ];

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