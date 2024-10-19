import 'package:flutter/material.dart';

import '../model/error_signal.dart';

class ErrorProvider with ChangeNotifier {
  ErrorSignal? _errorSignal;

  ErrorSignal? get errorSignal => _errorSignal;

  void setErrorSignal(ErrorSignal signal) {
    _errorSignal = signal;
    notifyListeners();
  }

  void clearErrorSignal() {
    _errorSignal = null;
    notifyListeners();
  }
}