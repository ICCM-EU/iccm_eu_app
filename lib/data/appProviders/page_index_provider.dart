import 'package:flutter/material.dart';

class PageIndexProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex  => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}