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

  late final List<EventData> _items = [];
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
    _cache.sort((a, b) => a.start.compareTo(b.start));
    saveCache();
    populateItemsFromCache();
  }

  @override
  void populateItemsFromCache() {
    if (_cache.isNotEmpty) {
      _items.clear();
      for (var item in _cache) {
        _items.add(item);
      }
      notifyListeners();
    }
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

  EventData get earliestEvent {
    if (_cache.isEmpty) {
      return EventData(
        name: TextSpan(text: '---'),
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: TextSpan(text: ''),
      );
    }

    return _cache.first;
  }

  EventData get latestEvent {
    if (_cache.isEmpty) {
      return EventData(
        name: TextSpan(text: '---'),
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: TextSpan(text: ''),
      );
    }

    return _cache.last;
  }
}
