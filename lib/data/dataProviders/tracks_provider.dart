import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TracksProvider with ChangeNotifier  {
  static String get worksheetTitle => "Category";
  String get _cacheTitle => "_trackDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<TrackData> _cache = [];

  final List<TrackData> _items = [];
  List<TrackData> items() {
    _populateItemsFromCache();
    return _items;
  }

  TracksProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
  }

  void updateCache() {
    // Process raw data from GsheetsProvider and update _tracks
    var data = _gsheetsProvider.getTrackData();
    if (data != null && data.isNotEmpty) {
      _cacheClear();
      for (final itemData in data) {
        _cacheAdd(TrackData.fromItemData(itemData));
      }
      _commit();
    }
  }

  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => TrackData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      _commit();
    }
  }

  void _cacheAdd(TrackData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() {
    _cache.sort((a, b) => a.name.toPlainText().compareTo(b.name.toPlainText()));
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
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = jsonEncode(_cache); // Convert _cache to JSON string
    await prefs.setString(_cacheTitle, cacheJson); // Save to SharedPreferences
  }
}
