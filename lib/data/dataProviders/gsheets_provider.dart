import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
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
  DateTime _lastFetchTime = DateTime.now().subtract(const Duration(days: 365));
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
          // final headers = rows[0].values.toList();
          // // Remove header row after extracting it.
          // rows.removeAt(0);
          data[worksheetTitle] = rows;
          //.map((row) {
          //   // Get the values of the map as a list
          //   final rowData = row.values.toList();
          //   return _rowToMap(rowData, headers);
          // }).cast<Map<String, dynamic>>().toList();
        }
      }
    } catch (e, stackTrace) {
      final RegExp regExp = RegExp(r'#0 +([^\s]+) \(([^\s]+):([0-9]+)\)');
      final Match? match = regExp.firstMatch(stackTrace.toString());
      final fileName = match?.group(2) ?? 'unknown';
      final lineNumber = match?.group(3) ?? 'unknown';
      errorProvider.setErrorSignal(ErrorSignal('Error ($fileName:$lineNumber): $e'));
      // rethrow; // Re-throw the exception to handle it elsewhere if needed
    }

    return data;
  }

  // Map<String, dynamic> _rowToMap(
  //     List<dynamic> row,
  //     List<String> headers
  //     ) {
  //   final map = <String, dynamic>{};
  //   for (var i = 0; i < headers.length; i++) {
  //     map[headers[i]] = row[i];
  //   }
  //   return map;
  // }

  Future<void> fetchData(
      BuildContext context,
      {bool force = false}
      ) async {
    DateTime now = DateTime.now();

    // Unblock running again by setting _lastFetchTime to null on force
    if (force) {
      _lastFetchTime = DateTime.now().subtract(const Duration(days: 365));
    }
    // Avoid running multiple times in parallel by setting the date early
    if (now.difference(_lastFetchTime) > const Duration(minutes: 5)) {
      _lastFetchTime = now;
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
      if (_isFetchingData) {
        return;
      }
      _isFetchingData = true;
      final data = await _readWorksheets(worksheetTitles, context).then((data) {
        _isFetchingData = false;
        return data;
      });

      for (final provider in providers) {
        final worksheetTitle = provider.worksheetTitle;
        if (provider == eventsProvider) {
          if (data.containsKey(worksheetTitle)) {
            provider.clear();
            for (final itemData in data[worksheetTitle]!) { // Iterate through room data
              try {
                final startValue = double.tryParse(itemData['StartTime'] ?? '0') ?? 0;
                final startDaysSinceEpoch = startValue - 25569;
                final startMsSinceEpoch = startDaysSinceEpoch * 24 * 60 * 60 * 1000;
                final startTime = DateTime.fromMillisecondsSinceEpoch(startMsSinceEpoch.toInt());
                final endValue = double.tryParse(itemData['End Date & Time'] ?? '0') ?? 0;
                final endDaysSinceEpoch = endValue - 25569;
                final endMsSinceEpoch = endDaysSinceEpoch * 24 * 60 * 60 * 1000;
                final endTime = DateTime.fromMillisecondsSinceEpoch(endMsSinceEpoch.toInt());
                final item = EventData(
                  imageUrl: itemData['Photo'] ?? '',
                  name: TextSpan(text: itemData['Session'] ?? ''),
                  details: TextSpan(text: itemData['Description'] ?? ''),
                  // final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                  // final dateTime = dateFormat.parse(dateTimeString);
                  start: startTime,
                  end: endTime,
                );
                provider.add(item); // Add the RoomData object to the list
              } catch (e) {
                // Set to null to open the request again.
                _lastFetchTime = DateTime.now().subtract(const Duration(days: 365));
                errorProvider.setErrorSignal(ErrorSignal('Error: $e'));
                rethrow;
              }
            }
          }
        }

        if (provider == roomsProvider) {
          if (data.containsKey(worksheetTitle)) {
            provider.clear();
            for (final itemData in data[worksheetTitle]!) { // Iterate through room data
              final item = RoomData(
                imageUrl: itemData['Photo 1'] ?? '',
                name: TextSpan(text: itemData['Name'] ?? ''),
                details: TextSpan(text: itemData['Description'] ?? ''),
              );
              provider.add(item); // Add the RoomData object to the list
            }
          }
        }

        if (provider == speakersProvider) {
          if (data.containsKey(worksheetTitle)) {
            provider.clear();
            for (final itemData in data[worksheetTitle]!) { // Iterate through room data
              final item = SpeakerData(
                imageUrl: itemData['Photo'] ?? '',
                name: TextSpan(text: itemData['Name'] ?? ''),
                details: TextSpan(text: itemData['Bio'] ?? ''),
              );
              provider.add(item); // Add the RoomData object to the list
            }
          }
        }

        if (provider == tracksProvider) {
          if (data.containsKey(worksheetTitle)) {
            provider.clear();
            for (final itemData in data[worksheetTitle]!) { // Iterate through room data
              final item = TrackData(
                imageUrl: itemData['Photo'] ?? '',
                name: TextSpan(text: itemData['Name'] ?? ''),
                details: TextSpan(text: itemData['Description'] ?? ''),
              );
              provider.add(item); // Add the RoomData object to the list
            }
          }
        }
      }
    }
  }
}