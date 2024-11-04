import 'package:flutter/material.dart';

class FetchTriggerProvider with ChangeNotifier {
  void triggerFetch() {
    notifyListeners();
  }
}
