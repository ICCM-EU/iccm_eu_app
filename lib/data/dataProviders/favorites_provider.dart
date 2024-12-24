import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/favorites_data.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:iccm_eu_app/utils/id_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  String get _cacheTitle => "_favoritesDataCache";
  final List<int> _registeredIDs = [];

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
      jsonList.map((json) => FavoritesData.fromJson(json)).toList().forEach((
          item) {
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

  void _commit() async {
    _cache.sort((a, b) => a.name.compareTo(b.name));
    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].id == null || _cache[i].id == 0) {
        _cache[i].id = await IdGenerator.generateItemId();
      }
    }
    _saveCache();
    _populateItemsFromCache();
    _registerNotifications();
    // _debugClass();
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

  void _registerNotifications() {
    // Selectively cancel the favorites notifications from this class.
    for (int id in _registeredIDs) {
      Debug.msg('CANCEL ID $id');
      LocalNotificationService.cancelNotification(id, null);
    }
    _registeredIDs.clear();

    DateTime now = DateTime.now();
    for (FavoritesData item in _items) {
      // Debug.msg('PROCESSING ${item.name}: ADD ${item.id ?? 0} TO _registeredIDs');
      if (item.start.isAfter(now)) {
        _registeredIDs.add(item.id ?? 0);
        DateTime notificationTime = _scheduleAhead(time: item.start);
        Debug.msg('NOTIFY ${item.name} at ${item.start} ($notificationTime) with ID ${item.id ?? 0}');
        LocalNotificationService.scheduleNotification(
          title: 'Upcoming: ${item.name}',
          body: item.details ?? '',
          id: item.id,
          scheduledDate: notificationTime,
        );
      } else {
        Debug.msg('SILENT ${item.name} at ${item.start}');
      }
    }
  }

  DateTime _scheduleAhead ({
    required DateTime time,
    Duration? before,
  }) {
    before ??= Duration(minutes: 3);
    return time.subtract(before);
  }

  bool isInFavorites({
    required String name,
    required DateTime start,
  }) {
    return _items.where((item) =>
    item.name.compareTo(name) == 0 &&
        item.start.isAtSameMomentAs(start)).isNotEmpty;
  }

  void _cleanCache(List<EventData> currentEvents) {
    List<FavoritesData> currentFavorites = List.from(_cache);
    _cache.clear();
    for (FavoritesData favorite in currentFavorites) {
      if (currentEvents.where((event) =>
      event.name.compareTo(favorite.name) == 0 &&
          event.start.isAtSameMomentAs(favorite.start)).isNotEmpty) {
        // Debug.msg('KEEP: ${favorite.name} at ${favorite.start}');
        _cache.add(favorite);
      } else {
        // Debug.msg('DROP: ${favorite.name} at ${favorite.start}');
      }
    }
  }

  void addEvent({
    required String name,
    required DateTime start,
    String? details,
    required List<EventData> currentEvents,
  }) {
    // Debug.msg('ADD: $name at $start');
    // Debug.msg('ITEMS: ${_items.length}');

    _cleanCache(currentEvents);
    _cacheAdd(FavoritesData(
      name: name,
      start: start,
      details: details ?? '',
    ));
    _commit();
  }

  void rmEvent({
    required String name,
    required DateTime start,
    required List<EventData> currentEvents,
  }) {
    // Debug.msg('DEL: $name at $start');

    _cache.removeWhere((item) =>
    item.name.compareTo(name) == 0
        && item.start.isAtSameMomentAs(start));
    _cleanCache(currentEvents);
    _commit();
  }

  // _debugClass()
  // {
  //   for (int item in _registeredIDs) {
  //     Debug.msg('== itemId: $item');
  //   }
  //   for (FavoritesData item in _cache) {
  //     Debug.msg('== cache: ${item.name} at ${item.start} ID  ${item.id}');
  //   }
  //   for (FavoritesData item in _items) {
  //     Debug.msg('== items: ${item.name} at ${item.start} ID  ${item.id}');
  //   }
  // }
}
