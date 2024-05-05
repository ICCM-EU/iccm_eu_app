import 'package:flutter/material.dart';
import 'package:iccm_eu_app/theme/dark_theme.dart';
import 'package:iccm_eu_app/theme/light_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
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