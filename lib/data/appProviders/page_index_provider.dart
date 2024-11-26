import 'package:flutter/material.dart';
import 'package:iccm_eu_app/controls/nav_bar.dart';
import 'package:iccm_eu_app/data/appProviders/preferences_provider.dart';

class PageIndexProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  PageIndexProvider() {
    _initSelectedIndex(); // Call the initialization method in the constructor
  }

  Future<void> _initSelectedIndex() async {
    _selectedIndex = await PreferencesProvider.currentNavigation;
    notifyListeners(); // Notify listeners after setting the initial value
  }

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    PreferencesProvider.setCurrentNavigation(index);
    notifyListeners();
  }

  void incrementSelectedIndex() {
    if (_selectedIndex >= 0 &&
        _selectedIndex < NavBar.bottomNavigationBarItems.length) {
      _selectedIndex ++;
      notifyListeners();
    }
  }

  void decrementSelectedIndex() {
    if (_selectedIndex > 0 &&
        _selectedIndex <= NavBar.bottomNavigationBarItems.length) {
      _selectedIndex --;
      notifyListeners();
    }
  }
}