import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iccm_eu_app/data/model/provider_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeakersProvider extends ProviderData<SpeakerData> with ChangeNotifier {
  @override
  String get worksheetTitle => "Speakers";
  @override
  String get cacheTitle => "_speakerDataCache";

  late final List<SpeakerData> _items = [];
  List<SpeakerData> items() {
    populateItemsFromCache();
    return _items;
  }

  final List<SpeakerData> _cache = [];

  @override
  void cacheAdd(SpeakerData item) {
    _cache.add(item);
  }

  @override
  void cacheClear() {
    _cache.clear();
  }

  @override
  void commit() {
    _cache.sort((a, b) => a.name.toPlainText().compareTo(b.name.toPlainText()));
    _fillCacheItemIds();
    saveCache();
    populateItemsFromCache();
  }

  void _fillCacheItemIds() {
    for (int i = 0; i < _cache.length; i++) {
      _cache[i].id = i;
    }
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

  Future<List<SpeakerData>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(cacheTitle);
    if (cacheJson != null) {
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      return jsonList.map((json) => SpeakerData.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}