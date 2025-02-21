import 'package:flutter/material.dart';

class ExpandContentProvider with ChangeNotifier {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void setIsExpanded(bool value) {
    _isExpanded = value;
    notifyListeners();
  }
}