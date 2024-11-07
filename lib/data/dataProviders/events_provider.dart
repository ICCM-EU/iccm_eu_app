import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsProvider with ChangeNotifier  {
  static String get worksheetTitle => "Sessions";
  String get _cacheTitle => "_eventDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<EventData> _cache = [];

  final List<EventData> _items = [];
  List<EventData> items() {
    _populateItemsFromCache();
    return _items;
  }

  EventsProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
  }

  void updateCache() {
    // Process raw data from GsheetsProvider and update _tracks
    var data = _gsheetsProvider.getEventData();
    if (data != null && data.isNotEmpty) {
      _cacheClear();
      for (final itemData in data) {
        _cacheAdd(EventData.fromItemData(itemData));
      }
      _commit();
    }
    notifyListeners();
  }

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => EventData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      _commit();
    }
  }

  void _cacheAdd(EventData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() {
    _cache.sort((a, b) => a.start.compareTo(b.start));
    _fillCacheItemIds();
    _saveCache();
    _populateItemsFromCache();
    notifyListeners();
  }

  void _fillCacheItemIds() {
    for (int i = 0; i < _cache.length; i++) {
      _cache[i].id = i;
    }
  }

  void _populateItemsFromCache() {
    if (_cache.isNotEmpty) {
      _items.clear();
      for (var item in _cache) {
        _items.add(item);
      }
      // notifyListeners();
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = jsonEncode(_cache); // Convert _cache to JSON string
    await prefs.setString(_cacheTitle, cacheJson); // Save to SharedPreferences
  }

  EventData earliestEvent ({List<EventData>? items}) {
    items ??= _items;
    if (items.isEmpty) {
      return EventData(
        name: TextSpan(text: '---'),
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: TextSpan(text: ''),
      );
    }

    return items.first;
  }

  EventData latestEvent ({List<EventData>? items}) {
    items ??= _items;
    if (items.isEmpty) {
      return EventData(
        name: TextSpan(text: '---'),
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: TextSpan(text: ''),
      );
    }

    return items.last;
  }

  List<EventData> cutoffAfterDays({
    required int days,
    List<EventData>? items,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }
    final DateTime firstEventDate = earliestEvent().start;
    final cutoffDate = firstEventDate.add(Duration(days: days));

    return items.where(
            (item) =>
        item.end.isBefore(cutoffDate) ||
            item.end.isAtSameMomentAs(cutoffDate)).toList();
  }

  List<EventData> filterPastEvents({
    List<EventData>? items,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }
    final DateTime now = DateTime.now();

    return items.where(
            (item) =>
        item.end.isAfter(now) ||
            item.end.isAtSameMomentAs(now)).toList();
  }

  List<EventData> eventsByRoom({
    List<EventData>? items,
    required String name,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }

    return items.where(
            (item) =>
        item.room?.toPlainText().compareTo(name) == 0).toList();
  }

  List<EventData> eventsByTrack({
    List<EventData>? items,
    required String name,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }

    return items.where(
            (item) =>
        item.track?.toPlainText().compareTo(name) == 0).toList();
  }

  List<EventData> eventsBySpeaker({
    List<EventData>? items,
    required String name,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }

    return items.where(
            (item) =>
        item.toString().compareTo(name) == 0).toList();
  }
}
