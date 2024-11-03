import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsProvider extends ProviderData<RoomData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Venue";
  @override
  String get cacheTitle => "_roomDataCache";

  late List<RoomData> _items;
  List<RoomData> items() {
    populateItemsFromCache();
    return _items;
  }

  final List<RoomData> _cache = [];

  @override
  void cacheAdd(RoomData item) {
    _cache.add(item);
  }

  @override
  void cacheClear() {
    _cache.clear();
  }

  @override
  void commit() {
    saveCache();
    populateItemsFromCache();
  }

  @override
  void populateItemsFromCache() {
    _items.clear();
    for (var item in _cache) {
      _items.add(item);
    }
    notifyListeners();
  }

  @override
  Future<void> saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = jsonEncode(_cache); // Convert _cache to JSON string
    await prefs.setString(cacheTitle, cacheJson); // Save to SharedPreferences
  }

  Future<List<RoomData>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(cacheTitle);
    if (cacheJson != null) {
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      return jsonList.map((json) => RoomData.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}