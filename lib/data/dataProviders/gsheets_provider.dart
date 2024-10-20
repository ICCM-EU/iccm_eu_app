import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:iccm_eu_app/data/dataProviders/events_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/rooms_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/speakers_provider.dart';
import 'package:iccm_eu_app/data/dataProviders/tracks_provider.dart';
import 'package:iccm_eu_app/data/model/event_data.dart';
import 'package:iccm_eu_app/data/model/speaker_data.dart';
import 'package:iccm_eu_app/data/model/track_data.dart';
import 'package:provider/provider.dart';

import '../model/error_signal.dart';
import '../model/provider_data.dart';
import '../model/room_data.dart';
import 'error_provider.dart';

// Reference:
// https://medium.com/@jasmeet7411/using-google-sheets-for-reading-data-in-flutter-ebc00fdff8b3

// final provider = Provider.of<GsheetsProvider>(context, listen: false);
// final data = await provider.readData('Sheet2'); // Read data from "Sheet2"

class GsheetsProvider with ChangeNotifier {
  final String _deploymentID =
      'AKfycbzqhM8Yr-1prdGImsfKhRWz36dJa3SewJUQjO5MQUVG9odYoxEBebkAi8cbgL8C54Ja';
  final String _sheetID =
      '1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE';
  final ErrorProvider _errorProvider;
  DateTime? _lastFetchTime;

  GsheetsProvider(this._errorProvider);

  Future<Map<String, List<Map<String, dynamic>>>> _readWorksheets(List<String> worksheetTitles) async {
    try {
      final sheets = GSheets(_deploymentID);
      final spreadsheet = await sheets.spreadsheet(_sheetID);

      final data = <String, List<Map<String, dynamic>>>{};
      for (final worksheetTitle in worksheetTitles) {
        final worksheet = spreadsheet.worksheetByTitle(worksheetTitle);
        if (worksheet == null) {
          throw Exception('Worksheet "$worksheetTitle" not found.');
        } else {
          final rows = await worksheet.values.map.allRows() ?? [];
          data[worksheetTitle] = rows.map((row) => _rowToMap(
              row as List,
              worksheet
          )).cast<Map<String, dynamic>>().toList();
        }
      }

      return data;
    } catch (e) {
      // Show overlay message
      _errorProvider.setErrorSignal(ErrorSignal('Error: $e'));
      rethrow; // Re-throw the exception to handle it elsewhere if needed
    }
  }

  Future<void> fetchData(
      BuildContext context,
      {bool force = false}
      ) async {
    DateTime now = DateTime.now();

    // Unblock running again by setting _lastFetchTime to null on force
    if (force) {
      _lastFetchTime = null;
    }
    // Avoid running multiple times in parallel by setting the date early
    if (_lastFetchTime == null ||
        now.difference(_lastFetchTime!) > const Duration(minutes: 5)) {
      _lastFetchTime = now;

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
      final data = await _readWorksheets(worksheetTitles);

      for (final provider in providers) {
        var worksheetTitle = provider.worksheetTitle;
        if (provider == eventsProvider) {
          if (data.containsKey(worksheetTitle)) {
            provider.clear();
            for (final itemData in data[worksheetTitle]!) { // Iterate through room data
              try {
                final item = EventData(
                  imageUrl: itemData['Photo'] as String,
                  name: TextSpan(text: itemData['Name'] as String),
                  details: TextSpan(text: itemData['Description'] as String),
                  // final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                  // final dateTime = dateFormat.parse(dateTimeString);
                  start: DateTime.parse(itemData['Start'] as String),
                  end: DateTime.parse(itemData['End'] as String),
                );
                provider.add(item); // Add the RoomData object to the list
              } catch (e) {
                // Set to null to open the request again.
                _lastFetchTime = null;
                _errorProvider.setErrorSignal(ErrorSignal('Error: $e'));
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
                imageUrl: itemData['Photo'] as String,
                name: TextSpan(text: itemData['Name'] as String),
                details: TextSpan(text: itemData['Description'] as String),
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
                imageUrl: itemData['Photo'] as String,
                name: TextSpan(text: itemData['Name'] as String),
                details: TextSpan(text: itemData['Description'] as String),
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
                imageUrl: itemData['Photo'] as String,
                name: TextSpan(text: itemData['Name'] as String),
                details: TextSpan(text: itemData['Description'] as String),
              );
              provider.add(item); // Add the RoomData object to the list
            }
          }
        }
      }
    }
  }

  Future <Map<String, dynamic>> _rowToMap(List<dynamic> row, Worksheet worksheet) async {
    final headers = await worksheet.values.row(1);
    final map = <String, dynamic>{};
    for (var i = 0; i < headers.length; i++) {
      map[headers[i]] = row[i];
    }
    return map;
  }
}