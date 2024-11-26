import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/favorites_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  String get _cacheTitle => "_favoritesDataCache";

  final List<FavoritesData> _cache = [];

  final List<FavoritesData> _items = [];

  List<FavoritesData> items() {
    return _items;
  }

  FavoritesProvider() {
    _loadCache();
    _populateItemsFromCache();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => FavoritesData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Cache loaded: Favorites');
      _commit();
    } else {
      Debug.msg('Cache OMITTED: Favorites');
    }
  }

  void _cacheAdd(FavoritesData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() {
    _cache.sort((a, b) => a.eventName.compareTo(b.eventName));
    _saveCache();
    _populateItemsFromCache();
    notifyListeners();
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

  bool isInFavorites(String eventName) {
    return _items.where((item) => item.eventName == eventName).isNotEmpty;
  }

  void addEvent(String eventName) {
    _cacheAdd(FavoritesData(eventName: eventName));
    _commit();
  }

  void rmEvent(String eventName) {
    _cache.removeWhere((item) => item.eventName == eventName);
    _commit();
  }
}
