import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';

// Reference:
// https://medium.com/@jasmeet7411/using-google-sheets-for-reading-data-in-flutter-ebc00fdff8b3

// final provider = Provider.of<GsheetsProvider>(context, listen: false);
// final data = await provider.readData('Sheet2'); // Read data from "Sheet2"

class GsheetsProvider with ChangeNotifier {
  final String _deploymentID =
      "AKfycbzqhM8Yr-1prdGImsfKhRWz36dJa3SewJUQjO5MQUVG9odYoxEBebkAi8cbgL8C54Ja";
  final String _sheetID = "1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE";

  // final data = await provider.readData('Sheet1'); // Read data from "Sheet1"
  Future<List<Future<Map<String, dynamic>>>> readData(String worksheetTitle) async {
    final sheet = GSheets(_deploymentID);
    final spreadsheet = await sheet.spreadsheet(_sheetID);
    final worksheet = spreadsheet.worksheetByTitle(worksheetTitle);

    if (worksheet == null) {
      throw Exception('Worksheet "$worksheetTitle" not found.');
    }

    final data = await worksheet.values.map.allRows() ?? [];
    return data.map((row) => _rowToMap(row as List, worksheet)).toList();
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