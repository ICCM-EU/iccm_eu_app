import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/definitions/item_colors_dictionary.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsProvider with ChangeNotifier  {
  static String get worksheetTitle => "Venue";
  String get _cacheTitle => "_roomDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<RoomData> _cache = [];

  final List<RoomData> _items = [];
  List<RoomData> items() {
    return _items;
  }

  RoomsProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
    _loadCache();
    _populateItemsFromCache();
    _initializeItemColors();
  }

  void updateCache() {
    // Process raw data from GsheetsProvider and update _tracks
    var data = _gsheetsProvider.getRoomData();
    if (data != null && data.isNotEmpty) {
      _cacheClear();
      for (final itemData in data) {
        _cacheAdd(RoomData.fromItemData(itemData));
      }
      _commit();
    }
    notifyListeners();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => RoomData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Rooms cache loaded');
      _commit();
    } else {
      Debug.msg('Rooms cache omitted');
    }
  }

  void _cacheAdd(RoomData item) {
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
    _initializeItemColors();
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

  RoomData? getDataByName(String name) {
    try {
      return _items.firstWhere((item) => item.name.text == name);
    } catch (e) {
      if (e is StateError) {
        // Handle the case where no matching element is found
        return null;
      } else {
        // Re-throw other exceptions
        rethrow;
      }
    }
  }

  void _initializeItemColors()
  {
    final colors = ItemColorsDictionary().colors.values.toList();
    int colorIndex = 0;
    for (var item in _items) {
      item.colors = colors[colorIndex];

      colorIndex = (colorIndex + 1) % colors.length; // Update color index, wrap around if necessary
    }
  }
}