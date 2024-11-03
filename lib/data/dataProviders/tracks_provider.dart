import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TracksProvider extends ProviderData<TrackData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Category";
  @override
  String get cacheTitle => "_trackDataCache";

  late List<TrackData> _items;
  List<TrackData> items() {
    populateItemsFromCache();
    return _items;
  }

  final List<TrackData> _cache = [];

  @override
  void cacheAdd(TrackData item) {
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

  Future<List<TrackData>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(cacheTitle);
    if (cacheJson != null) {
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      return jsonList.map((json) => TrackData.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
