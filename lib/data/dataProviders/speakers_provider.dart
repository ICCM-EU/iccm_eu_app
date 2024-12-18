import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/testData/test_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeakersProvider with ChangeNotifier  {
  static String get worksheetTitle => "Speakers";
  String get _cacheTitle => "_speakerDataCache";
  final GsheetsProvider _gsheetsProvider;

  final List<SpeakerData> _cache = [];

  final List<SpeakerData> _items = [];
  List<SpeakerData> items() {
    return _items;
  }

  SpeakersProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
    _loadCache();
    _populateItemsFromCache();
  }

  void updateCache() {
    if (EventsProvider.showTestDataOption() &&
        PreferencesProvider.useTestDataNotifier.value) {
      _cacheClear();
      for (SpeakerData item in TestData.speakers) {
        _cacheAdd(item);
      }
    } else {
      // Process raw data from GsheetsProvider and update _tracks
      var data = _gsheetsProvider.getSpeakerData();
      if (data != null && data.isNotEmpty) {
        _cacheClear();
        for (final itemData in data) {
          _cacheAdd(SpeakerData.fromItemData(itemData));
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
      jsonList.map((json) => SpeakerData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Cache loaded: Speakers');
      _commit();
    } else {
      Debug.msg('Cache OMITTED: Speakers');
    }
  }

  void _cacheAdd(SpeakerData item) {
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
      // notifyListeners();
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = jsonEncode(_cache); // Convert _cache to JSON string
    await prefs.setString(_cacheTitle, cacheJson); // Save to SharedPreferences
  }

  SpeakerData? getDataByName(String name) {
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
}