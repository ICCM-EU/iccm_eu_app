import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsProvider extends ProviderData<EventData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Sessions";
  @override
  String get cacheTitle => "_eventDataCache";

  late List<EventData> _items;
  List<EventData> items() {
    populateItemsFromCache();
    return _items;
  }

  final List<EventData> _cache = [];

  @override
  void cacheAdd(EventData item) {
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

  Future<List<EventData>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(cacheTitle);
    if (cacheJson != null) {
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      return jsonList.map((json) => EventData.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
