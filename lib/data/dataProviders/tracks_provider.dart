import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/definitions/item_colors_dictionary.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:iccm_eu_app/data/testData/test_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TracksProvider with ChangeNotifier {
  static String get worksheetTitle => "Category";

  String get _cacheTitle => "_trackDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<TrackData> _cache = [];

  final List<TrackData> _items = [];

  List<TrackData> items() {
    return _items;
  }

  TracksProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
    _loadCache();
    _populateItemsFromCache();
    _initializeItemColors();
  }

  void updateCache() {
    if (kDebugMode && PreferencesProvider.useTestDataNotifier.value) {
      Debug.msg("Updating TrackData cache from TestData ($kDebugMode, ${PreferencesProvider.useTestDataNotifier.value}).");
      _cacheClear();
      for (TrackData item in TestData.tracks) {
        _cacheAdd(item);
      }
    } else {
      Debug.msg("Updating TrackData cache from GSheets ($kDebugMode, ${PreferencesProvider.useTestDataNotifier.value}).");
      // Process raw data from GsheetsProvider and update _tracks
      var data = _gsheetsProvider.getTrackData();
      if (data != null && data.isNotEmpty) {
        _cacheClear();
        for (final itemData in data) {
          _cacheAdd(TrackData.fromItemData(itemData));
        }
      }
    }
    _commit();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => TrackData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Cache loaded: Tracks');
      _commit();
    } else {
      Debug.msg('Cache OMITTED: Tracks');
    }
  }

  void _cacheAdd(TrackData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() {
    _cache.sort((a, b) => a.name.compareTo(b.name));
    _saveCache();
    _populateItemsFromCache();
    _initializeItemColors();
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

  TrackData? getDataByName(String name) {
    try {
      return _items.firstWhere((item) => item.name == name);
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
