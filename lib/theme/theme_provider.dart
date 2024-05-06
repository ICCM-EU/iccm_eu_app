import 'package:flutter/material.dart';
import "package:provider/provider.dart" show Provider;

import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';
import 'package:iccm_eu_app/data/preferences_provider.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    Provider.of<PrefsProvider>(context, listen: false).updatePrefsData('darkMode', isDark());
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      themeData = darkTheme;
    } else {
      themeData = lightTheme;
    }
  }

  bool isDark() {
    return (_themeData == darkTheme);
  }

  void setTheme(bool dark) {
    if (dark) {
      themeData = darkTheme;
    } else {
      themeData = lightTheme;
    }
  }
}