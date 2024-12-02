import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:iccm_eu_app/utils/debug.dart';
import '../model/error_signal.dart';
import 'error_provider.dart';

class GsheetsProvider with ChangeNotifier {
  final String _sheetId =
      '1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE';
  final _deploymentID =
      'AKfycbwQXXQuHnI0lyf5UU6RGkO7MQMb7BtUr-KkoRdBbruy7IZgh5qCXlKLpZ_Y0siXCto5';
  bool _isFetchingData = false;
  late final _rawData = <String, List<Map<String, String>>>{};

  GsheetsProvider() {
    _isFetchingData = false;
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

  Future<Map<String, dynamic>> _triggerWebAPP({required Map body}) async {
    Map<String, dynamic> dataDict = {};
    Uri url =
      Uri.parse("https://script.google.com/macros/s/$_deploymentID/exec");
    try {
      // Debug.msg("_triggerWebAPP post: $url");
      // Debug.msg("_triggerWebAPP body: $body");
      await http.post(
          url,
          body: body,
      ).then((response) async {
        // Debug.msg("_triggerWebAPP status: ${response.statusCode.toString()}");
        if ([200, 201].contains(response.statusCode)) {
          // Debug.msg("_triggerWebAPP body: ${response.body}");
          dataDict = jsonDecode(response.body);
        }
        if (response.statusCode == 302) {
          String redirectedUrl = response.headers['location'] ?? "";
          if (redirectedUrl.isNotEmpty) {
            // Debug.msg("_triggerWebAPP redirect: $redirectedUrl");
            Uri url = Uri.parse(redirectedUrl);
            await http.get(url).then((response) {
              if ([200, 201].contains(response.statusCode)) {
                dataDict = jsonDecode(response.body);
              }
            });
          }
        // } else {
        //   Debug.msg("_triggerWebAPP statusCode: ${response.statusCode.toString()}");
        }
      });
    } catch (e) {
      Debug.msg("_triggerWebAPP FAILED: $e");
    }

    return dataDict;
  }

  Future<Map<String, dynamic>> _getSheetsData({
    required String worksheetName,
  }) async {
    Map body = {
      "sheetId": _sheetId,
      "action": 'read',
      'worksheet': worksheetName,
    };
    Map<String, dynamic> dataDict = await _triggerWebAPP(
        body: body,
    );

    return dataDict;
  }

  Future<void> _readWorksheets({
      required List<String> worksheetTitles,
      ErrorProvider? errorProvider,
  }) async {
    for (final worksheetTitle in worksheetTitles) {
      try {
        Map<String, dynamic> response =
          await _getSheetsData(worksheetName: worksheetTitle);
        if (response["status"] as String != 'SUCCESS') {
          throw Exception('Worksheet "$worksheetTitle" not loaded.');
        }
        // Debug.msg("Got data: $response");
        List<String> columns = (response['columns'] as List).cast<String>();
        List<List<dynamic>> data = (response["data"] as List)
            .map((row) => (row as List).map((e) => e.toString()).toList())
            .toList();
        List<Map<String, String>> tableRows = data.map((row) {
          Map<String, String> rowMap = {};
          for (int colIndex = 0; colIndex < columns.length; colIndex++) {
            rowMap[columns[colIndex]] = row[colIndex].toString();
          }
          return rowMap;
        }).toList();
        _rawData[worksheetTitle] = tableRows;
      } catch (e, stackTrace) {
        final RegExp regExp = RegExp(r'#0 +([^\s]+) \(([^\s]+):([0-9]+)\)');
        final Match? match = regExp.firstMatch(stackTrace.toString());
        final fileName = match?.group(2) ?? 'unknown';
        final lineNumber = match?.group(3) ?? 'unknown';
        errorProvider?.setErrorSignal(
            ErrorSignal('Fetch Error ($fileName:$lineNumber): $e\n$stackTrace'));
      }
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
    // set lastUpdated out of silent range
    lastUpdated ??= DateTime.now().subtract(Duration(hours: 12));
    if (lastUpdated.isAfter(now.subtract(
            const Duration(minutes: 4, seconds: 50,))) &&
        !force
    ) {
      String duration = 'unset';
      duration = now.difference(lastUpdated).inMinutes.toString();
      Debug.msg('Fetch omitted. (${force ? 'force' : 'noforce'}, '
          '$duration since $now)');
      _isFetchingData = false;
      return;
    }

    if (!kDebugMode || !PreferencesProvider.useTestDataNotifier.value) {
      List<String> workSheetTitles = [];
      workSheetTitles.add(EventsProvider.worksheetTitle);
      workSheetTitles.add(RoomsProvider.worksheetTitle);
      workSheetTitles.add(SpeakersProvider.worksheetTitle);
      workSheetTitles.add(TracksProvider.worksheetTitle);
      workSheetTitles.add(HomeProvider.worksheetTitle);
      workSheetTitles.add(TravelProvider.worksheetTitle);
      workSheetTitles.add(TravelDetailsProvider.worksheetTitle);

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

      if (cachedChecksum != dataChecksum || force) {
        await PreferencesProvider.setCachedChecksum(dataChecksum);
        await PreferencesProvider.setLastUpdated(now);
      }
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

  List<Map<String, String>>? getHomeData() {
    String worksheetTitle = HomeProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }

  List<Map<String, String>>? getTravelData() {
    String worksheetTitle = TravelProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }

  List<Map<String, String>>? getTravelDirectionsData() {
    String worksheetTitle = TravelDetailsProvider.worksheetTitle;
    if (_rawData.containsKey(worksheetTitle)) {
      return _rawData[worksheetTitle];
    }
    return null;
  }
}