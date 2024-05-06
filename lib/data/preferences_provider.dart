import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsProvider with ChangeNotifier {
// ---------------------------------------------------------

  late Map<String, Object> jsonData = {};
  late bool darkMode = false;

  void updatePrefsData(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Register all preferences here
    final updatedData = jsonData;
    updatedData[key] = value;
    if (!mapEquals(jsonData, updatedData)) {
      setState(() {
        jsonData = updatedData;
      });
      prefs.setString('data', jsonEncode(jsonData));
    }
  }

  void loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      var dataString = prefs.getString('data');
      jsonData = dataString != null
          ? Map<String, Object>.from(jsonDecode(dataString))
          : {};
      darkMode = jsonData['darkMode'] == true;
    });
  }

  void clearPrefsData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void clearPrefsKey(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
// ---------------------------------------------------------
}

