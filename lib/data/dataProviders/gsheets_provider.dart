import 'dart:convert';
import 'dart:core';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import '../model/error_signal.dart';
import 'error_provider.dart';

class GsheetsProvider with ChangeNotifier {
  final String _sheetID =
      '1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE';
  bool _isFetchingData = false;
  late final _rawData = <String, List<Map<String, String>>>{};

  GsheetsProvider() {
    _isFetchingData = false;
  }

  Future<String> _loadCredentials(ErrorProvider? errorProvider) async {
    try {
      return await rootBundle.loadString('assets/service.json');
    } catch (e) {
      // Show overlay message
      errorProvider?.setErrorSignal(ErrorSignal('Error: $e'));
      rethrow; // Re-throw the exception to handle it elsewhere if needed
    }
  }

  String _generateChecksum(Map<String, List<Map<String, String>>> data) {
    final jsonString = jsonEncode(data); // Convert data to JSON string
    final bytes = utf8.encode(jsonString); // Encode string to bytes
    final digest = sha256.convert(bytes); // Calculate SHA-256 hash
    return digest.toString(); // Return checksum as a string
  }

  int _countDataObjects(Map<String, List<Map<String, String>>> data) {
    int totalObjects = 0;

    // Count the map itself
    // totalObjects++;

    // Iterate through keys and values
    data.forEach((key, value) {
      // totalObjects++; // Count the key (String)
      // totalObjects++; // Count the value (List)

      // Iterate through list of maps
      // totalObjects += value.length; // Count each map in the list

      // Iterate through map entries
      for (var map in value) {
        totalObjects += map.length; // Count each key in the map
        // totalObjects += map.length; // Count each value in the map
      }
    });

    return totalObjects;
  }

  Future<void> _readWorksheets({
      required List<String> worksheetTitles,
      ErrorProvider? errorProvider,
  }) async {
    try {
      final credentials = await _loadCredentials(errorProvider);
      final sheets = GSheets(credentials);
      final spreadsheet = await sheets.spreadsheet(_sheetID);

      for (final worksheetTitle in worksheetTitles) {
        final worksheet = spreadsheet.worksheetByTitle(worksheetTitle);
        if (worksheet == null) {
          throw Exception('Worksheet "$worksheetTitle" not found.');
        } else {
          final rows = await worksheet.values.map.allRows() ?? [];
          _rawData[worksheetTitle] = rows;
        }
      }
    } catch (e, stackTrace) {
      final RegExp regExp = RegExp(r'#0 +([^\s]+) \(([^\s]+):([0-9]+)\)');
      final Match? match = regExp.firstMatch(stackTrace.toString());
      final fileName = match?.group(2) ?? 'unknown';
      final lineNumber = match?.group(3) ?? 'unknown';
      errorProvider?.setErrorSignal(ErrorSignal('Error ($fileName:$lineNumber): $e'));
    }
  }

  Future<void> fetchData({
    ErrorProvider? errorProvider,
    bool force = false,
  }) async {
    if (_isFetchingData) {
      return;
    }
    _isFetchingData = true;

    DateTime now = DateTime.now();
    DateTime? lastUpdated = await PreferencesProvider.cacheLastUpdated;
    if (! force &&
        (lastUpdated != null && lastUpdated.isBefore(now.subtract(
            const Duration(minutes: 4, seconds: 50,))))
    ) {
      final Duration duration = now.difference(lastUpdated);
      Debug.msg('Fetch omitted. (${force ? 'force' : 'noforce'}, '
          '${duration..inMinutes})');
      _isFetchingData = false;
      return;
    }

    List<String> workSheetTitles = [];
    workSheetTitles.add(EventsProvider.worksheetTitle);
    workSheetTitles.add(RoomsProvider.worksheetTitle);
    workSheetTitles.add(SpeakersProvider.worksheetTitle);
    workSheetTitles.add(TracksProvider.worksheetTitle);

    await _readWorksheets(
        worksheetTitles: workSheetTitles,
        errorProvider: errorProvider);

    // Terminate if data is empty
    if (_countDataObjects(_rawData) == 0) {
      _isFetchingData = false;
      Debug.msg("Fetch: Not data found.");
      return;
    }

    String cachedChecksum = await PreferencesProvider.cachedChecksum;
    String dataChecksum = _generateChecksum(_rawData);

    if (lastUpdated == null || cachedChecksum != dataChecksum || force) {
      await PreferencesProvider.setCachedChecksum(dataChecksum);
      await PreferencesProvider.setLastUpdated(now);

    }
    notifyListeners();
    Debug.msg("Fetch completed successfully.");
    _isFetchingData = false;
  }

  List<Map<String, String>>? getEventData() {
    String worksheetTitle = EventsProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }

  List<Map<String, String>>? getRoomData() {
    String worksheetTitle = RoomsProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }

  List<Map<String, String>>? getSpeakerData() {
    String worksheetTitle = SpeakersProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }

  List<Map<String, String>>? getTrackData() {
    String worksheetTitle = TracksProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }
}