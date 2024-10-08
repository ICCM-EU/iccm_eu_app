import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Reference:
// https://medium.com/@jasmeet7411/using-google-sheets-for-reading-data-in-flutter-ebc00fdff8b3

String deploymentID =
    "AKfycbzqhM8Yr-1prdGImsfKhRWz36dJa3SewJUQjO5MQUVG9odYoxEBebkAi8cbgL8C54Ja";
String sheetID = "1dFLWrcbI1AltIvVCEjBx9I3I3d0ToGN2FmzcFuAYsZE";

Future<Map> triggerWebAPP({required Map body}) async {
  Map dataDict = {};
  Uri url =
    Uri.parse("https://script.google.com/macros/s/$deploymentID/exec");
  try {
    await http.post(url, body: body).then((response) async {
      if ([200, 201].contains(response.statusCode)) {
        dataDict = jsonDecode(response.body);
      }
      if (response.statusCode == 302) {
        String redirectedUrl = response.headers['location'] ?? "";
        if (redirectedUrl.isNotEmpty) {
          Uri url = Uri.parse(redirectedUrl);
          await http.get(url).then((response) {
            if ([200, 201].contains(response.statusCode)) {
              dataDict = jsonDecode(response.body);
            }
          });
        }
      } else {
        if (kDebugMode) {
          print("Other StatusCode: ${response.statusCode}");
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print("FAILED: $e");
    }
  }

  return dataDict;
}

Future<Map> getSheetsData({required String action}) async {
  Map body = {"sheetID": sheetID, "action": action};

  Map dataDict = await triggerWebAPP(body: body);

  return dataDict;
}