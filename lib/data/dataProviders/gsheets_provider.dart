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
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/room_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:provider/provider.dart';
import '../model/error_signal.dart';
import '../model/provider_data.dart';
import 'error_provider.dart';

class GsheetsProvider with ChangeNotifier {
  final String _sheetID =
      '1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE';
  bool _isFetchingData = false;

  Future<String> _loadCredentials(ErrorProvider errorProvider) async {
    try {
      return await rootBundle.loadString('assets/service.json');
    } catch (e) {
      // Show overlay message
      errorProvider.setErrorSignal(ErrorSignal('Error: $e'));
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

  Future<Map<String, List<Map<String, String>>>> _readWorksheets(
      List<String> worksheetTitles,
      BuildContext context,
      ) async {
    ErrorProvider errorProvider =
      Provider.of<ErrorProvider>(context, listen: false);
    final data = <String, List<Map<String, String>>>{};
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
          data[worksheetTitle] = rows;
        }
      }
    } catch (e, stackTrace) {
      final RegExp regExp = RegExp(r'#0 +([^\s]+) \(([^\s]+):([0-9]+)\)');
      final Match? match = regExp.firstMatch(stackTrace.toString());
      final fileName = match?.group(2) ?? 'unknown';
      final lineNumber = match?.group(3) ?? 'unknown';
      errorProvider.setErrorSignal(ErrorSignal('Error ($fileName:$lineNumber): $e'));
    }

    return data;
  }

  Future<void> fetchData(
      BuildContext context,
      {bool force = false}
      ) async {
    if (_isFetchingData) {
      return;
    }

    DateTime now = DateTime.now();
    DateTime? lastUpdated = await PreferencesProvider.cacheLastUpdated;
    if (force ||
        (lastUpdated != null && lastUpdated.isAfter(now.subtract(
            const Duration(minutes: 5))))
    ) {
      return;
    }

    // FIXME: Don't use 'BuildContext's across async gaps.
    ErrorProvider errorProvider = Provider.of<ErrorProvider>(
        context, listen: false);
    EventsProvider eventsProvider = Provider.of<EventsProvider>(
        context, listen: false);
    RoomsProvider roomsProvider = Provider.of<RoomsProvider>(
        context, listen: false);
    SpeakersProvider speakersProvider = Provider.of<SpeakersProvider>(
        context, listen: false);
    TracksProvider tracksProvider = Provider.of<TracksProvider>(
        context, listen: false);
    final List<ProviderData> providers = [
      eventsProvider,
      roomsProvider,
      speakersProvider,
      tracksProvider,
    ];
    final List<String> worksheetTitles = providers.map(
            (provider) => provider.worksheetTitle).toList();

    _isFetchingData = true;
    final data = await _readWorksheets(worksheetTitles, context);

    // Terminate if data is empty
    if (_countDataObjects(data) == 0) {
      return;
    }

    String cachedChecksum = await PreferencesProvider.cachedChecksum;
    String dataChecksum = _generateChecksum(data);

    if (lastUpdated != null && cachedChecksum == dataChecksum) {
      return;
    }
    await PreferencesProvider.setCachedChecksum(dataChecksum);
    await PreferencesProvider.setLastUpdated(now);

    for (final provider in providers) {
      final worksheetTitle = provider.worksheetTitle;
      if (provider == eventsProvider) {
        if (data.containsKey(worksheetTitle)) {
          provider.clear();
          for (final itemData in data[worksheetTitle]!) { // Iterate through room data
            try {
              provider.add(EventData.fromItemData(
                  itemData)); // Add the RoomData object to the list
            } catch (e) {
              // Set to null to open the request again.
              await PreferencesProvider.setLastUpdated(null);
              errorProvider.setErrorSignal(ErrorSignal('Error: $e'));
            }
          }
        }
      }

      if (provider == roomsProvider) {
        if (data.containsKey(worksheetTitle)) {
          provider.clear();
          for (final itemData in data[worksheetTitle]!) { // Iterate through room data
            provider.add(RoomData.fromItemData(
                itemData)); // Add the RoomData object to the list
          }
        }
      }

      if (provider == speakersProvider) {
        if (data.containsKey(worksheetTitle)) {
          provider.clear();
          for (final itemData in data[worksheetTitle]!) { // Iterate through room data
            provider.add(SpeakerData.fromItemData(
                itemData)); // Add the RoomData object to the list
          }
        }
      }

      if (provider == tracksProvider) {
        if (data.containsKey(worksheetTitle)) {
          provider.clear();
          for (final itemData in data[worksheetTitle]!) { // Iterate through room data
            provider.add(TrackData.fromItemData(
                itemData)); // Add the RoomData object to the list
          }
        }
      }
    }
    _isFetchingData = false;
  }
}