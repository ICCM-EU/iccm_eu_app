import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:iccm_eu_app/data/appProviders/error_provider.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/communication_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/home_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_details_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/travel_provider.dart';
import 'package:iccm_eu_app/data/model/error_signal.dart';
import 'package:iccm_eu_app/utils/debug.dart';

import '../../utils/url_functions.dart';

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
    String rawUrl = "https://script.google.com/macros/s/$_deploymentID/exec";
    Uri url =
      Uri.parse(kIsWeb ? UrlFunctions.proxy(rawUrl) : rawUrl);

    try {
      Map<String, String> bodyMap =
        body.map((key, value) => MapEntry(key.toString(), value.toString()));

      var client = http.Client();
      var request = http.Request('POST', url)
        ..followRedirects = false
        ..bodyFields = bodyMap;

      var response = await client.send(request);

      if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
        String? redirectedUrl = response.headers['location'];
        await response.stream.drain();

        if (redirectedUrl != null && redirectedUrl.isNotEmpty) {
          Uri redirectUri =
            Uri.parse(kIsWeb ? UrlFunctions.proxy(redirectedUrl) : redirectedUrl);
          var getResponse = await http.get(redirectUri);
          if ([200, 201].contains(getResponse.statusCode)) {
            String bodyText = getResponse.body.trim();
            if (bodyText.startsWith('{') || bodyText.startsWith('[')) {
              dataDict = jsonDecode(bodyText);
            } else {
              Debug.msg("_triggerWebAPP returned non-JSON: $bodyText");
            }
          }
        }
      } else if ([200, 201].contains(response.statusCode)) {
        var responseBody = await response.stream.bytesToString();
        String bodyText = responseBody.trim();
        if (bodyText.startsWith('{') || bodyText.startsWith('[')) {
          dataDict = jsonDecode(bodyText);
        } else {
          Debug.msg("_triggerWebAPP returned non-JSON: $bodyText");
        }
      } else {
        await response.stream.drain();
      }
      client.close();
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
    Future<void> fetchSingleWorksheet(String worksheetTitle) async {
      try {
        Map<String, dynamic> response =
          await _getSheetsData(worksheetName: worksheetTitle);
        if ((response["status"] as String?) != 'SUCCESS') {
          throw Exception('Worksheet "$worksheetTitle" not loaded.');
        }
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

    // Fetch worksheets in small batches of 2 to avoid overloading Google Apps Script
    // concurrent execution limits.
    int batchSize = 2;
    for (int i = 0; i < worksheetTitles.length; i += batchSize) {
      List<String> batch = worksheetTitles.sublist(
        i,
        (i + batchSize < worksheetTitles.length) ? i + batchSize : worksheetTitles.length,
      );
      await Future.wait(batch.map((title) => fetchSingleWorksheet(title)));
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

    if (!EventsProvider.showTestDataOption() ||
        !PreferencesProvider.useTestDataNotifier.value) {
      List<String> workSheetTitles = [];
      workSheetTitles.add(EventsProvider.worksheetTitle);
      workSheetTitles.add(RoomsProvider.worksheetTitle);
      workSheetTitles.add(SpeakersProvider.worksheetTitle);
      workSheetTitles.add(TracksProvider.worksheetTitle);
      workSheetTitles.add(HomeProvider.worksheetTitle);
      workSheetTitles.add(CommunicationProvider.worksheetTitle);
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

  List<Map<String, String>>? getCommunicationData() {
    String worksheetTitle = CommunicationProvider.worksheetTitle;
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