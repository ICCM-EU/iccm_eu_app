import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:iccm_eu_app/data/appProviders/next_event_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/gsheets_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/notification_channel_data.dart';
import 'package:iccm_eu_app/data/notifications/local_notification_service.dart';
import 'package:iccm_eu_app/data/testData/test_data.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import 'package:iccm_eu_app/utils/id_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsProvider with ChangeNotifier  {
  static String get worksheetTitle => "Sessions";
  String get _cacheTitle => "_eventDataCache";
  final GsheetsProvider _gsheetsProvider;
  final List<int> _notificationIDs = [];

  final List<EventData> _cache = [];

  final NotificationChannelData _channelData = NotificationChannelData(
      name: 'Announcement Events',
      id: 'event_announcements',
      description: 'Announcements and reminders after breaks',
  );

  final List<EventData> _items = [];
  List<EventData> items() {
    return _items;
  }

  EventsProvider({
    required GsheetsProvider gsheetsProvider,
  }) : _gsheetsProvider = gsheetsProvider {
    _gsheetsProvider.addListener(updateCache);
    _loadCache();
    _populateItemsFromCache();
    LocalNotificationService.init(
      channelData: _channelData,
    );
  }

  @override
  void dispose() {
    NextEventNotifier.stopTimer();
    super.dispose();
  }

  void updateCache() {
    if (EventsProvider.showTestDataOption() &&
        PreferencesProvider.useTestDataNotifier.value) {
      _cacheClear();
      for (EventData item in TestData.getEvents()) {
        _cacheAdd(item);
      }
    } else { // Process raw data from GsheetsProvider and update _tracks
      var data = _gsheetsProvider.getEventData();
      if (data != null && data.isNotEmpty) {
        _cacheClear();
        for (final itemData in data) {
          _cacheAdd(EventData.fromItemData(itemData));
        }
      }
    }
    _commit();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_cacheTitle);
    if (cacheJson != null && cacheJson.isNotEmpty) {
      // Debug.msg(cacheJson);
      _cacheClear();
      final List<dynamic> jsonList = jsonDecode(cacheJson);
      jsonList.map((json) => EventData.fromJson(json)).toList().forEach((item) {
        _cacheAdd(item);
      });
      Debug.msg('Cache loaded: Events');
      _commit();
    } else {
      Debug.msg('Cache OMITTED: Events');
    }
  }

  void _cacheAdd(EventData item) {
    _cache.add(item);
  }

  void _cacheClear() {
    _cache.clear();
  }

  void _commit() async {
    _cache.sort((a, b) => a.start.compareTo(b.start));
    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].id == null || _cache[i].id == 0) {
        _cache[i].id = await IdGenerator.generateItemId();
      }
    }
    _saveCache();
    _populateItemsFromCache();
    NextEventNotifier.startTimer(this);
    _registerNotifications();
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
    for (int id in _notificationIDs) {
      LocalNotificationService.cancelNotification(id, null);
    }
    _notificationIDs.clear();

    DateTime now = DateTime.now();
    Debug.msg('REGISTER after $now');
    for (EventData item in _items.where(
            (event) =>
        (((event.forceNotify ?? false) == true) &&
            LocalNotificationService.scheduleAhead(
                time: event.start,
            ).isAfter(now))).toList()
    ) {
      _notificationIDs.add(item.id ?? 0);
      DateTime notificationTime = LocalNotificationService.scheduleAhead(
        time: item.start,
      );
      Debug.msg('ANNOUNCE ${item.name} at ${item
          .start} ($notificationTime) with ID ${item.id ?? 0}');
      LocalNotificationService.scheduleNotification(
          title: 'Upcoming: ${item.name}',
          body: item.description,
          id: item.id,
          scheduledDate: notificationTime,
        channelData: _channelData,
      );
    }
  }

  EventData earliestEvent ({List<EventData>? items}) {
    items ??= _items;
    if (items.isEmpty) {
      return EventData(
        name: '---',
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: '',
      );
    }
    return items.first;
  }

  EventData latestEvent ({List<EventData>? items}) {
    items ??= _items;
    if (items.isEmpty) {
      return EventData(
        name: '---',
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 1,)),
        details: '',
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
    bool withCurrent = true,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }
    final DateTime now = DateTime.now();
    if (withCurrent) {
      return items.where(
              (item) =>
          item.end.isAfter(now) ||
              item.end.isAtSameMomentAs(now)).toList();
    } else {
      return items.where(
              (item) =>
          item.start.isAfter(now) ||
              item.start.isAtSameMomentAs(now)).toList();
    }
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
        item.room?.compareTo(name) == 0).toList();
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
        item.track?.compareTo(name) == 0).toList();
  }

  List<EventData> eventsByParallel({
    required EventData current,
    List<EventData>? items,
    required String parallel,
  }) {
    items ??= _items;
    if (items.isEmpty) {
      return [];
    }
    return items.where(
            (item) =>
        item.parallelSessions?.compareTo(parallel) == 0 &&
        current.name.compareTo(item.name) != 0
    ).toList();
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
        item.speaker?.compareTo(name) == 0).toList();
  }

  List<EventData> currentEvents({
    String? room,
  }) {
    List<EventData> items;
    if (room == null) {
      items = _items;
    } else {
      items = eventsByRoom(name: room);
    }
    if (items.isEmpty) {
      return [];
    }
    DateTime now = DateTime.now();
    return items.where(
      (item) =>
          item.start.isBefore(now) && item.end.isAfter(now)
    ).toList();
  }

  List<EventData> nextEvents({
    String? room,
    bool withCurrent = false,
  }) {
    List<EventData> items;
    DateTime now = DateTime.now();
    if (room == null) {
      items = _items;
    } else {
      items = eventsByRoom(name: room);
    }
    if (items.isEmpty) {
      return [];
    }
    DateTime? next = nextStartTime(room: room);
    if (next == null) {
      return [];
    }
    if (withCurrent) {
      return items.where(
        (item) =>
          item.start.isAtSameMomentAs(next) ||
            item.start.isAtSameMomentAs(now) ||
            (item.start.isBefore(now) && item.end.isAfter(now))
      ).toList();
    } else {
      return items.where(
              (item) =>
              item.start.isAtSameMomentAs(next)
      ).toList();
    }
  }

  DateTime? nextStartTime({
    String? room,
  }) {
    List<EventData> items;
    if (room == null) {
      items = _items;
    } else {
      items = eventsByRoom(name: room);
    }
    if (items.isEmpty) {
      return null;
    }
    EventData? next;
    try {
      next = items.firstWhere(
            (item) => item.start.isAfter(DateTime.now()),
      );
    } catch (e) {
      next = null;
    }
    if (next == null) {
      return null;
    } else {
      return next.start;
    }
  }

  static bool showTestDataOption() {
    bool value = kDebugMode;
    // Overwrite during development
    //value = true;
    return value;
  }
}
