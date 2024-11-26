import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/home_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider with ChangeNotifier {
  static String get worksheetTitle => "Home";

  String get _cacheTitle => "_homeDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<HomeData> _cache = [];

  final List<HomeData> _items = [];

  List<HomeData> items() {
    return _items;
  }

  HomeProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
    _loadCache();
    _populateItemsFromCache();
  }

  void updateCache() {
    // Process raw data from GsheetsProvider and update _tracks
    var data = _gsheetsProvider.getHomeData();
    if (data != null && data.isNotEmpty) {
      _cacheClear();
      for (final itemData in data) {
        _cacheAdd(HomeData.fromItemData(itemData));
      }
      _commit();
    }
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => HomeData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Cache loaded: Home');
      _commit();
    } else {
      Debug.msg('Cache OMITTED: Home');
    }
  }

  void _cacheAdd(HomeData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() {
    _cache.sort((a, b) => a.name.compareTo(b.name));
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
}
